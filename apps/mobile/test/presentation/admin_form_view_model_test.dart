import 'package:flutter_test/flutter_test.dart';
import 'package:qupa_wasi/data/local/demo_seed.dart';
import 'package:qupa_wasi/domain/entities/geo_position.dart';
import 'package:qupa_wasi/domain/entities/reward.dart';
import 'package:qupa_wasi/domain/errors/local_data_exception.dart';
import 'package:qupa_wasi/presentation/admin/admin_form_view_model.dart';
import 'package:qupa_wasi/presentation/admin/admin_point_form_view_model.dart';
import 'package:qupa_wasi/presentation/admin/admin_reward_form_view_model.dart';

import '../helpers/local_fixture.dart';

void main() {
  late LocalFixture f;
  setUp(() async => f = await LocalFixture.open());
  tearDown(() async => f.dispose());

  AdminPointFormViewModel pointForm({
    String? id,
    Future<GeoPosition> Function()? locate,
  }) => AdminPointFormViewModel(
    admin: f.services.admin!,
    entityId: id,
    clock: () => f.now,
    debounce: const Duration(milliseconds: 20),
    locate: locate ?? () async => const GeoPosition(-5.178213, -80.655671),
  );

  AdminRewardFormViewModel rewardForm({String? id}) => AdminRewardFormViewModel(
    admin: f.services.admin!,
    entityId: id,
    clock: () => f.now,
    debounce: const Duration(milliseconds: 20),
  );

  test('crear tacho: errores junto a cada campo y sin escritura', () async {
    final vm = pointForm();
    await vm.load();
    final before = (await f.services.overview.listPoints()).length;
    vm
      ..setName(' x ')
      ..setOccupancy('150')
      ..setLatitude('abc')
      ..setLongitude('');

    expect(await vm.save(), isFalse);
    expect(vm.nameError, isNotNull);
    expect(vm.occupancyError, isNotNull);
    expect(vm.latitudeError, contains('decimal'));
    expect(vm.longitudeError, contains('Obligatoria'));
    expect(await f.services.overview.listPoints(), hasLength(before));
    vm.dispose();
  });

  test('crear tacho con el GPS y guardarlo en SQLite', () async {
    final vm = pointForm();
    await vm.load();
    vm
      ..setName('Ciencias')
      ..setOccupancy('35');
    expect(await vm.useCurrentLocation(), isTrue);
    expect(vm.latitudeText, '-5.178213');
    expect(vm.longitudeText, '-80.655671');

    expect(await vm.save(), isTrue);
    expect(vm.messageIsError, isFalse);
    vm.dispose();

    await f.reopen();
    final created = (await f.services.overview.listPoints())
        .where((p) => p.name == 'Ciencias')
        .single;
    expect(created.latitude, closeTo(-5.178213, 1e-9));
    expect(created.occupancy, 35);
    expect(await f.services.admin!.loadDraft('admin-point-new'), isNull);
  });

  test('si el GPS falla se avisa y las coordenadas quedan vacías', () async {
    final vm = pointForm(
      locate: () async => throw const LocalDataException(
        LocalDataError.validation,
        'Permiso de ubicación denegado.',
      ),
    );
    await vm.load();
    expect(await vm.useCurrentLocation(), isFalse);
    expect(vm.message, 'Permiso de ubicación denegado.');
    expect(vm.messageIsError, isTrue);
    expect(vm.latitudeText, isEmpty);
    vm.dispose();
  });

  test('editar tacho: precarga, conserva el ID y actualiza', () async {
    final vm = pointForm(id: DemoSeed.libraryId);
    await vm.load();
    expect(vm.status, AdminFormStatus.editing);
    expect(vm.name, 'Biblioteca');
    vm
      ..setLatitude('-5.18')
      ..setLongitude('-80.64')
      ..setName('Biblioteca Central');

    expect(await vm.save(), isTrue);
    final point = (await f.services.admin!.getPoint(DemoSeed.libraryId))!;
    expect(point.name, 'Biblioteca Central');
    expect(point.longitude, -80.64);
    vm.dispose();
  });

  test('borrador incompleto se restaura tras reabrir y se descarta', () async {
    final vm = pointForm();
    await vm.load();
    vm
      ..setName('Medicina')
      ..setLatitude('-5.'); // entrada incompleta: se guarda tal cual
    await vm.flushDraft();
    vm.dispose();

    await f.reopen();
    final restored = pointForm();
    await restored.load();
    expect(restored.status, AdminFormStatus.draftOffer);
    expect(restored.offeredDraftAt, isNotNull);
    restored.continueDraft();
    expect(restored.name, 'Medicina');
    expect(restored.latitudeText, '-5.');
    restored.dispose();

    final again = pointForm();
    await again.load();
    await again.discardDraft();
    expect(again.status, AdminFormStatus.editing);
    expect(again.name, isEmpty);
    again.dispose();
    expect(await f.services.admin!.loadDraft('admin-point-new'), isNull);
  });

  test('cerrar con cambios sin escribir guarda el último valor', () async {
    final vm = pointForm();
    await vm.load();
    vm.setName('Derecho');
    vm.dispose(); // sin esperar el debounce
    for (var i = 0; i < 50; i++) {
      final draft = await f.services.admin!.loadDraft('admin-point-new');
      if (draft?['name'] == 'Derecho') return;
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
    fail('El borrador no se escribió al cerrar');
  });

  test('tacho con registros: eliminar devuelve inUse y se desactiva', () async {
    await f.services.recycling.create(f.input(pointId: DemoSeed.libraryId));
    final vm = pointForm(id: DemoSeed.libraryId);
    await vm.load();

    expect(await vm.delete(), DeleteOutcome.inUse);
    await vm.setActive(false);
    expect(vm.isActive, isFalse);
    expect(
      (await f.services.admin!.getPoint(DemoSeed.libraryId))!.isActive,
      isFalse,
    );
    vm.dispose();
  });

  test('editar un ID inexistente muestra notFound', () async {
    final vm = pointForm(id: '11111111-1111-4111-8111-111111111111');
    await vm.load();
    expect(vm.status, AdminFormStatus.notFound);
    vm.dispose();
  });

  test(
    'recompensa: categoría y costo validados; doble guardado = una',
    () async {
      final vm = rewardForm();
      await vm.load();
      vm
        ..setTitle('Termo reutilizable')
        ..setCost('0');
      expect(await vm.save(), isFalse);
      expect(vm.categoryError, isNotNull);
      expect(vm.costError, isNotNull);

      vm
        ..setCategory(RewardCategory.cafeteria)
        ..setCost('120');
      final results = await Future.wait([vm.save(), vm.save()]);
      expect(results.where((ok) => ok), hasLength(1));
      final created = (await f.services.admin!.watchRewards().first).where(
        (r) => r.title == 'Termo reutilizable',
      );
      expect(created, hasLength(1));
      expect(created.single.costPoints, 120);
      vm.dispose();
    },
  );

  test('recompensa canjeada: eliminar devuelve inUse', () async {
    await f.services.recycling.create(f.input(quantity: 10));
    await f.services.rewards.redeem(DemoSeed.photocopiesId, 'op-admin-vm');
    final vm = rewardForm(id: DemoSeed.photocopiesId);
    await vm.load();
    expect(vm.category, RewardCategory.photocopies);

    expect(await vm.delete(), DeleteOutcome.inUse);
    await vm.setActive(false);
    expect(
      (await f.services.rewards.watchCatalog().first).map((r) => r.id),
      isNot(contains(DemoSeed.photocopiesId)),
    );
    vm.dispose();
  });
}
