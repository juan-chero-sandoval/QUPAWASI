import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_page.dart';
import '../../data/preferences/shared_preferences_repository.dart';
import '../../data/remote/supabase_account_repository.dart';
import '../common/connection_view_model.dart';
import '../settings/app_settings_view_model.dart';
import 'connected_account_view_model.dart';
import 'connected_pages.dart';
import 'connected_sign_in.dart';

class ConnectedApp extends StatelessWidget {
  const ConnectedApp._({required this.client, required this.settings});

  final SupabaseClient client;
  final AppSettingsViewModel settings;

  static Future<Widget> configured() async {
    const url = String.fromEnvironment('SUPABASE_URL');
    const key = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
    final uri = Uri.tryParse(url);
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host.isEmpty ||
        !key.startsWith('sb_publishable_')) {
      return const _ConfigurationError(
        'Faltan los datos de conexión con Supabase.',
      );
    }

    try {
      final supabase = await Supabase.initialize(
        url: url,
        publishableKey: key,
        debug: false,
        authOptions: FlutterAuthClientOptions(
          localStorage: _SecureSession('qupawasi.auth.${uri.host}'),
        ),
      );
      final settings = AppSettingsViewModel(
        SharedPreferencesRepository(SharedPreferencesAsync()),
      );
      await settings.load();
      return ConnectedApp._(client: supabase.client, settings: settings);
    } catch (_) {
      return const _ConfigurationError(
        'No se pudo iniciar la cuenta. Vuelve a abrir la app.',
      );
    }
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<AuthState>(
    stream: client.auth.onAuthStateChange,
    builder: (context, snapshot) {
      final id = client.auth.currentUser?.id;
      return ListenableBuilder(
        listenable: settings,
        builder: (context, _) => MaterialApp(
          key: ValueKey(id),
          title: 'Q’UPA WASI',
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: settings.themeMode,
          locale: const Locale('es'),
          supportedLocales: const [Locale('es'), Locale('en')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          debugShowCheckedModeBanner: false,
          home: id == null
              ? ConnectedSignIn(auth: client.auth)
              : MultiProvider(
                  providers: [
                    ChangeNotifierProvider(
                      create: (_) {
                        final internet = InternetConnection();
                        return ConnectionViewModel(
                          changes: internet.onStatusChange.map(
                            (status) => status == InternetStatus.connected,
                          ),
                          check: () => internet.hasInternetAccess,
                        );
                      },
                    ),
                    ChangeNotifierProvider(
                      create: (_) {
                        final viewModel = ConnectedAccountViewModel(
                          SupabaseAccountRepository(client, id),
                        );
                        unawaited(viewModel.refresh());
                        return viewModel;
                      },
                    ),
                  ],
                  child: ConnectedPages(
                    settings: settings,
                    onSignOut: client.auth.signOut,
                  ),
                ),
        ),
      );
    },
  );
}

class _SecureSession extends LocalStorage {
  const _SecureSession(this.key);

  final String key;
  static const _storage = FlutterSecureStorage();

  @override
  Future<void> initialize() async {}

  @override
  Future<String?> accessToken() => _storage.read(key: key);

  @override
  Future<bool> hasAccessToken() => _storage.containsKey(key: key);

  @override
  Future<void> persistSession(String persistSessionString) =>
      _storage.write(key: key, value: persistSessionString);

  @override
  Future<void> removePersistedSession() => _storage.delete(key: key);
}

class _ConfigurationError extends StatelessWidget {
  const _ConfigurationError(this.message);
  final String message;

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: AppTheme.light(),
    debugShowCheckedModeBanner: false,
    home: AppPage(
      title: 'Q’UPA WASI',
      simulated: false,
      children: [Text(message)],
    ),
  );
}
