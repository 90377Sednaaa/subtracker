# Add Subscription Flow Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Redesign the Add/Edit Subscription user journey into a modern two-screen flow featuring a clickable Brand Catalog grid with search and a "+ Custom" option, transitioning into a grouped-card configuration form with a centered brand emblem, glow, category selection, and notes.

**Architecture:** A two-step route flow (`/subs/new` -> `SubscriptionCatalogScreen`, `/subs/new/config` or `/subs/:id/edit` -> `SubscriptionFormScreen`) backed by a curated `PresetService` catalog and extended `Subscription` / `SubscriptionDraft` domain models carrying `category` and `notes`. The form preserves Subly design tokens, geometry keys, and free-tier limits.

**Tech Stack:** Flutter 3.47+, Riverpod 3 (`Provider`, `ConsumerStatefulWidget`), GoRouter, `fake_cloud_firestore`, `flutter_lucide`, `intl`.

## Global Constraints

- Android is the only maintained target.
- Monochrome design tokens from `lib/core/theme.dart`: `context.sublyColors.*`, `SublyTypography.*`, `SublyMotion.*`, `SublySpace.*`.
- Brand accent color appears only on brand emblems/dots and glowing highlights (`brandColorFor` / preset brand color).
- Icons use `flutter_lucide` with snake_case names (`LucideIcons.search`, `LucideIcons.plus`, `LucideIcons.arrow_left`, `LucideIcons.calendar`, etc.).
- Free tier limit = 5 active subscriptions, enforced in `SubscriptionRepository.add` throwing `LimitReachedException` which pushes `/paywall`.
- Preserved test keys: `'name-field'`, `'cost-field'`, `'save-button'`, `'trial-switch'`, `'cycle-track'`, `'cycle-thumb'`.
- All tests must follow strict TDD: failing test -> confirm fail -> implement -> confirm pass -> commit.

---

### Task 1: Extend `Subscription` & `SubscriptionDraft` Domain Models with `category` and `notes`

**Files:**
- Modify: `lib/features/subscriptions/domain/subscription.dart`
- Modify: `lib/features/subscriptions/domain/subscription_draft.dart`
- Modify: `lib/features/subscriptions/data/subscription_repository.dart`
- Test: `test/domain/subscription_model_test.dart`

**Interfaces:**
- Consumes: Existing `Subscription`, `SubscriptionDraft`, `SubscriptionRepository`
- Produces:
  - `Subscription.category` (`String`, default `'Other'`)
  - `Subscription.notes` (`String`, default `''`)
  - `SubscriptionDraft.category` (`String`, default `'Other'`)
  - `SubscriptionDraft.notes` (`String`, default `''`)

- [ ] **Step 1: Write the failing test**

Create `test/domain/subscription_model_test.dart`:
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subtracker/features/subscriptions/domain/billing_cycle.dart';
import 'package:subtracker/features/subscriptions/domain/subscription.dart';
import 'package:subtracker/features/subscriptions/domain/subscription_draft.dart';

void main() {
  test('SubscriptionDraft supports category and notes with defaults', () {
    final draft = SubscriptionDraft(
      name: 'Netflix',
      cost: 15.49,
      currency: 'USD',
      billingCycle: BillingCycle.monthly,
      nextChargeDate: DateTime(2026, 10, 1),
      trialEndsAt: null,
      reminderDaysBefore: 3,
    );
    expect(draft.category, 'Other');
    expect(draft.notes, '');

    final customDraft = SubscriptionDraft(
      name: 'Cursor',
      cost: 20.0,
      currency: 'USD',
      billingCycle: BillingCycle.monthly,
      nextChargeDate: DateTime(2026, 10, 1),
      trialEndsAt: null,
      reminderDaysBefore: 3,
      category: 'Utilities',
      notes: 'Work account',
    );
    expect(customDraft.category, 'Utilities');
    expect(customDraft.notes, 'Work account');
  });

  test('Subscription.fromMap deserializes category and notes safely with defaults', () {
    final mapWithoutExtras = {
      'name': 'Spotify',
      'cost': 11.99,
      'currency': 'EUR',
      'billingCycle': 'monthly',
      'nextChargeDate': Timestamp.fromDate(DateTime(2026, 10, 1)),
      'trialEndsAt': null,
      'reminderDaysBefore': 3,
      'active': true,
    };
    final sub1 = Subscription.fromMap('sub1', mapWithoutExtras);
    expect(sub1.category, 'Other');
    expect(sub1.notes, '');

    final mapWithExtras = {
      ...mapWithoutExtras,
      'category': 'Music',
      'notes': 'Family plan',
    };
    final sub2 = Subscription.fromMap('sub2', mapWithExtras);
    expect(sub2.category, 'Music');
    expect(sub2.notes, 'Family plan');
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/domain/subscription_model_test.dart`  
Expected: FAIL compilation/field errors (`category` and `notes` undefined).

- [ ] **Step 3: Write minimal implementation**

In `lib/features/subscriptions/domain/subscription.dart`:
```dart
class Subscription {
  const Subscription({
    required this.id,
    required this.name,
    required this.cost,
    required this.currency,
    required this.billingCycle,
    required this.nextChargeDate,
    required this.trialEndsAt,
    required this.reminderDaysBefore,
    required this.active,
    required this.createdAt,
    this.brandColor,
    this.category = 'Other',
    this.notes = '',
  });

  // existing fields...
  final String category;
  final String notes;

  static Subscription fromMap(String id, Map<String, dynamic> map) {
    return Subscription(
      id: id,
      name: map['name'] as String,
      cost: (map['cost'] as num).toDouble(),
      currency: map['currency'] as String,
      billingCycle: parseBillingCycle(map['billingCycle'] as String),
      nextChargeDate: (map['nextChargeDate'] as Timestamp).toDate(),
      trialEndsAt: map['trialEndsAt'] == null
          ? null
          : (map['trialEndsAt'] as Timestamp).toDate(),
      reminderDaysBefore: (map['reminderDaysBefore'] as num?)?.toInt() ?? 3,
      active: map['active'] as bool? ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      brandColor: map['brandColor'] as String?,
      category: map['category'] as String? ?? 'Other',
      notes: map['notes'] as String? ?? '',
    );
  }
}
```

In `lib/features/subscriptions/domain/subscription_draft.dart`:
```dart
class SubscriptionDraft {
  const SubscriptionDraft({
    required this.name,
    required this.cost,
    required this.currency,
    required this.billingCycle,
    required this.nextChargeDate,
    required this.trialEndsAt,
    required this.reminderDaysBefore,
    this.category = 'Other',
    this.notes = '',
    this.brandColor,
  });

  final String name;
  final double cost;
  final String currency;
  final BillingCycle billingCycle;
  final DateTime nextChargeDate;
  final DateTime? trialEndsAt;
  final int reminderDaysBefore;
  final String category;
  final String notes;
  final String? brandColor;
}
```

In `lib/features/subscriptions/data/subscription_repository.dart` (`_mapFor`):
```dart
  Map<String, dynamic> _mapFor(SubscriptionDraft d) => {
        'name': d.name,
        'cost': d.cost,
        'currency': d.currency,
        'billingCycle': d.billingCycle.name,
        'nextChargeDate': Timestamp.fromDate(d.nextChargeDate),
        'trialEndsAt': d.trialEndsAt == null
            ? null
            : Timestamp.fromDate(d.trialEndsAt!),
        'reminderDaysBefore': d.reminderDaysBefore,
        'category': d.category,
        'notes': d.notes,
        'active': true,
        'brandColor': d.brandColor,
        'updatedAt': FieldValue.serverTimestamp(),
      };
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/domain/subscription_model_test.dart`  
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/subscriptions/domain/subscription.dart lib/features/subscriptions/domain/subscription_draft.dart lib/features/subscriptions/data/subscription_repository.dart test/domain/subscription_model_test.dart
git commit -m "feat(domain): add category and notes to Subscription and SubscriptionDraft"
```

---

### Task 2: Create Preset Services Catalog Model & Curated Presets List

**Files:**
- Create: `lib/features/subscriptions/domain/preset_service.dart`
- Test: `test/domain/preset_service_test.dart`

**Interfaces:**
- Consumes: `brandColorTable`, `brandIconAssetTable`
- Produces:
  - `class PresetService`: `name`, `category`, `brandColorHex`, `iconAsset`
  - `const List<PresetService> kPresetServices`
  - `List<String> kSubscriptionCategories`

- [ ] **Step 1: Write the failing test**

Create `test/domain/preset_service_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:subtracker/features/subscriptions/domain/preset_service.dart';

void main() {
  test('kPresetServices contains 20+ services with non-empty names and categories', () {
    expect(kPresetServices.length, greaterThanOrEqualTo(20));
    for (final service in kPresetServices) {
      expect(service.name.trim(), isNotEmpty);
      expect(service.category.trim(), isNotEmpty);
      expect(service.brandColorHex, isNonZero);
    }
  });

  test('kSubscriptionCategories contains common categories including Other', () {
    expect(kSubscriptionCategories, contains('Entertainment'));
    expect(kSubscriptionCategories, contains('Music'));
    expect(kSubscriptionCategories, contains('Productivity'));
    expect(kSubscriptionCategories, contains('Utilities'));
    expect(kSubscriptionCategories, contains('Other'));
  });

  test('PresetService matches case-insensitively', () {
    final netflix = kPresetServices.firstWhere((s) => s.name == 'Netflix');
    expect(netflix.matchesQuery('net'), isTrue);
    expect(netflix.matchesQuery('FLIX'), isTrue);
    expect(netflix.matchesQuery('xyz123'), isFalse);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/domain/preset_service_test.dart`  
Expected: FAIL ("preset_service.dart not found").

- [ ] **Step 3: Write minimal implementation**

Create `lib/features/subscriptions/domain/preset_service.dart`:
```dart
import 'package:flutter/foundation.dart';
import 'package:subtracker/core/brand/brand_colors.dart';
import 'package:subtracker/core/brand/brand_icons.dart';

const kSubscriptionCategories = <String>[
  'Entertainment',
  'Music',
  'Productivity',
  'Utilities',
  'Gaming',
  'Books',
  'Cloud & Storage',
  'Design',
  'Education',
  'Other',
];

@immutable
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

  bool matchesQuery(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return name.toLowerCase().contains(q) || category.toLowerCase().contains(q);
  }
}

const kPresetServices = <PresetService>[
  PresetService(
    name: 'Netflix',
    category: 'Entertainment',
    brandColorHex: 0xFFE50914,
    iconAsset: 'assets/brand/logos/netflix.svg',
  ),
  PresetService(
    name: 'Spotify',
    category: 'Music',
    brandColorHex: 0xFF1DB954,
    iconAsset: 'assets/brand/logos/spotify.svg',
  ),
  PresetService(
    name: 'Disney+',
    category: 'Entertainment',
    brandColorHex: 0xFF113CCF,
    iconAsset: 'assets/brand/logos/disneyplus.svg',
  ),
  PresetService(
    name: 'YouTube Premium',
    category: 'Entertainment',
    brandColorHex: 0xFFFF0033,
    iconAsset: 'assets/brand/logos/youtube.svg',
  ),
  PresetService(
    name: 'Amazon Prime',
    category: 'Entertainment',
    brandColorHex: 0xFF00A8E1,
    iconAsset: 'assets/brand/logos/amazonprime.svg',
  ),
  PresetService(
    name: 'Apple Music',
    category: 'Music',
    brandColorHex: 0xFFFA243C,
    iconAsset: null,
  ),
  PresetService(
    name: 'Apple One',
    category: 'Entertainment',
    brandColorHex: 0xFFA2AAAD,
    iconAsset: null,
  ),
  PresetService(
    name: 'Apple TV+',
    category: 'Entertainment',
    brandColorHex: 0xFF111111,
    iconAsset: null,
  ),
  PresetService(
    name: 'Adobe Creative Cloud',
    category: 'Design',
    brandColorHex: 0xFFFA0F00,
    iconAsset: 'assets/brand/logos/adobecreativecloud.svg',
  ),
  PresetService(
    name: 'ChatGPT Plus',
    category: 'Productivity',
    brandColorHex: 0xFF10A37F,
    iconAsset: null,
  ),
  PresetService(
    name: 'Cursor',
    category: 'Utilities',
    brandColorHex: 0xFF000000,
    iconAsset: null,
  ),
  PresetService(
    name: 'GitHub Copilot',
    category: 'Productivity',
    brandColorHex: 0xFF24292E,
    iconAsset: null,
  ),
  PresetService(
    name: 'Microsoft 365',
    category: 'Productivity',
    brandColorHex: 0xFFD83B01,
    iconAsset: 'assets/brand/logos/microsoft.svg',
  ),
  PresetService(
    name: 'Xbox Game Pass',
    category: 'Gaming',
    brandColorHex: 0xFF52B043,
    iconAsset: 'assets/brand/logos/xbox.svg',
  ),
  PresetService(
    name: 'PlayStation Plus',
    category: 'Gaming',
    brandColorHex: 0xFF003791,
    iconAsset: null,
  ),
  PresetService(
    name: 'Dropbox',
    category: 'Cloud & Storage',
    brandColorHex: 0xFF0061FF,
    iconAsset: 'assets/brand/logos/dropbox.svg',
  ),
  PresetService(
    name: 'Canva Pro',
    category: 'Design',
    brandColorHex: 0xFF00C4CC,
    iconAsset: 'assets/brand/logos/canva.svg',
  ),
  PresetService(
    name: 'Audible',
    category: 'Books',
    brandColorHex: 0xFFF8991C,
    iconAsset: 'assets/brand/logos/audible.svg',
  ),
  PresetService(
    name: 'iCloud+',
    category: 'Cloud & Storage',
    brandColorHex: 0xFFA2AAAD,
    iconAsset: 'assets/brand/logos/icloud.svg',
  ),
  PresetService(
    name: '1Password',
    category: 'Utilities',
    brandColorHex: 0xFF0A85EA,
    iconAsset: null,
  ),
  PresetService(
    name: 'Notion Plus',
    category: 'Productivity',
    brandColorHex: 0xFF000000,
    iconAsset: null,
  ),
  PresetService(
    name: 'Figma',
    category: 'Design',
    brandColorHex: 0xFFF24E1E,
    iconAsset: null,
  ),
  PresetService(
    name: 'Discord Nitro',
    category: 'Utilities',
    brandColorHex: 0xFF5865F2,
    iconAsset: null,
  ),
  PresetService(
    name: 'Duolingo Super',
    category: 'Education',
    brandColorHex: 0xFF58CC02,
    iconAsset: null,
  ),
];
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/domain/preset_service_test.dart`  
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/subscriptions/domain/preset_service.dart test/domain/preset_service_test.dart
git commit -m "feat(domain): add PresetService model and catalog of popular services"
```

---

### Task 3: Build `SubscriptionCatalogScreen` (Brand Logos Grid + Search + "+ Custom" Card)

**Files:**
- Create: `lib/features/subscriptions/ui/subscription_catalog_screen.dart`
- Test: `test/ui/subscription_catalog_screen_test.dart`

**Interfaces:**
- Consumes: `PresetService`, `kPresetServices`, `SublyColors`, `SublyTypography`, `SublySpace`
- Produces: `SubscriptionCatalogScreen(onSelect: (PresetService? service) => void)`

- [ ] **Step 1: Write the failing test**

Create `test/ui/subscription_catalog_screen_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subtracker/core/theme.dart';
import 'package:subtracker/features/subscriptions/domain/preset_service.dart';
import 'package:subtracker/features/subscriptions/ui/subscription_catalog_screen.dart';

void main() {
  Widget buildScreen({ValueChanged<PresetService?>? onSelect}) {
    return MaterialApp(
      theme: buildSublyTheme(Brightness.dark),
      home: SubscriptionCatalogScreen(
        onSelect: onSelect ?? (_) {},
      ),
    );
  }

  testWidgets('renders Cancel button, Add Subscription title, and Custom card', (tester) async {
    await tester.pumpWidget(buildScreen());
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Add Subscription'), findsOneWidget);
    expect(find.byKey(const Key('custom-service-card')), findsOneWidget);
    expect(find.text('Custom'), findsOneWidget);
  });

  testWidgets('tapping custom card invokes onSelect with null', (tester) async {
    PresetService? selected;
    var invoked = false;
    await tester.pumpWidget(buildScreen(onSelect: (val) {
      invoked = true;
      selected = val;
    }));

    await tester.tap(find.byKey(const Key('custom-service-card')));
    await tester.pumpAndSettle();
    expect(invoked, isTrue);
    expect(selected, isNull);
  });

  testWidgets('search bar filters services in real time', (tester) async {
    await tester.pumpWidget(buildScreen());
    expect(find.text('Netflix'), findsOneWidget);
    expect(find.text('Spotify'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('catalog-search-field')), 'Spotify');
    await tester.pumpAndSettle();

    expect(find.text('Spotify'), findsOneWidget);
    expect(find.text('Netflix'), findsNothing);
  });

  testWidgets('tapping a preset service invokes onSelect with that service', (tester) async {
    PresetService? selected;
    await tester.pumpWidget(buildScreen(onSelect: (val) {
      selected = val;
    }));

    await tester.tap(find.text('Netflix'));
    await tester.pumpAndSettle();
    expect(selected?.name, 'Netflix');
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/ui/subscription_catalog_screen_test.dart`  
Expected: FAIL ("subscription_catalog_screen.dart not found").

- [ ] **Step 3: Write minimal implementation**

Create `lib/features/subscriptions/ui/subscription_catalog_screen.dart`:
- Structure with:
  - Header: `Row` with TextButton('Cancel'), Text('Add Subscription', style: SublyTypography.titleM).
  - Header label: 'ALL SERVICES'.
  - Search bar: at bottom, `Key('catalog-search-field')`, `TextField` with `LucideIcons.search`.
  - Grid: `GridView`:
    - First item: `Key('custom-service-card')` with `LucideIcons.plus` and 'Custom'.
    - Filtered `kPresetServices` items: circular brand tile with glow + service name.
  - Tapping calls `widget.onSelect(preset)` or `widget.onSelect(null)`.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/ui/subscription_catalog_screen_test.dart`  
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/subscriptions/ui/subscription_catalog_screen.dart test/ui/subscription_catalog_screen_test.dart
git commit -m "feat(ui): implement SubscriptionCatalogScreen with brand grid and search"
```

---

### Task 4: Redesign `SubscriptionFormScreen` (Grouped Cards, Hero Brand Glow, Category, Notes)

**Files:**
- Modify: `lib/features/subscriptions/ui/subscription_form_screen.dart`
- Test: `test/ui/subscription_form_screen_test.dart`

**Interfaces:**
- Consumes: `SubscriptionRepository`, `Subscription`, `SubscriptionDraft`, `PresetService? initialPreset`
- Preserves:
  - Keys: `'name-field'`, `'cost-field'`, `'save-button'`, `'trial-switch'`, `'cycle-track'`, `'cycle-thumb'`
  - Segmented thumb geometry (one-third width track)
  - LimitReachedException catch -> `/paywall`

- [ ] **Step 1: Write additional tests in `test/ui/subscription_form_screen_test.dart`**

Add tests for:
- Pre-filling from `initialPreset`:
```dart
testWidgets('pre-populates from initialPreset', (tester) async {
  final db = FakeFirebaseFirestore();
  const preset = PresetService(
    name: 'Netflix',
    category: 'Entertainment',
    brandColorHex: 0xFFE50914,
  );
  await tester.pumpWidget(ProviderScope(
    overrides: [
      subscriptionRepositoryProvider
          .overrideWithValue(SubscriptionRepository(db, 'u1')),
    ],
    child: const MaterialApp(
      home: SubscriptionFormScreen(initialPreset: preset),
    ),
  ));

  expect(find.text('Netflix'), findsWidgets);
  expect(find.text('Entertainment'), findsOneWidget);
});
```
- Saving with `category` and `notes`:
```dart
testWidgets('saves category and notes into Firestore', (tester) async {
  final db = FakeFirebaseFirestore();
  await tester.pumpWidget(_wrap(db));

  await tester.enterText(find.byKey(const Key('name-field')), 'ChatGPT');
  await tester.enterText(find.byKey(const Key('cost-field')), '20.00');
  await tester.enterText(find.byKey(const Key('notes-field')), 'Work subscription');

  await tester.scrollUntilVisible(
    find.byKey(const Key('save-button')),
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('save-button')));
  await tester.pumpAndSettle();

  final subs = await db.collection('users').doc('u1').collection('subscriptions').get();
  expect(subs.docs.single.data()['name'], 'ChatGPT');
  expect(subs.docs.single.data()['notes'], 'Work subscription');
});
```

- [ ] **Step 2: Run tests to verify failure**

Run: `flutter test test/ui/subscription_form_screen_test.dart`  
Expected: FAIL (`initialPreset` not supported, `notes-field` not found).

- [ ] **Step 3: Implement updated `SubscriptionFormScreen`**

In `lib/features/subscriptions/ui/subscription_form_screen.dart`:
- Accept `final PresetService? initialPreset;`.
- In `initState`, initialize `_name.text = widget.initialPreset?.name ?? ''`, `_category = widget.initialPreset?.category ?? 'Other'`, `_brandColor = widget.initialPreset != null ? hexToStore(widget.initialPreset!.brandColorHex) : null`.
- Add `_notes = TextEditingController()`.
- Add Hero Brand Avatar with radial aura glow (`RadialGradient`) at the top of the form.
- Render grouped card containers (`Container` with `step1` surface, hairline border, `SublySpace.radiusCard = 16`):
  - Card 1: Name field, `_SegmentedCycle` (with preserved track and thumb keys), Start Date / Next Charge row, Free Trial switch.
  - Card 2: Cost field (`cost-field`) and Currency dropdown.
  - Card 3: Category dropdown with dot indicator, Notifications reminder dropdown.
  - Card 4: Notes field (`notes-field`).
- Save button (`save-button`) with full width.

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/ui/subscription_form_screen_test.dart`  
Run: `flutter test test/ui/ledger_card_test.dart`  
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/subscriptions/ui/subscription_form_screen.dart test/ui/subscription_form_screen_test.dart
git commit -m "feat(ui): redesign SubscriptionFormScreen with grouped cards and brand glow"
```

---

### Task 5: Update GoRouter Navigation & Wiring

**Files:**
- Modify: `lib/core/router.dart`
- Test: `test/router_test.dart`

**Interfaces:**
- Consumes: `SubscriptionCatalogScreen`, `SubscriptionFormScreen`
- Produces: Updated router config:
  - `/subs/new`: `SubscriptionCatalogScreen` (navigating to `/subs/new/config` or pushing form)
  - `/subs/new/config`: `SubscriptionFormScreen`
  - `/subs/:id/edit`: `SubscriptionFormScreen(existingId: ...)`

- [ ] **Step 1: Write the failing test**

In `test/router_test.dart`, add a test verifying navigation to `/subs/new` renders the catalog screen, and navigation to `/subs/new/config` renders the form screen:
```dart
testWidgets('routes /subs/new opens SubscriptionCatalogScreen', (tester) async {
  // test setup...
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/router_test.dart`  
Expected: FAIL

- [ ] **Step 3: Update `lib/core/router.dart`**

Update the route declarations:
```dart
GoRoute(
  path: '/subs/new',
  pageBuilder: (_, _) => NoTransitionPage(
    child: SubscriptionCatalogScreen(
      onSelect: (preset) {
        // Navigate or push config form
      },
    ),
  ),
  routes: [
    GoRoute(
      path: 'config',
      pageBuilder: (_, state) => NoTransitionPage(
        child: SubscriptionFormScreen(
          initialPreset: state.extra as PresetService?,
        ),
      ),
    ),
  ],
),
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/router_test.dart`  
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/core/router.dart test/router_test.dart
git commit -m "feat(router): wire catalog and configuration routes in GoRouter"
```

---

### Task 6: Full Regression Verification & Analyzer Check

**Files:**
- Verification only

- [ ] **Step 1: Run `flutter analyze`**

Run: `flutter analyze`  
Expected: "No issues found!"

- [ ] **Step 2: Run full test suite**

Run: `flutter test`  
Expected: All 80+ tests pass with zero failures.

- [ ] **Step 3: Run screenshot test to update screenshots**

Run: `flutter test test/design/screenshot_test.dart`  
Expected: PASS

- [ ] **Step 4: Commit any screenshot or test updates**

```bash
git add build/design-screenshots/ test/
git commit -m "chore: update design screenshots and verify full suite"
```
