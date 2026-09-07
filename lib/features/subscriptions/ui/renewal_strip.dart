import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:subtracker/core/brand/brand.dart';
import 'package:subtracker/core/brand/brand_colors.dart';
import 'package:subtracker/core/theme.dart';
import 'package:subtracker/features/subscriptions/data/subscription_repository.dart';
import 'package:subtracker/features/subscriptions/domain/billing_cycle.dart';
import 'package:subtracker/features/subscriptions/domain/subscription.dart';
import 'package:subtracker/features/subscriptions/domain/subscription_draft.dart';

/// "NEXT 7 DAYS" — horizontal chips of upcoming renewals. The alert value
/// prop, visible without scrolling. Chips <3 days out carry the
/// renewal-soon status tint on their hairline.
class RenewalStrip extends ConsumerWidget {
  const RenewalStrip({super.key, required this.upcoming, required this.now});

  final List<Subscription> upcoming;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.sublyColors;
    final today = DateTime(now.year, now.month, now.day);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: SublySpace.screenMargin),
          child: Text('NEXT 7 DAYS',
              style:
                  SublyTypography.label.copyWith(color: colors.inkTertiary)),
        ),
        const SizedBox(height: SublySpace.s12),
        if (upcoming.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: SublySpace.screenMargin),
            child: Text('Nothing renews this week.',
                key: const Key('renewal-empty'),
                style: SublyTypography.body
                    .copyWith(color: colors.inkTertiary)),
          )
        else
          SizedBox(
            height: 116,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: SublySpace.screenMargin),
              itemCount: upcoming.length,
              separatorBuilder: (_, _) => const SizedBox(width: SublySpace.s12),
              itemBuilder: (context, i) {
                final sub = upcoming[i];
                final daysOut =
                    sub.nextChargeDate.difference(today).inDays;
                final urgent = daysOut < 3;
                return _RenewalChip(
                  key: Key('renewal-chip-${sub.id}'),
                  weekday: DateFormat.E().format(sub.nextChargeDate),
                  day: sub.nextChargeDate.day.toString(),
                  name: sub.name,
                  amount:
                      '${sub.currency} ${sub.cost.toStringAsFixed(2)}',
                  daysOut: daysOut,
                  urgent: urgent,
                  urgentColor: colors.statusRenewalSoon,
                  brandColor: brandColorFor(sub),
                  onTap: () => _showRenewalActions(context, ref, sub, colors),
                );
              },
            ),
          ),
      ],
    );
  }

  void _showRenewalActions(BuildContext context, WidgetRef ref,
      Subscription sub, SublyColors colors) {
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
                  final nextDate =
                      sub.billingCycle.advance(sub.nextChargeDate);
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
                  child: Icon(LucideIcons.pencil,
                      color: colors.inkPrimary, size: 20),
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
              const SizedBox(height: SublySpace.s8),
            ],
          ),
        ),
      ),
    );
  }
}

class _RenewalChip extends StatelessWidget {
  const _RenewalChip({
    super.key,
    required this.weekday,
    required this.day,
    required this.name,
    required this.amount,
    required this.daysOut,
    required this.urgent,
    required this.urgentColor,
    required this.brandColor,
    this.onTap,
  });

  final String weekday;
  final String day;
  final String name;
  final String amount;
  final int daysOut;
  final bool urgent;
  final Color urgentColor;
  final Color brandColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.sublyColors;
    final countdown = daysOut == 0
        ? 'Today'
        : daysOut == 1
            ? 'Tomorrow'
            : 'In ${daysOut}d';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 124,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colors.step2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: urgent ? urgentColor : colors.hairline,
            width: urgent ? 1.5 : 1.0,
          ),
        ),
        child: Stack(
          children: [
            // The brand-color left edge: the strip's thread of chroma,
            // clipped to the pill shape.
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(width: 3, color: brandColor),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  15, SublySpace.s12, SublySpace.s12, SublySpace.s12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: urgent
                              ? urgentColor.withValues(alpha: 0.15)
                              : colors.step3,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          countdown,
                          style: SublyTypography.caption.copyWith(
                            color: urgent ? urgentColor : colors.inkTertiary,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        day,
                        style: SublyTypography.titleM.copyWith(
                          color: colors.inkPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SublyTypography.body
                        .copyWith(color: colors.inkPrimary),
                  ),
                  Text(
                    amount,
                    style: SublyTypography.caption
                        .copyWith(color: colors.inkSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
