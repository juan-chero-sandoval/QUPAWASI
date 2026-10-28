import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/local_suggestion.dart';
import '../../domain/errors/local_data_exception.dart';
import '../../domain/policies/demo_scoring_policy.dart';
import '../../domain/policies/local_validation.dart';
import '../../domain/repositories/suggestions_repository.dart';
import '../local/app_database.dart' show AppDatabase;
import '../local/local_data_guard.dart';
import '../local/row_mapping.dart';

class SqliteSuggestionsRepository implements SuggestionsRepository {
  SqliteSuggestionsRepository(this._db, {Clock? clock})
    : _clock = clock ?? DateTime.now;
  final AppDatabase _db;
  final Clock _clock;

  @override
  Future<List<LocalSuggestion>> list() => guardLocalData(() async {
    final rows = await _db
        .customSelect(
          'SELECT * FROM suggestions ORDER BY created_at DESC, id',
          readsFrom: {_db.suggestions},
        )
        .get();
    return List.unmodifiable(rows.map(suggestionFromRow));
  });

  @override
  Future<LocalSuggestion> create(String message) => guardLocalData(() async {
    final normalized = LocalValidation.suggestion(message);
    final suggestion = LocalSuggestion(
      id: const Uuid().v4(),
      message: normalized,
      createdAt: _clock().toUtc(),
    );
    await _db.customInsert(
      'INSERT INTO suggestions(id,message,created_at) VALUES (?,?,?)',
      variables: [
        Variable<String>(suggestion.id),
        Variable<String>(suggestion.message),
        Variable<int>(suggestion.createdAt.millisecondsSinceEpoch),
      ],
      updates: {_db.suggestions},
    );
    return suggestion;
  });

  @override
  Future<void> delete(String id) => guardLocalData(() async {
    LocalValidation.id(id);
    final count = await _db.customUpdate(
      'DELETE FROM suggestions WHERE id=?',
      variables: [Variable<String>(id)],
      updates: {_db.suggestions},
      updateKind: UpdateKind.delete,
    );
    if (count == 0) {
      throw const LocalDataException(
        LocalDataError.notFound,
        'La sugerencia ya no existe.',
      );
    }
  });
}
