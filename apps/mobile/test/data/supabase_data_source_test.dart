import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:qupa_wasi/data/remote/supabase_data_source.dart';

const _url = 'https://qupawasi.example.invalid';
const _publicKey = 'sb_publishable_test';
const _userId = '00000000-0000-4000-8000-000000000001';
const _suggestionId = '00000000-0000-4000-8000-000000000002';
const _token = 'fake.test.jwt';

SupabaseDataSource _source(
  MockClientHandler handler, {
  String url = _url,
  String key = _publicKey,
  Duration timeout = const Duration(seconds: 8),
}) => SupabaseDataSource(
  url: url,
  publishableKey: key,
  createClient: () => MockClient(handler),
  timeout: timeout,
);

Matcher _failure(SupabaseReadFailure failure) => isA<SupabaseReadException>()
    .having((error) => error.failure, 'kind', failure);

void main() {
  test('sin configuración la composición puede usar solo SQLite', () {
    expect(
      SupabaseDataSource.fromEnvironment(url: '', publishableKey: ''),
      isNull,
    );
  });

  test('comprueba categorías con una solicitud anónima y acotada', () async {
    var requests = 0;
    final source = _source((request) async {
      requests++;
      expect(request.method, 'GET');
      expect(request.url.path, '/rest/v1/categories');
      expect(request.url.queryParameters['limit'], '1');
      expect(request.headers['apikey'], _publicKey);
      expect(request.headers['accept-profile'], 'public');
      expect(request.headers, isNot(contains('authorization')));
      expect(request.followRedirects, isFalse);
      return http.Response('[]', 200);
    });

    expect(requests, 0);
    await source.checkConnection();
    expect(requests, 1);
  });

  test('respeta campos nulos, UTF-8 y paginación de recompensas', () async {
    final source = _source((request) async {
      expect(request.url.path, '/rest/v1/rewards');
      expect(request.url.queryParameters['enabled'], 'eq.true');
      expect(request.url.queryParameters['order'], 'id.asc');
      expect(request.url.queryParameters['offset'], '20');
      expect(
        request.url.queryParameters['select']!.split(','),
        containsAll(['category_id', 'cost', 'stock']),
      );
      return http.Response.bytes(
        utf8.encode('[{"id":"demo","title":"Café","stock":null}]'),
        200,
      );
    });

    final rows = await source.readCatalog(SupabaseCatalog.rewards, offset: 20);
    expect(rows.single, {'id': 'demo', 'title': 'Café', 'stock': null});
  });

  test('filtra el historial por UUID y conserva enums y JSONB', () async {
    final source = _source((request) async {
      expect(request.url.path, '/rest/v1/activity');
      expect(request.url.queryParameters['user_id'], 'eq.$_userId');
      expect(request.url.queryParameters['order'], 'created_at.desc,id.desc');
      expect(request.headers['authorization'], 'Bearer $_token');
      return http.Response(
        '[{"type":"reciclaje","source":"manual","items":[{"cantidad":2}]}]',
        200,
      );
    });

    final rows = await source.readHistory(
      SupabaseAccountHistory.activity,
      session: SupabaseSession(userId: _userId, accessToken: _token),
    );
    expect(rows.single['type'], 'reciclaje');
    expect(rows.single['items'], [
      {'cantidad': 2},
    ]);
  });

  test(
    'distingue un perfil ausente y pide respuestas por sugerencia',
    () async {
      final source = _source((request) async {
        expect(request.headers['authorization'], 'Bearer $_token');
        if (request.url.path == '/rest/v1/profiles') {
          expect(request.url.queryParameters['id'], 'eq.$_userId');
        } else {
          expect(request.url.path, '/rest/v1/suggestion_replies');
          expect(
            request.url.queryParameters['suggestion_id'],
            'eq.$_suggestionId',
          );
        }
        return http.Response('[]', 200);
      });
      final session = SupabaseSession(userId: _userId, accessToken: _token);

      expect(await source.readProfile(session), isNull);
      expect(
        await source.readSuggestionReplies(
          suggestionId: _suggestionId,
          session: session,
        ),
        isEmpty,
      );
    },
  );

  test('bloquea HTTP y claves no publicables antes del envío', () async {
    Future<http.Response> unexpected(http.Request _) async =>
        throw StateError('No se debía enviar la solicitud.');

    for (final source in [
      _source(unexpected, url: 'http://qupawasi.example.invalid'),
      _source(unexpected, key: 'sb_secret_test'),
      _source(unexpected, key: ''),
    ]) {
      await expectLater(
        source.checkConnection(),
        throwsA(_failure(SupabaseReadFailure.configuration)),
      );
    }
  });

  test('distingue permisos, errores de red y respuestas inválidas', () async {
    for (final (status, expected) in [
      (401, SupabaseReadFailure.unauthorized),
      (403, SupabaseReadFailure.forbidden),
      (503, SupabaseReadFailure.unavailable),
      (200, SupabaseReadFailure.invalidResponse),
    ]) {
      final source = _source(
        (_) async => http.Response('{"error":true}', status),
      );
      await expectLater(source.checkConnection(), throwsA(_failure(expected)));
    }

    final offline = _source((_) async => throw http.ClientException('offline'));
    await expectLater(
      offline.checkConnection(),
      throwsA(_failure(SupabaseReadFailure.network)),
    );
  });

  test('limita el tiempo de una consulta', () async {
    final source = _source((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 30));
      return http.Response('[]', 200);
    }, timeout: Duration.zero);

    await expectLater(
      source.checkConnection(),
      throwsA(_failure(SupabaseReadFailure.timeout)),
    );
  });
}
