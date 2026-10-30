import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qupa_wasi/app/routes.dart';
import 'package:qupa_wasi/data/local/demo_seed.dart';
import 'package:qupa_wasi/data/preferences/shared_preferences_repository.dart';
import 'package:qupa_wasi/presentation/admin/admin_points_view.dart';
import 'package:qupa_wasi/presentation/admin/admin_rewards_view.dart';
import 'package:qupa_wasi/presentation/profile/profile_view.dart';

import '../helpers/fake_local_services.dart';
import '../helpers/test_app.dart';

const adminStore = <String, Object>{
  ...onboardedStore,
  SharedPreferencesRepository.adminKey: true,
};

void main() {
  Future<void> enter(WidgetTester tester, String key, String text) async {
    await scrollTo(tester, find.byKey(Key(key)));
    await tester.enterText(find.byKey(Key(key)), text);
    await tester.pump();
  }

  testWidgets('sin modo administrador, /admin vuelve a Perfil', (tester) async {
    resetPreferencesStore(onboardedStore);
    await openApp(tester, initialLocation: AppRoutes.adminPoints);
    expect(find.byType(AdminPointsView), findsNothing);
    expect(find.byType(ProfileView), findsOneWidget);
  });

  testWidgets('el interruptor de Perfil muestra Administración y persiste', (
    tester,
  ) async {
    resetPreferencesStore(onboardedStore);
    await openApp(tester, initialLocation: AppRoutes.profile);
    expect(find.text('Tachos'), findsNothing);

    await tapVisible(tester, find.text('Modo administrador'));
    expect(find.text('Tachos'), findsOneWidget);
    expect(find.text('Modo administrador activado'), findsOneWidget);

    await openApp(tester, initialLocation: AppRoutes.profile);
    await scrollTo(tester, find.text('Tachos'));
    expect(find.text('Tachos'), findsOneWidget);
    await tapVisible(tester, find.text('Tachos'));
    expect(find.byType(AdminPointsView), findsOneWidget);
  });

  testWidgets(
    'CRUD de tacho en pantalla: crear con validación, editar, borrar',
    (tester) async {
      resetPreferencesStore(adminStore);
      final local = FakeLocal();
      await openApp(
        tester,
        initialLocation: AppRoutes.adminPoints,
        local: local,
      );

      await tester.tap(find.text('Nuevo tacho'));
      await tester.pumpAndSettle();
      await enter(tester, 'point-name', 'Ciencias');
      await enter(tester, 'point-latitude', '95');
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      expect(
        find.text('La latitud debe estar entre -90 y 90.'),
        findsOneWidget,
      );
      expect(find.text('Obligatoria. Usa el GPS o escríbela.'), findsOneWidget);

      await enter(tester, 'point-latitude', '-5.1782');
      await enter(tester, 'point-longitude', '-80.6556');
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      expect(find.byType(AdminPointsView), findsOneWidget);
      expect(find.text('Creado correctamente'), findsOneWidget);
      final created = local.admin.points.values.singleWhere(
        (p) => p.name == 'Ciencias',
      );

      await tapVisible(tester, find.text('Ciencias'));
      expect(find.text('Editar tacho'), findsOneWidget);
      await enter(tester, 'point-name', 'Ciencias Exactas');
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      expect(local.admin.points[created.id]!.name, 'Ciencias Exactas');

      await tapVisible(tester, find.text('Ciencias Exactas'));
      await tapVisible(tester, find.text('Eliminar tacho'));
      await tester.tap(find.widgetWithText(FilledButton, 'Eliminar'));
      await tester.pumpAndSettle();
      expect(local.admin.points.containsKey(created.id), isFalse);
      expect(find.text('Ciencias Exactas'), findsNothing);
    },
  );

  testWidgets('tacho con registros: se ofrece desactivar en vez de borrar', (
    tester,
  ) async {
    resetPreferencesStore(adminStore);
    final local = FakeLocal();
    await local.seedRecord(pointId: DemoSeed.libraryId);
    await openApp(
      tester,
      initialLocation: AppRoutes.editAdminPoint(DemoSeed.libraryId),
      local: local,
    );

    await tapVisible(tester, find.text('Eliminar tacho'));
    await tester.tap(find.widgetWithText(FilledButton, 'Eliminar'));
    await tester.pumpAndSettle();
    expect(find.text('No se puede eliminar'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Desactivar'));
    await tester.pumpAndSettle();

    expect(local.admin.points[DemoSeed.libraryId]!.isActive, isFalse);
    expect(find.text('Desactivado'), findsOneWidget);
  });

  testWidgets('pasar a segundo plano guarda el borrador del formulario', (
    tester,
  ) async {
    resetPreferencesStore(adminStore);
    final local = FakeLocal();
    await openApp(
      tester,
      initialLocation: AppRoutes.newAdminPoint(),
      local: local,
    );
    await enter(tester, 'point-name', 'Agronomía');
    expect(local.admin.drafts['admin-point-new']?['name'], isNot('Agronomía'));

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    expect(local.admin.drafts['admin-point-new']!['name'], 'Agronomía');

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await openApp(
      tester,
      initialLocation: AppRoutes.newAdminPoint(),
      local: local,
    );
    expect(find.text('Recuperamos un borrador'), findsOneWidget);
    await tapVisible(tester, find.text('Continuar borrador'));
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('point-name')))
          .controller!
          .text,
      'Agronomía',
    );
  });

  testWidgets('CRUD de recompensa en pantalla', (tester) async {
    resetPreferencesStore(adminStore);
    final local = FakeLocal();
    await openApp(
      tester,
      initialLocation: AppRoutes.adminRewards,
      local: local,
    );

    await tester.tap(find.text('Nueva recompensa'));
    await tester.pumpAndSettle();
    await enter(tester, 'reward-title', 'Termo reutilizable');
    await enter(tester, 'reward-cost', '120');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(find.text('Elige una categoría.'), findsOneWidget);

    await tapVisible(tester, find.text('Cafetería'));
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(find.byType(AdminRewardsView), findsOneWidget);
    final created = local.admin.rewards.values.singleWhere(
      (r) => r.title == 'Termo reutilizable',
    );
    expect(created.costPoints, 120);

    await tapVisible(tester, find.text('Termo reutilizable'));
    await tapVisible(tester, find.byType(Switch));
    expect(local.admin.rewards[created.id]!.isActive, isFalse);
  });
}
