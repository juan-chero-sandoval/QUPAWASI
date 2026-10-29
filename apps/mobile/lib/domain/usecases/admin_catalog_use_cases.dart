import '../entities/admin_inputs.dart';
import '../entities/deposit_qr.dart';
import '../entities/recycling_point.dart';
import '../entities/reward.dart';
import '../errors/local_data_exception.dart';
import '../policies/local_validation.dart';
import '../repositories/admin_catalog_repository.dart';

/// Casos de uso del administrador simulado: valida antes de escribir y deja
/// que el repositorio vuelva a validar dentro de la transacción.
class AdminCatalogUseCases {
  const AdminCatalogUseCases(this._points, this._rewards, this._drafts);

  final AdminPointsRepository _points;
  final AdminRewardsRepository _rewards;
  final FormDraftRepository _drafts;

  Stream<List<RecyclingPoint>> watchPoints() => _points.watchAllPoints();

  Future<RecyclingPoint?> getPoint(String id) async {
    LocalValidation.id(id);
    return _points.getPoint(id);
  }

  Future<RecyclingPoint> createPoint(PointInput input) async {
    validatePoint(input);
    return _points.createPoint(input);
  }

  Future<RecyclingPoint> updatePoint(String id, PointInput input) async {
    LocalValidation.id(id);
    validatePoint(input);
    return _points.updatePoint(id, input);
  }

  Future<void> setPointActive(String id, {required bool active}) async {
    LocalValidation.id(id);
    await _points.setPointActive(id, active: active);
  }

  Future<void> deletePoint(String id) async {
    LocalValidation.id(id);
    await _points.deletePoint(id);
  }

  Stream<List<Reward>> watchRewards() => _rewards.watchAllRewards();

  Future<Reward?> getReward(String id) async {
    LocalValidation.id(id);
    return _rewards.getReward(id);
  }

  Future<Reward> createReward(RewardInput input) async {
    validateReward(input);
    return _rewards.createReward(input);
  }

  Future<Reward> updateReward(String id, RewardInput input) async {
    LocalValidation.id(id);
    validateReward(input);
    return _rewards.updateReward(id, input);
  }

  Future<void> setRewardActive(String id, {required bool active}) async {
    LocalValidation.id(id);
    await _rewards.setRewardActive(id, active: active);
  }

  Future<void> deleteReward(String id) async {
    LocalValidation.id(id);
    await _rewards.deleteReward(id);
  }

  Future<Map<String, Object?>?> loadDraft(String key) async {
    LocalValidation.id(key);
    return _drafts.load(key);
  }

  Future<void> saveDraft(String key, Map<String, Object?> values, DateTime at) {
    LocalValidation.id(key);
    return _drafts.save(key, values, at);
  }

  Future<void> clearDraft(String key) async {
    LocalValidation.id(key);
    await _drafts.clear(key);
  }

  static void validatePoint(PointInput input) {
    final name = input.name.trim();
    _require(
      name.length >= AdminLimits.pointNameMin &&
          name.length <= AdminLimits.pointNameMax,
      'El nombre debe tener entre ${AdminLimits.pointNameMin} y '
      '${AdminLimits.pointNameMax} caracteres.',
    );
    _require(
      input.description.trim().length <= AdminLimits.descriptionMax,
      'La descripción admite hasta ${AdminLimits.descriptionMax} caracteres.',
    );
    _require(
      input.occupancy >= 0 && input.occupancy <= 100,
      'La ocupación debe estar entre 0 y 100.',
    );
    _require(
      validCoordinates(input.latitude, input.longitude),
      'Las coordenadas no son válidas.',
    );
  }

  static void validateReward(RewardInput input) {
    final title = input.title.trim();
    _require(
      title.length >= AdminLimits.rewardTitleMin &&
          title.length <= AdminLimits.rewardTitleMax,
      'El título debe tener entre ${AdminLimits.rewardTitleMin} y '
      '${AdminLimits.rewardTitleMax} caracteres.',
    );
    _require(
      input.costPoints >= AdminLimits.costMin &&
          input.costPoints <= AdminLimits.costMax,
      'El costo debe estar entre ${AdminLimits.costMin} y '
      '${AdminLimits.costMax} puntos.',
    );
    _require(
      input.description.trim().length <= AdminLimits.descriptionMax,
      'La descripción admite hasta ${AdminLimits.descriptionMax} caracteres.',
    );
  }

  static void _require(bool valid, String message) {
    if (!valid) throw LocalDataException(LocalDataError.validation, message);
  }
}
