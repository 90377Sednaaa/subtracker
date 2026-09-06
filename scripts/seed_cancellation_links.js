// Seed the cancellation_links collection (read-only to app clients; writes
// are blocked by firestore.rules, so this runs server-side).
//
// Setup (one time):
//   1. Firebase console -> Project settings -> Service accounts ->
//      "Generate new private key" -> save as scripts/serviceAccountKey.json
//      (NEVER commit that file; it is git-ignored).
//   2. cd scripts && npm install firebase-admin
//   3. node seed_cancellation_links.js
const admin = require('firebase-admin');

const serviceAccount = require('./serviceAccountKey.json');
admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });

const links = [
  ['netflix', 'Netflix', 'Streaming', 'https://www.netflix.com/cancelplan', 'Account -> Cancel plan'],
  ['spotify', 'Spotify', 'Music', 'https://www.spotify.com/account/subscription/', 'Account -> Change or cancel'],
  ['disneyplus', 'Disney+', 'Streaming', 'https://www.disneyplus.com/account/subscription', 'Account -> Subscription'],
  ['youtube-premium', 'YouTube Premium', 'Streaming', 'https://www.youtube.com/paid_memberships', 'Paid memberships -> Manage'],
  ['amazon-prime', 'Amazon Prime', 'Shopping', 'https://www.amazon.com/gp/primecentral', 'Prime membership -> End membership'],
  ['microsoft-365', 'Microsoft 365', 'Productivity', 'https://account.microsoft.com/services', 'Services & subscriptions -> Cancel'],
  ['adobe-cc', 'Adobe Creative Cloud', 'Productivity', 'https://account.adobe.com/plans', 'Plans -> Manage plan'],
  ['xbox-game-pass', 'Xbox Game Pass', 'Gaming', 'https://www.xbox.com/subscriptions', 'Subscriptions -> Manage'],
  ['dropbox', 'Dropbox', 'Storage', 'https://www.dropbox.com/account/plan', 'Plan -> Cancel plan'],
  ['canva', 'Canva Pro', 'Design', 'https://www.canva.com/settings/billing-and-plans', 'Billing & plans -> Cancel'],
  ['audible', 'Audible', 'Books', 'https://www.audible.com/account/membership', 'Membership -> Cancel'],
  ['icloud', 'iCloud+', 'Storage', 'https://support.apple.com/en-us/HT207594', 'iOS Settings -> Apple ID -> iCloud (guided steps)'],
];

(async () => {
  const db = admin.firestore();
  const batch = db.batch();
  links.forEach(([id, name, category, cancelUrl, notes], i) => {
    batch.set(db.collection('cancellation_links').doc(id), {
      name,
      category,
      cancelUrl,
      notes,
      sortOrder: i + 1,
    });
  });
  await batch.commit();
  console.log(`Seeded ${links.length} cancellation links.`);
  process.exit(0);
})();
