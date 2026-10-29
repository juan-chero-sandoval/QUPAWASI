import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/entities/recycling_draft.dart';
import '../../domain/entities/recycling_point.dart';
import '../../domain/entities/recycling_record.dart';
import '../../domain/errors/local_data_exception.dart';
import '../../domain/policies/demo_scoring_policy.dart';
import '../../domain/usecases/draft_use_cases.dart';
import '../../domain/usecases/overview_use_cases.dart';
import '../../domain/usecases/recycling_use_cases.dart';

enum RecordFormStatus {
  loading,

  /// Hay un borrador guardado: el usuario elige continuar o descartar.
  draftOffer,

  /// Se editaba un registro que ya no existe y queda su borrador.
  recordMissing,

  /// Edición de un ID inexistente sin borrador que recuperar.
  notFound,
  loadError,
  editing,
  saving,
  saved,
}

/// Formulario Punto → Material → Confirmar para crear o editar un registro.
///
/// El borrador se guarda en SQLite con debounce, en una cola que serializa las
/// escrituras (un guardado viejo nunca pisa uno nuevo), y se fuerza al cambiar
/// de paso, al volver atrás y cuando la app pasa a segundo plano.
class RecordFormViewModel extends ChangeNotifier {
  RecordFormViewModel({
    required this._recycling,
    required this._overview,
    required this._drafts,
    this._recordId,
    this.initialPointId,
    Clock? clock,
    this.debounce = const Duration(milliseconds: 400),
    this._policy = const DemoScoringPolicy(),
  }) : _clock = clock ?? DateTime.now;

  /// Una fila de borrador por formulario (docs/CONTRATOS.md).
  static const String newDraftKey = 'recycling-new';
  static const String editDraftKey = 'recycling-edit';
  static const int lastStep = 2;

  final RecyclingUseCases _recycling;
  final OverviewUseCases _overview;
  final DraftUseCases _drafts;
  final Clock _clock;
  final DemoScoringPolicy _policy;
  final Duration debounce;

  /// `pointId` recibido por la ruta `/recycling/new?pointId=`.
  final String? initialPointId;

  String? _recordId;
  RecyclingRecord? _original;
  RecyclingDraft? _offeredDraft;

  RecordFormStatus _status = RecordFormStatus.loading;
  List<RecyclingPoint> _points = const [];
  int _step = 0;
  String? _pointId;
  RecyclingMaterial? _material;
  String _quantityText = '';
  String _note = '';

  String? _pointError;
  String? _materialError;
  String? _quantityError;
  String? _noteError;
  String? _formError;
  String? _draftError;

  Timer? _debounceTimer;
  Future<void> _draftQueue = Future.value();
  bool _dirty = false;
  bool _autosave = false;
  DateTime? _lastStamp;
  bool _disposed = false;

  RecordFormStatus get status => _status;
  bool get isEditing => _recordId != null;
  String? get recordId => _recordId;
  String get draftKey => isEditing ? editDraftKey : newDraftKey;
  List<RecyclingPoint> get points => _points;
  int get step => _step;
  String? get pointId => _pointId;
  RecyclingMaterial? get material => _material;
  String get quantityText => _quantityText;
  String get note => _note;
  String? get pointError => _pointError;
  String? get materialError => _materialError;
  String? get quantityError => _quantityError;
  String? get noteError => _noteError;
  String? get formError => _formError;
  String? get draftError => _draftError;
  RecyclingDraft? get offeredDraft => _offeredDraft;
  bool get isSaving => _status == RecordFormStatus.saving;

  RecyclingPoint? get selectedPoint {
    for (final point in _points) {
      if (point.id == _pointId) return point;
    }
    return null;
  }

  /// Cantidad válida o `null`; no modifica errores.
  int? get parsedQuantity => _parseQuantity(_quantityText).$1;

  /// EcoPuntos simulados que sumaría el registro, según la política única.
  int? get estimatedPoints {
    final quantity = parsedQuantity;
    final material = _material;
    if (quantity == null || material == null) return null;
    return quantity * _policy.pointsPerUnit(material);
  }

  /// Fecha que se guardará: la original al editar, ahora al crear.
  DateTime get occurredAt => _original?.occurredAt ?? _clock();

  Future<void> load() async {
    _setStatus(RecordFormStatus.loading);
    try {
      _points = await _overview.listPoints();
      final draft = await _drafts.load(draftKey);
      if (isEditing) {
        final record = await _recycling.get(_recordId!);
        final ownDraft = draft?.recordId == _recordId ? draft : null;
        if (record == null) {
          _offeredDraft = ownDraft;
          _setStatus(
            ownDraft == null
                ? RecordFormStatus.notFound
                : RecordFormStatus.recordMissing,
          );
          return;
        }
        _original = record;
        _applyRecord(record);
        _offerOrEdit(ownDraft);
      } else {
        _applyInitialPoint();
        _offerOrEdit(draft);
      }
    } on LocalDataException catch (error) {
      _formError = error.message;
      _setStatus(RecordFormStatus.loadError);
    }
  }

  void _offerOrEdit(RecyclingDraft? draft) {
    if (draft == null) {
      _startEditing();
    } else {
      _offeredDraft = draft;
      _setStatus(RecordFormStatus.draftOffer);
    }
  }

  void _applyRecord(RecyclingRecord record) {
    _pointId = record.pointId;
    _material = record.material;
    _quantityText = '${record.quantity}';
    _note = record.note;
  }

  void _applyInitialPoint() {
    final requested = initialPointId;
    if (requested == null) return;
    if (_points.any((p) => p.id == requested)) {
      _pointId = requested;
    } else {
      // Nunca asignar en silencio otro punto distinto del pedido.
      _pointError = 'El punto indicado no existe. Elige uno de la lista.';
    }
  }

  void _applyDraft(RecyclingDraft draft) {
    final draftPoint = draft.pointId;
    if (draftPoint != null && _points.any((p) => p.id == draftPoint)) {
      _pointId = draftPoint;
    } else if (draftPoint != null) {
      _pointId = null;
      _pointError = 'El punto del borrador ya no existe. Elige otro.';
    }
    _material = null;
    for (final value in RecyclingMaterial.values) {
      if (value.name == draft.material) _material = value;
    }
    _quantityText = draft.quantityText;
    _note = draft.note;
    _step = draft.step.clamp(0, lastStep);
  }

  void _startEditing() {
    _offeredDraft = null;
    _autosave = true;
    _setStatus(RecordFormStatus.editing);
  }

  /// Continúa con el borrador ofrecido.
  void continueDraft() {
    final draft = _offeredDraft;
    if (draft == null) return;
    _applyDraft(draft);
    _startEditing();
  }

  /// Borra el borrador ofrecido y empieza con los datos guardados o vacíos.
  Future<void> discardDraft() async {
    if (!await _clearDraft(draftKey)) return;
    _startEditing();
  }

  /// El registro editado ya no existe: guardar sus datos como uno nuevo.
  /// Solo ocurre tras elección explícita; nunca se escribe sobre otro ID.
  Future<void> convertMissingToNew() async {
    final draft = _offeredDraft;
    if (draft == null) return;
    if (!await _clearDraft(editDraftKey)) return;
    _recordId = null;
    _original = null;
    _applyDraft(draft);
    _step = 0;
    _startEditing();
    _dirty = true;
    await flushDraft();
  }

  /// Descarta el borrador de un registro inexistente.
  Future<bool> discardMissing() => _clearDraft(editDraftKey);

  void selectPoint(String id) {
    if (!_editable) return;
    _pointId = id;
    _pointError = null;
    _changed();
  }

  void selectMaterial(RecyclingMaterial value) {
    if (!_editable) return;
    _material = value;
    _materialError = null;
    _changed();
  }

  void setQuantityText(String value) {
    if (!_editable) return;
    _quantityText = value;
    _quantityError = null;
    _changed();
  }

  void setNote(String value) {
    if (!_editable) return;
    _note = value;
    _noteError = null;
    _changed();
  }

  /// Valida el paso actual y avanza; guarda el borrador sin esperar debounce.
  Future<void> nextStep() async {
    if (!_editable || _step >= lastStep) return;
    if (!_validateStep(_step)) {
      _notify();
      return;
    }
    _step++;
    _dirty = true;
    _notify();
    await flushDraft();
  }

  Future<void> previousStep() async {
    if (!_editable || _step == 0) return;
    _step--;
    _dirty = true;
    _notify();
    await flushDraft();
  }

  /// Guarda el registro. Devuelve su ID solo si la escritura se confirmó.
  /// Mientras guarda ignora nuevos toques: un doble tap crea un solo registro.
  Future<String?> save() async {
    if (_status != RecordFormStatus.editing) return null;
    _formError = null;
    final firstInvalid = [0, 1].where((s) => !_validateStep(s)).firstOrNull;
    if (firstInvalid != null) {
      _step = firstInvalid;
      _notify();
      return null;
    }
    _setStatus(RecordFormStatus.saving);
    // El borrador queda al día por si la escritura falla.
    await flushDraft();
    final input = RecordInput(
      pointId: _pointId!,
      material: _material!,
      quantity: parsedQuantity!,
      occurredAt: occurredAt,
      note: _note.trim(),
    );
    try {
      final saved = isEditing
          ? await _recycling.update(_recordId!, input)
          : await _recycling.create(input);
      // Desde aquí ningún debounce pendiente puede recrear el borrador.
      _autosave = false;
      _debounceTimer?.cancel();
      _dirty = false;
      await _clearDraft(draftKey);
      _recordId = saved.id;
      _setStatus(RecordFormStatus.saved);
      return saved.id;
    } on LocalDataException catch (error) {
      if (error.code == LocalDataError.notFound && isEditing) {
        _offeredDraft = _snapshot(_nextStamp());
        _autosave = false;
        _setStatus(RecordFormStatus.recordMissing);
        return null;
      }
      _formError = error.message;
      _setStatus(RecordFormStatus.editing);
      return null;
    }
  }

  /// Al reanudar la app, una edición comprueba que su registro siga existiendo.
  Future<void> recheckOnResume() async {
    if (!isEditing || _status != RecordFormStatus.editing) return;
    try {
      final record = await _recycling.get(_recordId!);
      if (record == null && _status == RecordFormStatus.editing) {
        await flushDraft();
        _offeredDraft = _snapshot(_nextStamp());
        _autosave = false;
        _setStatus(RecordFormStatus.recordMissing);
      }
    } on LocalDataException {
      // Sin cambios: el guardado mostrará el error si persiste.
    }
  }

  /// Escribe ya el borrador pendiente y espera a que la cola termine.
  Future<void> flushDraft() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    if (_autosave && _dirty) _enqueueDraft();
    return _draftQueue;
  }

  bool get _editable => _status == RecordFormStatus.editing;

  void _changed() {
    _dirty = true;
    _notify();
    if (!_autosave) return;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounce, () {
      _debounceTimer = null;
      if (_autosave && _dirty) _enqueueDraft();
    });
  }

  void _enqueueDraft() {
    // La instantánea se toma ahora; la cola solo decide cuándo escribirla.
    final draft = _snapshot(_nextStamp());
    _dirty = false;
    _draftQueue = _draftQueue.then((_) async {
      try {
        await _drafts.save(draft);
        _setDraftError(null);
      } on LocalDataException catch (error) {
        _dirty = true;
        _setDraftError('No se pudo guardar el borrador: ${error.message}');
      }
    });
  }

  Future<bool> _clearDraft(String key) {
    final result = _draftQueue.then((_) async {
      try {
        await _drafts.clear(key);
        _setDraftError(null);
        return true;
      } on LocalDataException catch (error) {
        _setDraftError('No se pudo descartar el borrador: ${error.message}');
        return false;
      }
    });
    _draftQueue = result.then((_) {});
    return result;
  }

  RecyclingDraft _snapshot(DateTime stamp) => RecyclingDraft(
    key: draftKey,
    recordId: _recordId,
    pointId: _pointId,
    material: _material?.name,
    quantityText: _quantityText,
    note: _note,
    step: _step,
    updatedAt: stamp,
    occurredAt: _original?.occurredAt,
  );

  /// Marca de tiempo estrictamente creciente aunque el reloj no avance.
  DateTime _nextStamp() {
    var stamp = _clock().toUtc();
    final last = _lastStamp;
    if (last != null && !stamp.isAfter(last)) {
      stamp = last.add(const Duration(milliseconds: 1));
    }
    _lastStamp = stamp;
    return stamp;
  }

  bool _validateStep(int step) {
    switch (step) {
      case 0:
        _pointError = selectedPoint == null
            ? 'Elige el punto donde reciclaste.'
            : null;
        return _pointError == null;
      case 1:
        _materialError = _material == null ? 'Elige PET o lata.' : null;
        _quantityError = _parseQuantity(_quantityText).$2;
        _noteError = _note.trim().length > 200
            ? 'La nota admite hasta 200 caracteres.'
            : null;
        return _materialError == null &&
            _quantityError == null &&
            _noteError == null;
      default:
        return true;
    }
  }

  static (int?, String?) _parseQuantity(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return (null, 'Ingresa la cantidad.');
    if (!RegExp(r'^\d+$').hasMatch(text)) {
      return (null, 'Usa un número entero, sin decimales ni signos.');
    }
    final value = int.tryParse(text);
    if (value == null || value < 1 || value > 100) {
      return (null, 'La cantidad debe estar entre 1 y 100.');
    }
    return (value, null);
  }

  void _setDraftError(String? message) {
    if (_draftError == message) return;
    _draftError = message;
    _notify();
  }

  void _setStatus(RecordFormStatus next) {
    _status = next;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _debounceTimer?.cancel();
    // Último cambio aún sin escribir (p. ej. cierre de la vista sin back).
    if (_autosave && _dirty) _enqueueDraft();
    super.dispose();
  }
}
