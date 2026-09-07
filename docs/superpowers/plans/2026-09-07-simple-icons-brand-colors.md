# Authentic Simple Icons & Official Brand Colors Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace handcrafted vector SVGs with official `simple_icons` brand marks and render brand glyphs in their vibrant official brand colors with dark-mode contrast safety.

**Architecture:** Add `simple_icons: ^16.23.0` dependency. Define an authoritative `brandIconTable` and `brandIconFromName` function returning Flutter `IconData`. Enhance `BrandBadge`, `BrandGlyphTile`, and `BrandTile` to render official brand icons using their signature hex colors (e.g. Netflix Red `#E50914`, Spotify Green `#1DB954`, Discord `#5865F2`, OpenAI `#10A37F`) with luminance-based fallback to `inkPrimary` for black/dark marks (Apple, Notion, GitHub).

**Tech Stack:** Flutter 3.47, Dart 3.13, `simple_icons` 16.23.0, Flutter Riverpod 3, GoRouter.

## Global Constraints
- Android is the only maintained target.
- Monochrome design tokens from `lib/core/theme.dart`: `context.sublyColors.*`, `SublyTypography.*`, `SublyMotion.*`, `SublySpace.*`.
- Preserved test keys: `'name-field'`, `'cost-field'`, `'save-button'`, `'trial-switch'`, `'cycle-track'`, `'cycle-thumb'`, `'notes-field'`, `'custom-service-card'`, `'catalog-search-field'`, `'preset-<slug>-card'`.
- All tests must pass cleanly (`flutter test`).
- `flutter analyze` must report 0 issues.

---

### Task 1: Add `simple_icons` & Create Authoritative Brand Icon Mapping Table

**Files:**
- Modify: `pubspec.yaml`
- Modify: `lib/core/brand/brand_icons.dart`
- Modify: `lib/core/brand/brand_colors.dart`
- Modify: `test/design/brand_icons_test.dart`

**Interfaces:**
- Produces: `IconData? brandIconFromName(String name)`
- Produces: `const Map<String, IconData> brandIconTable`
- Produces: `Color effectiveBrandGlyphColor(Color brandColor, SublyColors colors)`

- [ ] **Step 1: Write the failing tests in `test/design/brand_icons_test.dart`**
  Add tests asserting that `brandIconFromName`:
  - Returns non-null `IconData` for all directory services (Netflix, Spotify, Disney+, YouTube, Amazon Prime, Microsoft, Adobe, Xbox, Dropbox, Canva, Audible, iCloud).
  - Returns non-null `IconData` for modern services (ChatGPT Plus, Claude Pro, Cursor, Perplexity, Midjourney, Notion, Figma, 1Password, Slack, PlayStation, Nintendo, Discord, Duolingo, Strava, Medium).
  - Assert that `effectiveBrandGlyphColor` returns `colors.inkPrimary` for black colors (luminance < 0.15) and brand color for vibrant colors.

- [ ] **Step 2: Run tests to confirm failure**
  ```bash
  flutter test test/design/brand_icons_test.dart
  ```

- [ ] **Step 3: Implement `brandIconTable`, `brandIconFromName`, and `effectiveBrandGlyphColor`**
  - In `lib/core/brand/brand_icons.dart`, import `package:simple_icons/simple_icons.dart` and define `brandIconTable` mapping all 35+ brands to `SimpleIcons.*`.
  - In `lib/core/brand/brand_colors.dart`, add `effectiveBrandGlyphColor(Color brandColor, SublyColors colors)`.

- [ ] **Step 4: Run tests to confirm passing**
  ```bash
  flutter test test/design/brand_icons_test.dart
  ```

- [ ] **Step 5: Commit changes**
  ```bash
  git add pubspec.yaml pubspec.lock lib/core/brand/brand_icons.dart lib/core/brand/brand_colors.dart test/design/brand_icons_test.dart
  git commit -m "feat(brand): add simple_icons and authoritative brandIconTable with contrast resolver"
  ```

---

### Task 2: Refactor `BrandBadge` with Official Brand Colors & Contrast Fallback

**Files:**
- Modify: `lib/core/brand/brand_icons.dart`
- Modify: `test/ui/brand_badge_test.dart`

**Interfaces:**
- Consumes: `brandIconFromName`, `effectiveBrandGlyphColor`, `SublyColors`
- Produces: `BrandBadge({IconData? icon, String? asset, String? name, required Color color, double size, bool showGlow})`

- [ ] **Step 1: Update tests in `test/ui/brand_badge_test.dart`**
  - Add test: `BrandBadge` renders `Icon` widget with `color: brandColor` for vibrant services (e.g. Netflix, Spotify, Discord).
  - Add test: `BrandBadge` renders `Icon` widget with `color: colors.inkPrimary` for dark services (e.g. Apple).
  - Add test: `BrandBadge` retains circular decoration and radial glow matching `color.withValues(alpha: 0.35)`.

- [ ] **Step 2: Run tests to confirm failure**
  ```bash
  flutter test test/ui/brand_badge_test.dart
  ```

- [ ] **Step 3: Refactor `BrandBadge`**
  - Update `BrandBadge.build` to resolve `icon ?? (name != null ? brandIconFromName(name!) : null)`.
  - If resolved icon is present, render `Icon(resolvedIcon, size: size * 0.52, color: glyphColor)`.
  - If no icon is present and `asset != null`, render `SvgPicture.asset`.
  - Fall back to `brandInitial(name)` styled with `glyphColor`.

- [ ] **Step 4: Run tests to confirm passing**
  ```bash
  flutter test test/ui/brand_badge_test.dart
  ```

- [ ] **Step 5: Commit changes**
  ```bash
  git add lib/core/brand/brand_icons.dart test/ui/brand_badge_test.dart
  git commit -m "feat(ui): render official brand colors in BrandBadge with contrast safety"
  ```

---

### Task 3: Refactor `BrandTile` and `BrandGlyphTile` to Use `simple_icons`

**Files:**
- Modify: `lib/core/brand/brand.dart`
- Modify: `lib/core/brand/brand_icons.dart`
- Modify: `test/design/brand_icons_test.dart`

**Interfaces:**
- Consumes: `brandIconFromName`, `SublyColors`
- Modifies: `BrandTile`, `BrandGlyphTile`

- [ ] **Step 1: Update tests in `test/design/brand_icons_test.dart`**
  - Assert `BrandGlyphTile` and `BrandTile` render an `Icon` widget when an official brand matches.

- [ ] **Step 2: Run tests to confirm failure**
  ```bash
  flutter test test/design/brand_icons_test.dart
  ```

- [ ] **Step 3: Refactor `BrandTile` and `BrandGlyphTile`**
  - In `BrandTile`, resolve `final icon = brandIconFromName(name)`. If non-null, render `Icon(icon, size: size * 0.68, color: colors.inkInverse)`.
  - In `BrandGlyphTile`, support `IconData? icon` resolved from `name`, rendering `Icon(icon, size: size * 0.54, color: colors.inkInverse)`.

- [ ] **Step 4: Run tests to confirm passing**
  ```bash
  flutter test test/design/brand_icons_test.dart
  ```

- [ ] **Step 5: Commit changes**
  ```bash
  git add lib/core/brand/brand.dart lib/core/brand/brand_icons.dart test/design/brand_icons_test.dart
  git commit -m "feat(brand): render authentic SimpleIcons in BrandTile and BrandGlyphTile"
  ```

---

### Task 4: Connect Screens and Verify Full Test Suite

**Files:**
- Modify: `lib/features/subscriptions/ui/subscription_catalog_screen.dart`
- Modify: `lib/features/subscriptions/ui/subscription_form_screen.dart`
- Test: Full test suite

- [ ] **Step 1: Verify `BrandBadge` invocations in `subscription_catalog_screen.dart` and `subscription_form_screen.dart`**
  - Ensure `name` and `color` are passed to `BrandBadge` so the official `SimpleIcons` glyph and official color resolve automatically.
  - Test real-time typing in `subscription_form_screen`: as the user types "Spotify", the 72x72 hero badge instantly turns into the green Spotify logo with green glow.

- [ ] **Step 2: Run `flutter analyze`**
  ```bash
  flutter analyze
  ```

- [ ] **Step 3: Run the entire test suite**
  ```bash
  flutter test
  ```

- [ ] **Step 4: Commit changes**
  ```bash
  git add lib/features/subscriptions/ui/subscription_catalog_screen.dart lib/features/subscriptions/ui/subscription_form_screen.dart
  git commit -m "feat(ui): connect live brand icon and color resolution in catalog and form screens"
  ```

---

### Task 5: Live Android Verification & Screenshot Capture

**Files:**
- Update: `walkthrough.md`
- Artifacts: `catalog_live.png`, `form_live.png`

- [ ] **Step 1: Run the app on the Android emulator**
  ```bash
  flutter run -d emulator-5554
  ```

- [ ] **Step 2: Capture live screenshots of the catalog and form screens**
  - `adb shell screencap -p /sdcard/catalog_live.png`
  - `adb pull /sdcard/catalog_live.png`
  - `adb shell screencap -p /sdcard/form_live.png`
  - `adb pull /sdcard/form_live.png`

- [ ] **Step 3: Update `walkthrough.md` with the new screenshots and visual comparison**
