import 'dart:async';

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
import '../../domain/entities/recycling_record.dart';
import 'record_form_view_model.dart';
import 'record_format.dart';

/// Destino de `/recycling/new?pointId=` y `/recycling/:recordId/edit`.
class RecordFormView extends StatelessWidget {
  const RecordFormView.create({super.key, this.pointId}) : recordId = null;

  const RecordFormView.edit({super.key, required String this.recordId})
    : pointId = null;

  final String? pointId;
  final String? recordId;

  @override
  Widget build(BuildContext context) {
    final local = context.read<AppDependencies>().local;
    return ChangeNotifierProvider(
      key: ValueKey('${recordId ?? 'new'}|$pointId'),
      create: (_) => RecordFormViewModel(
        recycling: local.recycling,
        overview: local.overview,
        drafts: local.drafts,
        recordId: recordId,
        initialPointId: pointId,
      )..load(),
      child: const _RecordFormBody(),
    );
  }
}

class _RecordFormBody extends StatefulWidget {
  const _RecordFormBody();

  @override
  State<_RecordFormBody> createState() => _RecordFormBodyState();
}

class _RecordFormBodyState extends State<_RecordFormBody> {
  final _quantity = TextEditingController();
  final _note = TextEditingController();
  late final RecordFormViewModel _viewModel;
  late final AppLifecycleListener _lifecycle;
  bool _synced = false;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<RecordFormViewModel>();
    _viewModel.addListener(_syncControllers);
    // Android puede matar el proceso en segundo plano sin más avisos:
    // el borrador se escribe en cuanto la app deja de estar activa.
    _lifecycle = AppLifecycleListener(
      onInactive: _flush,
      onHide: _flush,
      onPause: _flush,
      onResume: () => unawaited(_viewModel.recheckOnResume()),
    );
  }

  void _flush() => unawaited(_viewModel.flushDraft());

  /// Copia los valores del ViewModel a los campos al empezar a editar
  /// (datos guardados, borrador restaurado o conversión a nuevo).
  void _syncControllers() {
    final editing = _viewModel.status == RecordFormStatus.editing;
    if (editing && !_synced) {
      _quantity.text = _viewModel.quantityText;
      _note.text = _viewModel.note;
    }
    if (_viewModel.status != RecordFormStatus.saving) _synced = editing;
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _viewModel.removeListener(_syncControllers);
    _quantity.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    // Al crear, el ViewModel adopta el ID nuevo: el modo se lee antes.
    final wasEditing = _viewModel.isEditing;
    final id = await _viewModel.save();
    if (id == null || !mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            wasEditing ? 'Registro actualizado.' : 'Registro guardado.',
          ),
        ),
      );
    context.go(AppRoutes.recordDetail(id));
  }

  Future<void> _discardMissing() async {
    if (!await _viewModel.discardMissing()) return;
    if (mounted) context.go(AppRoutes.recycling);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RecordFormViewModel>();
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _flush();
      },
      child: AppPage(
        title: viewModel.isEditing ? 'Editar registro' : 'Nuevo registro',
        showBack: true,
        children: [
          switch (viewModel.status) {
            RecordFormStatus.loading => const Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Center(child: CircularProgressIndicator()),
            ),
            RecordFormStatus.loadError => StateMessage(
              icon: Icons.error_outline,
              title: 'No se pudo abrir el formulario',
              message: viewModel.formError ?? 'Error de almacenamiento.',
              actionLabel: 'Reintentar',
              onAction: viewModel.load,
            ),
            RecordFormStatus.notFound => StateMessage(
              icon: Icons.search_off,
              title: 'Registro no encontrado',
              message:
                  'No existe un registro con el ID "${viewModel.recordId}". '
                  'Puede haber sido eliminado.',
              actionLabel: 'Volver a Reciclar',
              onAction: () => context.go(AppRoutes.recycling),
            ),
            RecordFormStatus.draftOffer => _DraftOffer(
              savedAt: viewModel.offeredDraft!.updatedAt,
              onContinue: viewModel.continueDraft,
              onDiscard: viewModel.discardDraft,
            ),
            RecordFormStatus.recordMissing => _MissingRecord(
              onConvert: viewModel.convertMissingToNew,
              onDiscard: _discardMissing,
            ),
            RecordFormStatus.editing ||
            RecordFormStatus.saving ||
            RecordFormStatus.saved => _Wizard(
              quantity: _quantity,
              note: _note,
              onSave: _save,
            ),
          },
          if (viewModel.draftError != null &&
              (viewModel.status == RecordFormStatus.draftOffer ||
                  viewModel.status == RecordFormStatus.recordMissing))
            _FieldError(message: viewModel.draftError!),
        ],
      ),
    );
  }
}

class _Wizard extends StatelessWidget {
  const _Wizard({
    required this.quantity,
    required this.note,
    required this.onSave,
  });

  final TextEditingController quantity;
  final TextEditingController note;
  final VoidCallback onSave;

  static const List<String> stepLabels = ['Punto', 'Material', 'Confirmar'];

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RecordFormViewModel>();
    final palette = AppPalette.of(context);
    final step = viewModel.step;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StepHeader(current: step),
        const SizedBox(height: AppSpacing.md),
        switch (step) {
          0 => const _PointStep(),
          1 => _MaterialStep(quantity: quantity, note: note),
          _ => const _ConfirmStep(),
        },
        if (viewModel.formError != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            viewModel.formError!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            if (step > 0) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: viewModel.isSaving ? null : viewModel.previousStep,
                  child: const Text('Atrás'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            Expanded(
              flex: 2,
              child: step < RecordFormViewModel.lastStep
                  ? FilledButton(
                      onPressed: viewModel.nextStep,
                      child: const Text('Siguiente'),
                    )
                  : FilledButton.icon(
                      onPressed: viewModel.isSaving ? null : onSave,
                      icon: viewModel.isSaving
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check),
                      label: Text(
                        viewModel.isEditing
                            ? 'Guardar cambios'
                            : 'Guardar registro',
                      ),
                    ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          viewModel.draftError ??
              'Tus datos se guardan como borrador en este dispositivo '
                  'mientras escribes.',
          style: TextStyle(
            color: viewModel.draftError == null
                ? palette.textMuted
                : Theme.of(context).colorScheme.error,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.current});

  final int current;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Semantics(
      label: 'Paso ${current + 1} de 3: ${_Wizard.stepLabels[current]}',
      excludeSemantics: true,
      child: Row(
        children: [
          for (final (index, label) in _Wizard.stepLabels.indexed) ...[
            if (index > 0)
              Expanded(
                child: Divider(
                  color: index <= current ? palette.brand : palette.border,
                  thickness: 2,
                ),
              ),
            Column(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: index <= current
                      ? palette.brandStrong
                      : palette.surface,
                  foregroundColor: index <= current
                      ? palette.onBrandStrong
                      : palette.textMuted,
                  child: index < current
                      ? const Icon(Icons.check, size: 16)
                      : Text('${index + 1}'),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: index == current
                        ? FontWeight.w800
                        : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PointStep extends StatelessWidget {
  const _PointStep();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RecordFormViewModel>();
    final palette = AppPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '¿Dónde reciclaste?',
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final point in viewModel.points) ...[
          _SelectableCard(
            selected: viewModel.pointId == point.id,
            icon: Icons.place_outlined,
            title: point.name,
            subtitle:
                '${point.description} · Ocupación de demostración '
                '${point.occupancy}%',
            onTap: () => viewModel.selectPoint(point.id),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (viewModel.pointError != null)
          _FieldError(message: viewModel.pointError!),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Selección manual: funciona sin conexión. El escaneo del QR del '
          'punto se incorporará en una fase posterior.',
          style: TextStyle(color: palette.textMuted, fontSize: 12),
        ),
      ],
    );
  }
}

class _MaterialStep extends StatelessWidget {
  const _MaterialStep({required this.quantity, required this.note});

  final TextEditingController quantity;
  final TextEditingController note;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RecordFormViewModel>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '¿Qué reciclaste?',
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final material in RecyclingMaterial.values) ...[
          _SelectableCard(
            selected: viewModel.material == material,
            icon: RecordFormat.materialIcon(material),
            title: material.label,
            subtitle: switch (material) {
              RecyclingMaterial.pet => 'Botellas de plástico',
              RecyclingMaterial.aluminum => 'Latas de bebida',
            },
            onTap: () => viewModel.selectMaterial(material),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (viewModel.materialError != null)
          _FieldError(message: viewModel.materialError!),
        const SizedBox(height: AppSpacing.md),
        TextField(
          key: const Key('quantity-field'),
          controller: quantity,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          onChanged: viewModel.setQuantityText,
          decoration: InputDecoration(
            labelText: 'Cantidad (unidades)',
            helperText: 'Número entero entre 1 y 100.',
            errorText: viewModel.quantityError,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          key: const Key('note-field'),
          controller: note,
          maxLength: 200,
          maxLines: 3,
          minLines: 1,
          onChanged: viewModel.setNote,
          decoration: InputDecoration(
            labelText: 'Nota (opcional)',
            errorText: viewModel.noteError,
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}

class _ConfirmStep extends StatelessWidget {
  const _ConfirmStep();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RecordFormViewModel>();
    final palette = AppPalette.of(context);
    final material = viewModel.material;
    final rows = <(String, String)>[
      ('Punto', viewModel.selectedPoint?.name ?? '—'),
      ('Material', material?.label ?? '—'),
      ('Cantidad', '${viewModel.parsedQuantity ?? '—'}'),
      ('Nota', viewModel.note.trim().isEmpty ? 'Sin nota' : viewModel.note),
      ('Fecha', RecordFormat.dateTime(context, viewModel.occurredAt)),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Revisa antes de guardar',
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (label, value) in rows)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: palette.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        value,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              const Divider(),
              Text(
                '+${viewModel.estimatedPoints ?? 0} EcoPuntos simulados',
                style: TextStyle(
                  color: palette.brand,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SelectableCard extends StatelessWidget {
  const _SelectableCard({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? palette.notice : palette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          side: BorderSide(
            color: selected ? palette.brand : palette.border,
            width: selected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                IconBadge(icon: icon),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(color: palette.textMuted),
                      ),
                    ],
                  ),
                ),
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: selected ? palette.brand : palette.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldError extends StatelessWidget {
  const _FieldError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.error;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 16, color: color),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(message, style: TextStyle(color: color)),
          ),
        ],
      ),
    );
  }
}

class _DraftOffer extends StatelessWidget {
  const _DraftOffer({
    required this.savedAt,
    required this.onContinue,
    required this.onDiscard,
  });

  final DateTime savedAt;
  final VoidCallback onContinue;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: IconBadge(icon: Icons.restore, size: 52)),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Recuperamos un borrador',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Lo dejaste sin terminar el '
            '${RecordFormat.dateTime(context, savedAt)}. Aún no es un '
            'registro ni suma puntos.',
            textAlign: TextAlign.center,
            style: TextStyle(color: palette.textMuted),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            onPressed: onContinue,
            child: const Text('Continuar borrador'),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            onPressed: onDiscard,
            child: const Text('Descartar y empezar de nuevo'),
          ),
        ],
      ),
    );
  }
}

class _MissingRecord extends StatelessWidget {
  const _MissingRecord({required this.onConvert, required this.onDiscard});

  final VoidCallback onConvert;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: IconBadge(icon: Icons.search_off, size: 52)),
          const SizedBox(height: AppSpacing.md),
          Text(
            'El registro que editabas ya no existe',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Se eliminó mientras tenías cambios sin guardar. Puedes usar '
            'esos datos para crear un registro nuevo o descartarlos.',
            textAlign: TextAlign.center,
            style: TextStyle(color: palette.textMuted),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            onPressed: onConvert,
            child: const Text('Usar como registro nuevo'),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            onPressed: onDiscard,
            child: const Text('Descartar borrador'),
          ),
        ],
      ),
    );
  }
}
