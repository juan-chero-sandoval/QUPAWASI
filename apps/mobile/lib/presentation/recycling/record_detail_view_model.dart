import 'package:flutter/foundation.dart';

import '../../domain/entities/record_preview.dart';
import '../../domain/repositories/record_preview_repository.dart';

sealed class RecordDetailState {
  const RecordDetailState();
}

class RecordDetailLoading extends RecordDetailState {
  const RecordDetailLoading();
}

class RecordDetailData extends RecordDetailState {
  const RecordDetailData(this.record);

  final RecordPreview record;
}

class RecordDetailNotFound extends RecordDetailState {
  const RecordDetailNotFound();
}

class RecordDetailError extends RecordDetailState {
  const RecordDetailError(this.message);

  final String message;
}

/// Carga un registro por su ID serializable. Nunca recibe la entidad en
/// memoria: así el detalle funciona igual al restaurar la ruta.
class RecordDetailViewModel extends ChangeNotifier {
  RecordDetailViewModel({required this._repository, required this.recordId});

  final RecordPreviewRepository _repository;
  final String recordId;

  RecordDetailState _state = const RecordDetailLoading();
  bool _disposed = false;

  RecordDetailState get state => _state;

  Future<void> load() async {
    _emit(const RecordDetailLoading());
    try {
      final record = await _repository.getById(recordId);
      _emit(
        record == null
            ? const RecordDetailNotFound()
            : RecordDetailData(record),
      );
    } on Exception {
      _emit(
        const RecordDetailError(
          'No se pudo cargar el registro. Inténtalo de nuevo.',
        ),
      );
    }
  }

  void _emit(RecordDetailState next) {
    if (_disposed) return;
    _state = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
