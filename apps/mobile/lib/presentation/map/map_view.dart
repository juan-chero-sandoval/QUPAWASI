import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_page.dart';
import '../../core/widgets/state_message.dart';

/// Pestaña Mapa. El esquema local del campus y los puntos de demostración
/// se implementan en F04; aquí se comprueba el parámetro `pointId`.
class MapView extends StatelessWidget {
  const MapView({super.key, this.pointId});

  final String? pointId;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return AppPage(
      title: 'Mapa',
      children: [
        if (pointId != null) ...[
          Text(
            'Punto recibido: $pointId',
            style: TextStyle(color: palette.textMuted),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        const StateMessage.inPreparation(
          message:
              'El esquema local del campus y la lista de puntos de '
              'demostración se implementan en F04. Funcionará sin internet.',
        ),
        const SizedBox(height: AppSpacing.md),
        FilledButton.icon(
          onPressed: () => context.go(AppRoutes.newRecord(pointId: pointId)),
          icon: const Icon(Icons.recycling),
          label: Text(
            pointId == null ? 'Registrar reciclaje' : 'Registrar en este punto',
          ),
        ),
      ],
    );
  }
}
