import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subtracker/core/brand/brand.dart';
import 'package:subtracker/core/theme.dart';

void main() {
  testWidgets('SublyLogoBadge renders white background with black S in dark mode',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildSublyTheme(Brightness.dark),
        home: const Scaffold(
          body: SublyLogoBadge(size: 40, radius: 2.0),
        ),
      ),
    );

    final containerFinder = find.byType(Container);
    expect(containerFinder, findsOneWidget);
    final container = tester.widget<Container>(containerFinder);
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, equals(Colors.white));
    expect(decoration.borderRadius, equals(BorderRadius.circular(2.0)));

    final markFinder = find.byType(SublyMark);
    expect(markFinder, findsOneWidget);
    final mark = tester.widget<SublyMark>(markFinder);
    expect(mark.color, equals(const Color(0xFF0A0A0C)));
  });

  testWidgets('SublyLogoBadge renders black background with white S in light mode',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildSublyTheme(Brightness.light),
        home: const Scaffold(
          body: SublyLogoBadge(size: 40, radius: 2.0),
        ),
      ),
    );

    final containerFinder = find.byType(Container);
    expect(containerFinder, findsOneWidget);
    final container = tester.widget<Container>(containerFinder);
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, equals(const Color(0xFF0A0A0C)));
    expect(decoration.borderRadius, equals(BorderRadius.circular(2.0)));

    final markFinder = find.byType(SublyMark);
    expect(markFinder, findsOneWidget);
    final mark = tester.widget<SublyMark>(markFinder);
    expect(mark.color, equals(Colors.white));
  });
}
