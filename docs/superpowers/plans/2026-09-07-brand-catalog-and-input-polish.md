# Authentic Brand Badges, Popular Services Catalog, and Inset Input Polish Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Elevate the Subly Add/Edit Subscription flow to match high-fidelity reference designs with authentic circular brand vector badges, an expanded 35+ preset services catalog split into "POPULAR SERVICES" and "ALL SERVICES", and bespoke iOS/Fintech grouped input rows replacing generic Material outline fields.

**Architecture:**
- Expand `assets/brand/logos/` with official, crisp vector SVGs for all presets.
- Enhance `PresetService` domain model with `isPopular: bool` and expand `kPresetServices` to 35+ top modern subscriptions across AI, Streaming, Dev, Productivity, Gaming, and Lifestyle.
- Implement `BrandBadge` in `lib/core/brand/brand_icons.dart` delivering a circular disc with subtle rim, centered vector glyph, and soft brand-tinted radial glow.
- Refactor `SubscriptionCatalogScreen` to display pinned "POPULAR SERVICES" (ChatGPT Plus, Netflix, Spotify, YouTube Premium, Cursor, Apple One) and "ALL SERVICES" (starting with `+ Custom`).
- Redesign `SubscriptionFormScreen` grouped cards with borderless right-aligned inputs, date pills, category dot rows, and tabular figure cost inputs, preserving all existing test keys (`name-field`, `cost-field`, `save-button`, `trial-switch`, `cycle-track`, `cycle-thumb`, `notes-field`).

**Tech Stack:**
- Flutter 3.47+ / Dart 3.13+
- `flutter_riverpod: ^3.4.3`
- `flutter_svg: ^2.3.0`
- `flutter_lucide: ^1.41.0`
- Subly custom design tokens (`SublyColors`, `SublyTypography`, `SublySpace`, `SublyMotion`)

## Global Constraints
- Android is the only maintained target.
- Monochrome design tokens from `lib/core/theme.dart` (`context.sublyColors.*`, `SublyTypography.*`, `SublySpace.*`).
- Color appears only as brand accents / dots / aura glows (`brandColorHex`).
- All existing test keys (`name-field`, `cost-field`, `save-button`, `trial-switch`, `cycle-track`, `cycle-thumb`, `notes-field`, `custom-service-card`, `catalog-search-field`) MUST be preserved.
- No FCM, no Cloud Functions, no paid Firebase plan.
- All 102 existing tests must remain 100% green; `flutter analyze` must remain 0 issues.

---

### Task 1: Add Vector SVG Assets & Expand `PresetService` Domain Model

**Files:**
- Create:
  - `assets/brand/logos/chatgpt.svg`
  - `assets/brand/logos/claude.svg`
  - `assets/brand/logos/cursor.svg`
  - `assets/brand/logos/github.svg`
  - `assets/brand/logos/perplexity.svg`
  - `assets/brand/logos/midjourney.svg`
  - `assets/brand/logos/applemusic.svg`
  - `assets/brand/logos/appletv.svg`
  - `assets/brand/logos/appleone.svg`
  - `assets/brand/logos/max.svg`
  - `assets/brand/logos/crunchyroll.svg`
  - `assets/brand/logos/twitch.svg`
  - `assets/brand/logos/googleone.svg`
  - `assets/brand/logos/notion.svg`
  - `assets/brand/logos/figma.svg`
  - `assets/brand/logos/1password.svg`
  - `assets/brand/logos/slack.svg`
  - `assets/brand/logos/playstation.svg`
  - `assets/brand/logos/nintendo.svg`
  - `assets/brand/logos/discord.svg`
  - `assets/brand/logos/duolingo.svg`
  - `assets/brand/logos/strava.svg`
  - `assets/brand/logos/medium.svg`
- Modify: `lib/features/subscriptions/domain/preset_service.dart`
- Test: `test/domain/preset_service_test.dart`

**Interfaces:**
- Produces:
  - `PresetService.isPopular: bool` (defaults to `false`)
  - `kPresetServices`: List of 35+ `PresetService` objects with valid hex colors and non-null `iconAsset` paths.
  - `kPopularPresetServices`: Filtered getter or list of popular services.

- [ ] **Step 1: Write the failing unit tests**

```dart
// test/domain/preset_service_test.dart
test('kPresetServices contains 35+ services and popular presets flagged', () {
  expect(kPresetServices.length, greaterThanOrEqualTo(35));
  final popular = kPresetServices.where((s) => s.isPopular).toList();
  expect(popular.length, greaterThanOrEqualTo(6));
  expect(popular.any((s) => s.name == 'ChatGPT Plus'), isTrue);
  expect(popular.any((s) => s.name == 'Netflix'), isTrue);
  expect(popular.any((s) => s.name == 'Spotify'), isTrue);
  expect(popular.any((s) => s.name == 'Cursor'), isTrue);
  expect(popular.any((s) => s.name == 'Apple One'), isTrue);
  expect(popular.any((s) => s.name == 'YouTube Premium'), isTrue);
});

test('all presets have non-null iconAsset and non-empty categories', () {
  for (final preset in kPresetServices) {
    expect(preset.iconAsset, isNotNull, reason: '${preset.name} missing iconAsset');
    expect(preset.iconAsset!.endsWith('.svg'), isTrue);
    expect(preset.category, isNotEmpty);
  }
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/domain/preset_service_test.dart`  
Expected: FAIL (less than 35 services, `isPopular` not defined, null iconAssets).

- [ ] **Step 3: Add the missing SVG assets and update `PresetService`**

Write standard, clean Simple Icons SVG paths to `assets/brand/logos/*.svg` and update `PresetService` and `kPresetServices` in `lib/features/subscriptions/domain/preset_service.dart`.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/domain/preset_service_test.dart`  
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add assets/brand/logos/ lib/features/subscriptions/domain/preset_service.dart test/domain/preset_service_test.dart
git commit -m "feat(domain): add authentic vector SVGs and expand preset services catalog to 35+ items"
```

---

### Task 2: Implement `BrandBadge` Component & Expand Asset Table

**Files:**
- Modify: `lib/core/brand/brand_icons.dart`
- Create: `test/ui/brand_badge_test.dart`

**Interfaces:**
- Produces:
  - `BrandBadge`: Widget rendering a circular disc badge with centered SVG vector, subtle border, and brand-color radial aura glow.
  - `brandIconAssetTable`: Expanded with all new services keywords (chatgpt, claude, cursor, perplexity, github, etc.).

- [ ] **Step 1: Write the failing widget test**

```dart
// test/ui/brand_badge_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subtracker/core/brand/brand_icons.dart';
import 'package:subtracker/core/theme.dart';

void main() {
  testWidgets('BrandBadge renders circular disc with asset and glow', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildSublyTheme(Brightness.dark),
        home: const Scaffold(
          body: BrandBadge(
            name: 'Netflix',
            asset: 'assets/brand/logos/netflix.svg',
            color: Color(0xFFE50914),
            size: 48,
          ),
        ),
      ),
    );
    expect(find.byType(BrandBadge), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/ui/brand_badge_test.dart`  
Expected: FAIL (`BrandBadge` not defined).

- [ ] **Step 3: Implement `BrandBadge` and update `brandIconAssetTable`**

In `lib/core/brand/brand_icons.dart`:
- Implement `BrandBadge` with circular disc decoration, radial glow (`boxShadow`), and centered `SvgPicture.asset`.
- Add entries for all 35+ services to `brandIconAssetTable`.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/ui/brand_badge_test.dart`  
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/core/brand/brand_icons.dart test/ui/brand_badge_test.dart
git commit -m "feat(ui): implement BrandBadge component with radial aura glow and circular disc"
```

---

### Task 3: Refactor `SubscriptionCatalogScreen` with Popular & All Services

**Files:**
- Modify: `lib/features/subscriptions/ui/subscription_catalog_screen.dart`
- Modify: `test/ui/subscription_catalog_screen_test.dart`

**Interfaces:**
- Consumes: `kPresetServices`, `BrandBadge`
- Produces: `SubscriptionCatalogScreen` with pinned "POPULAR SERVICES", "ALL SERVICES" starting with `+ Custom`, and docked search bar.

- [ ] **Step 1: Update widget tests for the new sections**

In `test/ui/subscription_catalog_screen_test.dart`:
- Assert `"POPULAR SERVICES"` text is present.
- Assert `"ALL SERVICES"` text is present.
- Assert popular presets (e.g. `'preset-netflix-card'`, `'preset-chatgpt-plus-card'`) render in popular section.
- Assert `Key('custom-service-card')` renders at the top of All Services.
- Assert searching hides section headers and filters properly.

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/ui/subscription_catalog_screen_test.dart`  
Expected: FAIL (missing section headers).

- [ ] **Step 3: Implement Popular & All Services sections**

In `lib/features/subscriptions/ui/subscription_catalog_screen.dart`:
- Partition `kPresetServices` into `popular` (`s.isPopular`) and `all` (all services sorted alphabetically).
- Build the scroll view:
  - If query is empty:
    1. Header: `"POPULAR SERVICES"`
    2. Grid: 2-column grid of popular services with `BrandBadge`.
    3. Header: `"ALL SERVICES"`
    4. Grid: 2-column grid starting with `+ Custom` tile, followed by all remaining services.
  - If query is not empty:
    - Renders filtered grid directly with `BrandBadge` and empty state fallback.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/ui/subscription_catalog_screen_test.dart`  
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/subscriptions/ui/subscription_catalog_screen.dart test/ui/subscription_catalog_screen_test.dart
git commit -m "feat(ui): add Popular Services and All Services sections to catalog screen"
```

---

### Task 4: Polish `SubscriptionFormScreen` with Inset Grouped Rows

**Files:**
- Modify: `lib/features/subscriptions/ui/subscription_form_screen.dart`
- Modify: `test/ui/subscription_form_screen_test.dart`

**Interfaces:**
- Consumes: `BrandBadge`, Subly theme tokens.
- Produces: `SubscriptionFormScreen` with iOS/Fintech grouped rows, removing all nested Material `OutlineInputBorder` boxes.

- [ ] **Step 1: Update form tests to assert new grouped row structure**

In `test/ui/subscription_form_screen_test.dart`:
- Verify all existing keys (`'name-field'`, `'cost-field'`, `'save-button'`, `'trial-switch'`, `'cycle-track'`, `'cycle-thumb'`, `'notes-field'`) exist and work as expected.
- Verify cost validation still works.
- Verify date picking works.
- Verify `Hero` tag and brand badge render with brand color radial aura glow.

- [ ] **Step 2: Run test to verify existing tests**

Run: `flutter test test/ui/subscription_form_screen_test.dart`

- [ ] **Step 3: Redesign form fields to grouped row cells**

In `lib/features/subscriptions/ui/subscription_form_screen.dart`:
- **Hero**: Replace avatar container with `BrandBadge(size: 72, name: _name.text, asset: _activeBrandIconAsset, color: _activeBrandColor)`.
- **Details Card**:
  - Row 1: Left `"Name"`, Right borderless text field (`Key('name-field')`) with `textAlign: TextAlign.end` and `InputDecoration.collapsed(hintText: 'Service name')`.
  - Divider: `Divider(height: 1, color: colors.hairline)`
  - Row 2: Left `"Schedule"`, Right `_SegmentedCycle(value: _cycle, onChanged: ...)`
  - Divider
  - Row 3: Left `"Start date"` (or `"Next charge"`), Right date pill button (`dateFormat.format(_nextCharge)`)
  - Divider
  - Row 4: Left `"Free trial"`, Right `Switch` (`Key('trial-switch')`)
  - Optional Row 5: Left `"Trial ends"`, Right date pill button.
- **Amount Card**:
  - Left `"Amount"`, Right row containing currency dropdown pill (`USD ▾`) and borderless numeric input (`Key('cost-field')`, `textAlign: TextAlign.end`, `style: SublyTypography.moneyRow`).
- **Categorization Card**:
  - Row 1: Left `Icon(LucideIcons.tag)` + `"Category"`, Right category dot + category name with clean selector dropdown.
  - Divider
  - Row 2: Left `Icon(LucideIcons.bell)` + `"Remind me"`, Right reminder timing selector.
- **Notes Card**:
  - Left label `"Notes"`, below it borderless multiline text area (`Key('notes-field')`) inside card.
- **Save Button**: Full-width elevated button (`Key('save-button')`).

- [ ] **Step 4: Run test suite**

Run: `flutter test test/ui/subscription_form_screen_test.dart`  
Run: `flutter test test/ui/ledger_card_test.dart`  
Expected: All tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/subscriptions/ui/subscription_form_screen.dart test/ui/subscription_form_screen_test.dart
git commit -m "feat(ui): redesign configuration form fields into bespoke inset grouped rows"
```

---

### Task 5: End-to-End Test Suite Verification & Emulator Capture

**Files:**
- Run all tests across the entire project.
- Take live emulator screenshots.

- [ ] **Step 1: Run flutter analyze**

Run: `flutter analyze`  
Expected: 0 issues.

- [ ] **Step 2: Run full flutter test suite**

Run: `flutter test`  
Expected: All tests pass.

- [ ] **Step 3: Rebuild and deploy to Android emulator**

Run: `flutter run -d emulator-5554` (or install apk) and capture screenshots:
- `catalog_live.png`: Showing Popular Services, All Services, and Authentic Brand Badges.
- `form_live.png`: Showing polished inset grouped rows, BrandBadge with aura glow.

- [ ] **Step 4: Update walkthrough artifact and present results to user**
