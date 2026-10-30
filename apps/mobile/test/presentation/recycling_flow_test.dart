import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qupa_wasi/app/routes.dart';
import 'package:qupa_wasi/data/local/demo_seed.dart';

import '../helpers/fake_local_services.dart';
import '../helpers/qr_payload.dart';
import '../helpers/test_app.dart';

void main() {
  late FakeLocal f;
  setUp(() async {
    resetPreferencesStore(onboardedStore);
    f = FakeLocal();
  });

  testWidgets('alta QR, confirmación de solo lectura, saldo y eliminación', (
    tester,
  ) async {
    await openApp(
      tester,
      initialLocation: AppRoutes.recycling,
      services: f.services,
      scanQr: () async => qrPayload(),
    );
    await tapVisible(tester, find.text('Nuevo registro'));
    expect(find.byKey(const Key('quantity-field')), findsNothing);
    await tapVisible(tester, find.text('Escanear QR'));
    expect(find.text('PET × 2'), findsOneWidget);
    expect(find.text('+20 EcoPuntos'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    await tapVisible(tester, find.text('Confirmar reciclaje'));
    expect(find.text('Detalle del registro'), findsOneWidget);
    expect(find.text('Editar'), findsNothing);
    await tapVisible(tester, find.text('Editar nota'));
    await tester.enterText(find.byType(TextField), 'Nota después de escanear');
    await tapVisible(tester, find.text('Guardar nota'));
    expect(find.text('Nota después de escanear'), findsOneWidget);
    expect((await f.services.overview.getStatistics()).availablePoints, 20);
    await tapVisible(tester, find.text('Eliminar'));
    await tester.tap(find.widgetWithText(FilledButton, 'Eliminar'));
    await tester.pumpAndSettle();
    expect(find.text('Aún no tienes registros'), findsOneWidget);
    expect((await f.services.overview.getStatistics()).availablePoints, 0);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('QR inválido y cancelación de cámara no crean registro', (
    tester,
  ) async {
    var count = 0;
    await openApp(
      tester,
      initialLocation: AppRoutes.newRecord(),
      services: f.services,
      scanQr: () async => count++ == 0 ? null : 'QR incorrecto',
    );
    await tapVisible(tester, find.text('Escanear QR'));
    expect(find.text('Confirmar reciclaje'), findsNothing);
    await tapVisible(tester, find.text('Escanear QR'));
    expect(find.textContaining('QR de reciclaje inválido'), findsOneWidget);
    expect(f.records.all, isEmpty);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('mapa transmite tacho esperado y rechaza QR de otro tacho', (
    tester,
  ) async {
    await openApp(
      tester,
      initialLocation: AppRoutes.mapPoint(pointId: DemoSeed.libraryId),
      services: f.services,
      scanQr: () async => qrPayload(),
    );
    await tapVisible(tester, find.text('Registrar en este punto'));
    await tapVisible(tester, find.text('Escanear QR'));
    expect(find.textContaining('corresponde a otro tacho'), findsOneWidget);
    expect(find.text('Confirmar reciclaje'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('un reescaneo abre el mismo registro sin puntos duplicados', (
    tester,
  ) async {
    final record = await f.services.deposits!.accept(
      f.services.deposits!.decode(qrPayload()),
    );
    await openApp(
      tester,
      initialLocation: AppRoutes.newRecord(),
      services: f.services,
      scanQr: () async => qrPayload(),
    );
    await tapVisible(tester, find.text('Escanear QR'));
    await tapVisible(tester, find.text('Confirmar reciclaje'));
    await scrollTo(tester, find.text(record.id));
    expect(find.text(record.id), findsOneWidget);
    expect(f.records.all, hasLength(1));
    expect((await f.services.overview.getStatistics()).availablePoints, 20);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'registros manuales anteriores siguen editables con borrador al pausar',
    (tester) async {
      final record = await f.seedRecord();
      await openApp(
        tester,
        initialLocation: AppRoutes.editRecord(record.id),
        services: f.services,
      );
      await tapVisible(tester, find.text('Siguiente'));
      final quantity = find.byKey(const Key('quantity-field'));
      await tester.enterText(quantity, '1.5');
      await tapVisible(tester, find.text('Siguiente'));
      expect(
        find.text('Usa un número entero, sin decimales ni signos.'),
        findsOneWidget,
      );
      await tester.enterText(quantity, '3');
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pumpAndSettle();
      expect(
        (await f.services.drafts.load('recycling-edit'))!.quantityText,
        '3',
      );
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      await tapVisible(tester, find.text('Siguiente'));
      await tapVisible(tester, find.text('Guardar cambios'));
      expect(find.text('PET × 3'), findsOneWidget);
      expect((await f.services.recycling.get(record.id))!.quantity, 3);
      expect((await f.services.overview.getStatistics()).availablePoints, 30);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
