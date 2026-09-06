import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subtracker/features/profile/data/user_profile.dart';

/// Overridden in main.dart with the real Firestore + signed-in uid; tests
/// override with a fake-backed repository.
final profileRepositoryProvider =
    Provider<UserProfileRepository>((ref) => throw UnimplementedError());

class UserProfileRepository {
  UserProfileRepository(this._db, this._uid);
  final FirebaseFirestore _db;
  final String _uid;

  Future<void> ensureProfile(
      {required String email, String? displayName}) async {
    final doc = _db.collection('users').doc(_uid);
    await doc.set({
      'email': email,
      'displayName': displayName ?? '',
      'premium': false,
      'premiumPlan': 'free',
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<UserProfile?> watch() => _db
      .collection('users')
      .doc(_uid)
      .snapshots()
      .map((snap) =>
          snap.exists ? UserProfile.fromMap(snap.id, snap.data()!) : null);

  Future<void> setPremium({required bool premium, required String plan}) =>
      _db.collection('users').doc(_uid).set(
        {'premium': premium, 'premiumPlan': plan},
        SetOptions(merge: true),
      );
}

final profileStreamProvider = StreamProvider<UserProfile?>(
    (ref) => ref.watch(profileRepositoryProvider).watch());
