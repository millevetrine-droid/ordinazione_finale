// Script per popolare Firestore con dati di esempio.
// Requisiti:
// 1) Node.js installato
// 2) file di service account scaricato dalla Firebase Console in tool/serviceAccountKey.json
// 3) nella cartella del progetto: npm install firebase-admin

const fs = require('fs');
const admin = require('firebase-admin');

async function main() {
  // If FIRESTORE_EMULATOR_HOST is set we assume the developer wants to seed
  // the local emulator. In that case we can initialize the Admin SDK with
  // a projectId only and it will connect to the emulator. Otherwise we look
  // for a service account key JSON.
  if (process.env.FIRESTORE_EMULATOR_HOST) {
    console.log('Detected FIRESTORE_EMULATOR_HOST; connecting to the Firestore emulator.');
    // Provide a projectId; when using emulator this is sufficient.
    admin.initializeApp({ projectId: process.env.FIREBASE_PROJECT_ID || 'demo-project' });
  } else {
    const serviceKeyPath = './tool/serviceAccountKey.json';
    if (!fs.existsSync(serviceKeyPath)) {
      console.error('Service account key non trovata. Crea il file tool/serviceAccountKey.json con la chiave JSON scaricata dalla Firebase Console oppure usa l\'emulator (vedi README).');
      process.exit(1);
    }

    const serviceAccount = require(serviceKeyPath);

    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      // projectId viene estratto automaticamente dalla chiave ma puoi specificarlo qui se serve
    });
  }

  const db = admin.firestore();

  const seedPath = './tool/seed_data.json';
  if (!fs.existsSync(seedPath)) {
    console.error('File di seed non trovato: tool/seed_data.json');
    process.exit(1);
  }

  const seed = JSON.parse(fs.readFileSync(seedPath, 'utf8'));

  try {
    console.log('Popolazione collection "macrocategorie"...');
    const colRef = db.collection('macrocategorie');
    for (const item of seed.macrocategorie) {
      const docRef = await colRef.add(item);
      console.log(` - creato ${docRef.id} -> ${JSON.stringify(item)}`);
    }
    console.log('Seed completato con successo.');
    process.exit(0);
  } catch (e) {
    console.error('Errore durante il seed:', e);
    process.exit(1);
  }
}

main();
