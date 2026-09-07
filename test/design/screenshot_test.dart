import 'dart:io';
import 'dart:ui' as ui;

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subtracker/core/theme.dart';
import 'package:subtracker/features/auth/data/auth_repository.dart';
import 'package:subtracker/features/auth/logic/auth_controller.dart';
import 'package:subtracker/features/directory/data/cancellation_link_repository.dart';
import 'package:subtracker/features/directory/ui/directory_screen.dart';
import 'package:subtracker/features/subscriptions/data/subscription_repository.dart';
import 'package:subtracker/features/subscriptions/domain/billing_cycle.dart';
import 'package:subtracker/features/subscriptions/domain/preset_service.dart';
import 'package:subtracker/features/subscriptions/domain/subscription_draft.dart';
import 'package:subtracker/features/subscriptions/ui/dashboard_screen.dart';
import 'package:subtracker/features/subscriptions/ui/subscription_catalog_screen.dart';
import 'package:subtracker/features/subscriptions/ui/subscription_form_screen.dart';

/// Visual QA: renders the real dashboard and the cancellation directory in
/// both themes to PNGs under build/design-screenshots/ so layout and
/// alignment can be reviewed by eye.
/// Run: flutter test test/design/screenshot_test.dart
class _SignedInAuthRepository implements AuthRepository {
  static final _user = MockUser(uid: 'u1', email: 'a@b.c');
  @override
  Stream<User?> get authStateChanges => Stream.value(_user);
  @override
  User? currentUser() => _user;
  @override
  Future<void> signInWithGoogle() async {}
  @override
  Future<void> signOut() async {}
}

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('dashboard screenshot — ${brightness.name}', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(412, 892); // typical Android
      addTearDown(tester.view.reset);

      final db = FakeFirebaseFirestore();
      await db.collection('users').doc('u1').set({'premium': true});
      final repo = SubscriptionRepository(db, 'u1');
      Future<void> add(String name, double cost, String currency,
          BillingCycle cycle, DateTime next) {
        return repo.add(SubscriptionDraft(
          name: name,
          cost: cost,
          currency: currency,
          billingCycle: cycle,
          nextChargeDate: next,
          trialEndsAt: null,
          reminderDaysBefore: 3,
        ));
      }

      final now = DateTime.now();
      await add('Netflix', 15.49, 'USD', BillingCycle.monthly,
          now.add(const Duration(days: 2)));
      await add('Spotify', 11.99, 'USD', BillingCycle.monthly,
          now.add(const Duration(days: 5)));
      await add('Adobe Creative Cloud', 659.88, 'USD', BillingCycle.annual,
          now.add(const Duration(days: 10)));
      await add('Doit.im Pro', 9.99, 'EUR', BillingCycle.annual,
          now.add(const Duration(days: 20)));

      final key = GlobalKey();
      await tester.pumpWidget(RepaintBoundary(
        key: key,
        child: ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(_SignedInAuthRepository()),
            subscriptionRepositoryProvider.overrideWithValue(repo),
          ],
          child: SubtrackerThemeApp(
              brightness: brightness, child: const DashboardScreen()),
        ),
      ));
      await tester.pumpAndSettle();

      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 1.0);
        final bytes =
            await image.toByteData(format: ui.ImageByteFormat.png);
        Directory('build/design-screenshots').createSync(recursive: true);
        File('build/design-screenshots/dashboard-${brightness.name}.png')
            .writeAsBytesSync(bytes!.buffer.asUint8List());
      });
      expect(
          File('build/design-screenshots/dashboard-${brightness.name}.png')
              .lengthSync(),
          greaterThan(5000));
    });

    testWidgets('directory screenshot — ${brightness.name}', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(412, 892); // typical Android
      addTearDown(tester.view.reset);

      const seeded = [
        ('Netflix', 'Streaming', 'Account → Cancel plan'),
        ('Spotify', 'Music', 'Account → Change or cancel'),
        ('Disney+', 'Streaming', 'Account → Subscription'),
        ('YouTube Premium', 'Streaming', 'Paid memberships → Manage'),
        ('Amazon Prime', 'Shopping', 'Prime membership → End membership'),
        ('Microsoft 365', 'Productivity', 'Services & subscriptions → Cancel'),
        ('Adobe Creative Cloud', 'Productivity', 'Plans → Manage plan'),
        ('Xbox Game Pass', 'Gaming', 'Subscriptions → Manage'),
        ('Dropbox', 'Storage', 'Plan → Cancel plan'),
        ('Canva Pro', 'Design', 'Billing & plans → Cancel'),
        ('Audible', 'Books', 'Membership → Cancel'),
        ('iCloud+', 'Storage', 'iCloud → Downgrade options'),
      ];
      final db = FakeFirebaseFirestore();
      for (var i = 0; i < seeded.length; i++) {
        await db.collection('cancellation_links').add({
          'name': seeded[i].$1,
          'category': seeded[i].$2,
          'notes': seeded[i].$3,
          'cancelUrl': 'https://example.com/cancel',
          'sortOrder': i,
        });
      }

      final key = GlobalKey();
      await tester.pumpWidget(RepaintBoundary(
        key: key,
        child: ProviderScope(
          overrides: [
            cancellationLinkRepositoryProvider
                .overrideWithValue(CancellationLinkRepository(db)),
          ],
          child: SubtrackerThemeApp(
              brightness: brightness, child: const DirectoryScreen()),
        ),
      ));
      await tester.pumpAndSettle();

      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 1.0);
        final bytes =
            await image.toByteData(format: ui.ImageByteFormat.png);
        Directory('build/design-screenshots').createSync(recursive: true);
        File('build/design-screenshots/directory-${brightness.name}.png')
            .writeAsBytesSync(bytes!.buffer.asUint8List());
      });
      expect(
          File('build/design-screenshots/directory-${brightness.name}.png')
              .lengthSync(),
          greaterThan(5000));
    });

    testWidgets('catalog screenshot — ${brightness.name}', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(412, 892);
      addTearDown(tester.view.reset);

      final key = GlobalKey();
      await tester.pumpWidget(RepaintBoundary(
        key: key,
        child: SubtrackerThemeApp(
          brightness: brightness,
          child: const SubscriptionCatalogScreen(),
        ),
      ));
      await tester.pumpAndSettle();

      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 1.0);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        Directory('build/design-screenshots').createSync(recursive: true);
        File('build/design-screenshots/catalog-${brightness.name}.png')
            .writeAsBytesSync(bytes!.buffer.asUint8List());
      });
      expect(
        File('build/design-screenshots/catalog-${brightness.name}.png')
            .lengthSync(),
        greaterThan(5000),
      );
    });

    testWidgets('form screenshot — ${brightness.name}', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(412, 892);
      addTearDown(tester.view.reset);

      final db = FakeFirebaseFirestore();
      final repo = SubscriptionRepository(db, 'u1');

      const preset = PresetService(
        name: 'Cursor',
        category: 'Utilities',
        brandColorHex: 0xFF000000,
      );

      final key = GlobalKey();
      await tester.pumpWidget(RepaintBoundary(
        key: key,
        child: ProviderScope(
          overrides: [
            subscriptionRepositoryProvider.overrideWithValue(repo),
          ],
          child: SubtrackerThemeApp(
            brightness: brightness,
            child: const SubscriptionFormScreen(initialPreset: preset),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 1.0);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        Directory('build/design-screenshots').createSync(recursive: true);
        File('build/design-screenshots/form-${brightness.name}.png')
            .writeAsBytesSync(bytes!.buffer.asUint8List());
      });
      expect(
        File('build/design-screenshots/form-${brightness.name}.png')
            .lengthSync(),
        greaterThan(5000),
      );
    });
  }
}

/// Minimal app wrapper that pins a brightness without touching providers.
class SubtrackerThemeApp extends StatelessWidget {
  const SubtrackerThemeApp(
      {super.key, required this.brightness, required this.child});

  final Brightness brightness;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: buildSublyTheme(brightness),
      home: child,
    );
  }
}
