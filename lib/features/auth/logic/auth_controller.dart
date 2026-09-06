import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subtracker/core/notifications/local_notification_service.dart';
import 'package:subtracker/features/auth/data/auth_repository.dart';
import 'package:subtracker/features/profile/data/user_profile_repository.dart';

/// Overridden in main.dart with the real repository; tests override with fakes.
final authRepositoryProvider =
    Provider<AuthRepository>((ref) => throw UnimplementedError());

final firebaseAuthProvider = StreamProvider<User?>(
    (ref) => ref.watch(authRepositoryProvider).authStateChanges);

/// App-level bootstrap on every auth change: create the user's Firestore
/// profile on first sign-in and ask for notification permission once.
/// Watched from the app root (SubtrackerApp).
final profileBootstrapProvider = Provider<void>((ref) {
  ref.listen(firebaseAuthProvider, (_, auth) {
    final user = auth.value;
    if (user == null) return;
    ref.read(profileRepositoryProvider).ensureProfile(
          email: user.email ?? '',
          displayName: user.displayName,
        );
    LocalNotificationService.instance.requestPermissions();
  });
});
