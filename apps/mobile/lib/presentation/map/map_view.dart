import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/dependencies.dart';
import '../../app/routes.dart';
import '../../core/widgets/app_page.dart';
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
    if (ok && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Catálogo guardado.')));
    }
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
    return AppPage(
      title: 'Mapa',
      children: [
        const Text(
          'Consulta los tachos registrados. Tu ubicación se usa solo al solicitarla y no se guarda.',
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: vm.locating ? null : vm.findNearest,
          icon: const Icon(Icons.my_location),
          label: Text(
            vm.locating ? 'Buscando ubicación…' : 'Usar mi ubicación',
          ),
        ),
        TextButton.icon(
          onPressed: vm.importing ? null : () => import(context, vm),
          icon: const Icon(Icons.file_upload_outlined),
          label: const Text('Cargar catálogo de tachos'),
        ),
        if (vm.loading) const Center(child: CircularProgressIndicator()),
        if (vm.error != null)
          Text(
            vm.error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        if (geographic.isEmpty)
          const StateMessage(
            icon: Icons.map_outlined,
            title: 'Tus puntos, más cerca',
            message: 'Aún no hay ubicaciones geográficas. Carga las coordenadas de los tachos para ver el mapa. Los puntos de ejemplo no indican ubicaciones reales.',
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
          Text(
            online
                ? '© OpenStreetMap contributors · openstreetmap.org/copyright'
                : 'Mapa base no disponible sin internet. Los marcadores y distancias del catálogo siguen disponibles.',
          ),
        ],
        if (nearest != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Más cercano: ${nearest.point.name} · ${nearest.meters.round()} m en línea recta (no es una ruta peatonal).',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        const SizedBox(height: 16),
        Text(
          'Tachos del catálogo',
          style: Theme.of(context).textTheme.titleLarge,
        ),
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
            subtitle: Text(
              p.isDemo
                  ? 'Punto de ejemplo · no indica disponibilidad real'
                  : (distances[p.id] != null
                        ? '${distances[p.id]!.round()} m en línea recta'
                        : 'Ubicación registrada en el catálogo'),
            ),
            onTap: () => vm.select(p.id),
          ),
        if (!vm.loading && point == null)
          Text(
            vm.points.isEmpty
                ? 'No hay puntos disponibles en el catálogo local.'
                : 'Punto no encontrado. Elige uno de la lista.',
          ),
        if (point != null) ...[
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(point.name, style: Theme.of(context).textTheme.titleLarge),
                Text(point.description),
                if (validCoordinates(point.latitude, point.longitude))
                  Text('${point.latitude}, ${point.longitude}'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.go(AppRoutes.newRecord(pointId: point.id)),
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Registrar en este punto'),
          ),
        ],
      ],
    );
  }
}
