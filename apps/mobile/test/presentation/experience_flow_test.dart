import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qupa_wasi/app/routes.dart';
import 'package:qupa_wasi/data/local/demo_seed.dart';
import 'package:qupa_wasi/domain/entities/recycling_record.dart';
import 'package:qupa_wasi/presentation/home/widgets/points_summary_card.dart';

import '../helpers/fake_local_services.dart';
import '../helpers/test_app.dart';

void main() {
  setUp(() => resetPreferencesStore(onboardedStore));
  testWidgets('Inicio reacciona a CRUD y Perfil comparte nivel e insignias', (
    tester,
  ) async {
    final local = FakeLocal();
    await openApp(tester, local: local);
    final record = await local.seedRecord();
    await tester.pumpAndSettle();
    expect(
      tester.widget<PointsSummaryCard>(find.byType(PointsSummaryCard)).points,
      20,
    );
    await local.records.update(
      record.id,
      RecordInput(
        pointId: record.pointId,
        material: record.material,
        quantity: 25,
        occurredAt: record.occurredAt,
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<PointsSummaryCard>(find.byType(PointsSummaryCard)).points,
      250,
    );
    await tester.tap(navTab('Perfil'));
    await tester.pumpAndSettle();
    expect(find.text('Nivel Brote · alias local'), findsOneWidget);
    await local.records.delete(record.id);
    await tester.pumpAndSettle();
    expect(find.text('Nivel Semilla · alias local'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    expect(local.records.activeWatchers, 0);
  });

  testWidgets('Premios filtra el catálogo y explica puntos faltantes', (
    tester,
  ) async {
    await openApp(tester, initialLocation: AppRoutes.rewards);
    await tapVisible(tester, find.text('Saldo móvil'));
    expect(find.text('Recarga S/ 1.00 simulada'), findsOneWidget);
    expect(find.text('50% en fotocopias'), findsNothing);
    await scrollTo(tester, find.text('Te faltan 100 puntos'));
    expect(find.text('Te faltan 100 puntos'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Canjear'))
          .onPressed,
      isNull,
    );
  });

  testWidgets('Mapa maneja ID ausente y permite elegir UUID válido', (
    tester,
  ) async {
    await openApp(
      tester,
      initialLocation: AppRoutes.mapPoint(pointId: 'ausente'),
    );
    await scrollTo(
      tester,
      find.text('Punto no encontrado. Elige uno de la lista.'),
    );
    expect(find.text('Registrar en este punto'), findsNothing);
    await tapVisible(
      tester,
      find.byKey(const ValueKey('point-${DemoSeed.libraryId}')),
      delta: -200,
    );
    await tapVisible(tester, find.text('Registrar en este punto'));
    expect(find.text('Nuevo registro'), findsOneWidget);
  });

  testWidgets('Sugerencia inválida conserva texto y muestra error de campo', (
    tester,
  ) async {
    await openApp(tester, initialLocation: AppRoutes.suggestions);
    await tester.enterText(find.byType(TextField), ' x ');
    await tapVisible(tester, find.text('Guardar localmente'));
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      ' x ',
    );
    expect(
      tester.widget<TextField>(find.byType(TextField)).decoration!.errorText,
      isNotNull,
    );
    expect(
      find.text('Solo en este dispositivo; no se ha enviado'),
      findsOneWidget,
    );
  });
}
