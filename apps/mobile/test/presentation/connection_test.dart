import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qupa_wasi/core/widgets/simulation_chip.dart';
import 'package:qupa_wasi/presentation/common/connection_view_model.dart';

void main() {
  testWidgets(
    'aviso desaparece al recuperar internet y vuelve al desconectar',
    (tester) async {
      final stream = StreamController<bool>.broadcast();
      final vm = ConnectionViewModel(changes: stream.stream);
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: vm,
          child: const MaterialApp(home: Scaffold(body: SimulationChip())),
        ),
      );
      expect(find.text('Simulado'), findsOneWidget);
      stream.add(false);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
      stream.add(true);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.wifi_off_rounded), findsNothing);
      expect(find.text('Simulado'), findsOneWidget);
      stream.add(false);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      vm.dispose();
      unawaited(stream.close());
      await tester.pump();
    },
  );
  testWidgets('respuesta inicial tardía no pisa cambio de red reciente', (
    tester,
  ) async {
    final check = Completer<bool>();
    final stream = StreamController<bool>.broadcast();
    final vm = ConnectionViewModel(
      changes: stream.stream,
      check: () => check.future,
    );
    stream.add(true);
    await tester.pump();
    check.complete(false);
    await tester.pump();
    expect(vm.state, InternetState.online);
    vm.dispose();
    unawaited(stream.close());
    await tester.pump();
  });
}
