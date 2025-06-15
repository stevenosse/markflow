import 'package:flutter/material.dart';

class SyntaxHighlighter {
  static TextSpan highlight(String text, String? fileName, BuildContext context) {
    final theme = Theme.of(context);
    final extension = fileName?.split('.').last.toLowerCase();
    
    switch (extension) {
      case 'md':
      case 'markdown':
        return _highlightMarkdown(text, theme);
      case 'json':
        return _highlightJson(text, theme);
      case 'yaml':
      case 'yml':
        return _highlightYaml(text, theme);
      default:
        return TextSpan(
          text: text,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
          ),
        );
    }
  }

  static TextSpan _highlightMarkdown(String text, ThemeData theme) {
    final spans = <TextSpan>[];
    final lines = text.split('\n');
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      spans.add(_highlightMarkdownLine(line, theme));
      if (i < lines.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }
    
    return TextSpan(children: spans);
  }

  static TextSpan _highlightMarkdownLine(String line, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    
    // Headers
    if (line.startsWith('#')) {
      final headerLevel = line.indexOf(' ');
      if (headerLevel > 0 && headerLevel <= 6) {
        return TextSpan(
          text: line,
          style: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 16 + (6 - headerLevel) * 2,
          ),
        );
      }
    }
    
    // Code blocks
    if (line.trim().startsWith('```')) {
      return TextSpan(
        text: line,
        style: TextStyle(
          color: colorScheme.secondary,
          fontFamily: 'monospace',
          backgroundColor: colorScheme.surfaceContainerHighest,
        ),
      );
    }
    
    // Blockquotes
    if (line.trim().startsWith('>')) {
      return TextSpan(
        text: line,
        style: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.7),
          fontStyle: FontStyle.italic,
        ),
      );
    }
    
    // Lists
    if (RegExp(r'^\s*[-*+]\s').hasMatch(line) || RegExp(r'^\s*\d+\.\s').hasMatch(line)) {
      return TextSpan(
        text: line,
        style: TextStyle(
          color: colorScheme.onSurface,
        ),
      );
    }
    
    // Process inline formatting
    return _highlightInlineMarkdown(line, theme);
  }

  static TextSpan _highlightInlineMarkdown(String text, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final spans = <TextSpan>[];
    final patterns = [
      // Bold
      RegExp(r'\*\*(.*?)\*\*'),
      // Italic
      RegExp(r'\*(.*?)\*'),
      // Code
      RegExp(r'`(.*?)`'),
      // Links
      RegExp(r'\[(.*?)\]\((.*?)\)'),
      // Strikethrough
      RegExp(r'~~(.*?)~~'),
    ];
    
    int lastEnd = 0;
    final matches = <MapEntry<int, Match>>[];
    
    // Find all matches
    for (final pattern in patterns) {
      for (final match in pattern.allMatches(text)) {
        matches.add(MapEntry(patterns.indexOf(pattern), match));
      }
    }
    
    // Sort matches by start position
    matches.sort((a, b) => a.value.start.compareTo(b.value.start));
    
    for (final entry in matches) {
      final patternIndex = entry.key;
      final match = entry.value;
      
      // Add text before match
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: TextStyle(color: colorScheme.onSurface),
        ));
      }
      
      // Add styled match
      switch (patternIndex) {
        case 0: // Bold
          spans.add(TextSpan(
            text: match.group(0)!,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ));
          break;
        case 1: // Italic
          spans.add(TextSpan(
            text: match.group(0)!,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontStyle: FontStyle.italic,
            ),
          ));
          break;
        case 2: // Code
          spans.add(TextSpan(
            text: match.group(0)!,
            style: TextStyle(
              color: colorScheme.secondary,
              fontFamily: 'monospace',
              backgroundColor: colorScheme.surfaceContainerHighest,
            ),
          ));
          break;
        case 3: // Links
          spans.add(TextSpan(
            text: match.group(0)!,
            style: TextStyle(
              color: colorScheme.primary,
              decoration: TextDecoration.underline,
            ),
          ));
          break;
        case 4: // Strikethrough
          spans.add(TextSpan(
            text: match.group(0)!,
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              decoration: TextDecoration.lineThrough,
            ),
          ));
          break;
      }
      
      lastEnd = match.end;
    }
    
    // Add remaining text
    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: TextStyle(color: colorScheme.onSurface),
      ));
    }
    
    return spans.isEmpty
        ? TextSpan(
            text: text,
            style: TextStyle(color: colorScheme.onSurface),
          )
        : TextSpan(children: spans);
  }

  static TextSpan _highlightJson(String text, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final spans = <TextSpan>[];
    
    final patterns = {
      // Strings
      RegExp(r'"(.*?)"'): colorScheme.tertiary,
      // Numbers
      RegExp(r'\b\d+\.?\d*\b'): colorScheme.secondary,
      // Booleans and null
      RegExp(r'\b(true|false|null)\b'): colorScheme.primary,
      // Keys (strings followed by colon)
      RegExp(r'"(.*?)"\s*:'): colorScheme.primary,
    };
    
    int lastEnd = 0;
    final matches = <MapEntry<Color, Match>>[];
    
    for (final entry in patterns.entries) {
      for (final match in entry.key.allMatches(text)) {
        matches.add(MapEntry(entry.value, match));
      }
    }
    
    matches.sort((a, b) => a.value.start.compareTo(b.value.start));
    
    for (final entry in matches) {
      final color = entry.key;
      final match = entry.value;
      
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: TextStyle(color: colorScheme.onSurface),
        ));
      }
      
      spans.add(TextSpan(
        text: match.group(0)!,
        style: TextStyle(color: color),
      ));
      
      lastEnd = match.end;
    }
    
    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: TextStyle(color: colorScheme.onSurface),
      ));
    }
    
    return spans.isEmpty
        ? TextSpan(
            text: text,
            style: TextStyle(color: colorScheme.onSurface),
          )
        : TextSpan(children: spans);
  }

  static TextSpan _highlightYaml(String text, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final spans = <TextSpan>[];
    final lines = text.split('\n');
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      
      // Comments
      if (line.trim().startsWith('#')) {
        spans.add(TextSpan(
          text: line,
          style: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            fontStyle: FontStyle.italic,
          ),
        ));
      }
      // Keys
      else if (line.contains(':')) {
        final colonIndex = line.indexOf(':');
        spans.add(TextSpan(
          text: line.substring(0, colonIndex + 1),
          style: TextStyle(color: colorScheme.primary),
        ));
        if (colonIndex + 1 < line.length) {
          spans.add(TextSpan(
            text: line.substring(colonIndex + 1),
            style: TextStyle(color: colorScheme.onSurface),
          ));
        }
      }
      // Regular text
      else {
        spans.add(TextSpan(
          text: line,
          style: TextStyle(color: colorScheme.onSurface),
        ));
      }
      
      if (i < lines.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }
    
    return TextSpan(children: spans);
  }
}