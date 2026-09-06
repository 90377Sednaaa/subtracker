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
