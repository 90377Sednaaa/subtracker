import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:subtracker/core/theme.dart';
import 'package:subtracker/features/subscriptions/domain/preset_service.dart';
import 'package:subtracker/features/subscriptions/ui/subscription_catalog_screen.dart';

class _TestNavObserver extends NavigatorObserver {
  bool popped = false;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    popped = true;
    super.didPop(route, previousRoute);
  }
}

void main() {
  Widget buildScreen({ValueChanged<PresetService?>? onSelect}) {
    return MaterialApp(
      theme: buildSublyTheme(Brightness.dark),
      home: SubscriptionCatalogScreen(
        onSelect: onSelect ?? (_) {},
      ),
    );
  }

  testWidgets('renders Cancel button, Add Subscription title, and Custom card',
      (tester) async {
    await tester.pumpWidget(buildScreen());
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Add Subscription'), findsOneWidget);
    expect(find.byKey(const Key('custom-service-card')), findsOneWidget);
    expect(find.text('Custom'), findsOneWidget);
  });

  testWidgets('tapping custom card invokes onSelect with null', (tester) async {
    PresetService? selected;
    var invoked = false;
    await tester.pumpWidget(buildScreen(onSelect: (val) {
      invoked = true;
      selected = val;
    }));

    await tester.tap(find.byKey(const Key('custom-service-card')));
    await tester.pumpAndSettle();
    expect(invoked, isTrue);
    expect(selected, isNull);
  });

  testWidgets('search bar filters services in real time', (tester) async {
    await tester.pumpWidget(buildScreen());
    expect(find.text('Netflix'), findsOneWidget);
    expect(find.text('Spotify'), findsOneWidget);

    // Using prefix 'Spot' so find.text('Spotify') finds only the card Text widget
    // without colliding with the EditableText inside the search field.
    await tester.enterText(
        find.byKey(const Key('catalog-search-field')), 'Spot');
    await tester.pumpAndSettle();

    expect(find.text('Spotify'), findsOneWidget);
    expect(find.text('Netflix'), findsNothing);
  });

  testWidgets('search bar with exact name filters grid to matching card',
      (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.enterText(
        find.byKey(const Key('catalog-search-field')), 'Spotify');
    await tester.pumpAndSettle();

    expect(find.widgetWithText(InkWell, 'Spotify'), findsOneWidget);
    expect(find.text('Netflix'), findsNothing);
  });

  testWidgets('tapping a preset service invokes onSelect with that service',
      (tester) async {
    PresetService? selected;
    await tester.pumpWidget(buildScreen(onSelect: (val) {
      selected = val;
    }));

    await tester.tap(find.text('Netflix'));
    await tester.pumpAndSettle();
    expect(selected?.name, 'Netflix');
  });

  testWidgets('empty search state displays message and allows adding custom',
      (tester) async {
    PresetService? selected;
    var invoked = false;
    await tester.pumpWidget(buildScreen(onSelect: (val) {
      invoked = true;
      selected = val;
    }));

    await tester.enterText(
        find.byKey(const Key('catalog-search-field')), 'NonExistentService123');
    await tester.pumpAndSettle();

    expect(find.text('Netflix'), findsNothing);
    expect(find.textContaining('No services found'), findsOneWidget);

    final addCustomBtn = find.byKey(const Key('empty-add-custom-button'));
    expect(addCustomBtn, findsOneWidget);
    await tester.tap(addCustomBtn);
    await tester.pumpAndSettle();
    expect(invoked, isTrue);
    expect(selected, isNull);
  });

  testWidgets('tapping cancel button attempts to pop navigator',
      (tester) async {
    final observer = _TestNavObserver();
    await tester.pumpWidget(
      MaterialApp(
        theme: buildSublyTheme(Brightness.dark),
        navigatorObservers: [observer],
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SubscriptionCatalogScreen(),
                  ),
                );
              },
              child: const Text('Open Catalog'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Catalog'));
    await tester.pumpAndSettle();

    expect(find.text('Cancel'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(observer.popped, isTrue);
  });

  testWidgets('tapping preset without onSelect pushes to /subs/new/config',
      (tester) async {
    final router = GoRouter(
      initialLocation: '/subs/new',
      routes: [
        GoRoute(
          path: '/subs/new',
          builder: (_, _) => const SubscriptionCatalogScreen(),
        ),
        GoRoute(
          path: '/subs/new/config',
          builder: (context, state) {
            final service = state.extra as PresetService?;
            return Scaffold(
              body: Text('Config Screen: ${service?.name ?? "custom"}'),
            );
          },
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        theme: buildSublyTheme(Brightness.dark),
        routerConfig: router,
      ),
    );

    await tester.tap(find.text('Netflix'));
    await tester.pumpAndSettle();

    expect(find.text('Config Screen: Netflix'), findsOneWidget);
  });

  testWidgets(
      'tapping custom without onSelect pushes to /subs/new/config with null extra',
      (tester) async {
    final router = GoRouter(
      initialLocation: '/subs/new',
      routes: [
        GoRoute(
          path: '/subs/new',
          builder: (_, _) => const SubscriptionCatalogScreen(),
        ),
        GoRoute(
          path: '/subs/new/config',
          builder: (context, state) {
            final service = state.extra as PresetService?;
            return Scaffold(
              body: Text('Config Screen: ${service?.name ?? "custom"}'),
            );
          },
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        theme: buildSublyTheme(Brightness.dark),
        routerConfig: router,
      ),
    );

    await tester.tap(find.byKey(const Key('custom-service-card')));
    await tester.pumpAndSettle();

    expect(find.text('Config Screen: custom'), findsOneWidget);
  });
}
