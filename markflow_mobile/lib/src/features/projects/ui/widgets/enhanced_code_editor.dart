import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markflow/src/core/theme/dimens.dart';
import 'package:markflow/src/features/projects/ui/widgets/syntax_highlighter.dart';

class EnhancedCodeEditor extends StatefulWidget {
  final String content;
  final String? fileName;
  final ValueChanged<String> onContentChanged;
  final bool readOnly;
  final bool showLineNumbers;
  
  const EnhancedCodeEditor({
    super.key,
    required this.content,
    this.fileName,
    required this.onContentChanged,
    this.readOnly = false,
    this.showLineNumbers = true,
  });
  
  @override
  State<EnhancedCodeEditor> createState() => _EnhancedCodeEditorState();
}

class _EnhancedCodeEditorState extends State<EnhancedCodeEditor> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final ScrollController _scrollController;
  late final ScrollController _lineNumberScrollController;
  
  int _lineCount = 1;
  
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.content);
    _focusNode = FocusNode();
    _scrollController = ScrollController();
    _lineNumberScrollController = ScrollController();
    
    _updateLineCount();
    _controller.addListener(_updateLineCount);
    
    // Sync scroll controllers
    _scrollController.addListener(() {
      if (_lineNumberScrollController.hasClients) {
        _lineNumberScrollController.jumpTo(_scrollController.offset);
      }
    });
  }
  
  @override
  void didUpdateWidget(EnhancedCodeEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.content != oldWidget.content && widget.content != _controller.text) {
      _controller.text = widget.content;
      _updateLineCount();
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    _lineNumberScrollController.dispose();
    super.dispose();
  }
  
  void _updateLineCount() {
    final newLineCount = '\n'.allMatches(_controller.text).length + 1;
    if (newLineCount != _lineCount) {
      setState(() {
        _lineCount = newLineCount;
      });
    }
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
      child: Row(
        children: [
          if (widget.showLineNumbers) _buildLineNumbers(context),
          Expanded(
            child: _buildEditor(context),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLineNumbers(BuildContext context) {
    final lineHeight = Dimens.editorFontSize * Dimens.editorLineHeight;
    
    return Container(
      width: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: ListView.builder(
        controller: _lineNumberScrollController,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          vertical: Dimens.editorPadding,
          horizontal: Dimens.halfSpacing,
        ),
        itemCount: _lineCount,
        itemBuilder: (context, index) {
          return Container(
            height: lineHeight,
            alignment: Alignment.centerRight,
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: Dimens.editorFontSize - 2,
                height: Dimens.editorLineHeight,
                fontFamily: 'SF Mono',
                fontFamilyFallback: const ['Monaco', 'Consolas', 'monospace'],
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildEditor(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimens.editorPadding),
      child: Stack(
        children: [
          // Syntax highlighted text (background)
          if (widget.fileName != null)
            SingleChildScrollView(
              controller: _scrollController,
              child: RichText(
                text: SyntaxHighlighter.highlight(
                  _controller.text,
                  widget.fileName,
                  context,
                ),
              ),
            ),
          // Transparent text field (foreground)
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            scrollController: _scrollController,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            readOnly: widget.readOnly,
            style: TextStyle(
              fontSize: Dimens.editorFontSize,
              height: Dimens.editorLineHeight,
              fontFamily: 'SF Mono',
              fontFamilyFallback: const ['Monaco', 'Consolas', 'monospace'],
              color: widget.fileName != null
                  ? Colors.transparent
                  : Theme.of(context).colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: widget.readOnly ? null : 'Start typing...',
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
            inputFormatters: [
              _TabInputFormatter(),
            ],
          ),
        ],
      ),
    );
  }
}

class _TabInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Handle tab insertion
    if (newValue.text.length > oldValue.text.length) {
      final insertedText = newValue.text.substring(
        oldValue.selection.start,
        oldValue.selection.start + (newValue.text.length - oldValue.text.length),
      );
      
      if (insertedText == '\t') {
        // Replace tab with spaces
        const tabSpaces = '  '; // 2 spaces
        final newText = newValue.text.replaceRange(
          oldValue.selection.start,
          oldValue.selection.start + 1,
          tabSpaces,
        );
        
        return TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(
            offset: oldValue.selection.start + tabSpaces.length,
          ),
        );
      }
    }
    
    return newValue;
  }
}