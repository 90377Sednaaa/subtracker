import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:subtracker/core/brand/brand.dart';
import 'package:subtracker/core/brand/brand_colors.dart';
import 'package:subtracker/core/theme.dart';
import 'package:subtracker/features/subscriptions/domain/subscription.dart';
/// The ledger row: brand dot, name + renewal line, right-aligned tabular
/// cost. Geometry is asserted by test/ui/ledger_card_test.dart — change
/// tokens, not magic numbers here.
class SubscriptionCard extends StatelessWidget {
  const SubscriptionCard({
    super.key,
    required this.subscription,
    required this.dateFormat,
  });

  final Subscription subscription;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    final colors = context.sublyColors;
    return Hero(
      tag: 'sub-${subscription.id}',
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(SublySpace.radiusCard),
          onTap: () => context.push('/subs/${subscription.id}/edit'),
          child: Padding(
            padding: const EdgeInsets.all(SublySpace.s16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: SublySpace.rowHeight - 32),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: BrandTile(
                        name: subscription.name,
                        color: brandColorFor(subscription),
                        size: 22),
                  ),
                  const SizedBox(width: SublySpace.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          subscription.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: SublyTypography.titleM.copyWith(
                            fontSize: 16,
                            color: colors.inkPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subscription.trialing
                              ? 'Trial ends ${dateFormat.format(subscription.trialEndsAt!)}'
                              : 'Renews ${dateFormat.format(subscription.nextChargeDate)} · ${subscription.billingCycle.name}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: SublyTypography.caption.copyWith(
                            fontSize: 12,
                            color: subscription.trialing
                                ? colors.statusTrial
                                : colors.inkSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: SublySpace.s12),
                  Text(
                    '${subscription.currency} ${subscription.cost.toStringAsFixed(2)}',
                    key: Key('cost-${subscription.id}'),
                    style: SublyTypography.moneyRow.copyWith(
                      fontSize: 15,
                      color: colors.inkPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
