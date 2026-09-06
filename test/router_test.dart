import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subtracker/core/router.dart';
import 'package:subtracker/features/auth/data/auth_repository.dart';
import 'package:subtracker/features/auth/logic/auth_controller.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Stream<User?> get authStateChanges => Stream.value(null); // signed out
  @override
  User? currentUser() => null;
  @override
  Future<void> signInWithGoogle() async {}
  @override
  Future<void> signOut() async {}
}

void main() {
  testWidgets('unauthenticated user is redirected to /signin', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
      ],
      child: const SubtrackerApp(),
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('signin-screen')), findsOneWidget);
  });
}
