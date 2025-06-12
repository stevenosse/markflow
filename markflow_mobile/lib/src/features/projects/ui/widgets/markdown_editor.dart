import 'package:flutter/material.dart';
import 'package:markflow/src/core/theme/dimens.dart';
import 'package:markflow/src/datasource/models/markdown_file.dart';

class MarkdownEditor extends StatefulWidget {
  final MarkdownFile file;
  final String content;
  final ValueChanged<String> onContentChanged;
  final bool isLoading;
  
  const MarkdownEditor({
    super.key,
    required this.file,
    required this.content,
    required this.onContentChanged,
    this.isLoading = false,
  });
  
  @override
  State<MarkdownEditor> createState() => _MarkdownEditorState();
}

class _MarkdownEditorState extends State<MarkdownEditor> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.content);
    _focusNode = FocusNode();
  }
  
  @override
  void didUpdateWidget(MarkdownEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.content != oldWidget.content && widget.content != _controller.text) {
      _controller.text = widget.content;
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        children: [
          _buildEditorHeader(context),
          const Divider(height: 1),
          Expanded(
            child: _buildEditor(context),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEditorHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimens.spacing),
      child: Row(
        children: [
          Icon(
            Icons.edit,
            size: Dimens.iconSizeS,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          const SizedBox(width: Dimens.halfSpacing),
          Expanded(
            child: Text(
              widget.file.name,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (widget.file.hasUnsavedChanges)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimens.halfSpacing,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Dimens.fullRadius),
              ),
              child: Text(
                'Modified',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          if (widget.isLoading) ...[
            const SizedBox(width: Dimens.halfSpacing),
            SizedBox(
              width: Dimens.iconSizeS,
              height: Dimens.iconSizeS,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildEditor(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimens.editorPadding),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        style: TextStyle(
          fontSize: Dimens.editorFontSize,
          height: Dimens.editorLineHeight,
          fontFamily: 'monospace',
          color: Theme.of(context).colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: 'Start writing your markdown...',
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: widget.onContentChanged,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
      ),
    );
  }
}