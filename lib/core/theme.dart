import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ============================================================================
/// SUBLy DESIGN TOKENS — the single source of every visual decision.
/// Design plan: docs/superpowers/plans/2026-09-06-subly-design.md
/// Screens read tokens from here; hardcoding a color/font/size is a bug.
/// ============================================================================

/// Non-Material color tokens (ink tiers, surfaces, status tints, the glow).
@immutable
class SublyColors extends ThemeExtension<SublyColors> {
  const SublyColors({
    required this.base,
    required this.step1,
    required this.step2,
    required this.step3,
    required this.hairline,
    required this.inkPrimary,
    required this.inkSecondary,
    required this.inkTertiary,
    required this.inkInverse,
    required this.ctaFill,
    required this.glow,
    required this.statusRenewalSoon,
    required this.statusTrial,
    required this.statusSettled,
  });

  final Color base;
  final Color step1;
  final Color step2;
  final Color step3;
  final Color hairline;
  final Color inkPrimary;
  final Color inkSecondary;
  final Color inkTertiary;
  final Color inkInverse;
  final Color ctaFill;
  final Color glow;
  final Color statusRenewalSoon;
  final Color statusTrial;
  final Color statusSettled;

  static const dark = SublyColors(
    base: Color(0xFF0A0A0C),
    step1: Color(0xFF131316),
    step2: Color(0xFF1A1A1F),
    step3: Color(0xFF232329),
    hairline: Color(0x12FFFFFF), // white @ 7%
    inkPrimary: Color(0xFFF2F0EB),
    inkSecondary: Color(0xFFA6A399),
    inkTertiary: Color(0xFF6E6B63),
    inkInverse: Color(0xFF141412),
    ctaFill: Color(0xFFF2F0EB),
    glow: Color(0x14F2F0EB), // warm white @ 8%
    statusRenewalSoon: Color(0xFFD9B380),
    statusTrial: Color(0xFFC77E6E),
    statusSettled: Color(0xFF8FA98F),
  );

  static const light = SublyColors(
    base: Color(0xFFF5F3EE),
    step1: Color(0xFFFBFAF7),
    step2: Color(0xFFFFFFFF),
    step3: Color(0xFFFFFFFF),
    hairline: Color(0x14141412), // ink @ 8%
    inkPrimary: Color(0xFF1A1915),
    inkSecondary: Color(0xFF6B6860),
    inkTertiary: Color(0xFFA19D93),
    inkInverse: Color(0xFFF5F3EE),
    ctaFill: Color(0xFF1A1915),
    glow: Color(0x0A1A1915), // ink @ 4%
    statusRenewalSoon: Color(0xFF9A7434),
    statusTrial: Color(0xFFA65445),
    statusSettled: Color(0xFF5E7A5E),
  );

  @override
  SublyColors copyWith({Color? base, Color? inkPrimary}) =>
      SublyColors(
        base: base ?? this.base,
        step1: step1,
        step2: step2,
        step3: step3,
        hairline: hairline,
        inkPrimary: inkPrimary ?? this.inkPrimary,
        inkSecondary: inkSecondary,
        inkTertiary: inkTertiary,
        inkInverse: inkInverse,
        ctaFill: ctaFill,
        glow: glow,
        statusRenewalSoon: statusRenewalSoon,
        statusTrial: statusTrial,
        statusSettled: statusSettled,
      );

  @override
  SublyColors lerp(SublyColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return SublyColors(
      base: l(base, other.base),
      step1: l(step1, other.step1),
      step2: l(step2, other.step2),
      step3: l(step3, other.step3),
      hairline: l(hairline, other.hairline),
      inkPrimary: l(inkPrimary, other.inkPrimary),
      inkSecondary: l(inkSecondary, other.inkSecondary),
      inkTertiary: l(inkTertiary, other.inkTertiary),
      inkInverse: l(inkInverse, other.inkInverse),
      ctaFill: l(ctaFill, other.ctaFill),
      glow: l(glow, other.glow),
      statusRenewalSoon: l(statusRenewalSoon, other.statusRenewalSoon),
      statusTrial: l(statusTrial, other.statusTrial),
      statusSettled: l(statusSettled, other.statusSettled),
    );
  }
}

extension SublyColorsContext on BuildContext {
  /// `context.sublyColors.inkPrimary` — the token accessor for screens.
  SublyColors get sublyColors =>
      Theme.of(this).extension<SublyColors>() ?? SublyColors.dark;
}

/// Typography: Space Grotesk (display, money) + Inter (body, labels).
/// Variable fonts are bundled (offline-safe); weights come from the
/// `wght` axis via fontVariations, money uses tabular figures.
class SublyTypography {
  SublyTypography._();

  static const displayFamily = 'SpaceGrotesk';
  static const bodyFamily = 'InterSubly';

  static List<FontVariation> _wght(double w) =>
      [FontVariation('wght', w)];

  /// The app's face: the animated dashboard total.
  static TextStyle get heroMoney => TextStyle(
        fontFamily: displayFamily,
        fontSize: 56,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.84, // −1.5%
        fontFeatures: const [FontFeature.tabularFigures()],
        fontVariations: _wght(500),
      );

  static TextStyle get titleL => TextStyle(
        fontFamily: displayFamily,
        fontSize: 24,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.36,
        fontVariations: _wght(500),
      );

  static TextStyle get titleM => TextStyle(
        fontFamily: displayFamily,
        fontSize: 20,
        fontWeight: FontWeight.w500,
        fontVariations: _wght(500),
      );

  /// Right-aligned card costs — tabular so columns align.
  static TextStyle get moneyRow => TextStyle(
        fontFamily: bodyFamily,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        fontFeatures: const [FontFeature.tabularFigures()],
        fontVariations: _wght(500),
      );

  static TextStyle get body => TextStyle(
        fontFamily: bodyFamily,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        fontVariations: _wght(400),
      );

  static TextStyle get label => TextStyle(
        fontFamily: bodyFamily,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.26, // +2% tracking
        fontVariations: _wght(500),
      );

  static TextStyle get caption => TextStyle(
        fontFamily: bodyFamily,
        fontSize: 11,
        fontWeight: FontWeight.w400,
        fontVariations: _wght(400),
      );
}

/// Motion: cinematic calm — ease-out, no bounce, haptic accents.
class SublyMotion {
  SublyMotion._();

  static const durInstant = Duration(milliseconds: 100);
  static const durQuick = Duration(milliseconds: 250);
  static const durBase = Duration(milliseconds: 320);
  static const durSlow = Duration(milliseconds: 480);
  static const durHero = Duration(milliseconds: 700);
  static const stagger = Duration(milliseconds: 40);

  static const curveStandard = Curves.easeOutCubic;
  static const curveEmphasized = Curves.easeInOutCubicEmphasized;
}

/// Spacing scale (4-base) and radii — use these, never magic numbers.
class SublySpace {
  SublySpace._();

  static const s4 = 4.0;
  static const s8 = 8.0;
  static const s12 = 12.0;
  static const s16 = 16.0;
  static const s24 = 24.0;
  static const s32 = 32.0;
  static const s48 = 48.0;
  static const s64 = 64.0;

  static const screenMargin = s24;
  static const rowHeight = 76.0;
  static const radiusCard = 16.0;
  static const radiusSheet = 24.0;
  static const radiusField = 14.0;
}

/// Dark by default (the night ledger is the identity); light ships too.
class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.dark;

  void set(ThemeMode mode) => state = mode;

  void toggle() =>
      state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
}

final themeModeProvider =
    NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);

/// Builds the full ThemeData for a brightness from the token sheet.
ThemeData buildSublyTheme(Brightness brightness) {
  final colors =
      brightness == Brightness.dark ? SublyColors.dark : SublyColors.light;
  final scheme = ColorScheme(
    brightness: brightness,
    primary: colors.inkPrimary,
    onPrimary: colors.inkInverse,
    secondary: colors.inkSecondary,
    onSecondary: colors.inkInverse,
    surface: colors.base,
    onSurface: colors.inkPrimary,
    surfaceContainerHighest: colors.step2,
    onSurfaceVariant: colors.inkSecondary,
    outline: colors.inkTertiary,
    error: colors.statusTrial,
    onError: colors.inkInverse,
  );

  TextTheme textTheme() => TextTheme(
        headlineLarge: SublyTypography.heroMoney,
        titleLarge: SublyTypography.titleM,
        titleMedium: SublyTypography.moneyRow,
        bodyMedium: SublyTypography.body,
        bodySmall: SublyTypography.caption,
        labelMedium: SublyTypography.label,
      );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: colors.base,
    extensions: [colors],
    textTheme: textTheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: colors.base,
      foregroundColor: colors.inkPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: SublyTypography.titleL.copyWith(color: colors.inkPrimary),
    ),
    cardTheme: CardThemeData(
      color: colors.step1,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SublySpace.radiusCard),
        side: BorderSide(color: colors.hairline),
      ),
    ),
    dividerTheme: DividerThemeData(color: colors.hairline, thickness: 1),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colors.ctaFill,
      foregroundColor: colors.inkInverse,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SublySpace.radiusCard),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colors.ctaFill,
        foregroundColor: colors.inkInverse,
        minimumSize: const Size(64, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SublySpace.radiusField),
        ),
        textStyle: SublyTypography.moneyRow,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.step1,
      labelStyle: SublyTypography.body.copyWith(color: colors.inkSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SublySpace.radiusField),
        borderSide: BorderSide(color: colors.hairline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SublySpace.radiusField),
        borderSide: BorderSide(color: colors.hairline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SublySpace.radiusField),
        borderSide: BorderSide(color: colors.inkPrimary),
      ),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: colors.inkSecondary,
      titleTextStyle: SublyTypography.titleM.copyWith(
          fontSize: 16, color: colors.inkPrimary, fontVariations: const []),
      subtitleTextStyle: SublyTypography.body.copyWith(
        color: colors.inkSecondary,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: colors.step3,
      contentTextStyle: SublyTypography.body.copyWith(
        color: colors.inkPrimary,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SublySpace.radiusField),
      ),
    ),
  );
}
