/// Entrada parcial: quantityText puede ser vacío o inválido sin crear un registro.
class RecyclingDraft {
  const RecyclingDraft({
    required this.key,
    required this.quantityText,
    required this.note,
    required this.step,
    required this.updatedAt,
    this.recordId,
    this.pointId,
    this.material,
    this.occurredAt,
  });

  final String key;
  final String? recordId;
  final String? pointId;
  final String? material;
  final String quantityText;
  final String note;
  final int step;
  final DateTime updatedAt;
  final DateTime? occurredAt;
}
