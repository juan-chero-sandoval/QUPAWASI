import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qupa_wasi/app/routes.dart';

import '../helpers/test_app.dart';

void main() {
  for (final dark in [false, true]) {
    testWidgets(
      'F04 controles etiquetados, táctiles y contraste en tema $dark',
      (tester) async {
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
          await expectLater(
            tester,
            meetsGuideline(textContrastGuideline),
            reason: route,
          );
        }
        semantics.dispose();
      },
    );
  }
}
