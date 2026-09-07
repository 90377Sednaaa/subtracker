import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subtracker/core/theme.dart';
import 'package:subtracker/features/auth/ui/otp_input_row.dart';

void main() {
  testWidgets('renders 6 distinct OTP boxes', (tester) async {
    String? completedCode;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildSublyTheme(Brightness.dark),
        home: Scaffold(
          body: OtpInputRow(
            onCompleted: (code) => completedCode = code,
          ),
        ),
      ),
    );

    for (var i = 0; i < 6; i++) {
      expect(find.byKey(Key('otp-box-$i')), findsOneWidget);
    }
    expect(completedCode, isNull);
  });

  testWidgets('pasting 6-digit code fills all boxes and fires onCompleted',
      (tester) async {
    String? completedCode;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildSublyTheme(Brightness.dark),
        home: Scaffold(
          body: OtpInputRow(
            onCompleted: (code) => completedCode = code,
          ),
        ),
      ),
    );

    // Paste into box 0
    await tester.enterText(find.byKey(const Key('otp-box-0')), '482915');
    await tester.pumpAndSettle();

    expect(find.text('4'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);

    expect(completedCode, equals('482915'));
  });

  testWidgets('typing digits individually fires onCompleted when full',
      (tester) async {
    String? completedCode;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildSublyTheme(Brightness.dark),
        home: Scaffold(
          body: OtpInputRow(
            onCompleted: (code) => completedCode = code,
          ),
        ),
      ),
    );

    final digits = ['7', '3', '1', '9', '4', '0'];
    for (var i = 0; i < digits.length; i++) {
      await tester.enterText(find.byKey(Key('otp-box-$i')), digits[i]);
      await tester.pumpAndSettle();
    }

    expect(completedCode, equals('731940'));
  });

  testWidgets('backspace on empty box navigates and clears previous box',
      (tester) async {
    final key = GlobalKey<OtpInputRowState>();
    await tester.pumpWidget(
      MaterialApp(
        theme: buildSublyTheme(Brightness.dark),
        home: Scaffold(
          body: OtpInputRow(
            key: key,
            onCompleted: (_) {},
          ),
        ),
      ),
    );

    await tester.enterText(find.byKey(const Key('otp-box-0')), '5');
    await tester.pumpAndSettle();
    expect(find.text('5'), findsOneWidget);

    // Box 1 should now be focused, press backspace
    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.pumpAndSettle();

    // Box 0 should be cleared
    expect(find.text('5'), findsNothing);
  });
}
