import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Represents a Markdown file within a project
class MarkdownFile extends Equatable {
  /// Unique identifier for the file (typically relative path from project root)
  final String id;
  
  /// Display name of the file (filename with extension)
  final String name;
  
  /// Relative path from the project root
  final String relativePath;
  
  /// Full absolute path to the file
  final String absolutePath;
  
  /// File content (loaded when needed)
  final String? content;
  
  /// Whether the file has unsaved changes
  final bool hasUnsavedChanges;
  
  /// Last modified timestamp
  final DateTime lastModified;
  
  /// File size in bytes
  final int sizeBytes;
  
  /// Whether this file is currently open in the editor
  final bool isOpen;

  const MarkdownFile({
    required this.id,
    required this.name,
    required this.relativePath,
    required this.absolutePath,
    this.content,
    this.hasUnsavedChanges = false,
    required this.lastModified,
    required this.sizeBytes,
    this.isOpen = false,
  });
  
  /// Creates a copy of this MarkdownFile with the given fields replaced with new values
  MarkdownFile copyWith({
    String? id,
    String? name,
    String? relativePath,
    String? absolutePath,
    ValueGetter<String?>? content,
    bool? hasUnsavedChanges,
    DateTime? lastModified,
    int? sizeBytes,
    bool? isOpen,
  }) {
    return MarkdownFile(
      id: id ?? this.id,
      name: name ?? this.name,
      relativePath: relativePath ?? this.relativePath,
      absolutePath: absolutePath ?? this.absolutePath,
      content: content != null ? content() : this.content,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      lastModified: lastModified ?? this.lastModified,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      isOpen: isOpen ?? this.isOpen,
    );
  }
  
  /// Returns true if the file is a Markdown file based on extension
  bool get isMarkdownFile {
    final extension = name.toLowerCase();
    return extension.endsWith('.md') || 
           extension.endsWith('.markdown') || 
           extension.endsWith('.mdown');
  }
  
  /// Returns the file extension
  String get extension {
    final lastDot = name.lastIndexOf('.');
    return lastDot != -1 ? name.substring(lastDot) : '';
  }
  
  @override
  List<Object?> get props => [
    id, 
    name, 
    relativePath, 
    absolutePath, 
    content, 
    hasUnsavedChanges, 
    lastModified, 
    sizeBytes, 
    isOpen
  ];
}