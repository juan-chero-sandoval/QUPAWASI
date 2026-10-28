import '../../domain/entities/recycling_statistics.dart';
import '../../domain/policies/demo_scoring_policy.dart';
import '../../domain/repositories/statistics_repository.dart';
import '../local/app_database.dart' show AppDatabase;
import '../local/local_data_guard.dart';
import '../local/row_mapping.dart';

class SqliteStatisticsRepository implements StatisticsRepository {
  SqliteStatisticsRepository(
    this._db, {
    Clock? clock,
    DemoScoringPolicy? policy,
  }) : _clock = clock ?? DateTime.now,
       _policy = policy ?? const DemoScoringPolicy();

  final AppDatabase _db;
  final Clock _clock;
  final DemoScoringPolicy _policy;

  @override
  Future<RecyclingStatistics> getStatistics() => guardLocalData(
    () => _db.transaction(() async {
      final records = await _db
          .customSelect('SELECT * FROM recycling_records')
          .get();
      final redemptions = await _db
          .customSelect('SELECT * FROM redemptions')
          .get();
      return _policy.summarize(
        records.map(recordFromRow).toList(),
        redemptions.map(redemptionFromRow).toList(),
        now: _clock(),
      );
    }),
  );

  @override
  Stream<RecyclingStatistics> watchStatistics() => guardLocalStream(
    // Invalidaciones Drift por tabla, también cuando cambia una fila sin variar
    // el número de registros. La lectura posterior es una instantánea transaccional.
    _db
        .customSelect(
          'SELECT 1',
          readsFrom: {_db.recyclingRecords, _db.redemptions},
        )
        .watch()
        .asyncMap((_) => getStatistics()),
  );
}
