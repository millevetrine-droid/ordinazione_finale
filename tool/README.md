Seed Firestore - istruzioni

Prerequisiti
- Node.js (>=14)
- Avere accesso alla Firebase Console del progetto target
- Scaricare la Service Account Key (JSON) e salvarla come `tool/serviceAccountKey.json`

Installazione e uso (PowerShell):

# Opzione A - Seed usando l'EMULATOR (raccomandato per sviluppo)
# Richiede: Firebase CLI e l'emulator Firestore in esecuzione
# Avvia l'emulator in una shell separata: firebase emulators:start --only firestore
# Poi, nella root del progetto esegui:
npm install firebase-admin; $env:FIRESTORE_EMULATOR_HOST='localhost:8080'; $env:FIREBASE_PROJECT_ID='demo-project'; node .\tool\seed_firestore.js

# Opzione B - Seed verso Firestore REALE (usa con cautela)
# 1) Scarica la Service Account JSON dalla Firebase Console e salvala come tool/serviceAccountKey.json
# 2) Esegui (PowerShell):
npm install firebase-admin; node .\tool\seed_firestore.js

Note:
- Lo script scrive nella collection `macrocategorie`. Se vuoi cambiare collection o aggiungere altri documenti, modifica `tool/seed_data.json`.
- Non committare mai `tool/serviceAccountKey.json` nel repository.
- Non eseguire questo script su ambienti di produzione senza averne verificato l'impatto e le regole di sicurezza.
