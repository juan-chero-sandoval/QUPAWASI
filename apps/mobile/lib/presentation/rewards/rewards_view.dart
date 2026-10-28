import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_page.dart';
import '../../core/widgets/state_message.dart';

/// Pestaña Premios. Catálogo y canjes simulados se implementan en F04.
class RewardsView extends StatelessWidget {
  const RewardsView({super.key, this.category});

  final String? category;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return AppPage(
      title: 'Recompensas',
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md + 4),
          decoration: BoxDecoration(
            color: palette.brandStrong,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          ),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.sm,
            children: [
              Text('Tu saldo', style: TextStyle(color: palette.onBrandStrong)),
              Text(
                '0 EcoPuntos',
                style: TextStyle(
                  color: palette.onBrandStrong,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Los canjes son simulados: no hay dinero real ni entrega comercial.',
          style: TextStyle(color: palette.textMuted),
        ),
        if (category != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Categoría recibida: $category',
            style: TextStyle(color: palette.textMuted),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        const StateMessage.inPreparation(
          message:
              'El catálogo de demostración, la confirmación de canje y su '
              'cancelación se implementan en F04.',
        ),
      ],
    );
  }
}
