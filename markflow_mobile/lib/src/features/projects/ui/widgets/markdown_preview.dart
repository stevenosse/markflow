import 'package:flutter/material.dart';
import 'package:markflow/src/core/theme/dimens.dart';

class MarkdownPreview extends StatelessWidget {
  final String content;
  final String fileName;
  
  const MarkdownPreview({
    super.key,
    required this.content,
    required this.fileName,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        children: [
          _buildPreviewHeader(context),
          const Divider(height: 1),
          Expanded(
            child: _buildPreview(context),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPreviewHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimens.spacing),
      child: Row(
        children: [
          Icon(
            Icons.visibility,
            size: Dimens.iconSizeS,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          const SizedBox(width: Dimens.halfSpacing),
          Expanded(
            child: Text(
              'Preview - $fileName',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPreview(BuildContext context) {
    if (content.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.preview,
              size: Dimens.iconSizeXL,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: Dimens.spacing),
            Text(
              'Nothing to preview',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: Dimens.halfSpacing),
            Text(
              'Start typing in the editor to see the preview',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Dimens.editorPadding),
      child: _buildMarkdownContent(context),
    );
  }
  
  Widget _buildMarkdownContent(BuildContext context) {
    // For now, we'll display the raw markdown content
    // In a real implementation, you would use a markdown rendering package
    // like flutter_markdown or markdown_widget
    
    final lines = content.split('\n');
    final widgets = <Widget>[];
    
    for (final line in lines) {
      widgets.add(_parseMarkdownLine(context, line));
      widgets.add(const SizedBox(height: 4));
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
  
  Widget _parseMarkdownLine(BuildContext context, String line) {
    final trimmedLine = line.trim();
    
    // Headers
    if (trimmedLine.startsWith('# ')) {
      return Text(
        trimmedLine.substring(2),
        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      );
    }
    
    if (trimmedLine.startsWith('## ')) {
      return Text(
        trimmedLine.substring(3),
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      );
    }
    
    if (trimmedLine.startsWith('### ')) {
      return Text(
        trimmedLine.substring(4),
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      );
    }
    
    if (trimmedLine.startsWith('#### ')) {
      return Text(
        trimmedLine.substring(5),
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      );
    }
    
    if (trimmedLine.startsWith('##### ')) {
      return Text(
        trimmedLine.substring(6),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      );
    }
    
    if (trimmedLine.startsWith('###### ')) {
      return Text(
        trimmedLine.substring(7),
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      );
    }
    
    // Code blocks
    if (trimmedLine.startsWith('```')) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(Dimens.spacing),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(Dimens.radius),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          trimmedLine.substring(3),
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      );
    }
    
    // Inline code
    if (trimmedLine.contains('`')) {
      return _buildInlineCodeText(context, trimmedLine);
    }
    
    // Lists
    if (trimmedLine.startsWith('- ') || trimmedLine.startsWith('* ')) {
      return Padding(
        padding: const EdgeInsets.only(left: Dimens.spacing),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '•',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(width: Dimens.halfSpacing),
            Expanded(
              child: Text(
                trimmedLine.substring(2),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );
    }
    
    // Numbered lists
    final numberedListMatch = RegExp(r'^(\d+)\. (.*)').firstMatch(trimmedLine);
    if (numberedListMatch != null) {
      return Padding(
        padding: const EdgeInsets.only(left: Dimens.spacing),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${numberedListMatch.group(1)}.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(width: Dimens.halfSpacing),
            Expanded(
              child: Text(
                numberedListMatch.group(2) ?? '',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );
    }
    
    // Blockquotes
    if (trimmedLine.startsWith('> ')) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(Dimens.spacing),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 4,
            ),
          ),
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
        ),
        child: Text(
          trimmedLine.substring(2),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }
    
    // Empty line
    if (trimmedLine.isEmpty) {
      return const SizedBox(height: Dimens.halfSpacing);
    }
    
    // Regular paragraph
    return Text(
      line,
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }
  
  Widget _buildInlineCodeText(BuildContext context, String text) {
    final parts = <TextSpan>[];
    final regex = RegExp(r'`([^`]+)`');
    int lastEnd = 0;
    
    for (final match in regex.allMatches(text)) {
      // Add text before the code
      if (match.start > lastEnd) {
        parts.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: Theme.of(context).textTheme.bodyMedium,
        ));
      }
      
      // Add the code part
      parts.add(TextSpan(
        text: match.group(1),
        style: TextStyle(
          fontFamily: 'monospace',
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ));
      
      lastEnd = match.end;
    }
    
    // Add remaining text
    if (lastEnd < text.length) {
      parts.add(TextSpan(
        text: text.substring(lastEnd),
        style: Theme.of(context).textTheme.bodyMedium,
      ));
    }
    
    return RichText(
      text: TextSpan(children: parts),
    );
  }
}