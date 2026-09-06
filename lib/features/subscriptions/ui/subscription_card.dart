import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:subtracker/features/subscriptions/domain/subscription.dart';

class SubscriptionCard extends StatelessWidget {
  const SubscriptionCard(
      {super.key, required this.subscription, required this.dateFormat});

  final Subscription subscription;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        title: Text(subscription.name),
        subtitle: Text(subscription.trialing
            ? 'Trial ends ${dateFormat.format(subscription.trialEndsAt!)}'
            : 'Renews ${dateFormat.format(subscription.nextChargeDate)} · ${subscription.billingCycle.name}'),
        trailing: Text(
          '${subscription.currency} ${subscription.cost.toStringAsFixed(2)}',
          style: theme.textTheme.titleMedium,
        ),
      ),
    );
  }
}
