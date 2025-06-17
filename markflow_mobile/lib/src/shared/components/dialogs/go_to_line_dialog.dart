import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markflow/src/core/theme/dimens.dart';
import 'package:markflow/src/shared/extensions/context_extensions.dart';

class GoToLineDialog {
  static Future<int?> show({
    required BuildContext context,
    int? maxLineNumber,
  }) {
    return showDialog<int>(
      context: context,
      barrierDismissible: true,
      useRootNavigator: false,
      builder: (context) => _GoToLineDialogContent(
        maxLineNumber: maxLineNumber,
      ),
    );
  }
}

class _GoToLineDialogContent extends StatefulWidget {
  final int? maxLineNumber;

  const _GoToLineDialogContent({
    this.maxLineNumber,
  });

  @override
  State<_GoToLineDialogContent> createState() => _GoToLineDialogContentState();
}

class _GoToLineDialogContentState extends State<_GoToLineDialogContent> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    
    // Auto-focus the input field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
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
    
    if (text.isEmpty) {
      setState(() {
        _errorText = 'Please enter a line number';
      });
      return;
    }
    
    final lineNumber = int.tryParse(text);
    if (lineNumber == null || lineNumber < 1) {
      setState(() {
        _errorText = 'Please enter a valid line number (1 or greater)';
      });
      return;
    }
    
    if (widget.maxLineNumber != null && lineNumber > widget.maxLineNumber!) {
      setState(() {
        _errorText = 'Line number cannot exceed ${widget.maxLineNumber}';
      });
      return;
    }
    
    Navigator.of(context).pop(lineNumber);
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
              Icons.format_list_numbered,
              size: Dimens.iconSizeS,
              color: context.colorScheme.primary,
            ),
          ),
          const SizedBox(width: Dimens.spacing),
          const Text('Go to Line'),
        ],
      ),
      content: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.maxLineNumber != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: Dimens.spacing),
                  child: Text(
                    'Enter line number (1-${widget.maxLineNumber}):',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onSubmitted: (_) => _handleSubmit(),
                decoration: InputDecoration(
                  labelText: 'Line number',
                  hintText: 'e.g., 42',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.tag),
                  errorText: _errorText,
                ),
                onChanged: (_) {
                  if (_errorText != null) {
                    setState(() {
                      _errorText = null;
                    });
                  }
                },
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
          child: const Text('Go'),
        ),
      ],
    );
  }
}