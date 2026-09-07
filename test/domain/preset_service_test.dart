import 'package:flutter_test/flutter_test.dart';
import 'package:subtracker/features/subscriptions/domain/preset_service.dart';

void main() {
  test('kPresetServices contains 20+ services with non-empty names and categories', () {
    expect(kPresetServices.length, greaterThanOrEqualTo(20));
    for (final service in kPresetServices) {
      expect(service.name.trim(), isNotEmpty);
      expect(service.category.trim(), isNotEmpty);
      expect(service.brandColorHex, isNonZero);
    }
  });

  test('kSubscriptionCategories contains common categories including Other', () {
    expect(kSubscriptionCategories, contains('Entertainment'));
    expect(kSubscriptionCategories, contains('Music'));
    expect(kSubscriptionCategories, contains('Productivity'));
    expect(kSubscriptionCategories, contains('Utilities'));
    expect(kSubscriptionCategories, contains('Other'));
  });

  test('PresetService matches case-insensitively', () {
    final netflix = kPresetServices.firstWhere((s) => s.name == 'Netflix');
    expect(netflix.matchesQuery('net'), isTrue);
    expect(netflix.matchesQuery('FLIX'), isTrue);
    expect(netflix.matchesQuery('xyz123'), isFalse);
  });
}
