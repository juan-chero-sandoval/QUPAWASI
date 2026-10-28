import 'package:flutter_test/flutter_test.dart';
import 'package:qupa_wasi/domain/entities/recycling_record.dart';
import 'package:qupa_wasi/domain/entities/recycling_statistics.dart';
import 'package:qupa_wasi/domain/entities/reward.dart';
import 'package:qupa_wasi/domain/policies/demo_scoring_policy.dart';

void main() {
  const policy = DemoScoringPolicy();
  final now = DateTime(2026, 10, 28, 12);

  RecyclingRecord record(
    int index, {
    int quantity = 1,
    int unitPoints = 10,
    String point = 'p1',
    int daysAgo = 0,
  }) => RecyclingRecord(
    id: 'r$index',
    pointId: point,
    material: RecyclingMaterial.pet,
    quantity: quantity,
    unitPoints: unitPoints,
    occurredAt: now.subtract(Duration(days: daysAgo)),
    note: '',
    createdAt: now,
    updatedAt: now,
  );

  test('vacío: Semilla, progreso cero, sin racha ni factores de impacto inventados', () {
    final result = policy.summarize([], [], now: now);
    expect(result.availablePoints, 0);
    expect(result.level, EcoLevel.seed);
    expect(result.nextLevel, EcoLevel.sprout);
    expect(result.pointsToNextLevel, 200);
    expect(result.levelProgress, 0);
    expect(result.streakDays, 0);
    expect(result.badges, isEmpty);
    expect(result.estimatedMassKg, isNull);
    expect(result.estimatedCo2Kg, isNull);
    expect(policy.pointsPerUnit(RecyclingMaterial.aluminum), 5);
  });

  test('niveles se basan en ganado y progreso permanece acotado', () {
    for (final entry in {
      0: EcoLevel.seed,
      190: EcoLevel.seed,
      200: EcoLevel.sprout,
      500: EcoLevel.youngTree,
      1000: EcoLevel.forestGuardian,
      1500: EcoLevel.forestGuardian,
    }.entries) {
      final result = policy.summarize(
        [record(1, quantity: entry.key, unitPoints: 1)],
        [],
        now: now,
      );
      expect(result.level, entry.value);
      expect(result.levelProgress, inInclusiveRange(0.0, 1.0));
      if (entry.key >= 1000) {
        expect(result.nextLevel, isNull);
        expect(result.pointsToNextLevel, 0);
        expect(result.levelProgress, 1);
      }
    }
  });

  test(
    'racha cuenta días civiles únicos, tolera ayer y se corta tras un hueco',
    () {
      final result = policy.summarize(
        [
          record(1),
          record(2),
          record(3, daysAgo: 1),
          record(4, daysAgo: 2),
          record(5, daysAgo: 4),
        ],
        [],
        now: now,
      );
      expect(result.streakDays, 3);
      expect(
        policy
            .summarize(
              [record(1, daysAgo: 1), record(2, daysAgo: 2)],
              [],
              now: now,
            )
            .streakDays,
        2,
      );
      expect(
        policy.summarize([record(1, daysAgo: 2)], [], now: now).streakDays,
        0,
      );
    },
  );

  test('insignias derivadas y cancelación no cuenta como canje activo', () {
    final records = List.generate(
      30,
      (i) => record(i, daysAgo: i, point: 'p${i % 3}'),
    );
    Redemption redemption({DateTime? canceledAt}) => Redemption(
      id: 'c',
      operationId: 'op',
      rewardId: 'reward',
      titleSnapshot: 'Demo',
      costSnapshot: 80,
      createdAt: now,
      canceledAt: canceledAt,
    );
    final active = policy.summarize(records, [redemption()], now: now);
    expect(active.badges, EcoBadge.values.toSet());
    expect(active.earnedPoints, 300);
    expect(active.availablePoints, 220);
    expect(active.level, EcoLevel.sprout);
    final canceled = policy.summarize(records, [
      redemption(canceledAt: now),
    ], now: now);
    expect(canceled.availablePoints, 300);
    expect(canceled.badges, isNot(contains(EcoBadge.firstRedemption)));
    expect(policy.summarize([], [], now: now).badges, isEmpty);
  });
}
