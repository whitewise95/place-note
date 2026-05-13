import 'package:flutter/material.dart';

class FolderNameDialog extends StatefulWidget {
  const FolderNameDialog({
    required this.title,
    required this.confirmLabel,
    this.initialValue = '',
    super.key,
  });

  final String title;
  final String confirmLabel;
  final String initialValue;

  @override
  State<FolderNameDialog> createState() => _FolderNameDialogState();
}

class _FolderNameDialogState extends State<FolderNameDialog> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: '폴더 이름',
          hintText: '예: 맛집, 부동산, 여행',
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }

  void _submit() {
    Navigator.of(context).pop(controller.text);
  }
}
