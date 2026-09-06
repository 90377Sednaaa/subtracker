import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subtracker/features/profile/data/user_profile.dart';
import 'package:subtracker/features/profile/data/user_profile_repository.dart';

void main() {
  test('ensureProfile creates the document once and is idempotent', () async {
    final db = FakeFirebaseFirestore();
    final repo = UserProfileRepository(db, 'u1');

    await repo.ensureProfile(email: 'a@b.c', displayName: 'Ann');
    await repo.ensureProfile(email: 'a@b.c', displayName: 'Ann');

    final snap = await db.collection('users').doc('u1').get();
    expect(snap.exists, isTrue);
    expect(snap.data()!['email'], 'a@b.c');

    final profiles = await db.collection('users').get();
    expect(profiles.docs, hasLength(1));
  });

  test('setPremium flips premium and plan', () async {
    final db = FakeFirebaseFirestore();
    final repo = UserProfileRepository(db, 'u1');
    await repo.ensureProfile(email: 'a@b.c');

    await repo.setPremium(premium: true, plan: 'monthly');
    final profile = await db.collection('users').doc('u1').get();
    expect(profile.data()!['premium'], true);
    expect(profile.data()!['premiumPlan'], 'monthly');
  });

  test('watch emits UserProfile updates', () async {
    final db = FakeFirebaseFirestore();
    final repo = UserProfileRepository(db, 'u1');
    await repo.ensureProfile(email: 'a@b.c');

    final first = await repo.watch().first;
    expect(first, isA<UserProfile>());
    expect(first!.premium, false);
  });
}
