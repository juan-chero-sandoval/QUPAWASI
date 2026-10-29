import 'package:flutter/material.dart';

import '../../core/widgets/state_message.dart';
import 'local_stream_view_model.dart';

class LocalState<T> extends StatelessWidget {
  const LocalState({super.key, required this.vm, required this.builder});
  final LocalStreamViewModel<T> vm;
  final Widget Function(T) builder;
  @override
  Widget build(BuildContext context) {
    if (vm.error != null) {
      return StateMessage(
        icon: Icons.error_outline,
        title: 'No se pudo cargar',
        message: vm.error!,
        actionLabel: 'Reintentar',
        onAction: vm.reload,
      );
    }
    if (vm.loading || vm.data == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return builder(vm.data as T);
  }
}
