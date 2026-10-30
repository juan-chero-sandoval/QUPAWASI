import '../../domain/entities/recycling_point.dart';
import '../../domain/repositories/points_repository.dart';
import '../../domain/usecases/point_catalog_use_cases.dart';
import '../../domain/entities/deposit_qr.dart';
import '../../domain/policies/local_validation.dart';

import 'package:drift/drift.dart';

import '../local/app_database.dart' show AppDatabase;
import '../local/local_data_guard.dart';
import '../local/row_mapping.dart';

class SqlitePointsRepository
    implements PointsRepository, PointCatalogRepository {
  SqlitePointsRepository(this._db);
  final AppDatabase _db;

  @override
  Future<void> upsertAll(List<RecyclingPoint> points) => guardLocalData(
    () => _db.transaction(() async {
      for (final p in points) {
        LocalValidation.id(p.id);
        LocalValidation.require(
          p.name.trim().isNotEmpty &&
              validCoordinates(p.latitude, p.longitude) &&
              p.occupancy >= 0 &&
              p.occupancy <= 100,
          'Tacho inválido.',
        );
        await _db.customInsert(
          'INSERT INTO recycling_points '
          '(id,name,description,occupancy,latitude,longitude,is_demo) VALUES (?,?,?,?,?,?,?) '
          'ON CONFLICT(id) DO UPDATE SET name=excluded.name,description=excluded.description,'
          'occupancy=excluded.occupancy,latitude=excluded.latitude,longitude=excluded.longitude,is_demo=excluded.is_demo',
          variables: [
            Variable<String>(p.id),
            Variable<String>(p.name),
            Variable<String>(p.description),
            Variable<int>(p.occupancy),
            Variable<double>(p.latitude!),
            Variable<double>(p.longitude!),
            Variable<int>(p.isDemo ? 1 : 0),
          ],
          updates: {_db.recyclingPoints},
        );
      }
    }),
  );

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
