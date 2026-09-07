import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:subtracker/core/brand/brand.dart';
import 'package:subtracker/core/brand/brand_colors.dart';
import 'package:subtracker/core/theme.dart';

/// Authoritative mapping from normalized brand name keywords to official
/// SimpleIcons and FontAwesomeIcons IconData glyphs.
final brandIconTable = <String, IconData>{
  'netflix': SimpleIcons.netflix,
  'spotify': SimpleIcons.spotify,
  'youtube': SimpleIcons.youtube,
  'amazon': FontAwesomeIcons.amazon.data,
  'prime': FontAwesomeIcons.amazon.data,
  'microsoft': FontAwesomeIcons.microsoft.data,
  'office': FontAwesomeIcons.microsoft.data,
  'xbox': FontAwesomeIcons.xbox.data,
  'game pass': FontAwesomeIcons.xbox.data,
  'dropbox': SimpleIcons.dropbox,
  'audible': SimpleIcons.audible,
  'icloud': SimpleIcons.icloud,
  'chatgpt': FontAwesomeIcons.openai.data,
  'openai': FontAwesomeIcons.openai.data,
  'claude': SimpleIcons.claude,
  'anthropic': SimpleIcons.anthropic,
  'cursor': SimpleIcons.cursor,
  'github': SimpleIcons.github,
  'copilot': SimpleIcons.githubcopilot,
  'perplexity': SimpleIcons.perplexity,
  'apple music': SimpleIcons.applemusic,
  'apple tv': SimpleIcons.appletv,
  'apple one': SimpleIcons.apple,
  'apple': SimpleIcons.apple,
  'max': SimpleIcons.max,
  'hbo': SimpleIcons.hbo,
  'crunchyroll': SimpleIcons.crunchyroll,
  'twitch': SimpleIcons.twitch,
  'google one': SimpleIcons.google,
  'google drive': SimpleIcons.googledrive,
  'google': SimpleIcons.google,
  'notion': SimpleIcons.notion,
  'figma': SimpleIcons.figma,
  '1password': SimpleIcons.n1password,
  'slack': FontAwesomeIcons.slack.data,
  'playstation': SimpleIcons.playstation,
  'ps plus': SimpleIcons.playstation,
  'discord': SimpleIcons.discord,
  'duolingo': SimpleIcons.duolingo,
  'strava': SimpleIcons.strava,
  'medium': SimpleIcons.medium,
};

/// Resolves the official brand IconData from a bare name: case-insensitive
/// substring match, null when unknown.
IconData? brandIconFromName(String name) {
  final lowered = name.toLowerCase();
  for (final entry in brandIconTable.entries) {
    if (lowered.contains(entry.key)) return entry.value;
  }
  return null;
}

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
    this.icon,
    this.asset,
    this.name,
    required this.color,
    this.size = 36,
  });

  final IconData? icon;
  final String? asset;
  final String? name;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).extension<SublyColors>() ?? SublyColors.dark;
    final isPrime = name != null && name!.toLowerCase().contains('prime');
    final isCursor = name != null && name!.toLowerCase().contains('cursor');
    final resolvedIcon = (isPrime || isCursor)
        ? null
        : (icon ?? (name != null ? brandIconFromName(name!) : null));
    final resolvedAsset =
        asset ?? (name != null ? brandIconAssetFromName(name!) : null);

    Widget child;
    if (resolvedIcon != null) {
      child = Icon(
        resolvedIcon,
        size: size * 0.58,
        color: colors.inkInverse,
      );
    } else if (resolvedAsset != null) {
      child = SvgPicture.asset(
        resolvedAsset,
        width: size * 0.54,
        height: size * 0.54,
        colorFilter: ColorFilter.mode(colors.inkInverse, BlendMode.srcIn),
      );
    } else {
      child = Text(
        brandInitial(name ?? ''),
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

/// Circular brand badge with crisp centered official logo or lettermark fallback,
/// hairline border, and brand-tinted radial aura glow. Renders official brand colors.
class BrandBadge extends StatelessWidget {
  const BrandBadge({
    super.key,
    this.icon,
    this.asset,
    this.name,
    this.category,
    required this.color,
    this.size = 48,
    this.showGlow = true,
  });

  final IconData? icon;
  final String? asset;
  final String? name;
  final String? category;
  final Color color;
  final double size;
  final bool showGlow;

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).extension<SublyColors>() ?? SublyColors.dark;
    final glyphColor = effectiveBrandGlyphColor(color, colors);
    final isPrime = name != null && name!.toLowerCase().contains('prime');
    final isCursor = name != null && name!.toLowerCase().contains('cursor');
    final resolvedIcon = (isPrime || isCursor)
        ? null
        : (icon ?? (name != null ? brandIconFromName(name!) : null));
    final resolvedAsset =
        asset ?? (name != null ? brandIconAssetFromName(name!) : null);

    Widget? child;
    if (resolvedIcon != null) {
      child = Icon(
        resolvedIcon,
        size: size * 0.52,
        color: glyphColor,
      );
    } else if (resolvedAsset != null) {
      child = SvgPicture.asset(
        resolvedAsset,
        width: size * 0.52,
        height: size * 0.52,
        colorFilter: ColorFilter.mode(glyphColor, BlendMode.srcIn),
      );
    } else if (category != null && categoryIconFromName(category!) != null) {
      child = Icon(
        categoryIconFromName(category!),
        size: size * 0.52,
        color: glyphColor,
      );
    } else if (name != null && name!.isNotEmpty) {
      child = Text(
        brandInitial(name!),
        style: TextStyle(
          color: glyphColor,
          fontSize: size * 0.46,
          height: 1.0,
          fontWeight: FontWeight.w700,
          fontFamily: SublyTypography.displayFamily,
        ),
      );
    }

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
      child: child,
    );
  }
}

/// Resolves a matching Lucide icon for standard subscription categories.
IconData? categoryIconFromName(String category) {
  switch (category.toLowerCase().trim()) {
    case 'entertainment':
    case 'streaming':
      return LucideIcons.tv;
    case 'music':
    case 'audio':
      return LucideIcons.music;
    case 'productivity':
    case 'work':
      return LucideIcons.briefcase;
    case 'development':
    case 'tech':
      return LucideIcons.code;
    case 'design':
      return LucideIcons.pen_tool;
    case 'cloud & storage':
    case 'storage':
    case 'cloud':
      return LucideIcons.cloud;
    case 'gaming':
      return LucideIcons.gamepad_2;
    case 'health & fitness':
    case 'fitness':
      return LucideIcons.dumbbell;
    case 'utilities':
      return LucideIcons.zap;
    case 'finance':
      return LucideIcons.wallet;
    case 'education':
      return LucideIcons.graduation_cap;
    case 'news':
      return LucideIcons.newspaper;
    default:
      return null;
  }
}

