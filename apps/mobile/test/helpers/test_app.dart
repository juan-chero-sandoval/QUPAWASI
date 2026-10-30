import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qupa_wasi/app/app.dart';
import 'package:qupa_wasi/app/dependencies.dart';
import 'package:qupa_wasi/app/local_services.dart';
import 'package:qupa_wasi/domain/entities/geo_position.dart';
import 'package:qupa_wasi/app/routes.dart';
import 'package:qupa_wasi/data/preferences/shared_preferences_repository.dart';
import 'package:qupa_wasi/presentation/settings/app_settings_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'fake_local_services.dart';

/// Almacén de preferencias en memoria compartido entre "aperturas" de la app.
void resetPreferencesStore([Map<String, Object> data = const {}]) {
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.withData(data);
}

/// Simula abrir la app: repositorio y ViewModel nuevos sobre el mismo
/// almacén, como hace `main()`.
///
/// [local] conserva los registros entre aperturas dentro de una prueba.
Future<AppSettingsViewModel> openApp(
  WidgetTester tester, {
  String initialLocation = AppRoutes.home,
  FakeLocal? local,
  LocalServices? services,
  Future<String?> Function()? scanQr,
  Future<GeoPosition> Function()? locate,
  Stream<bool>? internetChanges,
}) async {
  final repository = SharedPreferencesRepository(SharedPreferencesAsync());
  final settings = AppSettingsViewModel(repository);
  await settings.load();
  // Desmonta una instancia previa para empezar con un router nuevo.
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpWidget(
    QupaWasiApp(
      dependencies: AppDependencies(
        preferencesRepository: repository,
        local: services ?? (local ?? FakeLocal()).services,
        scanQr: scanQr,
        locate: locate,
        internetChanges: internetChanges,
      ),
      settings: settings,
      initialLocation: initialLocation,
    ),
  );
  await tester.pumpAndSettle();
  return settings;
}

/// Preferencias de una app con onboarding ya completado.
const Map<String, Object> onboardedStore = {
  SharedPreferencesRepository.onboardingKey: true,
};

Finder navTab(String label) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label));

/// Desplaza la lista principal hasta construir el elemento (ListView es
/// perezosa) y lo toca. Usar [delta] negativo para buscar hacia arriba.
Future<void> tapVisible(
  WidgetTester tester,
  Finder finder, {
  double delta = 200,
}) async {
  await scrollTo(tester, finder, delta: delta);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> scrollTo(
  WidgetTester tester,
  Finder finder, {
  double delta = 200,
}) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      delta,
      scrollable: find.byType(Scrollable).hitTestable().first,
    );
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

/// Botón volver del AppBar (el tooltip está en español, no "Back").
Future<void> tapAppBarBack(WidgetTester tester) async {
  await tester.tap(find.byType(BackButton));
  await tester.pumpAndSettle();
}
