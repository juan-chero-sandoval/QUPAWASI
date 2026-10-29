import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:qupa_wasi/data/local/demo_seed.dart';
import 'package:qupa_wasi/domain/entities/recycling_record.dart';
import 'package:qupa_wasi/domain/errors/local_data_exception.dart';

import '../helpers/local_fixture.dart';
import '../helpers/local_matchers.dart';

void main() {
  late LocalFixture f;
  setUp(() async => f = await LocalFixture.open());
  tearDown(() async => f.dispose());

  test('base inicial v3: tres puntos activos, coordenadas desconocidas y cero registros', () async {
    final points = await f.services.overview.listPoints();
    expect(points, hasLength(3));
    expect(
      points.every(
        (p) =>
            p.isDemo && p.isActive && p.latitude == null && p.longitude == null,
      ),
      isTrue,
    );
    expect((await f.services.recycling.watch().first), isEmpty);
    expect((await f.services.overview.getStatistics()).availablePoints, 0);
    expect(
      (await f.db.customSelect('PRAGMA user_version').getSingle()).read<int>(
        'user_version',
      ),
      3,
    );
  });

  test('CRUD persistente: UUID, mismo ID/createdAt al editar y borrado tras reapertura', () async {
    final created = await f.services.recycling.create(
      f.input(note: '  prueba  '),
    );
    expect(
      created.id,
      matches(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ),
      ),
    );
    expect(created.note, 'prueba');
    expect(created.occurredAt.isUtc, isTrue);
    await f.reopen();
    expect((await f.services.recycling.get(created.id))!.note, 'prueba');
    f.now = f.now.add(const Duration(minutes: 1));
    final updated = await f.services.recycling.update(
      created.id,
      f.input(quantity: 3, note: 'editada'),
    );
    expect(updated.id, created.id);
    expect(updated.createdAt, created.createdAt);
    expect(updated.updatedAt, f.now);
    expect(updated.quantity, 3);
    await f.reopen();
    expect((await f.services.recycling.watch().first), hasLength(1));
    expect((await f.services.recycling.get(created.id))!.note, 'editada');
    await f.services.recycling.delete(created.id);
    await f.reopen();
    expect(await f.services.recycling.get(created.id), isNull);
    expect(await f.services.recycling.watch().first, isEmpty);
  });

  test('editar PET2 a PET3 recalcula 20 a 30 y borrar devuelve cero', () async {
    final record = await f.services.recycling.create(f.input());
    expect((await f.services.overview.getStatistics()).earnedPoints, 20);
    await f.services.recycling.update(record.id, f.input(quantity: 3));
    final statistics = await f.services.overview.getStatistics();
    expect(statistics.earnedPoints, 30);
    expect(statistics.petCount, 3);
    expect(statistics.recordCount, 1);
    expect(statistics.estimatedMassKg, isNull);
    await f.services.recycling.delete(record.id);
    expect((await f.services.overview.getStatistics()).availablePoints, 0);
  });

  test(
    'cambiar de material aplica política correcta sin duplicar registros',
    () async {
      final record = await f.services.recycling.create(f.input(quantity: 10));
      await f.services.recycling.update(
        record.id,
        f.input(quantity: 10, material: RecyclingMaterial.aluminum),
      );
      final summary = await f.services.overview.getStatistics();
      expect(summary.earnedPoints, 50);
      expect(summary.petCount, 0);
      expect(summary.aluminumCount, 10);
      expect(summary.recordCount, 1);
    },
  );

  for (final quantity in [0, -1, 101]) {
    test('cantidad $quantity rechazada sin filas nuevas', () async {
      await expectLater(
        f.services.recycling.create(f.input(quantity: quantity)),
        throwsA(hasCode(LocalDataError.validation)),
      );
      expect(await f.services.recycling.watch().first, isEmpty);
    });
  }

  test(
    'fecha futura, nota larga y punto inexistente no producen éxito falso',
    () async {
      for (final input in [
        f.input(occurredAt: f.now.add(const Duration(seconds: 1))),
        f.input(note: 'x' * 201),
        f.input(pointId: 'no-existe'),
        f.input(pointId: ''),
      ]) {
        await expectLater(
          f.services.recycling.create(input),
          throwsA(hasCode(LocalDataError.validation)),
        );
      }
      expect(await f.services.recycling.watch().first, isEmpty);
    },
  );

  test('ausente: get es null; update/delete devuelven notFound', () async {
    expect(await f.services.recycling.get('ausente'), isNull);
    await expectLater(
      f.services.recycling.update('ausente', f.input()),
      throwsA(hasCode(LocalDataError.notFound)),
    );
    await expectLater(
      f.services.recycling.delete('ausente'),
      throwsA(hasCode(LocalDataError.notFound)),
    );
  });

  test('restricciones SQLite: material, cantidad y FK también rechazan SQL directo', () async {
    for (final values in [
      ['raw-1', DemoSeed.architectureId, 'invalid', 2],
      ['raw-2', DemoSeed.architectureId, 'pet', 0],
      ['raw-3', 'point-inexistente', 'pet', 2],
      ['raw-4', DemoSeed.architectureId, 'pet', 1.5],
    ]) {
      await expectLater(
        f.db.customStatement(
          'INSERT INTO recycling_records(id,point_id,material,quantity,unit_points,occurred_at,note,created_at,updated_at) '
          'VALUES (?,?,?,?,10,0,\'\',0,0)',
          values,
        ),
        throwsA(anything),
      );
    }
    expect(await f.services.recycling.watch().first, isEmpty);
  });

  test('orden determinista y filtros por punto/material', () async {
    final one = await f.services.recycling.create(
      f.input(occurredAt: f.now.subtract(const Duration(days: 1))),
    );
    final two = await f.services.recycling.create(
      f.input(
        pointId: DemoSeed.libraryId,
        material: RecyclingMaterial.aluminum,
      ),
    );
    final all = await f.services.recycling.watch().first;
    expect(all.map((r) => r.id), [two.id, one.id]);
    final filtered = await f.services.recycling
        .watch(
          filter: const RecordsFilter(
            pointId: DemoSeed.libraryId,
            material: RecyclingMaterial.aluminum,
          ),
        )
        .first;
    expect(filtered.single.id, two.id);
    expect(
      await f.services.recycling
          .watch(
            filter: const RecordsFilter(
              pointId: DemoSeed.libraryId,
              material: RecyclingMaterial.pet,
            ),
          )
          .first,
      isEmpty,
    );
  });

  test(
    'watchAll y estadísticas emiten tras update sin cambiar cantidad de filas',
    () async {
      final records = StreamIterator(f.services.recycling.watch());
      final statistics = StreamIterator(f.services.overview.watchStatistics());
      addTearDown(records.cancel);
      addTearDown(statistics.cancel);
      await records.moveNext();
      await statistics.moveNext();
      expect(records.current, isEmpty);
      expect(statistics.current.earnedPoints, 0);
      final record = await f.services.recycling.create(f.input());
      await records.moveNext();
      await statistics.moveNext();
      expect(records.current.single.quantity, 2);
      expect(statistics.current.earnedPoints, 20);
      await f.services.recycling.update(record.id, f.input(quantity: 3));
      await records.moveNext();
      await statistics.moveNext();
      expect(records.current.single.quantity, 3);
      expect(statistics.current.earnedPoints, 30);
      await f.services.recycling.delete(record.id);
      await records.moveNext();
      await statistics.moveNext();
      expect(records.current, isEmpty);
      expect(statistics.current.earnedPoints, 0);
    },
  );

  test(
    'rollback de una transacción externa no conserva la creación interna',
    () async {
      await expectLater(
        f.db.transaction(() async {
          await f.services.recycling.create(f.input());
          throw const LocalDataException(
            LocalDataError.conflict,
            'Fallo posterior a la escritura',
          );
        }),
        throwsA(hasCode(LocalDataError.conflict)),
      );
      expect(await f.services.recycling.watch().first, isEmpty);
    },
  );

  test('semillas no se duplican ni se sobrescriben al reabrir', () async {
    await f.db.customStatement(
      'UPDATE recycling_points SET occupancy=27 WHERE id=?',
      [DemoSeed.architectureId],
    );
    await f.db.customStatement('UPDATE rewards SET is_active=0 WHERE id=?', [
      DemoSeed.mobileId,
    ]);
    await f.reopen();
    final points = await f.services.overview.listPoints();
    expect(points, hasLength(3));
    expect(
      points.firstWhere((p) => p.id == DemoSeed.architectureId).occupancy,
      27,
    );
    expect(await f.services.rewards.watchCatalog().first, hasLength(2));
  });

  test(
    'almacenamiento cerrado entrega error tipado, no un resultado exitoso',
    () async {
      await f.services.close();
      await expectLater(
        f.services.recycling.create(f.input()),
        throwsA(hasCode(LocalDataError.storage)),
      );
    },
  );
}
