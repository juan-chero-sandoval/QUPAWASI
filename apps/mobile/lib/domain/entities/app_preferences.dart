/// Preferencias simples del dispositivo. No representan una sesión ni
/// contienen credenciales: en Unidad II todo es local.
enum ThemePreference {
  system,
  light,
  dark;

  /// Convierte el valor almacenado; un valor desconocido vuelve a `system`.
  static ThemePreference parse(String? raw) {
    for (final value in ThemePreference.values) {
      if (value.name == raw) return value;
    }
    return ThemePreference.system;
  }
}

class AppPreferences {
  const AppPreferences({
    required this.themePreference,
    required this.onboardingCompleted,
    required this.alias,
  });

  /// Valores de primera instalación.
  static const AppPreferences defaults = AppPreferences(
    themePreference: ThemePreference.system,
    onboardingCompleted: false,
    alias: LocalAlias.defaultValue,
  );

  final ThemePreference themePreference;
  final bool onboardingCompleted;
  final String alias;

  AppPreferences copyWith({
    ThemePreference? themePreference,
    bool? onboardingCompleted,
    String? alias,
  }) {
    return AppPreferences(
      themePreference: themePreference ?? this.themePreference,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      alias: alias ?? this.alias,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AppPreferences &&
      other.themePreference == themePreference &&
      other.onboardingCompleted == onboardingCompleted &&
      other.alias == alias;

  @override
  int get hashCode => Object.hash(themePreference, onboardingCompleted, alias);
}

/// Alias de demostración (2..40 caracteres tras trim). No es un nombre real.
abstract final class LocalAlias {
  static const String defaultValue = 'Reciclador UNP';
  static const int minLength = 2;
  static const int maxLength = 40;

  /// Devuelve el mensaje de error para el usuario o `null` si es válido.
  static String? validate(String? raw) {
    final value = raw?.trim() ?? '';
    if (value.length < minLength) {
      return 'El alias necesita al menos $minLength caracteres.';
    }
    if (value.length > maxLength) {
      return 'El alias admite como máximo $maxLength caracteres.';
    }
    return null;
  }

  static String normalize(String raw) => raw.trim();
}

/// Error tipado al leer o escribir preferencias.
class PreferencesException implements Exception {
  const PreferencesException(this.message);

  final String message;

  @override
  String toString() => 'PreferencesException: $message';
}
