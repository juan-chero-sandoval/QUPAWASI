import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/entities/recycling_draft.dart';
import '../../domain/entities/recycling_record.dart';
import '../../domain/errors/local_data_exception.dart';
import '../../domain/usecases/draft_use_cases.dart';
import '../../domain/usecases/overview_use_cases.dart';
import '../../domain/usecases/recycling_use_cases.dart';
import 'record_form_view_model.dart';

enum RecordListStatus { loading, empty, data, error }

/// Lista reactiva: se suscribe al stream de SQLite, así crear/editar/eliminar
/// se reflejan sin recargar a mano ni añadir copias en memoria.
class RecordListViewModel extends ChangeNotifier {
  RecordListViewModel({
    required this._recycling,
    required this._overview,
    required this._drafts,
    this.material,
  });

  final RecyclingUseCases _recycling;
  final OverviewUseCases _overview;
  final DraftUseCases _drafts;

  /// Filtro opcional recibido por la ruta `/recycling?filter=`.
  final RecyclingMaterial? material;

  StreamSubscription<List<RecyclingRecord>>? _subscription;
  RecordListStatus _status = RecordListStatus.loading;
  List<RecyclingRecord> _records = const [];
  Map<String, String> _pointNames = const {};
  RecyclingDraft? _pendingDraft;
  String? _errorMessage;
  bool _disposed = false;

  RecordListStatus get status => _status;
  List<RecyclingRecord> get records => _records;
  String? get errorMessage => _errorMessage;

  /// Borrador sin terminar más reciente (nuevo o edición), si existe.
  RecyclingDraft? get pendingDraft => _pendingDraft;

  String pointName(String pointId) => _pointNames[pointId] ?? 'Punto local';

  /// `pet` o `aluminum`; cualquier otro valor se ignora (lista completa).
  static RecyclingMaterial? parseFilter(String? raw) {
    for (final value in RecyclingMaterial.values) {
      if (value.name == raw) return value;
    }
    return null;
  }

  Future<void> start() async {
    await _subscription?.cancel();
    _status = RecordListStatus.loading;
    _errorMessage = null;
    _notify();
    try {
      final points = await _overview.listPoints();
      _pointNames = {for (final p in points) p.id: p.name};
    } on LocalDataException catch (error) {
      _fail(error.message);
      return;
    }
    if (_disposed) return;
    _subscription = _recycling
        .watch(filter: RecordsFilter(material: material))
        .listen(
          (records) {
            _records = records;
            _status = records.isEmpty
                ? RecordListStatus.empty
                : RecordListStatus.data;
            _notify();
          },
          onError: (Object error) => _fail(
            error is LocalDataException
                ? error.message
                : 'No se pudieron cargar tus registros.',
          ),
        );
    await refreshDrafts();
  }

  /// Vuelve a consultar borradores; la vista lo llama al volver a esta ruta.
  Future<void> refreshDrafts() async {
    try {
      final candidates = [
        await _drafts.load(RecordFormViewModel.newDraftKey),
        await _drafts.load(RecordFormViewModel.editDraftKey),
      ].whereType<RecyclingDraft>().toList();
      candidates.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      _pendingDraft = candidates.isEmpty ? null : candidates.first;
    } on LocalDataException {
      _pendingDraft = null;
    }
    _notify();
  }

  Future<void> discardPendingDraft() async {
    final draft = _pendingDraft;
    if (draft == null) return;
    try {
      await _drafts.clear(draft.key);
    } on LocalDataException catch (error) {
      _errorMessage = error.message;
    }
    await refreshDrafts();
  }

  void _fail(String message) {
    _status = RecordListStatus.error;
    _errorMessage = message;
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
