import '../entities/recycling_record.dart';

abstract interface class RecordsRepository {
  Stream<List<RecyclingRecord>> watchAll({RecordsFilter? filter});
  Future<RecyclingRecord?> getById(String id);
  Future<RecyclingRecord> create(RecordInput input);
  Future<RecyclingRecord> update(String id, RecordInput input);
  Future<void> delete(String id);
}
