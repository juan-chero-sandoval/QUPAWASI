import 'package:shared_preferences/shared_preferences.dart';

import '../data/preferences/shared_preferences_repository.dart';
import '../data/preview/demo_record_preview_repository.dart';
import '../domain/repositories/preferences_repository.dart';
import '../domain/repositories/record_preview_repository.dart';

/// Punto único de composición. Las vistas reciben dependencias desde aquí
/// (vía Provider) y nunca abren almacenamiento por su cuenta.
///
/// F02: abrir aquí la base Drift de forma asíncrona y añadir sus
/// repositorios (`RecordsRepository`, `PointsRepository`, ...). F03 sustituye
/// [recordPreviewRepository] por un adaptador sobre `RecordsRepository`.
class AppDependencies {
  const AppDependencies({
    required this.preferencesRepository,
    required this.recordPreviewRepository,
  });

  final PreferencesRepository preferencesRepository;
  final RecordPreviewRepository recordPreviewRepository;

  static Future<AppDependencies> create() async {
    return AppDependencies(
      preferencesRepository: SharedPreferencesRepository(
        SharedPreferencesAsync(),
      ),
      recordPreviewRepository: const DemoRecordPreviewRepository(),
    );
  }
}
