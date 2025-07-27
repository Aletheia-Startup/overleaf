#!/bin/bash

# Aspetta che mongo sia pronto
until mongo --eval "print('mongo is up')" > /dev/null 2>&1
do
  echo "Waiting for Mongo to be available..."
  sleep 2
done

# Controlla se replica set è già inizializzato
if ! mongo --eval "rs.status().ok" | grep 1 > /dev/null 2>&1; then
  echo "Initiating replica set..."
  mongo --eval '
    rs.initiate({
      _id: "rs0",
      members: [{ _id: 0, host: "mongo:27017" }]
    })
  '
else
  echo "Replica set already initialized."
fi

# Mostra stato replica set
echo "Checking replica set status..."
mongo --eval 'rs.status()'
