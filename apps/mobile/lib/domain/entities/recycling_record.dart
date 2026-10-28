enum RecyclingMaterial {
  pet('PET'),
  aluminum('Lata de aluminio');

  const RecyclingMaterial(this.label);
  final String label;
}

class RecordInput {
  const RecordInput({
    required this.pointId,
    required this.material,
    required this.quantity,
    required this.occurredAt,
    this.note = '',
  });

  final String pointId;
  final RecyclingMaterial material;
  final int quantity;
  final DateTime occurredAt;
  final String note;
}

class RecyclingRecord {
  const RecyclingRecord({
    required this.id,
    required this.pointId,
    required this.material,
    required this.quantity,
    required this.unitPoints,
    required this.occurredAt,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String pointId;
  final RecyclingMaterial material;
  final int quantity;

  /// Política demo aplicada al guardar: no cambia por una futura actualización.
  final int unitPoints;
  final DateTime occurredAt;
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;

  int get earnedPoints => quantity * unitPoints;
}

class RecordsFilter {
  const RecordsFilter({this.pointId, this.material});

  final String? pointId;
  final RecyclingMaterial? material;
}
