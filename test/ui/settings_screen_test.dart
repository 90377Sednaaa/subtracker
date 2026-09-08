import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subtracker/core/theme.dart';
import 'package:subtracker/features/auth/data/auth_repository.dart';
import 'package:subtracker/features/auth/logic/auth_controller.dart';
import 'package:subtracker/features/profile/data/user_profile_repository.dart';
import 'package:subtracker/features/settings/ui/settings_screen.dart';

class _TrackingAuthRepository implements AuthRepository {
  static final _user = MockUser(uid: 'u1', email: 'test@subtracker.app');
  bool signedOut = false;

  @override
  Stream<User?> get authStateChanges => Stream.value(_user);
  @override
  User? currentUser() => _user;
  @override
  Future<void> signInWithGoogle() async {}
  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {}
  @override
  Future<void> createUserWithEmailAndPassword(
    String email,
    String password, {
    String? displayName,
  }) async {}
  @override
  Future<void> signOut() async {
    signedOut = true;
  }
}

void main() {
  testWidgets('tapping Sign out opens confirmation dialog; cancel does not sign out',
      (tester) async {
    final authRepo = _TrackingAuthRepository();
    final db = FakeFirebaseFirestore();
    final profileRepo = UserProfileRepository(db, 'u1');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepo),
          profileRepositoryProvider.overrideWithValue(profileRepo),
        ],
        child: MaterialApp(
          theme: buildSublyTheme(Brightness.dark),
          home: const SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap Sign out tile
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();

    // Confirmation dialog should be visible
    expect(find.text('Sign Out'), findsWidgets);
    expect(find.text('Are you sure you want to sign out of your account?'),
        findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    // Tap Cancel
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Dialog dismissed and not signed out
    expect(authRepo.signedOut, isFalse);
  });

  testWidgets('tapping Sign out and confirming calls authRepository.signOut',
      (tester) async {
    final authRepo = _TrackingAuthRepository();
    final db = FakeFirebaseFirestore();
    final profileRepo = UserProfileRepository(db, 'u1');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepo),
          profileRepositoryProvider.overrideWithValue(profileRepo),
        ],
        child: MaterialApp(
          theme: buildSublyTheme(Brightness.dark),
          home: const SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap Sign out tile
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();

    // Tap the confirm button in dialog (the FilledButton)
    final confirmButton = find.widgetWithText(FilledButton, 'Sign Out');
    expect(confirmButton, findsOneWidget);
    await tester.tap(confirmButton);
    await tester.pumpAndSettle();

    // Verified signed out
    expect(authRepo.signedOut, isTrue);
  });
}
