import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subtracker/features/auth/data/auth_repository.dart';

/// Overridden in main.dart with the real repository; tests override with fakes.
final authRepositoryProvider =
    Provider<AuthRepository>((ref) => throw UnimplementedError());

final firebaseAuthProvider = StreamProvider<User?>(
    (ref) => ref.watch(authRepositoryProvider).authStateChanges);
