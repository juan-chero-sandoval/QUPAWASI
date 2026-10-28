import '../entities/recycling_statistics.dart';

abstract interface class StatisticsRepository {
  Future<RecyclingStatistics> getStatistics();
  Stream<RecyclingStatistics> watchStatistics();
}
