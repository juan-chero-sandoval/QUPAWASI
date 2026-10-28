import 'package:flutter_test/flutter_test.dart';
import 'package:qupa_wasi/data/preferences/shared_preferences_repository.dart';
import 'package:qupa_wasi/domain/entities/app_preferences.dart';
import 'package:qupa_wasi/domain/repositories/preferences_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

/// Crea un repositorio nuevo sobre el mismo almacén, como al reabrir la app.
SharedPreferencesRepository rebuildRepository() =>
    SharedPreferencesRepository(SharedPreferencesAsync());

void main() {
  test(
    'confirmación de canje persiste al reconstruir y se limpia explícitamente',
    () async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
      await rebuildRepository().setPendingRedemption(
        const PendingRedemption('reward', 'operation'),
      );
      final restored = await rebuildRepository().loadPendingRedemption();
      expect(restored!.rewardId, 'reward');
      expect(restored.operationId, 'operation');
      await rebuildRepository().setPendingRedemption(null);
      expect(await rebuildRepository().loadPendingRedemption(), isNull);
    },
  );
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test('sin datos devuelve los valores de primera instalación', () async {
    final prefs = await rebuildRepository().loadPreferences();

    expect(prefs, AppPreferences.defaults);
  });

  test(
    'tema, alias y onboarding sobreviven a reconstruir el repositorio',
    () async {
      final first = rebuildRepository();
      await first.setTheme(ThemePreference.dark);
      await first.setAlias('  Eco Tester  ');
      await first.completeOnboarding();

      final reopened = await rebuildRepository().loadPreferences();

      expect(reopened.themePreference, ThemePreference.dark);
      expect(reopened.alias, 'Eco Tester');
      expect(reopened.onboardingCompleted, isTrue);
    },
  );

  test('usa claves versionadas qupawasi.v1.*', () async {
    final repository = rebuildRepository();
    await repository.setTheme(ThemePreference.light);
    await repository.setAlias('Eco');
    await repository.completeOnboarding();

    final keys = await SharedPreferencesAsync().getKeys();

    expect(keys, {
      'qupawasi.v1.themeMode',
      'qupawasi.v1.alias',
      'qupawasi.v1.onboardingCompleted',
    });
  });

  test('alias inválido se rechaza y no sobrescribe el anterior', () async {
    final repository = rebuildRepository();
    await repository.setAlias('Eco');

    await expectLater(
      repository.setAlias(' x '),
      throwsA(isA<PreferencesException>()),
    );

    expect((await rebuildRepository().loadPreferences()).alias, 'Eco');
  });

  test('valores corruptos o de otro tipo vuelven a valores seguros', () async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData({
          SharedPreferencesRepository.themeKey: 'sepia',
          SharedPreferencesRepository.aliasKey: 'x',
          SharedPreferencesRepository.onboardingKey: 'true',
        });

    final prefs = await rebuildRepository().loadPreferences();

    expect(prefs, AppPreferences.defaults);
  });
}
