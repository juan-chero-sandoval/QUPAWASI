import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:qupa_wasi/app/app.dart';
import 'package:qupa_wasi/app/dependencies.dart';
import 'package:qupa_wasi/app/routes.dart';
import 'package:qupa_wasi/domain/entities/recycling_record.dart';
import 'package:qupa_wasi/presentation/settings/app_settings_view_model.dart';

/// Recorrido CRUD en un dispositivo con la base SQLite real de la app.
/// Entre pasos se cierra la conexión y se abre otra, como al reiniciar.
/// Usa una nota única y borra su propio registro al final.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final quantityField = find.byKey(const Key('quantity-field'));
  final noteField = find.byKey(const Key('note-field'));

  Future<void> pumpUntil(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 100; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (finder.evaluate().isNotEmpty) return;
    }
    fail('No apareció: $finder');
  }

  /// Cierra el teclado nativo y espera a que el área visible se estabilice;
  /// si no, la posición calculada para el toque queda obsoleta.
  Future<void> hideKeyboard(WidgetTester tester) async {
    FocusManager.instance.primaryFocus?.unfocus();
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await hideKeyboard(tester);
    await pumpUntil(tester, finder);
    await tester.ensureVisible(finder.first);
    await tester.pumpAndSettle();
    await tester.tap(finder.first);
    await tester.pumpAndSettle();
  }

  Future<AppDependencies> open(WidgetTester tester, String location) async {
    final dependencies = await AppDependencies.create();
    final settings = AppSettingsViewModel(dependencies.preferencesRepository);
    await settings.load();
    if (!settings.onboardingCompleted) await settings.completeOnboarding();
    await tester.pumpWidget(
      QupaWasiApp(
        dependencies: dependencies,
        settings: settings,
        initialLocation: location,
      ),
    );
    await tester.pumpAndSettle();
    return dependencies;
  }

  Future<void> close(WidgetTester tester, AppDependencies deps) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await deps.close();
  }

  Future<RecyclingRecord?> findByNote(AppDependencies deps, String note) async {
    final all = await deps.local.recycling.watch().first;
    final matches = all.where((r) => r.note == note).toList();
    expect(matches.length, lessThanOrEqualTo(1), reason: 'sin duplicados');
    return matches.isEmpty ? null : matches.single;
  }

  testWidgets('crear, reabrir, editar el mismo ID y eliminar (M04–M07)', (
    tester,
  ) async {
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final note = 'prueba-$stamp';
    final edited = 'editada-$stamp';

    // M04 Crear PET 2 en Arquitectura.
    var deps = await open(tester, AppRoutes.recycling);
    await tap(tester, find.text('Nuevo registro'));
    if (find.text('Descartar y empezar de nuevo').evaluate().isNotEmpty) {
      await tap(tester, find.text('Descartar y empezar de nuevo'));
    }
    await tap(tester, find.text('Arquitectura'));
    await tap(tester, find.text('Siguiente'));
    await tap(tester, find.text('PET'));
    await tester.enterText(quantityField, '2');
    await tester.enterText(noteField, note);
    await tester.pump();
    await tap(tester, find.text('Siguiente'));
    expect(find.text('+20 EcoPuntos simulados'), findsOneWidget);
    await tap(tester, find.text('Guardar registro'));
    await pumpUntil(tester, find.text('Detalle del registro'));
    final created = (await findByNote(deps, note))!;
    expect(find.text(created.id), findsOneWidget);
    expect(created.earnedPoints, 20);

    // M05 Persistir: nueva conexión al mismo archivo SQLite.
    await close(tester, deps);
    deps = await open(tester, AppRoutes.recordDetail(created.id));
    await pumpUntil(tester, find.text(note));
    expect(find.text('PET × 2'), findsOneWidget);

    // M06 Actualizar a PET 3 con nota nueva: mismo ID, una sola fila.
    await tap(tester, find.text('Editar'));
    await tap(tester, find.text('Siguiente'));
    await tester.enterText(quantityField, '3');
    await tester.enterText(noteField, edited);
    await tester.pump();
    await tap(tester, find.text('Siguiente'));
    await tap(tester, find.text('Guardar cambios'));
    await pumpUntil(tester, find.text('PET × 3'));
    final updated = (await findByNote(deps, edited))!;
    expect(updated.id, created.id);
    expect(updated.earnedPoints, 30);
    expect(await findByNote(deps, note), isNull);

    // M07 Eliminar con confirmación y comprobar tras reabrir.
    await tap(tester, find.text('Eliminar'));
    await tester.tap(find.widgetWithText(FilledButton, 'Eliminar'));
    await pumpUntil(tester, find.text('Mis registros'));
    await close(tester, deps);
    deps = await open(tester, AppRoutes.recordDetail(created.id));
    await pumpUntil(tester, find.text('Registro no encontrado'));
    expect(await deps.local.recycling.get(created.id), isNull);
    await close(tester, deps);
  });
}
