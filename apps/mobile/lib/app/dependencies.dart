import 'package:shared_preferences/shared_preferences.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../data/preferences/shared_preferences_repository.dart';
import '../domain/repositories/preferences_repository.dart';
import 'local_services.dart';
import '../data/location/device_location.dart';
import '../domain/entities/geo_position.dart';

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
    this.internetChanges,
    this.checkInternet,
    this.scanQr,
    this.locate,
  });

  final PreferencesRepository preferencesRepository;
  final LocalServices local;
  final Stream<bool>? internetChanges;
  final Future<bool> Function()? checkInternet;

  /// Adaptador opcional para automatización sin una cámara física.
  final Future<String?> Function()? scanQr;
  final Future<GeoPosition> Function()? locate;

  Future<void> close() => local.close();

  static Future<AppDependencies> create() async {
    final internet = InternetConnection();
    return AppDependencies(
      internetChanges: internet.onStatusChange.map(
        (s) => s == InternetStatus.connected,
      ),
      checkInternet: () => internet.hasInternetAccess,
      locate: locateDevice,
      preferencesRepository: SharedPreferencesRepository(
        SharedPreferencesAsync(),
      ),
      local: await LocalServices.open(),
    );
  }
}
