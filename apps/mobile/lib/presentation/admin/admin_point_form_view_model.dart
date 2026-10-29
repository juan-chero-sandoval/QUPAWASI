import '../../domain/entities/admin_inputs.dart';
import '../../domain/entities/geo_position.dart';
import '../../domain/entities/recycling_point.dart';
import '../../domain/errors/local_data_exception.dart';
import 'admin_form_view_model.dart';

/// Formulario de tacho: nombre, descripción, ocupación y coordenadas (GPS o
/// escritas a mano). Los campos numéricos se guardan como texto para que el
/// borrador conserve también una entrada incompleta.
class AdminPointFormViewModel extends AdminFormViewModel<RecyclingPoint> {
  AdminPointFormViewModel({
    required super.admin,
    super.entityId,
    super.clock,
    super.debounce,
    this.locate,
  });

  final Future<GeoPosition> Function()? locate;

  String name = '';
  String description = '';
  String occupancyText = '0';
  String latitudeText = '';
  String longitudeText = '';
  bool locating = false;

  String? nameError;
  String? descriptionError;
  String? occupancyError;
  String? latitudeError;
  String? longitudeError;

  @override
  String get draftPrefix => 'admin-point';

  void setName(String value) {
    name = value;
    nameError = null;
    changed();
  }

  void setDescription(String value) {
    description = value;
    descriptionError = null;
    changed();
  }

  void setOccupancy(String value) {
    occupancyText = value;
    occupancyError = null;
    changed();
  }

  void setLatitude(String value) {
    latitudeText = value;
    latitudeError = null;
    changed();
  }

  void setLongitude(String value) {
    longitudeText = value;
    longitudeError = null;
    changed();
  }

  /// Rellena latitud y longitud con la ubicación actual (permiso a demanda).
  Future<bool> useCurrentLocation() async {
    if (locating || status != AdminFormStatus.editing) return false;
    message = null;
    if (locate == null) {
      message = 'Ubicación no disponible en este dispositivo.';
      messageIsError = true;
      notifyChanged();
      return false;
    }
    locating = true;
    notifyChanged();
    try {
      final position = await locate!();
      latitudeText = position.latitude.toStringAsFixed(6);
      longitudeText = position.longitude.toStringAsFixed(6);
      latitudeError = null;
      longitudeError = null;
      changed();
      return true;
    } on LocalDataException catch (error) {
      message = error.message;
      messageIsError = true;
      return false;
    } catch (_) {
      message = 'No se pudo obtener la ubicación. Revisa el permiso y el GPS.';
      messageIsError = true;
      return false;
    } finally {
      locating = false;
      notifyChanged();
    }
  }

  @override
  Future<RecyclingPoint?> loadEntity(String id) => admin.getPoint(id);

  @override
  bool entityIsActive(RecyclingPoint entity) => entity.isActive;

  @override
  void applyEntity(RecyclingPoint entity) {
    name = entity.name;
    description = entity.description;
    occupancyText = '${entity.occupancy}';
    latitudeText = entity.latitude?.toString() ?? '';
    longitudeText = entity.longitude?.toString() ?? '';
  }

  @override
  Map<String, Object?> toDraft() => {
    'name': name,
    'description': description,
    'occupancy': occupancyText,
    'latitude': latitudeText,
    'longitude': longitudeText,
  };

  @override
  void applyDraft(Map<String, Object?> draft) {
    String text(String key, String fallback) =>
        draft[key] is String ? draft[key]! as String : fallback;
    name = text('name', name);
    description = text('description', description);
    occupancyText = text('occupancy', occupancyText);
    latitudeText = text('latitude', latitudeText);
    longitudeText = text('longitude', longitudeText);
  }

  @override
  bool validate() {
    final trimmed = name.trim();
    nameError =
        trimmed.length < AdminLimits.pointNameMin ||
            trimmed.length > AdminLimits.pointNameMax
        ? 'Entre ${AdminLimits.pointNameMin} y ${AdminLimits.pointNameMax} '
              'caracteres.'
        : null;
    descriptionError = description.trim().length > AdminLimits.descriptionMax
        ? 'Hasta ${AdminLimits.descriptionMax} caracteres.'
        : null;
    final occupancy = int.tryParse(occupancyText.trim());
    occupancyError =
        !RegExp(r'^\d+$').hasMatch(occupancyText.trim()) ||
            occupancy == null ||
            occupancy > 100
        ? 'Número entero entre 0 y 100.'
        : null;
    latitudeError = _coordinateError(latitudeText, 90, 'La latitud');
    longitudeError = _coordinateError(longitudeText, 180, 'La longitud');
    return nameError == null &&
        descriptionError == null &&
        occupancyError == null &&
        latitudeError == null &&
        longitudeError == null;
  }

  static String? _coordinateError(String raw, double limit, String label) {
    final text = raw.trim();
    if (text.isEmpty) return 'Obligatoria. Usa el GPS o escríbela.';
    final value = double.tryParse(text.replaceAll(',', '.'));
    if (value == null || !value.isFinite) return 'Usa un número decimal.';
    if (value.abs() > limit) {
      return '$label debe estar entre -${limit.toInt()} y ${limit.toInt()}.';
    }
    return null;
  }

  PointInput get _input => PointInput(
    name: name.trim(),
    description: description.trim(),
    occupancy: int.parse(occupancyText.trim()),
    latitude: double.parse(latitudeText.trim().replaceAll(',', '.')),
    longitude: double.parse(longitudeText.trim().replaceAll(',', '.')),
  );

  @override
  Future<void> persist() async {
    if (isEditing) {
      await admin.updatePoint(entityId!, _input);
    } else {
      await admin.createPoint(_input);
    }
  }

  @override
  Future<void> deleteEntity(String id) => admin.deletePoint(id);

  @override
  Future<void> setEntityActive(String id, {required bool active}) =>
      admin.setPointActive(id, active: active);
}
