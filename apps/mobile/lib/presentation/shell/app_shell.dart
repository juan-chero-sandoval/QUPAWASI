import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_palette.dart';

/// Barra inferior con cinco destinos; cada pestaña conserva su propia pila.
///
/// Back de Android: primero vuelve dentro de la pestaña; en la raíz de una
/// pestaña distinta de Inicio regresa a Inicio; en Inicio cierra la app.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  static const List<NavigationDestination> destinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Inicio',
    ),
    NavigationDestination(
      icon: Icon(Icons.recycling_outlined),
      selectedIcon: Icon(Icons.recycling),
      label: 'Reciclar',
    ),
    NavigationDestination(
      icon: Icon(Icons.place_outlined),
      selectedIcon: Icon(Icons.place),
      label: 'Mapa',
    ),
    NavigationDestination(
      icon: Icon(Icons.card_giftcard_outlined),
      selectedIcon: Icon(Icons.card_giftcard),
      label: 'Premios',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: 'Perfil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: shell.currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) shell.goBranch(0);
      },
      child: Scaffold(
        body: shell,
        bottomNavigationBar: DecoratedBox(
          decoration: BoxDecoration(
            color: AppPalette.of(context).surface,
            border: Border(
              top: BorderSide(color: AppPalette.of(context).border),
            ),
          ),
          child: NavigationBar(
            selectedIndex: shell.currentIndex,
            destinations: destinations,
            // Tocar la pestaña activa vuelve a su pantalla raíz.
            onDestinationSelected: (index) => shell.goBranch(
              index,
              initialLocation: index == shell.currentIndex,
            ),
          ),
        ),
      ),
    );
  }
}
