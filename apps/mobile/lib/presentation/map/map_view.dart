import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/dependencies.dart';
import '../../app/routes.dart';
import '../../core/widgets/app_page.dart';
import '../../core/widgets/app_card.dart';
import '../../core/theme/app_palette.dart';
import '../../domain/entities/recycling_point.dart';
import '../common/local_stream_view_model.dart';
import '../common/local_state.dart';

class MapView extends StatelessWidget {
  const MapView({super.key, this.pointId});
  final String? pointId;
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    key: ValueKey(pointId),
    create: (_) => LocalStreamViewModel(
      context.read<AppDependencies>().local.overview.watchPoints,
    ),
    child: Consumer<LocalStreamViewModel<List<RecyclingPoint>>>(
      builder: (context, vm, _) => AppPage(
        title: 'Mapa',
        children: [
          const Text(
            'Esquema del campus · puntos y ocupación de ejemplo. No indica ubicación ni disponibilidad real.',
          ),
          LocalState(
            vm: vm,
            builder: (points) => _Points(points: points, initialId: pointId),
          ),
        ],
      ),
    ),
  );
}

class _Points extends StatefulWidget {
  const _Points({required this.points, this.initialId});
  final List<RecyclingPoint> points;
  final String? initialId;
  @override
  State<_Points> createState() => _PointsState();
}

class _PointsState extends State<_Points> {
  late String? selected = widget.initialId ?? widget.points.firstOrNull?.id;
  @override
  Widget build(BuildContext context) {
    final point = widget.points.where((p) => p.id == selected).firstOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            children: [
              const Text('Campus · esquema sin escala'),
              const SizedBox(height: 8),
              SizedBox(
                height: 180,
                child: CustomPaint(
                  painter: _CampusPainter(AppPalette.of(context)),
                  child: Stack(
                    children: [
                      for (final (index, p) in widget.points.indexed)
                        Align(
                          // These are diagram slots, never geographical coordinates.
                          alignment: [
                            Alignment.topLeft,
                            Alignment.centerRight,
                            Alignment.bottomLeft,
                          ][index % 3],
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Semantics(
                              selected: selected == p.id,
                              child: IconButton.filledTonal(
                                tooltip: 'Seleccionar ${p.name}',
                                onPressed: () =>
                                    setState(() => selected = p.id),
                                icon: Icon(
                                  selected == p.id
                                      ? Icons.location_on
                                      : Icons.location_on_outlined,
                                ),
                              ),
                            ),
                          ),
                        ),
                      const Center(
                        child: ExcludeSemantics(
                          child: Icon(Icons.school_outlined, size: 36),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final p in widget.points)
                    OutlinedButton.icon(
                      onPressed: () => setState(() => selected = p.id),
                      icon: Icon(
                        selected == p.id
                            ? Icons.location_on
                            : Icons.location_on_outlined,
                      ),
                      label: Text(p.name),
                    ),
                ],
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text('Lista accesible de puntos de demostración'),
        ),
        for (final p in widget.points)
          ListTile(
            key: ValueKey('point-${p.id}'),
            selected: selected == p.id,
            leading: Icon(
              selected == p.id
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
            ),
            title: Text(p.name),
            subtitle: Text('Ocupación de ejemplo: ${p.occupancy}%'),
            onTap: () => setState(() => selected = p.id),
          ),
        if (point == null)
          Text(
            widget.points.isEmpty
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
                Text('Ocupación de ejemplo: ${point.occupancy}%'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.go(AppRoutes.newRecord(pointId: point.id)),
            icon: const Icon(Icons.recycling),
            label: const Text('Registrar en este punto'),
          ),
        ],
      ],
    );
  }
}

class _CampusPainter extends CustomPainter {
  const _CampusPainter(this.palette);
  final AppPalette palette;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = palette.iconBadge;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(16)),
      paint,
    );
    paint
      ..color = palette.border
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * .18, 35),
      Offset(size.width * .8, size.height * .5),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * .8, size.height * .5),
      Offset(size.width * .18, size.height - 35),
      paint,
    );
    paint.color = palette.surface;
    for (final offset in [
      Offset(size.width * .45, 12),
      Offset(size.width * .52, size.height - 44),
    ]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          offset & const Size(52, 32),
          const Radius.circular(6),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_CampusPainter oldDelegate) =>
      palette != oldDelegate.palette;
}
