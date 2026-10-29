import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qupa_wasi/app/routes.dart';
import 'package:qupa_wasi/data/local/demo_seed.dart';
import 'package:qupa_wasi/domain/entities/recycling_record.dart';
import 'package:qupa_wasi/core/widgets/prototype_banner.dart';
import 'package:qupa_wasi/presentation/common/not_found_view.dart';
import 'package:qupa_wasi/presentation/home/home_view.dart';
import 'package:qupa_wasi/presentation/map/map_view.dart';
import 'package:qupa_wasi/presentation/recycling/record_detail_view.dart';
import 'package:qupa_wasi/presentation/recycling/recycling_view.dart';

import '../helpers/fake_local_services.dart';
import '../helpers/test_app.dart';

void main() {
  setUp(() => resetPreferencesStore(onboardedStore));

  int selectedTab(WidgetTester tester) =>
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex;

  testWidgets('las cinco pestañas abren su destino y marcan la selección', (
    tester,
  ) async {
    await openApp(tester);
    const tabs = {
      'Reciclar': 1,
      'Mapa': 2,
      'Premios': 3,
      'Perfil': 4,
      'Inicio': 0,
    };
    const titles = {
      'Reciclar': 'Reciclar',
      'Mapa': 'Mapa',
      'Premios': 'Recompensas',
      'Perfil': 'Mi perfil',
    };

    for (final MapEntry(key: label, value: index) in tabs.entries) {
      await tester.tap(navTab(label));
      await tester.pumpAndSettle();
      expect(selectedTab(tester), index, reason: label);
      if (titles[label] case final title?) {
        expect(
          find.descendant(of: find.byType(AppBar), matching: find.text(title)),
          findsOneWidget,
        );
      }
      expect(find.text(PrototypeBanner.message), findsOneWidget);
    }
  });

  testWidgets('el detalle recibe el UUID por la ruta y recarga el registro', (
    tester,
  ) async {
    final local = FakeLocal();
    final record = await local.seedRecord(
      quantity: 3,
      material: RecyclingMaterial.aluminum,
      pointId: DemoSeed.libraryId,
    );
    await openApp(tester, initialLocation: AppRoutes.recycling, local: local);

    await tapVisible(tester, find.text('Lata de aluminio × 3'));

    expect(find.byType(RecordDetailView), findsOneWidget);
    expect(find.text(record.id), findsOneWidget);
    expect(find.text('Biblioteca'), findsOneWidget);
    expect(selectedTab(tester), 1);

    await tapAppBarBack(tester);
    expect(find.byType(RecyclingView), findsOneWidget);
  });

  testWidgets('un ID inexistente muestra mensaje y permite volver', (
    tester,
  ) async {
    await openApp(
      tester,
      initialLocation: AppRoutes.recordDetail('no-existe-123'),
    );

    expect(find.text('Registro no encontrado'), findsOneWidget);
    expect(find.textContaining('no-existe-123'), findsOneWidget);

    await tapVisible(tester, find.text('Volver a Reciclar'));
    expect(find.byType(RecyclingView), findsOneWidget);
  });

  testWidgets('editar un ID inexistente no abre un formulario vacío', (
    tester,
  ) async {
    await openApp(tester, initialLocation: AppRoutes.editRecord('no-existe'));

    expect(find.text('Editar registro'), findsOneWidget);
    expect(find.text('Registro no encontrado'), findsOneWidget);
    expect(find.text('Siguiente'), findsNothing);
  });

  testWidgets('el mapa reenvía su pointId al nuevo registro', (tester) async {
    await openApp(
      tester,
      initialLocation: AppRoutes.mapPoint(pointId: DemoSeed.diningId),
    );
    expect(find.byType(MapView), findsOneWidget);

    await tapVisible(tester, find.text('Registrar en este punto'));

    expect(find.text('Registrar reciclaje'), findsOneWidget);
    expect(selectedTab(tester), 1);
    expect(find.text('Escanear QR'), findsOneWidget);
    expect(find.byKey(const Key('quantity-field')), findsNothing);
  });

  testWidgets('una ruta desconocida muestra vista segura con retorno', (
    tester,
  ) async {
    await openApp(tester, initialLocation: '/ruta/que/no/existe');

    expect(find.byType(NotFoundView), findsOneWidget);

    await tapVisible(tester, find.text('Volver al inicio'));
    expect(find.byType(HomeView), findsOneWidget);
  });

  testWidgets('back de Android en otra pestaña vuelve a Inicio', (
    tester,
  ) async {
    await openApp(tester);
    await tester.tap(navTab('Mapa'));
    await tester.pumpAndSettle();
    expect(selectedTab(tester), 2);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(selectedTab(tester), 0);
    expect(find.byType(HomeView), findsOneWidget);
  });

  testWidgets('ranking y sugerencias se apilan y vuelven atrás', (
    tester,
  ) async {
    await openApp(tester);

    await tapVisible(tester, find.text('Ranking'));
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Ranking')),
      findsOneWidget,
    );

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(HomeView), findsOneWidget);
  });
}
