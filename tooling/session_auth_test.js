/*
  session_auth_test.js
  - Uses firebase-admin to create a custom token with claim { role: 'staff' }
  - Exchanges the custom token for an ID token via the Auth emulator
  - Calls Firestore emulator REST create and patch endpoints with/without the ID token

  Usage (from repo root):
    cd tooling
    npm install
    node session_auth_test.js

  Requirements: Node.js installed and Auth + Firestore emulators running on localhost
*/

const admin = require('firebase-admin');
const axios = require('axios');

const PROJECT_ID = process.env.FB_PROJECT_ID || 'demo-no-project';
const AUTH_EMULATOR_HOST = process.env.FIREBASE_AUTH_EMULATOR_HOST || '127.0.0.1:9099';
const FIRESTORE_EMULATOR_HOST = process.env.FIRESTORE_EMULATOR_HOST || '127.0.0.1:8080';

async function main() {
  console.log('Starting auth + firestore emulator end-to-end test...');

  // Tell admin sdk to use the emulator
  process.env.FIREBASE_AUTH_EMULATOR_HOST = AUTH_EMULATOR_HOST;
  process.env.FIRESTORE_EMULATOR_HOST = FIRESTORE_EMULATOR_HOST;

  admin.initializeApp({ projectId: PROJECT_ID });

  const uid = `staff-tester-${Date.now()}`;
  console.log('Creating custom token for uid:', uid);
  const customToken = await admin.auth().createCustomToken(uid, { role: 'staff' });

  // Exchange custom token for ID token via Auth emulator
  const signInUrl = `http://${AUTH_EMULATOR_HOST}/identitytoolkit.googleapis.com/v1/accounts:signInWithCustomToken?key=fake`;
  console.log('Exchanging custom token for idToken via', signInUrl);

  const signInResp = await axios.post(signInUrl, { token: customToken, returnSecureToken: true });
  const idToken = signInResp.data.idToken;
  console.log('Received idToken (truncated):', idToken ? idToken.slice(0, 30) + '...' : 'none');

  // Try to create a session WITHOUT token (should fail if rules enforced)
  const firestoreCreateUrl = `http://${FIRESTORE_EMULATOR_HOST}/v1/projects/${PROJECT_ID}/databases/(default)/documents/sessions`;
  const body = {
    fields: {
      codice: { stringValue: 'S-AUTH-TEST' },
      numeroTavolo: { integerValue: '11' },
      idCameriere: { stringValue: 'node-staff' },
      createdAt: { timestampValue: new Date().toISOString() },
      expiresAt: { timestampValue: new Date(Date.now() + 3600 * 1000).toISOString() },
      attiva: { booleanValue: true }
    }
  };

  console.log('\n1) Create session WITHOUT token (expected: 403 if rules enforced)');
  try {
    const rNoAuth = await axios.post(firestoreCreateUrl, body);
    console.log('Unexpected success (no auth):', rNoAuth.data.name);
  } catch (err) {
    console.log('No-auth create result (expected):', err.response ? err.response.status : err.message);
  }

  console.log('\n2) Create session WITH idToken (expected: success)');
  const r = await axios.post(firestoreCreateUrl, body, { headers: { Authorization: `Bearer ${idToken}` } });
  console.log('Created:', r.data.name);
  const docId = r.data.name.split('/').pop();

  console.log('\n3) Read created document WITH token');
  const readUrl = `http://${FIRESTORE_EMULATOR_HOST}/v1/projects/${PROJECT_ID}/databases/(default)/documents/sessions/${docId}`;
  const readResp = await axios.get(readUrl, { headers: { Authorization: `Bearer ${idToken}` } });
  console.log('Read:', readResp.data.name);

  console.log('\n4) Patch (end session) WITH token');
  const patchUrl = `${readUrl}?updateMask.fieldPaths=attiva&updateMask.fieldPaths=expiresAt`;
  const patchBody = {
    fields: {
      attiva: { booleanValue: false },
      expiresAt: { timestampValue: new Date().toISOString() }
    }
  };
  const patchResp = await axios.patch(patchUrl, patchBody, { headers: { Authorization: `Bearer ${idToken}` } });
  console.log('Patched:', patchResp.data.name);

  console.log('\n5) Read after patch WITH token (expected: 403 because session was ended)');
  try {
    const read2 = await axios.get(readUrl, { headers: { Authorization: `Bearer ${idToken}` } });
    // If we get here, the rules didn't block the read which is unexpected because attiva=false
    console.log('Unexpected read after end (should have been forbidden):', JSON.stringify(read2.data.fields.attiva));
  } catch (err) {
    const status = err.response ? err.response.status : null;
    if (status === 403) {
      console.log('Read after patch correctly forbidden (403). Rules behave as expected.');
    } else {
      console.log('Read after patch returned unexpected error:', err.response ? err.response.data : err.message);
      throw err;
    }
  }

  console.log('\nDone.');
}

main().catch(err => {
  console.error('Error during auth test:', err.response ? err.response.data : err.message);
  process.exit(1);
});
