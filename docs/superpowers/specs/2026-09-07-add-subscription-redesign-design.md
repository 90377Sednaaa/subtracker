# Add Subscription Flow Redesign Spec

**Date:** 2026-09-07  
**Status:** Approved  
**Target:** Android (Subly Subscription Tracker)

---

## 1. Overview & Goals

The goal of this redesign is to provide a modern, visually compelling two-step flow for adding and configuring subscriptions in Subly, inspired by reference designs:

1. **Step 1 — Brand Catalog Screen (`SubscriptionCatalogScreen`)**: A visual brand catalog where users choose what subscription service they want to manage from a 2-column grid of clickable brand logos, search across services, or tap a persistent **"+ Custom"** button.
2. **Step 2 — Configuration Screen (`SubscriptionFormScreen`)**: A refined, grouped-card configuration form displaying a prominent centered brand emblem with radial glow, clean card groups for details (Name, Billing Schedule, Start/Charge Date, Free Trial), amount & currency, category & notifications, and notes.
3. **Edit Flow (`/subs/:id/edit`)**: Directly opens the Configuration Screen pre-populated with the existing subscription's values.

---

## 2. Visual & Token Specifications

All UI elements adhere strictly to `lib/core/theme.dart`:

- **Surfaces & Cards**:
  - Catalog cards & Form group sections use `context.sublyColors.step1` surface with `context.sublyColors.hairline` borders and `SublySpace.radiusCard` (16dp).
  - Background is `context.sublyColors.base` (`#0A0A0C` in dark mode).
- **Emblem & Glow**:
  - Hero emblem on the configuration screen is centered at 80x80dp with a soft radial aura behind it matching the service's `brandColor` at 20% opacity.
- **Typography**:
  - Headings: `SublyTypography.titleM` and `titleL` (`SpaceGrotesk`).
  - Money & numbers: `SublyTypography.moneyRow` (`tabularFigures`).
  - Labels & Body: `SublyTypography.label` and `body` (`InterSubly`).
- **Icons**:
  - `flutter_lucide` icons (`LucideIcons.search`, `LucideIcons.plus`, `LucideIcons.chevron_left`, `LucideIcons.calendar`, `LucideIcons.bell`, `LucideIcons.tag`).

---

## 3. Data Model & Firestore Changes

### `Subscription` & `SubscriptionDraft`
Both domain models will be extended with two optional/defaulted fields:

```dart
// lib/features/subscriptions/domain/subscription.dart
class Subscription {
  // Existing fields...
  final String category; // e.g. 'Entertainment', 'Music', 'Utilities', etc.
  final String notes;    // Optional multiline notes

  static Subscription fromMap(String id, Map<String, dynamic> map) {
    return Subscription(
      // ...
      category: map['category'] as String? ?? 'Other',
      notes: map['notes'] as String? ?? '',
    );
  }
}

// lib/features/subscriptions/domain/subscription_draft.dart
class SubscriptionDraft {
  // Existing fields...
  final String category;
  final String notes;
}
```

### Firestore Document Schema
Saved under `users/{uid}/subscriptions/{subId}`:
- `name`: string
- `cost`: number
- `currency`: string
- `billingCycle`: string ('weekly' | 'monthly' | 'annual')
- `nextChargeDate`: timestamp
- `trialEndsAt`: timestamp | null
- `reminderDaysBefore`: number (1, 3, 5, 7)
- `category`: string (defaults to 'Other')
- `notes`: string (defaults to '')
- `brandColor`: string | null (hex string like '1DB954')
- `active`: boolean
- `createdAt`: timestamp

*Backwards compatibility*: Any existing subscription document without `category` or `notes` defaults safely to `'Other'` and `''`.

---

## 4. Preset Services Catalog (`preset_services.dart`)

A curated list of preset services in `lib/features/subscriptions/domain/preset_services.dart`:

```dart
class PresetService {
  const PresetService({
    required this.name,
    required this.category,
    required this.brandColorHex,
    this.iconAsset,
  });

  final String name;
  final String category;
  final int brandColorHex;
  final String? iconAsset;
}
```

Included presets (20+ services):
- **Entertainment/Streaming**: Netflix, Disney+, Amazon Prime, YouTube Premium, Apple TV+, Paramount+, Crunchyroll.
- **Music**: Spotify, Apple Music, Amazon Music, YouTube Music.
- **Productivity & Cloud**: ChatGPT, GitHub, Notion, Figma, Dropbox, Canva, Microsoft 365, iCloud, 1Password.
- **Gaming & Books**: Xbox Game Pass, PlayStation Plus, Audible, Discord Nitro.
- **Utilities / Other**: Cursor, Adobe Creative Cloud, Duolingo.

Each preset maps to an existing SVG logo from `assets/brand/logos/` when available, or renders a circular brand tile with the service initial.

---

## 5. Screen 1: Brand Catalog Screen (`SubscriptionCatalogScreen`)

**Route:** `/subs/new`  
**File:** `lib/features/subscriptions/ui/subscription_catalog_screen.dart`

### Layout Structure:
1. **Top Header**:
   - `TextButton('Cancel')` on top-left (calls `context.pop()`).
   - Center Title: `"Add Subscription"` (`SublyTypography.titleM`).
2. **Category / Section Header**:
   - `"ALL SERVICES"` in uppercase `SublyTypography.label` with `inkTertiary`.
3. **2-Column Grid**:
   - Scrollable `GridView.builder` with 2 columns, aspect ratio ~1.15, spacing 12dp.
   - **Tile 1 (Persistent Custom Button)**:
     - Elevated card (`step1` surface).
     - Circular dashed/accent border with `LucideIcons.plus`.
     - Label: `"Custom"`.
     - Tapping opens the configuration form with empty fields.
   - **Preset Tiles**:
     - Circular brand avatar with subtle back-glow (`BrandGlyphTile` or circular avatar).
     - Service name in `SublyTypography.label`.
     - Tapping opens the configuration form pre-filled with the preset's name, brand color, and category.
4. **Bottom Search Bar**:
   - Docked above system navigation bar.
   - Search pill with `LucideIcons.search` and hint `"Search services"`.
   - Live filtering by service name.
   - When no services match: displays an empty state prompt with a direct button: `"Can't find it? Add custom subscription"`.

---

## 6. Screen 2: Configuration Screen (`SubscriptionFormScreen`)

**Route:** `/subs/new/config` (or pushed directly) and `/subs/:id/edit`  
**File:** `lib/features/subscriptions/ui/subscription_form_screen.dart`

### Layout Structure:
1. **App Bar**:
   - Back button (`<`) on the left.
   - Title: `"New Subscription"` (or `"Edit Subscription"` / subscription name in edit mode).
2. **Hero Brand Emblem**:
   - Centered circular brand icon (72x72dp) with a radial glow (`RadialGradient`) tinted with the subscription's `brandColor`.
3. **Grouped Card 1 — Core Details** (`step1` card, `radiusCard: 16`):
   - **Name**: Text field with floating label `"Service name"`.
   - **Schedule**: `_SegmentedCycle` selector (`Weekly`, `Monthly`, `Annual`) with animated sliding thumb.
   - **Start Date / Next Charge**: Tappable row displaying formatted date (`dd MMM yyyy`, e.g. `19 Jan 2026`) with calendar icon, opening standard date picker.
   - **Free Trial**: Switch tile (`"Free trial"`). When toggled on, exposes the `"Trial ends"` date picker row.
4. **Grouped Card 2 — Amount** (`step1` card, `radiusCard: 16`):
   - Row with large tabular cost text field and currency dropdown selector (`USD`, `EUR`, `GBP`, `PHP`, `JPY`).
5. **Grouped Card 3 — Category & Notifications** (`step1` card, `radiusCard: 16`):
   - **Category Dropdown**: Selector with colored category dot indicator (Entertainment, Music, Productivity, Utilities, Gaming, Books, Storage, Shopping, Other).
   - **Notifications / Reminders**: Dropdown for reminder days (1, 3, 5, 7 days before).
6. **Grouped Card 4 — Notes** (`step1` card, `radiusCard: 16`):
   - Multiline text field with hint `"Add notes, account email, or plan details"`.
7. **Bottom Action Button**:
   - Full-width rounded primary button: `"Add Subscription"` (or `"Save Changes"`).
   - Validates form.
   - Saves via `SubscriptionRepository.add` or `.update`.
   - Handles `LimitReachedException` by navigating to `/paywall`.

---

## 7. Routing Integration (`router.dart`)

- `/subs/new`: `SubscriptionCatalogScreen`
- `/subs/new/config`: `SubscriptionFormScreen` (accepts extra `PresetService?` or `SubscriptionDraft?`)
- `/subs/:id/edit`: `SubscriptionFormScreen(existingId: state.pathParameters['id'])`

---

## 8. Verification & Testing Strategy

1. **Domain Tests**:
   - `test/domain/subscription_test.dart`: Serialization/deserialization of `category` and `notes`.
   - `test/domain/preset_services_test.dart`: Preset catalog validation (all presets have valid names, categories, and colors).
2. **Widget Tests**:
   - `test/ui/subscription_catalog_screen_test.dart`:
     - Renders grid and custom button.
     - Search filter correctly filters preset services.
     - Tapping a preset navigates to configuration form with pre-filled details.
     - Tapping "+ Custom" opens empty configuration form.
   - `test/ui/subscription_form_screen_test.dart`:
     - Preloads existing subscription in edit mode.
     - Renders all grouped card sections (Details, Amount, Category/Notifications, Notes).
     - Validates name and cost.
     - Enforces 5-subscription limit on free tier.
3. **Regression Tests**:
   - Run `flutter test` across all 79+ tests to ensure 100% pass rate.
   - Run `flutter analyze` to ensure zero warnings or errors.
