import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:subtracker/core/brand/brand.dart';
import 'package:subtracker/core/theme.dart';
import 'package:subtracker/features/subscriptions/data/subscription_repository.dart';
import 'package:subtracker/features/subscriptions/domain/billing_cycle.dart';
import 'package:subtracker/features/subscriptions/domain/subscription.dart';
import 'package:subtracker/features/subscriptions/domain/subscription_draft.dart';
import 'package:subtracker/features/subscriptions/ui/subscription_card.dart';
import 'package:subtracker/features/subscriptions/ui/subscription_form_screen.dart';

Subscription _sub() => Subscription(
      id: 'sub1',
      name: 'Netflix',
      cost: 15.49,
      currency: 'USD',
      billingCycle: BillingCycle.monthly,
      nextChargeDate: DateTime(2026, 10, 1),
      trialEndsAt: null,
      reminderDaysBefore: 3,
      active: true,
      createdAt: null,
    );

void main() {
  testWidgets('CARD GEOMETRY: cost right-aligns to the card content edge',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildSublyTheme(Brightness.dark),
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24),
          child:
              SubscriptionCard(subscription: _sub(), dateFormat: DateFormat.yMMMd()),
        ),
      ),
    ));
    final card = tester.getRect(find.byType(Card));
    final cost = tester.getRect(find.byKey(const Key('cost-sub1')));
    // Card padding is 16dp on both sides; the hairline border adds 1dp.
    expect(card.right - cost.right, closeTo(16 + 1, 1.5),
        reason: 'cost must sit flush against the card content right edge');
  });

  testWidgets('CARD GEOMETRY: name starts after tile + 12dp gutter',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildSublyTheme(Brightness.dark),
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24),
          child:
              SubscriptionCard(subscription: _sub(), dateFormat: DateFormat.yMMMd()),
        ),
      ),
    ));
    final tile = tester.getRect(find.byType(BrandTile));
    final name = tester.getRect(find.text('Netflix'));
    final card = tester.getRect(find.byType(Card));
    expect(name.left - tile.right, closeTo(12, 1.5),
        reason: 'name must follow the brand tile with a 12dp gutter');
    // The lettermark is vertically centered on the ledger row.
    expect((tile.centerLeft.dy - card.centerLeft.dy).abs(), lessThan(2.0));
  });

  testWidgets('CARD GEOMETRY: long names ellipsize instead of pushing cost',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildSublyTheme(Brightness.dark),
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: SubscriptionCard(
            subscription: Subscription(
              id: 'long',
              name:
                  'YouTube Premium Family Plan With Extra Storage Add-on 2026',
              cost: 23.99,
              currency: 'USD',
              billingCycle: BillingCycle.monthly,
              nextChargeDate: DateTime(2026, 10, 1),
              trialEndsAt: null,
              reminderDaysBefore: 3,
              active: true,
              createdAt: null,
            ),
            dateFormat: DateFormat.yMMMd(),
          ),
        ),
      ),
    ));
    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('cost-long')), findsOneWidget);
  });

  testWidgets('SEGMENTED SELECTOR: thumb is exactly one third, flush 4dp',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildSublyTheme(Brightness.dark),
      home: const Scaffold(
        body: Padding(
          padding: EdgeInsets.all(24),
          child: SubscriptionFormScreen(),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    Rect trackRect() => tester.getRect(find.byKey(const Key('cycle-track')));
    Rect thumbRect() => tester.getRect(find.byKey(const Key('cycle-thumb')));

    final expectedWidth = (trackRect().width - 8 - 2) / 3; // padding + border
    expect(thumbRect().width, closeTo(expectedWidth, 1.0),
        reason: 'thumb must span exactly one third');

    // Default is monthly → centered: equal gap on both sides.
    final centerGap =
        (thumbRect().left - trackRect().left) - (trackRect().right - thumbRect().right);
    expect(centerGap.abs(), lessThan(2.0));

    // Tap annual: thumb slides flush to the right edge.
    await tester.tap(find.text('annual'));
    await tester.pumpAndSettle();
    expect(trackRect().right - thumbRect().right, closeTo(4 + 1, 1.5),
        reason: 'annual thumb must sit flush right (4dp inset)');

    // Tap weekly: thumb slides flush to the left edge.
    await tester.tap(find.text('weekly'));
    await tester.pumpAndSettle();
    expect(thumbRect().left - trackRect().left, closeTo(4 + 1, 1.5),
        reason: 'weekly thumb must sit flush left (4dp inset)');
  });

  testWidgets('EDIT MODE: form preloads stored values', (tester) async {
    final db = FakeFirebaseFirestore();
    await db.collection('users').doc('u1').set({'premium': true});
    final repo = SubscriptionRepository(db, 'u1');
    await repo.add(SubscriptionDraft(
      name: 'Spotify',
      cost: 11.99,
      currency: 'EUR',
      billingCycle: BillingCycle.annual,
      nextChargeDate: DateTime(2027, 3, 1),
      trialEndsAt: null,
      reminderDaysBefore: 5,
    ));
    final stored = (await repo.watchAll().first).single;

    await tester.pumpWidget(ProviderScope(
      overrides: [subscriptionRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(
        theme: buildSublyTheme(Brightness.dark),
        home: Scaffold(body: SubscriptionFormScreen(existingId: stored.id)),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Spotify'), findsNWidgets(2)); // Hero title + field
    expect(find.text('11.99'), findsOneWidget);
  });
}
