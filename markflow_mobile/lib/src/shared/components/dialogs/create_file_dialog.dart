import 'package:flutter/material.dart';
import 'package:markflow/src/core/theme/dimens.dart';
import 'package:markflow/src/shared/components/forms/input.dart';
import 'package:markflow/src/shared/extensions/context_extensions.dart';

class CreateFileDialog {
  static Future<String?> show({
    required BuildContext context,
    String? initialPath,
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      useRootNavigator: false,
      builder: (context) => _CreateFileDialogContent(
        initialPath: initialPath,
      ),
    );
  }
}

class _CreateFileDialogContent extends StatefulWidget {
  final String? initialPath;

  const _CreateFileDialogContent({
    this.initialPath,
  });

  @override
  State<_CreateFileDialogContent> createState() =>
      _CreateFileDialogContentState();
}

class _CreateFileDialogContentState extends State<_CreateFileDialogContent> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  String _errorMessage = '';
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();

    // Auto-focus the input field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });

    _controller.addListener(_validateInput);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _validateInput() {
    final value = _controller.text.trim();
    setState(() {
      if (value.isEmpty) {
        _errorMessage = 'File name cannot be empty';
        _isValid = false;
      } else if (value.contains('/') || value.contains('\\')) {
        _errorMessage = 'File name cannot contain / or \\ characters';
        _isValid = false;
      } else if (value.startsWith('.')) {
        _errorMessage = 'File name cannot start with a dot';
        _isValid = false;
      } else {
        _errorMessage = '';
        _isValid = true;
      }
    });
  }

  void _handleCreate() {
    if (_isValid) {
      Navigator.of(context).pop(_controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      surfaceTintColor: Colors.transparent,
      backgroundColor: context.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimens.radius),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(Dimens.halfSpacing),
            decoration: BoxDecoration(
              color: context.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Dimens.radiusS),
            ),
            child: Icon(
              Icons.note_add_outlined,
              size: Dimens.iconSizeS,
              color: context.colorScheme.primary,
            ),
          ),
          const SizedBox(width: Dimens.spacing),
          const Text('Create New File'),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.initialPath != null) ...[
              Text(
                'Location: ${widget.initialPath}',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: Dimens.spacing),
            ],
            Material(
              color: Colors.transparent,
              child: Input(
                controller: _controller,
                focusNode: _focusNode,
                labelText: 'File name',
                hintText: 'example.md',
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _handleCreate(),
                keyboardType: TextInputType.text,
              ),
            ),
            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: Dimens.halfSpacing),
              Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: Dimens.iconSizeS,
                    color: context.colorScheme.error,
                  ),
                  const SizedBox(width: Dimens.halfSpacing),
                  Expanded(
                    child: Text(
                      _errorMessage,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: Dimens.spacing),
            Container(
              padding: const EdgeInsets.all(Dimens.spacing),
              decoration: BoxDecoration(
                color: context.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(Dimens.radiusS),
                border: Border.all(
                  color: context.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: Dimens.iconSizeS,
                    color: context.colorScheme.primary,
                  ),
                  const SizedBox(width: Dimens.halfSpacing),
                  Expanded(
                    child: Text(
                      'Files will be created as Markdown (.md) documents',
                      textAlign: TextAlign.left,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurface
                            .withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.zero),
            ),
          ),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _isValid ? _handleCreate : null,
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.zero),
            ),
          ),
          child: const Text('Create File'),
        ),
      ],
    );
  }
}
