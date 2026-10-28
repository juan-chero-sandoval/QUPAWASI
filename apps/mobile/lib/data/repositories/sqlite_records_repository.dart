import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/recycling_record.dart';
import '../../domain/errors/local_data_exception.dart';
import '../../domain/policies/demo_scoring_policy.dart';
import '../../domain/policies/local_validation.dart';
import '../../domain/repositories/records_repository.dart';
import '../local/app_database.dart' show AppDatabase;
import '../local/local_data_guard.dart';
import '../local/row_mapping.dart';

class SqliteRecordsRepository implements RecordsRepository {
  SqliteRecordsRepository(this._db, {Clock? clock, DemoScoringPolicy? policy})
    : _clock = clock ?? DateTime.now,
      _policy = policy ?? const DemoScoringPolicy();

  final AppDatabase _db;
  final Clock _clock;
  final DemoScoringPolicy _policy;

  @override
  Stream<List<RecyclingRecord>> watchAll({RecordsFilter? filter}) {
    final clauses = <String>[];
    final variables = <Variable<Object>>[];
    if (filter?.pointId case final point?) {
      clauses.add('point_id = ?');
      variables.add(Variable<String>(point));
    }
    if (filter?.material case final material?) {
      clauses.add('material = ?');
      variables.add(Variable<String>(material.name));
    }
    final where = clauses.isEmpty ? '' : 'WHERE ${clauses.join(' AND ')}';
    return guardLocalStream(
      _db
          .customSelect(
            'SELECT * FROM recycling_records $where ORDER BY occurred_at DESC, id',
            variables: variables,
            readsFrom: {_db.recyclingRecords},
          )
          .watch()
          .map((rows) => List.unmodifiable(rows.map(recordFromRow))),
    );
  }

  @override
  Future<RecyclingRecord?> getById(String id) => guardLocalData(() async {
    LocalValidation.id(id);
    return _find(id);
  });

  Future<RecyclingRecord?> _find(String id) async {
    final row = await _db
        .customSelect(
          'SELECT * FROM recycling_records WHERE id = ?',
          variables: [Variable<String>(id)],
          readsFrom: {_db.recyclingRecords},
        )
        .getSingleOrNull();
    return row == null ? null : recordFromRow(row);
  }

  @override
  Future<RecyclingRecord> create(RecordInput input) => guardLocalData(() async {
    final now = _clock().toUtc();
    LocalValidation.record(input, now);
    return _db.transaction(() async {
      final id = const Uuid().v4();
      await _db.customInsert(
        'INSERT INTO recycling_records '
        '(id,point_id,material,quantity,unit_points,occurred_at,note,created_at,updated_at) '
        'VALUES (?,?,?,?,?,?,?,?,?)',
        variables: [
          Variable<String>(id),
          ..._inputValues(input),
          Variable<int>(now.millisecondsSinceEpoch),
          Variable<int>(now.millisecondsSinceEpoch),
        ],
        updates: {_db.recyclingRecords},
      );
      return (await _find(id))!;
    });
  });

  @override
  Future<RecyclingRecord> update(String id, RecordInput input) =>
      guardLocalData(() async {
        LocalValidation.id(id);
        final now = _clock().toUtc();
        LocalValidation.record(input, now);
        return _db.transaction(() async {
          final existing = await _find(id);
          if (existing == null) {
            throw const LocalDataException(
              LocalDataError.notFound,
              'El registro ya no existe.',
            );
          }
          await _db.customUpdate(
            'UPDATE recycling_records SET point_id=?,material=?,quantity=?,unit_points=?, '
            'occurred_at=?,note=?,updated_at=? WHERE id=?',
            variables: [
              ..._inputValues(input),
              Variable<int>(now.millisecondsSinceEpoch),
              Variable<String>(id),
            ],
            updates: {_db.recyclingRecords},
          );
          return (await _find(id))!;
        });
      });

  List<Variable<Object>> _inputValues(RecordInput input) => [
    Variable<String>(input.pointId),
    Variable<String>(input.material.name),
    Variable<int>(input.quantity),
    Variable<int>(_policy.pointsPerUnit(input.material)),
    Variable<int>(input.occurredAt.toUtc().millisecondsSinceEpoch),
    Variable<String>(input.note.trim()),
  ];

  @override
  Future<void> delete(String id) => guardLocalData(() async {
    LocalValidation.id(id);
    final affected = await _db.customUpdate(
      'DELETE FROM recycling_records WHERE id=?',
      variables: [Variable<String>(id)],
      updates: {_db.recyclingRecords},
      updateKind: UpdateKind.delete,
    );
    if (affected == 0) {
      throw const LocalDataException(
        LocalDataError.notFound,
        'El registro ya no existe.',
      );
    }
  });
}
