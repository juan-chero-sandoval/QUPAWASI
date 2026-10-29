import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/dependencies.dart';
import '../../app/routes.dart';
import '../../core/widgets/app_page.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/state_message.dart';
import '../../core/theme/app_palette.dart';
import '../../domain/entities/deposit_qr.dart';
import '../common/connection_view_model.dart';
import 'map_view_model.dart';

class MapView extends StatelessWidget {
  const MapView({super.key, this.pointId});
  final String? pointId;
  @override
  Widget build(BuildContext context) {
    final deps = context.read<AppDependencies>();
    return ChangeNotifierProvider(
      key: ValueKey(pointId),
      create: (_) => MapViewModel(
        overview: deps.local.overview,
        catalog: deps.local.catalog,
        locate: deps.locate,
        pointId: pointId,
      ),
      child: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();
  Future<void> import(BuildContext context, MapViewModel vm) async {
    final controller = TextEditingController();
    final raw = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cargar catálogo de tachos'),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Pega el JSON del catálogo con las coordenadas verificadas. Se guarda en este dispositivo.',
                ),
                TextField(
                  controller: controller,
                  minLines: 4,
                  maxLines: 10,
                  maxLength: 100000,
                  decoration: const InputDecoration(labelText: 'Catálogo JSON'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Cargar'),
          ),
        ],
      ),
    );
    // El diálogo puede continuar su animación de cierre usando el controlador.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    controller.dispose();
    if (raw == null) return;
    final ok = await vm.importJson(raw);
    if (ok && context.mounted) AppToast.success(context, 'Catálogo guardado');
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MapViewModel>();
    // Las teselas y la superficie del mapa son claras en ambos temas.
    const mapPalette = AppPalette.light;
    final online =
        context.watch<ConnectionViewModel>().state == InternetState.online;
    final geographic = vm.points
        .where((p) => validCoordinates(p.latitude, p.longitude))
        .toList();
    final point = vm.selectedPoint;
    final nearest = vm.ranked.firstOrNull;
    final distances = {for (final r in vm.ranked) r.point.id: r.meters};
    final page = AppPage(
      title: 'Mapa',
      bottomAction: point == null
          ? null
          : FilledButton.icon(
              onPressed: () =>
                  context.go(AppRoutes.newRecord(pointId: point.id)),
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Registrar en este punto'),
            ),
      actions: [
        IconButton(
          tooltip: 'Cargar catálogo de tachos',
          onPressed: vm.importing ? null : () => import(context, vm),
          icon: const Icon(Icons.file_upload_outlined),
        ),
      ],
      children: [
        Tooltip(
          message: 'Tu ubicación se usa solo al pedirla y no se guarda',
          child: OutlinedButton.icon(
            onPressed: vm.locating ? null : vm.findNearest,
            icon: const Icon(Icons.my_location),
            label: Text(
              vm.locating ? 'Buscando ubicación…' : 'Usar mi ubicación',
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (vm.loading) const Center(child: CircularProgressIndicator()),
        if (geographic.isEmpty)
          StateMessage(
            icon: Icons.map_outlined,
            title: 'Sin ubicaciones en el mapa',
            actionLabel: 'Cargar catálogo',
            onAction: vm.importing ? null : () => import(context, vm),
          ),
        if (geographic.isNotEmpty) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: SizedBox(
              height: 260,
              child: FlutterMap(
                key: ValueKey(
                  '${vm.selected}-${vm.position?.latitude}-${geographic.map((p) => '${p.id}:${p.latitude}:${p.longitude}').join(',')}',
                ),
                options: MapOptions(
                  initialCenter:
                      validCoordinates(point?.latitude, point?.longitude)
                      ? LatLng(point!.latitude!, point.longitude!)
                      : LatLng(
                          geographic.first.latitude!,
                          geographic.first.longitude!,
                        ),
                  initialZoom: 16,
                ),
                children: [
                  if (online)
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'pe.edu.unp.qupawasi',
                    ),
                  MarkerLayer(
                    markers: [
                      for (final p in geographic)
                        Marker(
                          point: LatLng(p.latitude!, p.longitude!),
                          width: 48,
                          height: 48,
                          child: IconButton(
                            tooltip: p.name,
                            onPressed: () => vm.select(p.id),
                            icon: Icon(
                              Icons.location_on,
                              color: p.id == vm.selected
                                  ? mapPalette.brandStrong
                                  : mapPalette.textMuted,
                              size: 36,
                            ),
                          ),
                        ),
                      if (vm.position != null)
                        Marker(
                          point: LatLng(
                            vm.position!.latitude,
                            vm.position!.longitude,
                          ),
                          child: Tooltip(
                            message: 'Tu ubicación',
                            child: Icon(
                              Icons.my_location,
                              color: mapPalette.brand,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (online)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                '© OpenStreetMap contributors',
                style: TextStyle(
                  fontSize: 12,
                  color: AppPalette.of(context).textMuted,
                ),
              ),
            ),
        ],
        if (nearest != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: Row(
              children: [
                Icon(
                  Icons.near_me_outlined,
                  color: AppPalette.of(context).brand,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Más cercano: ${nearest.point.name} · '
                    '${nearest.meters.round()} m',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        const SectionHeader(title: 'Tachos'),
        for (final p in vm.points)
          ListTile(
            key: ValueKey('point-${p.id}'),
            selected: p.id == vm.selected,
            leading: Icon(
              p.id == vm.selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
            ),
            title: Text(p.name),
            subtitle: distances[p.id] == null
                ? null
                : Text('${distances[p.id]!.round()} m en línea recta'),
            onTap: () => vm.select(p.id),
          ),
        if (!vm.loading && point == null)
          Text(
            vm.points.isEmpty
                ? 'No hay puntos disponibles en el catálogo local.'
                : 'Punto no encontrado. Elige uno de la lista.',
          ),
        if (point != null) ...[
          if (validCoordinates(point.latitude, point.longitude))
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    point.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (validCoordinates(point.latitude, point.longitude))
                    Text('${point.latitude}, ${point.longitude}'),
                ],
              ),
            ),
        ],
      ],
    );
    return ToastListener(listenable: vm, message: () => vm.error, child: page);
  }
}
