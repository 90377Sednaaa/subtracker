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

  test('kPresetServices contains 35+ services and popular presets flagged', () {
    expect(kPresetServices.length, greaterThanOrEqualTo(35));
    final popular = kPresetServices.where((s) => s.isPopular).toList();
    expect(popular.length, greaterThanOrEqualTo(6));
    expect(popular.any((s) => s.name == 'ChatGPT Plus'), isTrue);
    expect(popular.any((s) => s.name == 'Netflix'), isTrue);
    expect(popular.any((s) => s.name == 'Spotify'), isTrue);
    expect(popular.any((s) => s.name == 'Cursor'), isTrue);
    expect(popular.any((s) => s.name == 'Apple One'), isTrue);
    expect(popular.any((s) => s.name == 'YouTube Premium'), isTrue);
    expect(kPopularPresetServices, equals(popular));
  });

  test('all presets have non-null iconAsset and non-empty categories', () {
    for (final preset in kPresetServices) {
      expect(preset.iconAsset, isNotNull, reason: '${preset.name} missing iconAsset');
      expect(preset.iconAsset!.endsWith('.svg'), isTrue);
      expect(preset.category, isNotEmpty);
    }
  });
}
