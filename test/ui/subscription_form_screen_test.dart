import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subtracker/features/subscriptions/data/subscription_repository.dart';
import 'package:subtracker/features/subscriptions/ui/subscription_form_screen.dart';

Widget _wrap(FakeFirebaseFirestore db) => ProviderScope(
      overrides: [
        subscriptionRepositoryProvider
            .overrideWithValue(SubscriptionRepository(db, 'u1')),
      ],
      child: const MaterialApp(home: SubscriptionFormScreen()),
    );

void main() {
  testWidgets('validates required fields', (tester) async {
    final db = FakeFirebaseFirestore();
    await tester.pumpWidget(_wrap(db));
    await tester.tap(find.byKey(const Key('save-button')));
    await tester.pump();

    expect(find.text('Enter a name'), findsOneWidget);
    expect(find.byKey(const Key('save-button')), findsOneWidget);
  });

  testWidgets('save writes a subscription draft', (tester) async {
    final db = FakeFirebaseFirestore();
    await tester.pumpWidget(_wrap(db));

    await tester.enterText(find.byKey(const Key('name-field')), 'Spotify');
    await tester.enterText(find.byKey(const Key('cost-field')), '11.99');
    await tester.tap(find.byKey(const Key('save-button')));
    await tester.pumpAndSettle();

    final subs = await db
        .collection('users')
        .doc('u1')
        .collection('subscriptions')
        .get();
    expect(subs.docs.single.data()['name'], 'Spotify');
    expect(subs.docs.single.data()['cost'], 11.99);
  });
}
