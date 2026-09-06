import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subtracker/core/router.dart';
import 'package:subtracker/features/auth/data/auth_repository.dart';
import 'package:subtracker/features/auth/logic/auth_controller.dart';
import 'package:subtracker/firebase_options.dart';

/// Temporary stand-in until Task 3 ships the real Google Sign-In repository.
class _NoopAuthRepository implements AuthRepository {
  @override
  Stream<User?> get authStateChanges => const Stream.empty();
  @override
  User? currentUser() => null;
  @override
  Future<void> signInWithGoogle() async {}
  @override
  Future<void> signOut() async {}
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(_NoopAuthRepository()),
    ],
    child: const SubtrackerApp(),
  ));
}
