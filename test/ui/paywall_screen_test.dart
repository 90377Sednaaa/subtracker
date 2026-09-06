import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subtracker/features/premium/ui/paywall_screen.dart';
import 'package:subtracker/features/profile/data/user_profile_repository.dart';

void main() {
  testWidgets('choosing monthly sets premium=true, plan=monthly',
      (tester) async {
    final db = FakeFirebaseFirestore();
    await db.collection('users').doc('u1').set({'email': 'a@b.c'});
    await tester.pumpWidget(ProviderScope(
      overrides: [
        profileRepositoryProvider
            .overrideWithValue(UserProfileRepository(db, 'u1')),
      ],
      child: const MaterialApp(home: PaywallScreen()),
    ));

    await tester.tap(find.byKey(const Key('plan-monthly')));
    await tester.pumpAndSettle();

    final user = await db.collection('users').doc('u1').get();
    expect(user.data()!['premium'], true);
    expect(user.data()!['premiumPlan'], 'monthly');
  });
}
