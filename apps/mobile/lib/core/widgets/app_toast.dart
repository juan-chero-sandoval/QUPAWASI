import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../theme/app_palette.dart';
import '../theme/app_theme.dart';

enum ToastType { success, error, info }

/// Notificación emergente superior: icono y color por tipo, se cierra sola
/// y se puede descartar tocando o deslizando hacia arriba. Solo hay una a la
/// vez; una nueva reemplaza a la anterior.
abstract final class AppToast {
  static OverlayEntry? _current;

  static void show(
    BuildContext context,
    String message, {
    ToastType type = ToastType.success,
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    _dismissCurrent();
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ToastView(
        message: message,
        type: type,
        onDismissed: () {
          if (entry.mounted) entry.remove();
          if (identical(_current, entry)) _current = null;
        },
      ),
    );
    _current = entry;
    overlay.insert(entry);
  }

  static void success(BuildContext context, String message) =>
      show(context, message);

  static void error(BuildContext context, String message) =>
      show(context, message, type: ToastType.error);

  static void info(BuildContext context, String message) =>
      show(context, message, type: ToastType.info);

  static void _dismissCurrent() {
    final previous = _current;
    _current = null;
    if (previous != null && previous.mounted) previous.remove();
  }
}

class _ToastView extends StatefulWidget {
  const _ToastView({
    required this.message,
    required this.type,
    required this.onDismissed,
  });

  final String message;
  final ToastType type;
  final VoidCallback onDismissed;

  @override
  State<_ToastView> createState() => _ToastViewState();
}

class _ToastViewState extends State<_ToastView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    reverseDuration: const Duration(milliseconds: 160),
  );
  Timer? _timer;
  bool _closing = false;

  // Los errores se leen con más calma que una confirmación.
  Duration get _visibleFor => widget.type == ToastType.error
      ? const Duration(seconds: 5)
      : const Duration(seconds: 3);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller.isDismissed && !_closing) {
      if (MediaQuery.disableAnimationsOf(context)) {
        _controller.value = 1;
      } else {
        _controller.forward();
      }
      _timer ??= Timer(_visibleFor, _close);
    }
  }

  Future<void> _close() async {
    if (_closing) return;
    _closing = true;
    _timer?.cancel();
    if (mounted && !MediaQuery.disableAnimationsOf(context)) {
      await _controller.reverse();
    }
    widget.onDismissed();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final scheme = Theme.of(context).colorScheme;
    final (background, foreground, iconColor, icon) = switch (widget.type) {
      ToastType.success => (
        palette.brandStrong,
        palette.onBrandStrong,
        palette.accent,
        Icons.check_circle_rounded,
      ),
      ToastType.error => (
        scheme.errorContainer,
        scheme.onErrorContainer,
        scheme.error,
        Icons.error_rounded,
      ),
      ToastType.info => (
        palette.surface,
        palette.text,
        palette.brand,
        Icons.info_rounded,
      ),
    };
    final top = MediaQuery.paddingOf(context).top + AppSpacing.sm;
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return Positioned(
      top: top,
      left: AppSpacing.md,
      right: AppSpacing.md,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween(
                  begin: const Offset(0, -0.4),
                  end: Offset.zero,
                ).animate(curved),
                child: Dismissible(
                  key: const ValueKey('app-toast'),
                  direction: DismissDirection.up,
                  onDismissed: (_) {
                    _closing = true;
                    _timer?.cancel();
                    widget.onDismissed();
                  },
                  child: Semantics(
                    container: true,
                    liveRegion: true,
                    child: Material(
                      color: background,
                      elevation: 6,
                      shadowColor: Colors.black26,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: widget.type == ToastType.info
                            ? BorderSide(color: palette.border)
                            : BorderSide.none,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
                        child: Row(
                          children: [
                            ExcludeSemantics(
                              child: Icon(icon, color: iconColor, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.message,
                                style: TextStyle(
                                  color: foreground,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  height: 1.35,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Cerrar aviso',
                              onPressed: _close,
                              color: foreground,
                              icon: const Icon(Icons.close_rounded, size: 20),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Muestra como toast cada mensaje nuevo que publica un ViewModel (errores de
/// operaciones asíncronas o confirmaciones), en lugar de dejarlo como texto
/// fijo dentro de la página. Un mismo mensaje no se repite mientras no cambie.
class ToastListener extends StatefulWidget {
  const ToastListener({
    super.key,
    required this.listenable,
    required this.message,
    required this.child,
    this.type = ToastType.error,
    this.isError,
  });

  final Listenable listenable;
  final String? Function() message;
  final ToastType type;

  /// Si se indica, decide por mensaje entre error y éxito (ignora [type]).
  final bool Function()? isError;
  final Widget child;

  @override
  State<ToastListener> createState() => _ToastListenerState();
}

class _ToastListenerState extends State<ToastListener> {
  String? _shown;

  @override
  void initState() {
    super.initState();
    widget.listenable.addListener(_check);
  }

  @override
  void didUpdateWidget(ToastListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.listenable, widget.listenable)) {
      oldWidget.listenable.removeListener(_check);
      widget.listenable.addListener(_check);
    }
  }

  void _check() {
    final current = widget.message();
    if (current == _shown) return;
    _shown = current;
    if (current == null) return;
    final type = switch (widget.isError) {
      null => widget.type,
      final isError => isError() ? ToastType.error : ToastType.success,
    };
    void show() {
      if (mounted) AppToast.show(context, current, type: type);
    }

    // Fuera de un build se muestra ya. Durante un frame se pospone y se
    // agenda otro: un post-frame callback por sí solo no pide un frame y el
    // aviso quedaría esperando a que algo más redibuje la pantalla.
    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.idle ||
        phase == SchedulerPhase.postFrameCallbacks) {
      show();
    } else {
      SchedulerBinding.instance
        ..addPostFrameCallback((_) => show())
        ..ensureVisualUpdate();
    }
  }

  @override
  void dispose() {
    widget.listenable.removeListener(_check);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
