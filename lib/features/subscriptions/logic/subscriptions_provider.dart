import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subtracker/features/subscriptions/data/subscription_repository.dart';
import 'package:subtracker/features/subscriptions/logic/subscription_controller.dart';
import '../domain/subscription.dart';
import '../domain/totals_calculator.dart';

/// Dashboard-facing projections of the subscription repository. The
/// repository provider itself is overridden once in main.dart; tests
/// override it with fake-backed instances.
final subscriptionsStreamProvider = StreamProvider<List<Subscription>>(
    (ref) => ref.watch(subscriptionRepositoryProvider).watchAll());

final totalsProvider = Provider((ref) {
  final subs = ref.watch(subscriptionsStreamProvider).value ?? const [];
  return monthlyAndAnnualByCurrency(subs);
});

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
