import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:qupa_wasi/data/remote/supabase_account_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../helpers/test_app.dart';

const _account = '10000000-0000-4000-8000-000000000001';
const _otherAccount = '10000000-0000-4000-8000-000000000002';

String _segment(Object json) =>
    base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');

Future<void> _signIn(SupabaseClient client, String account) async {
  final expires =
      DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/
      1000;
  final token =
      '${_segment({'alg': 'HS256'})}.${_segment({'sub': account, 'exp': expires})}.fixture';
  await client.auth.recoverSession(
    jsonEncode({
      'access_token': token,
      'token_type': 'bearer',
      'user': {
        'id': account,
        'app_metadata': {},
        'user_metadata': {},
        'created_at': '2026-01-01T00:00:00Z',
      },
    }),
  );
}

SupabaseClient _client(MockClientHandler handler) => SupabaseClient(
  'https://supabase.example.invalid',
  'sb_publishable_fixture',
  authOptions: const AuthClientOptions(autoRefreshToken: false),
  httpClient: MockClient(handler),
);

http.Response _jsonResponse(
  http.Request request,
  int status,
  Map<String, Object?> body,
) => http.Response(
  jsonEncode(body),
  status,
  request: request,
  headers: {'content-type': 'application/json'},
);

void main() {
  setUp(resetPreferencesStore);

  test('un canje cuya respuesta se pierde conserva su ID al reabrir', () async {
    final operations = <String>[];
    final client = _client((request) async {
      expect(request.method, 'POST');
      expect(request.url.path, '/rest/v1/rpc/redeem_reward');
      expect(request.headers['accept'], 'application/vnd.pgrst.object+json');
      final data = jsonDecode(request.body) as Map<String, dynamic>;
      expect(data['p_reward_id'], 'premio');
      operations.add(data['p_operation_id'] as String);
      return operations.length == 1
          ? _jsonResponse(request, 502, {
              'code': '08006',
              'message': 'Fixture: respuesta no disponible',
            })
          : _jsonResponse(request, 200, {
              'id': 'fixture-redemption',
              'code': 'ECO-FIXTURE',
            });
    });
    addTearDown(client.dispose);
    await _signIn(client, _account);

    final before = SupabaseAccountRepository(client, _account);
    final pending = await before.prepareReward('premio');
    await expectLater(
      before.redeem(pending),
      throwsA(isA<PostgrestException>()),
    );

    final after = SupabaseAccountRepository(client, _account);
    final retry = await after.prepareReward('premio');
    expect(retry.operationId, pending.operationId);
    final result = await after.redeem(retry);
    expect(result['code'], 'ECO-FIXTURE');
    expect(operations, [pending.operationId, pending.operationId]);
    expect(await after.loadPending(), isNull);
  });

  test('rechazo confirmado permite iniciar otro canje', () async {
    final client = _client(
      (request) async => _jsonResponse(request, 400, {
        'code': 'P0001',
        'message': 'Saldo insuficiente.',
      }),
    );
    addTearDown(client.dispose);
    await _signIn(client, _account);
    final repository = SupabaseAccountRepository(client, _account);

    final pending = await repository.prepareReward('premio');
    await expectLater(
      repository.redeem(pending),
      throwsA(isA<PostgrestException>()),
    );
    expect(await repository.loadPending(), isNull);
  });

  test(
    'el canje pendiente y el acceso se mantienen aislados por cuenta',
    () async {
      final client = _client(
        (_) async => throw StateError('Solicitud inesperada'),
      );
      addTearDown(client.dispose);
      await _signIn(client, _account);
      final repository = SupabaseAccountRepository(client, _account);
      final pending = await repository.prepareReward('premio');

      await _signIn(client, _otherAccount);
      final otherRepository = SupabaseAccountRepository(client, _otherAccount);
      await expectLater(
        repository.redeem(pending),
        throwsA(isA<AccountFailure>()),
      );
      expect(await otherRepository.loadPending(), isNull);
    },
  );
}
