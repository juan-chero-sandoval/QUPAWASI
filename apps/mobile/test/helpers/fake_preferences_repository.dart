import 'dart:async';

import 'package:qupa_wasi/domain/entities/app_preferences.dart';
import 'package:qupa_wasi/domain/repositories/preferences_repository.dart';

/// Doble de prueba controlado para simular fallos y esperas.
class FakePreferencesRepository implements PreferencesRepository {
  FakePreferencesRepository({
    AppPreferences initial = AppPreferences.defaults,
    this.failLoad = false,
    this.failWrites = false,
    this.pendingLoad,
  }) : _stored = initial;

  AppPreferences _stored;
  final bool failLoad;
  final bool failWrites;
  final Completer<AppPreferences>? pendingLoad;
  int writes = 0;

  @override
  Future<AppPreferences> loadPreferences() async {
    if (pendingLoad != null) return pendingLoad!.future;
    if (failLoad) throw const PreferencesException('lectura simulada fallida');
    return _stored;
  }

  @override
  Future<void> setTheme(ThemePreference mode) =>
      _write(_stored.copyWith(themePreference: mode));

  @override
  Future<void> setAlias(String alias) =>
      _write(_stored.copyWith(alias: LocalAlias.normalize(alias)));

  @override
  Future<void> completeOnboarding() =>
      _write(_stored.copyWith(onboardingCompleted: true));

  Future<void> _write(AppPreferences next) async {
    if (failWrites) {
      throw const PreferencesException('escritura simulada fallida');
    }
    writes++;
    _stored = next;
  }
}
