import 'dart:convert';
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:qupa_wasi/domain/entities/geo_position.dart';
import 'package:qupa_wasi/domain/errors/local_data_exception.dart';
import 'package:qupa_wasi/presentation/map/map_view_model.dart';

import '../helpers/local_fixture.dart';

Future<void> waitForMap(MapViewModel vm, bool Function() ready) async {
  if (ready()) return;
  final completed = Completer<void>();
  void listener() {
    if (ready() && !completed.isCompleted) {
      completed.complete();
    }
  }

  vm.addListener(listener);
  try {
    await completed.future.timeout(const Duration(seconds: 5));
  } finally {
    vm.removeListener(listener);
  }
}

void main() {
  late LocalFixture f;
  setUp(() async => f = await LocalFixture.open());
  tearDown(() async => f.dispose());
  final catalog = jsonEncode({
    'version': 1,
    'points': [
      {
        'id': 'near',
        'name': 'Cercano sintético',
        'latitude': 0.001,
        'longitude': 0,
        'isDemo': false,
      },
      {
        'id': 'far',
        'name': 'Lejano sintético',
        'latitude': 1,
        'longitude': 0,
        'isDemo': false,
      },
      {
        'id': 'demo',
        'name': 'Demo sintético',
        'latitude': 0,
        'longitude': 0,
        'isDemo': true,
      },
    ],
  });
  test('catálogo SQLite persiste y proximidad omite demos; no guarda ubicación del teléfono', () async {
    await f.services.catalog!.importJson(catalog);
    await f.reopen();
    final vm = MapViewModel(
      overview: f.services.overview,
      catalog: f.services.catalog,
      locate: () async => const GeoPosition(0, 0),
    );
    await waitForMap(vm, () => !vm.loading);
    await vm.findNearest();
    expect(vm.selected, 'near');
    expect(vm.ranked.map((r) => r.point.id), ['near', 'far']);
    expect(vm.ranked.first.meters, closeTo(111.2, 0.1));
    vm.dispose();
    expect(
      (await f.services.overview.listPoints())
          .where((p) => p.id == 'near')
          .single
          .latitude,
      .001,
    );
  });
  test('sin coordenadas no solicita permisos; denegación se muestra y permite reintentar', () async {
    var calls = 0;
    final vm = MapViewModel(
      overview: f.services.overview,
      locate: () async {
        calls++;
        throw const LocalDataException(
          LocalDataError.validation,
          'Permiso denegado',
        );
      },
    );
    await waitForMap(vm, () => !vm.loading);
    await vm.findNearest();
    expect(calls, 0);
    expect(vm.error, contains('Faltan coordenadas'));
    await f.services.catalog!.importJson(catalog);
    await waitForMap(vm, () => vm.points.length == 6);
    await vm.findNearest();
    expect(calls, 1);
    expect(vm.error, 'Permiso denegado');
    expect(vm.locating, isFalse);
    vm.dispose();
  });
  test('catálogo malformado no deja escrituras parciales ni borra puntos existentes', () async {
    final malformed = jsonDecode(catalog) as Map<String, dynamic>;
    (malformed['points'] as List).add({'id': 'invalid'});
    await expectLater(
      f.services.catalog!.importJson(jsonEncode(malformed)),
      throwsA(isA<LocalDataException>()),
    );
    expect(await f.services.overview.listPoints(), hasLength(3));
    await f.services.catalog!.importJson(catalog);
    await f.services.catalog!.importJson(catalog);
    expect(await f.services.overview.listPoints(), hasLength(6));
  });
}
