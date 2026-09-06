import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subtracker/core/router.dart';
import 'package:subtracker/core/notifications/local_notification_service.dart';
import 'package:subtracker/features/auth/data/auth_repository.dart';
import 'package:subtracker/features/auth/logic/auth_controller.dart';
import 'package:subtracker/features/profile/data/user_profile_repository.dart';
import 'package:subtracker/features/subscriptions/data/subscription_repository.dart';
import 'package:subtracker/features/subscriptions/logic/subscription_controller.dart';
import 'package:subtracker/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await LocalNotificationService.instance.init();
  runApp(ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(
          FirebaseAuthGoogleRepository(FirebaseAuth.instance)),
      reminderSchedulerProvider
          .overrideWithValue(LocalNotificationService.instance),
      // Lazy: only read after the router redirect guarantees a signed-in user.
      profileRepositoryProvider.overrideWith((ref) => UserProfileRepository(
          FirebaseFirestore.instance, FirebaseAuth.instance.currentUser!.uid)),
      subscriptionRepositoryProvider.overrideWith((ref) =>
          SubscriptionRepository(FirebaseFirestore.instance,
              FirebaseAuth.instance.currentUser!.uid)),
    ],
    child: const SubtrackerApp(),
  ));
}
