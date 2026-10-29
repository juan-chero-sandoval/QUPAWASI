import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/dependencies.dart';
import '../../core/widgets/app_page.dart';
import '../../core/widgets/app_card.dart';
import '../common/confirm_local.dart';
import '../recycling/record_format.dart';
import 'suggestions_view_model.dart';

class SuggestionsView extends StatelessWidget {
  const SuggestionsView({super.key});
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) =>
        SuggestionsViewModel(context.read<AppDependencies>().local.suggestions),
    child: const _SuggestionsBody(),
  );
}

class _SuggestionsBody extends StatefulWidget {
  const _SuggestionsBody();
  @override
  State<_SuggestionsBody> createState() => _SuggestionsBodyState();
}

class _SuggestionsBodyState extends State<_SuggestionsBody> {
  final _text = TextEditingController();
  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SuggestionsViewModel>();
    return AppPage(
      title: 'Sugerencias',
      showBack: true,
      children: [
        const Text('Solo en este dispositivo; no se ha enviado'),
        const SizedBox(height: 16),
        TextField(
          controller: _text,
          minLines: 3,
          maxLines: 6,
          maxLength: 500,
          enabled: !vm.busy,
          decoration: InputDecoration(
            labelText: 'Mensaje local',
            helperText: 'Entre 5 y 500 caracteres',
            errorText: vm.fieldError,
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: vm.busy
              ? null
              : () async {
                  final saved = await vm.save(_text.text);
                  if (context.mounted && saved) {
                    _text.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Guardado solo en este dispositivo; no se ha enviado.',
                        ),
                      ),
                    );
                  }
                },
          child: const Text('Guardar localmente'),
        ),
        const SizedBox(height: 16),
        if (vm.loading) const Center(child: CircularProgressIndicator()),
        if (vm.error != null) ...[
          Text(vm.error!),
          TextButton(
            onPressed: vm.busy ? null : vm.load,
            child: const Text('Reintentar'),
          ),
        ],
        if (!vm.loading && vm.error == null && vm.items.isEmpty)
          const Text('Aún no tienes sugerencias locales.'),
        for (final item in vm.items)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(item.message),
                  Text(RecordFormat.dateTime(context, item.createdAt)),
                  OutlinedButton(
                    onPressed: vm.busy
                        ? null
                        : () async {
                            if (await confirmLocal(
                              context,
                              'Eliminar sugerencia',
                              item.message,
                              'Eliminar',
                            )) {
                              await vm.delete(item.id);
                            }
                          },
                    child: const Text('Eliminar sugerencia'),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
