import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subtracker/core/brand/brand.dart';
import 'package:subtracker/core/router.dart';
import 'package:subtracker/features/auth/data/auth_repository.dart';
import 'package:subtracker/features/auth/data/email_service.dart';
import 'package:subtracker/features/auth/logic/auth_controller.dart';
import 'package:subtracker/features/auth/ui/otp_input_row.dart';
import 'package:subtracker/features/auth/ui/sign_in_screen.dart';

class _MockedAuthRepository implements AuthRepository {
  _MockedAuthRepository(this._auth);
  final MockFirebaseAuth _auth;

  String? lastSignedInEmail;
  String? lastSignedInPassword;
  String? lastCreatedEmail;
  String? lastCreatedPassword;
  String? lastCreatedDisplayName;
  bool googleSignInCalled = false;

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  @override
  User? currentUser() => _auth.currentUser;
  @override
  Future<void> signInWithGoogle() async {
    googleSignInCalled = true;
  }

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    lastSignedInEmail = email;
    lastSignedInPassword = password;
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> createUserWithEmailAndPassword(
    String email,
    String password, {
    String? displayName,
  }) async {
    lastCreatedEmail = email;
    lastCreatedPassword = password;
    lastCreatedDisplayName = displayName;
    await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> signOut() async {}
}

class _MockEmailService implements EmailVerificationService {
  String? lastRecipient;
  String? lastCode;

  @override
  Future<bool> sendOtpEmail({
    required String recipientEmail,
    required String code,
  }) async {
    lastRecipient = recipientEmail;
    lastCode = code;
    return true;
  }
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

  testWidgets('unauthenticated user sees modern SignInScreen with logo, form, and Google button',
      (tester) async {
    final auth = MockFirebaseAuth();
    final repo = _MockedAuthRepository(auth);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(repo),
      ],
      child: const MaterialApp(home: SignInScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(SublyLogoBadge), findsOneWidget);
    expect(find.text('Subly'), findsOneWidget);
    expect(find.text('Know where your money recurs.'), findsOneWidget);

    expect(find.byKey(const Key('tab-sign-in')), findsOneWidget);
    expect(find.byKey(const Key('tab-create-account')), findsOneWidget);

    expect(find.byKey(const Key('auth-email')), findsOneWidget);
    expect(find.byKey(const Key('auth-password')), findsOneWidget);
    expect(find.byKey(const Key('auth-submit')), findsOneWidget);

    expect(find.byKey(const Key('google-sign-in')), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.byType(SvgPicture), findsWidgets);
  });

  testWidgets('switching mode toggles Display Name and Confirm Password fields',
      (tester) async {
    final auth = MockFirebaseAuth();
    final repo = _MockedAuthRepository(auth);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(repo),
      ],
      child: const MaterialApp(home: SignInScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('auth-display-name')), findsNothing);
    expect(find.byKey(const Key('auth-confirm-password')), findsNothing);

    // Tap "Create Account" tab
    await tester.tap(find.byKey(const Key('tab-create-account')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('auth-display-name')), findsOneWidget);
    expect(find.byKey(const Key('auth-confirm-password')), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);

    // Switch back to "Sign In"
    await tester.tap(find.byKey(const Key('tab-sign-in')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('auth-display-name')), findsNothing);
    expect(find.byKey(const Key('auth-confirm-password')), findsNothing);
  });

  testWidgets('validates required email and password fields',
      (tester) async {
    final auth = MockFirebaseAuth();
    final repo = _MockedAuthRepository(auth);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(repo),
      ],
      child: const MaterialApp(home: SignInScreen()),
    ));
    await tester.pumpAndSettle();

    // Submit with empty inputs
    await tester.tap(find.byKey(const Key('auth-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);

    // Enter invalid email format
    await tester.enterText(find.byKey(const Key('auth-email')), 'invalidemail');
    await tester.enterText(find.byKey(const Key('auth-password')), '123');
    await tester.tap(find.byKey(const Key('auth-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Please enter a valid email address'), findsOneWidget);
    expect(find.text('Password must be at least 6 characters'), findsOneWidget);
  });

  testWidgets('submitting valid credentials calls signInWithEmailAndPassword',
      (tester) async {
    final auth = MockFirebaseAuth();
    final repo = _MockedAuthRepository(auth);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(repo),
      ],
      child: const MaterialApp(home: SignInScreen()),
    ));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('auth-email')), 'alex@subly.app');
    await tester.enterText(find.byKey(const Key('auth-password')), 'secret123');
    await tester.tap(find.byKey(const Key('auth-submit')));
    await tester.pumpAndSettle();

    expect(repo.lastSignedInEmail, equals('alex@subly.app'));
    expect(repo.lastSignedInPassword, equals('secret123'));
  });

  testWidgets('create account sends OTP email, shows modern OTP input, and creates user on valid code',
      (tester) async {
    final auth = MockFirebaseAuth();
    final repo = _MockedAuthRepository(auth);
    final emailService = _MockEmailService();

    await tester.pumpWidget(ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(repo),
        emailServiceProvider.overrideWithValue(emailService),
      ],
      child: const MaterialApp(home: SignInScreen()),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('tab-create-account')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('auth-display-name')), 'Alex Doe');
    await tester.enterText(find.byKey(const Key('auth-email')), 'alex@subly.app');
    await tester.enterText(find.byKey(const Key('auth-password')), 'secret123');
    await tester.enterText(find.byKey(const Key('auth-confirm-password')), 'secret123');

    await tester.ensureVisible(find.byKey(const Key('auth-submit')));
    await tester.tap(find.byKey(const Key('auth-submit')));
    await tester.pumpAndSettle();

    // Verification email dispatched
    expect(emailService.lastRecipient, equals('alex@subly.app'));
    expect(emailService.lastCode, isNotNull);
    final sentCode = emailService.lastCode!;
    expect(sentCode.length, equals(6));

    // View has transitioned to OTP screen
    expect(find.text('Verify your email'), findsOneWidget);
    expect(find.byType(OtpInputRow), findsOneWidget);

    // Test invalid OTP code
    await tester.enterText(find.byKey(const Key('otp-box-0')), '000000');
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('auth-verify-submit')));
    await tester.tap(find.byKey(const Key('auth-verify-submit')));
    await tester.pump();

    expect(find.text('Invalid verification code. Please try again.'), findsOneWidget);
    expect(repo.lastCreatedEmail, isNull);

    // Enter correct OTP code
    await tester.enterText(find.byKey(const Key('otp-box-0')), sentCode);
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('auth-verify-submit')));
    await tester.tap(find.byKey(const Key('auth-verify-submit')));
    await tester.pumpAndSettle();

    expect(repo.lastCreatedDisplayName, equals('Alex Doe'));
    expect(repo.lastCreatedEmail, equals('alex@subly.app'));
    expect(repo.lastCreatedPassword, equals('secret123'));
  });

  testWidgets('tapping Change email address returns to Create Account form',
      (tester) async {
    final auth = MockFirebaseAuth();
    final repo = _MockedAuthRepository(auth);
    final emailService = _MockEmailService();

    await tester.pumpWidget(ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(repo),
        emailServiceProvider.overrideWithValue(emailService),
      ],
      child: const MaterialApp(home: SignInScreen()),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('tab-create-account')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('auth-email')), 'alex@subly.app');
    await tester.enterText(find.byKey(const Key('auth-password')), 'secret123');
    await tester.enterText(find.byKey(const Key('auth-confirm-password')), 'secret123');

    await tester.ensureVisible(find.byKey(const Key('auth-submit')));
    await tester.tap(find.byKey(const Key('auth-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Verify your email'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('btn-change-email')));
    await tester.tap(find.byKey(const Key('btn-change-email')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('auth-email')), findsOneWidget);
    expect(find.text('alex@subly.app'), findsOneWidget);
  });

  testWidgets('tapping Continue with Google calls signInWithGoogle',
      (tester) async {
    final auth = MockFirebaseAuth();
    final repo = _MockedAuthRepository(auth);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(repo),
      ],
      child: const MaterialApp(home: SignInScreen()),
    ));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('google-sign-in')));
    await tester.tap(find.byKey(const Key('google-sign-in')));
    await tester.pumpAndSettle();

    expect(repo.googleSignInCalled, isTrue);
  });
}
