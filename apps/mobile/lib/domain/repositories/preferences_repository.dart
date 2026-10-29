import '../entities/app_preferences.dart';

/// Contrato de preferencias simples (tema, onboarding y alias local).
///
/// No sustituye a SQLite: los registros de reciclaje viven en la base (F02).
abstract interface class PreferencesRepository {
  Future<AppPreferences> loadPreferences();

  Future<void> setTheme(ThemePreference mode);

  /// Lanza [PreferencesException] si el alias no es válido.
  Future<void> setAlias(String alias);

  Future<void> completeOnboarding();

  /// One recoverable confirmation, not the redemption ledger (which is SQLite).
  Future<PendingRedemption?> loadPendingRedemption();
  Future<void> setPendingRedemption(PendingRedemption? pending);
}

class PendingRedemption {
  const PendingRedemption(this.rewardId, this.operationId);
  final String rewardId;
  final String operationId;
}
