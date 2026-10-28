class RecyclingPoint {
  const RecyclingPoint({
    required this.id,
    required this.name,
    required this.description,
    required this.occupancy,
    required this.isDemo,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String name;
  final String description;
  final int occupancy;
  final bool isDemo;
  final double? latitude;
  final double? longitude;
}
