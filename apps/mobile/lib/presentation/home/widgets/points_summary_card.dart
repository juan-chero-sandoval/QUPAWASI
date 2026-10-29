import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/brand_surfaces.dart';

/// Tarjeta verde con saldo, nivel, progreso y CTA principal.
class PointsSummaryCard extends StatelessWidget {
  const PointsSummaryCard({
    super.key,
    required this.points,
    required this.levelName,
    required this.progress,
    required this.nextLevelText,
    required this.onRegister,
  });

  final int points;
  final String levelName;
  final double progress;
  final String nextLevelText;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final onCard = palette.onBrandStrong;
    return BrandSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              Text(
                'Puntos disponibles',
                style: TextStyle(
                  color: onCard.withValues(alpha: 0.88),
                  fontSize: 14,
                ),
              ),
              StatusPill(
                label: 'Nivel $levelName',
                icon: Icons.eco_outlined,
                highlighted: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Semantics(
            label: '$points EcoPuntos simulados',
            excludeSemantics: true,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$points ',
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 56,
                      height: 1.1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(
                    text: 'EcoPuntos',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              style: TextStyle(color: onCard),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1),
              minHeight: 6,
              color: palette.accent,
              backgroundColor: onCard.withValues(alpha: 0.2),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            nextLevelText,
            style: TextStyle(
              color: onCard.withValues(alpha: 0.88),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: palette.accent,
                foregroundColor: palette.onAccent,
              ),
              onPressed: onRegister,
              icon: const Icon(Icons.recycling),
              label: const Text('Registrar reciclaje'),
            ),
          ),
        ],
      ),
    );
  }
}
