import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:subtracker/core/brand/brand.dart';
import 'package:subtracker/core/theme.dart';

/// Vendored brand glyphs (SVG, single fill — they tint like the brand dots).
/// Sources are noted in each file's header comment; keywords mirror
/// `brandColorTable` so color and glyph always agree.
const brandIconAssetTable = <String, String>{
  'netflix': 'assets/brand/logos/netflix.svg',
  'spotify': 'assets/brand/logos/spotify.svg',
  'disney': 'assets/brand/logos/disneyplus.svg',
  'youtube': 'assets/brand/logos/youtube.svg',
  'amazon prime': 'assets/brand/logos/amazonprime.svg',
  'prime video': 'assets/brand/logos/amazonprime.svg',
  'microsoft': 'assets/brand/logos/microsoft.svg',
  'office 365': 'assets/brand/logos/microsoft.svg',
  'adobe': 'assets/brand/logos/adobecreativecloud.svg',
  'game pass': 'assets/brand/logos/xbox.svg',
  'xbox': 'assets/brand/logos/xbox.svg',
  'dropbox': 'assets/brand/logos/dropbox.svg',
  'canva': 'assets/brand/logos/canva.svg',
  'audible': 'assets/brand/logos/audible.svg',
  'icloud': 'assets/brand/logos/icloud.svg',
  'chatgpt': 'assets/brand/logos/chatgpt.svg',
  'openai': 'assets/brand/logos/chatgpt.svg',
  'claude': 'assets/brand/logos/claude.svg',
  'anthropic': 'assets/brand/logos/claude.svg',
  'cursor': 'assets/brand/logos/cursor.svg',
  'github': 'assets/brand/logos/github.svg',
  'copilot': 'assets/brand/logos/github.svg',
  'perplexity': 'assets/brand/logos/perplexity.svg',
  'midjourney': 'assets/brand/logos/midjourney.svg',
  'apple music': 'assets/brand/logos/applemusic.svg',
  'apple tv': 'assets/brand/logos/appletv.svg',
  'apple one': 'assets/brand/logos/appleone.svg',
  'max': 'assets/brand/logos/max.svg',
  'hbo': 'assets/brand/logos/max.svg',
  'crunchyroll': 'assets/brand/logos/crunchyroll.svg',
  'twitch': 'assets/brand/logos/twitch.svg',
  'google one': 'assets/brand/logos/googleone.svg',
  'google drive': 'assets/brand/logos/googleone.svg',
  'notion': 'assets/brand/logos/notion.svg',
  'figma': 'assets/brand/logos/figma.svg',
  '1password': 'assets/brand/logos/1password.svg',
  'slack': 'assets/brand/logos/slack.svg',
  'playstation': 'assets/brand/logos/playstation.svg',
  'ps plus': 'assets/brand/logos/playstation.svg',
  'nintendo': 'assets/brand/logos/nintendo.svg',
  'discord': 'assets/brand/logos/discord.svg',
  'duolingo': 'assets/brand/logos/duolingo.svg',
  'strava': 'assets/brand/logos/strava.svg',
  'medium': 'assets/brand/logos/medium.svg',
};

/// Resolves the brand glyph asset from a bare name: case-insensitive
/// substring match, null when unknown (callers fall back to the dot).
String? brandIconAssetFromName(String name) {
  final lowered = name.toLowerCase();
  for (final entry in brandIconAssetTable.entries) {
    if (lowered.contains(entry.key)) return entry.value;
  }
  return null;
}

/// The brand tile carrying the service's actual mark: a rounded square in
/// the brand color with the vendored glyph knocked out in `inkInverse`
/// (same geometry as [BrandTile]). Without an asset it degrades to the
/// BrandTile lettermark.
class BrandGlyphTile extends StatelessWidget {
  const BrandGlyphTile({
    super.key,
    this.asset,
    this.name,
    required this.color,
    this.size = 36,
  });

  final String? asset;
  final String? name;
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
      child: asset != null
          ? SvgPicture.asset(
              asset!,
              width: size * 0.54,
              height: size * 0.54,
              colorFilter: ColorFilter.mode(colors.inkInverse, BlendMode.srcIn),
            )
          : Text(
              brandInitial(name ?? ''),
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

/// Circular brand badge with crisp centered vector logo or lettermark fallback,
/// hairline border, and brand-tinted radial aura glow.
class BrandBadge extends StatelessWidget {
  const BrandBadge({
    super.key,
    this.asset,
    this.name,
    required this.color,
    this.size = 48,
    this.showGlow = true,
  });

  final String? asset;
  final String? name;
  final Color color;
  final double size;
  final bool showGlow;

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).extension<SublyColors>() ?? SublyColors.dark;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.step2,
        border: Border.all(color: colors.hairline, width: 1.0),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.35),
                  blurRadius: size * 0.45,
                  spreadRadius: 1.0,
                ),
              ]
            : null,
      ),
      child: asset != null
          ? SvgPicture.asset(
              asset!,
              width: size * 0.52,
              height: size * 0.52,
              colorFilter: ColorFilter.mode(colors.inkPrimary, BlendMode.srcIn),
            )
          : (name != null && name!.isNotEmpty)
              ? Text(
                  brandInitial(name!),
                  style: TextStyle(
                    color: colors.inkPrimary,
                    fontSize: size * 0.46,
                    height: 1.0,
                    fontWeight: FontWeight.w700,
                    fontFamily: SublyTypography.displayFamily,
                  ),
                )
              : null,
    );
  }
}

