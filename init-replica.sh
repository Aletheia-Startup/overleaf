#!/bin/bash

set -e

echo "Waiting for MongoDB to be available..."

until mongosh --host mongo --eval "print('Mongo is up')" &>/dev/null
do
  echo "$(date) - Waiting for MongoDB..."
  sleep 2
done

echo "MongoDB is up, trying to initiate replica set..."

init_replica_set() {
  mongosh --host mongo --eval '
    try {
      rs.initiate({
        _id: "rs0",
        members: [{ _id: 0, host: "mongo:27017" }]
      });
      print("Replica set initiated successfully");
    } catch (e) {
      print("Replica set initiation failed: " + e);
      process.exit(1);
    }
  '
}

MAX_RETRIES=10
COUNT=0

until init_replica_set
do
  COUNT=$((COUNT+1))
  if [ "$COUNT" -ge "$MAX_RETRIES" ]; then
    echo "Failed to initiate replica set after $MAX_RETRIES attempts. Exiting."
    exit 1
  fi
  echo "Retrying replica set initiation in 5 seconds..."
  sleep 5
done

echo "Replica set initiated, checking status..."

mongosh --host mongo --eval 'rs.status()'

echo "Replica set is ready!"
