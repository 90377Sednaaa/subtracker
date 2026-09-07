import 'package:flutter/foundation.dart';

const kSubscriptionCategories = <String>[
  'Entertainment',
  'Music',
  'Productivity',
  'Utilities',
  'Gaming',
  'Books',
  'Cloud & Storage',
  'Design',
  'Education',
  'Other',
];

@immutable
class PresetService {
  const PresetService({
    required this.name,
    required this.category,
    required this.brandColorHex,
    this.iconAsset,
    this.isPopular = false,
  });

  final String name;
  final String category;
  final int brandColorHex;
  final String? iconAsset;
  final bool isPopular;

  bool matchesQuery(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return name.toLowerCase().contains(q) || category.toLowerCase().contains(q);
  }
}

List<PresetService> get kPopularPresetServices =>
    kPresetServices.where((s) => s.isPopular).toList();

const kPresetServices = <PresetService>[
  // Popular Services (Pinned at top)
  PresetService(
    name: 'ChatGPT Plus',
    category: 'Productivity',
    brandColorHex: 0xFF10A37F,
    iconAsset: 'assets/brand/logos/chatgpt.svg',
    isPopular: true,
  ),
  PresetService(
    name: 'Netflix',
    category: 'Entertainment',
    brandColorHex: 0xFFE50914,
    iconAsset: 'assets/brand/logos/netflix.svg',
    isPopular: true,
  ),
  PresetService(
    name: 'Spotify',
    category: 'Music',
    brandColorHex: 0xFF1DB954,
    iconAsset: 'assets/brand/logos/spotify.svg',
    isPopular: true,
  ),
  PresetService(
    name: 'YouTube Premium',
    category: 'Entertainment',
    brandColorHex: 0xFFFF0033,
    iconAsset: 'assets/brand/logos/youtube.svg',
    isPopular: true,
  ),
  PresetService(
    name: 'Cursor',
    category: 'Utilities',
    brandColorHex: 0xFF2B2D31,
    iconAsset: 'assets/brand/logos/cursor.svg',
    isPopular: true,
  ),
  PresetService(
    name: 'Apple One',
    category: 'Entertainment',
    brandColorHex: 0xFFA2AAAD,
    iconAsset: 'assets/brand/logos/appleone.svg',
    isPopular: true,
  ),

  // All Services
  PresetService(
    name: 'Disney+',
    category: 'Entertainment',
    brandColorHex: 0xFF113CCF,
    iconAsset: 'assets/brand/logos/disneyplus.svg',
  ),
  PresetService(
    name: 'Amazon Prime',
    category: 'Entertainment',
    brandColorHex: 0xFF00A8E1,
    iconAsset: 'assets/brand/logos/amazonprime.svg',
  ),
  PresetService(
    name: 'Apple Music',
    category: 'Music',
    brandColorHex: 0xFFFA243C,
    iconAsset: 'assets/brand/logos/applemusic.svg',
  ),
  PresetService(
    name: 'Apple TV+',
    category: 'Entertainment',
    brandColorHex: 0xFF242424,
    iconAsset: 'assets/brand/logos/appletv.svg',
  ),
  PresetService(
    name: 'Claude Pro',
    category: 'Productivity',
    brandColorHex: 0xFFD97706,
    iconAsset: 'assets/brand/logos/claude.svg',
  ),
  PresetService(
    name: 'GitHub Copilot',
    category: 'Productivity',
    brandColorHex: 0xFF24292E,
    iconAsset: 'assets/brand/logos/github.svg',
  ),
  PresetService(
    name: 'Perplexity Pro',
    category: 'Productivity',
    brandColorHex: 0xFF13BBAF,
    iconAsset: 'assets/brand/logos/perplexity.svg',
  ),
  PresetService(
    name: 'Midjourney',
    category: 'Design',
    brandColorHex: 0xFF1E293B,
    iconAsset: 'assets/brand/logos/midjourney.svg',
  ),
  PresetService(
    name: 'Max',
    category: 'Entertainment',
    brandColorHex: 0xFF002BE7,
    iconAsset: 'assets/brand/logos/max.svg',
  ),
  PresetService(
    name: 'Crunchyroll',
    category: 'Entertainment',
    brandColorHex: 0xFFF47521,
    iconAsset: 'assets/brand/logos/crunchyroll.svg',
  ),
  PresetService(
    name: 'Twitch',
    category: 'Entertainment',
    brandColorHex: 0xFF9146FF,
    iconAsset: 'assets/brand/logos/twitch.svg',
  ),
  PresetService(
    name: 'Adobe Creative Cloud',
    category: 'Design',
    brandColorHex: 0xFFFA0F00,
    iconAsset: 'assets/brand/logos/adobecreativecloud.svg',
  ),
  PresetService(
    name: 'Microsoft 365',
    category: 'Productivity',
    brandColorHex: 0xFFD83B01,
    iconAsset: 'assets/brand/logos/microsoft.svg',
  ),
  PresetService(
    name: 'Google One',
    category: 'Cloud & Storage',
    brandColorHex: 0xFF1A73E8,
    iconAsset: 'assets/brand/logos/googleone.svg',
  ),
  PresetService(
    name: 'iCloud+',
    category: 'Cloud & Storage',
    brandColorHex: 0xFFA2AAAD,
    iconAsset: 'assets/brand/logos/icloud.svg',
  ),
  PresetService(
    name: 'Dropbox',
    category: 'Cloud & Storage',
    brandColorHex: 0xFF0061FF,
    iconAsset: 'assets/brand/logos/dropbox.svg',
  ),
  PresetService(
    name: 'Notion Plus',
    category: 'Productivity',
    brandColorHex: 0xFF242424,
    iconAsset: 'assets/brand/logos/notion.svg',
  ),
  PresetService(
    name: 'Figma',
    category: 'Design',
    brandColorHex: 0xFFF24E1E,
    iconAsset: 'assets/brand/logos/figma.svg',
  ),
  PresetService(
    name: 'Canva Pro',
    category: 'Design',
    brandColorHex: 0xFF00C4CC,
    iconAsset: 'assets/brand/logos/canva.svg',
  ),
  PresetService(
    name: '1Password',
    category: 'Utilities',
    brandColorHex: 0xFF0A85EA,
    iconAsset: 'assets/brand/logos/1password.svg',
  ),
  PresetService(
    name: 'Slack',
    category: 'Productivity',
    brandColorHex: 0xFF4A154B,
    iconAsset: 'assets/brand/logos/slack.svg',
  ),
  PresetService(
    name: 'Xbox Game Pass',
    category: 'Gaming',
    brandColorHex: 0xFF52B043,
    iconAsset: 'assets/brand/logos/xbox.svg',
  ),
  PresetService(
    name: 'PlayStation Plus',
    category: 'Gaming',
    brandColorHex: 0xFF003791,
    iconAsset: 'assets/brand/logos/playstation.svg',
  ),
  PresetService(
    name: 'Nintendo Switch Online',
    category: 'Gaming',
    brandColorHex: 0xFFE60012,
    iconAsset: 'assets/brand/logos/nintendo.svg',
  ),
  PresetService(
    name: 'Discord Nitro',
    category: 'Utilities',
    brandColorHex: 0xFF5865F2,
    iconAsset: 'assets/brand/logos/discord.svg',
  ),
  PresetService(
    name: 'Duolingo Super',
    category: 'Education',
    brandColorHex: 0xFF58CC02,
    iconAsset: 'assets/brand/logos/duolingo.svg',
  ),
  PresetService(
    name: 'Audible',
    category: 'Books',
    brandColorHex: 0xFFF8991C,
    iconAsset: 'assets/brand/logos/audible.svg',
  ),
  PresetService(
    name: 'Strava',
    category: 'Other',
    brandColorHex: 0xFFFC4C02,
    iconAsset: 'assets/brand/logos/strava.svg',
  ),
  PresetService(
    name: 'Medium',
    category: 'Books',
    brandColorHex: 0xFF1A1A1A,
    iconAsset: 'assets/brand/logos/medium.svg',
  ),
];
