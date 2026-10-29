import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qupa_wasi/app/app.dart';
import 'package:qupa_wasi/app/dependencies.dart';
import 'package:qupa_wasi/presentation/settings/app_settings_view_model.dart';

/// Composición de producción: plugins nativos y archivo SQLite, sin mocks.
class NativeApp {
  late AppDependencies deps;
  late AppSettingsViewModel settings;

  Future<void> open(WidgetTester tester, String location) async {
    deps = await AppDependencies.create();
    settings = AppSettingsViewModel(deps.preferencesRepository);
    await settings.load();
    await tester.pumpWidget(
      QupaWasiApp(
        dependencies: deps,
        settings: settings,
        initialLocation: location,
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    settings.dispose();
    await deps.close();
  }
}

Future<void> waitVisible(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 150; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('No apareció: $finder');
}

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  FocusManager.instance.primaryFocus?.unfocus();
  // El IME Android puede responder después de terminar las animaciones Flutter.
  // Esperar antes de cambiar el foco evita que un evento nativo viejo vacíe
  // la siguiente entrada del runner de integración.
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  await tester.pumpAndSettle();
  await waitVisible(tester, finder);
  await tester.ensureVisible(finder.first);
  await tester.pumpAndSettle();
  await tester.tap(finder.first);
  await tester.pumpAndSettle();
}

Future<void> enterNativeText(
  WidgetTester tester,
  Finder finder,
  String text,
) async {
  await tapVisible(tester, finder);
  await tester.enterText(finder, text);
  await tester.pumpAndSettle();
  expect(tester.widget<TextField>(finder).controller!.text, text);
}
