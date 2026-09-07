import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subtracker/core/brand/brand_icons.dart';
import 'package:subtracker/core/theme.dart';

void main() {
  group('BrandBadge', () {
    testWidgets('renders circular disc with asset and glow', (tester) async {
      const brandColor = Color(0xFFE50914);
      const size = 48.0;

      await tester.pumpWidget(
        MaterialApp(
          theme: buildSublyTheme(Brightness.dark),
          home: const Scaffold(
            body: Center(
              child: BrandBadge(
                name: 'Netflix',
                asset: 'assets/brand/logos/netflix.svg',
                color: brandColor,
                size: size,
                showGlow: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(BrandBadge), findsOneWidget);
      expect(find.byType(SvgPicture), findsOneWidget);

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(BrandBadge),
          matching: find.byType(Container),
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);
      expect(decoration.border, isNotNull);
      expect(decoration.border!.top.width, 1.0);
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.length, 1);

      final shadow = decoration.boxShadow!.first;
      expect(shadow.color, brandColor.withValues(alpha: 0.35));
      expect(shadow.blurRadius, size * 0.45);
      expect(shadow.spreadRadius, 1.0);
    });

    testWidgets('renders without asset (fallback lettermark)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildSublyTheme(Brightness.dark),
          home: const Scaffold(
            body: Center(
              child: BrandBadge(
                name: 'Custom Service',
                color: Color(0xFF113CCF),
                size: 48,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(BrandBadge), findsOneWidget);
      expect(find.byType(SvgPicture), findsNothing);
      expect(find.text('C'), findsOneWidget);
    });

    testWidgets('renders circular shape with specified size', (tester) async {
      const size = 72.0;

      await tester.pumpWidget(
        MaterialApp(
          theme: buildSublyTheme(Brightness.dark),
          home: const Scaffold(
            body: Center(
              child: BrandBadge(
                name: 'Spotify',
                color: Color(0xFF1DB954),
                size: size,
              ),
            ),
          ),
        ),
      );

      final badgeSize = tester.getSize(find.byType(BrandBadge));
      expect(badgeSize.width, size);
      expect(badgeSize.height, size);

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(BrandBadge),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);
    });

    testWidgets('supports showGlow: false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildSublyTheme(Brightness.dark),
          home: const Scaffold(
            body: Center(
              child: BrandBadge(
                name: 'Netflix',
                asset: 'assets/brand/logos/netflix.svg',
                color: Color(0xFFE50914),
                size: 48,
                showGlow: false,
              ),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(BrandBadge),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.boxShadow, isNull);
    });
  });

  group('brandIconAssetTable & brandIconAssetFromName', () {
    test('resolves newly added services correctly', () {
      final expectedResolutions = <String, String>{
        'ChatGPT Plus': 'assets/brand/logos/chatgpt.svg',
        'OpenAI': 'assets/brand/logos/chatgpt.svg',
        'Claude Pro': 'assets/brand/logos/claude.svg',
        'Anthropic Claude': 'assets/brand/logos/claude.svg',
        'Cursor': 'assets/brand/logos/cursor.svg',
        'GitHub Copilot': 'assets/brand/logos/github.svg',
        'Perplexity Pro': 'assets/brand/logos/perplexity.svg',
        'Midjourney': 'assets/brand/logos/midjourney.svg',
        'Apple Music': 'assets/brand/logos/applemusic.svg',
        'Apple TV+': 'assets/brand/logos/appletv.svg',
        'Apple One': 'assets/brand/logos/appleone.svg',
        'Max': 'assets/brand/logos/max.svg',
        'HBO Max': 'assets/brand/logos/max.svg',
        'Crunchyroll': 'assets/brand/logos/crunchyroll.svg',
        'Twitch': 'assets/brand/logos/twitch.svg',
        'Google One': 'assets/brand/logos/googleone.svg',
        'Google Drive': 'assets/brand/logos/googleone.svg',
        'Notion Plus': 'assets/brand/logos/notion.svg',
        'Figma': 'assets/brand/logos/figma.svg',
        '1Password': 'assets/brand/logos/1password.svg',
        'Slack': 'assets/brand/logos/slack.svg',
        'PlayStation Plus': 'assets/brand/logos/playstation.svg',
        'PS Plus': 'assets/brand/logos/playstation.svg',
        'Nintendo Switch Online': 'assets/brand/logos/nintendo.svg',
        'Discord Nitro': 'assets/brand/logos/discord.svg',
        'Duolingo Super': 'assets/brand/logos/duolingo.svg',
        'Strava': 'assets/brand/logos/strava.svg',
        'Medium': 'assets/brand/logos/medium.svg',
      };

      for (final entry in expectedResolutions.entries) {
        expect(
          brandIconAssetFromName(entry.key),
          entry.value,
          reason: '${entry.key} should resolve to ${entry.value}',
        );
      }
    });
  });
}
