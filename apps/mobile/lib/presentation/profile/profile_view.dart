import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_page.dart';
import '../../core/widgets/state_message.dart';
import '../../domain/entities/app_preferences.dart';
import '../common/user_avatar.dart';
import '../settings/app_settings_view_model.dart';
import 'alias_dialog.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  /// Niveles por EcoPuntos ganados (docs/CONTRATOS.md). Solo se listan;
  /// el cálculo del nivel actual llega con `DemoScoringPolicy` en F02.
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
    return AppPage(
      title: 'Mi perfil',
      children: [
        _ProfileHeader(
          alias: settings.alias,
          onEdit: () => showAliasDialog(context),
        ),
        const SizedBox(height: AppSpacing.md),
        const Row(
          children: [
            Expanded(
              child: _StatTile(
                icon: Icons.local_fire_department_outlined,
                value: '0 días',
                label: 'Racha de reciclaje',
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _StatTile(
                icon: Icons.emoji_events_outlined,
                value: '0/6',
                label: 'Insignias logradas',
              ),
            ),
          ],
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
              SegmentedButton<ThemePreference>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: ThemePreference.system,
                    icon: Icon(Icons.brightness_auto_outlined),
                    label: Text('Sistema'),
                  ),
                  ButtonSegment(
                    value: ThemePreference.light,
                    icon: Icon(Icons.light_mode_outlined),
                    label: Text('Claro'),
                  ),
                  ButtonSegment(
                    value: ThemePreference.dark,
                    icon: Icon(Icons.dark_mode_outlined),
                    label: Text('Oscuro'),
                  ),
                ],
                selected: {settings.themePreference},
                onSelectionChanged: settings.isSaving
                    ? null
                    : (selection) => _changeTheme(context, selection.first),
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
        const StateMessage.inPreparation(
          message:
              'Las insignias se calcularán desde tus registros guardados '
              '(fases F02–F04).',
        ),
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
  const _ProfileHeader({required this.alias, required this.onEdit});

  final String alias;
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
                  'Nivel Semilla · alias local',
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
