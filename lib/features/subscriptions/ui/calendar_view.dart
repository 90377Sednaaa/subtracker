import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:subtracker/core/brand/brand.dart';
import 'package:subtracker/core/brand/brand_colors.dart';
import 'package:subtracker/core/theme.dart';
import 'package:subtracker/features/subscriptions/domain/renewal_calendar.dart';
import 'package:subtracker/features/subscriptions/domain/subscription.dart';

/// Month calendar of projected renewals: each day cell carries the brand
/// lettermarks of the services charging that day ('+N' when more than
/// three). Monday-first; today gets the ink border; tapping a day lists
/// its renewals in a bottom sheet.
class CalendarView extends StatefulWidget {
  const CalendarView({
    super.key,
    required this.subscriptions,
    required this.monthlyTotalByCurrency,
    required this.now,
  });

  final List<Subscription> subscriptions;
  final Map<String, ({double monthly, double annual})> monthlyTotalByCurrency;
  final DateTime now;

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  int _monthOffset = 0;

  DateTime get _displayMonth {
    final now = widget.now;
    return DateTime(now.year, now.month + _monthOffset);
  }

  void _shift(int delta) => setState(() => _monthOffset += delta);

  static const _weekdays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

  @override
  Widget build(BuildContext context) {
    final colors = context.sublyColors;
    final month = _displayMonth;
    final byDay = renewalsByDay(widget.subscriptions, month);
    final today = DateTime(widget.now.year, widget.now.month, widget.now.day);
    final isCurrentMonth = _monthOffset == 0;

    final heroCurrency = widget.monthlyTotalByCurrency.isEmpty
        ? null
        : widget.monthlyTotalByCurrency.entries
            .reduce((a, b) => a.value.monthly >= b.value.monthly ? a : b);
    final totalFormat = NumberFormat.simpleCurrency(
        decimalDigits: 2, name: heroCurrency?.key ?? 'USD');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SublySpace.screenMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: SublySpace.s16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('MMMM, yyyy').format(month),
                      style: SublyTypography.titleL
                          .copyWith(color: colors.inkPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Monthly total: ${heroCurrency == null ? '—' : totalFormat.format(heroCurrency.value.monthly)}',
                      style: SublyTypography.body
                          .copyWith(color: colors.inkSecondary),
                    ),
                  ],
                ),
              ),
              _MonthArrow(
                icon: Icons.chevron_left,
                onTap: () => _shift(-1),
              ),
              const SizedBox(width: SublySpace.s8),
              _MonthArrow(
                icon: Icons.chevron_right,
                onTap: isCurrentMonth ? null : () => _shift(1),
              ),
            ],
          ),
          const SizedBox(height: SublySpace.s16),
          Row(
            children: [
              for (final w in _weekdays)
                Expanded(
                  child: Center(
                    child: Text(w,
                        style: SublyTypography.label
                            .copyWith(color: colors.inkTertiary, fontSize: 11)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: SublySpace.s8),
          // Short screens scroll the grid; cells keep their fixed geometry.
          Expanded(
            child: SingleChildScrollView(
              child: _buildGrid(colors, month, byDay, today),
            ),
          ),
          const SizedBox(height: SublySpace.s16),
        ],
      ),
    );
  }

  Widget _buildGrid(SublyColors colors, DateTime month,
      Map<int, List<Subscription>> byDay, DateTime today) {
    final first = DateTime(month.year, month.month, 1);
    final daysInMonth =
        DateTime(month.year, month.month + 1).difference(first).inDays;
    // Monday-first offset: DateTime.weekday is Mon=1..Sun=7.
    final leading = first.weekday - 1;
    final totalCells = leading + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return LayoutBuilder(builder: (context, constraints) {
      final cellWidth = constraints.maxWidth / 7;
      final cellHeight = cellWidth * 1.16;

      return Column(
        children: [
          for (var r = 0; r < rows; r++)
            Row(
              children: [
                for (var c = 0; c < 7; c++)
                  SizedBox(
                    width: cellWidth,
                    height: cellHeight,
                    child: _cellFor(colors, r, c, leading, daysInMonth, byDay,
                        today, month),
                  ),
              ],
            ),
        ],
      );
    });
  }

  Widget _cellFor(
      SublyColors colors,
      int row,
      int col,
      int leading,
      int daysInMonth,
      Map<int, List<Subscription>> byDay,
      DateTime today,
      DateTime month) {
    final dayNumber = row * 7 + col + 1 - leading;
    if (dayNumber < 1 || dayNumber > daysInMonth) {
      return const SizedBox.shrink();
    }
    final renewals = byDay[dayNumber] ?? const <Subscription>[];
    final date = DateTime(month.year, month.month, dayNumber);
    final isToday = date == today;

    return Padding(
      padding: const EdgeInsets.all(2),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: renewals.isEmpty ? null : () => _showDaySheet(renewals, dayNumber),
        child: Container(
          key: Key('cal-day-$dayNumber'),
          padding: const EdgeInsets.symmetric(
            horizontal: SublySpace.s4,
            vertical: SublySpace.s4,
          ),
          decoration: BoxDecoration(
            color: renewals.isEmpty ? colors.step1 : colors.step2,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isToday ? colors.inkPrimary : colors.hairline,
              width: isToday ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$dayNumber',
                style: SublyTypography.caption.copyWith(
                  color: isToday ? colors.inkPrimary : colors.inkTertiary,
                  fontWeight: isToday ? FontWeight.w700 : null,
                ),
              ),
              if (renewals.isNotEmpty) ...[
                const Spacer(),
                RenewalCluster(renewals: renewals),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showDaySheet(List<Subscription> renewals, int day) {
    final colors = context.sublyColors;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.step3,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(SublySpace.radiusSheet)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(SublySpace.s16),
              child: Text(
                DateFormat('MMMM d').format(DateTime(
                    _displayMonth.year, _displayMonth.month, day)),
                style: SublyTypography.titleM.copyWith(color: colors.inkPrimary),
              ),
            ),
            for (final sub in renewals)
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: SublySpace.s16),
                leading: BrandTile(
                    name: sub.name,
                    color: brandColorFor(sub),
                    size: 30),
                title: Text(sub.name,
                    style: SublyTypography.body.copyWith(
                        color: sheetContext.sublyColors.inkPrimary)),
                trailing: Text(
                  '${sub.currency} ${sub.cost.toStringAsFixed(2)}',
                  style: SublyTypography.moneyRow.copyWith(
                      fontSize: 14,
                      color: sheetContext.sublyColors.inkPrimary),
                ),
              ),
            const SizedBox(height: SublySpace.s8),
          ],
        ),
      ),
    );
  }
}

/// Overlapping avatar stack showing up to 3 brand marks, or 2 marks + '+N' counter.
class RenewalCluster extends StatelessWidget {
  const RenewalCluster({super.key, required this.renewals});

  final List<Subscription> renewals;

  @override
  Widget build(BuildContext context) {
    if (renewals.isEmpty) return const SizedBox.shrink();

    final colors = context.sublyColors;
    const double tileSize = 16.0;
    const double step = 9.0;
    const double borderW = 1.5;

    final int total = renewals.length;
    // Up to 3 renewals: show all (1, 2, or 3 icons).
    // 4 or more renewals: show first 2 icons + '+N' badge.
    final bool hasExtra = total > 3;
    final int visibleIconCount = hasExtra ? 2 : total;
    final int extraCount = total - visibleIconCount;

    final int elementCount = visibleIconCount + (hasExtra ? 1 : 0);
    final double totalWidth = tileSize + (elementCount - 1) * step;

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: totalWidth,
        height: tileSize,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (int i = 0; i < visibleIconCount; i++)
              Positioned(
                left: i * step,
                top: 0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(tileSize * 0.3 + borderW),
                    border: Border.all(
                      color: colors.step2,
                      width: borderW,
                      strokeAlign: BorderSide.strokeAlignOutside,
                    ),
                  ),
                  child: BrandTile(
                    name: renewals[i].name,
                    color: brandColorFor(renewals[i]),
                    size: tileSize,
                  ),
                ),
              ),
            if (hasExtra)
              Positioned(
                left: visibleIconCount * step,
                top: 0,
                child: Container(
                  width: tileSize,
                  height: tileSize,
                  decoration: BoxDecoration(
                    color: colors.step3,
                    borderRadius:
                        BorderRadius.circular(tileSize * 0.3 + borderW),
                    border: Border.all(
                      color: colors.step2,
                      width: borderW,
                      strokeAlign: BorderSide.strokeAlignOutside,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '+$extraCount',
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      color: colors.inkPrimary,
                      height: 1.0,
                      fontFamily: SublyTypography.displayFamily,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MonthArrow extends StatelessWidget {
  const _MonthArrow({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.sublyColors;
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 22, color: colors.inkSecondary),
      visualDensity: VisualDensity.compact,
    );
  }
}
