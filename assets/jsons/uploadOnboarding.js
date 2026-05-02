// upload_onboarding.js
// Run: GOOGLE_APPLICATION_CREDENTIALS=./serviceAccountKey.json node upload_onboarding.js

const admin = require('firebase-admin');
const data = require('./onboardingFlow.json');

admin.initializeApp({
  credential: admin.credential.applicationDefault(),
});

const db = admin.firestore();

async function upload() {
  console.log(`Uploading ${data.onboarding_pages.length} onboarding pages...`);

  for (const page of data.onboarding_pages) {
    await db.collection('onboarding_pages').doc(page.id).set(page);
    console.log(`✅ Uploaded ${page.id} — "${Object.values(page.translations)[0].substring(0, 30)}..."`);
  }

  console.log('\n🎉 All pages uploaded successfully!');
  process.exit(0);
}

upload().catch((err) => {
  console.error('❌ Upload failed:', err);
  process.exit(1);
});