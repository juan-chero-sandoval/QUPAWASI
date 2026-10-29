import 'package:flutter_test/flutter_test.dart';
import 'package:qupa_wasi/data/local/demo_seed.dart';
import 'package:qupa_wasi/domain/entities/admin_inputs.dart';
import 'package:qupa_wasi/domain/entities/reward.dart';
import 'package:qupa_wasi/domain/errors/local_data_exception.dart';
import 'package:qupa_wasi/domain/usecases/admin_catalog_use_cases.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

import '../helpers/local_fixture.dart';
import '../helpers/local_matchers.dart';

void main() {
  late LocalFixture f;
  setUp(() async => f = await LocalFixture.open());
  tearDown(() async => f.dispose());

  AdminCatalogUseCases admin() => f.services.admin!;

  PointInput point({
    String name = 'Ingeniería',
    int occupancy = 20,
    double latitude = -5.1782,
    double longitude = -80.6556,
  }) => PointInput(
    name: name,
    description: 'Junto al pabellón',
    occupancy: occupancy,
    latitude: latitude,
    longitude: longitude,
  );

  RewardInput reward({String title = 'Libreta reciclada', int cost = 60}) =>
      RewardInput(
        title: title,
        category: RewardCategory.cafeteria,
        costPoints: cost,
        description: 'Canje de ejemplo',
      );

  test('CRUD de tacho: crear, leer, editar el mismo ID y eliminar', () async {
    final created = await admin().createPoint(point());
    expect(created.isDemo, isFalse);
    expect(created.isActive, isTrue);

    await f.reopen();
    final read = (await admin().getPoint(created.id))!;
    expect(read.name, 'Ingeniería');
    expect(read.latitude, -5.1782);

    final updated = await admin().updatePoint(
      created.id,
      point(name: 'Ingeniería Industrial', occupancy: 75),
    );
    expect(updated.id, created.id);
    expect(updated.occupancy, 75);
    expect(
      (await f.services.overview.listPoints()).where((p) => p.id == created.id),
      hasLength(1),
    );

    await admin().deletePoint(created.id);
    await f.reopen();
    expect(await admin().getPoint(created.id), isNull);
  });

  test('entradas de tacho inválidas se rechazan sin escribir', () async {
    final before = (await f.services.overview.listPoints()).length;
    for (final bad in [
      point(name: ' x '),
      point(name: 'a' * 61),
      point(occupancy: -1),
      point(occupancy: 101),
      point(latitude: 91),
      point(longitude: -181),
    ]) {
      await expectLater(
        admin().createPoint(bad),
        throwsA(hasCode(LocalDataError.validation)),
      );
    }
    expect(await f.services.overview.listPoints(), hasLength(before));
  });

  test(
    'tacho con registros: borrar se rechaza y se puede desactivar',
    () async {
      final created = await admin().createPoint(point());
      await f.services.recycling.create(f.input(pointId: created.id));

      await expectLater(
        admin().deletePoint(created.id),
        throwsA(hasCode(LocalDataError.conflict)),
      );
      expect(await admin().getPoint(created.id), isNotNull);

      await admin().setPointActive(created.id, active: false);
      await f.reopen();
      expect((await admin().getPoint(created.id))!.isActive, isFalse);
      // El historial y sus puntos se conservan.
      expect((await f.services.overview.getStatistics()).earnedPoints, 20);

      await admin().setPointActive(created.id, active: true);
      expect((await admin().getPoint(created.id))!.isActive, isTrue);
    },
  );

  test('un tacho de ejemplo borrado no reaparece al reabrir', () async {
    await admin().deletePoint(DemoSeed.diningId);
    await f.reopen();
    await f.reopen();
    expect(await admin().getPoint(DemoSeed.diningId), isNull);
    // Los demás datos sembrados siguen ahí.
    expect(await admin().getPoint(DemoSeed.libraryId), isNotNull);
  });

  test('CRUD de recompensa y lista para el administrador', () async {
    final created = await admin().createReward(reward());
    expect(created.isActive, isTrue);
    expect(
      (await f.services.rewards.watchCatalog().first).map((r) => r.id),
      contains(created.id),
    );

    final updated = await admin().updateReward(
      created.id,
      reward(title: 'Libreta ecológica', cost: 90),
    );
    expect(updated.id, created.id);
    expect(updated.costPoints, 90);

    await admin().setRewardActive(created.id, active: false);
    expect(
      (await f.services.rewards.watchCatalog().first).map((r) => r.id),
      isNot(contains(created.id)),
      reason: 'el catálogo del estudiante solo muestra activas',
    );
    expect(
      (await admin().watchRewards().first).map((r) => r.id),
      contains(created.id),
      reason: 'el administrador ve también las desactivadas',
    );

    await admin().deleteReward(created.id);
    await f.reopen();
    expect(await admin().getReward(created.id), isNull);
  });

  test(
    'recompensa canjeada: borrar se rechaza; editar no altera el canje',
    () async {
      await f.services.recycling.create(f.input(quantity: 10));
      final redemption = await f.services.rewards.redeem(
        DemoSeed.photocopiesId,
        'operacion-admin',
      );

      await expectLater(
        admin().deleteReward(DemoSeed.photocopiesId),
        throwsA(hasCode(LocalDataError.conflict)),
      );
      await admin().updateReward(
        DemoSeed.photocopiesId,
        reward(title: 'Fotocopias gratis', cost: 120),
      );
      final history = await f.services.rewards.watchRedemptions().first;
      expect(history.single.id, redemption.id);
      expect(history.single.costSnapshot, 80);
      expect(history.single.titleSnapshot, isNot('Fotocopias gratis'));
    },
  );

  test('costo o título de recompensa inválidos se rechazan', () async {
    for (final bad in [
      reward(title: 'ab'),
      reward(cost: 0),
      reward(cost: 10001),
    ]) {
      await expectLater(
        admin().createReward(bad),
        throwsA(hasCode(LocalDataError.validation)),
      );
    }
  });

  test(
    'borrador de formulario sobrevive a reabrir y uno viejo no pisa',
    () async {
      await admin().saveDraft('admin-point-new', {
        'name': 'Nuevo',
        'latitude': '-5.1',
      }, f.now);
      await admin().saveDraft('admin-point-new', {
        'name': 'Viejo',
      }, f.now.subtract(const Duration(seconds: 1)));
      await f.reopen();
      final draft = (await admin().loadDraft('admin-point-new'))!;
      expect(draft['name'], 'Nuevo');
      expect(draft['latitude'], '-5.1');

      await admin().clearDraft('admin-point-new');
      expect(await admin().loadDraft('admin-point-new'), isNull);
    },
  );

  test('migra una base v2 a v3 sin perder tachos ni registros', () async {
    final record = await f.services.recycling.create(f.input());
    await f.services.close();
    final path = '${f.directory.path}/test.sqlite';
    final legacy = sqlite.sqlite3.open(path);
    // Volver al esquema v2: sin is_active, sin borradores ni marcas.
    legacy.execute('DROP TABLE form_drafts');
    legacy.execute('DROP TABLE app_flags');
    legacy.execute('ALTER TABLE recycling_points DROP COLUMN is_active');
    legacy.execute(
      "DELETE FROM recycling_points WHERE id = '${DemoSeed.diningId}'",
    );
    legacy.execute('PRAGMA user_version=2');
    legacy.close();

    await f.reopen();
    final points = await f.services.overview.listPoints();
    expect(points.every((p) => p.isActive), isTrue);
    expect(
      points.map((p) => p.id),
      isNot(contains(DemoSeed.diningId)),
      reason: 'la migración marca la siembra como hecha y no la repite',
    );
    expect((await f.services.recycling.get(record.id))!.note, 'prueba');
    await admin().setPointActive(DemoSeed.libraryId, active: false);
    expect((await admin().getPoint(DemoSeed.libraryId))!.isActive, isFalse);
  });
}
