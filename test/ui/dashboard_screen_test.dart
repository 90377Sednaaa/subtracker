import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subtracker/features/subscriptions/data/subscription_repository.dart';
import 'package:subtracker/features/subscriptions/domain/billing_cycle.dart';
import 'package:subtracker/features/subscriptions/domain/subscription_draft.dart';
import 'package:subtracker/features/subscriptions/ui/dashboard_screen.dart';

Future<ProviderContainer> _container(FakeFirebaseFirestore db) async {
  final repo = SubscriptionRepository(db, 'u1');
  await db
      .collection('users')
      .doc('u1')
      .set({'premium': true, 'email': 'a@b.c'});
  await repo.add(SubscriptionDraft(
    name: 'Netflix',
    cost: 15.49,
    currency: 'USD',
    billingCycle: BillingCycle.monthly,
    nextChargeDate: DateTime(2026, 10, 1),
    trialEndsAt: null,
    reminderDaysBefore: 3,
  ));
  final container = ProviderContainer(overrides: [
    subscriptionRepositoryProvider.overrideWithValue(repo),
  ]);
  addTearDown(container.dispose);
  return container;
}

void main() {
  testWidgets('renders subscriptions and per-currency totals', (tester) async {
    final container = await _container(FakeFirebaseFirestore());
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: DashboardScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Netflix'), findsOneWidget);
    expect(find.textContaining(r'$15.49'), findsWidgets);
  });

  testWidgets('empty state shown with no subscriptions', (tester) async {
    final db = FakeFirebaseFirestore();
    final container = ProviderContainer(overrides: [
      subscriptionRepositoryProvider
          .overrideWithValue(SubscriptionRepository(db, 'u1')),
    ]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: DashboardScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('empty-state')), findsOneWidget);
  });
}
