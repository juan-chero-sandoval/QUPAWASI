import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:qupa_wasi/data/local/demo_seed.dart';
import 'package:qupa_wasi/domain/entities/deposit_qr.dart';
import 'package:qupa_wasi/domain/errors/local_data_exception.dart';

import '../helpers/local_fixture.dart';
import '../helpers/qr_payload.dart';

void main() {
  late LocalFixture f;
  setUp(() async => f = await LocalFixture.open());
  tearDown(() async => f.dispose());
  DepositQr decode(String raw) => f.services.deposits!.decode(raw);

  test('actualizar nota QR conserva identidad, datos y puntos; trigger protege datos del tacho', () async {
    final qr = decode(qrPayload());
    final created = await f.services.deposits!.accept(qr);
    final updated = await f.services.recycling.update(
      created.id,
      f.input(note: 'Observación local'),
    );
    expect(updated.id, created.id);
    expect(updated.depositId, created.depositId);
    expect(updated.latitude, created.latitude);
    expect(updated.quantity, 2);
    expect(updated.note, 'Observación local');
    expect((await f.services.overview.getStatistics()).availablePoints, 20);
    await expectLater(
      f.db.customStatement(
        'UPDATE recycling_records SET quantity=3 WHERE qr_deposit_id IS NOT NULL',
      ),
      throwsA(anything),
    );
    await expectLater(
      f.db.customStatement(
        'UPDATE recycling_records SET latitude=1 WHERE qr_deposit_id IS NOT NULL',
      ),
      throwsA(anything),
    );
    await f.reopen();
    final retry = await f.services.deposits!.accept(qr);
    expect(retry.note, 'Observación local');
    expect(retry.quantity, 2);
    expect((await f.services.overview.getStatistics()).availablePoints, 20);
  });

  test('QR conserva datos, fecha UTC y calcula puntos; reabrir/reintentar no duplica', () async {
    final qr = decode(qrPayload());
    final records = await Future.wait([
      f.services.deposits!.accept(qr),
      f.services.deposits!.accept(qr),
    ]);
    expect(records[0].id, records[1].id);
    expect(records[0].occurredAt, DateTime.utc(2026, 10, 28, 15));
    expect(records[0].depositId, 'test-deposit-1');
    expect(records[0].latitude, 0);
    expect((await f.services.overview.getStatistics()).availablePoints, 20);
    await f.reopen();
    expect((await f.services.deposits!.accept(qr)).id, records[0].id);
    expect(await f.services.recycling.watch().first, hasLength(1));
    await f.services.deposits!.accept(
      decode(qrPayload(id: 'test-aluminum', material: 'aluminum', quantity: 3)),
    );
    expect((await f.services.overview.getStatistics()).availablePoints, 35);
  });

  test('rechaza ID con datos diferentes; datos QR inmutables; borrar no permite re-acreditar', () async {
    final qr = decode(qrPayload());
    final record = await f.services.deposits!.accept(qr);
    await expectLater(
      f.services.deposits!.accept(decode(qrPayload(quantity: 3))),
      throwsA(isA<LocalDataException>()),
    );
    await expectLater(
      f.services.recycling.update(record.id, f.input(quantity: 3)),
      throwsA(isA<LocalDataException>()),
    );
    expect((await f.services.overview.getStatistics()).availablePoints, 20);
    await f.services.recycling.delete(record.id);
    await f.reopen();
    await expectLater(
      f.services.deposits!.accept(qr),
      throwsA(isA<LocalDataException>()),
    );
    expect((await f.services.overview.getStatistics()).availablePoints, 0);
  });

  test('punto desconocido y coordenadas incompatibles no guardan recibo ni registro', () async {
    await expectLater(
      f.services.deposits!.accept(decode(qrPayload(point: 'missing'))),
      throwsA(isA<LocalDataException>()),
    );
    await f.services.catalog!.importJson(
      jsonEncode({
        'version': 1,
        'points': [
          {
            'id': DemoSeed.architectureId,
            'name': 'Tacho de prueba',
            'isDemo': true,
            'latitude': 1,
            'longitude': 1,
          },
        ],
      }),
    );
    await expectLater(
      f.services.deposits!.accept(decode(qrPayload())),
      throwsA(isA<LocalDataException>()),
    );
    expect(await f.services.recycling.watch().first, isEmpty);
    expect(
      await f.db.customSelect('SELECT * FROM deposit_receipts').get(),
      isEmpty,
    );
  });

  test(
    'QR respeta saldo comprometido y canjes continúan consistentes',
    () async {
      final record = await f.services.deposits!.accept(
        decode(qrPayload(quantity: 10)),
      );
      final catalog = await f.services.rewards.watchCatalog().first;
      final reward = catalog.firstWhere((r) => r.costPoints == 80);
      final redemption = await f.services.rewards.redeem(
        reward.id,
        'qr-redeem',
      );
      await expectLater(
        f.services.recycling.delete(record.id),
        throwsA(isA<LocalDataException>()),
      );
      await f.services.rewards.cancel(redemption.id);
      await f.services.recycling.delete(record.id);
      expect((await f.services.overview.getStatistics()).availablePoints, 0);
    },
  );

  test(
    'migra archivo v1 con registro y borrador a v2 sin perder historial',
    () async {
      final old = await f.services.recycling.create(f.input());
      await f.services.close();
      final path = '${f.directory.path}/test.sqlite';
      final legacy = sqlite.sqlite3.open(path);
      // Reconstruir exactamente el esquema histórico, conservando un registro real.
      legacy.execute('PRAGMA foreign_keys=OFF');
      for (final row in legacy.select(
        "SELECT name FROM sqlite_master WHERE type='trigger'",
      )) {
        legacy.execute('DROP TRIGGER "${row['name']}"');
      }
      for (final row in legacy.select(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
      )) {
        legacy.execute('DROP TABLE "${row['name']}"');
      }
      legacy.execute(File('test/helpers/schema_v1.sql').readAsStringSync());
      legacy.execute(
        "INSERT INTO recycling_points VALUES (?, 'Ejemplo', '', 0, NULL, NULL, 1)",
        [old.pointId],
      );
      legacy.execute(
        'INSERT INTO recycling_records VALUES (?,?,?,?,?,?,?,?,?)',
        [
          old.id,
          old.pointId,
          'pet',
          2,
          10,
          old.occurredAt.millisecondsSinceEpoch,
          'histórico',
          old.createdAt.millisecondsSinceEpoch,
          old.updatedAt.millisecondsSinceEpoch,
        ],
      );
      legacy.execute(
        "INSERT INTO drafts VALUES ('recycling-edit',?,?,'pet','3','borrador',1,?,NULL)",
        [old.id, old.pointId, old.updatedAt.millisecondsSinceEpoch],
      );
      legacy.execute('PRAGMA user_version=1');
      legacy.close();
      await f.reopen();
      expect((await f.services.recycling.get(old.id))!.note, 'histórico');
      expect(
        (await f.services.drafts.load('recycling-edit'))!.quantityText,
        '3',
      );
      expect((await f.services.recycling.get(old.id))!.depositId, isNull);
      await f.services.recycling.update(old.id, f.input(quantity: 3));
      await f.services.deposits!.accept(decode(qrPayload()));
      expect((await f.services.overview.getStatistics()).availablePoints, 50);
    },
  );
}
