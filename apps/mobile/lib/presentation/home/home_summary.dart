/// Datos que muestra Inicio. En F01 solo existe el estado inicial (sin
/// registros); F02 aporta `StatisticsRepository` y `DemoScoringPolicy`
/// para calcular estos valores desde SQLite.
class HomeSummary {
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
