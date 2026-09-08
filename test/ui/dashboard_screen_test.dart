import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subtracker/features/auth/data/auth_repository.dart';
import 'package:subtracker/features/auth/logic/auth_controller.dart';
import 'package:subtracker/features/subscriptions/data/subscription_repository.dart';
import 'package:subtracker/features/subscriptions/domain/billing_cycle.dart';
import 'package:subtracker/features/subscriptions/domain/subscription_draft.dart';
import 'package:subtracker/features/subscriptions/ui/dashboard_screen.dart';
import 'package:subtracker/features/subscriptions/ui/hero_spend_header.dart';

/// Signed-in auth so the dashboard's one-frame guard lets the list render.
class _SignedInAuthRepository implements AuthRepository {
  static final _user = MockUser(uid: 'u1', email: 'a@b.c');
  @override
  Stream<User?> get authStateChanges => Stream.value(_user);
  @override
  User? currentUser() => _user;
  @override
  Future<void> signInWithGoogle() async {}
  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {}
  @override
  Future<void> createUserWithEmailAndPassword(
    String email,
    String password, {
    String? displayName,
  }) async {}
  @override
  Future<void> signOut() async {}
}

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
    authRepositoryProvider.overrideWithValue(_SignedInAuthRepository()),
    subscriptionRepositoryProvider.overrideWithValue(repo),
  ]);
  addTearDown(container.dispose);
  return container;
}

void main() {
  testWidgets('renders subscriptions and per-currency totals in ledger view',
      (tester) async {
    final container = await _container(FakeFirebaseFirestore());
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: DashboardScreen()),
    ));
    await tester.pumpAndSettle();

    // Calendar is the default view; flip to the ledger to see the cards.
    await tester.tap(find.text('Ledger'));
    await tester.pumpAndSettle();

    expect(find.text('Netflix'), findsOneWidget);
    expect(find.textContaining(r'$15.49'), findsWidgets);
  });

  testWidgets('calendar is the default view with the month grid',
      (tester) async {
    final container = await _container(FakeFirebaseFirestore());
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: DashboardScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('calendar-view')), findsOneWidget);
    expect(find.text('Ledger'), findsOneWidget);
  });

  testWidgets('empty state shown with no subscriptions', (tester) async {
    final db = FakeFirebaseFirestore();
    final container = ProviderContainer(overrides: [
      authRepositoryProvider.overrideWithValue(_SignedInAuthRepository()),
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

  testWidgets('Inactive filter chip filters for canceled subscriptions',
      (tester) async {
    final db = FakeFirebaseFirestore();
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
      active: true,
    ));
    await repo.add(SubscriptionDraft(
      name: 'Old Gym',
      cost: 50.00,
      currency: 'USD',
      billingCycle: BillingCycle.monthly,
      nextChargeDate: DateTime(2026, 10, 1),
      trialEndsAt: null,
      reminderDaysBefore: 3,
      active: false,
    ));

    final container = ProviderContainer(overrides: [
      authRepositoryProvider.overrideWithValue(_SignedInAuthRepository()),
      subscriptionRepositoryProvider.overrideWithValue(repo),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: DashboardScreen()),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ledger'));
    await tester.pumpAndSettle();

    // Check filter chips exist
    expect(find.text('All (2)'), findsOneWidget);
    expect(find.text('Inactive (1)'), findsOneWidget);
    expect(find.text('Netflix'), findsOneWidget);
    expect(find.text('Old Gym'), findsOneWidget);

    // Tap Inactive filter
    await tester.tap(find.text('Inactive (1)'));
    await tester.pumpAndSettle();

    expect(find.text('Netflix'), findsNothing);
    expect(find.text('Old Gym'), findsOneWidget);
  });

  testWidgets(
      'swiping in calendar container shifts month, swiping outside switches to ledger',
      (tester) async {
    final container = await _container(FakeFirebaseFirestore());
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: DashboardScreen()),
    ));
    await tester.pumpAndSettle();

    // Initially in Calendar view
    expect(find.byKey(const Key('calendar-view')), findsOneWidget);

    // Swiping in calendar container shifts month, does not switch to ledger
    await tester.drag(
      find.byKey(const Key('calendar-container')),
      const Offset(-100, 0),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('calendar-view')), findsOneWidget);

    // Swiping outside calendar container (on the agenda card) switches page to Ledger
    final agenda = find.byKey(const Key('selected-day-agenda'));
    await tester.scrollUntilVisible(
      agenda,
      150,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();

    await tester.fling(agenda, const Offset(-400, 0), 1000);
    await tester.pumpAndSettle();

    // Should now be on Ledger view showing subscriptions
    expect(find.text('Netflix'), findsOneWidget);

    // Swiping back right on Ledger (outside dismissible cards) switches to Calendar view
    await tester.fling(find.byType(HeroSpendHeader), const Offset(400, 0), 1000);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('calendar-view')), findsOneWidget);
  });
}


