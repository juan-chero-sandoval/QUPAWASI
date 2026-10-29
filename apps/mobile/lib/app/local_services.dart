import '../data/local/app_database.dart' show AppDatabase;
import '../data/repositories/sqlite_draft_repository.dart';
import '../data/repositories/sqlite_points_repository.dart';
import '../data/repositories/sqlite_records_repository.dart';
import '../data/repositories/sqlite_rewards_repository.dart';
import '../data/repositories/sqlite_statistics_repository.dart';
import '../data/repositories/sqlite_suggestions_repository.dart';
import '../domain/policies/demo_scoring_policy.dart';
import '../domain/usecases/draft_use_cases.dart';
import '../domain/usecases/overview_use_cases.dart';
import '../domain/usecases/recycling_use_cases.dart';
import '../domain/usecases/rewards_use_cases.dart';
import '../domain/usecases/suggestions_use_cases.dart';

/// Composición F02. Las vistas consumen casos de uso; no reciben conexión SQL.
class LocalServices {
  LocalServices._(
    this._close, {
    required this.recycling,
    required this.overview,
    required this.rewards,
    required this.drafts,
    required this.suggestions,
  });

  factory LocalServices.withDatabase(AppDatabase db, {Clock? clock}) =>
      LocalServices._(
        db.close,
        recycling: RecyclingUseCases(
          SqliteRecordsRepository(db, clock: clock),
          clock: clock,
        ),
        overview: OverviewUseCases(
          SqlitePointsRepository(db),
          SqliteStatisticsRepository(db, clock: clock),
        ),
        rewards: RewardsUseCases(SqliteRewardsRepository(db, clock: clock)),
        drafts: DraftUseCases(SqliteDraftRepository(db)),
        suggestions: SuggestionsUseCases(
          SqliteSuggestionsRepository(db, clock: clock),
        ),
      );

  /// Casos de uso ya construidos, sin conexión propia. Pensado para pruebas de
  /// UI con repositorios controlados; producción usa [open].
  factory LocalServices.fromUseCases({
    required RecyclingUseCases recycling,
    required OverviewUseCases overview,
    required RewardsUseCases rewards,
    required DraftUseCases drafts,
    required SuggestionsUseCases suggestions,
  }) => LocalServices._(
    () async {},
    recycling: recycling,
    overview: overview,
    rewards: rewards,
    drafts: drafts,
    suggestions: suggestions,
  );

  static Future<LocalServices> open() async =>
      LocalServices.withDatabase(await AppDatabase.open());

  final RecyclingUseCases recycling;
  final OverviewUseCases overview;
  final RewardsUseCases rewards;
  final DraftUseCases drafts;
  final SuggestionsUseCases suggestions;
  final Future<void> Function() _close;
  Future<void>? _closing;

  /// El propietario de la composición cierra una sola vez al liberar el entorno.
  /// No cerrar al pausar Android: el proceso puede volver a usar los repositorios.
  Future<void> close() => _closing ??= _close();
}
