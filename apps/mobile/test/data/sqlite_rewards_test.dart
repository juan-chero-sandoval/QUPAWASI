import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:qupa_wasi/data/local/demo_seed.dart';
import 'package:qupa_wasi/domain/entities/reward.dart';
import 'package:qupa_wasi/domain/errors/local_data_exception.dart';

import '../helpers/local_fixture.dart';
import '../helpers/local_matchers.dart';

void main() {
  late LocalFixture f;
  setUp(() async => f = await LocalFixture.open());
  tearDown(() async => f.dispose());

  test('catálogo filtrado y saldo insuficiente no crean canje', () async {
    expect(await f.services.rewards.watchCatalog().first, hasLength(3));
    final catalog = await f.services.rewards
        .watchCatalog(category: RewardCategory.mobile)
        .first;
    expect(catalog.single.id, DemoSeed.mobileId);
    await expectLater(
      f.services.rewards.redeem(DemoSeed.photocopiesId, 'insuficiente'),
      throwsA(hasCode(LocalDataError.insufficientPoints)),
    );
    expect(await f.services.rewards.watchRedemptions().first, isEmpty);
    await expectLater(
      f.services.rewards.redeem('ausente', 'ausente'),
      throwsA(hasCode(LocalDataError.notFound)),
    );
  });

  test(
    'operationId repetido devuelve el mismo canje incluso tras reabrir',
    () async {
      await f.services.recycling.create(f.input(quantity: 10));
      final first = await f.services.rewards.redeem(
        DemoSeed.photocopiesId,
        'operacion-1',
      );
      final retry = await f.services.rewards.redeem(
        DemoSeed.photocopiesId,
        'operacion-1',
      );
      expect(retry.id, first.id);
      expect((await f.services.overview.getStatistics()).availablePoints, 20);
      await f.reopen();
      final reopened = await f.services.rewards.redeem(
        DemoSeed.photocopiesId,
        'operacion-1',
      );
      expect(reopened.id, first.id);
      expect(await f.services.rewards.watchRedemptions().first, hasLength(1));
      await expectLater(
        f.services.rewards.redeem(DemoSeed.mobileId, 'operacion-1'),
        throwsA(hasCode(LocalDataError.conflict)),
      );
      expect((await f.services.overview.getStatistics()).availablePoints, 20);
    },
  );

  test('snapshot no cambia al modificar el catálogo', () async {
    await f.services.recycling.create(f.input(quantity: 10));
    final redeemed = await f.services.rewards.redeem(
      DemoSeed.photocopiesId,
      'snapshot',
    );
    await f.db.customStatement(
      'UPDATE rewards SET title=?,cost_points=? WHERE id=?',
      ['Título nuevo', 500, DemoSeed.photocopiesId],
    );
    await f.reopen();
    final saved = (await f.services.rewards.watchRedemptions().first).single;
    expect(saved.costSnapshot, 80);
    expect(saved.titleSnapshot, redeemed.titleSnapshot);
    expect((await f.services.overview.getStatistics()).availablePoints, 20);
  });

  test(
    'dos canjes simultáneos con la misma operación solo escriben una vez',
    () async {
      await f.services.recycling.create(f.input(quantity: 10));
      final results = await Future.wait(
        List.generate(
          6,
          (_) => f.services.rewards.redeem(DemoSeed.photocopiesId, 'doble-tap'),
        ),
      );
      expect(results.map((r) => r.id).toSet(), hasLength(1));
      expect(await f.services.rewards.watchRedemptions().first, hasLength(1));
      expect((await f.services.overview.getStatistics()).availablePoints, 20);
    },
  );

  test(
    'operaciones diferentes simultáneas no gastan más que el saldo',
    () async {
      await f.services.recycling.create(f.input(quantity: 10));
      final results = await Future.wait(
        List.generate(5, (i) async {
          try {
            await f.services.rewards.redeem(DemoSeed.photocopiesId, 'op-$i');
            return true;
          } on LocalDataException catch (e) {
            expect(e.code, LocalDataError.insufficientPoints);
            return false;
          }
        }),
      );
      expect(results.where((succeeded) => succeeded), hasLength(1));
      expect((await f.services.overview.getStatistics()).availablePoints, 20);
    },
  );

  test('editar/borrar registro comprometido hace rollback; cancelar libera una sola vez', () async {
    final record = await f.services.recycling.create(f.input(quantity: 10));
    final redemption = await f.services.rewards.redeem(
      DemoSeed.photocopiesId,
      'reserva',
    );
    await expectLater(
      f.services.recycling.update(record.id, f.input(quantity: 2)),
      throwsA(hasCode(LocalDataError.committedPoints)),
    );
    await expectLater(
      f.services.recycling.delete(record.id),
      throwsA(hasCode(LocalDataError.committedPoints)),
    );
    expect((await f.services.recycling.get(record.id))!.quantity, 10);
    expect((await f.services.overview.getStatistics()).availablePoints, 20);
    await f.services.rewards.cancel(redemption.id);
    await f.services.rewards.cancel(redemption.id);
    expect((await f.services.overview.getStatistics()).availablePoints, 100);
    final retry = await f.services.rewards.redeem(
      DemoSeed.photocopiesId,
      'reserva',
    );
    expect(retry.isActive, isFalse);
    expect((await f.services.overview.getStatistics()).availablePoints, 100);
    await f.services.recycling.update(record.id, f.input(quantity: 2));
    await f.services.recycling.delete(record.id);
    await f.reopen();
    expect((await f.services.overview.getStatistics()).availablePoints, 0);
    expect(
      (await f.services.rewards.watchRedemptions().first).single.isActive,
      isFalse,
    );
  });

  test(
    'no se puede cancelar un canje inexistente ni alterar un snapshot por SQL',
    () async {
      await expectLater(
        f.services.rewards.cancel('ausente'),
        throwsA(hasCode(LocalDataError.notFound)),
      );
      await f.services.recycling.create(f.input(quantity: 10));
      final redemption = await f.services.rewards.redeem(
        DemoSeed.photocopiesId,
        'inmutable',
      );
      await expectLater(
        f.db.customStatement(
          'UPDATE redemptions SET cost_snapshot=1 WHERE id=?',
          [redemption.id],
        ),
        throwsA(anything),
      );
      expect((await f.services.overview.getStatistics()).spentPoints, 80);
    },
  );

  test(
    'watchStatistics cambia al canjear/cancelar sin modificar registros',
    () async {
      await f.services.recycling.create(f.input(quantity: 10));
      final statistics = StreamIterator(f.services.overview.watchStatistics());
      addTearDown(statistics.cancel);
      await statistics.moveNext();
      expect(statistics.current.availablePoints, 100);
      final redemption = await f.services.rewards.redeem(
        DemoSeed.photocopiesId,
        'reactivo',
      );
      await statistics.moveNext();
      expect(statistics.current.availablePoints, 20);
      await f.services.rewards.cancel(redemption.id);
      await statistics.moveNext();
      expect(statistics.current.availablePoints, 100);
    },
  );
}
