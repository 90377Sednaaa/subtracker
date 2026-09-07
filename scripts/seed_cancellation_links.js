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
  ['netflix', 'Netflix', 'Entertainment', 'https://www.netflix.com/cancelplan', 'Account -> Cancel plan'],
  ['spotify', 'Spotify', 'Music', 'https://www.spotify.com/account/subscription/', 'Account -> Change or cancel plan'],
  ['chatgpt', 'ChatGPT Plus', 'Productivity', 'https://chatgpt.com/#settings/DataControls', 'Settings -> My plan -> Manage subscription -> Cancel'],
  ['youtube-premium', 'YouTube Premium', 'Entertainment', 'https://www.youtube.com/paid_memberships', 'Paid memberships -> Manage -> Deactivate'],
  ['cursor', 'Cursor', 'Utilities', 'https://www.cursor.com/settings', 'Settings -> General -> Manage Subscription -> Cancel'],
  ['apple-one', 'Apple One', 'Entertainment', 'https://support.apple.com/en-us/HT202039', 'iOS Settings -> Apple ID -> Subscriptions -> Cancel'],
  ['disneyplus', 'Disney+', 'Entertainment', 'https://www.disneyplus.com/account/subscription', 'Account -> Subscription -> Cancel Subscription'],
  ['amazon-prime', 'Amazon Prime', 'Entertainment', 'https://www.amazon.com/gp/primecentral', 'Prime membership -> Manage -> End membership'],
  ['apple-music', 'Apple Music', 'Music', 'https://support.apple.com/en-us/HT202039', 'iOS Settings -> Subscriptions -> Apple Music -> Cancel'],
  ['apple-tv', 'Apple TV+', 'Entertainment', 'https://support.apple.com/en-us/HT202039', 'iOS Settings -> Subscriptions -> Apple TV+ -> Cancel'],
  ['claude', 'Claude Pro', 'Productivity', 'https://claude.ai/settings/billing', 'Settings -> Billing -> Manage Subscription -> Cancel plan'],
  ['github-copilot', 'GitHub Copilot', 'Productivity', 'https://github.com/settings/copilot', 'Settings -> Copilot -> Manage subscription -> Cancel'],
  ['perplexity', 'Perplexity Pro', 'Productivity', 'https://www.perplexity.ai/settings/account', 'Settings -> Account -> Subscription -> Manage -> Cancel'],
  ['midjourney', 'Midjourney', 'Design', 'https://www.midjourney.com/account', 'Account -> Manage Sub -> Cancel Plan'],
  ['max', 'Max', 'Entertainment', 'https://auth.max.com/subscription', 'Account -> Subscription -> Manage Subscription -> Cancel'],
  ['crunchyroll', 'Crunchyroll', 'Entertainment', 'https://www.crunchyroll.com/account/membership', 'Account -> Membership Plan -> Cancel Membership'],
  ['twitch', 'Twitch', 'Entertainment', 'https://www.twitch.tv/subscriptions', 'Subscriptions -> Subscriptions -> Cancel Subscription'],
  ['adobe-cc', 'Adobe Creative Cloud', 'Design', 'https://account.adobe.com/plans', 'Plans -> Manage plan -> Cancel your plan'],
  ['microsoft-365', 'Microsoft 365', 'Productivity', 'https://account.microsoft.com/services', 'Services & subscriptions -> Manage -> Cancel subscription'],
  ['google-one', 'Google One', 'Cloud & Storage', 'https://one.google.com/settings', 'Settings -> Change membership plan -> Cancel membership'],
  ['icloud', 'iCloud+', 'Cloud & Storage', 'https://support.apple.com/en-us/HT207594', 'iOS Settings -> Apple ID -> iCloud -> Downgrade options'],
  ['dropbox', 'Dropbox', 'Cloud & Storage', 'https://www.dropbox.com/account/plan', 'Settings -> Plan -> Cancel plan'],
  ['notion', 'Notion Plus', 'Productivity', 'https://www.notion.so/settings', 'Settings & members -> Upgrade -> Change plan -> Cancel'],
  ['figma', 'Figma', 'Design', 'https://www.figma.com/settings', 'Settings -> Billing -> Change plan -> Cancel subscription'],
  ['canva', 'Canva Pro', 'Design', 'https://www.canva.com/settings/billing-and-plans', 'Settings -> Billing & plans -> Cancel subscription'],
  ['1password', '1Password', 'Utilities', 'https://my.1password.com/billing', 'Billing -> Manage subscription -> Cancel'],
  ['slack', 'Slack', 'Productivity', 'https://my.slack.com/admin/billing', 'Settings & administration -> Billing -> Cancel subscription'],
  ['xbox-game-pass', 'Xbox Game Pass', 'Gaming', 'https://account.microsoft.com/services/xboxgamepass', 'Services & subscriptions -> Xbox Game Pass -> Cancel'],
  ['playstation', 'PlayStation Plus', 'Gaming', 'https://store.playstation.com/subscriptions', 'Settings -> Account Management -> Subscriptions -> Cancel'],
  ['nintendo', 'Nintendo Switch Online', 'Gaming', 'https://ec.nintendo.com/my/membership', 'Nintendo eShop -> Subscriptions -> Turn Off Automatic Renewal'],
  ['discord', 'Discord Nitro', 'Utilities', 'https://discord.com/app', 'User Settings -> Subscriptions -> Cancel'],
  ['duolingo', 'Duolingo Super', 'Education', 'https://www.duolingo.com/settings/super', 'Settings -> Super Duolingo -> Cancel Subscription'],
  ['audible', 'Audible', 'Books', 'https://www.audible.com/account/membership', 'Account Details -> Membership Details -> Cancel membership'],
  ['strava', 'Strava', 'Other', 'https://www.strava.com/settings/subscription', 'Settings -> My Account -> Cancel Subscription'],
  ['medium', 'Medium', 'Books', 'https://medium.com/me/settings/membership', 'Settings -> Membership -> Cancel membership'],
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
