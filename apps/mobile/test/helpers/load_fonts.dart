import 'package:flutter/services.dart';

/// Métricas reales de las fuentes del APK en pruebas de layout/accesibilidad.
Future<void> loadProjectFonts() async {
  for (final (family, asset) in [
    ('Outfit', 'assets/fonts/outfit/outfit.ttf'),
    ('WorkSans', 'assets/fonts/worksans/worksans.ttf'),
  ]) {
    final loader = FontLoader(family)..addFont(rootBundle.load(asset));
    await loader.load();
  }
}
