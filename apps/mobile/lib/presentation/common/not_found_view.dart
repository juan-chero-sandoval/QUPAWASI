import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/widgets/app_page.dart';
import '../../core/widgets/state_message.dart';

/// Vista segura para rutas desconocidas: explica y ofrece volver.
class NotFoundView extends StatelessWidget {
  const NotFoundView({super.key, required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Página no encontrada',
      children: [
        StateMessage(
          icon: Icons.search_off,
          title: 'No encontramos esta página',
          message: 'La dirección "$location" no existe en la app.',
          actionLabel: 'Volver al inicio',
          onAction: () => context.go(AppRoutes.home),
        ),
      ],
    );
  }
}
