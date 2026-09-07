import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subtracker/core/theme.dart';
import 'package:subtracker/features/subscriptions/domain/billing_cycle.dart';
import 'package:subtracker/features/subscriptions/domain/subscription.dart';
import 'package:subtracker/features/subscriptions/ui/calendar_view.dart';

Subscription _mockSub(String name, {String? brandColor}) {
  return Subscription(
    id: name.toLowerCase(),
    name: name,
    cost: 10.0,
    currency: 'USD',
    billingCycle: BillingCycle.monthly,
    nextChargeDate: DateTime(2026, 9, 7),
    trialEndsAt: null,
    reminderDaysBefore: 3,
    brandColor: brandColor,
    category: 'Productivity',
    notes: '',
    active: true,
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  group('RenewalCluster', () {
    testWidgets('renders single subscription without overflow', (tester) async {
      final renewals = [_mockSub('Netflix')];

      await tester.pumpWidget(
        MaterialApp(
          theme: buildSublyTheme(Brightness.dark),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 30,
                child: RenewalCluster(renewals: renewals),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(RenewalCluster), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders 2 subscriptions overlapping without overflow in narrow 30px cell',
        (tester) async {
      final renewals = [_mockSub('Claude'), _mockSub('ChatGPT')];

      await tester.pumpWidget(
        MaterialApp(
          theme: buildSublyTheme(Brightness.dark),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 30,
                child: RenewalCluster(renewals: renewals),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(RenewalCluster), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders 3 subscriptions overlapping without overflow in narrow 30px cell',
        (tester) async {
      final renewals = [
        _mockSub('Netflix'),
        _mockSub('Spotify'),
        _mockSub('Cursor'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: buildSublyTheme(Brightness.dark),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 30,
                child: RenewalCluster(renewals: renewals),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(RenewalCluster), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(find.text('+1'), findsNothing);
    });

    testWidgets('renders 2 icons + counter badge when renewals > 3',
        (tester) async {
      final renewals = [
        _mockSub('Netflix'),
        _mockSub('Spotify'),
        _mockSub('Cursor'),
        _mockSub('Claude'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: buildSublyTheme(Brightness.dark),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 30,
                child: RenewalCluster(renewals: renewals),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(RenewalCluster), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(find.text('+2'), findsOneWidget);
    });

    testWidgets('CalendarView renders multi-renewal days without RenderFlex overflow on small screen',
        (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final now = DateTime(2026, 9, 1);
      final subs = [
        _mockSub('Gemini'),
        _mockSub('Claude'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: buildSublyTheme(Brightness.dark),
          home: Scaffold(
            body: CalendarView(
              subscriptions: subs,
              monthlyTotalByCurrency: const {
                'USD': (monthly: 40.0, annual: 480.0)
              },
              now: now,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(CalendarView), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('cal-day-7')), findsOneWidget);
      expect(find.descendant(
        of: find.byKey(const Key('cal-day-7')),
        matching: find.byType(RenewalCluster),
      ), findsOneWidget);
    });
  });
}
