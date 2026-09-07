import 'package:flutter/material.dart';
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
};

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
