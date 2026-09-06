import 'package:flutter_test/flutter_test.dart';
import 'package:subtracker/features/premium/logic/csv_export.dart';
import 'package:subtracker/features/subscriptions/domain/billing_cycle.dart';
import 'package:subtracker/features/subscriptions/domain/subscription.dart';

Subscription _s(String name, {String currency = 'USD'}) => Subscription(
      id: 'x-$name',
      name: name,
      cost: 9.99,
      currency: currency,
      billingCycle: BillingCycle.monthly,
      nextChargeDate: DateTime(2026, 10, 1),
      trialEndsAt: DateTime(2026, 9, 20),
      reminderDaysBefore: 3,
      active: true,
      createdAt: null,
    );

void main() {
  test('csv has header and one row per subscription', () {
    final csv = subscriptionsToCsv([_s('Netflix'), _s('Hulu')]);
    final lines = csv.trim().split('\n');
    expect(lines.first,
        'name,cost,currency,billing_cycle,next_charge,trial_end');
    expect(lines, hasLength(3));
    expect(lines[1], contains('Netflix'));
    expect(lines[1], contains('2026-10-01'));
  });

  test('fields containing commas are quoted', () {
    final csv = subscriptionsToCsv([_s('Prime, Video')]);
    expect(csv, contains('"Prime, Video"'));
  });
}
