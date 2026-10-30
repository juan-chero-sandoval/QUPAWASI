import 'dart:math';

import '../entities/deposit_qr.dart';
import '../entities/recycling_point.dart';

double distanceMeters(double lat1, double lon1, double lat2, double lon2) {
  double rad(double n) => n * pi / 180;
  final a =
      pow(sin(rad(lat2 - lat1) / 2), 2) +
      cos(rad(lat1)) * cos(rad(lat2)) * pow(sin(rad(lon2 - lon1) / 2), 2);
  return 6371000 * 2 * atan2(sqrt(a.clamp(0, 1)), sqrt((1 - a).clamp(0, 1)));
}

List<({RecyclingPoint point, double meters})> nearestPoints(
  List<RecyclingPoint> points,
  double latitude,
  double longitude,
) {
  if (!validCoordinates(latitude, longitude)) {
    throw ArgumentError('Ubicación inválida');
  }
  final result = [
    for (final p in points)
      if (!p.isDemo && validCoordinates(p.latitude, p.longitude))
        (
          point: p,
          meters: distanceMeters(
            latitude,
            longitude,
            p.latitude!,
            p.longitude!,
          ),
        ),
  ];
  result.sort((a, b) {
    final distance = a.meters.compareTo(b.meters);
    return distance != 0 ? distance : a.point.id.compareTo(b.point.id);
  });
  return result;
}
