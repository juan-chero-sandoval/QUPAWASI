import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../presentation/common/connection_view_model.dart';
import '../theme/app_palette.dart';
import '../theme/app_theme.dart';

/// Rótulo compacto de simulación para la cabecera de cada pantalla
/// (AGENTS.md: toda pantalla indica que EcoPuntos y canjes son simulados).
/// Al tocarlo explica por qué. Muestra "Sin conexión" solo si no hay red.
class SimulationChip extends StatelessWidget {
  const SimulationChip({super.key});

  static const String message = 'EcoPuntos y canjes simulados';

  void _explain(BuildContext context, bool offline) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Prototipo sin servidor: nadie verifica el depósito físico, '
                'así que los puntos no tienen valor y los canjes no entregan '
                'productos ni dinero. Tus datos se guardan solo en este '
                'dispositivo.',
              ),
              if (offline) ...[
                const SizedBox(height: AppSpacing.sm),
                const Text('Ahora estás sin conexión; la app funciona igual.'),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final offline =
        context.watch<ConnectionViewModel?>()?.state == InternetState.offline;
    return Semantics(
      button: true,
      label: offline ? 'Sin conexión · $message' : message,
      excludeSemantics: true,
      child: Tooltip(
        message: offline ? 'Sin conexión · $message' : message,
        child: InkWell(
          onTap: () => _explain(context, offline),
          customBorder: const StadiumBorder(),
          // Área táctil de 48 dp aunque el chip se vea más compacto.
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Center(
              widthFactor: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: ShapeDecoration(
                  color: palette.notice,
                  shape: StadiumBorder(side: BorderSide(color: palette.border)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      offline ? Icons.wifi_off_rounded : Icons.science_outlined,
                      size: 16,
                      color: palette.onNotice,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Simulado',
                      style: TextStyle(
                        color: palette.onNotice,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
