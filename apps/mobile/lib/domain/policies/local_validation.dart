import '../entities/recycling_draft.dart';
import '../entities/recycling_record.dart';
import '../errors/local_data_exception.dart';

class LocalValidation {
  static void require(bool valid, String message) {
    if (!valid) {
      throw LocalDataException(LocalDataError.validation, message);
    }
  }

  static void id(String value) => require(
    value.trim().isNotEmpty && value.length <= 100,
    'El identificador no es válido.',
  );

  static void record(RecordInput input, DateTime now) {
    id(input.pointId);
    require(
      input.quantity >= 1 && input.quantity <= 100,
      'La cantidad debe ser un entero entre 1 y 100.',
    );
    require(
      input.note.trim().length <= 200,
      'La nota admite hasta 200 caracteres.',
    );
    require(
      !input.occurredAt.isAfter(now),
      'La fecha del reciclaje no puede estar en el futuro.',
    );
  }

  static void draft(RecyclingDraft draft) {
    id(draft.key);
    require(draft.step >= 0 && draft.step <= 2, 'El paso no es válido.');
    require(
      draft.quantityText.length <= 100,
      'Entrada de cantidad demasiado larga.',
    );
    require(draft.note.length <= 200, 'La nota admite hasta 200 caracteres.');
  }

  static String suggestion(String message) {
    final normalized = message.trim();
    require(
      normalized.length >= 5 && normalized.length <= 500,
      'La sugerencia debe tener entre 5 y 500 caracteres.',
    );
    return normalized;
  }
}
