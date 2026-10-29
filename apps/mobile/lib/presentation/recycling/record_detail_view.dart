import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/dependencies.dart';
import '../../app/routes.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_page.dart';
import '../../core/widgets/state_message.dart';
import '../../domain/entities/recycling_record.dart';
import 'record_detail_view_model.dart';
import 'record_format.dart';
import 'record_note_dialog.dart';

class RecordDetailView extends StatelessWidget {
  const RecordDetailView({super.key, required this.recordId});

  final String recordId;

  @override
  Widget build(BuildContext context) {
    final local = context.read<AppDependencies>().local;
    return ChangeNotifierProvider(
      key: ValueKey(recordId),
      create: (_) => RecordDetailViewModel(
        recycling: local.recycling,
        overview: local.overview,
        recordId: recordId,
      )..load(),
      child: const _RecordDetailBody(),
    );
  }
}

class _RecordDetailBody extends StatelessWidget {
  const _RecordDetailBody();

  Future<void> _confirmDelete(
    BuildContext context,
    RecyclingRecord record,
  ) async {
    final viewModel = context.read<RecordDetailViewModel>();
    final summary =
        '${RecordFormat.quantity(record.material, record.quantity)} en '
        '${viewModel.pointName(record.pointId)} '
        '(${record.earnedPoints} EcoPuntos)';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar registro?'),
        content: Text(
          'Se borrará $summary de este dispositivo. No se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final deleted = await viewModel.delete();
    if (!context.mounted) return;
    if (deleted) {
      AppToast.success(context, 'Registro eliminado');
      context.go(AppRoutes.recycling);
    } else if (viewModel.deleteError case final message?) {
      AppToast.error(context, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RecordDetailViewModel>();
    return AppPage(
      title: 'Detalle del registro',
      showBack: true,
      children: [
        switch (viewModel.state) {
          RecordDetailLoading() => const Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Center(child: CircularProgressIndicator()),
          ),
          RecordDetailNotFound() => StateMessage(
            icon: Icons.search_off,
            title: 'Registro no encontrado',
            message:
                'No existe un registro con el ID "${viewModel.recordId}". '
                'Puede haber sido eliminado.',
            actionLabel: 'Volver a Reciclar',
            onAction: () => context.go(AppRoutes.recycling),
          ),
          RecordDetailError(:final message) => StateMessage(
            icon: Icons.error_outline,
            title: 'Error al cargar',
            message: message,
            actionLabel: 'Reintentar',
            onAction: viewModel.load,
          ),
          RecordDetailData(:final record) => _RecordDetails(
            record: record,
            pointName: viewModel.pointName(record.pointId),
            isDeleting: viewModel.isDeleting,
            onEdit: () async {
              if (record.depositId == null) {
                context.go(AppRoutes.editRecord(record.id));
              } else {
                viewModel.noteError = null;
                await showDialog<void>(
                  context: context,
                  builder: (_) => RecordNoteDialog(
                    viewModel: viewModel,
                    initialNote: record.note,
                  ),
                );
              }
            },
            onDelete: () => _confirmDelete(context, record),
          ),
        },
      ],
    );
  }
}

class _RecordDetails extends StatelessWidget {
  const _RecordDetails({
    required this.record,
    required this.pointName,
    required this.isDeleting,
    required this.onEdit,
    required this.onDelete,
  });

  final RecyclingRecord record;
  final String pointName;
  final bool isDeleting;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final error = Theme.of(context).colorScheme.error;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconBadge(icon: RecordFormat.materialIcon(record.material)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      RecordFormat.quantity(record.material, record.quantity),
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              _Field(label: 'Punto', value: pointName),
              _Field(label: 'EcoPuntos', value: '+${record.earnedPoints}'),
              _Field(
                label: 'Fecha',
                value: RecordFormat.dateTime(context, record.occurredAt),
              ),
              _Field(
                label: 'Nota',
                value: record.note.isEmpty ? 'Sin nota' : record.note,
              ),
              _Field(
                label: 'Última edición',
                value: RecordFormat.dateTime(context, record.updatedAt),
              ),
              _Field(label: 'ID', value: record.id),
              if (record.depositId != null) ...[
                _Field(label: 'Recibo QR', value: record.depositId!),
                _Field(
                  label: 'Ubicación del depósito',
                  value: '${record.latitude}, ${record.longitude}',
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        FilledButton.icon(
          onPressed: isDeleting ? null : onEdit,
          icon: const Icon(Icons.edit_outlined),
          label: Text(record.depositId == null ? 'Editar' : 'Editar nota'),
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(foregroundColor: error),
          onPressed: isDeleting ? null : onDelete,
          icon: isDeleting
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.delete_outline),
          label: const Text('Eliminar'),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: palette.textMuted, fontSize: 12)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
