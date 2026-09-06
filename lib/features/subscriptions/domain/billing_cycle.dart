import 'dart:math';

enum BillingCycle { weekly, monthly, annual }

BillingCycle parseBillingCycle(String value) =>
    BillingCycle.values.firstWhere((c) => c.name == value,
        orElse: () => BillingCycle.monthly);

extension BillingCycleX on BillingCycle {
  DateTime advance(DateTime date) => switch (this) {
        BillingCycle.weekly => date.add(const Duration(days: 7)),
        BillingCycle.annual => _addMonths(date, 12),
        BillingCycle.monthly => _addMonths(date, 1),
      };

  double monthlyEquivalent(double cost) => switch (this) {
        BillingCycle.weekly => cost * 52 / 12,
        BillingCycle.annual => cost / 12,
        BillingCycle.monthly => cost,
      };
}

DateTime _addMonths(DateTime d, int months) {
  final total = d.month - 1 + months;
  final year = d.year + total ~/ 12;
  final month = total % 12 + 1;
  final day = min(d.day, _daysInMonth(year, month));
  return DateTime(year, month, day, d.hour, d.minute);
}

int _daysInMonth(int year, int month) {
  final nextMonth =
      month == 12 ? DateTime(year + 1, 1, 1) : DateTime(year, month + 1, 1);
  return nextMonth.subtract(const Duration(days: 1)).day;
}
