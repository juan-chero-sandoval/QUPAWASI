enum EcoLevel {
  seed('Semilla', 0),
  sprout('Brote', 200),
  youngTree('Árbol joven', 500),
  forestGuardian('Guardián del bosque', 1000);

  const EcoLevel(this.label, this.threshold);
  final String label;
  final int threshold;
}

enum EcoBadge {
  firstRecord,
  fiveDayStreak,
  twentyFivePet,
  explorer,
  firstRedemption,
  thirtyDayStreak,
}

class RecyclingStatistics {
  RecyclingStatistics({
    required this.earnedPoints,
    required this.spentPoints,
    required this.petCount,
    required this.aluminumCount,
    required this.recordCount,
    required this.streakDays,
    required this.level,
    required this.nextLevel,
    required this.levelProgress,
    required Set<EcoBadge> badges,
  }) : badges = Set.unmodifiable(badges);

  final int earnedPoints;
  final int spentPoints;
  final int petCount;
  final int aluminumCount;
  final int recordCount;
  final int streakDays;
  final EcoLevel level;
  final EcoLevel? nextLevel;
  final double levelProgress;
  final Set<EcoBadge> badges;
  int get availablePoints => earnedPoints - spentPoints;
  int get pointsToNextLevel =>
      (nextLevel?.threshold ?? earnedPoints) - earnedPoints;

  /// No hay factores físicos validados en esta entrega.
  double? get estimatedMassKg => null;
  double? get estimatedCo2Kg => null;
}
