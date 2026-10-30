/// Rutas estables de docs/CONTRATOS.md. Construir siempre las ubicaciones
/// con estos helpers para codificar IDs y parámetros correctamente.
abstract final class AppRoutes {
  static const String welcome = '/welcome';
  static const String home = '/home';
  static const String recycling = '/recycling';
  static const String map = '/map';
  static const String rewards = '/rewards';
  static const String profile = '/profile';
  static const String ranking = '/ranking';
  static const String suggestions = '/suggestions';

  /// Modo administrador simulado: CRUD de tachos y recompensas.
  static const String admin = '/admin';
  static const String adminPoints = '/admin/points';
  static const String adminRewards = '/admin/rewards';

  static String newAdminPoint() => '$adminPoints/new';
  static String editAdminPoint(String pointId) =>
      '$adminPoints/${Uri.encodeComponent(pointId)}';
  static String newAdminReward() => '$adminRewards/new';
  static String editAdminReward(String rewardId) =>
      '$adminRewards/${Uri.encodeComponent(rewardId)}';

  static String recyclingList({String? filter}) =>
      _withQuery(recycling, {'filter': filter});

  static String newRecord({String? pointId}) =>
      _withQuery('$recycling/new', {'pointId': pointId});

  static String recordDetail(String recordId) =>
      '$recycling/${Uri.encodeComponent(recordId)}';

  static String editRecord(String recordId) => '${recordDetail(recordId)}/edit';

  static String mapPoint({String? pointId}) =>
      _withQuery(map, {'pointId': pointId});

  static String rewardsCategory({String? category}) =>
      _withQuery(rewards, {'category': category});

  static String _withQuery(String path, Map<String, String?> params) {
    final query = {
      for (final entry in params.entries)
        if (entry.value != null && entry.value!.trim().isNotEmpty)
          entry.key: entry.value!.trim(),
    };
    return Uri(
      path: path,
      queryParameters: query.isEmpty ? null : query,
    ).toString();
  }
}
