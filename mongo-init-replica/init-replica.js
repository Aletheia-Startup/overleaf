// Controlla se MongoDB è pronto
function waitForMongo() {
  try {
    db.adminCommand({ ping: 1 })
    return true
  } catch (e) {
    print("MongoDB non pronto, riprovo...")
    return false
  }
}

// Inizializza il replica set
function initReplica() {
  if (!waitForMongo()) {
    setTimeout(initReplica, 3000)
    return
  }

  try {
    const status = rs.status()
    if (!status.ok) {
      print("Inizializing replica set...")
      rs.initiate({
        _id: "overleaf",
        members: [{ _id: 0, host: "mongo:27017" }],
        settings: {
          heartbeatTimeoutSecs: 2,
          electionTimeoutMillis: 4000
        }
      })
      print("Replica set initialized!")
    } else {
      print("Replica set già esistente")
    }
  } catch (e) {
    print(`Errore: ${e}`)
    print("Riprovo in 5 secondi...")
    setTimeout(initReplica, 5000)
  }
}

// Avvia il processo
initReplica()