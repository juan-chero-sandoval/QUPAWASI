import '../../domain/entities/recycling_point.dart';
import '../../domain/entities/reward.dart';

/// UUID estables de fixtures. No representan equipos, posiciones ni comercios reales.
class DemoSeed {
  static const architectureId = '00000000-0000-4000-8000-000000000001';
  static const libraryId = '00000000-0000-4000-8000-000000000002';
  static const diningId = '00000000-0000-4000-8000-000000000003';
  static const photocopiesId = '00000000-0000-4000-8000-000000000011';
  static const mobileId = '00000000-0000-4000-8000-000000000012';
  static const cafeteriaId = '00000000-0000-4000-8000-000000000013';

  static const points = [
    RecyclingPoint(
      id: architectureId,
      name: 'Arquitectura',
      description: 'Punto de demostración · sin ubicación real verificada',
      occupancy: 0,
      isDemo: true,
    ),
    RecyclingPoint(
      id: libraryId,
      name: 'Biblioteca',
      description: 'Punto de demostración · sin ubicación real verificada',
      occupancy: 40,
      isDemo: true,
    ),
    RecyclingPoint(
      id: diningId,
      name: 'Comedor',
      description: 'Punto de demostración · sin ubicación real verificada',
      occupancy: 80,
      isDemo: true,
    ),
  ];

  static const rewards = [
    Reward(
      id: photocopiesId,
      title: '50% en fotocopias',
      category: RewardCategory.photocopies,
      costPoints: 80,
      description: 'Simulación local. No se entrega un descuento real.',
      isActive: true,
    ),
    Reward(
      id: mobileId,
      title: 'Recarga S/ 1.00 simulada',
      category: RewardCategory.mobile,
      costPoints: 100,
      description: 'Simulación local. No se realiza ninguna recarga.',
      isActive: true,
    ),
    Reward(
      id: cafeteriaId,
      title: '20% en cafetería UNP',
      category: RewardCategory.cafeteria,
      costPoints: 150,
      description: 'Simulación local. No se entrega un descuento real.',
      isActive: true,
    ),
  ];
}
