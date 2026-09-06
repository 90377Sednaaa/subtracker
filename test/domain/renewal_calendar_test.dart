import 'package:flutter_test/flutter_test.dart';
import 'package:subtracker/features/subscriptions/domain/billing_cycle.dart';
import 'package:subtracker/features/subscriptions/domain/renewal_calendar.dart';
import 'package:subtracker/features/subscriptions/domain/subscription.dart';

Subscription _sub(
  String id,
  BillingCycle cycle,
  DateTime nextCharge, {
  bool active = true,
}) =>
    Subscription(
      id: id,
      name: id,
      cost: 10,
      currency: 'USD',
      billingCycle: cycle,
      nextChargeDate: nextCharge,
      trialEndsAt: null,
      reminderDaysBefore: 3,
      active: active,
      createdAt: null,
    );

void main() {
  // October 2026: 31 days, starts on a Thursday.
  final oct = DateTime(2026, 10);

  test('lands a monthly renewal on its charge day', () {
    final map = renewalsByDay([_sub('a', BillingCycle.monthly, DateTime(2026, 10, 3))], oct);
    expect(map[3], hasLength(1));
    expect(map.keys, hasLength(1));
  });

  test('projects weekly renewals across the whole month', () {
    final map = renewalsByDay([_sub('w', BillingCycle.weekly, DateTime(2026, 10, 2))], oct);
    // Oct 2, 9, 16, 23, 30 — five Fridays.
    expect(map[2] ?? [], isNotEmpty);
    expect(map[9] ?? [], isNotEmpty);
    expect(map[16] ?? [], isNotEmpty);
    expect(map[23] ?? [], isNotEmpty);
    expect(map[30] ?? [], isNotEmpty);
    expect(map.length, 5);
  });

  test('catches up subscriptions whose next charge is before the month', () {
    final map = renewalsByDay([_sub('old', BillingCycle.monthly, DateTime(2026, 7, 15))], oct);
    expect(map[15], hasLength(1)); // lands on Oct 15
  });

  test('annual cycles appear at most once per month', () {
    final map = renewalsByDay([_sub('y', BillingCycle.annual, DateTime(2025, 10, 12))], oct);
    expect(map[12], hasLength(1));
    expect(map.length, 1);
  });

  test('inactive subscriptions never appear', () {
    final map = renewalsByDay(
        [_sub('off', BillingCycle.monthly, DateTime(2026, 10, 3), active: false)], oct);
    expect(map, isEmpty);
  });

  test('multi-renewal days accumulate lists', () {
    final map = renewalsByDay([
      _sub('a', BillingCycle.monthly, DateTime(2026, 10, 3)),
      _sub('b', BillingCycle.monthly, DateTime(2026, 10, 3)),
      _sub('c', BillingCycle.weekly, DateTime(2026, 10, 3)),
    ], oct);
    expect(map[3], hasLength(3));
  });

  test('dailyRenewals returns null for empty days', () {
    final map = renewalsByDay([_sub('a', BillingCycle.monthly, DateTime(2026, 10, 3))], oct);
    expect(dailyRenewals(map, 4), isNull);
    expect(dailyRenewals(map, 3), hasLength(1));
  });
}
