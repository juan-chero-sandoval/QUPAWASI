import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qupa_wasi/app/routes.dart';
import 'package:qupa_wasi/domain/entities/recycling_draft.dart';
import 'package:qupa_wasi/domain/errors/local_data_exception.dart';
import 'package:qupa_wasi/presentation/recycling/record_detail_view.dart';
import 'package:qupa_wasi/presentation/recycling/record_form_view_model.dart';
import 'package:qupa_wasi/presentation/recycling/recycling_view.dart';

import '../helpers/fake_local_services.dart';
import '../helpers/test_app.dart';

void main() {
  setUp(() => resetPreferencesStore(onboardedStore));

  final quantityField = find.byKey(const Key('quantity-field'));
  final noteField = find.byKey(const Key('note-field'));

  Future<void> next(WidgetTester tester) =>
      tapVisible(tester, find.text('Siguiente'));

  Future<void> fillNew(
    WidgetTester tester, {
    String point = 'Arquitectura',
    String quantity = '2',
    String note = 'prueba',
  }) async {
    await tapVisible(tester, find.text(point));
    await next(tester);
    await tapVisible(tester, find.text('PET'));
    await tester.enterText(quantityField, quantity);
    await tester.enterText(noteField, note);
    await tester.pump();
    await next(tester);
  }

  testWidgets('CRUD visible: crear, ver, editar y eliminar el mismo ID', (
    tester,
  ) async {
    final local = FakeLocal();
    await openApp(tester, initialLocation: AppRoutes.recycling, local: local);
    expect(find.text('Aún no tienes registros'), findsOneWidget);

    // Crear
    await tapVisible(tester, find.text('Nuevo registro'));
    await fillNew(tester);
    expect(find.text('+20 EcoPuntos simulados'), findsOneWidget);
    await tapVisible(tester, find.text('Guardar registro'));
    expect(find.byType(RecordDetailView), findsOneWidget);
    expect(find.text('Registro guardado.'), findsOneWidget);
    final id = local.records.all.single.id;
    expect(find.text(id), findsOneWidget);
    expect(find.text('PET × 2'), findsOneWidget);

    // Leer en la lista
    await tapAppBarBack(tester);
    expect(find.byType(RecyclingView), findsOneWidget);
    expect(find.text('PET × 2'), findsOneWidget);

    // Actualizar
    await tapVisible(tester, find.text('PET × 2'));
    await tapVisible(tester, find.text('Editar'));
    expect(find.text('Editar registro'), findsOneWidget);
    await next(tester);
    expect(
      tester.widget<TextField>(quantityField).controller!.text,
      '2',
      reason: 'el formulario se precarga con lo guardado',
    );
    await tester.enterText(quantityField, '3');
    await tester.enterText(noteField, 'editada');
    await tester.pump();
    await next(tester);
    await tapVisible(tester, find.text('Guardar cambios'));
    expect(find.text('Registro actualizado.'), findsOneWidget);
    expect(find.text('PET × 3'), findsOneWidget);
    expect(find.text('+30'), findsOneWidget);
    expect(local.records.all, hasLength(1));
    expect(local.records.all.single.id, id);

    // Eliminar: cancelar no cambia nada
    await tapVisible(tester, find.text('Eliminar'));
    expect(find.textContaining('PET × 3 en Arquitectura'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(local.records.all, hasLength(1));

    await tapVisible(tester, find.text('Eliminar'));
    await tester.tap(find.widgetWithText(FilledButton, 'Eliminar'));
    await tester.pumpAndSettle();
    expect(local.records.all, isEmpty);
    expect(find.byType(RecyclingView), findsOneWidget);
    expect(find.text('Aún no tienes registros'), findsOneWidget);
    expect(find.text('Registro eliminado.'), findsOneWidget);
  });

  testWidgets('errores de cantidad aparecen junto al campo', (tester) async {
    await openApp(tester, initialLocation: AppRoutes.newRecord());
    await tapVisible(tester, find.text('Arquitectura'));
    await next(tester);
    await tapVisible(tester, find.text('PET'));

    await tester.enterText(quantityField, '1.5');
    await next(tester);
    expect(
      find.text('Usa un número entero, sin decimales ni signos.'),
      findsOneWidget,
    );
    await tester.enterText(quantityField, '101');
    await next(tester);
    expect(find.text('La cantidad debe estar entre 1 y 100.'), findsOneWidget);
  });

  testWidgets('doble toque en Guardar crea un solo registro', (tester) async {
    final local = FakeLocal();
    local.records.writeGate = Completer<void>();
    await openApp(tester, initialLocation: AppRoutes.newRecord(), local: local);
    await fillNew(tester);

    await tester.tap(find.text('Guardar registro'));
    await tester.pump();
    // Segundo toque mientras la primera escritura sigue en curso.
    await tester.tap(find.text('Guardar registro'), warnIfMissed: false);
    await tester.pump();
    local.records.writeGate!.complete();
    await tester.pumpAndSettle();

    expect(local.records.createCalls, 1);
    expect(local.records.all, hasLength(1));
  });

  testWidgets('si falla la escritura no hay éxito y se conservan los datos', (
    tester,
  ) async {
    final local = FakeLocal();
    local.records.failNextWrite = const LocalDataException(
      LocalDataError.storage,
      'No se pudo acceder al almacenamiento local. Intenta nuevamente.',
    );
    await openApp(tester, initialLocation: AppRoutes.newRecord(), local: local);
    await fillNew(tester, quantity: '4');

    await tapVisible(tester, find.text('Guardar registro'));

    expect(find.textContaining('almacenamiento local'), findsOneWidget);
    expect(find.text('Guardar registro'), findsOneWidget);
    expect(local.records.all, isEmpty);
    expect(
      local.drafts.rows[RecordFormViewModel.newDraftKey]!.quantityText,
      '4',
    );

    // Reintento con los mismos datos.
    await tapVisible(tester, find.text('Guardar registro'));
    expect(local.records.all, hasLength(1));
    expect(local.drafts.rows, isEmpty);
  });

  testWidgets('pasar a segundo plano guarda el borrador sin esperar', (
    tester,
  ) async {
    final local = FakeLocal();
    await openApp(tester, initialLocation: AppRoutes.newRecord(), local: local);
    await tapVisible(tester, find.text('Biblioteca'));
    await next(tester);
    await tester.enterText(quantityField, '5');
    await tester.pump();
    expect(
      local.drafts.rows[RecordFormViewModel.newDraftKey]?.quantityText,
      isNot('5'),
    );

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    final draft = local.drafts.rows[RecordFormViewModel.newDraftKey]!;
    expect(draft.quantityText, '5');
    expect(draft.step, 1);
    expect(local.records.all, isEmpty, reason: 'un borrador no es registro');

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
  });

  testWidgets('volver atrás guarda el borrador y la lista lo ofrece', (
    tester,
  ) async {
    final local = FakeLocal();
    await openApp(tester, initialLocation: AppRoutes.recycling, local: local);
    await tapVisible(tester, find.text('Nuevo registro'));
    await tapVisible(tester, find.text('Comedor'));
    await next(tester);
    await tester.enterText(quantityField, '6');
    await tester.pump();

    await tapAppBarBack(tester);

    expect(
      local.drafts.rows[RecordFormViewModel.newDraftKey]!.quantityText,
      '6',
    );
    expect(find.text('Tienes un nuevo registro sin terminar'), findsOneWidget);
    await tapVisible(tester, find.text('Descartar borrador'));
    expect(local.drafts.rows, isEmpty);
    expect(find.text('Tienes un nuevo registro sin terminar'), findsNothing);
  });

  testWidgets('al reabrir se ofrece continuar o descartar el borrador', (
    tester,
  ) async {
    final local = FakeLocal();
    local.drafts.rows[RecordFormViewModel.newDraftKey] = RecyclingDraft(
      key: RecordFormViewModel.newDraftKey,
      pointId: '00000000-0000-4000-8000-000000000002',
      material: 'aluminum',
      quantityText: '7',
      note: 'pendiente',
      step: 1,
      updatedAt: local.now,
    );
    await openApp(tester, initialLocation: AppRoutes.recycling, local: local);
    expect(find.text('Tienes un nuevo registro sin terminar'), findsOneWidget);

    await tapVisible(tester, find.text('Continuar'));
    expect(find.text('Recuperamos un borrador'), findsOneWidget);
    await tapVisible(tester, find.text('Continuar borrador'));

    expect(tester.widget<TextField>(quantityField).controller!.text, '7');
    expect(tester.widget<TextField>(noteField).controller!.text, 'pendiente');
    expect(local.records.all, isEmpty);
  });
}
