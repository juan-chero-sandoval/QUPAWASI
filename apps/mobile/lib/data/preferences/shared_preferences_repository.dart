import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/app_preferences.dart';
import '../../domain/repositories/preferences_repository.dart';

/// Adaptador de [PreferencesRepository] sobre Shared Preferences asíncronas.
class SharedPreferencesRepository implements PreferencesRepository {
  SharedPreferencesRepository(this._preferences);

  final SharedPreferencesAsync _preferences;

  // Claves versionadas según docs/CONTRATOS.md.
  static const String themeKey = 'qupawasi.v1.themeMode';
  static const String onboardingKey = 'qupawasi.v1.onboardingCompleted';
  static const String aliasKey = 'qupawasi.v1.alias';
  static const pendingKey = 'qupawasi.v1.pendingRedemption';

  @override
  Future<PendingRedemption?> loadPendingRedemption() async {
    final value = await _preferences.getStringList(pendingKey);
    if (value == null) return null;
    if (value.length != 2) {
      throw const PreferencesException('Confirmación local inválida.');
    }
    return PendingRedemption(value[0], value[1]);
  }

  @override
  Future<void> setPendingRedemption(PendingRedemption? pending) => _write(
    () => pending == null
        ? _preferences.remove(pendingKey)
        : _preferences.setStringList(pendingKey, [
            pending.rewardId,
            pending.operationId,
          ]),
  );

  @override
  Future<AppPreferences> loadPreferences() async {
    try {
      final values = await _preferences.getAll(
        allowList: {themeKey, onboardingKey, aliasKey},
      );
      final storedAlias = values[aliasKey];
      final alias =
          storedAlias is String && LocalAlias.validate(storedAlias) == null
          ? LocalAlias.normalize(storedAlias)
          : LocalAlias.defaultValue;
      final onboarding = values[onboardingKey];
      final theme = values[themeKey];
      return AppPreferences(
        themePreference: ThemePreference.parse(theme is String ? theme : null),
        onboardingCompleted: onboarding is bool && onboarding,
        alias: alias,
      );
    } on Exception catch (error) {
      throw PreferencesException(
        'No se pudieron leer las preferencias: $error',
      );
    }
  }

  @override
  Future<void> setTheme(ThemePreference mode) =>
      _write(() => _preferences.setString(themeKey, mode.name));

  @override
  Future<void> setAlias(String alias) {
    final error = LocalAlias.validate(alias);
    if (error != null) {
      return Future.error(PreferencesException(error));
    }
    return _write(
      () => _preferences.setString(aliasKey, LocalAlias.normalize(alias)),
    );
  }

  @override
  Future<void> completeOnboarding() =>
      _write(() => _preferences.setBool(onboardingKey, true));

  Future<void> _write(Future<void> Function() action) async {
    try {
      await action();
    } on Exception catch (error) {
      throw PreferencesException('No se pudo guardar la preferencia: $error');
    }
  }
}
