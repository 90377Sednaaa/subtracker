import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TotalsHeader extends StatelessWidget {
  const TotalsHeader({super.key, required this.totals});

  final Map<String, ({double monthly, double annual})> totals;

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat.simpleCurrency();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final entry in totals.entries) ...[
              Text(entry.key, style: Theme.of(context).textTheme.labelMedium),
              Text(
                '${format.format(entry.value.monthly)}/mo · ${format.format(entry.value.annual)}/yr',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
