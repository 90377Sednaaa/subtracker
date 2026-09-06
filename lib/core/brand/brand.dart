import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

/// The service's lettermark: a rounded square in the brand color with the
/// service's initial (the N/tv style of the reference apps). Used in the
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
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      alignment: Alignment.center,
      child: Text(
        brandInitial(name),
        style: TextStyle(
          color: colors.inkInverse,
          fontSize: size * 0.52,
          height: 1.0,
          fontWeight: FontWeight.w700,
          fontFamily: SublyTypography.displayFamily,
        ),
      ),
    );
  }
}

/// The lettermark glyph: first character, uppercased ('?' when empty).
String brandInitial(String name) {
  final t = name.trim();
  return t.isEmpty ? '?' : t[0].toUpperCase();
}
