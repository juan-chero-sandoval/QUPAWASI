class RecyclingPoint {
  const RecyclingPoint({
    required this.id,
    required this.name,
    required this.description,
    required this.occupancy,
    required this.isDemo,
    this.latitude,
    this.longitude,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String description;
  final int occupancy;
  final bool isDemo;
  final double? latitude;
  final double? longitude;

  /// Un tacho desactivado conserva su historial pero no admite nuevos usos.
  final bool isActive;
}
