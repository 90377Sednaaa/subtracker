import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subtracker/core/brand/brand.dart';

/// Renders the launcher icon from the code-drawn mark. Run via
/// `flutter test test/design/generate_app_icon_test.dart` to refresh
/// assets/branding/subly_icon_1024.png, then `dart run flutter_launcher_icons`.
void main() {
  testWidgets('renders the 1024px launcher icon', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1024, 1024);
    addTearDown(tester.view.reset);

    const key = Key('icon-boundary');
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: Container(
          color: const Color(0xFF0A0A0C),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(1024 * 0.18),
          child: const SublyMark(size: 1024 * 0.60, color: Color(0xFFF2F0EB)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final boundary =
        tester.renderObject<RenderRepaintBoundary>(find.byKey(key));
    // Rasterization needs real async — runAsync escapes the fake-async zone,
    // inside which toImage() would hang forever.
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 1.0);
      expect(image.width, 1024);
      expect(image.height, 1024);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      final out = File('assets/branding/subly_icon_1024.png');
      out.writeAsBytesSync(byteData!.buffer.asUint8List());
      expect(out.lengthSync(), greaterThan(1000));
    });
  });
}
