import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/entities/geo_position.dart';
import '../../domain/entities/recycling_point.dart';
import '../../domain/errors/local_data_exception.dart';
import '../../domain/policies/nearest_point.dart';
import '../../domain/usecases/overview_use_cases.dart';
import '../../domain/usecases/point_catalog_use_cases.dart';

class MapViewModel extends ChangeNotifier {
  MapViewModel({
    required OverviewUseCases overview,
    this.catalog,
    this.locate,
    String? pointId,
  }) : selected = pointId {
    _subscription = overview.watchPoints().listen(
      (value) {
        // Los tachos desactivados conservan historial pero no se ofrecen.
        points = value.where((p) => p.isActive).toList();
        loading = false;
        error = null;
        selected ??= points.firstOrNull?.id;
        _rank();
        _notify();
      },
      onError: (Object e) {
        loading = false;
        error = _message(e);
        _notify();
      },
    );
  }
  final PointCatalogUseCases? catalog;
  final Future<GeoPosition> Function()? locate;
  late final StreamSubscription<List<RecyclingPoint>> _subscription;
  List<RecyclingPoint> points = [];
  List<({RecyclingPoint point, double meters})> ranked = [];
  GeoPosition? position;
  String? selected;
  String? error;
  bool loading = true;
  bool locating = false;
  bool importing = false;
  bool _disposed = false;
  RecyclingPoint? get selectedPoint =>
      points.where((p) => p.id == selected).firstOrNull;
  void select(String id) {
    selected = id;
    _notify();
  }

  void _rank() {
    if (position != null) {
      ranked = nearestPoints(points, position!.latitude, position!.longitude);
    }
  }

  Future<void> findNearest() async {
    if (locating) return;
    error = null;
    locating = true;
    _notify();
    try {
      if (!points.any(
        (p) => !p.isDemo && p.latitude != null && p.longitude != null,
      )) {
        throw const LocalDataException(
          LocalDataError.validation,
          'Faltan coordenadas verificadas de tachos. Carga el catálogo para calcular el más cercano.',
        );
      }
      if (locate == null) {
        throw const LocalDataException(
          LocalDataError.storage,
          'Ubicación no disponible en este dispositivo.',
        );
      }
      position = await locate!();
      _rank();
      if (ranked.isEmpty) {
        throw const LocalDataException(
          LocalDataError.validation,
          'No hay tachos con coordenadas válidas.',
        );
      }
      selected = ranked.first.point.id;
    } catch (e) {
      error = _message(e);
    } finally {
      locating = false;
      _notify();
    }
  }

  Future<bool> importJson(String raw) async {
    if (importing) return false;
    importing = true;
    error = null;
    _notify();
    try {
      if (catalog == null) {
        throw const LocalDataException(
          LocalDataError.storage,
          'Carga de catálogo no disponible.',
        );
      }
      await catalog!.importJson(raw);
      return true;
    } catch (e) {
      error = _message(e);
      return false;
    } finally {
      importing = false;
      _notify();
    }
  }

  String _message(Object e) => e is LocalDataException
      ? e.message
      : 'No se pudo consultar el mapa. Reintenta.';
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription.cancel();
    super.dispose();
  }
}
