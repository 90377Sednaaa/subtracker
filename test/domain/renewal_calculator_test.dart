import 'package:flutter_test/flutter_test.dart';
import 'package:subtracker/features/subscriptions/domain/billing_cycle.dart';
import 'package:subtracker/features/subscriptions/domain/renewal_calculator.dart';

void main() {
  group('advance (one cycle)', () {
    test('weekly adds 7 days', () {
      expect(
        BillingCycle.weekly.advance(DateTime(2026, 9, 6)),
        DateTime(2026, 9, 13),
      );
    });

    test('monthly clamps month-end: Jan 31 -> Feb 28 (2027 non-leap)', () {
      expect(
        BillingCycle.monthly.advance(DateTime(2027, 1, 31)),
        DateTime(2027, 2, 28),
      );
    });

    test('monthly clamps to Feb 29 in a leap year', () {
      expect(
        BillingCycle.monthly.advance(DateTime(2028, 1, 31)),
        DateTime(2028, 2, 29),
      );
    });

    test('annual crosses the year', () {
      expect(
        BillingCycle.annual.advance(DateTime(2026, 9, 6)),
        DateTime(2027, 9, 6),
      );
    });
  });

  group('advanceToDate (catch-up)', () {
    test('advances a long-overdue monthly date past now', () {
      final now = DateTime(2026, 9, 6);
      final next = RenewalCalculator.advanceToDate(
          DateTime(2026, 1, 10), BillingCycle.monthly, now);
      expect(next.isAfter(now), isTrue);
      expect(next.day, 10);
    });

    test('keeps future dates untouched', () {
      final now = DateTime(2026, 9, 6);
      expect(
        RenewalCalculator.advanceToDate(
            DateTime(2026, 12, 1), BillingCycle.monthly, now),
        DateTime(2026, 12, 1),
      );
    });
  });

  group('monthlyEquivalent', () {
    test('weekly cost is annualized over 52 weeks', () {
      expect(BillingCycle.weekly.monthlyEquivalent(4), closeTo(17.33, 0.01));
    });
    test('annual cost divides by 12', () {
      expect(BillingCycle.annual.monthlyEquivalent(120), 10.0);
    });
  });

  group('planFireDate', () {
    final now = DateTime(2026, 9, 6, 12);

    test('fires reminderDaysBefore at 09:00 local', () {
      final fire = RenewalCalculator.planFireDate(
        nextChargeDate: DateTime(2026, 9, 20),
        trialing: false,
        reminderDaysBefore: 3,
        now: now,
      );
      expect(fire, DateTime(2026, 9, 17, 9));
    });

    test('returns null when the fire date is already past', () {
      final fire = RenewalCalculator.planFireDate(
        nextChargeDate: DateTime(2026, 9, 8),
        trialing: false,
        reminderDaysBefore: 3,
        now: now,
      );
      expect(fire, isNull); // Sep 5 09:00 is before Sep 6 12:00
    });

    test('trialing subscriptions fire before trial end', () {
      final fire = RenewalCalculator.planFireDate(
        nextChargeDate: DateTime(2026, 9, 30), // == trialEndsAt
        trialing: true,
        reminderDaysBefore: 3,
        now: now,
      );
      expect(fire, DateTime(2026, 9, 27, 9));
    });
  });
}
