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
  });

  final String name;
  final String category;
  final int brandColorHex;
  final String? iconAsset;

  bool matchesQuery(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return name.toLowerCase().contains(q) || category.toLowerCase().contains(q);
  }
}

const kPresetServices = <PresetService>[
  PresetService(
    name: 'Netflix',
    category: 'Entertainment',
    brandColorHex: 0xFFE50914,
    iconAsset: 'assets/brand/logos/netflix.svg',
  ),
  PresetService(
    name: 'Spotify',
    category: 'Music',
    brandColorHex: 0xFF1DB954,
    iconAsset: 'assets/brand/logos/spotify.svg',
  ),
  PresetService(
    name: 'Disney+',
    category: 'Entertainment',
    brandColorHex: 0xFF113CCF,
    iconAsset: 'assets/brand/logos/disneyplus.svg',
  ),
  PresetService(
    name: 'YouTube Premium',
    category: 'Entertainment',
    brandColorHex: 0xFFFF0033,
    iconAsset: 'assets/brand/logos/youtube.svg',
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
    iconAsset: null,
  ),
  PresetService(
    name: 'Apple One',
    category: 'Entertainment',
    brandColorHex: 0xFFA2AAAD,
    iconAsset: null,
  ),
  PresetService(
    name: 'Apple TV+',
    category: 'Entertainment',
    brandColorHex: 0xFF111111,
    iconAsset: null,
  ),
  PresetService(
    name: 'Adobe Creative Cloud',
    category: 'Design',
    brandColorHex: 0xFFFA0F00,
    iconAsset: 'assets/brand/logos/adobecreativecloud.svg',
  ),
  PresetService(
    name: 'ChatGPT Plus',
    category: 'Productivity',
    brandColorHex: 0xFF10A37F,
    iconAsset: null,
  ),
  PresetService(
    name: 'Cursor',
    category: 'Utilities',
    brandColorHex: 0xFF000000,
    iconAsset: null,
  ),
  PresetService(
    name: 'GitHub Copilot',
    category: 'Productivity',
    brandColorHex: 0xFF24292E,
    iconAsset: null,
  ),
  PresetService(
    name: 'Microsoft 365',
    category: 'Productivity',
    brandColorHex: 0xFFD83B01,
    iconAsset: 'assets/brand/logos/microsoft.svg',
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
    iconAsset: null,
  ),
  PresetService(
    name: 'Dropbox',
    category: 'Cloud & Storage',
    brandColorHex: 0xFF0061FF,
    iconAsset: 'assets/brand/logos/dropbox.svg',
  ),
  PresetService(
    name: 'Canva Pro',
    category: 'Design',
    brandColorHex: 0xFF00C4CC,
    iconAsset: 'assets/brand/logos/canva.svg',
  ),
  PresetService(
    name: 'Audible',
    category: 'Books',
    brandColorHex: 0xFFF8991C,
    iconAsset: 'assets/brand/logos/audible.svg',
  ),
  PresetService(
    name: 'iCloud+',
    category: 'Cloud & Storage',
    brandColorHex: 0xFFA2AAAD,
    iconAsset: 'assets/brand/logos/icloud.svg',
  ),
  PresetService(
    name: '1Password',
    category: 'Utilities',
    brandColorHex: 0xFF0A85EA,
    iconAsset: null,
  ),
  PresetService(
    name: 'Notion Plus',
    category: 'Productivity',
    brandColorHex: 0xFF000000,
    iconAsset: null,
  ),
  PresetService(
    name: 'Figma',
    category: 'Design',
    brandColorHex: 0xFFF24E1E,
    iconAsset: null,
  ),
  PresetService(
    name: 'Discord Nitro',
    category: 'Utilities',
    brandColorHex: 0xFF5865F2,
    iconAsset: null,
  ),
  PresetService(
    name: 'Duolingo Super',
    category: 'Education',
    brandColorHex: 0xFF58CC02,
    iconAsset: null,
  ),
];
