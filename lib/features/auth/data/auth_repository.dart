import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  User? currentUser();
  Future<void> signInWithGoogle();
  Future<void> signOut();
}
