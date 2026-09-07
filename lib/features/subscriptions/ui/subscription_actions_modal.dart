import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:subtracker/core/brand/brand.dart';
import 'package:subtracker/core/brand/brand_colors.dart';
import 'package:subtracker/core/theme.dart';
import 'package:subtracker/features/subscriptions/data/subscription_repository.dart';
import 'package:subtracker/features/subscriptions/domain/billing_cycle.dart';
import 'package:subtracker/features/subscriptions/domain/subscription.dart';
import 'package:subtracker/features/subscriptions/domain/subscription_draft.dart';

/// Bottom sheet modal offering quick actions for a subscription:
/// - Overview with BrandTile, name, renewal date, and cost
/// - Mark Paid / Advance Cycle
/// - Edit Subscription
void showSubscriptionActionsModal({
  required BuildContext context,
  required WidgetRef ref,
  required Subscription sub,
  required SublyColors colors,
}) {
  HapticFeedback.lightImpact();
  final dateFormat = DateFormat.yMMMd();
  final brandColor = brandColorFor(sub);

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: colors.step2,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(SublySpace.radiusSheet),
      ),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(SublySpace.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.hairline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: SublySpace.s16),
            Row(
              children: [
                BrandTile(
                  name: sub.name,
                  color: brandColor,
                  category: sub.category,
                  size: 36,
                ),
                const SizedBox(width: SublySpace.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sub.name,
                        style: SublyTypography.titleL.copyWith(
                          color: colors.inkPrimary,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        'Renews ${dateFormat.format(sub.nextChargeDate)} · ${sub.currency} ${sub.cost.toStringAsFixed(2)}',
                        style: SublyTypography.caption
                            .copyWith(color: colors.inkSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: SublySpace.s24),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.check,
                    color: Color(0xFF10B981), size: 20),
              ),
              title: Text(
                'Mark Paid / Advance Cycle',
                style: SublyTypography.body.copyWith(
                  color: colors.inkPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Move renewal date to next ${sub.billingCycle.name} cycle',
                style: SublyTypography.caption
                    .copyWith(color: colors.inkTertiary),
              ),
              onTap: () async {
                Navigator.of(ctx).pop();
                HapticFeedback.mediumImpact();
                final nextDate = sub.billingCycle.advance(sub.nextChargeDate);
                final draft = SubscriptionDraft(
                  name: sub.name,
                  cost: sub.cost,
                  currency: sub.currency,
                  billingCycle: sub.billingCycle,
                  nextChargeDate: nextDate,
                  trialEndsAt: null,
                  reminderDaysBefore: sub.reminderDaysBefore,
                  brandColor: sub.brandColor,
                  category: sub.category,
                  notes: sub.notes,
                );
                await ref
                    .read(subscriptionRepositoryProvider)
                    .update(sub.id, draft);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Advanced ${sub.name} to ${dateFormat.format(nextDate)}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
            Divider(color: colors.hairline, height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.step3,
                  shape: BoxShape.circle,
                ),
                child:
                    Icon(LucideIcons.pencil, color: colors.inkPrimary, size: 20),
              ),
              title: Text(
                'Edit Subscription',
                style: SublyTypography.body.copyWith(
                  color: colors.inkPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Modify cost, cycle, reminder settings',
                style: SublyTypography.caption
                    .copyWith(color: colors.inkTertiary),
              ),
              onTap: () {
                Navigator.of(ctx).pop();
                context.push('/subs/${sub.id}/edit');
              },
            ),
            Divider(color: colors.hairline, height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (sub.active
                          ? colors.statusRenewalSoon
                          : const Color(0xFF10B981))
                      .withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  sub.active ? LucideIcons.ban : LucideIcons.rotate_cw,
                  color: sub.active
                      ? colors.statusRenewalSoon
                      : const Color(0xFF10B981),
                  size: 20,
                ),
              ),
              title: Text(
                sub.active ? 'Mark as Canceled' : 'Reactivate Subscription',
                style: SublyTypography.body.copyWith(
                  color: colors.inkPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                sub.active
                    ? 'Pause tracking and remove from total spend'
                    : 'Resume tracking and renewal alerts',
                style: SublyTypography.caption
                    .copyWith(color: colors.inkTertiary),
              ),
              onTap: () async {
                Navigator.of(ctx).pop();
                HapticFeedback.mediumImpact();
                await ref
                    .read(subscriptionRepositoryProvider)
                    .setActive(sub.id, !sub.active);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(sub.active
                          ? 'Marked ${sub.name} as canceled'
                          : 'Reactivated ${sub.name}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: SublySpace.s8),
          ],
        ),
      ),
    ),
  );
}
