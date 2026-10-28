import '../entities/recycling_point.dart';

abstract interface class PointsRepository {
  Future<List<RecyclingPoint>> listPoints();
  Stream<List<RecyclingPoint>> watchPoints();
}
