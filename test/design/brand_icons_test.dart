import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subtracker/core/brand/brand.dart';
import 'package:subtracker/core/brand/brand_colors.dart';
import 'package:subtracker/core/brand/brand_icons.dart';
import 'package:subtracker/core/theme.dart';

/// Every service seeded in the cancellation directory must resolve to a
/// vendored brand glyph.
const directoryNames = [
  'Netflix',
  'Spotify',
  'Disney+',
  'YouTube Premium',
  'Amazon Prime',
  'Microsoft 365',
  'Adobe Creative Cloud',
  'Xbox Game Pass',
  'Dropbox',
  'Canva Pro',
  'Audible',
  'iCloud+',
];

void main() {
  test('resolves every directory service case-insensitively', () {
    for (final name in directoryNames) {
      expect(brandIconAssetFromName(name), isNotNull,
          reason: '$name should match a brand glyph');
    }
    expect(brandIconAssetFromName('NETFLIX'),
        brandIconAssetFromName('Netflix'));
    expect(brandIconAssetFromName('my spotify family'),
        contains('spotify'));
  });

  test('unknown names return null so callers can fall back', () {
    expect(brandIconAssetFromName("Bob's Gym"), isNull);
    expect(brandIconAssetFromName(''), isNull);
  });

  test('every mapped glyph exists on disk', () {
    for (final asset in brandIconAssetTable.values) {
      final file = File('assets${asset.replaceFirst('assets', '')}');
      expect(file.existsSync(), isTrue, reason: '$asset is missing');
    }
  });

  test('brandIconFromName resolves directory and modern services to IconData', () {
    final testNames = [
      'Netflix',
      'Spotify',
      'YouTube Premium',
      'Amazon Prime',
      'Microsoft 365',
      'Xbox Game Pass',
      'Dropbox',
      'Audible',
      'iCloud+',
      'ChatGPT Plus',
      'Claude Pro',
      'Cursor',
      'GitHub Copilot',
      'Perplexity Pro',
      'Notion Plus',
      'Figma',
      '1Password',
      'Slack',
      'PlayStation Plus',
      'Discord Nitro',
      'Duolingo Super',
      'Strava',
      'Medium',
    ];

    for (final name in testNames) {
      final icon = brandIconFromName(name);
      expect(icon, isNotNull, reason: '$name should resolve to an IconData');
    }

    expect(brandIconFromName("Bob's Gym"), isNull);
    expect(brandIconFromName(''), isNull);
  });

  test('effectiveBrandGlyphColor provides high-contrast fallback for black/dark colors', () {
    const darkColors = SublyColors.dark;

    // Black / near-black brands should resolve to inkPrimary (white in dark mode)
    expect(
      effectiveBrandGlyphColor(const Color(0xFF000000), darkColors),
      darkColors.inkPrimary,
    );
    expect(
      effectiveBrandGlyphColor(const Color(0xFF181717), darkColors),
      darkColors.inkPrimary,
    );

    // Vibrant colors should remain their authentic brand color
    const netflixRed = Color(0xFFE50914);
    const spotifyGreen = Color(0xFF1DB954);
    const discordBlurple = Color(0xFF5865F2);

    expect(effectiveBrandGlyphColor(netflixRed, darkColors), netflixRed);
    expect(effectiveBrandGlyphColor(spotifyGreen, darkColors), spotifyGreen);
    expect(effectiveBrandGlyphColor(discordBlurple, darkColors), discordBlurple);
  });

  testWidgets('BrandGlyphTile renders the tinted glyph in a brand tile',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: BrandGlyphTile(
        asset: 'assets/brand/logos/netflix.svg',
        color: Color(0xFFE50914),
      ),
    ));
    expect(find.byType(SvgPicture), findsOneWidget);
    expect(find.byType(BrandGlyphTile), findsOneWidget);
  });

  testWidgets('BrandGlyphTile renders official Icon when name matches',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: BrandGlyphTile(
        name: 'Netflix',
        color: Color(0xFFE50914),
      ),
    ));
    expect(find.byType(Icon), findsOneWidget);
    expect(find.byType(BrandGlyphTile), findsOneWidget);
  });

  testWidgets('BrandTile renders official Icon when name matches',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: BrandTile(
        name: 'Spotify',
        color: Color(0xFF1DB954),
      ),
    ));
    expect(find.byType(Icon), findsOneWidget);
    expect(find.byType(BrandTile), findsOneWidget);
  });
}
