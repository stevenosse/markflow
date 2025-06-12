import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Represents a MarkFlow project which corresponds to a Git repository
/// containing Markdown files.
class Project extends Equatable {
  /// Unique identifier for the project
  final String id;
  
  /// Display name of the project
  final String name;
  
  /// Full path to the project directory on the file system
  final String path;
  
  /// Path to the Git repository (may be the same as path)
  final String gitPath;
  
  /// Remote repository URL if available
  final String? remoteUrl;
  
  /// Last time the project was opened
  final DateTime lastOpened;
  
  /// Whether this is a favorite project
  final bool isFavorite;

  const Project({
    required this.id,
    required this.name,
    required this.path,
    required this.gitPath,
    this.remoteUrl,
    required this.lastOpened,
    this.isFavorite = false,
  });
  
  /// Creates a copy of this Project with the given fields replaced with new values
  Project copyWith({
    String? id,
    String? name,
    String? path,
    String? gitPath,
    ValueGetter<String?>? remoteUrl,
    DateTime? lastOpened,
    bool? isFavorite,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      gitPath: gitPath ?? this.gitPath,
      remoteUrl: remoteUrl != null ? remoteUrl() : this.remoteUrl,
      lastOpened: lastOpened ?? this.lastOpened,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
  
  @override
  List<Object?> get props => [id, name, path, gitPath, remoteUrl, lastOpened, isFavorite];
}