import 'package:drift/drift.dart';

import '../../domain/entities/local_suggestion.dart';
import '../../domain/entities/recycling_draft.dart';
import '../../domain/entities/recycling_point.dart';
import '../../domain/entities/recycling_record.dart';
import '../../domain/entities/reward.dart';

DateTime readUtc(QueryRow row, String column) =>
    DateTime.fromMillisecondsSinceEpoch(row.read<int>(column), isUtc: true);

RecyclingRecord recordFromRow(QueryRow row) => RecyclingRecord(
  id: row.read<String>('id'),
  pointId: row.read<String>('point_id'),
  material: RecyclingMaterial.values.byName(row.read<String>('material')),
  quantity: row.read<int>('quantity'),
  unitPoints: row.read<int>('unit_points'),
  occurredAt: readUtc(row, 'occurred_at'),
  note: row.read<String>('note'),
  createdAt: readUtc(row, 'created_at'),
  updatedAt: readUtc(row, 'updated_at'),
);

RecyclingPoint pointFromRow(QueryRow row) => RecyclingPoint(
  id: row.read<String>('id'),
  name: row.read<String>('name'),
  description: row.read<String>('description'),
  occupancy: row.read<int>('occupancy'),
  latitude: row.readNullable<double>('latitude'),
  longitude: row.readNullable<double>('longitude'),
  isDemo: row.read<int>('is_demo') == 1,
);

Reward rewardFromRow(QueryRow row) => Reward(
  id: row.read<String>('id'),
  title: row.read<String>('title'),
  category: RewardCategory.values.byName(row.read<String>('category')),
  costPoints: row.read<int>('cost_points'),
  description: row.read<String>('description'),
  isActive: row.read<int>('is_active') == 1,
);

Redemption redemptionFromRow(QueryRow row) {
  final canceled = row.readNullable<int>('canceled_at');
  return Redemption(
    id: row.read<String>('id'),
    operationId: row.read<String>('operation_id'),
    rewardId: row.read<String>('reward_id'),
    titleSnapshot: row.read<String>('title_snapshot'),
    costSnapshot: row.read<int>('cost_snapshot'),
    createdAt: readUtc(row, 'created_at'),
    canceledAt: canceled == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(canceled, isUtc: true),
  );
}

RecyclingDraft draftFromRow(QueryRow row) {
  final occurred = row.readNullable<int>('occurred_at');
  return RecyclingDraft(
    key: row.read<String>('key'),
    recordId: row.readNullable<String>('record_id'),
    pointId: row.readNullable<String>('point_id'),
    material: row.readNullable<String>('material'),
    quantityText: row.read<String>('quantity_text'),
    note: row.read<String>('note'),
    step: row.read<int>('step'),
    updatedAt: readUtc(row, 'updated_at'),
    occurredAt: occurred == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(occurred, isUtc: true),
  );
}

LocalSuggestion suggestionFromRow(QueryRow row) => LocalSuggestion(
  id: row.read<String>('id'),
  message: row.read<String>('message'),
  createdAt: readUtc(row, 'created_at'),
);
