import '../entities/recycling_record.dart';
import '../entities/recycling_statistics.dart';
import '../entities/reward.dart';

typedef Clock = DateTime Function();

/// Reglas de demostración; estos puntos no acreditan reciclaje real.
class DemoScoringPolicy {
  const DemoScoringPolicy();

  int pointsPerUnit(RecyclingMaterial material) => switch (material) {
    RecyclingMaterial.pet => 10,
    RecyclingMaterial.aluminum => 5,
  };

  RecyclingStatistics summarize(
    List<RecyclingRecord> records,
    List<Redemption> redemptions, {
    required DateTime now,
  }) {
    var earned = 0;
    var pet = 0;
    var aluminum = 0;
    final days = <DateTime>{};
    final points = <String>{};
    for (final record in records) {
      earned += record.earnedPoints;
      if (record.material == RecyclingMaterial.pet) {
        pet += record.quantity;
      } else {
        aluminum += record.quantity;
      }
      // Normalizar fecha local a medianoche UTC permite contar días civiles
      // sin que un cambio horario convierta un día en 23/25 horas.
      final local = record.occurredAt.toLocal();
      days.add(DateTime.utc(local.year, local.month, local.day));
      points.add(record.pointId);
    }
    final localNow = now.toLocal();
    final today = DateTime.utc(localNow.year, localNow.month, localNow.day);
    var cursor = days.contains(today)
        ? today
        : today.subtract(const Duration(days: 1));
    var streak = 0;
    while (days.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    final active = redemptions.where((r) => r.isActive);
    final spent = active.fold(0, (sum, r) => sum + r.costSnapshot);
    final level = EcoLevel.values.lastWhere((l) => earned >= l.threshold);
    final next = level.index + 1 < EcoLevel.values.length
        ? EcoLevel.values[level.index + 1]
        : null;
    final progress = next == null
        ? 1.0
        : ((earned - level.threshold) / (next.threshold - level.threshold))
              .clamp(0.0, 1.0);
    return RecyclingStatistics(
      earnedPoints: earned,
      spentPoints: spent,
      petCount: pet,
      aluminumCount: aluminum,
      recordCount: records.length,
      streakDays: streak,
      level: level,
      nextLevel: next,
      levelProgress: progress,
      badges: {
        if (records.isNotEmpty) EcoBadge.firstRecord,
        if (streak >= 5) EcoBadge.fiveDayStreak,
        if (pet >= 25) EcoBadge.twentyFivePet,
        if (points.length >= 3) EcoBadge.explorer,
        if (active.isNotEmpty) EcoBadge.firstRedemption,
        if (streak >= 30) EcoBadge.thirtyDayStreak,
      },
    );
  }
}
