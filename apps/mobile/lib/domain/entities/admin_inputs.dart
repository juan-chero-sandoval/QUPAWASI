import 'reward.dart';

/// Datos que el administrador (simulado) escribe para crear o editar un tacho.
class PointInput {
  const PointInput({
    required this.name,
    required this.description,
    required this.occupancy,
    required this.latitude,
    required this.longitude,
  });

  final String name;
  final String description;
  final int occupancy;
  final double latitude;
  final double longitude;
}

/// Datos de una recompensa del catálogo de canjes simulados.
class RewardInput {
  const RewardInput({
    required this.title,
    required this.category,
    required this.costPoints,
    required this.description,
  });

  final String title;
  final RewardCategory category;
  final int costPoints;
  final String description;
}

/// Límites compartidos por la validación de dominio y los formularios.
abstract final class AdminLimits {
  static const int pointNameMin = 2;
  static const int pointNameMax = 60;
  static const int descriptionMax = 200;
  static const int rewardTitleMin = 3;
  static const int rewardTitleMax = 60;
  static const int costMin = 1;
  static const int costMax = 10000;
}
