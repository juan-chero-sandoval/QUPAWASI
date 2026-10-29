import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'simulation_chip.dart';

/// Estructura común de pantalla: encabezado con el rótulo de simulación y
/// contenido con scroll dentro de SafeArea. Sin alturas fijas para texto
/// ampliado.
class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.title,
    required this.children,
    this.actions,
    this.showBack = false,
    this.floatingActionButton,
    this.bottomAction,
  });

  final String title;
  final List<Widget> children;
  final List<Widget>? actions;

  /// Muestra botón volver aunque la pantalla sea raíz de una pestaña.
  final bool showBack;
  final Widget? floatingActionButton;

  /// Acción principal fija abajo: siempre visible, sin tener que desplazarse
  /// (también en pantallas pequeñas o con texto ampliado).
  final Widget? bottomAction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight:
            64 * (MediaQuery.textScalerOf(context).scale(22) / 22).clamp(1, 2),
        title: Text(
          title,
          maxLines: 2,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        actions: [
          ...?actions,
          const SimulationChip(),
          const SizedBox(width: AppSpacing.screen - AppSpacing.xs),
        ],
        automaticallyImplyLeading: showBack,
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomAction == null
          ? null
          : SafeArea(
              top: false,
              child: Center(
                heightFactor: 1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppSpacing.contentWidth,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screen,
                      AppSpacing.sm,
                      AppSpacing.screen,
                      AppSpacing.md,
                    ),
                    // Ancho completo: el botón principal no se encoge al centro.
                    child: SizedBox(
                      width: double.infinity,
                      child: bottomAction,
                    ),
                  ),
                ),
              ),
            ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.contentWidth,
            ),
            child: ListView(
              // Clave por título: cada pantalla conserva solo su propio scroll.
              key: PageStorageKey<String>('page-$title'),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.sm,
                AppSpacing.screen,
                AppSpacing.xl,
              ),
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}
