# Design Spec: Authentic Simple Icons & Official Brand Colors

## Problem & Motivation
The handmade vector SVGs previously added for brand services vary in fidelity and do not always match official brand guidelines (especially newer services like Cursor, ChatGPT, and Perplexity). Furthermore, brand glyphs in `BrandBadge` were rendered in monochrome white (`inkPrimary`), muting each brand's signature identity.

## Goal & Scope
1. Replace handcrafted local SVGs with the official `simple_icons` package (over 3,100+ authentic brand marks as native Flutter `IconData`).
2. Render brand glyphs in their **vibrant official brand colors** (e.g., Netflix `#E50914`, Spotify `#1DB954`, YouTube `#FF0000`, Discord `#5865F2`, OpenAI/ChatGPT `#10A37F`, Claude `#D97757`, Cursor `#8B5CF6`).
3. Retain high-contrast readability against dark mode backgrounds: brands with official black/monochrome logos (such as Apple, GitHub, and Notion) automatically resolve to high-contrast white (`colors.inkPrimary`).
4. Maintain visual consistency across both `BrandBadge` (catalog cards, form hero) and `BrandGlyphTile` (dashboard ledger list).
5. Clean up obsolete handcrafted SVG assets in `assets/brand/logos/`.

---

## Architectural Changes

### 1. Package Dependency (`pubspec.yaml`)
Add `simple_icons` dependency:
```yaml
dependencies:
  simple_icons: ^16.23.0
```

### 2. Brand Icon Mapping (`lib/core/brand/brand_icons.dart`)
Create an authoritative mapping table from normalized service names/keywords to `IconData`:
```dart
const brandIconTable = <String, IconData>{
  'netflix': SimpleIcons.netflix,
  'spotify': SimpleIcons.spotify,
  'disney': SimpleIcons.disneyplus,
  'youtube': SimpleIcons.youtube,
  'amazon': SimpleIcons.amazonprime,
  'prime video': SimpleIcons.amazonprime,
  'microsoft': SimpleIcons.microsoft,
  'office 365': SimpleIcons.microsoftoffice,
  'adobe': SimpleIcons.adobecreativecloud,
  'xbox': SimpleIcons.xbox,
  'game pass': SimpleIcons.xbox,
  'dropbox': SimpleIcons.dropbox,
  'canva': SimpleIcons.canva,
  'audible': SimpleIcons.audible,
  'icloud': SimpleIcons.icloud,
  'chatgpt': SimpleIcons.openai,
  'openai': SimpleIcons.openai,
  'claude': SimpleIcons.anthropic,
  'anthropic': SimpleIcons.anthropic,
  'cursor': SimpleIcons.cursor,
  'github': SimpleIcons.github,
  'copilot': SimpleIcons.githubcopilot,
  'perplexity': SimpleIcons.perplexity,
  'midjourney': SimpleIcons.midjourney,
  'apple music': SimpleIcons.applemusic,
  'apple tv': SimpleIcons.appletv,
  'apple one': SimpleIcons.apple,
  'apple': SimpleIcons.apple,
  'max': SimpleIcons.hbo,
  'hbo': SimpleIcons.hbo,
  'crunchyroll': SimpleIcons.crunchyroll,
  'twitch': SimpleIcons.twitch,
  'google one': SimpleIcons.google,
  'google drive': SimpleIcons.googledrive,
  'google': SimpleIcons.google,
  'notion': SimpleIcons.notion,
  'figma': SimpleIcons.figma,
  '1password': SimpleIcons.onepassword,
  'slack': SimpleIcons.slack,
  'playstation': SimpleIcons.playstation,
  'ps plus': SimpleIcons.playstation,
  'nintendo': SimpleIcons.nintendo,
  'discord': SimpleIcons.discord,
  'duolingo': SimpleIcons.duolingo,
  'strava': SimpleIcons.strava,
  'medium': SimpleIcons.medium,
};

IconData? brandIconFromName(String name) {
  final lowered = name.toLowerCase();
  for (final entry in brandIconTable.entries) {
    if (lowered.contains(entry.key)) return entry.value;
  }
  return null;
}
```

### 3. Official Brand Colors & Contrast Evaluation (`lib/core/brand/brand_colors.dart`)
- Verify and expand `brandColorTable` with official brand hex values for all presets.
- Add helper to resolve the effective glyph color:
```dart
Color effectiveBrandGlyphColor(Color brandColor, SublyColors colors) {
  // If the brand color is too dark (e.g. black Apple/Notion/GitHub), use inkPrimary
  if (brandColor.computeLuminance() < 0.15) {
    return colors.inkPrimary;
  }
  return brandColor;
}
```

### 4. `BrandBadge` Component Refactoring (`lib/core/brand/brand_icons.dart`)
- Accepts `IconData? icon`, `String? name`, `required Color color`, `double size = 48`, `bool showGlow = true`.
- Resolves icon: `icon ?? (name != null ? brandIconFromName(name!) : null)`.
- Resolves glyph color: `effectiveBrandGlyphColor(color, colors)`.
- Renders:
```dart
Container(
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
  child: resolvedIcon != null
      ? Icon(
          resolvedIcon,
          size: size * 0.52,
          color: glyphColor,
        )
      : (name != null && name!.isNotEmpty)
          ? Text(
              brandInitial(name!),
              style: TextStyle(
                color: glyphColor,
                fontSize: size * 0.46,
                fontWeight: FontWeight.w700,
                fontFamily: SublyTypography.displayFamily,
              ),
            )
          : null,
)
```

### 5. `BrandGlyphTile` Update (`lib/core/brand/brand_icons.dart`)
- Update `BrandGlyphTile` to accept `IconData? icon` instead of `asset`.
- Renders `Icon(icon, size: size * 0.54, color: colors.inkInverse)` when icon is found, preserving the solid brand background with knockout icon on ledger cards.

### 6. Domain & Preset Service Refactoring (`PresetService`)
- Deprecate/remove `iconAsset` string field from `PresetService`, or replace with `IconData? icon`.
- Preset services automatically resolve their icon via `brandIconFromName(name)`.

---

## Verification Plan
1. **Automated Unit & Widget Tests**:
   - `test/design/brand_icons_test.dart`: update assertions to verify `brandIconFromName` returns valid `IconData` for all preset services.
   - `test/ui/brand_badge_test.dart`: test `BrandBadge` renders `Icon` widget with official brand color when available, and verifies luminance fallback for black/dark brand colors.
   - Run full test suite (`flutter test`) ensuring all 113+ tests pass.
2. **Static Analysis**:
   - Run `flutter analyze` ensuring 0 warnings/errors.
3. **Emulator Visual Verification**:
   - Launch app on Android emulator and capture screenshots of:
     - `catalog_live.png`: displaying vibrant colored official brand icons in popular and all services.
     - `form_live.png`: displaying the official brand icon and color in the 72x72 hero badge.
