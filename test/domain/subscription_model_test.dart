import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subtracker/features/subscriptions/domain/billing_cycle.dart';
import 'package:subtracker/features/subscriptions/domain/subscription.dart';
import 'package:subtracker/features/subscriptions/domain/subscription_draft.dart';

void main() {
  test('SubscriptionDraft supports category and notes with defaults', () {
    final draft = SubscriptionDraft(
      name: 'Netflix',
      cost: 15.49,
      currency: 'USD',
      billingCycle: BillingCycle.monthly,
      nextChargeDate: DateTime(2026, 10, 1),
      trialEndsAt: null,
      reminderDaysBefore: 3,
    );
    expect(draft.category, 'Other');
    expect(draft.notes, '');

    final customDraft = SubscriptionDraft(
      name: 'Cursor',
      cost: 20.0,
      currency: 'USD',
      billingCycle: BillingCycle.monthly,
      nextChargeDate: DateTime(2026, 10, 1),
      trialEndsAt: null,
      reminderDaysBefore: 3,
      category: 'Utilities',
      notes: 'Work account',
    );
    expect(customDraft.category, 'Utilities');
    expect(customDraft.notes, 'Work account');
  });

  test('Subscription.fromMap deserializes category and notes safely with defaults', () {
    final mapWithoutExtras = {
      'name': 'Spotify',
      'cost': 11.99,
      'currency': 'EUR',
      'billingCycle': 'monthly',
      'nextChargeDate': Timestamp.fromDate(DateTime(2026, 10, 1)),
      'trialEndsAt': null,
      'reminderDaysBefore': 3,
      'active': true,
    };
    final sub1 = Subscription.fromMap('sub1', mapWithoutExtras);
    expect(sub1.category, 'Other');
    expect(sub1.notes, '');

    final mapWithExtras = {
      ...mapWithoutExtras,
      'category': 'Music',
      'notes': 'Family plan',
    };
    final sub2 = Subscription.fromMap('sub2', mapWithExtras);
    expect(sub2.category, 'Music');
    expect(sub2.notes, 'Family plan');
  });
}
