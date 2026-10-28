import 'package:flutter/material.dart';

import '../../core/widgets/app_page.dart';
import '../../core/widgets/state_message.dart';

/// `/ranking`: solo datos de demostración, nunca estudiantes reales (F04).
class RankingView extends StatelessWidget {
  const RankingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPage(
      title: 'Ranking',
      showBack: true,
      children: [
        StateMessage.inPreparation(
          message:
              'Ranking de demostración rotulado, sin estudiantes reales. '
              'Se implementa en F04.',
        ),
      ],
    );
  }
}

/// `/suggestions`: sugerencias guardadas solo en el dispositivo (F04).
class SuggestionsView extends StatelessWidget {
  const SuggestionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPage(
      title: 'Sugerencias',
      showBack: true,
      children: [
        StateMessage.inPreparation(
          message:
              'Podrás escribir sugerencias que se guardan solo en este '
              'dispositivo; no se envían a nadie. Se implementa en F04.',
        ),
      ],
    );
  }
}
