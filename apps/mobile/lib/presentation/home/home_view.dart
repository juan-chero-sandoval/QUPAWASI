import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/prototype_banner.dart';
import '../../core/widgets/state_message.dart';
import '../common/user_avatar.dart';
import '../settings/app_settings_view_model.dart';
import 'home_summary.dart';
import 'widgets/points_summary_card.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key, this.summary = const HomeSummary.initial()});

  final HomeSummary summary;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final alias = context.select<AppSettingsViewModel, String>(
      (vm) => vm.alias,
    );
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'suggestions',
        onPressed: () => context.push(AppRoutes.suggestions),
        icon: const Icon(Icons.inbox_outlined),
        label: const Text('Sugerencias'),
      ),
      body: SafeArea(
        child: ListView(
          // Clave propia: no hereda el desplazamiento de otra pantalla.
          key: const PageStorageKey<String>('home-scroll'),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen,
            AppSpacing.md,
            AppSpacing.screen,
            96,
          ),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Q'UPA WASI UNP",
                        style: TextStyle(
                          color: palette.brand,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Hola, $alias',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
                UserAvatar(
                  alias: alias,
                  onTap: () => context.go(AppRoutes.profile),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const PrototypeBanner(),
            const SizedBox(height: AppSpacing.md),
            PointsSummaryCard(
              points: summary.availablePoints,
              levelName: summary.levelName,
              progress: summary.levelProgress,
              nextLevelText: summary.nextLevelText,
              onRegister: () => context.go(AppRoutes.newRecord()),
            ),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              onTap: () => context.push(AppRoutes.ranking),
              child: Row(
                children: [
                  const IconBadge(icon: Icons.emoji_events_outlined),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ranking',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          'Ejemplo de demostración, sin estudiantes reales',
                          style: TextStyle(color: palette.textMuted),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
            const SectionHeader(
              title: 'Tu impacto',
              trailing: 'Conteo de unidades',
            ),
            Row(
              children: [
                Expanded(
                  child: _ImpactTile(
                    icon: Icons.local_drink_outlined,
                    value: '${summary.petBottles}',
                    label: 'botellas PET',
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _ImpactTile(
                    icon: Icons.inventory_2_outlined,
                    value: '${summary.cans}',
                    label: 'latas',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Masa y CO₂: estimación no configurada.',
              style: TextStyle(color: palette.textMuted, fontSize: 12),
            ),
            const SectionHeader(title: 'Actividad reciente'),
            StateMessage(
              icon: Icons.history,
              title: 'Aún no tienes registros',
              message:
                  'Cuando registres tu reciclaje aparecerá aquí. Los '
                  'registros se guardarán en este dispositivo.',
              actionLabel: 'Registrar mi primer reciclaje',
              onAction: () => context.go(AppRoutes.newRecord()),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImpactTile extends StatelessWidget {
  const _ImpactTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: palette.brand),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          Text(label, style: TextStyle(color: palette.textMuted)),
        ],
      ),
    );
  }
}
