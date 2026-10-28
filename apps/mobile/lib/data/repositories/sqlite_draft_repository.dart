import 'package:drift/drift.dart';

import '../../domain/entities/recycling_draft.dart';
import '../../domain/policies/local_validation.dart';
import '../../domain/repositories/draft_repository.dart';
import '../local/app_database.dart' show AppDatabase;
import '../local/local_data_guard.dart';
import '../local/row_mapping.dart';

class SqliteDraftRepository implements DraftRepository {
  SqliteDraftRepository(this._db);
  final AppDatabase _db;

  @override
  Future<RecyclingDraft?> load(String key) => guardLocalData(() async {
    LocalValidation.id(key);
    final row = await _db
        .customSelect(
          'SELECT * FROM drafts WHERE key=?',
          variables: [Variable<String>(key)],
          readsFrom: {_db.drafts},
        )
        .getSingleOrNull();
    return row == null ? null : draftFromRow(row);
  });

  @override
  Future<void> save(RecyclingDraft draft) => guardLocalData(() async {
    LocalValidation.draft(draft);
    await _db.customInsert(
      'INSERT INTO drafts (key,record_id,point_id,material,quantity_text,note,step,updated_at,occurred_at) '
      'VALUES (?,?,?,?,?,?,?,?,?) ON CONFLICT(key) DO UPDATE SET '
      'record_id=excluded.record_id,point_id=excluded.point_id,material=excluded.material, '
      'quantity_text=excluded.quantity_text,note=excluded.note,step=excluded.step, '
      'updated_at=excluded.updated_at,occurred_at=excluded.occurred_at '
      'WHERE excluded.updated_at >= drafts.updated_at',
      variables: [
        Variable<String>(draft.key),
        Variable<String>(draft.recordId),
        Variable<String>(draft.pointId),
        Variable<String>(draft.material),
        Variable<String>(draft.quantityText),
        Variable<String>(draft.note),
        Variable<int>(draft.step),
        Variable<int>(draft.updatedAt.toUtc().millisecondsSinceEpoch),
        Variable<int>(draft.occurredAt?.toUtc().millisecondsSinceEpoch),
      ],
      updates: {_db.drafts},
    );
  });

  @override
  Future<void> clear(String key) => guardLocalData(() async {
    LocalValidation.id(key);
    await _db.customUpdate(
      'DELETE FROM drafts WHERE key=?',
      variables: [Variable<String>(key)],
      updates: {_db.drafts},
      updateKind: UpdateKind.delete,
    );
  });
}
