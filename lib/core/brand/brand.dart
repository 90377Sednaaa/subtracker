import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:subtracker/core/brand/brand_icons.dart';
import 'package:subtracker/core/theme.dart';

/// The Subly monogram — the user-authored bold "S" (assets/branding/
/// subly_mark.svg), tinted at runtime so it always carries the active
/// theme's ink color.
class SublyMark extends StatelessWidget {
  const SublyMark({super.key, this.size = 96, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ??
        Theme.of(context).extension<SublyColors>()?.inkPrimary ??
        const Color(0xFFF2F0EB);
    return SvgPicture.asset(
      'assets/branding/subly_mark.svg',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(c, BlendMode.srcIn),
    );
  }
}

/// The Subly brand badge with inverted theme colors and subtle 1-2px rounded corners:
/// - Dark theme: white background (#FFFFFF) with black "S" (#0A0A0C).
/// - Light theme: black background (#0A0A0C) with white "S" (#FFFFFF).
class SublyLogoBadge extends StatelessWidget {
  const SublyLogoBadge({
    super.key,
    this.size = 32,
    this.radius = 2.0,
  });

  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.white : const Color(0xFF0A0A0C);
    final markColor = isDark ? const Color(0xFF0A0A0C) : Colors.white;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(radius),
      ),
      alignment: Alignment.center,
      child: SublyMark(
        size: size * 0.64,
        color: markColor,
      ),
    );
  }
}


/// The one thread of chroma in the monochrome UI: a small brand-color dot
/// (Netflix red, Spotify green, ...) shown on ledger cards and strips.
class BrandDot extends StatelessWidget {
  const BrandDot({super.key, required this.color, this.size = 8});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// The service's mark: a rounded square in the brand color carrying the
/// vendored brand glyph when one matches (simple-icons, knocked out in
/// inkInverse), degrading to the lettermark initial otherwise. Used in the
/// renewal calendar and ledger rows.
class BrandTile extends StatelessWidget {
  const BrandTile({
    super.key,
    required this.name,
    required this.color,
    this.size = 22,
  });

  final String name;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).extension<SublyColors>() ?? SublyColors.dark;
    final icon = brandIconFromName(name);
    final asset = icon == null ? brandIconAssetFromName(name) : null;

    Widget child;
    if (icon != null) {
      child = Icon(
        icon,
        size: size * 0.58,
        color: colors.inkInverse,
      );
    } else if (asset != null) {
      child = SvgPicture.asset(
        asset,
        width: size * 0.54,
        height: size * 0.54,
        colorFilter: ColorFilter.mode(colors.inkInverse, BlendMode.srcIn),
      );
    } else {
      child = Text(
        brandInitial(name),
        style: TextStyle(
          color: colors.inkInverse,
          fontSize: size * 0.52,
          height: 1.0,
          fontWeight: FontWeight.w700,
          fontFamily: SublyTypography.displayFamily,
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}

/// The lettermark glyph: first character, uppercased ('?' when empty).
String brandInitial(String name) {
  final t = name.trim();
  return t.isEmpty ? '?' : t[0].toUpperCase();
}
