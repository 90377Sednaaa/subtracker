import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:subtracker/core/brand/brand_colors.dart';
import 'package:subtracker/core/theme.dart';
import 'package:subtracker/features/subscriptions/domain/subscription.dart';

/// "NEXT 7 DAYS" — horizontal chips of upcoming renewals. The alert value
/// prop, visible without scrolling. Chips <3 days out carry the
/// renewal-soon status tint on their hairline.
class RenewalStrip extends StatelessWidget {
  const RenewalStrip({super.key, required this.upcoming, required this.now});

  final List<Subscription> upcoming;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
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
            height: 112,
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
                  urgent: urgent,
                  urgentColor: colors.statusRenewalSoon,
                  brandColor: brandColorFor(sub),
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
    required this.urgent,
    required this.urgentColor,
    required this.brandColor,
  });

  final String weekday;
  final String day;
  final String name;
  final String amount;
  final bool urgent;
  final Color urgentColor;
  final Color brandColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.sublyColors;
    return Container(
      width: 108,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.step2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: urgent ? urgentColor : colors.hairline,
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
            padding:
                const EdgeInsets.fromLTRB(15, SublySpace.s12, SublySpace.s12, SublySpace.s12),
            child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(weekday,
                  style: SublyTypography.caption
                      .copyWith(color: colors.inkTertiary)),
              const Spacer(),
              Text(day,
                  style: SublyTypography.titleM
                      .copyWith(color: colors.inkPrimary)),
            ],
          ),
          const Spacer(),
          Text(name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: SublyTypography.body.copyWith(color: colors.inkPrimary)),
          Text(amount,
              style: SublyTypography.caption
                  .copyWith(color: colors.inkSecondary)),
        ],
          ),
        ),
        ],
      ),
    );
  }
}
