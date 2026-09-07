import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
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
    this.onMarkPaid,
    this.onDelete,
  });

  final Subscription subscription;
  final DateFormat dateFormat;
  final Future<void> Function(Subscription sub)? onMarkPaid;
  final Future<void> Function(Subscription sub)? onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.sublyColors;

    final card = Hero(
      tag: 'sub-${subscription.id}',
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(SublySpace.radiusCard),
          onTap: () => context.push('/subs/${subscription.id}/edit'),
          child: Padding(
            padding: const EdgeInsets.all(SublySpace.s16),
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(minHeight: SublySpace.rowHeight - 32),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: BrandTile(
                      name: subscription.name,
                      color: brandColorFor(subscription),
                      category: subscription.category,
                      size: 22,
                    ),
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
                          !subscription.active
                              ? 'Canceled'
                              : subscription.trialing
                                  ? 'Trial ends ${dateFormat.format(subscription.trialEndsAt!)}'
                                  : 'Renews ${dateFormat.format(subscription.nextChargeDate)} · ${subscription.billingCycle.name}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: SublyTypography.caption.copyWith(
                            fontSize: 12,
                            color: !subscription.active
                                ? colors.inkTertiary
                                : subscription.trialing
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
                      color: !subscription.active
                          ? colors.inkTertiary
                          : colors.inkPrimary,
                      decoration: !subscription.active
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (onMarkPaid == null && onDelete == null) {
      return card;
    }

    return Dismissible(
      key: Key('dismissible-${subscription.id}'),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981), // Emerald
          borderRadius: BorderRadius.circular(SublySpace.radiusCard),
        ),
        child: const Row(
          children: [
            Icon(LucideIcons.check, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Mark Paid',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: colors.statusRenewalSoon,
          borderRadius: BorderRadius.circular(SublySpace.radiusCard),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            SizedBox(width: 8),
            Icon(LucideIcons.trash, color: Colors.white, size: 20),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          HapticFeedback.mediumImpact();
          if (onMarkPaid != null) {
            await onMarkPaid!(subscription);
          }
          return false;
        } else if (direction == DismissDirection.endToStart) {
          HapticFeedback.heavyImpact();
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: colors.step2,
              title: Text('Delete ${subscription.name}?',
                  style: TextStyle(color: colors.inkPrimary)),
              content: Text(
                'This will permanently remove ${subscription.name} from your ledger.',
                style: TextStyle(color: colors.inkSecondary),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child:
                      Text('Cancel', style: TextStyle(color: colors.inkTertiary)),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.statusRenewalSoon,
                  ),
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Delete'),
                ),
              ],
            ),
          );
          if (confirmed == true && onDelete != null) {
            await onDelete!(subscription);
            return true;
          }
          return false;
        }
        return false;
      },
      child: card,
    );
  }
}
