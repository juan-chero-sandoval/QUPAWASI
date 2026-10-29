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
import '../../domain/entities/recycling_draft.dart';
import '../../domain/entities/recycling_record.dart';
import 'record_format.dart';
import 'record_list_view_model.dart';

/// Pestaña Reciclar: historial de registros guardados en SQLite.
class RecyclingView extends StatelessWidget {
  const RecyclingView({super.key, this.filter});

  /// Valor crudo de `/recycling?filter=` (`pet` o `aluminum`).
  final String? filter;

  @override
  Widget build(BuildContext context) {
    final local = context.read<AppDependencies>().local;
    final material = RecordListViewModel.parseFilter(filter);
    return ChangeNotifierProvider(
      key: ValueKey(material),
      create: (_) => RecordListViewModel(
        recycling: local.recycling,
        overview: local.overview,
        drafts: local.drafts,
        material: material,
      )..start(),
      child: const _RecyclingBody(),
    );
  }
}

class _RecyclingBody extends StatefulWidget {
  const _RecyclingBody();

  @override
  State<_RecyclingBody> createState() => _RecyclingBodyState();
}

class _RecyclingBodyState extends State<_RecyclingBody> {
  bool _wasCurrent = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Al volver a esta ruta (p. ej. tras salir del formulario) se reconsulta
    // el borrador, que pudo guardarse o descartarse en otra pantalla.
    final isCurrent = ModalRoute.isCurrentOf(context) ?? true;
    if (isCurrent && !_wasCurrent) {
      context.read<RecordListViewModel>().refreshDrafts();
    }
    _wasCurrent = isCurrent;
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RecordListViewModel>();
    return AppPage(
      title: 'Reciclar',
      children: [
        Text(
          'Tus recibos de reciclaje, en un solo lugar.',
          style: TextStyle(color: AppPalette.of(context).textMuted),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => context.go(AppRoutes.newRecord()),
          icon: const Icon(Icons.qr_code_scanner_rounded),
          label: const Text('Nuevo registro'),
        ),
        if (viewModel.pendingDraft case final draft?
            when draft.recordId != null) ...[
          const SizedBox(height: AppSpacing.md),
          _DraftBanner(
            draft: draft,
            onContinue: () => context.go(
              draft.recordId == null
                  ? AppRoutes.newRecord()
                  : AppRoutes.editRecord(draft.recordId!),
            ),
            onDiscard: viewModel.discardPendingDraft,
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        _FilterChips(selected: viewModel.material),
        const SectionHeader(title: 'Mis registros', trailing: 'En este equipo'),
        switch (viewModel.status) {
          RecordListStatus.loading => const Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Center(child: CircularProgressIndicator()),
          ),
          RecordListStatus.error => StateMessage(
            icon: Icons.error_outline,
            title: 'No se pudo cargar',
            message: viewModel.errorMessage ?? 'Error de almacenamiento.',
            actionLabel: 'Reintentar',
            onAction: viewModel.start,
          ),
          RecordListStatus.empty => StateMessage(
            icon: Icons.recycling,
            title: viewModel.material == null
                ? 'Aún no tienes registros'
                : 'Sin registros con este filtro',
            message: 'Escanea el recibo QR del tacho para registrar tus botellas PET o latas en este dispositivo.',
            actionLabel: 'Registrar reciclaje',
            onAction: () => context.go(AppRoutes.newRecord()),
          ),
          RecordListStatus.data => Column(
            children: [
              for (final record in viewModel.records) ...[
                _RecordTile(
                  record: record,
                  pointName: viewModel.pointName(record.pointId),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ),
        },
      ],
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selected});

  final RecyclingMaterial? selected;

  @override
  Widget build(BuildContext context) {
    final options = <(RecyclingMaterial?, String)>[
      (null, 'Todos'),
      (RecyclingMaterial.pet, 'PET'),
      (RecyclingMaterial.aluminum, 'Latas'),
    ];
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final (material, label) in options)
          ChoiceChip(
            label: Text(label),
            selected: selected == material,
            onSelected: (_) =>
                context.go(AppRoutes.recyclingList(filter: material?.name)),
          ),
      ],
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({required this.record, required this.pointName});

  final RecyclingRecord record;
  final String pointName;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return AppCard(
      onTap: () => context.go(AppRoutes.recordDetail(record.id)),
      child: Row(
        children: [
          IconBadge(icon: RecordFormat.materialIcon(record.material)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  RecordFormat.quantity(record.material, record.quantity),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  '$pointName · '
                  '${RecordFormat.dateTime(context, record.occurredAt)}',
                  style: TextStyle(color: palette.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '+${record.earnedPoints}',
            style: TextStyle(color: palette.brand, fontWeight: FontWeight.w800),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}

class _DraftBanner extends StatelessWidget {
  const _DraftBanner({
    required this.draft,
    required this.onContinue,
    required this.onDiscard,
  });

  final RecyclingDraft draft;
  final VoidCallback onContinue;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final kind = draft.recordId == null ? 'nuevo registro' : 'edición';
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: palette.notice,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: palette.accent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tienes un $kind sin terminar',
            style: TextStyle(
              color: palette.onNotice,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            'Guardado el ${RecordFormat.dateTime(context, draft.updatedAt)}.',
            style: TextStyle(color: palette.onNotice),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              FilledButton(
                onPressed: onContinue,
                child: const Text('Continuar'),
              ),
              OutlinedButton(
                onPressed: onDiscard,
                child: const Text('Descartar borrador'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
