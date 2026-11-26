import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../data/location/device_location.dart';
import '../../data/remote/supabase_account_repository.dart';
import '../../domain/entities/recycling_point.dart';
import '../../domain/errors/local_data_exception.dart';
import '../../domain/policies/nearest_point.dart';

class ConnectedAccountViewModel extends ChangeNotifier {
  ConnectedAccountViewModel(this._repository);

  final SupabaseAccountRepository _repository;
  AccountRow? profile;
  List<AccountRow> activity = [];
  List<AccountRow> rewards = [];
  List<AccountRow> redemptions = [];
  List<AccountRow> points = [];
  PendingReward? pendingReward;
  bool loading = false;
  bool working = false;
  bool moreActivity = false;
  bool moreRedemptions = false;
  bool _disposed = false;
  String? error;
  ({RecyclingPoint point, double meters})? nearest;

  Future<void> findNearest() => _run(() async {
    final candidates = points
        .map(
          (row) => RecyclingPoint(
            id: row['id'] as String,
            name: row['name'] as String,
            description: '',
            occupancy: 0,
            isDemo: false,
            latitude: (row['lat'] as num?)?.toDouble(),
            longitude: (row['lng'] as num?)?.toDouble(),
          ),
        )
        .toList();
    final position = await locateDevice();
    nearest = nearestPoints(
      candidates,
      position.latitude,
      position.longitude,
    ).firstOrNull;
    if (nearest == null) {
      throw const AccountFailure('No hay tachos con coordenadas válidas.');
    }
  });

  Future<void> refresh() async {
    if (loading || _disposed) return;
    loading = true;
    error = null;
    _notify();
    try {
      final (account, recent, catalog, history, locations, pending) = await (
        _repository.profile(),
        _repository.activityPage(0),
        _repository.rewards(),
        _repository.redemptionsPage(0),
        _repository.points(),
        _repository.loadPending(),
      ).wait;
      profile = account;
      activity = recent;
      rewards = catalog;
      redemptions = history;
      points = locations;
      pendingReward = pending;
      moreActivity = recent.length == SupabaseAccountRepository.pageSize;
      moreRedemptions = history.length == SupabaseAccountRepository.pageSize;
    } on ParallelWaitError<
      Object?,
      (
        AsyncError?,
        AsyncError?,
        AsyncError?,
        AsyncError?,
        AsyncError?,
        AsyncError?,
      )
    > catch (failure) {
      final (account, activity, catalog, history, points, pending) =
          failure.errors;
      final errors = [account, activity, catalog, history, points, pending];
      final first = errors.whereType<AsyncError>().firstOrNull?.error;
      error = accountError(first ?? failure);
    } catch (failure) {
      error = accountError(failure);
    } finally {
      loading = false;
      _notify();
    }
  }

  Future<void> nextPage({required bool redemptionsOnly}) => _run(() async {
    final current = redemptionsOnly ? redemptions : activity;
    final next = await (redemptionsOnly
        ? _repository.redemptionsPage(current.length)
        : _repository.activityPage(current.length));
    if (redemptionsOnly) {
      redemptions = [...current, ...next];
      moreRedemptions = next.length == SupabaseAccountRepository.pageSize;
    } else {
      activity = [...current, ...next];
      moreActivity = next.length == SupabaseAccountRepository.pageSize;
    }
  });

  Future<AccountRow> preview(String raw, {String? expectedPoint}) async {
    final id = _captureId(raw);
    final result = await _repository.preview(id);
    if (expectedPoint != null && result['point_id'] != expectedPoint) {
      throw const AccountFailure('El QR corresponde a otro tacho.');
    }
    return result;
  }

  Future<bool> claim(AccountRow capture) async {
    final confirmed = await _run(() async {
      final location = capture['requires_location'] == true
          ? await locateDevice()
          : null;
      await _repository.claim(capture['id'] as String, location);
    });
    if (confirmed) await refresh();
    return confirmed;
  }

  Future<bool> note(String recordId, String note) async {
    final saved = await _run(() => _repository.updateNote(recordId, note));
    if (saved) await refresh();
    return saved;
  }

  Future<AccountRow?> record(String recordId) =>
      _repository.recyclingRecord(recordId);

  Future<AccountRow?> redeem(String rewardId) async {
    AccountRow? result;
    final saved = await _run(() async {
      final pending = await _repository.prepareReward(rewardId);
      try {
        result = await _repository.redeem(pending);
      } finally {
        pendingReward = await _repository.loadPending();
      }
    });
    if (saved) await refresh();
    return result;
  }

  Future<bool> cancel(String redemptionId) async {
    final canceled = await _run(() => _repository.cancel(redemptionId));
    if (canceled) await refresh();
    return canceled;
  }

  Future<bool> _run(Future<void> Function() operation) async {
    if (working || loading || _disposed) return false;
    working = true;
    error = null;
    _notify();
    try {
      await operation();
      return true;
    } on LocalDataException catch (failure) {
      error = failure.message;
      return false;
    } catch (failure) {
      error = accountError(failure);
      return false;
    } finally {
      working = false;
      _notify();
    }
  }

  static String _captureId(String raw) {
    var value = raw.trim();
    if (value.startsWith('{') && value.length <= 4096) {
      try {
        final map = jsonDecode(value);
        value = (map is Map && map['type'] == 'qupawasi.deposit')
            ? (map['captureId'] ?? map['depositId']).toString()
            : '';
      } on FormatException {
        value = '';
      }
    }
    if (RegExp(
      r'^[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}$',
      caseSensitive: false,
    ).hasMatch(value)) {
      return value;
    }
    throw const AccountFailure(
      'El QR debe contener el identificador de una captura del tacho.',
    );
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
