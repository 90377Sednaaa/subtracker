import 'dart:math';

import 'package:flutter/material.dart';
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SublySpace.screenMargin,
        SublySpace.s16,
        SublySpace.screenMargin,
        SublySpace.s24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('THIS MONTH',
              style: SublyTypography.label
                  .copyWith(color: colors.inkTertiary)),
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
    )
        .animate()
        .fade(duration: SublyMotion.durBase, curve: SublyMotion.curveStandard)
        .slideY(begin: 0.05, end: 0, duration: SublyMotion.durBase);
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

/// Month-pace ring: hairline track, round-capped ink progress arc.
class _PaceRing extends StatelessWidget {
  const _PaceRing({
    super.key,
    required this.size,
    required this.fraction,
    required this.track,
    required this.progress,
  });

  final double size;
  final double fraction;
  final Color track;
  final Color progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _PaceRingPainter(
          fraction: fraction,
          track: track,
          progress: progress,
        ),
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
