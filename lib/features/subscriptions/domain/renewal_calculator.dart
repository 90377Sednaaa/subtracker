import 'billing_cycle.dart';

class RenewalCalculator {
  /// Advances [current] by whole cycles until it is strictly after [now].
  static DateTime advanceToDate(
      DateTime current, BillingCycle cycle, DateTime now) {
    var next = current;
    var guard = 0;
    while (!next.isAfter(now) && guard < 600) {
      next = cycle.advance(next);
      guard++;
    }
    return next;
  }

  /// The 09:00 local fire time [reminderDaysBefore] days before
  /// [nextChargeDate], or null when that moment has already passed.
  static DateTime? planFireDate({
    required DateTime nextChargeDate,
    required bool trialing,
    required int reminderDaysBefore,
    required DateTime now,
  }) {
    final day =
        DateTime(nextChargeDate.year, nextChargeDate.month, nextChargeDate.day);
    final candidate = day
        .subtract(Duration(days: reminderDaysBefore))
        .add(const Duration(hours: 9));
    if (!candidate.isAfter(now)) return null;
    return candidate;
  }
}
