import 'package:cloud_firestore/cloud_firestore.dart';
import 'billing_cycle.dart';

class Subscription {
  const Subscription({
    required this.id,
    required this.name,
    required this.cost,
    required this.currency,
    required this.billingCycle,
    required this.nextChargeDate,
    required this.trialEndsAt,
    required this.reminderDaysBefore,
    required this.active,
    required this.createdAt,
    this.brandColor,
    this.category = 'Other',
    this.notes = '',
  });

  final String id;
  final String name;
  final double cost;
  final String currency;
  final BillingCycle billingCycle;
  final DateTime nextChargeDate;
  final DateTime? trialEndsAt;
  final int reminderDaysBefore;
  final bool active;
  final DateTime? createdAt;

  /// Manual brand-color override (hex like '1DB954'); null = auto-match.
  final String? brandColor;

  final String category;
  final String notes;

  bool get trialing =>
      trialEndsAt != null && trialEndsAt!.isAfter(DateTime.now());

  static Subscription fromMap(String id, Map<String, dynamic> map) {
    return Subscription(
      id: id,
      name: map['name'] as String,
      cost: (map['cost'] as num).toDouble(),
      currency: map['currency'] as String,
      billingCycle: parseBillingCycle(map['billingCycle'] as String),
      nextChargeDate: (map['nextChargeDate'] as Timestamp).toDate(),
      trialEndsAt: map['trialEndsAt'] == null
          ? null
          : (map['trialEndsAt'] as Timestamp).toDate(),
      reminderDaysBefore: (map['reminderDaysBefore'] as num?)?.toInt() ?? 3,
      active: map['active'] as bool? ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      brandColor: map['brandColor'] as String?,
      category: map['category'] as String? ?? 'Other',
      notes: map['notes'] as String? ?? '',
    );
  }
}
