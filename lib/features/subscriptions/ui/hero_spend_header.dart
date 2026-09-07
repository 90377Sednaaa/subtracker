import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:subtracker/core/theme.dart';

/// The dashboard's first screen: label → animated monthly total → annual
/// caption, with the month-pace ring at the right edge and a single faint
/// radial glow behind the number. Totals are per-currency; the currency with
/// the largest monthly total is the hero, the rest render as secondary rows.
class HeroSpendHeader extends StatelessWidget {
  const HeroSpendHeader({
    super.key,
    required this.totals,
    required this.subCount,
    required this.now,
  });

  final Map<String, ({double monthly, double annual})> totals;
  final int subCount;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final colors = context.sublyColors;
    if (totals.isEmpty) {
      return const SizedBox(height: 8);
    }
    final hero = totals.entries
        .reduce((a, b) => a.value.monthly >= b.value.monthly ? a : b);
    final others =
        totals.entries.where((e) => e.key != hero.key).toList();
    final format = NumberFormat.simpleCurrency(decimalDigits: 2, name: hero.key);
    final annualFormat =
        NumberFormat.simpleCurrency(decimalDigits: 0, name: hero.key);

    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SublySpace.screenMargin,
        SublySpace.s16,
        SublySpace.screenMargin,
        SublySpace.s24,
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _showSpendBreakdown(
          context,
          colors,
          hero,
          others,
          subCount,
          now,
          format,
          annualFormat,
          daysInMonth,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'THIS MONTH',
                  style: SublyTypography.label
                      .copyWith(color: colors.inkTertiary),
                ),
                const SizedBox(width: SublySpace.s8),
                Icon(
                  Icons.info_outline,
                  size: 13,
                  color: colors.inkTertiary.withValues(alpha: 0.6),
                ),
              ],
            ),
            const SizedBox(height: SublySpace.s8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      // The one glow: a faint radial behind the number.
                      Positioned.fill(
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                radius: 0.9,
                                colors: [colors.glow, colors.glow.withValues(alpha: 0)],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // FittedBox guards the 56dp face against narrow screens
                      // without ever letting the number wrap or overflow.
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: hero.value.monthly),
                        duration: SublyMotion.durHero,
                        curve: SublyMotion.curveStandard,
                        builder: (context, value, _) => FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            format.format(value),
                            key: const Key('hero-money'),
                            style: SublyTypography.heroMoney
                                .copyWith(color: colors.inkPrimary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: SublySpace.s16),
                _PaceRing(
                  key: const Key('hero-ring'),
                  size: 96,
                  fraction: _monthProgress(now),
                  track: colors.hairline,
                  progress: colors.inkPrimary,
                  daysElapsed: now.day,
                  daysTotal: daysInMonth,
                ),
              ],
            ),
            const SizedBox(height: SublySpace.s12),
            Text(
              '${others.isEmpty ? '' : 'plus ${others.length} other currenc${others.length == 1 ? 'y' : 'ies'} · '}'
              '≈ ${annualFormat.format(hero.value.annual)}/year across $subCount subscriptions',
              key: const Key('hero-caption'),
              style: SublyTypography.caption.copyWith(color: colors.inkTertiary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            for (final e in others)
              Padding(
                padding: const EdgeInsets.only(top: SublySpace.s4),
                child: Text(
                  '${e.key} ${NumberFormat.simpleCurrency(decimalDigits: 2, name: e.key).format(e.value.monthly)}/mo',
                  style: SublyTypography.titleM.copyWith(
                    fontSize: 16,
                    color: colors.inkSecondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    )
        .animate()
        .fade(duration: SublyMotion.durBase, curve: SublyMotion.curveStandard)
        .slideY(begin: 0.05, end: 0, duration: SublyMotion.durBase);
  }

  void _showSpendBreakdown(
    BuildContext context,
    SublyColors colors,
    MapEntry<String, ({double monthly, double annual})> hero,
    List<MapEntry<String, ({double monthly, double annual})>> others,
    int subCount,
    DateTime now,
    NumberFormat format,
    NumberFormat annualFormat,
    int daysInMonth,
  ) {
    HapticFeedback.lightImpact();
    final daily = hero.value.monthly / daysInMonth;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.step2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(SublySpace.radiusSheet)),
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
              Text(
                'Monthly Spend Breakdown',
                style: SublyTypography.titleL.copyWith(color: colors.inkPrimary),
              ),
              const SizedBox(height: SublySpace.s16),
              _breakdownRow(colors, 'Monthly commitment',
                  format.format(hero.value.monthly)),
              _breakdownRow(colors, 'Daily average burn',
                  '${format.format(daily)} / day'),
              _breakdownRow(colors, 'Projected annual cost',
                  '${annualFormat.format(hero.value.annual)} / year'),
              _breakdownRow(
                  colors, 'Active subscriptions', '$subCount'),
              _breakdownRow(colors, 'Cycle progress',
                  '${now.day} of $daysInMonth days (${(_monthProgress(now) * 100).round()}%)'),
              if (others.isNotEmpty) ...[
                const SizedBox(height: SublySpace.s12),
                Divider(color: colors.hairline),
                const SizedBox(height: SublySpace.s8),
                Text(
                  'Other Currencies',
                  style: SublyTypography.label
                      .copyWith(color: colors.inkTertiary),
                ),
                for (final e in others)
                  _breakdownRow(
                    colors,
                    e.key,
                    '${NumberFormat.simpleCurrency(decimalDigits: 2, name: e.key).format(e.value.monthly)}/mo',
                  ),
              ],
              const SizedBox(height: SublySpace.s16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _breakdownRow(SublyColors colors, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SublySpace.s8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: SublyTypography.body.copyWith(color: colors.inkSecondary),
          ),
          Text(
            value,
            style: SublyTypography.titleM.copyWith(
              color: colors.inkPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  /// Fraction of the current billing month elapsed (0..1). When every
  /// subscription bills annually, the year plays the same role.
  static double _monthProgress(DateTime now) {
    final monthStart = DateTime(now.year, now.month);
    final monthNext = DateTime(now.year, now.month + 1);
    return (now.difference(monthStart).inDays /
            monthNext.difference(monthStart).inDays)
        .clamp(0.0, 1.0);
  }
}

/// Month-pace ring: hairline track, round-capped ink progress arc with centered tabular stat.
class _PaceRing extends StatelessWidget {
  const _PaceRing({
    super.key,
    required this.size,
    required this.fraction,
    required this.track,
    required this.progress,
    this.daysElapsed,
    this.daysTotal,
  });

  final double size;
  final double fraction;
  final Color track;
  final Color progress;
  final int? daysElapsed;
  final int? daysTotal;

  @override
  Widget build(BuildContext context) {
    final colors = context.sublyColors;
    final percent = (fraction.clamp(0.0, 1.0) * 100).round();
    final remaining = (daysTotal != null && daysElapsed != null)
        ? (daysTotal! - daysElapsed!).clamp(0, daysTotal!)
        : null;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _PaceRingPainter(
              fraction: fraction,
              track: track,
              progress: progress,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$percent%',
                style: SublyTypography.titleM.copyWith(
                  color: colors.inkPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              if (remaining != null)
                Text(
                  '${remaining}d left',
                  style: SublyTypography.caption.copyWith(
                    color: colors.inkTertiary,
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaceRingPainter extends CustomPainter {
  _PaceRingPainter({
    required this.fraction,
    required this.track,
    required this.progress,
  });

  final double fraction;
  final Color track;
  final Color progress;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 3.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(center, radius, Paint()..color = track..style = PaintingStyle.stroke..strokeWidth = stroke);
    final progressPaint = Paint()
      ..color = progress
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, -pi / 2, 2 * pi * fraction, false, progressPaint);
  }

  @override
  bool shouldRepaint(_PaceRingPainter oldDelegate) =>
      oldDelegate.fraction != fraction;
}
