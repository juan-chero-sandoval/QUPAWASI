import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../../domain/entities/geo_position.dart';
import '../../domain/errors/local_data_exception.dart';

Future<GeoPosition> locateDevice() async {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocalDataException(
        LocalDataError.validation,
        'Activa la ubicación del dispositivo y reintenta.',
      );
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw const LocalDataException(
        LocalDataError.validation,
        'Permiso de ubicación denegado. Puedes habilitarlo en Ajustes; la lista de tachos sigue disponible.',
      );
    }
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
    return GeoPosition(position.latitude, position.longitude);
  } on LocalDataException {
    rethrow;
  } on TimeoutException {
    throw const LocalDataException(
      LocalDataError.storage,
      'No se obtuvo ubicación a tiempo. Reintenta al aire libre.',
    );
  } catch (_) {
    throw const LocalDataException(
      LocalDataError.storage,
      'No se pudo obtener tu ubicación. Reintenta.',
    );
  }
}
