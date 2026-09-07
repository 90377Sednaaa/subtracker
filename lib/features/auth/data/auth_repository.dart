import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:subtracker/core/notifications/local_notification_service.dart';

/// The project's OAuth 2.0 **Web client ID** — required by google_sign_in v7
/// on Android to mint an idToken. One-time setup:
///   Firebase console → Authentication → (Get started, enable Google) →
///   Sign-in method → Google → Web SDK configuration → Web client ID.
/// Paste the full `….apps.googleusercontent.com` value below.
const String kGoogleServerClientId =
    '187849793488-c8kdltd93iqnc1l3q22t3nsfis9rvr2r.apps.googleusercontent.com';

abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  User? currentUser();
  Future<void> signInWithGoogle();
  Future<void> signInWithEmailAndPassword(String email, String password);
  Future<void> createUserWithEmailAndPassword(
    String email,
    String password, {
    String? displayName,
  });
  Future<void> signOut();
}

class FirebaseAuthGoogleRepository implements AuthRepository {
  FirebaseAuthGoogleRepository(this._auth);
  final FirebaseAuth _auth;
  bool _googleInitialized = false;

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  User? currentUser() => _auth.currentUser;

  @override
  Future<void> signInWithGoogle() async {
    if (!_googleInitialized) {
      if (kGoogleServerClientId.isEmpty) {
        throw StateError(
          'Google sign-in is not configured: paste the Web client ID into '
          'kGoogleServerClientId (lib/features/auth/data/auth_repository.dart). '
          'See Firebase console → Authentication → Sign-in method → Google.',
        );
      }
      await GoogleSignIn.instance.initialize(
        serverClientId: kGoogleServerClientId,
      );
      _googleInitialized = true;
    }
    final account = await GoogleSignIn.instance.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw StateError('Google sign-in returned no idToken');
    }
    await _auth.signInWithCredential(
      GoogleAuthProvider.credential(idToken: idToken),
    );
    // Android 13+ needs a runtime opt-in; ask once right after sign-in.
    await LocalNotificationService.instance.requestPermissions();
  }

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await LocalNotificationService.instance.requestPermissions();
  }

  @override
  Future<void> createUserWithEmailAndPassword(
    String email,
    String password, {
    String? displayName,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    if (displayName != null && displayName.trim().isNotEmpty) {
      await cred.user?.updateDisplayName(displayName.trim());
    }
    await LocalNotificationService.instance.requestPermissions();
  }

  @override
  Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    await _auth.signOut();
  }
}
