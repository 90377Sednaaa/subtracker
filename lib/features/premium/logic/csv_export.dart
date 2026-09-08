import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:subtracker/features/subscriptions/domain/subscription.dart';

final csvShareServiceProvider = Provider<CsvShareService>((ref) {
  return const CsvShareService();
});

class CsvShareService {
  const CsvShareService();

  /// Writes subscriptions as a timestamped CSV file in [directory].
  Future<File> createCsvFile({
    required List<Subscription> subscriptions,
    required Directory directory,
    DateTime? now,
  }) async {
    final timestamp = DateFormat('yyyy-MM-dd').format(now ?? DateTime.now());
    final file = File('${directory.path}/subly_subscriptions_$timestamp.csv');
    final csvContent = subscriptionsToCsv(subscriptions);
    return file.writeAsString(csvContent);
  }

  /// Writes the CSV to temporary cache storage and invokes the native OS share sheet.
  Future<void> shareSubscriptionsCsv({
    required List<Subscription> subscriptions,
    Directory? tempDir,
    DateTime? now,
    Future<void> Function(List<XFile> files, {String? subject})? shareAction,
  }) async {
    final dir = tempDir ?? await getTemporaryDirectory();
    final timestamp = DateFormat('yyyy-MM-dd').format(now ?? DateTime.now());
    final filename = 'subly_subscriptions_$timestamp.csv';
    final file = File('${dir.path}/$filename');
    await file.writeAsString(subscriptionsToCsv(subscriptions));

    final xFile = XFile(
      file.path,
      mimeType: 'text/csv',
      name: filename,
    );
    if (shareAction != null) {
      await shareAction([xFile], subject: 'Subly Subscriptions Export');
    } else {
      await SharePlus.instance.share(
        ShareParams(
          files: [xFile],
          subject: 'Subly Subscriptions Export',
        ),
      );
    }
  }
}

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
