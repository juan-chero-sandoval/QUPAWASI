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
import 'overview_view_model.dart';
import '../common/local_state.dart';
import '../common/local_stream_view_model.dart';
import '../../app/dependencies.dart';
import '../../domain/entities/recycling_record.dart';
import '../recycling/record_format.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final overview = context.watch<OverviewViewModel>();
    final alias = context.select<AppSettingsViewModel, String>(
      (vm) => vm.alias,
    );
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.contentWidth,
            ),
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
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Cada envase cuenta.',
                            style: TextStyle(
                              color: palette.textMuted,
                              fontSize: 14,
                            ),
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
                LocalState(
                  vm: overview,
                  builder: (stats) {
                    final summary = HomeSummary.fromStatistics(stats);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        PointsSummaryCard(
                          points: summary.availablePoints,
                          levelName: summary.levelName,
                          progress: summary.levelProgress,
                          nextLevelText: summary.nextLevelText,
                          onRegister: () => context.go(AppRoutes.newRecord()),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Total ganado: ${stats.earnedPoints} EcoPuntos simulados',
                          style: TextStyle(
                            color: palette.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    );
                  },
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
                LocalState(
                  vm: overview,
                  builder: (stats) => Row(
                    children: [
                      Expanded(
                        child: _ImpactTile(
                          icon: Icons.local_drink_outlined,
                          value: '${stats.petCount}',
                          label: 'botellas PET',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _ImpactTile(
                          icon: Icons.inventory_2_outlined,
                          value: '${stats.aluminumCount}',
                          label: 'latas',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Tu impacto se muestra en unidades recicladas.',
                  style: TextStyle(color: palette.textMuted, fontSize: 12),
                ),
                const SectionHeader(title: 'Actividad reciente'),
                const RecentActivity(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RecentActivity extends StatelessWidget {
  const RecentActivity({super.key});
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => LocalStreamViewModel(
      context.read<AppDependencies>().local.recycling.watch,
    ),
    child: Consumer<LocalStreamViewModel<List<RecyclingRecord>>>(
      builder: (context, vm, _) => LocalState(
        vm: vm,
        builder: (records) {
          final sorted = [...records]
            ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
          if (sorted.isEmpty) {
            return StateMessage(
              icon: Icons.history,
              title: 'Aún no tienes registros',
              message: 'Tus registros se guardan en este dispositivo.',
              actionLabel: 'Registrar mi primer reciclaje',
              onAction: () => context.go(AppRoutes.newRecord()),
            );
          }
          return Column(
            children: [
              for (final record in sorted.take(5))
                ListTile(
                  title: Text(
                    RecordFormat.quantity(record.material, record.quantity),
                  ),
                  subtitle: Text(
                    '${RecordFormat.dateTime(context, record.occurredAt)} · ${record.earnedPoints} pts simulados',
                  ),
                  onTap: () => context.push(AppRoutes.recordDetail(record.id)),
                ),
            ],
          );
        },
      ),
    ),
  );
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
          IconBadge(icon: icon, size: 40),
          const SizedBox(height: AppSpacing.md),
          Text(value, style: Theme.of(context).textTheme.headlineMedium),
          Text(label, style: TextStyle(color: palette.textMuted, fontSize: 14)),
        ],
      ),
    );
  }
}
