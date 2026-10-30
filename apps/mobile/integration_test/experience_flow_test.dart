import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:qupa_wasi/app/app.dart';
import 'package:qupa_wasi/app/dependencies.dart';
import 'package:qupa_wasi/app/routes.dart';
import 'package:qupa_wasi/data/local/demo_seed.dart';
import 'package:qupa_wasi/domain/entities/app_preferences.dart';
import 'package:qupa_wasi/domain/entities/recycling_record.dart';
import 'package:qupa_wasi/domain/repositories/preferences_repository.dart';
import 'package:qupa_wasi/presentation/home/widgets/points_summary_card.dart';
import 'package:qupa_wasi/presentation/settings/app_settings_view_model.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'F04: mapa, canje confirmado/cancelado y preferencias/sugerencias tras reapertura',
    (tester) async {
      Future<void> waitFor(FutureOr<bool> Function() ready) async {
        for (var i = 0; i < 150; i++) {
          await tester.pump(const Duration(milliseconds: 100));
          if (await ready()) return;
        }
        fail('Estado de F04 no disponible');
      }

      Future<void> tap(Finder finder) async {
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        if (finder.evaluate().isEmpty) {
          await tester.scrollUntilVisible(
            finder,
            250,
            scrollable: find.byType(Scrollable).hitTestable().first,
          );
        }
        await tester.ensureVisible(finder.first);
        await tester.pumpAndSettle();
        await tester.tap(finder.first);
        await tester.pumpAndSettle();
      }

      late AppDependencies deps;
      late AppSettingsViewModel settings;
      Future<void> open(String location) async {
        deps = await AppDependencies.create();
        settings = AppSettingsViewModel(deps.preferencesRepository);
        await settings.load();
        await settings.completeOnboarding();
        await tester.pumpWidget(
          QupaWasiApp(
            dependencies: deps,
            settings: settings,
            initialLocation: location,
          ),
        );
        await tester.pumpAndSettle();
      }

      Future<void> close() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        settings.dispose();
        await deps.close();
      }

      await open(AppRoutes.mapPoint(pointId: DemoSeed.libraryId));
      await waitFor(
        () => find.text('Registrar en este punto').evaluate().isNotEmpty,
      );
      await tap(find.text('Registrar en este punto'));
      expect(find.text('Registrar reciclaje'), findsOneWidget);
      expect(find.text('Escanear QR'), findsOneWidget);
      expect(find.byKey(const Key('quantity-field')), findsNothing);
      await close();

      await open(AppRoutes.home);
      final original = settings.preferences;
      final record = await deps.local.recycling.create(
        RecordInput(
          pointId: DemoSeed.libraryId,
          material: RecyclingMaterial.pet,
          quantity: 10,
          occurredAt: DateTime.now().toUtc(),
          note: 'F04 integración',
        ),
      );
      await waitFor(
        () => find
            .byWidgetPredicate((w) => w is PointsSummaryCard && w.points == 100)
            .evaluate()
            .isNotEmpty,
      );
      await tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Premios'),
        ),
      );
      await waitFor(() => find.text('50% en fotocopias').evaluate().isNotEmpty);
      await tap(find.text('Fotocopias'));
      expect(find.text('Recarga S/ 1.00 simulada'), findsNothing);
      await tap(find.text('Canjear'));
      await tap(find.text('Volver'));
      expect(await deps.local.rewards.watchRedemptions().first, isEmpty);
      await tap(find.text('Canjear'));
      await tap(find.text('Confirmar canje'));
      await waitFor(() => find.text('Canje guardado').evaluate().isNotEmpty);
      expect((await deps.local.overview.getStatistics()).availablePoints, 20);
      final redemption =
          (await deps.local.rewards.watchRedemptions().first).single;
      // A retry across process recreation must recover the same operation.
      await deps.preferencesRepository.setPendingRedemption(
        PendingRedemption(redemption.rewardId, redemption.operationId),
      );
      await deps.preferencesRepository.setAlias('Colibrí Demo');
      await deps.preferencesRepository.setTheme(ThemePreference.dark);
      final suggestion = await deps.local.suggestions.create(
        'Más puntos locales de ejemplo',
      );
      await close();
      await open(AppRoutes.rewards);
      expect(settings.alias, 'Colibrí Demo');
      expect(settings.themePreference, ThemePreference.dark);
      expect((await deps.local.suggestions.list()).single.id, suggestion.id);
      await waitFor(
        () => find.text('Reintentar canje pendiente').evaluate().isNotEmpty,
      );
      await tap(find.text('Reintentar canje pendiente'));
      await waitFor(
        () async =>
            await deps.preferencesRepository.loadPendingRedemption() == null,
      );
      expect(
        (await deps.local.rewards.watchRedemptions().first).single.id,
        redemption.id,
      );
      expect(await deps.local.rewards.watchRedemptions().first, hasLength(1));
      await expectLater(
        deps.local.recycling.delete(record.id),
        throwsA(anything),
      );
      await tap(find.text('Cancelar canje'));
      await tap(find.widgetWithText(FilledButton, 'Cancelar canje'));
      await waitFor(
        () async =>
            (await deps.local.overview.getStatistics()).availablePoints == 100,
      );
      await deps.local.rewards.cancel(redemption.id);
      expect((await deps.local.overview.getStatistics()).availablePoints, 100);
      await deps.local.recycling.update(
        record.id,
        RecordInput(
          pointId: record.pointId,
          material: record.material,
          quantity: 3,
          occurredAt: record.occurredAt,
          note: 'editada',
        ),
      );
      expect((await deps.local.overview.getStatistics()).availablePoints, 30);
      await deps.local.recycling.delete(record.id);
      await close();
      await open(AppRoutes.suggestions);
      await waitFor(() => find.text(suggestion.message).evaluate().isNotEmpty);
      await tap(find.text('Eliminar sugerencia'));
      await tap(find.widgetWithText(FilledButton, 'Eliminar'));
      await waitFor(
        () => find
            .text('Aún no tienes sugerencias locales.')
            .evaluate()
            .isNotEmpty,
      );
      expect(
        (await deps.local.rewards.watchRedemptions().first).single.isActive,
        false,
      );
      expect((await deps.local.overview.getStatistics()).availablePoints, 0);
      await deps.preferencesRepository.setAlias(original.alias);
      await deps.preferencesRepository.setTheme(original.themePreference);
      await close();
    },
  );
}
