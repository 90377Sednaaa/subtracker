import 'billing_cycle.dart';
import 'renewal_calculator.dart';
import 'subscription.dart';

/// Projects renewals of active subscriptions across a calendar month —
/// weekly subs repeat, monthly/annual appear at their charge day.
Map<int, List<Subscription>> renewalsByDay(
    List<Subscription> subs, DateTime monthStart) {
  final first = DateTime(monthStart.year, monthStart.month, 1);
  final daysInMonth =
      DateTime(monthStart.year, monthStart.month + 1).difference(first).inDays;
  final last = first.add(Duration(days: daysInMonth - 1));
  final map = <int, List<Subscription>>{};

  for (final sub in subs.where((s) => s.active)) {
    var cursor = sub.nextChargeDate;
    if (cursor.isBefore(first)) {
      cursor = RenewalCalculator.advanceToDate(
          cursor, sub.billingCycle, first.subtract(const Duration(days: 1)));
    }
    var guard = 0;
    while (!cursor.isAfter(last) && guard < 62) {
      (map[cursor.day] ??= []).add(sub);
      cursor = sub.billingCycle.advance(cursor);
      guard++;
    }
  }

  for (final list in map.values) {
    list.sort((a, b) => a.name.compareTo(b.name));
  }
  return map;
}

/// The renewals for one calendar day, or null when the day is free.
List<Subscription>? dailyRenewals(Map<int, List<Subscription>> byDay, int day) =>
    byDay[day];
