import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subtracker/core/notifications/reminder_scheduler.dart';
import 'package:subtracker/features/subscriptions/data/subscription_repository.dart';
import 'package:subtracker/features/subscriptions/domain/billing_cycle.dart';
import 'package:subtracker/features/subscriptions/domain/subscription_draft.dart';
import 'package:subtracker/features/subscriptions/logic/subscription_controller.dart';

// Deterministic fake so controller logic is testable without the plugin.
class _RecordingScheduler implements ReminderScheduler {
  final scheduled = <ScheduleRequest>[];
  final cancelled = <int>[];

  @override
  Future<void> schedule(ScheduleRequest request) async =>
      scheduled.add(request);

  @override
  Future<void> cancel(int id) async => cancelled.add(id);
}

SubscriptionDraft _draft(DateTime nextCharge) => SubscriptionDraft(
      name: 'Netflix',
      cost: 10,
      currency: 'USD',
      billingCycle: BillingCycle.monthly,
      nextChargeDate: nextCharge,
      trialEndsAt: null,
      reminderDaysBefore: 3,
    );

void main() {
  test('notificationId is stable per subscription id', () {
    expect(notificationIdFor('abc'), notificationIdFor('abc'));
    expect(notificationIdFor('abc'), isNot(notificationIdFor('xyz')));
    expect(notificationIdFor('abc'), greaterThanOrEqualTo(0));
  });

  test('reconcile schedules one reminder 3 days before the charge', () async {
    final db = FakeFirebaseFirestore();
    await db.collection('users').doc('u1').set({'premium': true});
    final repo = SubscriptionRepository(db, 'u1');
    // Deterministic regardless of the date the test runs:
    final charge = DateTime.now().add(const Duration(days: 14));
    await repo.add(_draft(charge));

    final scheduler = _RecordingScheduler();
    final container = ProviderContainer(overrides: [
      subscriptionRepositoryProvider.overrideWithValue(repo),
      reminderSchedulerProvider.overrideWithValue(scheduler),
    ]);
    addTearDown(container.dispose);

    await container
        .read(subscriptionControllerProvider.notifier)
        .reconcileSchedules(await repo.watchAll().first);
    expect(scheduler.cancelled, hasLength(1)); // cancel-before-schedule
    expect(scheduler.scheduled, hasLength(1));
    // (charge date 00:00 + 9h) - 3 days == 09:00 three days before.
    final expectedFire = DateTime(charge.year, charge.month, charge.day, 9)
        .subtract(const Duration(days: 3));
    expect(scheduler.scheduled.single.fireAt, expectedFire);
  });

  test('inactive subscriptions are not scheduled', () async {
    final db = FakeFirebaseFirestore();
    await db.collection('users').doc('u1').set({'premium': true});
    final repo = SubscriptionRepository(db, 'u1');
    await repo.add(_draft(DateTime.now().add(const Duration(days: 14))));
    final sub = (await repo.watchAll().first).single;
    await repo.setActive(sub.id, false);

    final scheduler = _RecordingScheduler();
    final container = ProviderContainer(overrides: [
      subscriptionRepositoryProvider.overrideWithValue(repo),
      reminderSchedulerProvider.overrideWithValue(scheduler),
    ]);
    addTearDown(container.dispose);

    await container
        .read(subscriptionControllerProvider.notifier)
        .reconcileSchedules(await repo.watchAll().first);

    expect(scheduler.scheduled, isEmpty);
  });
}
