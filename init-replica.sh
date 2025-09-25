#!/bin/bash
set -e

echo "⏳ Attendo che Mongo risponda..."
until mongosh --host mongo --eval "db.adminCommand('ping')" &>/dev/null; do
  echo "$(date) - Mongo non ancora pronto, riprovo..."
  sleep 2
done

echo "⚙️ Inizializzo la replica set..."
mongosh --host mongo <<'EOF'
try {
  rs.initiate({
    _id: "rs0",
    members: [{ _id: 0, host: "mongo:27017" }]
  });
  print("✅ Replica set inizializzato con successo");
} catch (e) {
  print("ℹ️ Replica set già configurato o errore: " + e);
}
EOF
