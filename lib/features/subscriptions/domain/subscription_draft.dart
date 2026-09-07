import 'billing_cycle.dart';

class SubscriptionDraft {
  const SubscriptionDraft({
    required this.name,
    required this.cost,
    required this.currency,
    required this.billingCycle,
    required this.nextChargeDate,
    required this.trialEndsAt,
    required this.reminderDaysBefore,
    this.brandColor,
    this.category = 'Other',
    this.notes = '',
  });

  final String name;
  final double cost;
  final String currency;
  final BillingCycle billingCycle;
  final DateTime nextChargeDate;
  final DateTime? trialEndsAt;
  final int reminderDaysBefore;

  /// Manual brand-color override (hex without '#'); null = auto-match.
  final String? brandColor;

  final String category;
  final String notes;
}
