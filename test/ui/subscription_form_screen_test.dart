import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subtracker/core/brand/brand_icons.dart';
import 'package:subtracker/features/subscriptions/data/subscription_repository.dart';
import 'package:subtracker/features/subscriptions/domain/preset_service.dart';
import 'package:subtracker/features/subscriptions/ui/subscription_form_screen.dart';

Widget _wrap(FakeFirebaseFirestore db) => ProviderScope(
      overrides: [
        subscriptionRepositoryProvider
            .overrideWithValue(SubscriptionRepository(db, 'u1')),
      ],
      child: const MaterialApp(home: SubscriptionFormScreen()),
    );

void main() {
  testWidgets('validates required fields', (tester) async {
    final db = FakeFirebaseFirestore();
    await tester.pumpWidget(_wrap(db));
    await tester.scrollUntilVisible(
      find.byKey(const Key('save-button')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('save-button')));
    await tester.pumpAndSettle();

    // Validation blocked the save: nothing was written. (The inline
    // 'Enter a name' error sits above the viewport by this point.)
    final subs = await db
        .collection('users')
        .doc('u1')
        .collection('subscriptions')
        .get();
    expect(subs.docs, isEmpty);
  });

  testWidgets('save writes a subscription draft', (tester) async {
    final db = FakeFirebaseFirestore();
    await tester.pumpWidget(_wrap(db));

    await tester.enterText(find.byKey(const Key('name-field')), 'Spotify');
    await tester.enterText(find.byKey(const Key('cost-field')), '11.99');
    await tester.scrollUntilVisible(
      find.byKey(const Key('save-button')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('save-button')));
    await tester.pumpAndSettle();

    final subs = await db
        .collection('users')
        .doc('u1')
        .collection('subscriptions')
        .get();
    expect(subs.docs.single.data()['name'], 'Spotify');
    expect(subs.docs.single.data()['cost'], 11.99);
    expect(subs.docs.single.data()['category'], isNotEmpty);
  });

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

  testWidgets('save writes category and notes into Firestore', (tester) async {
    final db = FakeFirebaseFirestore();
    await tester.pumpWidget(_wrap(db));

    await tester.enterText(find.byKey(const Key('name-field')), 'ChatGPT');
    await tester.enterText(find.byKey(const Key('cost-field')), '20.00');
    await tester.enterText(find.byKey(const Key('notes-field')), 'Work account');

    await tester.scrollUntilVisible(
      find.byKey(const Key('save-button')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('save-button')));
    await tester.pumpAndSettle();

    final subs = await db
        .collection('users')
        .doc('u1')
        .collection('subscriptions')
        .get();
    expect(subs.docs.single.data()['name'], 'ChatGPT');
    expect(subs.docs.single.data()['cost'], 20.0);
    expect(subs.docs.single.data()['notes'], 'Work account');
  });

  testWidgets('renders BrandBadge in hero with size 72', (tester) async {
    final db = FakeFirebaseFirestore();
    const preset = PresetService(
      name: 'Spotify',
      category: 'Music',
      brandColorHex: 0xFF1DB954,
      iconAsset: 'assets/brand/logos/spotify.svg',
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

    final badgeFinder = find.byType(BrandBadge);
    expect(badgeFinder, findsOneWidget);
    final badge = tester.widget<BrandBadge>(badgeFinder);
    expect(badge.size, 72);
    expect(badge.name, 'Spotify');
    expect(badge.asset, 'assets/brand/logos/spotify.svg');
  });

  testWidgets('toggling free trial switch reveals and hides trial ends row',
      (tester) async {
    final db = FakeFirebaseFirestore();
    await tester.pumpWidget(_wrap(db));

    // Initially trial is off -> no 'Trial ends' row
    expect(find.text('Trial ends'), findsNothing);

    // Toggle on
    await tester.tap(find.byKey(const Key('trial-switch')));
    await tester.pumpAndSettle();
    expect(find.text('Trial ends'), findsOneWidget);

    // Toggle off
    await tester.tap(find.byKey(const Key('trial-switch')));
    await tester.pumpAndSettle();
    expect(find.text('Trial ends'), findsNothing);
  });

  testWidgets('validates non-numeric cost input', (tester) async {
    final db = FakeFirebaseFirestore();
    await tester.pumpWidget(_wrap(db));

    await tester.enterText(find.byKey(const Key('name-field')), 'Netflix');
    await tester.enterText(find.byKey(const Key('cost-field')), 'abc');
    await tester.scrollUntilVisible(
      find.byKey(const Key('save-button')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('save-button')));
    await tester.pumpAndSettle();

    final subs = await db
        .collection('users')
        .doc('u1')
        .collection('subscriptions')
        .get();
    expect(subs.docs, isEmpty);
  });
}

