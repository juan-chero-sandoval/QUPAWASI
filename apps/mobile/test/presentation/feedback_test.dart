import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qupa_wasi/core/theme/app_theme.dart';
import 'package:qupa_wasi/core/widgets/app_toast.dart';
import 'package:qupa_wasi/core/widgets/simulation_chip.dart';

/// Pantalla mínima con el tema de la app para probar componentes aislados.
Widget host(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  home: Scaffold(body: Center(child: child)),
);

class _Notifier extends ChangeNotifier {
  String? message;
  bool isError = false;

  void publish(String? text, {bool error = false}) {
    message = text;
    isError = error;
    notifyListeners();
  }
}

void main() {
  testWidgets('el toast aparece arriba, con icono, y se cierra solo', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => AppToast.success(context, 'Registro guardado'),
            child: const Text('mostrar'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('mostrar'));
    await tester.pumpAndSettle();

    expect(find.text('Registro guardado'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    final top = tester.getTopLeft(find.text('Registro guardado')).dy;
    expect(top, lessThan(200), reason: 'el aviso se muestra arriba');

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Registro guardado'), findsNothing);
  });

  testWidgets('un error usa su propio icono y dura más', (tester) async {
    await tester.pumpWidget(
      host(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => AppToast.error(context, 'No se pudo guardar'),
            child: const Text('mostrar'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('mostrar'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.error_rounded), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('No se pudo guardar'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('No se pudo guardar'), findsNothing);
  });

  testWidgets('un toast nuevo reemplaza al anterior y se puede cerrar', (
    tester,
  ) async {
    late BuildContext captured;
    await tester.pumpWidget(
      host(
        Builder(
          builder: (context) {
            captured = context;
            return const SizedBox();
          },
        ),
      ),
    );
    AppToast.info(captured, 'Primero');
    await tester.pumpAndSettle();
    AppToast.info(captured, 'Segundo');
    await tester.pumpAndSettle();
    expect(find.text('Primero'), findsNothing);
    expect(find.text('Segundo'), findsOneWidget);

    await tester.tap(find.byTooltip('Cerrar aviso'));
    await tester.pumpAndSettle();
    expect(find.text('Segundo'), findsNothing);
  });

  testWidgets('ToastListener avisa cada mensaje nuevo con su tipo', (
    tester,
  ) async {
    final notifier = _Notifier();
    await tester.pumpWidget(
      host(
        ToastListener(
          listenable: notifier,
          message: () => notifier.message,
          isError: () => notifier.isError,
          child: const SizedBox(),
        ),
      ),
    );

    notifier.publish('Canje guardado');
    await tester.pumpAndSettle();
    expect(find.text('Canje guardado'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

    notifier.publish('Saldo insuficiente', error: true);
    await tester.pumpAndSettle();
    expect(find.text('Saldo insuficiente'), findsOneWidget);
    expect(find.byIcon(Icons.error_rounded), findsOneWidget);

    // El mismo mensaje no se repite mientras no cambie.
    await tester.tap(find.byTooltip('Cerrar aviso'));
    await tester.pumpAndSettle();
    notifier.notifyListeners();
    await tester.pumpAndSettle();
    expect(find.text('Saldo insuficiente'), findsNothing);
  });

  testWidgets('el chip de simulación explica por qué al tocarlo', (
    tester,
  ) async {
    await tester.pumpWidget(host(const SimulationChip()));
    expect(find.text('Simulado'), findsOneWidget);
    expect(
      tester.getSize(find.byType(InkWell)).height,
      greaterThanOrEqualTo(48),
      reason: 'área táctil mínima',
    );

    await tester.tap(find.byType(SimulationChip));
    await tester.pumpAndSettle();
    expect(find.text(SimulationChip.message), findsWidgets);
    expect(find.textContaining('nadie verifica el depósito'), findsOneWidget);
  });

  testWidgets('con movimiento reducido el toast aparece sin animación', (
    tester,
  ) async {
    late BuildContext captured;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: host(
          Builder(
            builder: (context) {
              captured = context;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    AppToast.info(captured, 'Sin animación');
    await tester.pump();
    final fade = tester.widget<FadeTransition>(
      find
          .ancestor(
            of: find.text('Sin animación'),
            matching: find.byType(FadeTransition),
          )
          .first,
    );
    expect(fade.opacity.value, 1);
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
  });
}
