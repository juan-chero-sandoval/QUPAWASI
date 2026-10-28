import '../entities/recycling_record.dart';
import '../policies/demo_scoring_policy.dart';
import '../policies/local_validation.dart';
import '../repositories/records_repository.dart';

/// Fachada de casos de uso para los ViewModels de lista, detalle y formulario.
class RecyclingUseCases {
  RecyclingUseCases(this._records, {Clock? clock})
    : _clock = clock ?? DateTime.now;
  final RecordsRepository _records;
  final Clock _clock;

  Stream<List<RecyclingRecord>> watch({RecordsFilter? filter}) =>
      _records.watchAll(filter: filter);

  Future<RecyclingRecord?> get(String id) async {
    LocalValidation.id(id);
    return _records.getById(id);
  }

  Future<RecyclingRecord> create(RecordInput input) async {
    LocalValidation.record(input, _clock());
    return _records.create(input);
  }

  Future<RecyclingRecord> update(String id, RecordInput input) async {
    LocalValidation.id(id);
    LocalValidation.record(input, _clock());
    return _records.update(id, input);
  }

  Future<void> delete(String id) async {
    LocalValidation.id(id);
    await _records.delete(id);
  }
}
