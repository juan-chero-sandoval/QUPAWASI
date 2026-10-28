import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qupa_wasi/app/routes.dart';

import '../helpers/test_app.dart';

/// Pantallas pequeñas y texto ampliado no deben producir overflow.
/// Un overflow de layout hace fallar la prueba con una excepción.
void main() {
  const widths = [320.0, 360.0, 412.0];
  const textScales = [1.0, 1.3, 2.0];
  const locations = [
    AppRoutes.welcome,
    AppRoutes.home,
    AppRoutes.recycling,
    AppRoutes.map,
    AppRoutes.rewards,
    AppRoutes.profile,
  ];

  for (final width in widths) {
    for (final scale in textScales) {
      testWidgets('sin overflow a $width dp y texto ${scale}x', (tester) async {
        tester.view.devicePixelRatio = 2;
        tester.view.physicalSize = Size(width * 2, 700 * 2);
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        for (final location in locations) {
          resetPreferencesStore(
            location == AppRoutes.welcome ? const {} : onboardedStore,
          );
          for (final dark in [false, true]) {
            tester.platformDispatcher.platformBrightnessTestValue = dark
                ? Brightness.dark
                : Brightness.light;
            await openApp(tester, initialLocation: location);
            expect(tester.takeException(), isNull, reason: location);
          }
        }
        tester.platformDispatcher.clearPlatformBrightnessTestValue();
      });
    }
  }
}
