import 'dart:convert';

import '../entities/deposit_qr.dart';
import '../entities/recycling_point.dart';
import '../errors/local_data_exception.dart';
import '../policies/local_validation.dart';

abstract interface class PointCatalogRepository {
  Future<void> upsertAll(List<RecyclingPoint> points);
}

class PointCatalogUseCases {
  const PointCatalogUseCases(this.repository);
  final PointCatalogRepository repository;
  Future<void> importJson(String raw) async {
    late final List<RecyclingPoint> points;
    try {
      if (raw.length > 100000) throw const FormatException();
      final json = jsonDecode(raw);
      if (json is! Map ||
          json['version'] != 1 ||
          json['version'] is! int ||
          json['points'] is! List) {
        throw const FormatException();
      }
      final items = json['points'] as List;
      if (items.isEmpty || items.length > 200) throw const FormatException();
      final ids = <String>{};
      points = [for (final item in items) _parse(item, ids)];
    } on LocalDataException {
      rethrow;
    } catch (_) {
      throw const LocalDataException(
        LocalDataError.validation,
        'Catálogo inválido. Revisa IDs, nombres y coordenadas de todos los tachos.',
      );
    }
    await repository.upsertAll(points);
  }

  RecyclingPoint _parse(dynamic item, Set<String> ids) {
    final id = item['id'] as String;
    LocalValidation.id(id);
    final name = (item['name'] as String).trim();
    final lat = (item['latitude'] as num).toDouble();
    final lon = (item['longitude'] as num).toDouble();
    final occupancy = item['occupancy'] ?? 0;
    if (!ids.add(id) ||
        id.trim() != id ||
        name.isEmpty ||
        name.length > 100 ||
        !validCoordinates(lat, lon) ||
        occupancy is! int ||
        occupancy < 0 ||
        occupancy > 100 ||
        item['isDemo'] is! bool) {
      throw const FormatException();
    }
    return RecyclingPoint(
      id: id,
      name: name,
      description: (item['description'] as String?) ?? '',
      occupancy: occupancy,
      latitude: lat,
      longitude: lon,
      isDemo: item['isDemo'] as bool,
    );
  }
}
