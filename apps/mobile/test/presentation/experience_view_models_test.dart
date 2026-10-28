import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:qupa_wasi/presentation/home/overview_view_model.dart';
import 'package:qupa_wasi/data/local/demo_seed.dart';
import 'package:qupa_wasi/domain/entities/recycling_statistics.dart';
import 'package:qupa_wasi/domain/entities/reward.dart';
import 'package:qupa_wasi/domain/repositories/preferences_repository.dart';
import 'package:qupa_wasi/presentation/common/local_stream_view_model.dart';
import 'package:qupa_wasi/presentation/rewards/rewards_view_model.dart';
import 'package:qupa_wasi/presentation/suggestions/suggestions_view_model.dart';

import '../helpers/local_fixture.dart';
import '../helpers/fake_preferences_repository.dart';

Future<void> until(bool Function() condition) async {
  for (var i = 0; i < 200; i++) {
    if (condition()) return;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  fail('El estado local no llegó a tiempo');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late LocalFixture f;
  setUp(() async => f = await LocalFixture.open());
  tearDown(() async => f.dispose());

  test('reanudar recalcula racha cuando pasan días sin escrituras', () async {
    await f.services.recycling.create(f.input());
    final vm = OverviewViewModel(f.services.overview);
    await until(() => vm.data != null);
    expect(vm.data!.streakDays, 1);
    f.now = f.now.add(const Duration(days: 2));
    vm.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await until(() => !vm.loading);
    expect(vm.data!.streakDays, 0);
    vm.dispose();
  });

  test(
    'dashboard real reacciona a crear editar eliminar y libera stream',
    () async {
      final vm = LocalStreamViewModel<RecyclingStatistics>(
        f.services.overview.watchStatistics,
      );
      await until(() => vm.data != null);
      expect(vm.data!.availablePoints, 0);
      final record = await f.services.recycling.create(f.input());
      await until(() => vm.data!.availablePoints == 20);
      expect(vm.data!.petCount, 2);
      await f.services.recycling.update(record.id, f.input(quantity: 3));
      await until(() => vm.data!.availablePoints == 30);
      await f.services.recycling.delete(record.id);
      await until(() => vm.data!.recordCount == 0);
      expect(vm.data!.availablePoints, 0);
      vm.dispose();
    },
  );

  test('canje UI doble tap, cancelación y reinicio con SQLite real', () async {
    await f.services.recycling.create(f.input(quantity: 10));
    final prefs = FakePreferencesRepository();
    final vm = RewardsViewModel(f.services.rewards, prefs);
    await until(() => vm.ready && vm.catalog.data != null);
    expect(vm.filtered, hasLength(3));
    vm.filter(RewardCategory.mobile);
    expect(vm.filtered.single.id, DemoSeed.mobileId);
    await Future.wait([
      vm.redeem(DemoSeed.photocopiesId),
      vm.redeem(DemoSeed.photocopiesId),
    ]);
    expect(await f.services.rewards.watchRedemptions().first, hasLength(1));
    expect((await f.services.overview.getStatistics()).availablePoints, 20);
    final redemption =
        (await f.services.rewards.watchRedemptions().first).single;
    await vm.cancel(redemption.id);
    await vm.cancel(redemption.id);
    vm.dispose();
    await f.reopen();
    expect((await f.services.overview.getStatistics()).availablePoints, 100);
    expect(
      (await f.services.rewards.watchRedemptions().first).single.isActive,
      false,
    );
  });

  test(
    'confirmación persistida recupera transacción ya aplicada sin duplicar',
    () async {
      await f.services.recycling.create(f.input(quantity: 10));
      final prefs = FakePreferencesRepository();
      const pending = PendingRedemption(
        DemoSeed.photocopiesId,
        'confirmacion-persistida',
      );
      await prefs.setPendingRedemption(pending);
      await f.services.rewards.redeem(pending.rewardId, pending.operationId);
      await f.reopen();
      final vm = RewardsViewModel(f.services.rewards, prefs);
      await until(() => vm.ready);
      await vm.redeem(pending.rewardId);
      expect(await f.services.rewards.watchRedemptions().first, hasLength(1));
      expect((await f.services.overview.getStatistics()).availablePoints, 20);
      expect(await prefs.loadPendingRedemption(), isNull);
      vm.dispose();
    },
  );

  test('saldo insuficiente conserva operación para reintento', () async {
    final prefs = FakePreferencesRepository();
    final vm = RewardsViewModel(f.services.rewards, prefs);
    await until(() => vm.ready);
    await vm.redeem(DemoSeed.photocopiesId);
    final operation = vm.pending!.operationId;
    expect(vm.message, isNotNull);
    expect(await f.services.rewards.watchRedemptions().first, isEmpty);
    await f.services.recycling.create(f.input(quantity: 10));
    await vm.redeem(DemoSeed.photocopiesId);
    expect(
      (await f.services.rewards.watchRedemptions().first).single.operationId,
      operation,
    );
    vm.dispose();
  });

  test('no escribe canje si falla persistir su identificador', () async {
    final vm = RewardsViewModel(
      f.services.rewards,
      FakePreferencesRepository(failWrites: true),
    );
    await until(() => vm.ready);
    await vm.redeem(DemoSeed.photocopiesId);
    expect(await f.services.rewards.watchRedemptions().first, isEmpty);
    expect(vm.message, isNotNull);
    vm.dispose();
  });

  test('sugerencias validadas, persistentes y eliminación real', () async {
    var vm = SuggestionsViewModel(f.services.suggestions);
    await until(() => !vm.loading);
    expect(await vm.save(' x '), false);
    expect(vm.fieldError, isNotNull);
    expect(await vm.save('Más puntos de ejemplo'), true);
    expect(vm.items.single.message, 'Más puntos de ejemplo');
    vm.dispose();
    await f.reopen();
    vm = SuggestionsViewModel(f.services.suggestions);
    await until(() => !vm.loading);
    await vm.delete(vm.items.single.id);
    vm.dispose();
    await f.reopen();
    expect(await f.services.suggestions.list(), isEmpty);
  });

  test(
    'stream muestra error, reintenta y deja de notificar al disponer',
    () async {
      var attempts = 0;
      final vm = LocalStreamViewModel<int>(
        () => ++attempts == 1
            ? Stream.error(Exception('raw SQL'))
            : Stream.value(7),
      );
      await until(() => vm.error != null);
      expect(vm.error, isNot(contains('raw SQL')));
      vm.reload();
      await until(() => vm.data == 7);
      expect(vm.error, isNull);
      vm.dispose();
    },
  );
}
