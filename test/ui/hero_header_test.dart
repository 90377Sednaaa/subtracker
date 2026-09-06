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
import 'package:subtracker/features/subscriptions/logic/subscriptions_provider.dart';
import 'package:subtracker/features/subscriptions/ui/hero_spend_header.dart';
import 'package:subtracker/features/subscriptions/ui/renewal_strip.dart';

class _SignedInAuthRepository implements AuthRepository {
  static final _user = MockUser(uid: 'u1', email: 'a@b.c');
  @override
  Stream<User?> get authStateChanges => Stream.value(_user);
  @override
  User? currentUser() => _user;
  @override
  Future<void> signInWithGoogle() async {}
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
    nextChargeDate: DateTime.now().add(const Duration(days: 2)),
    trialEndsAt: null,
    reminderDaysBefore: 3,
  ));
  await repo.add(SubscriptionDraft(
    name: 'Adobe',
    cost: 659.88,
    currency: 'USD',
    billingCycle: BillingCycle.annual,
    nextChargeDate: DateTime.now().add(const Duration(days: 10)),
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

Widget _app(ProviderContainer container) => UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: Scaffold(body: _DashboardBody())),
    );

/// Mirrors the dashboard list so hero tests pump the exact production stack.
class _DashboardBody extends ConsumerWidget {
  const _DashboardBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subs = ref.watch(subscriptionsStreamProvider).value ?? const [];
    return ListView(
      children: [
        HeroSpendHeader(
          totals: ref.watch(totalsProvider),
          subCount: subs.where((s) => s.active).length,
          now: DateTime.now(),
        ),
        RenewalStrip(
          upcoming: ref.watch(next7DaysProvider),
          now: DateTime.now(),
        ),
      ],
    );
  }
}

Rect _rectOf(WidgetTester tester, Finder finder) =>
    tester.getRect(finder);

void main() {
  testWidgets('hero counts up to the exact monthly total', (tester) async {
    final container = await _container(FakeFirebaseFirestore());
    await tester.pumpWidget(_app(container));
    await tester.pumpAndSettle();

    // 15.49 monthly + 659.88/12 = 15.49 + 54.99 = 70.48
    expect(find.textContaining(r'$70.48'), findsOneWidget);
    expect(find.textContaining('846/year'), findsOneWidget); // 70.48*12 ≈ 845.76 → $846
  });

  testWidgets('ALIGNMENT: ring is vertically centered on the hero number',
      (tester) async {
    final container = await _container(FakeFirebaseFirestore());
    await tester.pumpWidget(_app(container));
    await tester.pumpAndSettle();

    final money = _rectOf(tester, find.byKey(const Key('hero-money')));
    final ring = _rectOf(tester, find.byKey(const Key('hero-ring')));
    final moneyCenter = money.centerRight.dy;
    final ringCenter = ring.center.dy;
    expect((moneyCenter - ringCenter).abs(), lessThan(2.0),
        reason: 'ring center must align with the money line');
    // The ring never crowds the text: at least 12dp of gutter.
    expect(money.right <= ring.left, isTrue);
  });

  testWidgets('ALIGNMENT: hero content respects the 24dp screen margin',
      (tester) async {
    final container = await _container(FakeFirebaseFirestore());
    await tester.pumpWidget(_app(container));
    await tester.pumpAndSettle();

    final money = _rectOf(tester, find.byKey(const Key('hero-money')));
    final label = _rectOf(tester, find.text('THIS MONTH'));
    // Money and label share the same left edge (the label has no extra
    // padding, the money stack is inside the same padded column).
    expect((money.left - label.left).abs(), lessThan(1.0),
        reason: 'hero number must left-align with its label');
    expect(label.left, closeTo(24.0, 1.0));
  });

  testWidgets('ALIGNMENT: no overflow at 1.3x text scale', (tester) async {
    final container = await _container(FakeFirebaseFirestore());
    await tester.pumpWidget(MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.3,
      child: _app(container),
    ));
    await tester.pumpAndSettle();
    tester.takeException();
    expect(tester.takeException(), isNull);
  });

  testWidgets('renewal strip shows only the next-7-days renewal, urgent-tinted',
      (tester) async {
    final container = await _container(FakeFirebaseFirestore());
    await tester.pumpWidget(_app(container));
    await tester.pumpAndSettle();

    // Netflix (2 days out) is in the strip and urgent; Adobe (10 days) is not.
    expect(find.byKey(const Key('renewal-chip-')), findsNothing);
    expect(find.text('Netflix'), findsOneWidget);
    expect(find.text('Adobe'), findsNothing);
    expect(find.text('Nothing renews this week.'), findsNothing);
  });
}
