import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subtracker/core/brand/brand_icons.dart';

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

  testWidgets('BrandGlyphTile falls back to a lettermark without an asset',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: BrandGlyphTile(color: Color(0xFF8C8C8C), name: "Bob's Gym"),
    ));
    expect(find.byType(SvgPicture), findsNothing);
    expect(find.text('B'), findsOneWidget);
  });
}
