import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'prototype_banner.dart';

/// Estructura común de pantalla: encabezado, aviso de prototipo y contenido
/// con scroll dentro de SafeArea. Evita alturas fijas para texto ampliado.
class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.title,
    required this.children,
    this.actions,
    this.showBack = false,
    this.floatingActionButton,
  });

  final String title;
  final List<Widget> children;
  final List<Widget>? actions;

  /// Muestra botón volver aunque la pantalla sea raíz de una pestaña.
  final bool showBack;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
        automaticallyImplyLeading: showBack,
      ),
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        top: false,
        child: ListView(
          // Clave por título: cada pantalla conserva solo su propio scroll.
          key: PageStorageKey<String>('page-$title'),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen,
            AppSpacing.sm,
            AppSpacing.screen,
            AppSpacing.xl,
          ),
          children: [
            const PrototypeBanner(),
            const SizedBox(height: AppSpacing.md),
            ...children,
          ],
        ),
      ),
    );
  }
}
