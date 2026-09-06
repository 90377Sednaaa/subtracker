import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subtracker/core/router.dart';
import 'package:subtracker/features/auth/data/auth_repository.dart';
import 'package:subtracker/features/auth/logic/auth_controller.dart';

class _MockedAuthRepository implements AuthRepository {
  _MockedAuthRepository(this._auth);
  final MockFirebaseAuth _auth;
  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  @override
  User? currentUser() => _auth.currentUser;
  @override
  Future<void> signInWithGoogle() async {}
  @override
  Future<void> signOut() async {}
}

void main() {
  testWidgets('signed-in user does not see the sign-in screen',
      (tester) async {
    final auth = MockFirebaseAuth(
        mockUser: MockUser(uid: 'u1', email: 'a@b.c', isAnonymous: true));
    await auth.signInAnonymously(); // emits a user on authStateChanges
    await tester.pumpWidget(ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(_MockedAuthRepository(auth)),
      ],
      child: const SubtrackerApp(),
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('signin-screen')), findsNothing);
  });
}
