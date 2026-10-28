enum RewardCategory { photocopies, mobile, cafeteria }

class Reward {
  const Reward({
    required this.id,
    required this.title,
    required this.category,
    required this.costPoints,
    required this.description,
    required this.isActive,
  });

  final String id;
  final String title;
  final RewardCategory category;
  final int costPoints;
  final String description;
  final bool isActive;
}

class Redemption {
  const Redemption({
    required this.id,
    required this.operationId,
    required this.rewardId,
    required this.titleSnapshot,
    required this.costSnapshot,
    required this.createdAt,
    this.canceledAt,
  });

  final String id;
  final String operationId;
  final String rewardId;
  final String titleSnapshot;
  final int costSnapshot;
  final DateTime createdAt;
  final DateTime? canceledAt;
  bool get isActive => canceledAt == null;
}
