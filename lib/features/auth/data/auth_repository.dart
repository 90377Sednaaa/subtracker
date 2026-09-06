import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:subtracker/core/notifications/local_notification_service.dart';

abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  User? currentUser();
  Future<void> signInWithGoogle();
  Future<void> signOut();
}

class FirebaseAuthGoogleRepository implements AuthRepository {
  FirebaseAuthGoogleRepository(this._auth);
  final FirebaseAuth _auth;

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  User? currentUser() => _auth.currentUser;

  @override
  Future<void> signInWithGoogle() async {
    final google = GoogleSignIn.instance;
    final account = await google.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw StateError('Google sign-in returned no idToken');
    }
    await _auth
        .signInWithCredential(GoogleAuthProvider.credential(idToken: idToken));
    // Android 13+ needs a runtime opt-in; ask once right after sign-in.
    await LocalNotificationService.instance.requestPermissions();
  }

  @override
  Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    await _auth.signOut();
  }
}
