import '../entities/reward.dart';

abstract interface class RewardsRepository {
  Stream<List<Reward>> watchCatalog({RewardCategory? category});
  Stream<List<Redemption>> watchRedemptions();
  Future<Redemption> redeem(String rewardId, String operationId);
  Future<void> cancelRedemption(String id);
}
