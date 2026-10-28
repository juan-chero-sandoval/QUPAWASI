import '../entities/record_preview.dart';

/// Fuente que resuelve un registro a partir de su ID serializable.
///
/// Punto de extensión: F02/F03 lo implementan sobre `RecordsRepository`.
abstract interface class RecordPreviewRepository {
  Future<List<RecordPreview>> list();

  /// Devuelve `null` si el ID no existe.
  Future<RecordPreview?> getById(String id);
}
