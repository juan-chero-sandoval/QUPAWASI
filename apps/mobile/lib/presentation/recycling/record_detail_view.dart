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
import 'record_detail_view_model.dart';

class RecordDetailView extends StatelessWidget {
  const RecordDetailView({super.key, required this.recordId});

  final String recordId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      key: ValueKey(recordId),
      create: (context) => RecordDetailViewModel(
        repository: context.read<AppDependencies>().recordPreviewRepository,
        recordId: recordId,
      )..load(),
      child: const _RecordDetailBody(),
    );
  }
}

class _RecordDetailBody extends StatelessWidget {
  const _RecordDetailBody();

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
          RecordDetailData(:final record) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (record.isDemo) const _DemoChip(),
                    _Field(label: 'ID', value: record.id),
                    _Field(label: 'Punto', value: record.pointName),
                    _Field(label: 'Material', value: record.materialLabel),
                    _Field(label: 'Cantidad', value: '${record.quantity}'),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: () => context.go(AppRoutes.editRecord(record.id)),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Editar'),
              ),
            ],
          ),
        },
      ],
    );
  }
}

class _DemoChip extends StatelessWidget {
  const _DemoChip();

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Chip(
        avatar: Icon(Icons.visibility_outlined, color: palette.onNotice),
        label: const Text('Dato de ejemplo · no guardado'),
        backgroundColor: palette.notice,
        side: BorderSide(color: palette.accent),
      ),
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
