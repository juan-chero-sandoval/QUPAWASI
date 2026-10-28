import '../../domain/entities/record_preview.dart';
import '../../domain/repositories/record_preview_repository.dart';

/// Adaptador de preview explícito: datos fijos de demostración, no guardados.
///
/// Existe solo para comprobar el paso de IDs mientras no hay SQLite (F02).
class DemoRecordPreviewRepository implements RecordPreviewRepository {
  const DemoRecordPreviewRepository();

  static const List<RecordPreview> _items = [
    RecordPreview(
      id: 'demo-0001',
      pointName: 'Arquitectura',
      materialLabel: 'Botellas PET',
      quantity: 2,
      isDemo: true,
    ),
    RecordPreview(
      id: 'demo-0002',
      pointName: 'Biblioteca',
      materialLabel: 'Latas de aluminio',
      quantity: 3,
      isDemo: true,
    ),
  ];

  @override
  Future<List<RecordPreview>> list() async => _items;

  @override
  Future<RecordPreview?> getById(String id) async {
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }
}
