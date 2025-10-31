const admin = require('firebase-admin');
const axios = require('axios');
const fs = require('fs');

const PROJECT_ID = process.env.FB_PROJECT_ID || 'demo-no-project';
const AUTH_EMULATOR_HOST = process.env.FIREBASE_AUTH_EMULATOR_HOST || '127.0.0.1:9099';

process.env.FIREBASE_AUTH_EMULATOR_HOST = AUTH_EMULATOR_HOST;

admin.initializeApp({ projectId: PROJECT_ID });

async function main() {
  const uid = `dart-staff-${Date.now()}`;
  console.log('Creating custom token for uid:', uid);
  const customToken = await admin.auth().createCustomToken(uid, { role: 'staff' });

  const signInUrl = `http://${AUTH_EMULATOR_HOST}/identitytoolkit.googleapis.com/v1/accounts:signInWithCustomToken?key=fake`;
  console.log('Exchanging custom token for idToken via', signInUrl);

  const signInResp = await axios.post(signInUrl, { token: customToken, returnSecureToken: true });
  const idToken = signInResp.data.idToken;
  console.log('Received idToken (truncated):', idToken ? idToken.slice(0, 30) + '...' : 'none');

  const out = { idToken };
  fs.writeFileSync('token.json', JSON.stringify(out, null, 2));
  console.log('Wrote token.json in current dir (tooling).');
}

main().catch(err => {
  console.error('Failed to generate token:', err.response ? err.response.data : err.message);
  process.exit(1);
});
