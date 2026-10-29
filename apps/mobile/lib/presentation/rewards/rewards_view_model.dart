import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/reward.dart';
import '../../domain/repositories/preferences_repository.dart';
import '../../domain/usecases/rewards_use_cases.dart';
import '../common/local_stream_view_model.dart';

class RewardsViewModel extends ChangeNotifier {
  RewardsViewModel(this._rewards, this._preferences) {
    catalog = LocalStreamViewModel(() => _rewards.watchCatalog());
    history = LocalStreamViewModel(_rewards.watchRedemptions);
    restore();
  }
  final RewardsUseCases _rewards;
  final PreferencesRepository _preferences;
  late final LocalStreamViewModel<List<Reward>> catalog;
  late final LocalStreamViewModel<List<Redemption>> history;
  PendingRedemption? pending;
  bool busy = true;
  bool ready = false;
  bool _disposed = false;
  String? message;
  RewardCategory? category;
  List<Reward> get filtered => List.unmodifiable(
    (catalog.data ?? []).where(
      (r) => category == null || r.category == category,
    ),
  );
  void filter(RewardCategory? value) {
    category = value;
    notifyListeners();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> restore() async {
    busy = true;
    message = null;
    _notify();
    try {
      pending = await _preferences.loadPendingRedemption();
      ready = true;
    } catch (_) {
      message =
          'No se pudo recuperar la confirmación. Reintenta antes de canjear.';
    } finally {
      busy = false;
      _notify();
    }
  }

  Future<void> redeem(String rewardId) async {
    if (busy || !ready || (pending != null && pending!.rewardId != rewardId)) {
      return;
    }
    busy = true;
    message = null;
    _notify();
    try {
      pending ??= PendingRedemption(rewardId, const Uuid().v4());
      // Persist before the transaction; a crash at either boundary is retryable.
      await _preferences.setPendingRedemption(pending);
      final result = await _rewards.redeem(rewardId, pending!.operationId);
      await _preferences.setPendingRedemption(null);
      pending = null;
      message = result.isActive
          ? 'Canje simulado guardado. No tiene validez comercial.'
          : 'Este canje ya estaba cancelado; no se volvió a descontar.';
    } catch (error) {
      message = localMessage(error);
    } finally {
      busy = false;
      _notify();
    }
  }

  /// Explicitly abandons a retry after the user has reviewed local history.
  Future<void> dismissPending() async {
    if (busy) return;
    busy = true;
    _notify();
    try {
      await _preferences.setPendingRedemption(null);
      pending = null;
      message =
          'Confirmación cerrada. Los canjes guardados siguen en el historial.';
    } catch (error) {
      message = localMessage(error);
    } finally {
      busy = false;
      _notify();
    }
  }

  Future<void> cancel(String id) async {
    if (busy) return;
    busy = true;
    _notify();
    try {
      await _rewards.cancel(id);
      message = 'Canje simulado cancelado.';
    } catch (error) {
      message = localMessage(error);
    } finally {
      busy = false;
      _notify();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    catalog.dispose();
    history.dispose();
    super.dispose();
  }
}
