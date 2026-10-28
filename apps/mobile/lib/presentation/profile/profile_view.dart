import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_page.dart';
import '../../domain/entities/app_preferences.dart';
import '../common/user_avatar.dart';
import '../settings/app_settings_view_model.dart';
import 'alias_dialog.dart';
import '../home/overview_view_model.dart';
import '../home/home_view.dart';
import '../common/local_state.dart';
import '../../domain/entities/recycling_statistics.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  /// Level descriptions; current progress comes from the domain policy.
  static const List<({String name, int points, IconData icon})> levels = [
    (name: 'Semilla', points: 0, icon: Icons.grass),
    (name: 'Brote', points: 200, icon: Icons.eco_outlined),
    (name: 'Árbol joven', points: 500, icon: Icons.park_outlined),
    (name: 'Guardián del bosque', points: 1000, icon: Icons.forest_outlined),
  ];

  Future<void> _changeTheme(BuildContext context, ThemePreference mode) async {
    final settings = context.read<AppSettingsViewModel>();
    final saved = await settings.setTheme(mode);
    if (!saved && context.mounted && settings.errorMessage != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(settings.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final settings = context.watch<AppSettingsViewModel>();
    final overview = context.watch<OverviewViewModel>();
    return AppPage(
      title: 'Mi perfil',
      children: [
        _ProfileHeader(
          alias: settings.alias,
          level: overview.data?.level.label ?? 'Cargando',
          onEdit: () => showAliasDialog(context),
        ),
        const SizedBox(height: AppSpacing.md),
        LocalState(
          vm: overview,
          builder: (stats) => Column(
            children: [
              LinearProgressIndicator(
                value: stats.levelProgress,
                semanticsLabel: 'Progreso de nivel',
              ),
              Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      icon: Icons.local_fire_department_outlined,
                      value: stats.streakDays == 1
                          ? '1 día'
                          : '${stats.streakDays} días',
                      label: 'Racha de reciclaje',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _StatTile(
                      icon: Icons.emoji_events_outlined,
                      value: '${stats.badges.length}/6',
                      label: 'Insignias logradas',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SectionHeader(title: 'Apariencia'),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Tema de la app',
                style: TextStyle(color: palette.textMuted),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 8,
                children: [
                  for (final mode in ThemePreference.values)
                    ChoiceChip(
                      label: Text(switch (mode) {
                        ThemePreference.system => 'Sistema',
                        ThemePreference.light => 'Claro',
                        ThemePreference.dark => 'Oscuro',
                      }),
                      selected: settings.themePreference == mode,
                      onSelected: settings.isSaving
                          ? null
                          : (_) => _changeTheme(context, mode),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SectionHeader(title: 'Niveles'),
        AppCard(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Column(
            children: [
              for (final (index, level) in levels.indexed) ...[
                if (index > 0) const Divider(indent: 16, endIndent: 16),
                ListTile(
                  leading: Icon(level.icon, color: palette.brand),
                  title: Text(
                    level.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  trailing: Text(
                    '${level.points} pts',
                    style: TextStyle(color: palette.textMuted),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SectionHeader(title: 'Insignias'),
        LocalState(
          vm: overview,
          builder: (stats) => Column(
            children: [
              for (final badge in EcoBadge.values)
                ListTile(
                  leading: Icon(
                    stats.badges.contains(badge)
                        ? Icons.check_circle_outline
                        : Icons.lock_outline,
                  ),
                  title: Text(badgeLabel(badge)),
                  subtitle: Text(
                    stats.badges.contains(badge)
                        ? 'Lograda · demo local'
                        : 'Aún pendiente',
                  ),
                ),
            ],
          ),
        ),
        const SectionHeader(title: 'Historial local'),
        const RecentActivity(),
        const SectionHeader(title: 'Más'),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.leaderboard_outlined),
                title: const Text('Ranking de demostración'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoutes.ranking),
              ),
              const Divider(indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(Icons.inbox_outlined),
                title: const Text('Sugerencias locales'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoutes.suggestions),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Perfil local de demostración: no es una cuenta ni requiere '
          'contraseña. Tus datos se quedan en este dispositivo.',
          style: TextStyle(color: palette.textMuted, fontSize: 12),
        ),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.alias,
    required this.level,
    required this.onEdit,
  });

  final String alias;
  final String level;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final onCard = palette.onBrandStrong;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md + 4),
      decoration: BoxDecoration(
        color: palette.brandStrong,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius + 4),
      ),
      child: Row(
        children: [
          UserAvatar(alias: alias, radius: 28, inverted: true),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alias,
                  style: TextStyle(
                    color: onCard,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Nivel $level · alias local',
                  style: TextStyle(color: onCard.withValues(alpha: 0.85)),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Editar alias',
            onPressed: onEdit,
            color: onCard,
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
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
          IconBadge(icon: icon, size: 36),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          Text(label, style: TextStyle(color: palette.textMuted)),
        ],
      ),
    );
  }
}

String badgeLabel(EcoBadge badge) => switch (badge) {
  EcoBadge.firstRecord => 'Primer registro',
  EcoBadge.fiveDayStreak => 'Cinco días consecutivos',
  EcoBadge.twentyFivePet => '25 botellas PET',
  EcoBadge.explorer => 'Tres puntos distintos',
  EcoBadge.firstRedemption => 'Primer canje activo',
  EcoBadge.thirtyDayStreak => '30 días consecutivos',
};
