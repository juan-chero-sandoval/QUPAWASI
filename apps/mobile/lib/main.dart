import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'app/dependencies.dart';
import 'presentation/settings/app_settings_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dependencies = await AppDependencies.create();
  // Se leen las preferencias antes del primer frame (con límite de tiempo)
  // para abrir directamente bienvenida o inicio.
  final settings = AppSettingsViewModel(dependencies.preferencesRepository);
  await settings.load();
  runApp(QupaWasiApp(dependencies: dependencies, settings: settings));
}
