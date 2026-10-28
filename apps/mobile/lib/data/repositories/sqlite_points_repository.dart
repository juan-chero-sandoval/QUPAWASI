import '../../domain/entities/recycling_point.dart';
import '../../domain/repositories/points_repository.dart';
import '../local/app_database.dart' show AppDatabase;
import '../local/local_data_guard.dart';
import '../local/row_mapping.dart';

class SqlitePointsRepository implements PointsRepository {
  SqlitePointsRepository(this._db);
  final AppDatabase _db;

  @override
  Future<List<RecyclingPoint>> listPoints() => guardLocalData(() async {
    final rows = await _db
        .customSelect(
          'SELECT * FROM recycling_points ORDER BY name, id',
          readsFrom: {_db.recyclingPoints},
        )
        .get();
    return List.unmodifiable(rows.map(pointFromRow));
  });

  @override
  Stream<List<RecyclingPoint>> watchPoints() => guardLocalStream(
    _db
        .customSelect(
          'SELECT * FROM recycling_points ORDER BY name, id',
          readsFrom: {_db.recyclingPoints},
        )
        .watch()
        .map((rows) => List.unmodifiable(rows.map(pointFromRow))),
  );
}
