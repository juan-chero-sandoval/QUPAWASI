import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qupa_wasi/app/routes.dart';

import '../helpers/test_app.dart';
import '../helpers/load_fonts.dart';

/// Pantallas pequeñas y texto ampliado no deben producir overflow.
/// Un overflow de layout hace fallar la prueba con una excepción.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadProjectFonts);
  const widths = [320.0, 360.0, 375.0, 412.0, 800.0];
  const textScales = [1.0, 1.3, 2.0];
  const locations = [
    AppRoutes.welcome,
    AppRoutes.home,
    AppRoutes.recycling,
    '${AppRoutes.recycling}/new',
    AppRoutes.map,
    AppRoutes.rewards,
    AppRoutes.profile,
    AppRoutes.ranking,
    AppRoutes.suggestions,
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
            // Build every lazily laid-out section, including badges/catalog.
            for (var scroll = 0; scroll < 25; scroll++) {
              final list = find.byType(Scrollable).hitTestable().first;
              final state = tester.state<ScrollableState>(list);
              if (state.position.pixels >= state.position.maxScrollExtent) {
                break;
              }
              await tester.drag(list, const Offset(0, -450));
              await tester.pumpAndSettle();
              expect(
                tester.takeException(),
                isNull,
                reason: '$location scroll $scroll',
              );
            }
          }
        }
        tester.platformDispatcher.clearPlatformBrightnessTestValue();
      });
    }
  }

  for (final dark in [false, true]) {
    testWidgets('horizontal y movimiento reducido, tema oscuro $dark', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(812, 375);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      tester.platformDispatcher.platformBrightnessTestValue = dark
          ? Brightness.dark
          : Brightness.light;
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      for (final location in locations) {
        resetPreferencesStore(
          location == AppRoutes.welcome ? const {} : onboardedStore,
        );
        await openApp(tester, initialLocation: location);
        expect(tester.takeException(), isNull, reason: location);
      }
    });
  }
}
