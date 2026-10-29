import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/mascot.dart';
import '../../core/widgets/prototype_banner.dart';
import '../settings/app_settings_view_model.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  static const List<({IconData icon, String title, String body})> steps = [
    (
      icon: Icons.place_outlined,
      title: 'Encuentra un punto',
      body: 'Consulta los tachos del catálogo y encuentra el más cercano.',
    ),
    (
      icon: Icons.local_drink_outlined,
      title: 'Registra tu reciclaje',
      body: 'Escanea el QR del tacho: material y cantidad se cargan automáticamente.',
    ),
    (
      icon: Icons.card_giftcard_outlined,
      title: 'Suma y canjea',
      body: 'Acumula EcoPuntos simulados y prueba canjes de demostración.',
    ),
  ];

  Future<void> _start(BuildContext context) async {
    final settings = context.read<AppSettingsViewModel>();
    final saved = await settings.completeOnboarding();
    if (!context.mounted) return;
    if (saved) {
      context.go(AppRoutes.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            settings.errorMessage ?? 'No se pudo guardar. Inténtalo de nuevo.',
          ),
        ),
      );
    }
  }

  void _showPrivacy(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cómo cuidamos tus datos'),
        content: const Text(
          'En esta versión todo se guarda solo en este dispositivo: tus '
          'registros, tu alias de demostración y tus preferencias. No hay '
          'cuenta, contraseña ni envío a servidores. Los EcoPuntos y canjes '
          'son simulados y no tienen valor comercial.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    final isSaving = context.select<AppSettingsViewModel, bool>(
      (vm) => vm.isSaving,
    );
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              key: const PageStorageKey<String>('welcome-scroll'),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.md,
                AppSpacing.screen,
                AppSpacing.xl,
              ),
              children: [
                Text(
                  "Q'UPA WASI UNP · Universidad Nacional de Piura",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: palette.brand,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [palette.iconBadge, palette.background],
                      ),
                    ),
                    child: const Mascot(size: 112),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Recicla. Suma puntos.',
                  textAlign: TextAlign.center,
                  style: textTheme.headlineLarge,
                ),
                Text(
                  'Gana recompensas.',
                  textAlign: TextAlign.center,
                  style: textTheme.headlineLarge?.copyWith(
                    color: palette.brand,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Una forma simple de practicar el reciclaje en la UNP.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: palette.textMuted),
                ),
                const SizedBox(height: AppSpacing.lg),
                for (final (index, step) in steps.indexed) ...[
                  AppCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconBadge(icon: step.icon),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '0${index + 1}  ',
                                      style: TextStyle(color: palette.brand),
                                    ),
                                    TextSpan(text: step.title),
                                  ],
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                step.body,
                                style: TextStyle(color: palette.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                const SizedBox(height: AppSpacing.md),
                FilledButton.icon(
                  onPressed: isSaving ? null : () => _start(context),
                  iconAlignment: IconAlignment.end,
                  icon: isSaving
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.arrow_forward),
                  label: const Text('Empezar'),
                ),
                const SizedBox(height: AppSpacing.md),
                const PrototypeBanner(),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Tus datos se guardan solo en este dispositivo. Sin cuenta ni '
                  'contraseña.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: palette.textMuted, fontSize: 13),
                ),
                TextButton(
                  onPressed: () => _showPrivacy(context),
                  child: const Text('Cómo cuidamos tus datos'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
