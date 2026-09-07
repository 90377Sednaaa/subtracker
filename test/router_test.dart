import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subtracker/core/router.dart';
import 'package:subtracker/features/auth/data/auth_repository.dart';
import 'package:subtracker/features/auth/logic/auth_controller.dart';
import 'package:subtracker/features/subscriptions/domain/preset_service.dart';
import 'package:subtracker/features/subscriptions/ui/subscription_catalog_screen.dart';
import 'package:subtracker/features/subscriptions/ui/subscription_form_screen.dart';

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

class _FakeSignedInAuthRepository implements AuthRepository {
  @override
  Stream<User?> get authStateChanges => Stream.value(_FakeUser());
  @override
  User? currentUser() => _FakeUser();
  @override
  Future<void> signInWithGoogle() async {}
  @override
  Future<void> signOut() async {}
}

class _FakeUser extends Fake implements User {
  @override
  String get uid => 'u1';
  @override
  String? get email => 'test@example.com';
  @override
  String? get displayName => 'Test User';
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

  testWidgets(
      'signed-in user navigating to /subs/new displays SubscriptionCatalogScreen',
      (tester) async {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(_FakeSignedInAuthRepository()),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const SubtrackerApp(),
    ));
    await tester.pumpAndSettle();

    container.read(routerProvider).go('/subs/new');
    await tester.pumpAndSettle();

    expect(find.byType(SubscriptionCatalogScreen), findsOneWidget);
  });

  testWidgets(
      'signed-in user navigating to /subs/new/config displays SubscriptionFormScreen',
      (tester) async {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(_FakeSignedInAuthRepository()),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const SubtrackerApp(),
    ));
    await tester.pumpAndSettle();

    container.read(routerProvider).go('/subs/new/config');
    await tester.pumpAndSettle();

    expect(find.byType(SubscriptionFormScreen), findsOneWidget);
  });

  testWidgets(
      'signed-in user navigating to /subs/new/config with preset passes preset to form',
      (tester) async {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(_FakeSignedInAuthRepository()),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const SubtrackerApp(),
    ));
    await tester.pumpAndSettle();

    container.read(routerProvider).go(
      '/subs/new/config',
      extra: const PresetService(
        name: 'Netflix',
        category: 'Entertainment',
        brandColorHex: 0xFFE50914,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SubscriptionFormScreen), findsOneWidget);
    expect(find.text('Netflix'), findsOneWidget);
  });
}

