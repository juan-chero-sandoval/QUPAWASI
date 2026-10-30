import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/admin_inputs.dart';
import '../../domain/entities/recycling_point.dart';
import '../../domain/entities/reward.dart';
import '../../domain/errors/local_data_exception.dart';
import '../../domain/repositories/admin_catalog_repository.dart';
import '../../domain/usecases/admin_catalog_use_cases.dart';
import '../local/app_database.dart' show AppDatabase;
import '../local/local_data_guard.dart';
import '../local/row_mapping.dart';

const _notFound = LocalDataException(
  LocalDataError.notFound,
  'El elemento ya no existe.',
);

/// Tachos y recompensas editables por el administrador simulado.
class SqliteAdminCatalogRepository
    implements AdminPointsRepository, AdminRewardsRepository {
  SqliteAdminCatalogRepository(this._db);
  final AppDatabase _db;

  // ---- Tachos ----

  @override
  Stream<List<RecyclingPoint>> watchAllPoints() => guardLocalStream(
    _db
        .customSelect(
          'SELECT * FROM recycling_points ORDER BY is_active DESC, name, id',
          readsFrom: {_db.recyclingPoints},
        )
        .watch()
        .map((rows) => List.unmodifiable(rows.map(pointFromRow))),
  );

  @override
  Future<RecyclingPoint?> getPoint(String id) =>
      guardLocalData(() => _findPoint(id));

  Future<RecyclingPoint?> _findPoint(String id) async {
    final row = await _db
        .customSelect(
          'SELECT * FROM recycling_points WHERE id=?',
          variables: [Variable<String>(id)],
          readsFrom: {_db.recyclingPoints},
        )
        .getSingleOrNull();
    return row == null ? null : pointFromRow(row);
  }

  @override
  Future<RecyclingPoint> createPoint(PointInput input) => guardLocalData(() {
    AdminCatalogUseCases.validatePoint(input);
    return _db.transaction(() async {
      final id = const Uuid().v4();
      await _db.customInsert(
        'INSERT INTO recycling_points '
        '(id,name,description,occupancy,latitude,longitude,is_demo,is_active) '
        'VALUES (?,?,?,?,?,?,0,1)',
        variables: [Variable<String>(id), ..._pointValues(input)],
        updates: {_db.recyclingPoints},
      );
      return (await _findPoint(id))!;
    });
  });

  @override
  Future<RecyclingPoint> updatePoint(String id, PointInput input) =>
      guardLocalData(() {
        AdminCatalogUseCases.validatePoint(input);
        return _db.transaction(() async {
          final affected = await _db.customUpdate(
            'UPDATE recycling_points SET name=?,description=?,occupancy=?,'
            'latitude=?,longitude=? WHERE id=?',
            variables: [..._pointValues(input), Variable<String>(id)],
            updates: {_db.recyclingPoints},
          );
          if (affected == 0) throw _notFound;
          return (await _findPoint(id))!;
        });
      });

  List<Variable<Object>> _pointValues(PointInput input) => [
    Variable<String>(input.name.trim()),
    Variable<String>(input.description.trim()),
    Variable<int>(input.occupancy),
    Variable<double>(input.latitude),
    Variable<double>(input.longitude),
  ];

  @override
  Future<void> setPointActive(String id, {required bool active}) =>
      guardLocalData(() async {
        final affected = await _db.customUpdate(
          'UPDATE recycling_points SET is_active=? WHERE id=?',
          variables: [Variable<int>(active ? 1 : 0), Variable<String>(id)],
          updates: {_db.recyclingPoints},
        );
        if (affected == 0) throw _notFound;
      });

  @override
  Future<void> deletePoint(String id) => guardLocalData(
    () => _db.transaction(() async {
      final used = await _db
          .customSelect(
            'SELECT 1 FROM recycling_records WHERE point_id=? LIMIT 1',
            variables: [Variable<String>(id)],
            readsFrom: {_db.recyclingRecords},
          )
          .getSingleOrNull();
      if (used != null) {
        throw const LocalDataException(
          LocalDataError.conflict,
          'Este tacho tiene registros. Desactívalo para conservar el historial.',
        );
      }
      final affected = await _db.customUpdate(
        'DELETE FROM recycling_points WHERE id=?',
        variables: [Variable<String>(id)],
        updates: {_db.recyclingPoints},
        updateKind: UpdateKind.delete,
      );
      if (affected == 0) throw _notFound;
    }),
  );

  // ---- Recompensas ----

  @override
  Stream<List<Reward>> watchAllRewards() => guardLocalStream(
    _db
        .customSelect(
          'SELECT * FROM rewards ORDER BY is_active DESC, cost_points, id',
          readsFrom: {_db.rewards},
        )
        .watch()
        .map((rows) => List.unmodifiable(rows.map(rewardFromRow))),
  );

  @override
  Future<Reward?> getReward(String id) => guardLocalData(() => _findReward(id));

  Future<Reward?> _findReward(String id) async {
    final row = await _db
        .customSelect(
          'SELECT * FROM rewards WHERE id=?',
          variables: [Variable<String>(id)],
          readsFrom: {_db.rewards},
        )
        .getSingleOrNull();
    return row == null ? null : rewardFromRow(row);
  }

  @override
  Future<Reward> createReward(RewardInput input) => guardLocalData(() {
    AdminCatalogUseCases.validateReward(input);
    return _db.transaction(() async {
      final id = const Uuid().v4();
      await _db.customInsert(
        'INSERT INTO rewards (id,title,category,cost_points,description,is_active) '
        'VALUES (?,?,?,?,?,1)',
        variables: [Variable<String>(id), ..._rewardValues(input)],
        updates: {_db.rewards},
      );
      return (await _findReward(id))!;
    });
  });

  @override
  Future<Reward> updateReward(
    String id,
    RewardInput input,
  ) => guardLocalData(() {
    AdminCatalogUseCases.validateReward(input);
    return _db.transaction(() async {
      // Los canjes guardan título y costo en su snapshot: editar no los altera.
      final affected = await _db.customUpdate(
        'UPDATE rewards SET title=?,category=?,cost_points=?,description=? '
        'WHERE id=?',
        variables: [..._rewardValues(input), Variable<String>(id)],
        updates: {_db.rewards},
      );
      if (affected == 0) throw _notFound;
      return (await _findReward(id))!;
    });
  });

  List<Variable<Object>> _rewardValues(RewardInput input) => [
    Variable<String>(input.title.trim()),
    Variable<String>(input.category.name),
    Variable<int>(input.costPoints),
    Variable<String>(input.description.trim()),
  ];

  @override
  Future<void> setRewardActive(String id, {required bool active}) =>
      guardLocalData(() async {
        final affected = await _db.customUpdate(
          'UPDATE rewards SET is_active=? WHERE id=?',
          variables: [Variable<int>(active ? 1 : 0), Variable<String>(id)],
          updates: {_db.rewards},
        );
        if (affected == 0) throw _notFound;
      });

  @override
  Future<void> deleteReward(String id) => guardLocalData(
    () => _db.transaction(() async {
      final used = await _db
          .customSelect(
            'SELECT 1 FROM redemptions WHERE reward_id=? LIMIT 1',
            variables: [Variable<String>(id)],
            readsFrom: {_db.redemptions},
          )
          .getSingleOrNull();
      if (used != null) {
        throw const LocalDataException(
          LocalDataError.conflict,
          'Esta recompensa tiene canjes. Desactívala para conservar el historial.',
        );
      }
      final affected = await _db.customUpdate(
        'DELETE FROM rewards WHERE id=?',
        variables: [Variable<String>(id)],
        updates: {_db.rewards},
        updateKind: UpdateKind.delete,
      );
      if (affected == 0) throw _notFound;
    }),
  );
}

/// Borradores de formularios de administración como JSON en SQLite.
class SqliteFormDraftRepository implements FormDraftRepository {
  SqliteFormDraftRepository(this._db);
  final AppDatabase _db;

  @override
  Future<Map<String, Object?>?> load(String key) => guardLocalData(() async {
    final row = await _db
        .customSelect(
          'SELECT payload FROM form_drafts WHERE key=?',
          variables: [Variable<String>(key)],
          readsFrom: {_db.formDrafts},
        )
        .getSingleOrNull();
    if (row == null) return null;
    final decoded = jsonDecode(row.read<String>('payload'));
    return decoded is Map ? Map<String, Object?>.from(decoded) : null;
  });

  @override
  Future<void> save(String key, Map<String, Object?> values, DateTime at) =>
      guardLocalData(() async {
        final payload = jsonEncode(values);
        if (payload.length > 4000) {
          throw const LocalDataException(
            LocalDataError.validation,
            'El borrador es demasiado largo.',
          );
        }
        // Una escritura más antigua nunca pisa a una más reciente.
        await _db.customInsert(
          'INSERT INTO form_drafts (key,payload,updated_at) VALUES (?,?,?) '
          'ON CONFLICT(key) DO UPDATE SET payload=excluded.payload,'
          'updated_at=excluded.updated_at '
          'WHERE excluded.updated_at >= form_drafts.updated_at',
          variables: [
            Variable<String>(key),
            Variable<String>(payload),
            Variable<int>(at.toUtc().millisecondsSinceEpoch),
          ],
          updates: {_db.formDrafts},
        );
      });

  @override
  Future<void> clear(String key) => guardLocalData(() async {
    await _db.customUpdate(
      'DELETE FROM form_drafts WHERE key=?',
      variables: [Variable<String>(key)],
      updates: {_db.formDrafts},
      updateKind: UpdateKind.delete,
    );
  });
}
