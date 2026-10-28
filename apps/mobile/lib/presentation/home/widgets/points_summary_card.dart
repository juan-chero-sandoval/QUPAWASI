import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_theme.dart';

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
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: palette.brandStrong,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius + 4),
      ),
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
                style: TextStyle(color: onCard.withValues(alpha: 0.85)),
              ),
              Chip(
                avatar: Icon(
                  Icons.star_border,
                  size: 16,
                  color: palette.onAccent,
                ),
                label: Text('Nivel $levelName'),
                labelStyle: TextStyle(
                  color: palette.onAccent,
                  fontWeight: FontWeight.w700,
                ),
                backgroundColor: palette.accent,
                side: BorderSide.none,
                visualDensity: VisualDensity.compact,
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
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const TextSpan(
                    text: 'EcoPuntos',
                    style: TextStyle(fontWeight: FontWeight.w700),
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
              minHeight: 8,
              color: palette.accent,
              backgroundColor: onCard.withValues(alpha: 0.2),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            nextLevelText,
            style: TextStyle(color: onCard.withValues(alpha: 0.85)),
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
