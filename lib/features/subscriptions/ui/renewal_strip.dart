import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:subtracker/core/brand/brand_colors.dart';
import 'package:subtracker/core/theme.dart';
import 'package:subtracker/features/subscriptions/domain/subscription.dart';
import 'package:subtracker/features/subscriptions/ui/subscription_actions_modal.dart';

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
                  onTap: () => showSubscriptionActionsModal(
                    context: context,
                    ref: ref,
                    sub: sub,
                    colors: colors,
                  ),
                );
              },
            ),
          ),
      ],
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
        padding: const EdgeInsets.all(SublySpace.s12),
        decoration: BoxDecoration(
          color: colors.step2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: urgent ? urgentColor.withValues(alpha: 0.6) : colors.hairline,
            width: 1.0,
          ),
        ),
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
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: brandColor,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SublyTypography.body
                        .copyWith(color: colors.inkPrimary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              amount,
              style: SublyTypography.caption
                  .copyWith(color: colors.inkSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
