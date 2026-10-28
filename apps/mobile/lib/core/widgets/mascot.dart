import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

/// Mascota original simple construida con widgets (sin imágenes externas).
class Mascot extends StatelessWidget {
  const Mascot({super.key, this.size = 96});

  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    const ink = Color(0xFF16382E);
    final eye = size * 0.08;
    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size * 1.15,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              top: 0,
              child: Transform.rotate(
                angle: -0.5,
                child: Icon(Icons.eco, color: palette.brand, size: size * 0.3),
              ),
            ),
            Positioned(
              top: size * 0.2,
              child: Container(
                width: size * 0.72,
                height: size * 0.9,
                decoration: BoxDecoration(
                  color: palette.accent,
                  borderRadius: BorderRadius.circular(size * 0.36),
                  border: Border.all(color: ink, width: 2.5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _dot(eye, ink),
                        SizedBox(width: size * 0.16),
                        _dot(eye, ink),
                      ],
                    ),
                    SizedBox(height: size * 0.06),
                    Container(
                      width: size * 0.18,
                      height: size * 0.08,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: ink, width: 2.5),
                        ),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
