import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_page.dart';

/// Fictitious examples only; no automatic participation of the local profile.
class RankingView extends StatelessWidget {
  const RankingView({super.key});
  @override
  Widget build(BuildContext context) => const AppPage(
    title: 'Ranking',
    showBack: true,
    children: [
      // Alias ficticios: el perfil local no participa (sin estudiantes reales).
      _RankRow(position: 1, alias: 'Colibrí Verde', points: 900),
      _RankRow(position: 2, alias: 'Ceibo Azul', points: 600),
      _RankRow(position: 3, alias: 'Semilla Dorada', points: 300),
      SizedBox(height: 16),
      Text(
        'Datos de ejemplo',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12),
      ),
    ],
  );
}

class _RankRow extends StatelessWidget {
  const _RankRow({
    required this.position,
    required this.alias,
    required this.points,
  });

  final int position;
  final String alias;
  final int points;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final medal = position == 1;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: medal ? palette.accent : palette.iconBadge,
              foregroundColor: medal ? palette.onAccent : palette.brand,
              child: Text(
                '$position',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                alias,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Icon(Icons.eco_outlined, size: 18, color: palette.brand),
            const SizedBox(width: 4),
            Text(
              '$points pts',
              style: TextStyle(
                color: palette.brand,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
