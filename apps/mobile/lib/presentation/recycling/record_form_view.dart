import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_page.dart';
import '../../core/widgets/state_message.dart';

/// Destino de `/recycling/new?pointId=` y `/recycling/:recordId/edit`.
/// En F01 solo muestra los parámetros recibidos; F03 implementa el
/// formulario Punto → Material → Confirmar con borrador.
class RecordFormView extends StatelessWidget {
  const RecordFormView.create({super.key, this.pointId}) : recordId = null;

  const RecordFormView.edit({super.key, required String this.recordId})
    : pointId = null;

  final String? pointId;
  final String? recordId;

  bool get isEditing => recordId != null;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return AppPage(
      title: isEditing ? 'Editar registro' : 'Nuevo registro',
      showBack: true,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Parámetros recibidos',
                style: TextStyle(color: palette.textMuted, fontSize: 12),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                isEditing
                    ? 'recordId: $recordId'
                    : 'pointId: ${pointId ?? 'sin preselección'}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        StateMessage.inPreparation(
          message:
              'El formulario Punto → Material → Confirmar, con borrador '
              'automático, se implementa en F03.',
          actionLabel: 'Volver a Reciclar',
          onAction: () => context.go(AppRoutes.recycling),
        ),
      ],
    );
  }
}
