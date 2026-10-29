import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qupa_wasi/app/routes.dart';
import 'package:qupa_wasi/domain/entities/geo_position.dart';
import 'package:qupa_wasi/domain/entities/recycling_point.dart';

import '../helpers/fake_local_services.dart';
import '../helpers/test_app.dart';

void main() {
  testWidgets('mapa geográfico y marcadores funcionan sin descargar teselas', (
    tester,
  ) async {
    resetPreferencesStore(onboardedStore);
    final local = FakeLocal(
      points: const [
        RecyclingPoint(
          id: 'synthetic-near',
          name: 'Cercano de prueba',
          description: 'Coordenadas sintéticas',
          occupancy: 0,
          isDemo: false,
          latitude: 0.001,
          longitude: 0,
        ),
        RecyclingPoint(
          id: 'synthetic-far',
          name: 'Lejano de prueba',
          description: 'Coordenadas sintéticas',
          occupancy: 0,
          isDemo: false,
          latitude: 1,
          longitude: 0,
        ),
      ],
    );
    await openApp(
      tester,
      initialLocation: AppRoutes.map,
      local: local,
      locate: () async => const GeoPosition(0, 0),
    );
    expect(find.byType(FlutterMap), findsOneWidget);
    expect(find.byType(TileLayer), findsNothing);
    await tapVisible(tester, find.text('Usar mi ubicación'));
    expect(
      find.textContaining('Más cercano: Cercano de prueba'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.my_location), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });
}
