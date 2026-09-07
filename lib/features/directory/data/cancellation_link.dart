class CancellationLink {
  const CancellationLink({
    required this.id,
    required this.name,
    required this.category,
    required this.cancelUrl,
    required this.notes,
  });

  final String id;
  final String name;
  final String category;
  final String cancelUrl;
  final String notes;

  static CancellationLink fromMap(String id, Map<String, dynamic> map) =>
      CancellationLink(
        id: id,
        name: map['name'] as String,
        category: map['category'] as String? ?? '',
        cancelUrl: map['cancelUrl'] as String,
        notes: map['notes'] as String? ?? '',
      );
}

/// Comprehensive offline fallback list of all 35 popular services matching the catalog.
const kDefaultCancellationLinks = <CancellationLink>[
  CancellationLink(
    id: 'netflix',
    name: 'Netflix',
    category: 'Entertainment',
    cancelUrl: 'https://www.netflix.com/cancelplan',
    notes: 'Account -> Cancel plan',
  ),
  CancellationLink(
    id: 'spotify',
    name: 'Spotify',
    category: 'Music',
    cancelUrl: 'https://www.spotify.com/account/subscription/',
    notes: 'Account -> Change or cancel plan',
  ),
  CancellationLink(
    id: 'chatgpt',
    name: 'ChatGPT Plus',
    category: 'Productivity',
    cancelUrl: 'https://chatgpt.com/#settings/DataControls',
    notes: 'Settings -> My plan -> Manage subscription -> Cancel',
  ),
  CancellationLink(
    id: 'youtube-premium',
    name: 'YouTube Premium',
    category: 'Entertainment',
    cancelUrl: 'https://www.youtube.com/paid_memberships',
    notes: 'Paid memberships -> Manage -> Deactivate',
  ),
  CancellationLink(
    id: 'cursor',
    name: 'Cursor',
    category: 'Utilities',
    cancelUrl: 'https://www.cursor.com/settings',
    notes: 'Settings -> General -> Manage Subscription -> Cancel',
  ),
  CancellationLink(
    id: 'apple-one',
    name: 'Apple One',
    category: 'Entertainment',
    cancelUrl: 'https://support.apple.com/en-us/HT202039',
    notes: 'iOS Settings -> Apple ID -> Subscriptions -> Cancel',
  ),
  CancellationLink(
    id: 'disneyplus',
    name: 'Disney+',
    category: 'Entertainment',
    cancelUrl: 'https://www.disneyplus.com/account/subscription',
    notes: 'Account -> Subscription -> Cancel Subscription',
  ),
  CancellationLink(
    id: 'amazon-prime',
    name: 'Amazon Prime',
    category: 'Entertainment',
    cancelUrl: 'https://www.amazon.com/gp/primecentral',
    notes: 'Prime membership -> Manage -> End membership',
  ),
  CancellationLink(
    id: 'apple-music',
    name: 'Apple Music',
    category: 'Music',
    cancelUrl: 'https://support.apple.com/en-us/HT202039',
    notes: 'iOS Settings -> Subscriptions -> Apple Music -> Cancel',
  ),
  CancellationLink(
    id: 'apple-tv',
    name: 'Apple TV+',
    category: 'Entertainment',
    cancelUrl: 'https://support.apple.com/en-us/HT202039',
    notes: 'iOS Settings -> Subscriptions -> Apple TV+ -> Cancel',
  ),
  CancellationLink(
    id: 'claude',
    name: 'Claude Pro',
    category: 'Productivity',
    cancelUrl: 'https://claude.ai/settings/billing',
    notes: 'Settings -> Billing -> Manage Subscription -> Cancel plan',
  ),
  CancellationLink(
    id: 'github-copilot',
    name: 'GitHub Copilot',
    category: 'Productivity',
    cancelUrl: 'https://github.com/settings/copilot',
    notes: 'Settings -> Copilot -> Manage subscription -> Cancel',
  ),
  CancellationLink(
    id: 'perplexity',
    name: 'Perplexity Pro',
    category: 'Productivity',
    cancelUrl: 'https://www.perplexity.ai/settings/account',
    notes: 'Settings -> Account -> Subscription -> Manage -> Cancel',
  ),
  CancellationLink(
    id: 'midjourney',
    name: 'Midjourney',
    category: 'Design',
    cancelUrl: 'https://www.midjourney.com/account',
    notes: 'Account -> Manage Sub -> Cancel Plan',
  ),
  CancellationLink(
    id: 'max',
    name: 'Max',
    category: 'Entertainment',
    cancelUrl: 'https://auth.max.com/subscription',
    notes: 'Account -> Subscription -> Manage Subscription -> Cancel',
  ),
  CancellationLink(
    id: 'crunchyroll',
    name: 'Crunchyroll',
    category: 'Entertainment',
    cancelUrl: 'https://www.crunchyroll.com/account/membership',
    notes: 'Account -> Membership Plan -> Cancel Membership',
  ),
  CancellationLink(
    id: 'twitch',
    name: 'Twitch',
    category: 'Entertainment',
    cancelUrl: 'https://www.twitch.tv/subscriptions',
    notes: 'Subscriptions -> Subscriptions -> Cancel Subscription',
  ),
  CancellationLink(
    id: 'adobe-cc',
    name: 'Adobe Creative Cloud',
    category: 'Design',
    cancelUrl: 'https://account.adobe.com/plans',
    notes: 'Plans -> Manage plan -> Cancel your plan',
  ),
  CancellationLink(
    id: 'microsoft-365',
    name: 'Microsoft 365',
    category: 'Productivity',
    cancelUrl: 'https://account.microsoft.com/services',
    notes: 'Services & subscriptions -> Manage -> Cancel subscription',
  ),
  CancellationLink(
    id: 'google-one',
    name: 'Google One',
    category: 'Cloud & Storage',
    cancelUrl: 'https://one.google.com/settings',
    notes: 'Settings -> Change membership plan -> Cancel membership',
  ),
  CancellationLink(
    id: 'icloud',
    name: 'iCloud+',
    category: 'Cloud & Storage',
    cancelUrl: 'https://support.apple.com/en-us/HT207594',
    notes: 'iOS Settings -> Apple ID -> iCloud -> Downgrade options',
  ),
  CancellationLink(
    id: 'dropbox',
    name: 'Dropbox',
    category: 'Cloud & Storage',
    cancelUrl: 'https://www.dropbox.com/account/plan',
    notes: 'Settings -> Plan -> Cancel plan',
  ),
  CancellationLink(
    id: 'notion',
    name: 'Notion Plus',
    category: 'Productivity',
    cancelUrl: 'https://www.notion.so/settings',
    notes: 'Settings & members -> Upgrade -> Change plan -> Cancel',
  ),
  CancellationLink(
    id: 'figma',
    name: 'Figma',
    category: 'Design',
    cancelUrl: 'https://www.figma.com/settings',
    notes: 'Settings -> Billing -> Change plan -> Cancel subscription',
  ),
  CancellationLink(
    id: 'canva',
    name: 'Canva Pro',
    category: 'Design',
    cancelUrl: 'https://www.canva.com/settings/billing-and-plans',
    notes: 'Settings -> Billing & plans -> Cancel subscription',
  ),
  CancellationLink(
    id: '1password',
    name: '1Password',
    category: 'Utilities',
    cancelUrl: 'https://my.1password.com/billing',
    notes: 'Billing -> Manage subscription -> Cancel',
  ),
  CancellationLink(
    id: 'slack',
    name: 'Slack',
    category: 'Productivity',
    cancelUrl: 'https://my.slack.com/admin/billing',
    notes: 'Settings & administration -> Billing -> Cancel subscription',
  ),
  CancellationLink(
    id: 'xbox-game-pass',
    name: 'Xbox Game Pass',
    category: 'Gaming',
    cancelUrl: 'https://account.microsoft.com/services/xboxgamepass',
    notes: 'Services & subscriptions -> Xbox Game Pass -> Cancel',
  ),
  CancellationLink(
    id: 'playstation',
    name: 'PlayStation Plus',
    category: 'Gaming',
    cancelUrl: 'https://store.playstation.com/subscriptions',
    notes: 'Settings -> Account Management -> Subscriptions -> Cancel',
  ),
  CancellationLink(
    id: 'nintendo',
    name: 'Nintendo Switch Online',
    category: 'Gaming',
    cancelUrl: 'https://ec.nintendo.com/my/membership',
    notes: 'Nintendo eShop -> Subscriptions -> Turn Off Automatic Renewal',
  ),
  CancellationLink(
    id: 'discord',
    name: 'Discord Nitro',
    category: 'Utilities',
    cancelUrl: 'https://discord.com/app',
    notes: 'User Settings -> Subscriptions -> Cancel',
  ),
  CancellationLink(
    id: 'duolingo',
    name: 'Duolingo Super',
    category: 'Education',
    cancelUrl: 'https://www.duolingo.com/settings/super',
    notes: 'Settings -> Super Duolingo -> Cancel Subscription',
  ),
  CancellationLink(
    id: 'audible',
    name: 'Audible',
    category: 'Books',
    cancelUrl: 'https://www.audible.com/account/membership',
    notes: 'Account Details -> Membership Details -> Cancel membership',
  ),
  CancellationLink(
    id: 'strava',
    name: 'Strava',
    category: 'Other',
    cancelUrl: 'https://www.strava.com/settings/subscription',
    notes: 'Settings -> My Account -> Cancel Subscription',
  ),
  CancellationLink(
    id: 'medium',
    name: 'Medium',
    category: 'Books',
    cancelUrl: 'https://medium.com/me/settings/membership',
    notes: 'Settings -> Membership -> Cancel membership',
  ),
];

