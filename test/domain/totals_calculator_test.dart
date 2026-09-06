import 'package:flutter_test/flutter_test.dart';
import 'package:subtracker/features/subscriptions/domain/billing_cycle.dart';
import 'package:subtracker/features/subscriptions/domain/subscription.dart';
import 'package:subtracker/features/subscriptions/domain/totals_calculator.dart';

Subscription sub({
  required String currency,
  required BillingCycle cycle,
  required double cost,
  bool active = true,
}) =>
    Subscription(
      id: cost.toString(),
      name: 'n',
      cost: cost,
      currency: currency,
      billingCycle: cycle,
      nextChargeDate: DateTime(2026, 10, 1),
      trialEndsAt: null,
      reminderDaysBefore: 3,
      active: active,
      createdAt: null,
    );

void main() {
  test('groups totals per currency', () {
    final totals = monthlyAndAnnualByCurrency([
      sub(currency: 'USD', cycle: BillingCycle.monthly, cost: 10),
      sub(currency: 'USD', cycle: BillingCycle.annual, cost: 120),
      sub(currency: 'EUR', cycle: BillingCycle.monthly, cost: 9.99),
    ]);
    expect(totals['USD']!.monthly, 20.0);
    expect(totals['USD']!.annual, 240.0);
    expect(totals['EUR']!.monthly, closeTo(9.99, 0.001));
  });

  test('weekly is annualized 52/12', () {
    final totals = monthlyAndAnnualByCurrency([
      sub(currency: 'USD', cycle: BillingCycle.weekly, cost: 4),
    ]);
    expect(totals['USD']!.monthly, closeTo(17.33, 0.01));
    expect(totals['USD']!.annual, closeTo(208.0, 0.01));
  });

  test('inactive subscriptions are excluded', () {
    final totals = monthlyAndAnnualByCurrency([
      sub(currency: 'USD', cycle: BillingCycle.monthly, cost: 10, active: false),
    ]);
    expect(totals, isEmpty);
  });

  test('empty list yields empty map', () {
    expect(monthlyAndAnnualByCurrency([]), isEmpty);
  });
}
