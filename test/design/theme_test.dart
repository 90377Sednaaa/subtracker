import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subtracker/core/theme.dart';

void main() {
  group('SublyColors tokens', () {
    test('dark theme carries the night-ledger tokens', () {
      final theme = buildSublyTheme(Brightness.dark);
      final colors = theme.extension<SublyColors>()!;
      expect(colors.base, const Color(0xFF0A0A0C));
      expect(colors.inkPrimary, const Color(0xFFF2F0EB));
      expect(colors.inkSecondary, const Color(0xFFA6A399));
      expect(colors.ctaFill, const Color(0xFFF2F0EB));
      expect(colors.inkInverse, const Color(0xFF141412));
      expect(colors.statusRenewalSoon, const Color(0xFFD9B380));
      expect(colors.statusTrial, const Color(0xFFC77E6E));
      expect(colors.statusSettled, const Color(0xFF8FA98F));
      expect(theme.scaffoldBackgroundColor, colors.base);
      expect(theme.colorScheme.brightness, Brightness.dark);
    });

    test('light theme carries the warm-paper tokens', () {
      final theme = buildSublyTheme(Brightness.light);
      final colors = theme.extension<SublyColors>()!;
      expect(colors.base, const Color(0xFFF5F3EE));
      expect(colors.inkPrimary, const Color(0xFF1A1915));
      expect(colors.ctaFill, const Color(0xFF1A1915));
      expect(colors.inkInverse, const Color(0xFFF5F3EE));
      expect(colors.statusRenewalSoon, const Color(0xFF9A7434));
      expect(theme.scaffoldBackgroundColor, colors.base);
    });

    test('elevation is zero in both themes (hairlines do the work)', () {
      for (final b in Brightness.values) {
        final theme = buildSublyTheme(b);
        expect(theme.cardTheme.elevation ?? 0, 0);
        expect(theme.appBarTheme.elevation ?? 0, 0);
      }
    });
  });

  group('SublyTypography', () {
    test('display faces are Space Grotesk with tabular money', () {
      final hero = SublyTypography.heroMoney;
      expect(hero.fontFamily, 'SpaceGrotesk');
      expect(hero.fontSize, 56);
      expect(hero.fontFeatures, contains(FontFeature.tabularFigures()));

      final title = SublyTypography.titleL;
      expect(title.fontFamily, 'SpaceGrotesk');
      expect(title.fontSize, 24);
    });

    test('body faces are Inter', () {
      expect(SublyTypography.body.fontFamily, 'InterSubly');
      expect(SublyTypography.body.fontSize, 15);
      final money = SublyTypography.moneyRow;
      expect(money.fontFamily, 'InterSubly');
      expect(money.fontFeatures, contains(FontFeature.tabularFigures()));
      final label = SublyTypography.label;
      expect(label.letterSpacing, greaterThan(0)); // +2% tracking, uppercase
    });

    test('textTheme roles are wired onto the theme', () {
      final theme = buildSublyTheme(Brightness.dark);
      expect(theme.textTheme.titleLarge?.fontFamily, 'SpaceGrotesk');
      expect(theme.textTheme.bodyMedium?.fontFamily, 'InterSubly');
    });
  });

  group('SublyMotion', () {
    test('cinematic-calm tokens', () {
      expect(SublyMotion.durBase, const Duration(milliseconds: 320));
      expect(SublyMotion.durHero, const Duration(milliseconds: 700));
      expect(SublyMotion.stagger, const Duration(milliseconds: 40));
      expect(SublyMotion.curveStandard, Curves.easeOutCubic);
    });
  });

  test('theme mode defaults to dark', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(themeModeProvider), ThemeMode.dark);
  });
}
