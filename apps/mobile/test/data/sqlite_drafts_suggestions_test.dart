import 'package:flutter_test/flutter_test.dart';
import 'package:qupa_wasi/domain/entities/recycling_draft.dart';
import 'package:qupa_wasi/domain/errors/local_data_exception.dart';

import '../helpers/local_fixture.dart';
import '../helpers/local_matchers.dart';

void main() {
  late LocalFixture f;
  setUp(() async => f = await LocalFixture.open());
  tearDown(() async => f.dispose());

  RecyclingDraft draft({
    String quantity = '-',
    DateTime? updatedAt,
    int step = 1,
  }) => RecyclingDraft(
    key: 'new-record',
    quantityText: quantity,
    note: 'sin confirmar',
    step: step,
    updatedAt: updatedAt ?? f.now,
    occurredAt: f.now,
  );

  test('borrador parcial persiste al reabrir y no crea registros', () async {
    expect(await f.services.drafts.load('new-record'), isNull);
    await f.services.drafts.save(draft());
    await f.reopen();
    final saved = (await f.services.drafts.load('new-record'))!;
    expect(saved.quantityText, '-');
    expect(saved.pointId, isNull);
    expect(saved.step, 1);
    expect(saved.occurredAt, f.now);
    expect(await f.services.recycling.watch().first, isEmpty);
    await f.services.drafts.clear('new-record');
    await f.services.drafts.clear('new-record');
    await f.reopen();
    expect(await f.services.drafts.load('new-record'), isNull);
  });

  test(
    'guardado viejo no pisa borrador más reciente; misma clave hace upsert',
    () async {
      await f.services.drafts.save(
        draft(quantity: '3', updatedAt: f.now.add(const Duration(seconds: 1))),
      );
      await f.services.drafts.save(draft(quantity: '2'));
      expect((await f.services.drafts.load('new-record'))!.quantityText, '3');
      await f.reopen();
      expect((await f.services.drafts.load('new-record'))!.quantityText, '3');
      expect(
        (await f.db
                .customSelect('SELECT count(*) AS n FROM drafts')
                .getSingle())
            .read<int>('n'),
        1,
      );
    },
  );

  test('paso inválido no sobrescribe borrador', () async {
    await f.services.drafts.save(draft(quantity: '7'));
    await expectLater(
      f.services.drafts.save(draft(step: 3)),
      throwsA(hasCode(LocalDataError.validation)),
    );
    expect((await f.services.drafts.load('new-record'))!.quantityText, '7');
  });

  test(
    'sugerencias locales: crear/listar/reabrir/eliminar; texto se normaliza',
    () async {
      final created = await f.services.suggestions.create(
        '  Mejorar la señalética  ',
      );
      expect(created.message, 'Mejorar la señalética');
      await f.reopen();
      expect((await f.services.suggestions.list()).single.id, created.id);
      await f.services.suggestions.delete(created.id);
      await f.reopen();
      expect(await f.services.suggestions.list(), isEmpty);
      await expectLater(
        f.services.suggestions.delete(created.id),
        throwsA(hasCode(LocalDataError.notFound)),
      );
    },
  );

  test(
    'sugerencias vacías/cortas/largas se rechazan sin filas nuevas',
    () async {
      for (final message in ['', 'abcd', 'x' * 501]) {
        await expectLater(
          f.services.suggestions.create(message),
          throwsA(hasCode(LocalDataError.validation)),
        );
      }
      expect(await f.services.suggestions.list(), isEmpty);
    },
  );

  test('fallo de almacenamiento no borra borrador confirmado', () async {
    await f.services.drafts.save(draft(quantity: '8'));
    await f.services.close();
    await expectLater(
      f.services.drafts.save(draft(quantity: '9')),
      throwsA(hasCode(LocalDataError.storage)),
    );
    await f.reopen();
    expect((await f.services.drafts.load('new-record'))!.quantityText, '8');
  });
}
