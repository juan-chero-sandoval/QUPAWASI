import '../entities/admin_inputs.dart';
import '../entities/recycling_point.dart';
import '../entities/reward.dart';

/// CRUD de tachos para el modo administrador (incluye los desactivados).
abstract interface class AdminPointsRepository {
  Stream<List<RecyclingPoint>> watchAllPoints();
  Future<RecyclingPoint?> getPoint(String id);
  Future<RecyclingPoint> createPoint(PointInput input);
  Future<RecyclingPoint> updatePoint(String id, PointInput input);
  Future<void> setPointActive(String id, {required bool active});

  /// Lanza `LocalDataError.conflict` si el tacho tiene registros: en ese caso
  /// solo puede desactivarse, para no perder historial ni puntos.
  Future<void> deletePoint(String id);
}

/// CRUD del catálogo de recompensas (incluye las desactivadas).
abstract interface class AdminRewardsRepository {
  Stream<List<Reward>> watchAllRewards();
  Future<Reward?> getReward(String id);
  Future<Reward> createReward(RewardInput input);
  Future<Reward> updateReward(String id, RewardInput input);
  Future<void> setRewardActive(String id, {required bool active});

  /// Lanza `LocalDataError.conflict` si la recompensa tiene canjes.
  Future<void> deleteReward(String id);
}

/// Borrador libre (clave → valores escritos) de un formulario de admin.
abstract interface class FormDraftRepository {
  Future<Map<String, Object?>?> load(String key);
  Future<void> save(String key, Map<String, Object?> values, DateTime at);
  Future<void> clear(String key);
}
