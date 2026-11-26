import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Proyecciones de lectura del catálogo. Los campos opcionales pueden ser nulos.
enum SupabaseCatalog {
  categories('categories', 'id,name,icon,created_at'),
  rewards(
    'rewards',
    'id,title,detail,cost,partner,enabled,created_at,updated_at,category_id,icon,stock',
    enabledOnly: true,
  ),
  recyclingPoints(
    'recycle_points',
    'id,name,hours,capacity,status,note,lat,lng,enabled,created_at',
    enabledOnly: true,
  ),
  materials(
    'materials',
    'id,label,short,points,waste_kg,co2_kg,icon,enabled,created_at,updated_at',
    enabledOnly: true,
  ),
  careerCodes('career_codes', 'code,faculty,school,created_at', order: 'code');

  const SupabaseCatalog(
    this._table,
    this._columns, {
    this._order = 'id',
    this._enabledOnly = false,
  });

  final String _table;
  final String _columns;
  final String _order;
  final bool _enabledOnly;
}

enum SupabaseAccountHistory {
  activity(
    'activity',
    'id,user_id,type,items,reward_id,reward_title,label,point_name,source,points,created_at',
  ),
  redemptions(
    'redemptions',
    'id,user_id,reward_id,reward_title,cost,code,created_at,fulfilled,fulfilled_at',
  ),
  suggestions('suggestions', 'id,user_id,body,created_at'),
  notifications(
    'notifications',
    'id,user_id,type,ref_id,title,body,read_at,pushed_at,created_at',
  );

  const SupabaseAccountHistory(this._table, this._columns);

  final String _table;
  final String _columns;
}

/// Sesión de Supabase Auth provista por quien consume el adaptador.
/// La autorización corresponde al servidor mediante RLS.
class SupabaseSession {
  SupabaseSession({required this.userId, required String accessToken})
    : _accessToken = accessToken {
    _requireUuid(userId, 'userId');
    if (!_jwtPattern.hasMatch(accessToken)) {
      throw ArgumentError('Se requiere un token de sesión de Supabase Auth.');
    }
  }

  final String userId;
  final String _accessToken;
  static final _jwtPattern = RegExp(
    r'^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$',
  );
}

enum SupabaseReadFailure {
  configuration,
  timeout,
  network,
  unauthorized,
  forbidden,
  unavailable,
  invalidResponse,
}

class SupabaseReadException implements Exception {
  const SupabaseReadException(this.failure, {this.statusCode});

  final SupabaseReadFailure failure;
  final int? statusCode;
}

typedef SupabaseRow = Map<String, Object?>;

/// Acceso bajo demanda a la Data API de Supabase por HTTPS.
class SupabaseDataSource {
  SupabaseDataSource({
    required String url,
    required String publishableKey,
    http.Client Function()? createClient,
    this._timeout = const Duration(seconds: 8),
  }) : _url = url.trim(),
       _publishableKey = publishableKey.trim(),
       _createClient = createClient ?? http.Client.new;

  static SupabaseDataSource? fromEnvironment({
    String url = const String.fromEnvironment('SUPABASE_URL'),
    String publishableKey = const String.fromEnvironment(
      'SUPABASE_PUBLISHABLE_KEY',
    ),
  }) {
    if (url.trim().isEmpty && publishableKey.trim().isEmpty) return null;
    return SupabaseDataSource(url: url, publishableKey: publishableKey);
  }

  final String _url;
  final String _publishableKey;
  final http.Client Function() _createClient;
  final Duration _timeout;

  static final _publishableKeyPattern = RegExp(
    r'^sb_publishable_[A-Za-z0-9_-]+$',
  );

  Future<void> checkConnection() async {
    await readCatalog(SupabaseCatalog.categories, limit: 1);
  }

  Future<List<SupabaseRow>> readCatalog(
    SupabaseCatalog catalog, {
    SupabaseSession? session,
    int limit = 50,
    int offset = 0,
  }) => _read(
    catalog._table,
    catalog._columns,
    order: '${catalog._order}.asc',
    filters: {if (catalog._enabledOnly) 'enabled': 'eq.true'},
    session: session,
    limit: limit,
    offset: offset,
  );

  Future<SupabaseRow?> readProfile(SupabaseSession session) async {
    final rows = await _read(
      'profiles',
      'id,full_name,faculty,school,student_code,avatar_initials,points,lifetime_points,streak_days,totals,created_at,role',
      order: 'id.asc',
      filters: {'id': 'eq.${session.userId}'},
      session: session,
      limit: 1,
    );
    return rows.firstOrNull;
  }

  Future<List<SupabaseRow>> readHistory(
    SupabaseAccountHistory history, {
    required SupabaseSession session,
    int limit = 50,
    int offset = 0,
  }) => _read(
    history._table,
    history._columns,
    order: 'created_at.desc,id.desc',
    filters: {'user_id': 'eq.${session.userId}'},
    session: session,
    limit: limit,
    offset: offset,
  );

  Future<List<SupabaseRow>> readSuggestionReplies({
    required String suggestionId,
    required SupabaseSession session,
    int limit = 50,
    int offset = 0,
  }) {
    _requireUuid(suggestionId, 'suggestionId');
    return _read(
      'suggestion_replies',
      'id,suggestion_id,admin_id,body,created_at',
      order: 'created_at.asc,id.asc',
      filters: {'suggestion_id': 'eq.$suggestionId'},
      session: session,
      limit: limit,
      offset: offset,
    );
  }

  Future<List<SupabaseRow>> readAppSettings({
    required SupabaseSession session,
    int limit = 50,
    int offset = 0,
  }) => _read(
    'app_settings',
    'key,value,description,updated_at',
    order: 'key.asc',
    session: session,
    limit: limit,
    offset: offset,
  );

  Future<List<SupabaseRow>> _read(
    String table,
    String columns, {
    required String order,
    Map<String, String> filters = const {},
    SupabaseSession? session,
    required int limit,
    int offset = 0,
  }) async {
    RangeError.checkValueInInterval(limit, 1, 100, 'limit');
    RangeError.checkNotNegative(offset, 'offset');

    final baseUrl = Uri.tryParse(_url);
    if (baseUrl == null ||
        baseUrl.scheme != 'https' ||
        baseUrl.host.isEmpty ||
        baseUrl.authority.contains('@') ||
        (baseUrl.path.isNotEmpty && baseUrl.path != '/') ||
        baseUrl.hasQuery ||
        baseUrl.hasFragment ||
        !_publishableKeyPattern.hasMatch(_publishableKey)) {
      throw const SupabaseReadException(SupabaseReadFailure.configuration);
    }

    final uri = baseUrl.replace(
      path: '/rest/v1/$table',
      queryParameters: {
        'select': columns,
        'order': order,
        'limit': '$limit',
        'offset': '$offset',
        ...filters,
      },
    );
    final request = http.Request('GET', uri)
      ..followRedirects = false
      ..headers.addAll({
        'accept': 'application/json',
        'accept-profile': 'public',
        'apikey': _publishableKey,
        if (session != null) 'authorization': 'Bearer ${session._accessToken}',
      });

    final client = _createClient();
    try {
      final response = await client
          .send(request)
          .then(http.Response.fromStream)
          .timeout(_timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw SupabaseReadException(switch (response.statusCode) {
          401 => SupabaseReadFailure.unauthorized,
          403 => SupabaseReadFailure.forbidden,
          _ => SupabaseReadFailure.unavailable,
        }, statusCode: response.statusCode);
      }

      final Object? payload = jsonDecode(utf8.decode(response.bodyBytes));
      if (payload is! List<Object?> ||
          payload.any((row) => row is! SupabaseRow)) {
        throw const SupabaseReadException(SupabaseReadFailure.invalidResponse);
      }
      return payload.cast<SupabaseRow>();
    } on TimeoutException {
      throw const SupabaseReadException(SupabaseReadFailure.timeout);
    } on http.ClientException {
      throw const SupabaseReadException(SupabaseReadFailure.network);
    } on IOException {
      throw const SupabaseReadException(SupabaseReadFailure.network);
    } on FormatException {
      throw const SupabaseReadException(SupabaseReadFailure.invalidResponse);
    } finally {
      client.close();
    }
  }
}

final _uuidPattern = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
  caseSensitive: false,
);

void _requireUuid(String value, String name) {
  if (!_uuidPattern.hasMatch(value)) {
    throw ArgumentError('El valor de $name debe ser un UUID.');
  }
}
