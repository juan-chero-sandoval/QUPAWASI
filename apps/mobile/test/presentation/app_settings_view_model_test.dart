import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qupa_wasi/domain/entities/app_preferences.dart';
import 'package:qupa_wasi/presentation/settings/app_settings_view_model.dart';

import '../helpers/fake_preferences_repository.dart';

void main() {
  test('load aplica las preferencias guardadas', () async {
    final repository = FakePreferencesRepository(
      initial: const AppPreferences(
        themePreference: ThemePreference.dark,
        onboardingCompleted: true,
        alias: 'Eco',
      ),
    );
    final viewModel = AppSettingsViewModel(repository);

    await viewModel.load();

    expect(viewModel.isLoaded, isTrue);
    expect(viewModel.themeMode, ThemeMode.dark);
    expect(viewModel.onboardingCompleted, isTrue);
    expect(viewModel.alias, 'Eco');
  });

  test('si la lectura falla arranca con valores iniciales y avisa', () async {
    final viewModel = AppSettingsViewModel(
      FakePreferencesRepository(failLoad: true),
    );

    await viewModel.load();

    expect(viewModel.isLoaded, isTrue);
    expect(viewModel.preferences, AppPreferences.defaults);
    expect(viewModel.errorMessage, isNotNull);
  });

  test('si la lectura no responde, no espera indefinidamente', () async {
    final viewModel = AppSettingsViewModel(
      FakePreferencesRepository(pendingLoad: Completer<AppPreferences>()),
    );

    await viewModel.load(timeout: const Duration(milliseconds: 10));

    expect(viewModel.isLoaded, isTrue);
    expect(viewModel.onboardingCompleted, isFalse);
  });

  test('alias inválido devuelve error sin escribir', () async {
    final repository = FakePreferencesRepository();
    final viewModel = AppSettingsViewModel(repository);

    final error = await viewModel.setAlias(' ');

    expect(error, isNotNull);
    expect(repository.writes, 0);
    expect(viewModel.alias, LocalAlias.defaultValue);
  });

  test('una escritura fallida no cambia el estado visible', () async {
    final viewModel = AppSettingsViewModel(
      FakePreferencesRepository(failWrites: true),
    );

    final saved = await viewModel.setTheme(ThemePreference.dark);

    expect(saved, isFalse);
    expect(viewModel.themePreference, ThemePreference.system);
    expect(viewModel.errorMessage, isNotNull);
    expect(viewModel.isSaving, isFalse);
  });
}
