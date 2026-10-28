import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qupa_wasi/core/widgets/prototype_banner.dart';
import 'package:qupa_wasi/presentation/home/home_view.dart';
import 'package:qupa_wasi/presentation/onboarding/welcome_view.dart';

import '../helpers/test_app.dart';

void main() {
  setUp(resetPreferencesStore);

  testWidgets('bienvenida no reaparece tras completarla y reabrir', (
    tester,
  ) async {
    await openApp(tester);
    expect(find.byType(WelcomeView), findsOneWidget);
    await scrollTo(tester, find.text(PrototypeBanner.message));
    expect(find.text(PrototypeBanner.message), findsOneWidget);

    await tapVisible(tester, find.text('Empezar'));
    expect(find.byType(HomeView), findsOneWidget);

    await openApp(tester);
    expect(find.byType(WelcomeView), findsNothing);
    expect(find.byType(HomeView), findsOneWidget);
  });

  testWidgets('sin onboarding, cualquier ruta redirige a bienvenida', (
    tester,
  ) async {
    await openApp(tester, initialLocation: '/profile');

    expect(find.byType(WelcomeView), findsOneWidget);
  });

  testWidgets('el aviso de privacidad explica que todo es local', (
    tester,
  ) async {
    await openApp(tester);

    await tapVisible(tester, find.text('Cómo cuidamos tus datos'));

    expect(find.textContaining('solo en este dispositivo'), findsWidgets);
  });

  testWidgets('tema y alias se recuperan al reabrir la app', (tester) async {
    resetPreferencesStore(onboardedStore);
    await openApp(tester, initialLocation: '/profile');

    await tapVisible(tester, find.text('Oscuro'));
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );

    await tapVisible(tester, find.byTooltip('Editar alias'), delta: -200);
    await tester.enterText(find.byType(TextField), 'Eco Tester');
    await tapVisible(tester, find.text('Guardar'));
    expect(find.text('Eco Tester'), findsOneWidget);

    await openApp(tester);
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
    expect(find.text('Hola, Eco Tester'), findsOneWidget);
  });

  testWidgets('alias inválido muestra error junto al campo', (tester) async {
    resetPreferencesStore(onboardedStore);
    await openApp(tester, initialLocation: '/profile');

    await tapVisible(tester, find.byTooltip('Editar alias'));
    await tester.enterText(find.byType(TextField), ' x ');
    await tapVisible(tester, find.text('Guardar'));

    expect(find.textContaining('al menos 2 caracteres'), findsOneWidget);
    expect(find.byType(AlertDialog), findsOneWidget);
  });
}
