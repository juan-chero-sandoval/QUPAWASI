import '../entities/recycling_point.dart';
import '../entities/recycling_statistics.dart';
import '../repositories/points_repository.dart';
import '../repositories/statistics_repository.dart';

class OverviewUseCases {
  const OverviewUseCases(this._points, this._statistics);
  final PointsRepository _points;
  final StatisticsRepository _statistics;

  Future<List<RecyclingPoint>> listPoints() => _points.listPoints();
  Stream<List<RecyclingPoint>> watchPoints() => _points.watchPoints();
  Future<RecyclingStatistics> getStatistics() => _statistics.getStatistics();
  Stream<RecyclingStatistics> watchStatistics() =>
      _statistics.watchStatistics();
}
