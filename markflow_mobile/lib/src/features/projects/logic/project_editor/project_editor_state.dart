import 'package:equatable/equatable.dart';
import 'package:markflow/src/datasource/models/project.dart';
import 'package:markflow/src/datasource/models/markdown_file.dart';
import 'package:markflow/src/datasource/models/git_models.dart';

/// State for the project editor feature
class ProjectEditorState extends Equatable {
  final Project? project;
  final List<MarkdownFile> files;
  final List<MarkdownFile> openFiles;
  final MarkdownFile? currentFile;
  final String currentContent;
  final bool hasUnsavedChanges;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final GitStatus? gitStatus;
  final List<GitCommit> recentCommits;
  final String? currentBranch;
  final ProjectEditorView currentView;
  final bool isPreviewMode;
  
  const ProjectEditorState({
    this.project,
    this.files = const [],
    this.openFiles = const [],
    this.currentFile,
    this.currentContent = '',
    this.hasUnsavedChanges = false,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.gitStatus,
    this.recentCommits = const [],
    this.currentBranch,
    this.currentView = ProjectEditorView.editor,
    this.isPreviewMode = false,
  });
  
  /// Check if a project is loaded
  bool get hasProject => project != null;
  
  /// Check if there are any files
  bool get hasFiles => files.isNotEmpty;
  
  /// Check if a file is currently open
  bool get hasCurrentFile => currentFile != null;
  
  /// Check if Git is available for this project
  bool get hasGit => project?.gitPath != null;
  
  /// Check if there are uncommitted changes
  bool get hasUncommittedChanges {
    if (gitStatus == null) return false;
    return gitStatus!.hasChanges;
  }
  
  /// Check if currently showing error state
  bool get showErrorState => error != null;
  
  /// Check if currently showing empty state
  bool get showEmptyState {
    return !isLoading && !hasFiles && !showErrorState;
  }
  
  /// Get the current file name for display
  String get currentFileName {
    return currentFile?.name ?? 'Untitled';
  }
  
  /// Check if current file has been modified
  bool get currentFileModified {
    if (currentFile == null) return false;
    return currentContent != currentFile!.content;
  }
  
  ProjectEditorState copyWith({
    Project? project,
    List<MarkdownFile>? files,
    List<MarkdownFile>? openFiles,
    MarkdownFile? currentFile,
    String? currentContent,
    bool? hasUnsavedChanges,
    bool? isLoading,
    bool? isSaving,
    String? error,
    GitStatus? gitStatus,
    List<GitCommit>? recentCommits,
    String? currentBranch,
    ProjectEditorView? currentView,
    bool? isPreviewMode,
  }) {
    return ProjectEditorState(
      project: project ?? this.project,
      files: files ?? this.files,
      openFiles: openFiles ?? this.openFiles,
      currentFile: currentFile ?? this.currentFile,
      currentContent: currentContent ?? this.currentContent,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error ?? this.error,
      gitStatus: gitStatus ?? this.gitStatus,
      recentCommits: recentCommits ?? this.recentCommits,
      currentBranch: currentBranch ?? this.currentBranch,
      currentView: currentView ?? this.currentView,
      isPreviewMode: isPreviewMode ?? this.isPreviewMode,
    );
  }
  
  /// Clear current file
  ProjectEditorState clearCurrentFile() {
    return copyWith(
      currentFile: null,
      currentContent: '',
      hasUnsavedChanges: false,
    );
  }
  
  /// Clear error state
  ProjectEditorState clearError() {
    return copyWith(error: null);
  }
  
  /// Set loading state
  ProjectEditorState setLoading(bool loading) {
    return copyWith(isLoading: loading, error: null);
  }
  
  /// Set saving state
  ProjectEditorState setSaving(bool saving) {
    return copyWith(isSaving: saving, error: null);
  }
  
  /// Set error state
  ProjectEditorState setError(String errorMessage) {
    return copyWith(error: errorMessage, isLoading: false, isSaving: false);
  }
  
  @override
  List<Object?> get props => [
    project,
    files,
    openFiles,
    currentFile,
    currentContent,
    hasUnsavedChanges,
    isLoading,
    isSaving,
    error,
    gitStatus,
    recentCommits,
    currentBranch,
    currentView,
    isPreviewMode,
  ];

  /// Add methods for managing open files
  ProjectEditorState openFile(MarkdownFile file) {
    final newOpenFiles = List<MarkdownFile>.from(openFiles);
    if (!newOpenFiles.any((f) => f.absolutePath == file.absolutePath)) {
      newOpenFiles.add(file);
    }
    return copyWith(
      openFiles: newOpenFiles,
      currentFile: file,
    );
  }

  ProjectEditorState closeFile(MarkdownFile file) {
    final newOpenFiles = openFiles.where((f) => f.absolutePath != file.absolutePath).toList();
    MarkdownFile? newCurrentFile = currentFile;
    
    if (currentFile?.absolutePath == file.absolutePath) {
      newCurrentFile = newOpenFiles.isNotEmpty ? newOpenFiles.last : null;
    }
    
    return copyWith(
      openFiles: newOpenFiles,
      currentFile: newCurrentFile,
      currentContent: newCurrentFile?.content ?? '',
      hasUnsavedChanges: false,
    );
  }

  ProjectEditorState switchToFile(MarkdownFile file) {
    return copyWith(
      currentFile: file,
      currentContent: file.content,
      hasUnsavedChanges: false,
    );
  }
}

/// Different views in the project editor
enum ProjectEditorView {
  editor,
  fileTree,
  git,
  split,
  preview,
}

extension ProjectEditorViewExtension on ProjectEditorView {
  String get displayName {
    switch (this) {
      case ProjectEditorView.editor:
        return 'Editor';
      case ProjectEditorView.fileTree:
        return 'Files';
      case ProjectEditorView.git:
        return 'Git';
      case ProjectEditorView.split:
        return 'Split';
      case ProjectEditorView.preview:
        return 'Preview';
    }
  }
  
  String get key {
    switch (this) {
      case ProjectEditorView.editor:
        return 'editor';
      case ProjectEditorView.fileTree:
        return 'files';
      case ProjectEditorView.git:
        return 'git';
      case ProjectEditorView.split:
        return 'split';
      case ProjectEditorView.preview:
        return 'preview';
    }
  }
}