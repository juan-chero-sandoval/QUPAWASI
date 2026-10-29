import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_palette.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_page.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/state_message.dart';
import '../common/confirm_local.dart';
import '../recycling/record_format.dart';
import 'admin_form_view_model.dart';

/// Marco común de los formularios de administración.
///
/// Gestiona estados (cargando, no encontrado, borrador ofrecido, edición),
/// guarda el borrador al pasar a segundo plano o volver atrás, muestra los
/// mensajes como toast y deja "Guardar" fijo abajo.
class AdminFormScaffold extends StatefulWidget {
  const AdminFormScaffold({
    super.key,
    required this.viewModel,
    required this.newTitle,
    required this.editTitle,
    required this.entityName,
    required this.onEditingStarted,
    required this.fields,
  });

  final AdminFormViewModel<Object> viewModel;
  final String newTitle;
  final String editTitle;

  /// Sustantivo para los diálogos: "tacho", "recompensa".
  final String entityName;

  /// Copia los valores del ViewModel a los controladores de texto.
  final VoidCallback onEditingStarted;
  final List<Widget> Function(BuildContext context) fields;

  @override
  State<AdminFormScaffold> createState() => _AdminFormScaffoldState();
}

class _AdminFormScaffoldState extends State<AdminFormScaffold> {
  late final AppLifecycleListener _lifecycle;
  bool _synced = false;

  AdminFormViewModel<Object> get _vm => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _vm.addListener(_sync);
    // Android puede matar el proceso en segundo plano sin más avisos:
    // el borrador se escribe en cuanto la app deja de estar activa.
    _lifecycle = AppLifecycleListener(
      onInactive: _flush,
      onHide: _flush,
      onPause: _flush,
    );
  }

  void _flush() => unawaited(_vm.flushDraft());

  void _sync() {
    final editing = _vm.status == AdminFormStatus.editing;
    if (editing && !_synced) widget.onEditingStarted();
    if (_vm.status != AdminFormStatus.saving) _synced = editing;
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _vm.removeListener(_sync);
    super.dispose();
  }

  void _close() {
    if (context.canPop()) context.pop();
  }

  Future<void> _save() async {
    if (await _vm.save() && mounted) _close();
  }

  Future<void> _delete() async {
    final name = widget.entityName;
    if (!await confirmLocal(
      context,
      '¿Eliminar $name?',
      'Se borrará de este dispositivo. No se puede deshacer.',
      'Eliminar',
    )) {
      return;
    }
    final outcome = await _vm.delete();
    if (!mounted) return;
    switch (outcome) {
      case DeleteOutcome.deleted:
        _close();
      case DeleteOutcome.inUse:
        if (await confirmLocal(
          context,
          'No se puede eliminar',
          'Este $name tiene historial. Puedes desactivarlo: se conserva lo '
              'registrado y deja de ofrecerse.',
          'Desactivar',
        )) {
          await _vm.setActive(false);
        }
      case DeleteOutcome.failed:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = _vm;
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _flush();
      },
      child: ToastListener(
        listenable: vm,
        message: () => vm.message,
        isError: () => vm.messageIsError,
        child: ListenableBuilder(
          listenable: vm,
          builder: (context, _) => AppPage(
            title: vm.isEditing ? widget.editTitle : widget.newTitle,
            showBack: true,
            // Se evalúa en cada cambio del ViewModel (no con el estado inicial).
            bottomAction: vm.status == AdminFormStatus.editing || vm.isSaving
                ? FilledButton.icon(
                    onPressed: vm.isSaving ? null : _save,
                    icon: vm.isSaving
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check_rounded),
                    label: const Text('Guardar'),
                  )
                : null,
            children: [
              switch (vm.status) {
                AdminFormStatus.loading => const Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: Center(child: CircularProgressIndicator()),
                ),
                AdminFormStatus.loadError => StateMessage(
                  icon: Icons.error_outline,
                  title: 'No se pudo abrir',
                  actionLabel: 'Reintentar',
                  onAction: vm.load,
                ),
                AdminFormStatus.notFound => StateMessage(
                  icon: Icons.search_off,
                  title: 'No encontrado',
                  message: 'No existe un ${widget.entityName} con ese ID.',
                  actionLabel: 'Volver',
                  onAction: _close,
                ),
                AdminFormStatus.draftOffer => _DraftOffer(
                  savedAt: vm.offeredDraftAt,
                  onContinue: vm.continueDraft,
                  onDiscard: vm.discardDraft,
                ),
                AdminFormStatus.editing || AdminFormStatus.saving => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...widget.fields(context),
                    if (vm.isEditing) ...[
                      const SizedBox(height: AppSpacing.md),
                      AppCard(
                        padding: EdgeInsets.zero,
                        child: SwitchListTile(
                          title: const Text('Activo'),
                          value: vm.isActive,
                          onChanged: vm.isSaving ? null : vm.setActive,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                        ),
                        onPressed: vm.isSaving ? null : _delete,
                        icon: const Icon(Icons.delete_outline),
                        label: Text('Eliminar ${widget.entityName}'),
                      ),
                    ],
                  ],
                ),
              },
            ],
          ),
        ),
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

  final DateTime? savedAt;
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
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (savedAt != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              RecordFormat.dateTime(context, savedAt!),
              textAlign: TextAlign.center,
              style: TextStyle(color: palette.textMuted),
            ),
          ],
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
