import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/entities/recycling_record.dart';
import '../../domain/errors/local_data_exception.dart';
import '../../domain/usecases/overview_use_cases.dart';
import '../../domain/usecases/recycling_use_cases.dart';

sealed class RecordDetailState {
  const RecordDetailState();
}

class RecordDetailLoading extends RecordDetailState {
  const RecordDetailLoading();
}

class RecordDetailData extends RecordDetailState {
  const RecordDetailData(this.record);

  final RecyclingRecord record;
}

class RecordDetailNotFound extends RecordDetailState {
  const RecordDetailNotFound();
}

class RecordDetailError extends RecordDetailState {
  const RecordDetailError(this.message);

  final String message;
}

/// Detalle por ID serializable: recarga desde SQLite y sigue el stream, así
/// una edición se ve al volver y un borrado externo muestra "no encontrado".
class RecordDetailViewModel extends ChangeNotifier {
  RecordDetailViewModel({
    required this._recycling,
    required this._overview,
    required this.recordId,
  });

  final RecyclingUseCases _recycling;
  final OverviewUseCases _overview;
  final String recordId;

  StreamSubscription<List<RecyclingRecord>>? _subscription;
  RecordDetailState _state = const RecordDetailLoading();
  Map<String, String> _pointNames = const {};
  bool _deleting = false;
  bool _deleted = false;
  String? _deleteError;
  bool _disposed = false;

  RecordDetailState get state => _state;
  bool get isDeleting => _deleting;
  String? get deleteError => _deleteError;

  String pointName(String pointId) => _pointNames[pointId] ?? 'Punto local';

  Future<void> load() async {
    await _subscription?.cancel();
    _emit(const RecordDetailLoading());
    try {
      final points = await _overview.listPoints();
      _pointNames = {for (final p in points) p.id: p.name};
      // Valida el ID y consulta una vez antes de seguir los cambios.
      final first = await _recycling.get(recordId);
      _emit(
        first == null ? const RecordDetailNotFound() : RecordDetailData(first),
      );
    } on LocalDataException catch (error) {
      _emit(
        error.code == LocalDataError.validation
            ? const RecordDetailNotFound()
            : RecordDetailError(error.message),
      );
      return;
    }
    if (_disposed) return;
    _subscription = _recycling.watch().listen(
      (records) {
        if (_deleted) return;
        RecyclingRecord? match;
        for (final record in records) {
          if (record.id == recordId) match = record;
        }
        _emit(
          match == null
              ? const RecordDetailNotFound()
              : RecordDetailData(match),
        );
      },
      onError: (Object error) => _emit(
        RecordDetailError(
          error is LocalDataException
              ? error.message
              : 'No se pudo cargar el registro.',
        ),
      ),
    );
  }

  /// Elimina tras la confirmación de la vista. `true` solo si se borró.
  Future<bool> delete() async {
    if (_deleting) return false;
    _deleting = true;
    _deleteError = null;
    _notify();
    try {
      await _recycling.delete(recordId);
      _deleted = true;
      return true;
    } on LocalDataException catch (error) {
      // committedPoints ya trae la instrucción de cancelar el canje.
      _deleteError = error.code == LocalDataError.committedPoints
          ? '${error.message} Puedes hacerlo en Premios.'
          : error.message;
      return false;
    } finally {
      _deleting = false;
      _notify();
    }
  }

  void _emit(RecordDetailState next) {
    _state = next;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_subscription?.cancel());
    super.dispose();
  }
}
