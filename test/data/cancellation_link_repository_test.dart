import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subtracker/features/directory/data/cancellation_link_repository.dart';

void main() {
  test('returns links ordered by sortOrder when defaults are empty', () async {
    final db = FakeFirebaseFirestore();
    await db.collection('cancellation_links').doc('b').set({
      'name': 'B-service',
      'category': 'Streaming',
      'cancelUrl': 'https://b.example/cancel',
      'notes': '',
      'sortOrder': 2,
    });
    await db.collection('cancellation_links').doc('a').set({
      'name': 'A-service',
      'category': 'Music',
      'cancelUrl': 'https://a.example/cancel',
      'notes': '',
      'sortOrder': 1,
    });

    final links = await CancellationLinkRepository(db, defaults: const []).watchAll().first;
    expect(links.map((l) => l.name).toList(), ['A-service', 'B-service']);
  });

  test('returns kDefaultCancellationLinks when firestore collection is empty', () async {
    final db = FakeFirebaseFirestore();
    final links = await CancellationLinkRepository(db).watchAll().first;
    expect(links.length, 35);
    expect(links.first.name, 'Netflix');
  });

  test('merges remote firestore links with defaults without losing presets', () async {
    final db = FakeFirebaseFirestore();
    // Simulate Firestore having only a subset of services (e.g. 12 items)
    await db.collection('cancellation_links').doc('netflix').set({
      'name': 'Netflix (Custom)',
      'category': 'Entertainment',
      'cancelUrl': 'https://netflix.com/custom-cancel',
      'notes': 'Account -> Custom Cancel',
    });

    final links = await CancellationLinkRepository(db).watchAll().first;
    expect(links.length, 35);
    final netflix = links.firstWhere((l) => l.id == 'netflix');
    expect(netflix.name, 'Netflix (Custom)');
    expect(netflix.cancelUrl, 'https://netflix.com/custom-cancel');
    // Non-seeded defaults are still preserved
    expect(links.any((l) => l.id == 'canva'), isTrue);
    expect(links.any((l) => l.id == 'medium'), isTrue);
  });
}

