/// Vista mínima de un registro para probar la navegación por ID en F01.
///
/// No es la entidad `RecyclingRecord` de F02: F03 sustituye la fuente de
/// preview por el repositorio SQLite y conserva la ruta `/recycling/:recordId`.
class RecordPreview {
  const RecordPreview({
    required this.id,
    required this.pointName,
    required this.materialLabel,
    required this.quantity,
    required this.isDemo,
  });

  final String id;
  final String pointName;
  final String materialLabel;
  final int quantity;

  /// `true` cuando el dato es de demostración y no fue guardado por el usuario.
  final bool isDemo;
}
