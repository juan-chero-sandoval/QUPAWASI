import 'package:shared_preferences/shared_preferences.dart';

import '../data/preferences/shared_preferences_repository.dart';
import '../domain/repositories/preferences_repository.dart';
import 'local_services.dart';

/// Punto único de composición. Las vistas reciben dependencias desde aquí
/// (vía Provider) y nunca abren almacenamiento por su cuenta.
///
/// F02 abre SQLite en [create] y expone los casos de uso en [local]. Desde F03
/// las pantallas de reciclaje leen y escriben solo mediante [local]; ya no hay
/// datos de preview ni alternativa en memoria.
class AppDependencies {
  const AppDependencies({
    required this.preferencesRepository,
    required this.local,
  });

  final PreferencesRepository preferencesRepository;
  final LocalServices local;

  Future<void> close() => local.close();

  static Future<AppDependencies> create() async {
    return AppDependencies(
      preferencesRepository: SharedPreferencesRepository(
        SharedPreferencesAsync(),
      ),
      local: await LocalServices.open(),
    );
  }
}
