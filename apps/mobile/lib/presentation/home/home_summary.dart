import '../../domain/entities/recycling_statistics.dart';

/// Formatting of domain statistics; no independent points calculation.
class HomeSummary {
  factory HomeSummary.fromStatistics(RecyclingStatistics stats) => HomeSummary(
    availablePoints: stats.availablePoints,
    levelName: stats.level.label,
    levelProgress: stats.levelProgress,
    nextLevelText: stats.nextLevel == null
        ? 'Nivel máximo de demostración'
        : 'Te faltan ${stats.pointsToNextLevel} pts para ${stats.nextLevel!.label}',
    petBottles: stats.petCount,
    cans: stats.aluminumCount,
  );
  const HomeSummary({
    required this.availablePoints,
    required this.levelName,
    required this.levelProgress,
    required this.nextLevelText,
    required this.petBottles,
    required this.cans,
  });

  /// Primera instalación: sin registros guardados y saldo cero.
  const HomeSummary.initial()
    : availablePoints = 0,
      levelName = 'Semilla',
      levelProgress = 0,
      nextLevelText = 'Te faltan 200 pts para Brote',
      petBottles = 0,
      cans = 0;

  final int availablePoints;
  final String levelName;

  /// Progreso acotado entre 0 y 1.
  final double levelProgress;
  final String nextLevelText;
  final int petBottles;
  final int cans;
}
