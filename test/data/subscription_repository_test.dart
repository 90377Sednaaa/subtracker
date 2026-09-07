import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subtracker/features/subscriptions/data/subscription_repository.dart';
import 'package:subtracker/features/subscriptions/domain/billing_cycle.dart';
import 'package:subtracker/features/subscriptions/domain/subscription_draft.dart';

SubscriptionDraft draft(String name) => SubscriptionDraft(
      name: name,
      cost: 9.99,
      currency: 'USD',
      billingCycle: BillingCycle.monthly,
      nextChargeDate: DateTime(2026, 10, 1),
      trialEndsAt: null,
      reminderDaysBefore: 3,
    );

void main() {
  test('add persists a document and watchAll returns it', () async {
    final db = FakeFirebaseFirestore();
    final repo = SubscriptionRepository(db, 'u1');

    await repo.add(draft('Netflix'));

    final subs = await repo.watchAll().first;
    expect(subs, hasLength(1));
    expect(subs.single.name, 'Netflix');
    expect(subs.single.billingCycle, BillingCycle.monthly);
  });

  test('add throws LimitReachedException at 5 active subs for free user',
      () async {
    final db = FakeFirebaseFirestore();
    final repo = SubscriptionRepository(db, 'u1');
    for (var i = 0; i < 5; i++) {
      await repo.add(draft('Sub $i'));
    }

    expect(
      () => repo.add(draft('Number six')),
      throwsA(isA<LimitReachedException>()),
    );
  });

  test('premium user can exceed 5', () async {
    final db = FakeFirebaseFirestore();
    final repo = SubscriptionRepository(db, 'u1');
    await db.collection('users').doc('u1').set({'premium': true});
    for (var i = 0; i < 6; i++) {
      await repo.add(draft('Sub $i'));
    }
    final subs = await repo.watchAll().first;
    expect(subs, hasLength(6));
  });

  test('inactive subscriptions do not count toward the limit', () async {
    final db = FakeFirebaseFirestore();
    final repo = SubscriptionRepository(db, 'u1');
    for (var i = 0; i < 5; i++) {
      await repo.add(draft('Sub $i'));
    }
    final id = (await repo.watchAll().first).first.id;
    await repo.setActive(id, false);

    await repo.add(draft('Replacement'));
    final subs = await repo.watchAll().first;
    expect(subs.where((s) => s.active), hasLength(5));
  });

  test('update edits fields', () async {
    final db = FakeFirebaseFirestore();
    final repo = SubscriptionRepository(db, 'u1');
    await repo.add(draft('Netflix'));
    final sub = (await repo.watchAll().first).single;

    await repo.update(
        sub.id,
        SubscriptionDraft(
          name: 'Netflix Premium',
          cost: 22.99,
          currency: 'USD',
          billingCycle: BillingCycle.monthly,
          nextChargeDate: DateTime(2026, 10, 1),
          trialEndsAt: DateTime(2026, 9, 20),
          reminderDaysBefore: 3,
        ));

    final updated = (await repo.watchAll().first).single;
    expect(updated.name, 'Netflix Premium');
    expect(updated.cost, 22.99);
    expect(updated.trialEndsAt, DateTime(2026, 9, 20));
  });

  test('delete removes the document', () async {
    final db = FakeFirebaseFirestore();
    final repo = SubscriptionRepository(db, 'u1');
    await repo.add(draft('Netflix'));
    final sub = (await repo.watchAll().first).single;

    await repo.delete(sub.id);
    expect((await repo.watchAll().first), isEmpty);
  });

  test('update persists active status from draft', () async {
    final db = FakeFirebaseFirestore();
    final repo = SubscriptionRepository(db, 'u1');
    await repo.add(draft('Netflix'));
    final sub = (await repo.watchAll().first).single;
    expect(sub.active, isTrue);

    await repo.update(
      sub.id,
      SubscriptionDraft(
        name: 'Netflix',
        cost: 9.99,
        currency: 'USD',
        billingCycle: BillingCycle.monthly,
        nextChargeDate: DateTime(2026, 10, 1),
        trialEndsAt: null,
        reminderDaysBefore: 3,
        active: false,
      ),
    );

    final updated = (await repo.watchAll().first).single;
    expect(updated.active, isFalse);
  });
}

