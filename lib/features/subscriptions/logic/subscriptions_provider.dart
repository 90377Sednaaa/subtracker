import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subtracker/features/auth/logic/auth_controller.dart';
import 'package:subtracker/features/subscriptions/data/subscription_repository.dart';
import 'package:subtracker/features/subscriptions/logic/subscription_controller.dart';
import '../domain/subscription.dart';
import '../domain/totals_calculator.dart';

/// Dashboard-facing projections of the subscription repository.
///
/// Auth-aware: while signed out the repository cannot exist (it needs a uid),
/// so this yields an empty stream instead of mounting it — otherwise the
/// provider would cache an error state from the pre-sign-in frame and the
/// dashboard would stay broken after sign-in until restart.
final subscriptionsStreamProvider = StreamProvider<List<Subscription>>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final user = auth.value;
  if (user == null) return const Stream.empty();
  return ref.watch(subscriptionRepositoryProvider).watchAll();
});

final totalsProvider = Provider((ref) {
  final subs = ref.watch(subscriptionsStreamProvider).value ?? const [];
  return monthlyAndAnnualByCurrency(subs);
});

/// Active subscriptions renewing within the next 7 days (today included),
/// soonest first — the renewal strip's data.
final next7DaysProvider = Provider<List<Subscription>>((ref) {
  final subs = ref.watch(subscriptionsStreamProvider).value ?? const [];
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final limit = today.add(const Duration(days: 7));
  return subs
      .where((s) =>
          s.active &&
          !s.nextChargeDate.isBefore(today) &&
          s.nextChargeDate.isBefore(limit))
      .toList()
    ..sort((a, b) => a.nextChargeDate.compareTo(b.nextChargeDate));
});

/// Which dashboard view is showing. Calendar is the default: renewals at a
/// glance, ledger one tap away.
enum DashboardView { calendar, ledger }

class DashboardViewController extends Notifier<DashboardView> {
  @override
  DashboardView build() => DashboardView.calendar;

  void set(DashboardView v) => state = v;
}

final dashboardViewProvider = NotifierProvider<DashboardViewController, DashboardView>(
    DashboardViewController.new);

/// App-wide reminder sync: every time the subscription list changes (or is
/// first loaded), reconcile on-device reminders with the stored data.
/// Watching this provider from the app root keeps reminders in sync without
/// every screen having to remember to reschedule.
final reminderSyncProvider = Provider<void>((ref) {
  ref.listen(subscriptionsStreamProvider, (_, next) {
    final subs = next.value;
    if (subs != null) {
      ref.read(subscriptionControllerProvider.notifier).reconcileSchedules(subs);
    }
  });
});
