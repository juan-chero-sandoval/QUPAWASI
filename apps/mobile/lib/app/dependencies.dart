import 'package:shared_preferences/shared_preferences.dart';

import '../data/preferences/shared_preferences_repository.dart';
import '../data/preview/demo_record_preview_repository.dart';
import '../domain/repositories/preferences_repository.dart';
import '../domain/repositories/record_preview_repository.dart';
import 'local_services.dart';

/// Punto único de composición. Las vistas reciben dependencias desde aquí
/// (vía Provider) y nunca abren almacenamiento por su cuenta.
///
/// F02 abre SQLite en [create] y expone casos de uso mediante [local]. F03 sustituye
/// [recordPreviewRepository] por un adaptador sobre `RecordsRepository`.
class AppDependencies {
  const AppDependencies({
    required this.preferencesRepository,
    required this.recordPreviewRepository,
    this.localServices,
  });

  final PreferencesRepository preferencesRepository;
  final RecordPreviewRepository recordPreviewRepository;
  final LocalServices? localServices;

  /// Solo los tests de preview F01 pueden omitir servicios locales.
  /// Las pantallas F03/F04 deben inyectarlos; nunca hay fallback a memoria.
  LocalServices get local =>
      localServices ??
      (throw StateError(
        'Inyecta LocalServices para usar persistencia SQLite.',
      ));

  Future<void> close() async {
    await localServices?.close();
  }

  static Future<AppDependencies> create() async {
    return AppDependencies(
      preferencesRepository: SharedPreferencesRepository(
        SharedPreferencesAsync(),
      ),
      recordPreviewRepository: const DemoRecordPreviewRepository(),
      localServices: await LocalServices.open(),
    );
  }
}
