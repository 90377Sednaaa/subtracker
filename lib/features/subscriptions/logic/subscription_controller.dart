import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subtracker/core/notifications/reminder_scheduler.dart';
import 'package:subtracker/features/subscriptions/data/subscription_repository.dart';
import 'package:subtracker/features/subscriptions/domain/renewal_calculator.dart';
import 'package:subtracker/features/subscriptions/domain/subscription.dart';
import 'package:subtracker/features/subscriptions/domain/subscription_draft.dart';

/// Overridden in main.dart with the real plugin service; tests override with
/// a recording fake.
final reminderSchedulerProvider =
    Provider<ReminderScheduler>((ref) => throw UnimplementedError());

final subscriptionControllerProvider =
    NotifierProvider<SubscriptionController, void>(SubscriptionController.new);

class SubscriptionController extends Notifier<void> {
  @override
  void build() {}

  Future<void> _syncOne(Subscription sub) async {
    final scheduler = ref.read(reminderSchedulerProvider);
    final id = notificationIdFor(sub.id);
    await scheduler.cancel(id);

    final now = DateTime.now();
    if (!sub.active) return;

    var nextCharge = sub.nextChargeDate;
    // Catch-up: if a period elapsed while the app was closed, roll the
    // stored date forward so the dashboard stays truthful.
    if (!sub.trialing && !nextCharge.isAfter(now)) {
      nextCharge =
          RenewalCalculator.advanceToDate(nextCharge, sub.billingCycle, now);
      await ref.read(subscriptionRepositoryProvider).update(
            sub.id,
            SubscriptionDraft(
              name: sub.name,
              cost: sub.cost,
              currency: sub.currency,
              billingCycle: sub.billingCycle,
              nextChargeDate: nextCharge,
              trialEndsAt: sub.trialEndsAt,
              reminderDaysBefore: sub.reminderDaysBefore,
            ),
          );
    }

    final fireAt = RenewalCalculator.planFireDate(
      nextChargeDate: nextCharge,
      trialing: sub.trialing,
      reminderDaysBefore: sub.reminderDaysBefore,
      now: now,
    );
    if (fireAt == null) return; // too late to warn about this cycle
    await scheduler.schedule(ScheduleRequest(
      id: id,
      title: sub.trialing
          ? '${sub.name} trial ends soon'
          : '${sub.name} renews soon',
      body: sub.trialing
          ? 'Your free trial ends ${_fmt(nextCharge)}. Cancel if you don\'t want to be charged.'
          : '${sub.name} will charge ${sub.currency} ${sub.cost.toStringAsFixed(2)} on ${_fmt(nextCharge)}.',
      fireAt: fireAt,
    ));
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Reconciles the given [subs] with reality and keeps exactly one upcoming
  /// reminder per subscription. Callers supply the current list (event-driven
  /// via reminderSyncProvider) — riverpod 3's StreamProvider.future only
  /// resolves when the stream completes, which Firestore streams never do.
  Future<void> reconcileSchedules(List<Subscription> subs) async {
    for (final sub in subs) {
      await _syncOne(sub);
    }
  }
}
