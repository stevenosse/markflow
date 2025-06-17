import 'package:flutter/material.dart';
import 'package:markflow/src/core/theme/dimens.dart';
import 'package:markflow/src/shared/extensions/context_extensions.dart';

class FindDialog {
  static Future<String?> show({
    required BuildContext context,
    String? initialText,
    String title = 'Find',
    String hintText = 'Enter text to find...',
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      useRootNavigator: false,
      builder: (context) => _FindDialogContent(
        initialText: initialText,
        title: title,
        hintText: hintText,
      ),
    );
  }
}

class _FindDialogContent extends StatefulWidget {
  final String? initialText;
  final String title;
  final String hintText;

  const _FindDialogContent({
    this.initialText,
    required this.title,
    required this.hintText,
  });

  @override
  State<_FindDialogContent> createState() => _FindDialogContentState();
}

class _FindDialogContentState extends State<_FindDialogContent> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _focusNode = FocusNode();

    // Auto-focus and select all text
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      if (widget.initialText?.isNotEmpty == true) {
        _controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _controller.text.length,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      Navigator.of(context).pop(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(Dimens.halfSpacing),
            decoration: BoxDecoration(
              color: context.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Dimens.radiusS),
            ),
            child: Icon(
              Icons.search,
              size: Dimens.iconSizeS,
              color: context.colorScheme.primary,
            ),
          ),
          const SizedBox(width: Dimens.spacing),
          Text(widget.title),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Dimens.spacing),
              child: Material(
                color: Colors.transparent,
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onSubmitted: (_) => _handleSubmit(),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.zero),
            ),
          ),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _handleSubmit,
          style: FilledButton.styleFrom(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.zero),
            ),
          ),
          child: const Text('Find'),
        ),
      ],
    );
  }
}
