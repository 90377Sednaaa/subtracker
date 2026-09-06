import 'billing_cycle.dart';
import 'subscription.dart';

/// Per-currency (monthly, annual) totals. annual == monthly * 12 exactly.
Map<String, ({double monthly, double annual})> monthlyAndAnnualByCurrency(
    List<Subscription> subs) {
  final monthly = <String, double>{};
  for (final s in subs) {
    if (!s.active) continue;
    monthly[s.currency] =
        (monthly[s.currency] ?? 0) + s.billingCycle.monthlyEquivalent(s.cost);
  }
  return monthly
      .map((currency, m) => MapEntry(currency, (monthly: m, annual: m * 12)));
}
