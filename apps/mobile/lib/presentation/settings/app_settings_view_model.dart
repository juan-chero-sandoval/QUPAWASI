import 'package:flutter/material.dart';

import '../../domain/entities/app_preferences.dart';
import '../../domain/repositories/preferences_repository.dart';

/// Estado global de preferencias: tema, onboarding y alias local.
///
/// Las vistas no tocan Shared Preferences; llaman a este ViewModel, que
/// actualiza la UI solo después de que el repositorio confirma la escritura.
class AppSettingsViewModel extends ChangeNotifier {
  AppSettingsViewModel(this._repository);

  final PreferencesRepository _repository;

  AppPreferences _preferences = AppPreferences.defaults;
  bool _isLoaded = false;
  bool _isSaving = false;
  String? _errorMessage;

  AppPreferences get preferences => _preferences;
  bool get isLoaded => _isLoaded;
  bool get isSaving => _isSaving;
  bool get onboardingCompleted => _preferences.onboardingCompleted;
  String get alias => _preferences.alias;
  ThemePreference get themePreference => _preferences.themePreference;
  bool get adminMode => _preferences.adminMode;

  /// Último error de lectura/escritura para mostrar al usuario.
  String? get errorMessage => _errorMessage;

  ThemeMode get themeMode => switch (_preferences.themePreference) {
    ThemePreference.system => ThemeMode.system,
    ThemePreference.light => ThemeMode.light,
    ThemePreference.dark => ThemeMode.dark,
  };

  /// Lee preferencias con un límite de tiempo: si falla o tarda, la app
  /// arranca con valores por defecto en lugar de quedarse esperando.
  Future<void> load({Duration timeout = const Duration(seconds: 3)}) async {
    try {
      _preferences = await _repository.loadPreferences().timeout(timeout);
      _errorMessage = null;
    } on Exception {
      _preferences = AppPreferences.defaults;
      _errorMessage = 'No se pudieron leer tus preferencias; se usan los valores iniciales.';
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<bool> setTheme(ThemePreference mode) => _save(
    () => _repository.setTheme(mode),
    _preferences.copyWith(themePreference: mode),
  );

  /// Devuelve el error de validación o `null` si se guardó.
  Future<String?> setAlias(String alias) async {
    final validation = LocalAlias.validate(alias);
    if (validation != null) return validation;
    final saved = await _save(
      () => _repository.setAlias(alias),
      _preferences.copyWith(alias: LocalAlias.normalize(alias)),
    );
    return saved ? null : _errorMessage;
  }

  Future<bool> setAdminMode(bool enabled) => _save(
    () => _repository.setAdminMode(enabled),
    _preferences.copyWith(adminMode: enabled),
  );

  Future<bool> completeOnboarding() => _save(
    _repository.completeOnboarding,
    _preferences.copyWith(onboardingCompleted: true),
  );

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> _save(Future<void> Function() write, AppPreferences next) async {
    if (_isSaving) return false;
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await write();
      _preferences = next;
      return true;
    } on PreferencesException catch (error) {
      _errorMessage = error.message;
      return false;
    } on Exception {
      _errorMessage = 'No se pudo guardar la preferencia. Inténtalo de nuevo.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
