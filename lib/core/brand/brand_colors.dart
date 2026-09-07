import 'package:flutter/material.dart';
import 'package:subtracker/core/theme.dart';
import 'package:subtracker/features/subscriptions/domain/subscription.dart';

/// The one thread of chroma in the monochrome UI. Matching is
/// case-insensitive substring on the service name; unknown names fall back
/// to their category color, then to 'Other' gray. Manual overrides (stored
/// on the document) always win.
const brandColorTable = <String, int>{
  'netflix': 0xFFE50914,
  'spotify': 0xFF1DB954,
  'disney': 0xFF113CCF,
  'youtube': 0xFFFF0033,
  'amazon prime': 0xFF00A8E1,
  'prime video': 0xFF00A8E1,
  'microsoft': 0xFFD83B01,
  'office 365': 0xFFD83B01,
  'adobe': 0xFFFA0F00,
  'game pass': 0xFF52B043,
  'xbox': 0xFF52B043,
  'dropbox': 0xFF0061FF,
  'canva': 0xFF00C4CC,
  'audible': 0xFFF8991C,
  'icloud': 0xFFA2AAAD,
  'chatgpt': 0xFF10A37F,
  'openai': 0xFF10A37F,
  'claude': 0xFFD97757,
  'anthropic': 0xFFD97757,
  'cursor': 0xFF8B5CF6,
  'github': 0xFF181717,
  'copilot': 0xFF181717,
  'perplexity': 0xFF20B2AA,
  'midjourney': 0xFFFFFFFF,
  'apple music': 0xFFFA243C,
  'apple tv': 0xFF000000,
  'apple one': 0xFF000000,
  'apple': 0xFF000000,
  'max': 0xFF002BE7,
  'hbo': 0xFF002BE7,
  'crunchyroll': 0xFFFF6600,
  'twitch': 0xFF9146FF,
  'google one': 0xFF4285F4,
  'google drive': 0xFF34A853,
  'google': 0xFF4285F4,
  'notion': 0xFF000000,
  'figma': 0xFFF24E1E,
  '1password': 0xFF0A85EA,
  'slack': 0xFF4A154B,
  'playstation': 0xFF003791,
  'ps plus': 0xFF003791,
  'nintendo': 0xFFE60012,
  'discord': 0xFF5865F2,
  'duolingo': 0xFF58CC02,
  'strava': 0xFFFC4C02,
  'medium': 0xFF000000,
};

/// Resolves a contrast-safe color for brand glyphs rendered on dark surfaces.
/// Very dark or black brands (luminance < 0.03, like Apple, GitHub, Notion)
/// fall back to `colors.inkPrimary` (crisp white in dark mode).
Color effectiveBrandGlyphColor(Color brandColor, SublyColors colors) {
  if (brandColor.computeLuminance() < 0.03) {
    return colors.inkPrimary;
  }
  return brandColor;
}

const categoryColorTable = <String, int>{
  'entertainment': 0xFFC96B6B,
  'streaming': 0xFFC96B6B,
  'music': 0xFF6FA97C,
  'productivity': 0xFF7C93BE,
  'gaming': 0xFFA08BC0,
  'books': 0xFFC09878,
  'cloud': 0xFF78A0AC,
  'storage': 0xFF78A0AC,
  'shopping': 0xFFB8A878,
  'design': 0xFF78A8A0,
  'education': 0xFF58CC02,
  'utilities': 0xFF0A85EA,
};

const otherColor = Color(0xFF8C8C8C);

/// Resolves the color for a subscription category.
Color categoryColorFromName(String category) {
  final lowered = category.toLowerCase();
  for (final entry in categoryColorTable.entries) {
    if (lowered.contains(entry.key)) return Color(entry.value);
  }
  return otherColor;
}

/// Resolves the brand color from a bare name: name match → category
/// keyword → 'Other'.
Color brandColorFromName(String name) {
  final lowered = name.toLowerCase();
  for (final entry in brandColorTable.entries) {
    if (lowered.contains(entry.key)) return Color(entry.value);
  }
  for (final entry in categoryColorTable.entries) {
    if (lowered.contains(entry.key)) return Color(entry.value);
  }
  return otherColor;
}

/// Resolves the brand color for a subscription: manual override →
/// name match → category → 'Other'.
Color brandColorFor(Subscription sub) {
  final override = sub.brandColor;
  if (override != null && override.isNotEmpty) {
    final hex = override.replaceFirst('#', '');
    return Color(0xFF000000 | int.parse(hex, radix: 16));
  }
  return brandColorFromName(sub.name);
}

/// The swatch row in the form: 'Auto' first (null override), then brands.
const swatchChoices = <({String label, int? hex})>[
  (label: 'Auto', hex: null),
  (label: 'Netflix', hex: 0xFFE50914),
  (label: 'Spotify', hex: 0xFF1DB954),
  (label: 'Disney+', hex: 0xFF113CCF),
  (label: 'YouTube', hex: 0xFFFF0033),
  (label: 'Prime', hex: 0xFF00A8E1),
  (label: 'Microsoft', hex: 0xFFD83B01),
  (label: 'Adobe', hex: 0xFFFA0F00),
  (label: 'Xbox', hex: 0xFF52B043),
  (label: 'Dropbox', hex: 0xFF0061FF),
  (label: 'Canva', hex: 0xFF00C4CC),
  (label: 'Audible', hex: 0xFFF8991C),
  (label: 'iCloud', hex: 0xFFA2AAAD),
  (label: 'Other', hex: 0xFF8C8C8C),
];

String? hexToStore(int? hex) {
  if (hex == null) return null;
  return hex.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase();
}
