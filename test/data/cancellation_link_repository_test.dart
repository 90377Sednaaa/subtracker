import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subtracker/features/directory/data/cancellation_link_repository.dart';

void main() {
  test('returns links ordered by sortOrder', () async {
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

    final links = await CancellationLinkRepository(db).watchAll().first;
    expect(links.map((l) => l.name).toList(), ['A-service', 'B-service']);
  });
}
