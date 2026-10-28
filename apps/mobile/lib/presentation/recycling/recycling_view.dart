import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/dependencies.dart';
import '../../app/routes.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_page.dart';
import '../../core/widgets/state_message.dart';
import '../../domain/entities/record_preview.dart';

/// Pestaña Reciclar. La lista real con SQLite llega en F02/F03; aquí solo
/// hay acceso a crear y enlaces de ejemplo para probar rutas con ID.
class RecyclingView extends StatefulWidget {
  const RecyclingView({super.key, this.filter});

  final String? filter;

  @override
  State<RecyclingView> createState() => _RecyclingViewState();
}

class _RecyclingViewState extends State<RecyclingView> {
  late final Future<List<RecordPreview>> _previews = context
      .read<AppDependencies>()
      .recordPreviewRepository
      .list();

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return AppPage(
      title: 'Reciclar',
      children: [
        FilledButton.icon(
          onPressed: () => context.go(AppRoutes.newRecord()),
          icon: const Icon(Icons.add),
          label: const Text('Nuevo registro'),
        ),
        if (widget.filter != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Filtro recibido: ${widget.filter}',
            style: TextStyle(color: palette.textMuted),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        const StateMessage.inPreparation(
          message:
              'Tu historial de registros se guardará con SQLite (F02) y '
              'tendrá crear, editar y eliminar (F03).',
        ),
        const SectionHeader(
          title: 'Ejemplos para navegación',
          trailing: 'No guardados',
        ),
        FutureBuilder<List<RecordPreview>>(
          future: _previews,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('No se pudieron cargar los ejemplos.');
            }
            final items = snapshot.data;
            if (items == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return Column(
              children: [
                for (final item in items) ...[
                  AppCard(
                    onTap: () => context.go(AppRoutes.recordDetail(item.id)),
                    child: Row(
                      children: [
                        const IconBadge(icon: Icons.receipt_long_outlined),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${item.materialLabel} × ${item.quantity}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '${item.pointName} · ID ${item.id}',
                                style: TextStyle(color: palette.textMuted),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                TextButton(
                  onPressed: () =>
                      context.go(AppRoutes.recordDetail('id-inexistente')),
                  child: const Text('Probar un ID inexistente'),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
