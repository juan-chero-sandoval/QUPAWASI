import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/app_preferences.dart';
import '../settings/app_settings_view_model.dart';

Future<void> showAliasDialog(BuildContext context) {
  final alias = context.read<AppSettingsViewModel>().alias;
  return showDialog<void>(
    context: context,
    builder: (_) => _AliasDialog(initial: alias),
  );
}

class _AliasDialog extends StatefulWidget {
  const _AliasDialog({required this.initial});

  final String initial;

  @override
  State<_AliasDialog> createState() => _AliasDialogState();
}

class _AliasDialogState extends State<_AliasDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial,
  );
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final error = await context.read<AppSettingsViewModel>().setAlias(
      _controller.text,
    );
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop();
    } else {
      setState(() => _error = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.select<AppSettingsViewModel, bool>(
      (vm) => vm.isSaving,
    );
    return AlertDialog(
      title: const Text('Editar alias'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: LocalAlias.maxLength,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _save(),
        onChanged: (_) {
          if (_error != null) setState(() => _error = null);
        },
        decoration: InputDecoration(
          labelText: 'Alias de demostración',
          helperText: 'No uses tu nombre completo ni tu código.',
          errorText: _error,
        ),
      ),
      actions: [
        TextButton(
          onPressed: isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: isSaving ? null : _save,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
