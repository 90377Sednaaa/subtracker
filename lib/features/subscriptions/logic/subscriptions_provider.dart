import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subtracker/features/subscriptions/data/subscription_repository.dart';
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
