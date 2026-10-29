import 'package:flutter/material.dart';

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qupa_wasi/app/routes.dart';

import '../helpers/test_app.dart';
import '../helpers/load_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadProjectFonts);
  for (final dark in [false, true]) {
    testWidgets('F04 controles etiquetados, táctiles y contraste en tema $dark', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      tester.platformDispatcher.platformBrightnessTestValue = dark
          ? Brightness.dark
          : Brightness.light;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      for (final route in [
        AppRoutes.home,
        AppRoutes.map,
        AppRoutes.rewards,
        AppRoutes.profile,
        AppRoutes.suggestions,
      ]) {
        resetPreferencesStore(onboardedStore);
        await openApp(tester, initialLocation: route);
        await expectLater(
          tester,
          meetsGuideline(labeledTapTargetGuideline),
          reason: route,
        );
        await expectLater(
          tester,
          meetsGuideline(androidTapTargetGuideline),
          reason: route,
        );
        try {
          await expectLater(
            tester,
            meetsGuideline(textContrastGuideline),
            reason: route,
          );
        } catch (_) {
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byType(RepaintBoundary).first,
          );
          await tester.runAsync(() async {
            final image = await boundary.toImage();
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final file = File(
              '../../artifacts/c02/a11y-${dark ? 'dark' : 'light'}-${route.substring(1)}.png',
            );
            await file.parent.create(recursive: true);
            await file.writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
          rethrow;
        }
      }
      semantics.dispose();
    });
  }
}
