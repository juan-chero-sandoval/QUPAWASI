import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:qupa_wasi/data/local/demo_seed.dart';
import 'package:qupa_wasi/domain/entities/recycling_draft.dart';
import 'package:qupa_wasi/domain/entities/recycling_record.dart';
import 'package:qupa_wasi/domain/errors/local_data_exception.dart';
import 'package:qupa_wasi/domain/repositories/draft_repository.dart';
import 'package:qupa_wasi/domain/repositories/records_repository.dart';
import 'package:qupa_wasi/domain/usecases/draft_use_cases.dart';
import 'package:qupa_wasi/domain/usecases/recycling_use_cases.dart';
import 'package:qupa_wasi/presentation/recycling/record_form_view_model.dart';

import '../helpers/local_fixture.dart';

void main() {
  late LocalFixture f;
  setUp(() async => f = await LocalFixture.open());
  tearDown(() async => f.dispose());

  RecordFormViewModel form({
    String? recordId,
    String? pointId,
    RecyclingUseCases? recycling,
    DraftUseCases? drafts,
  }) => RecordFormViewModel(
    recycling: recycling ?? f.services.recycling,
    overview: f.services.overview,
    drafts: drafts ?? f.services.drafts,
    recordId: recordId,
    initialPointId: pointId,
    clock: () => f.now,
    debounce: const Duration(milliseconds: 20),
  );

  Future<void> fillValid(
    RecordFormViewModel vm, {
    String quantity = '2',
    String note = 'prueba',
  }) async {
    vm.selectPoint(DemoSeed.architectureId);
    await vm.nextStep();
    vm.selectMaterial(RecyclingMaterial.pet);
    vm.setQuantityText(quantity);
    vm.setNote(note);
    await vm.nextStep();
  }

  test('crear PET 2 guarda en SQLite y sobrevive a reabrir', () async {
    final vm = form();
    await vm.load();
    expect(vm.status, RecordFormStatus.editing);
    await fillValid(vm);
    expect(vm.step, 2);
    expect(vm.estimatedPoints, 20);

    final id = await vm.save();

    expect(id, isNotNull);
    expect(vm.status, RecordFormStatus.saved);
    expect(
      await f.services.drafts.load(RecordFormViewModel.newDraftKey),
      isNull,
    );
    vm.dispose();
    await f.reopen();
    final saved = (await f.services.recycling.get(id!))!;
    expect(saved.quantity, 2);
    expect(saved.note, 'prueba');
    expect(saved.earnedPoints, 20);
  });

  test('dos toques en Guardar crean un solo registro', () async {
    final vm = form();
    await vm.load();
    await fillValid(vm);

    final results = await Future.wait([vm.save(), vm.save()]);

    expect(results.whereType<String>(), hasLength(1));
    expect(await f.services.recycling.watch().first, hasLength(1));
    vm.dispose();
  });

  test('editar a PET 3 conserva ID y deja 30 puntos sin duplicar', () async {
    final created = await f.services.recycling.create(f.input(quantity: 2));
    final vm = form(recordId: created.id);
    await vm.load();
    expect(vm.status, RecordFormStatus.editing);
    expect(vm.quantityText, '2');
    expect(vm.pointId, DemoSeed.architectureId);

    vm.setQuantityText('3');
    vm.setNote('editada');
    await vm.nextStep();
    await vm.nextStep();
    final id = await vm.save();

    expect(id, created.id);
    final all = await f.services.recycling.watch().first;
    expect(all, hasLength(1));
    expect(all.single.note, 'editada');
    expect(all.single.createdAt, created.createdAt);
    expect((await f.services.overview.getStatistics()).earnedPoints, 30);
    vm.dispose();
  });

  test(
    'cantidades inválidas muestran error y no avanzan ni escriben',
    () async {
      final vm = form();
      await vm.load();
      vm.selectPoint(DemoSeed.architectureId);
      await vm.nextStep();
      vm.selectMaterial(RecyclingMaterial.pet);

      for (final bad in ['', '0', '-1', '101', '1.5', '2,5', 'abc', ' ']) {
        vm.setQuantityText(bad);
        await vm.nextStep();
        expect(vm.step, 1, reason: '"$bad" no debe avanzar');
        expect(vm.quantityError, isNotNull, reason: bad);
      }
      vm.setQuantityText('100');
      await vm.nextStep();
      expect(vm.step, 2);
      expect(await f.services.recycling.watch().first, isEmpty);
      vm.dispose();
    },
  );

  test('sin material ni punto no se puede avanzar', () async {
    final vm = form();
    await vm.load();
    await vm.nextStep();
    expect(vm.step, 0);
    expect(vm.pointError, isNotNull);

    vm.selectPoint(DemoSeed.libraryId);
    await vm.nextStep();
    vm.setQuantityText('2');
    await vm.nextStep();
    expect(vm.step, 1);
    expect(vm.materialError, isNotNull);
    vm.dispose();
  });

  test('pointId válido precarga; inválido no elige otro en silencio', () async {
    final valid = form(pointId: DemoSeed.diningId);
    await valid.load();
    expect(valid.pointId, DemoSeed.diningId);
    expect(valid.pointError, isNull);
    valid.dispose();

    final invalid = form(pointId: 'comedor');
    await invalid.load();
    expect(invalid.pointId, isNull);
    expect(invalid.pointError, contains('no existe'));
    await invalid.nextStep();
    expect(invalid.step, 0);
    invalid.dispose();
  });

  test(
    'borrador incompleto se restaura tras reabrir y se puede descartar',
    () async {
      final vm = form();
      await vm.load();
      vm.selectPoint(DemoSeed.libraryId);
      await vm.nextStep();
      vm.selectMaterial(RecyclingMaterial.aluminum);
      vm.setQuantityText('1.'); // entrada incompleta: se conserva como texto
      vm.setNote('a medias');
      await vm.flushDraft();
      vm.dispose();
      expect(await f.services.recycling.watch().first, isEmpty);

      await f.reopen();
      final restored = form();
      await restored.load();
      expect(restored.status, RecordFormStatus.draftOffer);
      restored.continueDraft();
      expect(restored.status, RecordFormStatus.editing);
      expect(restored.step, 1);
      expect(restored.pointId, DemoSeed.libraryId);
      expect(restored.material, RecyclingMaterial.aluminum);
      expect(restored.quantityText, '1.');
      expect(restored.note, 'a medias');
      restored.dispose();

      final again = form();
      await again.load();
      expect(again.status, RecordFormStatus.draftOffer);
      await again.discardDraft();
      expect(again.status, RecordFormStatus.editing);
      expect(again.pointId, isNull);
      again.dispose();
      await f.reopen();
      expect(
        await f.services.drafts.load(RecordFormViewModel.newDraftKey),
        isNull,
      );
    },
  );

  test('cambios rápidos: el debounce escribe solo el último valor', () async {
    final vm = form();
    await vm.load();
    for (final value in ['1', '12', '12', '123']) {
      vm.setQuantityText(value);
    }
    await Future<void>.delayed(const Duration(milliseconds: 80));
    await vm.flushDraft();

    final draft = await f.services.drafts.load(RecordFormViewModel.newDraftKey);
    expect(draft!.quantityText, '123');
    vm.dispose();
  });

  test('una escritura lenta anterior no pisa al último borrador', () async {
    final slow = _SlowDrafts();
    final vm = form(drafts: DraftUseCases(slow));
    await vm.load();
    vm.setQuantityText('1');
    unawaited(vm.flushDraft()); // primera escritura, lenta
    vm.setQuantityText('2');
    await vm.flushDraft(); // pausa: se encola detrás de la primera

    expect(slow.order, ['1', '2']);
    expect(slow.stored!.quantityText, '2');
    vm.dispose();
  });

  test('error de almacenamiento: sin éxito falso y borrador intacto', () async {
    final failing = RecyclingUseCases(_FailingRecords(), clock: () => f.now);
    final vm = form(recycling: failing);
    await vm.load();
    await fillValid(vm, quantity: '4', note: 'reintentar');

    final id = await vm.save();

    expect(id, isNull);
    expect(vm.status, RecordFormStatus.editing);
    expect(vm.formError, contains('almacenamiento'));
    expect(vm.quantityText, '4');
    final draft = await f.services.drafts.load(RecordFormViewModel.newDraftKey);
    expect(draft!.quantityText, '4');
    expect(draft.note, 'reintentar');
    vm.dispose();
  });

  test(
    'si el registro editado desaparece, solo se convierte tras elegirlo',
    () async {
      final created = await f.services.recycling.create(f.input());
      final other = await f.services.recycling.create(f.input(quantity: 5));
      final vm = form(recordId: created.id);
      await vm.load();
      vm.setNote('cambio pendiente');
      await vm.flushDraft();
      await f.services.recycling.delete(created.id);

      expect(await vm.save(), isNull);
      expect(vm.status, RecordFormStatus.recordMissing);
      expect((await f.services.recycling.get(other.id))!.quantity, 5);

      await vm.convertMissingToNew();
      expect(vm.isEditing, isFalse);
      await vm.nextStep();
      await vm.nextStep();
      final newId = await vm.save();

      expect(newId, isNot(created.id));
      expect(newId, isNot(other.id));
      expect(
        (await f.services.recycling.get(newId!))!.note,
        'cambio pendiente',
      );
      expect(await f.services.recycling.get(created.id), isNull);
      vm.dispose();
    },
  );

  test('al reabrir una edición de un ID borrado ofrece convertir', () async {
    final created = await f.services.recycling.create(f.input());
    final vm = form(recordId: created.id);
    await vm.load();
    vm.setQuantityText('7');
    await vm.flushDraft();
    vm.dispose();
    await f.services.recycling.delete(created.id);

    await f.reopen();
    final reopened = form(recordId: created.id);
    await reopened.load();
    expect(reopened.status, RecordFormStatus.recordMissing);
    await reopened.discardMissing();
    expect(
      await f.services.drafts.load(RecordFormViewModel.editDraftKey),
      isNull,
    );
    reopened.dispose();
  });

  test('editar un ID inexistente sin borrador muestra notFound', () async {
    final vm = form(recordId: '11111111-1111-4111-8111-111111111111');
    await vm.load();
    expect(vm.status, RecordFormStatus.notFound);
    vm.dispose();
  });

  test('cerrar con cambios sin escribir guarda el último valor', () async {
    final vm = form();
    await vm.load();
    vm.setQuantityText('9');
    vm.dispose(); // sin esperar el debounce
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final draft = await f.services.drafts.load(RecordFormViewModel.newDraftKey);
    expect(draft!.quantityText, '9');
  });
}

class _SlowDrafts implements DraftRepository {
  final List<String> order = [];
  RecyclingDraft? stored;
  bool _first = true;

  @override
  Future<RecyclingDraft?> load(String key) async => stored;

  @override
  Future<void> save(RecyclingDraft draft) async {
    if (_first) {
      _first = false;
      await Future<void>.delayed(const Duration(milliseconds: 60));
    }
    order.add(draft.quantityText);
    stored = draft;
  }

  @override
  Future<void> clear(String key) async => stored = null;
}

class _FailingRecords implements RecordsRepository {
  static const _error = LocalDataException(
    LocalDataError.storage,
    'No se pudo acceder al almacenamiento local. Intenta nuevamente.',
  );

  @override
  Stream<List<RecyclingRecord>> watchAll({RecordsFilter? filter}) =>
      Stream.value(const []);

  @override
  Future<RecyclingRecord?> getById(String id) async => null;

  @override
  Future<RecyclingRecord> create(RecordInput input) async => throw _error;

  @override
  Future<RecyclingRecord> update(String id, RecordInput input) async =>
      throw _error;

  @override
  Future<void> delete(String id) async => throw _error;
}
