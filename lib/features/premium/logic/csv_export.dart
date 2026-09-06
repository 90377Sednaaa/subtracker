import 'package:intl/intl.dart';
import 'package:subtracker/features/subscriptions/domain/subscription.dart';

String subscriptionsToCsv(List<Subscription> subs) {
  final dateFmt = DateFormat('yyyy-MM-dd');
  String cell(Object? value) {
    final s = value?.toString() ?? '';
    return s.contains(',') || s.contains('"')
        ? '"${s.replaceAll('"', '""')}"'
        : s;
  }

  final rows = <String>[
    'name,cost,currency,billing_cycle,next_charge,trial_end',
    for (final s in subs)
      [
        cell(s.name),
        cell(s.cost.toStringAsFixed(2)),
        cell(s.currency),
        cell(s.billingCycle.name),
        cell(dateFmt.format(s.nextChargeDate)),
        cell(s.trialEndsAt == null ? '' : dateFmt.format(s.trialEndsAt!)),
      ].join(','),
  ];
  return rows.join('\n');
}
