import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/dependencies.dart';
import '../../app/routes.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_page.dart';
import '../../core/widgets/brand_surfaces.dart';
import '../../core/widgets/state_message.dart';
import '../../domain/entities/recycling_point.dart';
import '../common/local_state.dart';
import '../common/local_stream_view_model.dart';

/// Lista de tachos para el administrador simulado (activos e inactivos).
class AdminPointsView extends StatelessWidget {
  const AdminPointsView({super.key});

  @override
  Widget build(BuildContext context) {
    final admin = context.read<AppDependencies>().local.admin!;
    return ChangeNotifierProvider(
      create: (_) =>
          LocalStreamViewModel<List<RecyclingPoint>>(admin.watchPoints),
      child: Consumer<LocalStreamViewModel<List<RecyclingPoint>>>(
        builder: (context, vm, _) => AppPage(
          title: 'Tachos',
          showBack: true,
          bottomAction: FilledButton.icon(
            onPressed: () => context.push(AppRoutes.newAdminPoint()),
            icon: const Icon(Icons.add_location_alt_outlined),
            label: const Text('Nuevo tacho'),
          ),
          children: [
            LocalState(
              vm: vm,
              builder: (points) => points.isEmpty
                  ? const StateMessage(
                      icon: Icons.delete_outline,
                      title: 'Aún no hay tachos',
                    )
                  : Column(
                      children: [
                        for (final point in points)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: _PointTile(point: point),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PointTile extends StatelessWidget {
  const _PointTile({required this.point});

  final RecyclingPoint point;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final located = point.latitude != null && point.longitude != null;
    return AppCard(
      onTap: () => context.push(AppRoutes.editAdminPoint(point.id)),
      child: Row(
        children: [
          IconBadge(
            icon: located ? Icons.location_on_outlined : Icons.location_off,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  point.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  located
                      ? '${point.latitude!.toStringAsFixed(5)}, '
                            '${point.longitude!.toStringAsFixed(5)}'
                      : 'Sin coordenadas',
                  style: TextStyle(color: palette.textMuted, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          StatusPill(
            label: point.isActive ? 'Activo' : 'Inactivo',
            icon: point.isActive ? Icons.check_rounded : Icons.block_rounded,
            highlighted: point.isActive,
          ),
        ],
      ),
    );
  }
}
