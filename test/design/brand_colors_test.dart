import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subtracker/core/brand/brand_colors.dart';
import 'package:subtracker/features/subscriptions/data/subscription_repository.dart';
import 'package:subtracker/features/subscriptions/domain/billing_cycle.dart';
import 'package:subtracker/features/subscriptions/domain/subscription.dart';
import 'package:subtracker/features/subscriptions/domain/subscription_draft.dart';

Subscription _sub(String name, {String? brandColor}) => Subscription(
      id: name.toLowerCase().replaceAll(' ', '-'),
      name: name,
      cost: 10,
      currency: 'USD',
      billingCycle: BillingCycle.monthly,
      nextChargeDate: DateTime(2026, 10, 1),
      trialEndsAt: null,
      reminderDaysBefore: 3,
      active: true,
      createdAt: null,
      brandColor: brandColor,
    );

void main() {
  test('matches known brands case-insensitively', () {
    expect(brandColorFor(_sub('Netflix')), const Color(0xFFE50914));
    expect(brandColorFor(_sub('NETFLIX Premium')), const Color(0xFFE50914));
    expect(brandColorFor(_sub('my spotify family')), const Color(0xFF1DB954));
  });

  test('unknown names fall back to Other gray', () {
    expect(brandColorFor(_sub("Bob's Gym")), otherColor);
  });

  test('manual override wins over the table', () {
    expect(brandColorFor(_sub('Netflix', brandColor: '00C4CC')),
        const Color(0xFF00C4CC));
  });

  test('hexToStore round-trips', () {
    expect(hexToStore(0xFF00C4CC), '00C4CC');
    expect(hexToStore(null), isNull);
  });

  test('brandColor persists through the repository', () async {
    final db = FakeFirebaseFirestore();
    final repo = SubscriptionRepository(db, 'u1');
    await repo.add(SubscriptionDraft(
      name: 'Bob\'s Gym',
      cost: 25,
      currency: 'USD',
      billingCycle: BillingCycle.monthly,
      nextChargeDate: DateTime(2027, 1, 1),
      trialEndsAt: null,
      reminderDaysBefore: 3,
      brandColor: '00C4CC',
    ));

    final stored = (await repo.watchAll().first).single;
    expect(stored.brandColor, '00C4CC');
    expect(brandColorFor(stored), const Color(0xFF00C4CC));
  });

  test('documents without brandColor stay null (auto-match)', () async {
    final db = FakeFirebaseFirestore();
    final repo = SubscriptionRepository(db, 'u1');
    await repo.add(SubscriptionDraft(
      name: 'Netflix',
      cost: 10,
      currency: 'USD',
      billingCycle: BillingCycle.monthly,
      nextChargeDate: DateTime(2027, 1, 1),
      trialEndsAt: null,
      reminderDaysBefore: 3,
    ));
    final stored = (await repo.watchAll().first).single;
    expect(stored.brandColor, isNull);
    expect(brandColorFor(stored), const Color(0xFFE50914)); // auto-match
  });
}
