import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:subtracker/features/premium/logic/csv_export.dart';
import 'package:subtracker/features/subscriptions/domain/billing_cycle.dart';
import 'package:subtracker/features/subscriptions/domain/subscription.dart';

Subscription _s(String name, {String currency = 'USD'}) => Subscription(
      id: 'x-$name',
      name: name,
      cost: 9.99,
      currency: currency,
      billingCycle: BillingCycle.monthly,
      nextChargeDate: DateTime(2026, 10, 1),
      trialEndsAt: DateTime(2026, 9, 20),
      reminderDaysBefore: 3,
      active: true,
      createdAt: null,
    );

void main() {
  test('csv has header and one row per subscription', () {
    final csv = subscriptionsToCsv([_s('Netflix'), _s('Hulu')]);
    final lines = csv.trim().split('\n');
    expect(lines.first,
        'name,cost,currency,billing_cycle,next_charge,trial_end');
    expect(lines, hasLength(3));
    expect(lines[1], contains('Netflix'));
    expect(lines[1], contains('2026-10-01'));
  });

  test('fields containing commas are quoted', () {
    final csv = subscriptionsToCsv([_s('Prime, Video')]);
    expect(csv, contains('"Prime, Video"'));
  });

  test('createCsvFile writes valid CSV to disk with timestamped filename', () async {
    final tempDir = await Directory.systemTemp.createTemp('csv_test_');
    addTearDown(() => tempDir.deleteSync(recursive: true));

    final service = const CsvShareService();
    final date = DateTime(2026, 9, 8);
    final file = await service.createCsvFile(
      subscriptions: [_s('Netflix'), _s('Spotify')],
      directory: tempDir,
      now: date,
    );

    expect(file.existsSync(), isTrue);
    expect(file.path, endsWith('subly_subscriptions_2026-09-08.csv'));
    final contents = await file.readAsString();
    expect(contents, contains('Netflix'));
    expect(contents, contains('Spotify'));
  });

  test('shareSubscriptionsCsv creates file and passes XFile to shareAction', () async {
    final tempDir = await Directory.systemTemp.createTemp('csv_share_test_');
    addTearDown(() => tempDir.deleteSync(recursive: true));

    final service = const CsvShareService();
    List<dynamic>? sharedFiles;
    String? sharedSubject;

    await service.shareSubscriptionsCsv(
      subscriptions: [_s('GitHub'), _s('Figma')],
      tempDir: tempDir,
      shareAction: (files, {subject}) async {
        sharedFiles = files;
        sharedSubject = subject;
      },
    );

    expect(sharedFiles, isNotNull);
    expect(sharedFiles, hasLength(1));
    expect(sharedFiles!.first.mimeType, 'text/csv');
    expect(sharedFiles!.first.name, contains('subly_subscriptions_'));
    expect(sharedFiles!.first.path, endsWith('.csv'));
    expect(sharedSubject, 'Subly Subscriptions Export');
  });
}
