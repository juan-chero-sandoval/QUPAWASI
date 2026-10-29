import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/errors/local_data_exception.dart';
import '../../domain/policies/demo_scoring_policy.dart';
import '../../domain/usecases/admin_catalog_use_cases.dart';

enum AdminFormStatus {
  loading,
  draftOffer,
  notFound,
  loadError,
  editing,
  saving,
}

enum DeleteOutcome { deleted, inUse, failed }

/// Base de los formularios de administración (tacho y recompensa).
///
/// Resuelve lo común: carga por ID, borrador en SQLite con debounce y cola
/// serializada (un guardado viejo nunca pisa uno nuevo), escritura forzada al
/// pasar a segundo plano, oferta de continuar/descartar y mensajes para toast.
abstract class AdminFormViewModel<T> extends ChangeNotifier {
  AdminFormViewModel({
    required this.admin,
    this.entityId,
    Clock? clock,
    this.debounce = const Duration(milliseconds: 400),
  }) : _clock = clock ?? DateTime.now;

  final AdminCatalogUseCases admin;

  /// `null` al crear; el ID serializable de la ruta al editar.
  final String? entityId;
  final Duration debounce;
  final Clock _clock;

  AdminFormStatus _status = AdminFormStatus.loading;
  bool _active = true;
  DateTime? _offeredAt;
  Map<String, Object?>? _offeredDraft;
  String? message;
  bool messageIsError = false;

  Timer? _timer;
  Future<void> _queue = Future.value();
  bool _dirty = false;
  bool _autosave = false;
  DateTime? _lastStamp;
  bool _disposed = false;

  AdminFormStatus get status => _status;
  bool get isEditing => entityId != null;
  bool get isSaving => _status == AdminFormStatus.saving;
  bool get isActive => _active;
  DateTime? get offeredDraftAt => _offeredAt;

  /// Prefijo de la clave de borrador, p. ej. `admin-point`.
  String get draftPrefix;
  String get draftKey => '$draftPrefix-${entityId ?? 'new'}';

  // ---- Ganchos de cada formulario ----
  Future<T?> loadEntity(String id);
  bool entityIsActive(T entity);
  void applyEntity(T entity);
  Map<String, Object?> toDraft();
  void applyDraft(Map<String, Object?> draft);

  /// Valida todos los campos (y deja los errores junto a cada uno).
  bool validate();

  /// Crea o actualiza con los valores ya validados.
  Future<void> persist();
  Future<void> deleteEntity(String id);
  Future<void> setEntityActive(String id, {required bool active});

  Future<void> load() async {
    _setStatus(AdminFormStatus.loading);
    try {
      if (isEditing) {
        final entity = await loadEntity(entityId!);
        if (entity == null) {
          _setStatus(AdminFormStatus.notFound);
          return;
        }
        _active = entityIsActive(entity);
        applyEntity(entity);
      }
      final draft = await admin.loadDraft(draftKey);
      if (draft == null) {
        _startEditing();
      } else {
        _offeredDraft = draft;
        final at = draft['savedAt'];
        _offeredAt = at is int
            ? DateTime.fromMillisecondsSinceEpoch(at, isUtc: true)
            : null;
        _setStatus(AdminFormStatus.draftOffer);
      }
    } on LocalDataException catch (error) {
      _toast(error.message, error: true);
      _setStatus(AdminFormStatus.loadError);
    }
  }

  void continueDraft() {
    final draft = _offeredDraft;
    if (draft != null) applyDraft(draft);
    _startEditing();
  }

  Future<void> discardDraft() async {
    await _enqueue(() => admin.clearDraft(draftKey));
    _startEditing();
  }

  void _startEditing() {
    _offeredDraft = null;
    _autosave = true;
    _setStatus(AdminFormStatus.editing);
  }

  /// Las subclases lo llaman tras cambiar un campo.
  @protected
  void changed() {
    if (_status != AdminFormStatus.editing) return;
    _dirty = true;
    _notify();
    if (!_autosave) return;
    _timer?.cancel();
    _timer = Timer(debounce, () {
      _timer = null;
      if (_autosave && _dirty) _saveDraftNow();
    });
  }

  /// Escribe ya el borrador pendiente (al pausar la app o volver atrás).
  Future<void> flushDraft() {
    _timer?.cancel();
    _timer = null;
    if (_autosave && _dirty) _saveDraftNow();
    return _queue;
  }

  void _saveDraftNow() {
    final stamp = _nextStamp();
    final values = {...toDraft(), 'savedAt': stamp.millisecondsSinceEpoch};
    _dirty = false;
    _enqueue(() => admin.saveDraft(draftKey, values, stamp));
  }

  Future<void> _enqueue(Future<void> Function() action) {
    _queue = _queue.then((_) async {
      try {
        await action();
      } on LocalDataException catch (error) {
        _dirty = true;
        _toast('No se pudo guardar el borrador: ${error.message}', error: true);
      }
    });
    return _queue;
  }

  /// Guarda en SQLite. Devuelve `true` solo si la escritura se confirmó;
  /// mientras guarda ignora nuevos toques (un doble tap = una operación).
  Future<bool> save() async {
    if (_status != AdminFormStatus.editing) return false;
    message = null;
    if (!validate()) {
      _notify();
      return false;
    }
    _setStatus(AdminFormStatus.saving);
    await flushDraft();
    try {
      await persist();
      _autosave = false;
      _timer?.cancel();
      _dirty = false;
      await _enqueue(() => admin.clearDraft(draftKey));
      _toast(isEditing ? 'Cambios guardados' : 'Creado correctamente');
      _setStatus(AdminFormStatus.editing);
      return true;
    } on LocalDataException catch (error) {
      _toast(error.message, error: true);
      _setStatus(AdminFormStatus.editing);
      return false;
    }
  }

  /// Elimina si no tiene historial. Con historial devuelve [DeleteOutcome.inUse]
  /// para que la vista ofrezca desactivarlo.
  Future<DeleteOutcome> delete() async {
    if (!isEditing || _status != AdminFormStatus.editing) {
      return DeleteOutcome.failed;
    }
    message = null;
    _setStatus(AdminFormStatus.saving);
    try {
      await deleteEntity(entityId!);
      _autosave = false;
      _timer?.cancel();
      await _enqueue(() => admin.clearDraft(draftKey));
      _toast('Eliminado');
      return DeleteOutcome.deleted;
    } on LocalDataException catch (error) {
      if (error.code == LocalDataError.conflict) return DeleteOutcome.inUse;
      _toast(error.message, error: true);
      return DeleteOutcome.failed;
    } finally {
      if (_status == AdminFormStatus.saving) {
        _setStatus(AdminFormStatus.editing);
      }
    }
  }

  Future<void> setActive(bool active) async {
    if (!isEditing || _status != AdminFormStatus.editing) return;
    message = null;
    try {
      await setEntityActive(entityId!, active: active);
      _active = active;
      _toast(active ? 'Activado' : 'Desactivado');
    } on LocalDataException catch (error) {
      _toast(error.message, error: true);
    }
    _notify();
  }

  void _toast(String text, {bool error = false}) {
    message = text;
    messageIsError = error;
  }

  DateTime _nextStamp() {
    var stamp = _clock().toUtc();
    final last = _lastStamp;
    if (last != null && !stamp.isAfter(last)) {
      stamp = last.add(const Duration(milliseconds: 1));
    }
    _lastStamp = stamp;
    return stamp;
  }

  void _setStatus(AdminFormStatus next) {
    _status = next;
    _notify();
  }

  @protected
  void notifyChanged() => _notify();

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    // Último cambio aún sin escribir (cierre de la vista sin back).
    if (_autosave && _dirty) _saveDraftNow();
    super.dispose();
  }
}
