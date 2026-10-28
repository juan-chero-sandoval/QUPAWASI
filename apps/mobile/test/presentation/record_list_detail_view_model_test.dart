import 'package:flutter_test/flutter_test.dart';
import 'package:qupa_wasi/data/local/demo_seed.dart';
import 'package:qupa_wasi/domain/entities/recycling_draft.dart';
import 'package:qupa_wasi/domain/entities/recycling_record.dart';
import 'package:qupa_wasi/presentation/recycling/record_detail_view_model.dart';
import 'package:qupa_wasi/presentation/recycling/record_form_view_model.dart';
import 'package:qupa_wasi/presentation/recycling/record_list_view_model.dart';
import 'package:uuid/uuid.dart';

import '../helpers/fake_local_services.dart';
import '../helpers/local_fixture.dart';

/// Espera a que el stream de SQLite (isolate) entregue el estado esperado.
Future<void> until(bool Function() condition) async {
  for (var i = 0; i < 100 && !condition(); i++) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  expect(condition(), isTrue, reason: 'Estado no alcanzado a tiempo');
}

void main() {
  group('con SQLite real', () {
    late LocalFixture f;
    setUp(() async => f = await LocalFixture.open());
    tearDown(() async => f.dispose());

    test('la lista reacciona a crear, editar y eliminar', () async {
      final vm = RecordListViewModel(
        recycling: f.services.recycling,
        overview: f.services.overview,
        drafts: f.services.drafts,
      );
      await vm.start();
      await until(() => vm.status == RecordListStatus.empty);

      final created = await f.services.recycling.create(f.input());
      await until(() => vm.records.length == 1);
      expect(vm.pointName(created.pointId), 'Arquitectura');

      await f.services.recycling.update(created.id, f.input(quantity: 3));
      await until(() => vm.records.single.quantity == 3);

      await f.services.recycling.delete(created.id);
      await until(() => vm.status == RecordListStatus.empty);
      vm.dispose();
    });

    test('el filtro por material solo muestra ese material', () async {
      await f.services.recycling.create(f.input());
      await f.services.recycling.create(
        f.input(material: RecyclingMaterial.aluminum),
      );
      final vm = RecordListViewModel(
        recycling: f.services.recycling,
        overview: f.services.overview,
        drafts: f.services.drafts,
        material: RecordListViewModel.parseFilter('aluminum'),
      );
      await vm.start();
      await until(() => vm.status == RecordListStatus.data);
      expect(vm.records.single.material, RecyclingMaterial.aluminum);
      expect(RecordListViewModel.parseFilter('vidrio'), isNull);
      vm.dispose();
    });

    test(
      'la lista muestra el borrador pendiente y permite descartarlo',
      () async {
        await f.services.drafts.save(
          RecyclingDraft(
            key: RecordFormViewModel.newDraftKey,
            quantityText: '2',
            note: '',
            step: 1,
            updatedAt: f.now,
          ),
        );
        final vm = RecordListViewModel(
          recycling: f.services.recycling,
          overview: f.services.overview,
          drafts: f.services.drafts,
        );
        await vm.start();
        expect(vm.pendingDraft?.key, RecordFormViewModel.newDraftKey);

        await vm.discardPendingDraft();
        expect(vm.pendingDraft, isNull);
        vm.dispose();
      },
    );

    test('el detalle sigue la edición y detecta un borrado externo', () async {
      final created = await f.services.recycling.create(f.input());
      final vm = RecordDetailViewModel(
        recycling: f.services.recycling,
        overview: f.services.overview,
        recordId: created.id,
      );
      await vm.load();
      expect((vm.state as RecordDetailData).record.quantity, 2);

      await f.services.recycling.update(created.id, f.input(quantity: 4));
      await until(
        () =>
            vm.state is RecordDetailData &&
            (vm.state as RecordDetailData).record.quantity == 4,
      );

      await f.services.recycling.delete(created.id);
      await until(() => vm.state is RecordDetailNotFound);
      vm.dispose();
    });

    test('un ID con formato inválido se trata como inexistente', () async {
      final vm = RecordDetailViewModel(
        recycling: f.services.recycling,
        overview: f.services.overview,
        recordId: ' ',
      );
      await vm.load();
      expect(vm.state, isA<RecordDetailNotFound>());
      vm.dispose();
    });

    test(
      'borrar puntos ya canjeados se rechaza y explica cómo liberar',
      () async {
        final created = await f.services.recycling.create(
          f.input(quantity: 10),
        );
        await f.services.rewards.redeem(
          DemoSeed.photocopiesId,
          const Uuid().v4(),
        );
        final vm = RecordDetailViewModel(
          recycling: f.services.recycling,
          overview: f.services.overview,
          recordId: created.id,
        );
        await vm.load();

        expect(await vm.delete(), isFalse);
        expect(vm.deleteError, contains('Cancela primero'));
        expect(vm.deleteError, contains('Premios'));
        expect(await f.services.recycling.get(created.id), isNotNull);
        vm.dispose();
      },
    );

    test('eliminar borra el registro y no vuelve tras reabrir', () async {
      final created = await f.services.recycling.create(f.input());
      final vm = RecordDetailViewModel(
        recycling: f.services.recycling,
        overview: f.services.overview,
        recordId: created.id,
      );
      await vm.load();
      expect(await vm.delete(), isTrue);
      vm.dispose();

      await f.reopen();
      expect(await f.services.recycling.get(created.id), isNull);
      expect((await f.services.overview.getStatistics()).earnedPoints, 0);
    });
  });

  test(
    'reintentar o volver a entrar no multiplica las suscripciones',
    () async {
      final local = FakeLocal();
      final vm = RecordListViewModel(
        recycling: local.services.recycling,
        overview: local.services.overview,
        drafts: local.services.drafts,
      );
      await vm.start();
      await vm.start();
      await vm.start();
      await Future<void>.delayed(Duration.zero);
      expect(local.records.activeWatchers, 1);

      vm.dispose();
      await Future<void>.delayed(Duration.zero);
      expect(local.records.activeWatchers, 0);

      // Tras dispose, un cambio del stream no notifica ni lanza.
      await local.seedRecord();
    },
  );
}
