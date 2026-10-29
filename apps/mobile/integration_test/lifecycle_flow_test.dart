import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:qupa_wasi/app/routes.dart';
import 'package:qupa_wasi/domain/entities/app_preferences.dart';
import 'package:qupa_wasi/presentation/recycling/record_form_view_model.dart';

import 'helpers/native_app.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('F05: preferencias nativas y borrador tras pausa y reapertura', (
    tester,
  ) async {
    final app = NativeApp();
    await app.open(tester, AppRoutes.home);
    final original = app.settings.preferences;
    await app.settings.completeOnboarding();
    await app.settings.setAlias('QA Colibri');
    await app.settings.setTheme(ThemePreference.dark);
    await app.close(tester);

    await app.open(tester, AppRoutes.newRecord());
    expect(app.settings.alias, 'QA Colibri');
    expect(app.settings.themePreference, ThemePreference.dark);
    expect(app.settings.onboardingCompleted, isTrue);
    await waitVisible(tester, find.text('Arquitectura'));
    await tapVisible(tester, find.text('Arquitectura'));
    await tapVisible(tester, find.text('Siguiente'));
    await tapVisible(tester, find.text('PET'));
    final quantity = find.byKey(const Key('quantity-field'));
    for (final bad in ['', '0', '-1', '101', '1.5']) {
      await enterNativeText(tester, quantity, bad);
      await tester.pumpAndSettle();
      await tapVisible(tester, find.text('Siguiente'));
      expect(find.text('¿Qué reciclaste?'), findsOneWidget);
      expect(await app.deps.local.recycling.watch().first, isEmpty);
    }
    await enterNativeText(tester, quantity, '1.');
    await tester.pumpAndSettle();
    await enterNativeText(
      tester,
      find.byKey(const Key('note-field')),
      'F05 sin terminar',
    );
    await tester.pumpAndSettle();
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(quantity).controller!.text, '1.');
    // Ejercita el observador real del formulario; no mata el proceso Android.
    for (final state in [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      binding.handleAppLifecycleStateChanged(state);
    }
    await tester.pumpAndSettle();
    final draft = await app.deps.local.drafts.load(
      RecordFormViewModel.newDraftKey,
    );
    expect(draft!.quantityText, '1.');
    await app.close(tester);

    await app.open(tester, AppRoutes.newRecord());
    await waitVisible(tester, find.text('Continuar borrador'));
    await tapVisible(tester, find.text('Continuar borrador'));
    expect(tester.widget<TextField>(quantity).controller!.text, '1.');
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('note-field')))
          .controller!
          .text,
      'F05 sin terminar',
    );
    expect(await app.deps.local.recycling.watch().first, isEmpty);
    await app.close(tester);

    await app.open(tester, AppRoutes.newRecord());
    await tapVisible(tester, find.text('Descartar y empezar de nuevo'));
    expect(
      await app.deps.local.drafts.load(RecordFormViewModel.newDraftKey),
      isNull,
    );
    await app.settings.setAlias(original.alias);
    await app.settings.setTheme(original.themePreference);
    await app.close(tester);
    await app.open(tester, AppRoutes.recordDetail('no-existe-f05'));
    await waitVisible(tester, find.text('Registro no encontrado'));
    await app.close(tester);
  });
}
