import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../presentation/settings/app_settings_view_model.dart';
import 'dependencies.dart';
import 'router.dart';
import 'routes.dart';

class QupaWasiApp extends StatefulWidget {
  const QupaWasiApp({
    super.key,
    required this.dependencies,
    required this.settings,
    this.initialLocation = AppRoutes.home,
  });

  final AppDependencies dependencies;

  /// Debe llegar ya cargado ([AppSettingsViewModel.load]) para decidir
  /// bienvenida o inicio sin parpadeo.
  final AppSettingsViewModel settings;
  final String initialLocation;

  @override
  State<QupaWasiApp> createState() => _QupaWasiAppState();
}

class _QupaWasiAppState extends State<QupaWasiApp> {
  late final GoRouter _router = createRouter(
    settings: widget.settings,
    initialLocation: widget.initialLocation,
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppDependencies>.value(value: widget.dependencies),
        ChangeNotifierProvider<AppSettingsViewModel>.value(
          value: widget.settings,
        ),
      ],
      child: ListenableBuilder(
        listenable: widget.settings,
        builder: (context, _) => MaterialApp.router(
          title: "Q'UPA WASI",
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: widget.settings.themeMode,
          locale: const Locale('es'),
          supportedLocales: const [Locale('es'), Locale('en')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          routerConfig: _router,
        ),
      ),
    );
  }
}
