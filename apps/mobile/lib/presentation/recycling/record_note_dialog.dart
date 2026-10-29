import 'package:flutter/material.dart';

import 'record_detail_view_model.dart';

class RecordNoteDialog extends StatefulWidget {
  const RecordNoteDialog({
    super.key,
    required this.viewModel,
    required this.initialNote,
  });
  final RecordDetailViewModel viewModel;
  final String initialNote;
  @override
  State<RecordNoteDialog> createState() => _RecordNoteDialogState();
}

class _RecordNoteDialogState extends State<RecordNoteDialog> {
  late final controller = TextEditingController(text: widget.initialNote);
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.viewModel,
    builder: (context, _) => AlertDialog(
      title: const Text('Editar nota'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Solo cambia la nota.'),
            TextField(
              controller: controller,
              maxLength: 200,
              minLines: 2,
              maxLines: 4,
              enabled: !widget.viewModel.isSavingNote,
              decoration: InputDecoration(
                labelText: 'Nota',
                errorText: widget.viewModel.noteError,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.viewModel.isSavingNote
              ? null
              : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: widget.viewModel.isSavingNote
              ? null
              : () async {
                  final ok = await widget.viewModel.updateNote(controller.text);
                  if (ok && context.mounted) {
                    Navigator.pop(context);
                  }
                },
          child: Text(
            widget.viewModel.isSavingNote ? 'Guardando…' : 'Guardar nota',
          ),
        ),
      ],
    ),
  );
}
