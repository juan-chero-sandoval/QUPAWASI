import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/geo_position.dart';

typedef AccountRow = Map<String, dynamic>;

class AccountFailure implements Exception {
  const AccountFailure(this.message);
  final String message;
}

class PendingReward {
  const PendingReward(this.rewardId, this.operationId);

  final String rewardId;
  final String operationId;
}

/// All requests are scoped to one authenticated account. Credits, redemptions
/// and inventory changes are performed by the database functions.
class SupabaseAccountRepository {
  SupabaseAccountRepository(this._client, this.userId);

  final SupabaseClient _client;
  final String userId;
  final _preferences = SharedPreferencesAsync();

  static const _activityColumns =
      'id,type,items,point_name,point_id,note,source,points,created_at,reward_title,label';

  String get _pendingKey => 'qupawasi.remote.pending.$userId';

  void _checkAccount() {
    if (_client.auth.currentUser?.id != userId) {
      throw const AccountFailure('Inicia sesión para continuar.');
    }
  }

  Future<T> _request<T>(Future<T> Function() request) async {
    _checkAccount();
    return request().timeout(const Duration(seconds: 15));
  }

  Future<AccountRow> profile() => _request(() async {
    final row = await _client
        .from('profiles')
        .select(
          'id,full_name,faculty,school,points,lifetime_points,streak_days,totals',
        )
        .eq('id', userId)
        .maybeSingle();
    if (row == null) {
      throw const AccountFailure('Tu cuenta aún no tiene un perfil.');
    }
    return row;
  });

  Future<List<AccountRow>> activityPage(int offset) => _request(
    () async => await _client
        .from('activity')
        .select(_activityColumns)
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .order('id', ascending: false)
        .range(offset, offset + pageSize - 1),
  );

  Future<AccountRow?> recyclingRecord(String id) => _request(
    () async => await _client
        .from('activity')
        .select(_activityColumns)
        .eq('user_id', userId)
        .eq('type', 'recycle')
        .eq('id', id)
        .maybeSingle(),
  );

  Future<List<AccountRow>> rewards() => _request(
    () async => await _client
        .from('rewards')
        .select(
          'id,title,detail,partner,cost,stock,category_id,categories(name)',
        )
        .eq('enabled', true)
        .order('title'),
  );

  Future<List<AccountRow>> redemptionsPage(int offset) => _request(
    () async => await _client
        .from('redemptions')
        .select(
          'id,reward_title,cost,code,created_at,fulfilled,canceled_at,stock_reserved',
        )
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .order('id', ascending: false)
        .range(offset, offset + pageSize - 1),
  );

  Future<List<AccountRow>> points() => _request(
    () async => await _client
        .from('recycle_points')
        .select('id,name,note,hours,lat,lng,status')
        .eq('enabled', true)
        .order('name'),
  );

  Future<AccountRow> preview(String captureId) => _request(() async {
    final row = await _client
        .rpc('preview_mobile_capture', params: {'p_capture_id': captureId})
        .maybeSingle();
    if (row == null) {
      throw const AccountFailure('La captura expiró o ya no está disponible.');
    }
    return Map<String, dynamic>.from(row as Map);
  });

  Future<void> claim(String captureId, GeoPosition? location) async {
    await _request(
      () => _client.rpc(
        'claim_device_capture',
        params: {
          'p_capture_id': captureId,
          'p_lat': location?.latitude,
          'p_lng': location?.longitude,
        },
      ),
    );
  }

  Future<void> updateNote(String activityId, String note) async {
    await _request(
      () => _client.rpc(
        'update_recycling_note',
        params: {'p_activity_id': activityId, 'p_note': note},
      ),
    );
  }

  Future<PendingReward?> loadPending() async {
    final saved = await _preferences.getString(_pendingKey);
    if (saved == null) return null;
    final value = jsonDecode(saved) as Map<String, dynamic>;
    return PendingReward(
      value['rewardId'] as String,
      value['operationId'] as String,
    );
  }

  Future<PendingReward> prepareReward(String rewardId) async {
    _checkAccount();
    final pending = await loadPending();
    if (pending != null) {
      if (pending.rewardId != rewardId) {
        throw const AccountFailure('Resuelve primero el canje pendiente.');
      }
      return pending;
    }

    final newPending = PendingReward(rewardId, const Uuid().v4());
    await _preferences.setString(
      _pendingKey,
      jsonEncode({'rewardId': rewardId, 'operationId': newPending.operationId}),
    );
    return newPending;
  }

  Future<AccountRow> redeem(PendingReward pending) async {
    final AccountRow row;
    try {
      row = await _request(
        () => _client
            .rpc(
              'redeem_reward',
              params: {
                'p_reward_id': pending.rewardId,
                'p_operation_id': pending.operationId,
              },
            )
            .single(),
      );
    } on PostgrestException catch (error) {
      if (error.code == 'P0001') {
        await _preferences.remove(_pendingKey);
      }
      rethrow;
    }
    await _preferences.remove(_pendingKey);
    return row;
  }

  Future<void> cancel(String redemptionId) async {
    await _request(
      () => _client.rpc(
        'cancel_mobile_redemption',
        params: {'p_redemption_id': redemptionId},
      ),
    );
  }

  static const pageSize = 30;
}

String accountError(Object error) => switch (error) {
  AccountFailure(:final message) => message,
  TimeoutException() => 'La conexión tardó demasiado. Reintenta.',
  PostgrestException(code: 'P0001', :final message) => message,
  PostgrestException(code: '42501') =>
    'Tu cuenta no tiene acceso a esta operación.',
  PostgrestException(code: 'PGRST202') =>
    'El servidor aún no tiene la actualización móvil.',
  _ => 'No se pudo conectar con Q’UPA WASI. Reintenta.',
};
