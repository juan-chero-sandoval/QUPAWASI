import 'package:flutter_test/flutter_test.dart';
import 'package:qupa_wasi/domain/entities/app_preferences.dart';

void main() {
  group('ThemePreference.parse', () {
    test('reconoce los tres valores almacenados', () {
      expect(ThemePreference.parse('system'), ThemePreference.system);
      expect(ThemePreference.parse('light'), ThemePreference.light);
      expect(ThemePreference.parse('dark'), ThemePreference.dark);
    });

    test('un valor nulo o desconocido vuelve a system', () {
      expect(ThemePreference.parse(null), ThemePreference.system);
      expect(ThemePreference.parse('sepia'), ThemePreference.system);
    });
  });

  group('LocalAlias.validate', () {
    test('acepta 2..40 caracteres después de recortar espacios', () {
      expect(LocalAlias.validate('  Eco  '), isNull);
      expect(LocalAlias.validate('ab'), isNull);
      expect(LocalAlias.validate('a' * 40), isNull);
    });

    test('rechaza vacío, solo espacios, 1 carácter y más de 40', () {
      expect(LocalAlias.validate(null), isNotNull);
      expect(LocalAlias.validate(''), isNotNull);
      expect(LocalAlias.validate('     '), isNotNull);
      expect(LocalAlias.validate(' a '), isNotNull);
      expect(LocalAlias.validate('a' * 41), isNotNull);
    });
  });

  test('primera instalación: tema del sistema y onboarding pendiente', () {
    expect(AppPreferences.defaults.themePreference, ThemePreference.system);
    expect(AppPreferences.defaults.onboardingCompleted, isFalse);
    expect(LocalAlias.validate(AppPreferences.defaults.alias), isNull);
  });
}
