import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    testWidgets('navigating to next month does not mark that day as selected',
        (tester) async {
      final now = DateTime(2026, 9, 7);
      final subs = [_mockSub('Claude')];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: buildSublyTheme(Brightness.dark),
            home: Scaffold(
              body: CalendarView(
                subscriptions: subs,
                monthlyTotalByCurrency: const {
                  'USD': (monthly: 20.0, annual: 240.0)
                },
                now: now,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // In September 2026, day 7 is selected (colors.step3 background)
      final day7Sep = tester.widget<Container>(find.byKey(const Key('cal-day-7')));
      final dec7Sep = day7Sep.decoration as BoxDecoration;
      expect(dec7Sep.color, SublyColors.dark.step3);

      // Tap chevron_right to go to October 2026
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();

      expect(find.text('October, 2026'), findsOneWidget);

      // In October 2026, day 7 should NOT be selected or marked as today
      final day7Oct = tester.widget<Container>(find.byKey(const Key('cal-day-7')));
      final dec7Oct = day7Oct.decoration as BoxDecoration;
      expect(dec7Oct.color, isNot(SublyColors.dark.step3));
    });

    testWidgets('tapping subscription item opens subscription actions modal',
        (tester) async {
      final now = DateTime(2026, 9, 7);
      final subs = [_mockSub('Claude')];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: buildSublyTheme(Brightness.dark),
            home: Scaffold(
              body: CalendarView(
                subscriptions: subs,
                monthlyTotalByCurrency: const {
                  'USD': (monthly: 20.0, annual: 240.0)
                },
                now: now,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tapping the Claude subscription in day agenda
      final subFinder = find.text('Claude').last;
      await tester.scrollUntilVisible(
        subFinder,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(subFinder);
      await tester.pumpAndSettle();

      // Bottom sheet modal should open with actions
      expect(find.text('Mark Paid / Advance Cycle'), findsOneWidget);
      expect(find.text('Edit Subscription'), findsOneWidget);
    });

    testWidgets('swiping left on calendar container navigates to next month',
        (tester) async {
      final now = DateTime(2026, 9, 7);
      final subs = [_mockSub('Claude')];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: buildSublyTheme(Brightness.dark),
            home: Scaffold(
              body: CalendarView(
                subscriptions: subs,
                monthlyTotalByCurrency: const {
                  'USD': (monthly: 20.0, annual: 240.0)
                },
                now: now,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('September, 2026'), findsOneWidget);

      // Drag left on calendar container
      await tester.drag(
        find.byKey(const Key('calendar-container')),
        const Offset(-100, 0),
      );
      await tester.pumpAndSettle();

      expect(find.text('October, 2026'), findsOneWidget);
    });

    testWidgets('swiping right on calendar container navigates to previous month',
        (tester) async {
      final now = DateTime(2026, 9, 7);
      final subs = [_mockSub('Claude')];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: buildSublyTheme(Brightness.dark),
            home: Scaffold(
              body: CalendarView(
                subscriptions: subs,
                monthlyTotalByCurrency: const {
                  'USD': (monthly: 20.0, annual: 240.0)
                },
                now: now,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('September, 2026'), findsOneWidget);

      // Drag right on calendar container
      await tester.drag(
        find.byKey(const Key('calendar-container')),
        const Offset(100, 0),
      );
      await tester.pumpAndSettle();

      expect(find.text('August, 2026'), findsOneWidget);
    });

    testWidgets('swiping on agenda does not navigate month',
        (tester) async {
      final now = DateTime(2026, 9, 7);
      final subs = [_mockSub('Claude')];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: buildSublyTheme(Brightness.dark),
            home: Scaffold(
              body: CalendarView(
                subscriptions: subs,
                monthlyTotalByCurrency: const {
                  'USD': (monthly: 20.0, annual: 240.0)
                },
                now: now,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('September, 2026'), findsOneWidget);

      // Scroll agenda into view, then drag on it
      final agendaFinder = find.byKey(const Key('selected-day-agenda'));
      await tester.scrollUntilVisible(
        agendaFinder,
        150,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      await tester.drag(agendaFinder, const Offset(-100, 0));
      await tester.pumpAndSettle();

      // Month must NOT have changed
      expect(find.text('September, 2026'), findsOneWidget);
      expect(find.text('October, 2026'), findsNothing);
    });
  });
}
