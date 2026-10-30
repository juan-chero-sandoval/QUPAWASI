import 'dart:convert';

import '../errors/local_data_exception.dart';
import '../policies/local_validation.dart';
import 'recycling_record.dart';

/// Recibo emitido por el tacho. Los puntos nunca se aceptan del emisor.
class DepositQr {
  const DepositQr({
    required this.depositId,
    required this.input,
    required this.latitude,
    required this.longitude,
  });
  final String depositId;
  final RecordInput input;
  final double latitude;
  final double longitude;

  static DepositQr parse(String raw, {DateTime? now}) {
    try {
      if (raw.length > 4096) throw const FormatException();
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic> ||
          json['type'] != 'qupawasi.deposit' ||
          json['version'] != 1 ||
          json['version'] is! int ||
          json['quantity'] is! int ||
          json['latitude'] is! num ||
          json['longitude'] is! num) {
        throw const FormatException();
      }
      final id = json['depositId'] as String;
      final pointId = json['pointId'] as String;
      LocalValidation.id(id);
      LocalValidation.id(pointId);
      if (id.trim() != id || pointId.trim() != pointId) {
        throw const FormatException();
      }
      final timestamp = json['occurredAt'] as String;
      // Evita fechas normalizadas silenciosamente (p.ej. 30 de febrero).
      final match = RegExp(
        r'^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})(Z|[+-]\d{2}:\d{2})$',
      ).firstMatch(timestamp);
      if (match == null) throw const FormatException();
      final parts = [for (var i = 1; i <= 6; i++) int.parse(match.group(i)!)];
      final date = DateTime.utc(
        parts[0],
        parts[1],
        parts[2],
        parts[3],
        parts[4],
        parts[5],
      );
      if (date.year != parts[0] ||
          date.month != parts[1] ||
          date.day != parts[2] ||
          parts[3] > 23 ||
          parts[4] > 59 ||
          parts[5] > 59) {
        throw const FormatException();
      }
      final zone = match.group(7)!;
      if (zone != 'Z' &&
          (int.parse(zone.substring(1, 3)) > 14 ||
              int.parse(zone.substring(4)) > 59 ||
              (int.parse(zone.substring(1, 3)) == 14 &&
                  int.parse(zone.substring(4)) != 0))) {
        throw const FormatException();
      }
      final lat = (json['latitude'] as num).toDouble();
      final lon = (json['longitude'] as num).toDouble();
      LocalValidation.require(
        validCoordinates(lat, lon),
        'Coordenadas del QR inválidas.',
      );
      final input = RecordInput(
        pointId: pointId,
        material: RecyclingMaterial.values.byName(json['material'] as String),
        quantity: json['quantity'] as int,
        occurredAt: DateTime.parse(timestamp).toUtc(),
      );
      LocalValidation.record(input, now ?? DateTime.now());
      return DepositQr(
        depositId: id,
        input: input,
        latitude: lat,
        longitude: lon,
      );
    } on LocalDataException {
      rethrow;
    } catch (_) {
      throw const LocalDataException(
        LocalDataError.validation,
        'QR de reciclaje inválido. Solicita un recibo compatible al tacho.',
      );
    }
  }

  String get canonical => jsonEncode({
    'depositId': depositId,
    'pointId': input.pointId,
    'material': input.material.name,
    'quantity': input.quantity,
    'occurredAt': input.occurredAt.toUtc().toIso8601String(),
    'latitude': latitude,
    'longitude': longitude,
  });
}

bool validCoordinates(double? lat, double? lon) =>
    lat != null &&
    lon != null &&
    lat.isFinite &&
    lon.isFinite &&
    lat >= -90 &&
    lat <= 90 &&
    lon >= -180 &&
    lon <= 180;
