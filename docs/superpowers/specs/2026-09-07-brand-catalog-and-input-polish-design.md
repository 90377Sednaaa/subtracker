# Design Specification: Authentic Brand Badges, Popular Services Catalog, and Inset Input Polish

**Date:** 2026-09-07  
**Status:** Approved  
**Feature Branch:** `feat/add-subscription-redesign`

---

## 1. Overview & Goals

Following initial user testing on Android emulator, this specification elevates the "Add Subscription" redesign in **Subly** to match the high-polish reference designs:
1. **Authentic Brand Logos**: Replace single-letter fallbacks with authentic, official vector SVGs on circular badges with soft brand-colored radial glows.
2. **Catalog Hierarchy**: Split the catalog into a pinned **"POPULAR SERVICES"** section (ChatGPT Plus, Netflix, Spotify, YouTube Premium, Cursor, Apple One) and an **"ALL SERVICES"** section (starting with `+ Custom`, followed by 35+ top modern subscriptions).
3. **Bespoke Input Field Polish**: Replace generic Material 3 `OutlineInputBorder` boxes with sleek iOS/Fintech grouped rows inside cards, separated by hairline dividers, with right-aligned values and inline validation.

---

## 2. Architecture & Components

### 2.1 Brand Badges & Vector Asset Pipeline

#### **Assets (`assets/brand/logos/`)**
We bundle official, single-color/two-color vector SVGs for all preset services in `assets/brand/logos/`:
- `chatgpt.svg`, `claude.svg`, `cursor.svg`, `github.svg`, `perplexity.svg`, `midjourney.svg`
- `netflix.svg`, `spotify.svg`, `youtube.svg`, `disneyplus.svg`, `amazonprime.svg`, `applemusic.svg`, `appletv.svg`, `max.svg`, `crunchyroll.svg`, `twitch.svg`
- `appleone.svg`, `icloud.svg`, `googleone.svg`, `notion.svg`, `figma.svg`, `canva.svg`, `microsoft.svg`, `adobecreativecloud.svg`, `1password.svg`, `dropbox.svg`, `slack.svg`
- `xbox.svg`, `playstation.svg`, `nintendo.svg`, `discord.svg`
- `duolingo.svg`, `audible.svg`, `strava.svg`, `medium.svg`

#### **Widget: `BrandBadge` (`lib/core/brand/brand_icons.dart`)**
- **Sizing**: 48x48 in catalog grid; 72x72 in configuration hero.
- **Visuals**:
  - Circular disc container with subtle gradient / surface step and 1px hairline border.
  - Knockout / centered SVG asset sized proportionally (60% disc diameter).
  - Ambient radial aura glow matching the brand's primary color (`brandColor.withValues(alpha: 0.25)`).
  - Graceful fallback: If an asset is missing or custom service is typed, renders the lettermark initial cleanly within the circular badge.

---

### 2.2 Data Model Updates

#### **`PresetService` (`lib/features/subscriptions/domain/preset_service.dart`)**
Add `isPopular: bool` (default: `false`):
```dart
@immutable
class PresetService {
  const PresetService({
    required this.name,
    required this.category,
    required this.brandColorHex,
    this.iconAsset,
    this.isPopular = false,
  });

  final String name;
  final String category;
  final int brandColorHex;
  final String? iconAsset;
  final bool isPopular;

  bool matchesQuery(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return name.toLowerCase().contains(q) || category.toLowerCase().contains(q);
  }
}
```

#### **Catalog List (`kPresetServices`)**
35+ modern services categorized across AI, Streaming, Productivity, Gaming, and Lifestyle.
Popular services flagged with `isPopular: true`:
- `ChatGPT Plus` (`isPopular: true`)
- `Netflix` (`isPopular: true`)
- `Spotify` (`isPopular: true`)
- `YouTube Premium` (`isPopular: true`)
- `Cursor` (`isPopular: true`)
- `Apple One` (`isPopular: true`)

---

### 2.3 SubscriptionCatalogScreen Redesign

#### **Layout**
- **Top Bar**: `Cancel` text button on left, `"Add Subscription"` title centered.
- **Scrollable Body**:
  - **When search query is empty**:
    1. **"POPULAR SERVICES"** section header (`SublyTypography.label`, uppercase, muted ink).
    2. 2-column grid of popular services (ChatGPT Plus, Netflix, Spotify, YouTube Premium, Cursor, Apple One).
    3. **"ALL SERVICES"** section header (`SublyTypography.label`, uppercase, muted ink).
    4. 2-column grid starting with `+ Custom` card, followed by the remaining services sorted alphabetically.
  - **When searching**:
    - Hides section headers and renders filtered grid directly.
    - If no matches: Renders empty state with 1-tap `"Add custom subscription"` button pre-filled with query.
- **Docked Search Bar**:
  - Padded above bottom system navigation bar with clear icon (`X`).
  - Auto-dismisses keyboard on scroll (`keyboardDismissBehavior: onDrag`).

---

### 2.4 SubscriptionFormScreen Input Polish

Replace nested Material `OutlineInputBorder` fields with sleek iOS/Fintech grouped rows inside cards:

#### **Grouped Card 1 — Subscription Details**
- **Row 1 (Name)**:
  - Left: `"Name"` label (`SublyTypography.body`, `inkSecondary`).
  - Right: Borderless text input (`Key('name-field')`), text aligned right, `hintText: 'Service name'`, `hintStyle: SublyTypography.body` in `inkTertiary`.
- **Hairline Divider** (`colors.hairline`)
- **Row 2 (Schedule)**:
  - Left: `"Schedule"` label.
  - Right: Segmented cycle toggle (`weekly`, `monthly`, `annual`) retaining `Key('cycle-track')` and `Key('cycle-thumb')`.
- **Hairline Divider**
- **Row 3 (Start Date / Next Charge)**:
  - Left: `"Start date"` (or `"Next charge"`).
  - Right: Interactive rounded pill button with date formatted as `dateFormat.format(_nextCharge)` (e.g. `19 Jan 2026`) that opens calendar picker on tap.
- **Hairline Divider**
- **Row 4 (Free trial)**:
  - Left: `"Free trial"` label.
  - Right: Toggle switch (`Key('trial-switch')`).
- **Row 5 (Trial ends)** (shown if trial is active):
  - Left: `"Trial ends"` label in amber tint (`colors.statusTrial`).
  - Right: Interactive rounded pill button with expiration date.

#### **Grouped Card 2 — Amount**
- **Row 1 (Amount & Currency)**:
  - Left: `"Amount"` label (`SublyTypography.body`, `inkSecondary`).
  - Right: Row containing:
    - Currency selector pill (e.g. `USD ▾`).
    - Borderless numeric input (`Key('cost-field')`) with tabular figures typography (`SublyTypography.moneyRow`), right-aligned, inline number validation.

#### **Grouped Card 3 — Categorization & Alerts**
- **Row 1 (Category)**:
  - Left: Category icon (`LucideIcons.tag`) + `"Category"` label.
  - Right: Row with category color dot + category name with dropdown selector.
- **Hairline Divider**
- **Row 2 (Reminders)**:
  - Left: Bell icon (`LucideIcons.bell`) + `"Remind me"` label.
  - Right: Timing dropdown (e.g. `"3 day(s) before ▾"`).

#### **Grouped Card 4 — Notes**
- Header: `"Notes"` label.
- Borderless multiline text area (`Key('notes-field')`) with hint `"Add plan details, account notes..."` inside `colors.step1` container.

#### **Bottom Button**
- Full-width elevated button (`Key('save-button')`).
- Handles `LimitReachedException` $\to$ `/paywall`.

---

## 3. Backward Compatibility & Test Preservation

- All existing test keys are preserved:
  - `'name-field'`, `'cost-field'`, `'save-button'`, `'trial-switch'`, `'cycle-track'`, `'cycle-thumb'`, `'notes-field'`, `'custom-service-card'`, `'catalog-search-field'`.
- Subscriptions in Firestore remain unchanged; `category` and `notes` continue to deserialize safely.
- All 102 existing tests must pass cleanly without regressions.

---

## 4. Verification Plan

1. **Unit & Domain Tests**:
   - Verify `PresetService` has 35+ services and `isPopular` flags properly.
   - Verify `PresetService.matchesQuery` covers name and category.
2. **UI & Widget Tests**:
   - Verify `SubscriptionCatalogScreen` renders `"POPULAR SERVICES"` and `"ALL SERVICES"` headers.
   - Verify `SubscriptionFormScreen` renders all grouped rows and preserves keys and geometry.
3. **Static Analysis**:
   - `flutter analyze` with 0 issues.
4. **Live Device Verification**:
   - Build, install on emulator, and take screenshots of both updated screens to verify visual polish.
