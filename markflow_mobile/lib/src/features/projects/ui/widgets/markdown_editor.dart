import 'package:flutter/material.dart';
import 'package:markflow/src/core/theme/dimens.dart';
import 'package:markflow/src/datasource/models/markdown_file.dart';

class MarkdownEditor extends StatefulWidget {
  final List<MarkdownFile> openFiles;
  final MarkdownFile? activeFile;
  final String content;
  final ValueChanged<String> onContentChanged;
  final ValueChanged<MarkdownFile> onFileSelected;
  final ValueChanged<MarkdownFile> onFileClose;
  final bool isLoading;
  
  const MarkdownEditor({
    super.key,
    required this.openFiles,
    required this.activeFile,
    required this.content,
    required this.onContentChanged,
    required this.onFileSelected,
    required this.onFileClose,
    this.isLoading = false,
  });
  
  @override
  State<MarkdownEditor> createState() => _MarkdownEditorState();
}

class _MarkdownEditorState extends State<MarkdownEditor> with TickerProviderStateMixin {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final ScrollController _scrollController;
  
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.content);
    _focusNode = FocusNode();
    _scrollController = ScrollController();
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
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          if (widget.openFiles.isNotEmpty) _buildTabBar(context),
          _buildEditorToolbar(context),
          const Divider(height: 1),
          Expanded(
            child: _buildEditor(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.openFiles.length,
        itemBuilder: (context, index) {
          final file = widget.openFiles[index];
          final isActive = file == widget.activeFile;
          
          return _EditorTab(
            file: file,
            isActive: isActive,
            onTap: () => widget.onFileSelected(file),
            onClose: () => widget.onFileClose(file),
          );
        },
      ),
    );
  }

  Widget _buildEditorToolbar(BuildContext context) {
    if (widget.activeFile == null) return const SizedBox.shrink();
    
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: Dimens.spacing),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Row(
        children: [
          Icon(
            _getFileIcon(widget.activeFile!.name),
            size: Dimens.iconSizeS,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          const SizedBox(width: Dimens.halfSpacing),
          Expanded(
            child: Text(
              widget.activeFile!.name,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (widget.activeFile!.hasUnsavedChanges)
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
          const SizedBox(width: Dimens.spacing),
          _buildToolbarActions(context),
        ],
      ),
    );
  }

  Widget _buildToolbarActions(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ToolbarButton(
          icon: Icons.format_bold,
          tooltip: 'Bold (Cmd+B)',
          onPressed: () => _insertMarkdown('**', '**'),
        ),
        _ToolbarButton(
          icon: Icons.format_italic,
          tooltip: 'Italic (Cmd+I)',
          onPressed: () => _insertMarkdown('*', '*'),
        ),
        _ToolbarButton(
          icon: Icons.format_strikethrough,
          tooltip: 'Strikethrough',
          onPressed: () => _insertMarkdown('~~', '~~'),
        ),
        const SizedBox(width: Dimens.halfSpacing),
        Container(
          width: 1,
          height: 24,
          color: Theme.of(context).dividerColor,
        ),
        const SizedBox(width: Dimens.halfSpacing),
        _ToolbarButton(
          icon: Icons.format_list_bulleted,
          tooltip: 'Bullet List',
          onPressed: () => _insertMarkdown('- ', ''),
        ),
        _ToolbarButton(
          icon: Icons.format_list_numbered,
          tooltip: 'Numbered List',
          onPressed: () => _insertMarkdown('1. ', ''),
        ),
        _ToolbarButton(
          icon: Icons.link,
          tooltip: 'Link',
          onPressed: () => _insertMarkdown('[', '](url)'),
        ),
        _ToolbarButton(
          icon: Icons.code,
          tooltip: 'Code',
          onPressed: () => _insertMarkdown('`', '`'),
        ),
        if (widget.isLoading) ...[
          const SizedBox(width: Dimens.spacing),
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
    );
  }

  Widget _buildEditor(BuildContext context) {
    if (widget.activeFile == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: Dimens.spacing),
            Text(
              'No file selected',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(Dimens.editorPadding),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        scrollController: _scrollController,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        style: TextStyle(
          fontSize: Dimens.editorFontSize,
          height: Dimens.editorLineHeight,
          fontFamily: 'SF Mono',
          fontFamilyFallback: const ['Monaco', 'Consolas', 'monospace'],
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

  void _insertMarkdown(String before, String after) {
    final selection = _controller.selection;
    final text = _controller.text;
    final selectedText = selection.textInside(text);
    
    final newText = text.replaceRange(
      selection.start,
      selection.end,
      '$before$selectedText$after',
    );
    
    _controller.text = newText;
    _controller.selection = TextSelection.collapsed(
      offset: selection.start + before.length + selectedText.length,
    );
    
    widget.onContentChanged(newText);
    _focusNode.requestFocus();
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'md':
      case 'markdown':
        return Icons.description;
      case 'txt':
        return Icons.text_snippet;
      case 'json':
        return Icons.data_object;
      default:
        return Icons.insert_drive_file;
    }
  }
}

class _EditorTab extends StatelessWidget {
  final MarkdownFile file;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const _EditorTab({
    required this.file,
    required this.isActive,
    required this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Dimens.editorTabWidth,
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).colorScheme.surface
            : Colors.transparent,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
          bottom: isActive
              ? BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                )
              : BorderSide.none,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimens.spacing,
              vertical: Dimens.halfSpacing,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.description,
                  size: Dimens.iconSizeXS,
                  color: isActive
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                const SizedBox(width: Dimens.quarterSpacing),
                Expanded(
                  child: Text(
                    file.name,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                      color: isActive
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (file.hasUnsavedChanges)
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(right: Dimens.quarterSpacing),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                InkWell(
                  onTap: onClose,
                  borderRadius: BorderRadius.circular(Dimens.fullRadius),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Icon(
                      Icons.close,
                      size: 14,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _ToolbarButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(Dimens.radius),
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 18,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }
}