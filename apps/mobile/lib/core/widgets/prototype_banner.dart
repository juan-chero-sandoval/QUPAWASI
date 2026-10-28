import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_theme.dart';

/// Aviso uniforme de simulación. Se muestra en todas las pantallas.
class PrototypeBanner extends StatelessWidget {
  const PrototypeBanner({super.key});

  static const String message =
      'Prototipo offline · EcoPuntos y canjes simulados';

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Semantics(
      container: true,
      label: message,
      excludeSemantics: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: palette.notice,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: palette.accent),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 18, color: palette.onNotice),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: palette.onNotice,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
