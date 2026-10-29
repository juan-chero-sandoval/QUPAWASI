import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../presentation/common/connection_view_model.dart';

import '../theme/app_palette.dart';
import '../theme/app_theme.dart';

/// Aviso uniforme de simulación. Se muestra en todas las pantallas.
class PrototypeBanner extends StatelessWidget {
  const PrototypeBanner({super.key});

  static const String message = 'EcoPuntos y canjes simulados';

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final state =
        context.watch<ConnectionViewModel?>()?.state ?? InternetState.unknown;
    final label = state == InternetState.offline
        ? 'Sin conexión · $message'
        : message;
    return Semantics(
      container: true,
      label: label,
      excludeSemantics: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: palette.notice,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: palette.border),
        ),
        child: Row(
          children: [
            Icon(
              state == InternetState.offline
                  ? Icons.wifi_off_outlined
                  : Icons.info_outline,
              size: 16,
              color: palette.onNotice,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: palette.onNotice,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
