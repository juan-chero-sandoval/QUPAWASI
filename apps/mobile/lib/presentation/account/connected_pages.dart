import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_page.dart';
import '../../core/widgets/app_toast.dart';
import '../../data/remote/supabase_account_repository.dart';
import '../../domain/entities/app_preferences.dart';
import '../../domain/entities/recycling_statistics.dart';
import '../common/connection_view_model.dart';
import '../home/widgets/points_summary_card.dart';
import '../recycling/qr_camera_view.dart';
import '../settings/app_settings_view_model.dart';
import '../shell/app_shell.dart';
import 'connected_account_view_model.dart';

class ConnectedPages extends StatefulWidget {
  const ConnectedPages({
    super.key,
    required this.settings,
    required this.onSignOut,
  });

  final AppSettingsViewModel settings;
  final Future<void> Function() onSignOut;

  @override
  State<ConnectedPages> createState() => _ConnectedPagesState();
}

class _ConnectedPagesState extends State<ConnectedPages>
    with WidgetsBindingObserver {
  int _tab = 0;
  bool _scanning = false;
  bool _signingOut = false;
  String? _rewardCategory;
  late final ConnectedAccountViewModel _account = context
      .read<ConnectedAccountViewModel>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_account.working) {
      unawaited(_account.refresh());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _scan({String? pointId}) async {
    if (_scanning || _account.working || _account.loading) return;
    setState(() => _scanning = true);
    try {
      final raw = await Navigator.of(context).push<String>(
        MaterialPageRoute(builder: (_) => const QrCameraView(simulated: false)),
      );
      if (!mounted || raw == null) return;
      final capture = await _account.preview(raw, expectedPoint: pointId);
      if (!mounted) return;
      final confirmed = await _confirm(
        'Confirmar depósito',
        '${capture['point_name']}\n${_items(capture['items'])}',
        'Registrar',
      );
      if (!mounted || !confirmed) return;
      if (await _account.claim(capture) && mounted) {
        AppToast.success(context, 'Depósito registrado');
      }
    } catch (error) {
      if (mounted) AppToast.error(context, accountError(error));
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  Future<bool> _confirm(
    String title,
    String description,
    String action,
  ) async =>
      await showDialog<bool>(
        context: context,
        builder: (dialog) => AlertDialog(
          title: Text(title),
          content: Text(description),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialog, false),
              child: const Text('Volver'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialog, true),
              child: Text(action),
            ),
          ],
        ),
      ) ??
      false;

  Future<void> _redeem(String rewardId, {AccountRow? reward}) async {
    if (reward != null &&
        !await _confirm(
          'Canjear recompensa',
          '${reward['title']} · ${reward['cost']} EcoPuntos',
          'Canjear',
        )) {
      return;
    }
    if (!mounted) return;
    final result = await _account.redeem(rewardId);
    if (result == null || !mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('Canje registrado'),
        content: SelectableText('Código de canje\n${result['code']}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> _edit(String id) async {
    final record = _account.record(id);
    final note = await showDialog<String>(
      context: context,
      routeSettings: RouteSettings(name: '/recycling/$id'),
      builder: (dialog) => FutureBuilder<AccountRow?>(
        future: record,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _RecordNoteDialog(record: snapshot.data!);
          }
          final loading = snapshot.connectionState != ConnectionState.done;
          return AlertDialog(
            title: const Text('Depósito'),
            content: loading
                ? const LinearProgressIndicator(
                    semanticsLabel: 'Consultando depósito',
                  )
                : Text(
                    snapshot.hasError
                        ? accountError(snapshot.error!)
                        : 'Este depósito ya no está disponible.',
                  ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialog),
                child: const Text('Cerrar'),
              ),
            ],
          );
        },
      ),
    );
    if (!mounted || note == null) return;
    if (await _account.note(id, note) && mounted) {
      AppToast.success(context, 'Nota guardada');
    }
  }

  Future<void> _signOut() async {
    if (_signingOut || _account.working) return;
    setState(() => _signingOut = true);
    try {
      await widget.onSignOut();
    } catch (error) {
      if (mounted) AppToast.error(context, accountError(error));
    } finally {
      if (mounted) setState(() => _signingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = context.watch<ConnectedAccountViewModel>();
    final offline =
        context.watch<ConnectionViewModel>().state == InternetState.offline;
    final title = AppShell.destinations[_tab].label;
    final available = account.profile?['points'] as int? ?? 0;
    final canAct =
        !offline &&
        !account.loading &&
        !account.working &&
        !_scanning &&
        !_signingOut;
    final body = [
      if (offline) const Text('Sin conexión'),
      if (account.loading || account.working || _scanning)
        const LinearProgressIndicator(semanticsLabel: 'Cargando'),
      if (account.error case final error?)
        Semantics(
          liveRegion: true,
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(error),
                TextButton(
                  onPressed: canAct ? account.refresh : null,
                  child: const Text('Actualizar'),
                ),
              ],
            ),
          ),
        ),
      if (account.profile != null)
        ...switch (_tab) {
          0 => _home(account, available, canAct),
          1 => _recycling(account, canAct),
          2 => _map(account, canAct, offline),
          3 => _rewards(account, available, canAct),
          _ => _profile(account),
        },
    ];
    return PopScope(
      canPop: _tab == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _tab = 0);
      },
      child: Scaffold(
        body: AppPage(
          title: title,
          simulated: false,
          actions: [
            if (_tab == 4 || account.profile == null)
              IconButton(
                tooltip: 'Cerrar sesión',
                onPressed: account.working || _signingOut ? null : _signOut,
                icon: const Icon(Icons.logout),
              ),
            IconButton(
              tooltip: 'Actualizar',
              onPressed: canAct ? account.refresh : null,
              icon: const Icon(Icons.refresh),
            ),
          ],
          bottomAction: _tab == 1 && account.profile != null
              ? FilledButton.icon(
                  onPressed: canAct ? _scan : null,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Escanear QR del tacho'),
                )
              : null,
          children: body,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tab,
          destinations: AppShell.destinations,
          onDestinationSelected: _scanning || account.working
              ? null
              : (index) => setState(() => _tab = index),
        ),
      ),
    );
  }

  List<Widget> _home(
    ConnectedAccountViewModel account,
    int available,
    bool canAct,
  ) {
    final profile = account.profile!;
    final earned = profile['lifetime_points'] as int;
    final level = EcoLevel.values.lastWhere(
      (level) => level.threshold <= earned,
      orElse: () => EcoLevel.seed,
    );
    final next = EcoLevel.values
        .where((value) => value.threshold > level.threshold)
        .firstOrNull;
    return [
      Text(
        'Hola, ${profile['full_name'] ?? 'estudiante'}',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SizedBox(height: AppSpacing.md),
      PointsSummaryCard(
        simulated: false,
        points: available,
        levelName: level.label,
        progress: next == null
            ? 1
            : (earned - level.threshold) / (next.threshold - level.threshold),
        nextLevelText: next == null
            ? 'Nivel máximo'
            : '${next.threshold - earned} EcoPuntos para ${next.label}',
        onRegister: () {
          setState(() => _tab = 1);
          if (canAct) unawaited(_scan());
        },
      ),
      const SectionHeader(title: 'Actividad reciente'),
      if (account.activity.isEmpty) const Text('Aún no tienes movimientos.'),
      for (final row in account.activity.take(5))
        ListTile(
          title: Text(_activityTitle(row)),
          trailing: Text('${row['points']} pts'),
        ),
    ];
  }

  List<Widget> _recycling(ConnectedAccountViewModel account, bool canAct) {
    final records = account.activity.where((row) => row['type'] == 'recycle');
    return [
      const SectionHeader(title: 'Mis depósitos'),
      if (records.isEmpty)
        const Text('Aún no hay depósitos en esta página del historial.'),
      for (final record in records)
        AppCard(
          child: ListTile(
            leading: const Icon(Icons.recycling),
            title: Text(_activityTitle(record)),
            subtitle: Text(_items(record['items'])),
            trailing: IconButton(
              tooltip: 'Ver depósito y editar nota',
              onPressed: canAct ? () => _edit(record['id'] as String) : null,
              icon: const Icon(Icons.edit_note),
            ),
          ),
        ),
      if (account.moreActivity)
        OutlinedButton(
          onPressed: canAct
              ? () => account.nextPage(redemptionsOnly: false)
              : null,
          child: const Text('Cargar más actividad'),
        ),
    ];
  }

  List<Widget> _map(
    ConnectedAccountViewModel account,
    bool canAct,
    bool offline,
  ) {
    final points = account.points;
    final mapped = points
        .where((point) => point['lat'] is num && point['lng'] is num)
        .toList();
    LatLng coords(AccountRow point) => LatLng(
      (point['lat'] as num).toDouble(),
      (point['lng'] as num).toDouble(),
    );
    final nearest = account.nearest;
    final center =
        mapped.where((point) => point['id'] == nearest?.point.id).firstOrNull ??
        mapped.firstOrNull;
    return [
      OutlinedButton.icon(
        onPressed: canAct && mapped.isNotEmpty ? account.findNearest : null,
        icon: const Icon(Icons.my_location),
        label: const Text('Buscar el tacho más cercano'),
      ),
      if (nearest != null && center?['id'] == nearest.point.id)
        Text('${nearest.point.name} · ${nearest.meters.round()} m'),
      if (center != null)
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            height: 250,
            child: FlutterMap(
              key: ValueKey(center['id']),
              options: MapOptions(
                initialCenter: coords(center),
                initialZoom: 16,
              ),
              children: [
                if (!offline)
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'pe.edu.unp.qupawasi',
                  ),
                MarkerLayer(
                  markers: [
                    for (final point in mapped)
                      Marker(
                        point: coords(point),
                        child: Tooltip(
                          message: point['name'] as String,
                          child: const Icon(Icons.location_on, size: 32),
                        ),
                      ),
                  ],
                ),
                if (!offline)
                  const RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution('OpenStreetMap contributors'),
                    ],
                  ),
              ],
            ),
          ),
        ),
      const SectionHeader(title: 'Tachos de reciclaje'),
      if (points.isEmpty) const Text('No hay tachos disponibles.'),
      for (final point in points)
        AppCard(
          child: ListTile(
            leading: const Icon(Icons.place_outlined),
            title: Text(point['name'] as String),
            subtitle: Text(
              [point['hours'], point['note']].whereType<String>().join('\n'),
            ),
            trailing: IconButton(
              tooltip: 'Escanear en ${point['name']}',
              onPressed: canAct
                  ? () => _scan(pointId: point['id'] as String)
                  : null,
              icon: const Icon(Icons.qr_code_scanner),
            ),
          ),
        ),
    ];
  }

  List<Widget> _rewards(
    ConnectedAccountViewModel account,
    int available,
    bool canAct,
  ) => [
    Text(
      '$available EcoPuntos disponibles',
      style: Theme.of(context).textTheme.titleLarge,
    ),
    if (account.pendingReward case final pending?)
      AppCard(
        child: ListTile(
          title: const Text('Hay un canje pendiente de confirmar'),
          trailing: TextButton(
            onPressed: canAct ? () => _redeem(pending.rewardId) : null,
            child: const Text('Reintentar'),
          ),
        ),
      ),
    const SectionHeader(title: 'Recompensas'),
    if (account.rewards.isNotEmpty)
      Wrap(
        spacing: AppSpacing.sm,
        children: [
          ChoiceChip(
            label: const Text('Todas'),
            selected: _rewardCategory == null,
            onSelected: (_) => setState(() => _rewardCategory = null),
          ),
          for (final category in {
            for (final reward in account.rewards)
              reward['category_id'] as String:
                  (reward['categories'] as Map?)?['name'] as String? ?? 'Otros',
          }.entries)
            ChoiceChip(
              label: Text(category.value),
              selected: _rewardCategory == category.key,
              onSelected: (_) => setState(() => _rewardCategory = category.key),
            ),
        ],
      ),
    if (account.rewards.isEmpty) const Text('No hay premios disponibles.'),
    for (final reward in account.rewards.where(
      (row) => _rewardCategory == null || row['category_id'] == _rewardCategory,
    ))
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.sm,
          children: [
            Text(
              reward['title'] as String,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (reward['detail'] case final String description)
              Text(description),
            Text('${reward['cost']} EcoPuntos'),
            FilledButton(
              onPressed:
                  canAct &&
                      account.pendingReward == null &&
                      reward['stock'] != 0 &&
                      available >= (reward['cost'] as int)
                  ? () => _redeem(reward['id'] as String, reward: reward)
                  : null,
              child: Text(reward['stock'] == 0 ? 'Agotado' : 'Canjear'),
            ),
          ],
        ),
      ),
    const SectionHeader(title: 'Mis canjes'),
    if (account.redemptions.isEmpty) const Text('Aún no tienes canjes.'),
    for (final row in account.redemptions)
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              row['reward_title'] as String,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (row['canceled_at'] != null)
              const Text('Cancelado')
            else if (row['fulfilled'] == true)
              const Text('Entregado')
            else ...[
              SelectableText('Código ${row['code']}'),
              if (row['stock_reserved'] != null)
                TextButton(
                  onPressed: canAct
                      ? () async {
                          if (await _confirm(
                                'Cancelar canje',
                                'Los EcoPuntos se devolverán a tu saldo.',
                                'Cancelar canje',
                              ) &&
                              mounted) {
                            if (await _account.cancel(row['id'] as String) &&
                                mounted) {
                              AppToast.success(context, 'Canje cancelado');
                            }
                          }
                        }
                      : null,
                  child: const Text('Cancelar canje'),
                ),
            ],
          ],
        ),
      ),
    if (account.moreRedemptions)
      OutlinedButton(
        onPressed: canAct
            ? () => account.nextPage(redemptionsOnly: true)
            : null,
        child: const Text('Cargar más canjes'),
      ),
  ];

  List<Widget> _profile(ConnectedAccountViewModel account) => [
    AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.sm,
        children: [
          Text(
            account.profile!['full_name'] as String? ?? 'Mi cuenta',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (account.profile!['faculty'] case final String faculty)
            Text(faculty),
          if (account.profile!['school'] case final String school) Text(school),
          Text('${account.profile!['lifetime_points']} EcoPuntos acumulados'),
          Text('Racha de ${account.profile!['streak_days']} días'),
        ],
      ),
    ),
    const SectionHeader(title: 'Apariencia'),
    DropdownButtonFormField<ThemePreference>(
      initialValue: widget.settings.themePreference,
      decoration: const InputDecoration(labelText: 'Tema'),
      items: [
        for (final preference in ThemePreference.values)
          DropdownMenuItem(
            value: preference,
            child: Text(switch (preference) {
              ThemePreference.system => 'Sistema',
              ThemePreference.light => 'Claro',
              ThemePreference.dark => 'Oscuro',
            }),
          ),
      ],
      onChanged: (preference) {
        if (preference != null) unawaited(widget.settings.setTheme(preference));
      },
    ),
  ];
}

String _items(Object? value) => value is List
    ? value
          .whereType<Map<String, dynamic>>()
          .map((row) => '${row['qty']} × ${row['material']}')
          .join(', ')
    : '';

String _activityTitle(AccountRow row) =>
    (row['point_name'] ??
            row['label'] ??
            row['reward_title'] ??
            'Movimiento de EcoPuntos')
        as String;

class _RecordNoteDialog extends StatefulWidget {
  const _RecordNoteDialog({required this.record});
  final AccountRow record;

  @override
  State<_RecordNoteDialog> createState() => _RecordNoteDialogState();
}

class _RecordNoteDialogState extends State<_RecordNoteDialog> {
  late final _controller = TextEditingController(
    text: widget.record['note'] as String? ?? '',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(_activityTitle(widget.record)),
    scrollable: true,
    content: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.md,
      children: [
        Text(_items(widget.record['items'])),
        Text(
          MaterialLocalizations.of(context).formatShortDate(
            DateTime.parse(widget.record['created_at'] as String).toLocal(),
          ),
        ),
        Text('${widget.record['points']} EcoPuntos'),
        TextField(
          controller: _controller,
          maxLength: 200,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Nota del depósito'),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Volver'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, _controller.text),
        child: const Text('Guardar nota'),
      ),
    ],
  );
}
