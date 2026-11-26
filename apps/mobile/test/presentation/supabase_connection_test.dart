import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:qupa_wasi/app/routes.dart';
import 'package:qupa_wasi/data/remote/supabase_data_source.dart';
import 'package:qupa_wasi/presentation/profile/supabase_connection_tile.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('Perfil omite la comprobación sin configuración', (tester) async {
    resetPreferencesStore(onboardedStore);
    await openApp(tester, initialLocation: AppRoutes.profile);
    await scrollTo(tester, find.text('Ranking'));
    expect(find.byType(SupabaseConnectionTile), findsNothing);
  });

  testWidgets('Perfil consulta solo al tocar y permite reintentar', (
    tester,
  ) async {
    resetPreferencesStore(onboardedStore);
    var requests = 0;
    final firstResponse = Completer<http.Response>();
    final source = SupabaseDataSource(
      url: 'https://qupawasi.example.invalid',
      publishableKey: 'sb_publishable_test',
      createClient: () => MockClient((_) async {
        requests++;
        if (requests == 1) return firstResponse.future;
        return http.Response('[]', 200);
      }),
    );
    await openApp(tester, initialLocation: AppRoutes.profile, supabase: source);

    final check = find.text('Probar conexión');
    await scrollTo(tester, check);
    expect(requests, 0);

    await tester.tap(check);
    await tester.pump();
    final waiting = find.widgetWithText(ListTile, 'Comprobando conexión…');
    expect(tester.widget<ListTile>(waiting).onTap, isNull);
    expect(requests, 1);

    firstResponse.complete(http.Response('{}', 403));
    await tester.pumpAndSettle();
    expect(find.text('Falta permiso para leer categorías'), findsOneWidget);

    await tapVisible(tester, check);
    expect(requests, 2);
    expect(find.text('Conexión con Supabase verificada'), findsOneWidget);

    await tester.tap(find.byTooltip('Cerrar aviso'));
    await tester.pumpAndSettle();
  });
}
