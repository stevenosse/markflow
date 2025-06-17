import 'package:flutter/material.dart';
import 'package:markflow/src/core/theme/dimens.dart';
import 'package:markflow/src/shared/extensions/context_extensions.dart';

class ReplaceResult {
  final String findText;
  final String replaceText;

  const ReplaceResult({
    required this.findText,
    required this.replaceText,
  });
}

class ReplaceDialog {
  static Future<ReplaceResult?> show({
    required BuildContext context,
    String? initialFindText,
    String? initialReplaceText,
  }) {
    return showDialog<ReplaceResult>(
      context: context,
      barrierDismissible: true,
      useRootNavigator: false,
      builder: (context) => _ReplaceDialogContent(
        initialFindText: initialFindText,
        initialReplaceText: initialReplaceText,
      ),
    );
  }
}

class _ReplaceDialogContent extends StatefulWidget {
  final String? initialFindText;
  final String? initialReplaceText;

  const _ReplaceDialogContent({
    this.initialFindText,
    this.initialReplaceText,
  });

  @override
  State<_ReplaceDialogContent> createState() => _ReplaceDialogContentState();
}

class _ReplaceDialogContentState extends State<_ReplaceDialogContent> {
  late final TextEditingController _findController;
  late final TextEditingController _replaceController;
  late final FocusNode _findFocusNode;
  late final FocusNode _replaceFocusNode;

  @override
  void initState() {
    super.initState();
    _findController = TextEditingController(text: widget.initialFindText);
    _replaceController = TextEditingController(text: widget.initialReplaceText);
    _findFocusNode = FocusNode();
    _replaceFocusNode = FocusNode();
    
    // Auto-focus and select all text in find field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _findFocusNode.requestFocus();
      if (widget.initialFindText?.isNotEmpty == true) {
        _findController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _findController.text.length,
        );
      }
    });
  }

  @override
  void dispose() {
    _findController.dispose();
    _replaceController.dispose();
    _findFocusNode.dispose();
    _replaceFocusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final findText = _findController.text.trim();
    final replaceText = _replaceController.text;
    
    if (findText.isNotEmpty) {
      Navigator.of(context).pop(ReplaceResult(
        findText: findText,
        replaceText: replaceText,
      ));
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
              Icons.find_replace,
              size: Dimens.iconSizeS,
              color: context.colorScheme.primary,
            ),
          ),
          const SizedBox(width: Dimens.spacing),
          const Text('Find and Replace'),
        ],
      ),
      content: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: Dimens.spacing),
              TextField(
                controller: _findController,
                focusNode: _findFocusNode,
                onSubmitted: (_) => _replaceFocusNode.requestFocus(),
                decoration: const InputDecoration(
                  labelText: 'Find',
                  hintText: 'Enter text to find...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: Dimens.spacing),
              TextField(
                controller: _replaceController,
                focusNode: _replaceFocusNode,
                onSubmitted: (_) => _handleSubmit(),
                decoration: const InputDecoration(
                  labelText: 'Replace with',
                  hintText: 'Enter replacement text...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit),
                ),
              ),
            ],
          ),
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
          child: const Text('Replace'),
        ),
      ],
    );
  }
}