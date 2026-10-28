import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/reward.dart';
import '../../domain/errors/local_data_exception.dart';
import '../../domain/policies/demo_scoring_policy.dart';
import '../../domain/policies/local_validation.dart';
import '../../domain/repositories/rewards_repository.dart';
import '../local/app_database.dart' show AppDatabase;
import '../local/local_data_guard.dart';
import '../local/row_mapping.dart';

class SqliteRewardsRepository implements RewardsRepository {
  SqliteRewardsRepository(this._db, {Clock? clock})
    : _clock = clock ?? DateTime.now;
  final AppDatabase _db;
  final Clock _clock;

  @override
  Stream<List<Reward>> watchCatalog({
    RewardCategory? category,
  }) => guardLocalStream(
    _db
        .customSelect(
          'SELECT * FROM rewards WHERE is_active=1 '
          '${category == null ? '' : 'AND category=? '}ORDER BY cost_points, id',
          variables: [if (category != null) Variable<String>(category.name)],
          readsFrom: {_db.rewards},
        )
        .watch()
        .map((rows) => List.unmodifiable(rows.map(rewardFromRow))),
  );

  @override
  Stream<List<Redemption>> watchRedemptions() => guardLocalStream(
    _db
        .customSelect(
          'SELECT * FROM redemptions ORDER BY created_at DESC, id',
          readsFrom: {_db.redemptions},
        )
        .watch()
        .map((rows) => List.unmodifiable(rows.map(redemptionFromRow))),
  );

  @override
  Future<Redemption> redeem(String rewardId, String operationId) =>
      guardLocalData(() async {
        LocalValidation.id(rewardId);
        LocalValidation.id(operationId);
        return _db.transaction(() async {
          final previous = await _db
              .customSelect(
                'SELECT * FROM redemptions WHERE operation_id=?',
                variables: [Variable<String>(operationId)],
              )
              .getSingleOrNull();
          if (previous != null) {
            if (previous.read<String>('reward_id') != rewardId) {
              throw const LocalDataException(
                LocalDataError.conflict,
                'Esta operación ya se usó para otra recompensa.',
              );
            }
            // Un reintento de un canje cancelado tampoco lo reactiva.
            return redemptionFromRow(previous);
          }
          final reward = await _db
              .customSelect(
                'SELECT * FROM rewards WHERE id=? AND is_active=1',
                variables: [Variable<String>(rewardId)],
              )
              .getSingleOrNull();
          if (reward == null) {
            throw const LocalDataException(
              LocalDataError.notFound,
              'La recompensa no está disponible.',
            );
          }
          final id = const Uuid().v4();
          await _db.customInsert(
            'INSERT INTO redemptions '
            '(id,operation_id,reward_id,title_snapshot,cost_snapshot,created_at) VALUES (?,?,?,?,?,?)',
            variables: [
              Variable<String>(id),
              Variable<String>(operationId),
              Variable<String>(rewardId),
              Variable<String>(reward.read<String>('title')),
              Variable<int>(reward.read<int>('cost_points')),
              Variable<int>(_clock().toUtc().millisecondsSinceEpoch),
            ],
            updates: {_db.redemptions},
          );
          final created = await _db
              .customSelect(
                'SELECT * FROM redemptions WHERE id=?',
                variables: [Variable<String>(id)],
              )
              .getSingle();
          return redemptionFromRow(created);
        });
      });

  @override
  Future<void> cancelRedemption(String id) => guardLocalData(() async {
    LocalValidation.id(id);
    await _db.transaction(() async {
      final exists = await _db
          .customSelect(
            'SELECT id FROM redemptions WHERE id=?',
            variables: [Variable<String>(id)],
          )
          .getSingleOrNull();
      if (exists == null) {
        throw const LocalDataException(
          LocalDataError.notFound,
          'El canje no existe.',
        );
      }
      await _db.customUpdate(
        'UPDATE redemptions SET canceled_at=? WHERE id=? AND canceled_at IS NULL',
        variables: [
          Variable<int>(_clock().toUtc().millisecondsSinceEpoch),
          Variable<String>(id),
        ],
        updates: {_db.redemptions},
      );
    });
  });
}
