import '../entities/reward.dart';
import '../policies/local_validation.dart';
import '../repositories/rewards_repository.dart';

class RewardsUseCases {
  const RewardsUseCases(this._rewards);
  final RewardsRepository _rewards;

  Stream<List<Reward>> watchCatalog({RewardCategory? category}) =>
      _rewards.watchCatalog(category: category);
  Stream<List<Redemption>> watchRedemptions() => _rewards.watchRedemptions();

  Future<Redemption> redeem(String rewardId, String operationId) async {
    LocalValidation.id(rewardId);
    LocalValidation.id(operationId);
    return _rewards.redeem(rewardId, operationId);
  }

  Future<void> cancel(String redemptionId) async {
    LocalValidation.id(redemptionId);
    await _rewards.cancelRedemption(redemptionId);
  }
}
