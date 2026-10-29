import 'dart:async';

import 'package:qupa_wasi/data/local/demo_seed.dart';
import 'package:qupa_wasi/domain/entities/admin_inputs.dart';
import 'package:qupa_wasi/domain/entities/recycling_point.dart';
import 'package:qupa_wasi/domain/entities/reward.dart';
import 'package:qupa_wasi/domain/errors/local_data_exception.dart';
import 'package:qupa_wasi/domain/repositories/admin_catalog_repository.dart';

import 'fake_local_services.dart';

/// Tachos, recompensas y borradores del administrador en memoria, para
/// pruebas de widgets. La persistencia real se prueba en
/// `test/data/sqlite_admin_catalog_test.dart`.
class FakeAdminCatalog
    implements
        AdminPointsRepository,
        AdminRewardsRepository,
        FormDraftRepository {
  FakeAdminCatalog(this._records) {
    for (final p in DemoSeed.points) {
      points[p.id] = p;
    }
    for (final r in DemoSeed.rewards) {
      rewards[r.id] = r;
    }
  }

  final FakeRecordsRepository _records;
  final Map<String, RecyclingPoint> points = {};
  final Map<String, Reward> rewards = {};
  final Map<String, Map<String, Object?>> drafts = {};

  /// Recompensas que se consideran ya canjeadas (no se pueden borrar).
  final Set<String> redeemedRewardIds = {};
  final _changes = StreamController<void>.broadcast();
  int _next = 1;

  String _id() => '00000000-0000-4000-a000-${'${_next++}'.padLeft(12, '0')}';

  Stream<T> _watch<T>(T Function() read) {
    late StreamController<T> controller;
    StreamSubscription<void>? sub;
    controller = StreamController<T>(
      onListen: () {
        controller.add(read());
        sub = _changes.stream.listen((_) => controller.add(read()));
      },
      onCancel: () => sub?.cancel(),
    );
    return controller.stream;
  }

  RecyclingPoint _point(String id, PointInput input, {bool active = true}) =>
      RecyclingPoint(
        id: id,
        name: input.name,
        description: input.description,
        occupancy: input.occupancy,
        latitude: input.latitude,
        longitude: input.longitude,
        isDemo: false,
        isActive: active,
      );

  @override
  Stream<List<RecyclingPoint>> watchAllPoints() =>
      _watch(() => List.unmodifiable(points.values));

  @override
  Future<RecyclingPoint?> getPoint(String id) async => points[id];

  @override
  Future<RecyclingPoint> createPoint(PointInput input) async {
    final point = _point(_id(), input);
    points[point.id] = point;
    _changes.add(null);
    return point;
  }

  @override
  Future<RecyclingPoint> updatePoint(String id, PointInput input) async {
    final old = points[id] ?? (throw _missing);
    final point = _point(id, input, active: old.isActive);
    points[id] = point;
    _changes.add(null);
    return point;
  }

  @override
  Future<void> setPointActive(String id, {required bool active}) async {
    final p = points[id] ?? (throw _missing);
    points[id] = RecyclingPoint(
      id: p.id,
      name: p.name,
      description: p.description,
      occupancy: p.occupancy,
      latitude: p.latitude,
      longitude: p.longitude,
      isDemo: p.isDemo,
      isActive: active,
    );
    _changes.add(null);
  }

  @override
  Future<void> deletePoint(String id) async {
    if (_records.all.any((r) => r.pointId == id)) {
      throw const LocalDataException(
        LocalDataError.conflict,
        'Este tacho tiene registros.',
      );
    }
    if (points.remove(id) == null) throw _missing;
    _changes.add(null);
  }

  Reward _reward(String id, RewardInput input, {bool active = true}) => Reward(
    id: id,
    title: input.title,
    category: input.category,
    costPoints: input.costPoints,
    description: input.description,
    isActive: active,
  );

  @override
  Stream<List<Reward>> watchAllRewards() =>
      _watch(() => List.unmodifiable(rewards.values));

  @override
  Future<Reward?> getReward(String id) async => rewards[id];

  @override
  Future<Reward> createReward(RewardInput input) async {
    final reward = _reward(_id(), input);
    rewards[reward.id] = reward;
    _changes.add(null);
    return reward;
  }

  @override
  Future<Reward> updateReward(String id, RewardInput input) async {
    final old = rewards[id] ?? (throw _missing);
    final reward = _reward(id, input, active: old.isActive);
    rewards[id] = reward;
    _changes.add(null);
    return reward;
  }

  @override
  Future<void> setRewardActive(String id, {required bool active}) async {
    final r = rewards[id] ?? (throw _missing);
    rewards[id] = Reward(
      id: r.id,
      title: r.title,
      category: r.category,
      costPoints: r.costPoints,
      description: r.description,
      isActive: active,
    );
    _changes.add(null);
  }

  @override
  Future<void> deleteReward(String id) async {
    if (redeemedRewardIds.contains(id)) {
      throw const LocalDataException(
        LocalDataError.conflict,
        'Esta recompensa tiene canjes.',
      );
    }
    if (rewards.remove(id) == null) throw _missing;
    _changes.add(null);
  }

  @override
  Future<Map<String, Object?>?> load(String key) async => drafts[key];

  @override
  Future<void> save(
    String key,
    Map<String, Object?> values,
    DateTime at,
  ) async => drafts[key] = Map.of(values);

  @override
  Future<void> clear(String key) async => drafts.remove(key);

  static const _missing = LocalDataException(
    LocalDataError.notFound,
    'El elemento ya no existe.',
  );
}
