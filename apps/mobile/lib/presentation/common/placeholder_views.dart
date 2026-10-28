import 'package:flutter/material.dart';

import '../../core/widgets/app_page.dart';

/// Fictitious examples only; no automatic participation of the local profile.
class RankingView extends StatelessWidget {
  const RankingView({super.key});
  @override
  Widget build(BuildContext context) => const AppPage(
    title: 'Ranking',
    showBack: true,
    children: [
      Text('Ejemplo de ranking · datos simulados'),
      Text(
        'Aliases ficticios. Tu perfil no participa. No es un ranking en vivo.',
      ),
      ListTile(
        leading: Text('1'),
        title: Text('Colibrí Verde'),
        subtitle: Text('900 puntos de ejemplo'),
      ),
      ListTile(
        leading: Text('2'),
        title: Text('Ceibo Azul'),
        subtitle: Text('600 puntos de ejemplo'),
      ),
      ListTile(
        leading: Text('3'),
        title: Text('Semilla Dorada'),
        subtitle: Text('300 puntos de ejemplo'),
      ),
    ],
  );
}
