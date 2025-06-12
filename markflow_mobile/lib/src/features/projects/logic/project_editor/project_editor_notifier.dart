import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:markflow/src/datasource/models/git_models.dart';
import 'package:markflow/src/datasource/models/project.dart';
import 'package:markflow/src/datasource/models/markdown_file.dart';
import 'package:markflow/src/datasource/repositories/project_repository.dart';
import 'package:markflow/src/datasource/repositories/file_repository.dart';
import 'package:markflow/src/datasource/repositories/git_repository.dart';
import 'package:markflow/src/features/projects/logic/project_editor/project_editor_state.dart';
import 'package:markflow/src/shared/locator.dart';
import 'package:markflow/src/shared/services/app_logger.dart';
import 'package:path/path.dart' as path;

/// Notifier for managing project editor state
class ProjectEditorNotifier extends ValueNotifier<ProjectEditorState> {
  final ProjectRepository _projectRepository;
  final FileRepository _fileRepository;
  final GitRepository _gitRepository;
  final AppLogger _logger;

  StreamSubscription<List<MarkdownFile>>? _fileWatchSubscription;
  Timer? _autoSaveTimer;

  ProjectEditorNotifier({
    ProjectRepository? projectRepository,
    FileRepository? fileRepository,
    GitRepository? gitRepository,
    AppLogger? logger,
  })  : _projectRepository = projectRepository ?? locator<ProjectRepository>(),
        _fileRepository = fileRepository ?? locator<FileRepository>(),
        _gitRepository = gitRepository ?? locator<GitRepository>(),
        _logger = logger ?? locator<AppLogger>(),
        super(const ProjectEditorState());

  /// Load a project for editing
  Future<void> loadProject(Project project) async {
    value = value.setLoading(true);

    try {
      // Update last opened time
      await _projectRepository.updateLastOpened(project);

      // Load project files
      final files = await _fileRepository.getProjectFiles(project.path);

      // Load Git status if available
      String? currentBranch;
      GitStatus? gitStatus;
      var recentCommits = <GitCommit>[];

      final isGitRepo = await _gitRepository.isGitRepository(project.path);
      if (isGitRepo) {
        currentBranch = await _gitRepository.getCurrentBranch(project.path);
        gitStatus = await _gitRepository.getStatus(project.path);
        recentCommits = await _gitRepository.getCommitHistory(
          project.path,
          limit: 10,
        );
      }

      value = value.copyWith(
        project: project,
        files: files,
        isLoading: false,
        gitStatus: gitStatus,
        currentBranch: currentBranch,
        recentCommits: recentCommits,
      );

      // Start watching for file changes
      _startFileWatching(project.path);
    } catch (e) {
      _logger.error('Failed to load project', e);
      value = value.setError('Failed to load project: ${e.toString()}');
    }
  }

  /// Open a file for editing
  Future<void> openFile(MarkdownFile file) async {
    try {
      // Save current file if it has unsaved changes
      if (value.hasUnsavedChanges && value.currentFile != null) {
        await _saveCurrentFile();
      }

      // Load file content
      final loadedFile = await _fileRepository.getFile(file.absolutePath);
      if (loadedFile == null) {
        value = value.setError('Failed to load file: ${file.name}');
        return;
      }

      value = value.copyWith(
        currentFile: loadedFile,
        currentContent: loadedFile.content,
        hasUnsavedChanges: false,
      );

      _startAutoSave();
    } catch (e) {
      _logger.error('Failed to open file', e);
      value = value.setError('Failed to open file: ${e.toString()}');
    }
  }

  /// Create a new file from file tree panel
  Future<void> createFile(String fileName) async {
    await createFileWithOptions(
      fileName: fileName,
    );
  }

  /// Create a new file with options
  Future<void> createFileWithOptions({
    required String fileName,
    String? content,
    String? subdirectory,
  }) async {
    if (value.project == null) {
      _logger.warning('Cannot create file: no project loaded');
      return;
    }

    _logger.info('Creating file: $fileName in project: ${value.project!.name}');

    try {
      final newFile = await _fileRepository.createFile(
        projectPath: value.project!.path,
        fileName: fileName,
        content: content,
        subdirectory: subdirectory,
      );

      if (newFile != null) {
        _logger.info('File created successfully: ${newFile.name}');
        
        // Refresh file list
        await _refreshFiles();
        _logger.info('Files refreshed. Current file count: ${value.files.length}');

        // Open the new file
        await openFile(newFile);
        _logger.info('New file opened: ${newFile.name}');
      } else {
        _logger.error('File creation returned null');
        value = value.setError('Failed to create file: File creation returned null');
      }
    } catch (e) {
      _logger.error('Failed to create file', e);
      value = value.setError('Failed to create file: ${e.toString()}');
    }
  }

  /// Update the content of the current file
  void updateContent(String content) {
    if (value.currentFile == null) return;

    final hasChanges = content != value.currentFile!.content;
    value = value.copyWith(
      currentContent: content,
      hasUnsavedChanges: hasChanges,
    );
  }

  /// Save the current file
  Future<bool> saveCurrentFile() async {
    return await _saveCurrentFile();
  }

  /// Internal method to save current file
  Future<bool> _saveCurrentFile() async {
    if (value.currentFile == null || !value.hasUnsavedChanges) {
      return true;
    }

    value = value.setSaving(true);

    try {
      final success = await _fileRepository.saveFile(
        value.currentFile!,
        value.currentContent,
      );

      if (success) {
        // Update the current file with new content
        final updatedFile = value.currentFile!.copyWith(
          content: () => value.currentContent,
          hasUnsavedChanges: false,
          lastModified: DateTime.now(),
        );

        value = value.copyWith(
          currentFile: updatedFile,
          hasUnsavedChanges: false,
          isSaving: false,
        );

        // Refresh Git status
        await refreshGitStatus();

        return true;
      } else {
        value = value.setError('Failed to save file');
        return false;
      }
    } catch (e) {
      _logger.error('Failed to save file', e);
      value = value.setError('Failed to save file: ${e.toString()}');
      return false;
    }
  }

  /// Delete a file
  Future<bool> deleteFile(MarkdownFile file) async {
    try {
      final success = await _fileRepository.deleteFile(file.absolutePath);

      if (success) {
        // If the deleted file was currently open, close it
        if (value.currentFile?.absolutePath == file.absolutePath) {
          value = value.clearCurrentFile();
        }

        // Refresh file list
        await _refreshFiles();

        // Refresh Git status
        await refreshGitStatus();

        return true;
      }

      return false;
    } catch (e) {
      _logger.error('Failed to delete file', e);
      value = value.setError('Failed to delete file: ${e.toString()}');
      return false;
    }
  }

  /// Rename a file
  Future<bool> renameFile(MarkdownFile file, String newName) async {
    try {
      final newPath = file.absolutePath.replaceAll(
        file.name,
        newName.endsWith('.md') ? newName : '$newName.md',
      );

      final success = await _fileRepository.renameFile(
        file.absolutePath,
        newPath,
      );

      if (success) {
        // Refresh file list
        await _refreshFiles();

        // If the renamed file was currently open, update it
        if (value.currentFile?.absolutePath == file.absolutePath) {
          final updatedFile = await _fileRepository.getFile(newPath);
          if (updatedFile != null) {
            value = value.copyWith(currentFile: updatedFile);
          }
        }

        // Refresh Git status
        await refreshGitStatus();

        return true;
      }

      return false;
    } catch (e) {
      _logger.error('Failed to rename file', e);
      value = value.setError('Failed to rename file: ${e.toString()}');
      return false;
    }
  }

  /// Set the current view
  void setView(ProjectEditorView view) {
    value = value.copyWith(currentView: view);
  }

  /// Toggle preview mode
  void togglePreviewMode() {
    value = value.copyWith(isPreviewMode: !value.isPreviewMode);
  }

  /// Stage files for Git commit
  Future<bool> stageFiles(List<String> filePaths) async {
    if (value.project == null) return false;

    try {
      final success = await _gitRepository.stageFiles(
        value.project!.path,
        filePaths,
      );

      if (success) {
        await refreshGitStatus();
      }

      return success;
    } catch (e) {
      _logger.error('Failed to stage files', e);
      value = value.setError('Failed to stage files: ${e.toString()}');
      return false;
    }
  }

  /// Commit changes
  Future<bool> commitChanges(String message) async {
    if (value.project == null) return false;

    try {
      final success = await _gitRepository.commit(
        value.project!.path,
        message,
      );

      if (success) {
        await refreshGitStatus();
        await _refreshCommitHistory();
      }

      return success;
    } catch (e) {
      _logger.error('Failed to commit changes', e);
      value = value.setError('Failed to commit changes: ${e.toString()}');
      return false;
    }
  }

  Future<void> stageFile(String filePath) async {
    await stageFiles([filePath]);
  }

  /// Unstage files for Git commit
  Future<bool> unstageFile(String filePath) async {
    if (value.project == null) return false;

    try {
      final success = await _gitRepository.unstageFiles(
        value.project!.path,
        [filePath],
      );

      if (success) {
        await refreshGitStatus();
      }

      return success;
    } catch (e) {
      _logger.error('Failed to unstage file', e);
      value = value.setError('Failed to unstage file: ${e.toString()}');
      return false;
    }
  }

  /// Create a new folder
  Future<bool> createFolder(String folderName) async {
    if (value.project == null) {
      _logger.warning('Cannot create folder: no project loaded');
      return false;
    }

    _logger.info('Creating folder: $folderName in project: ${value.project!.name}');

    try {
      final folderPath = path.join(value.project!.path, folderName);
      _logger.info('Folder path: $folderPath');
      
      final success = await _fileRepository.createDirectory(folderPath);
      _logger.info('Folder creation result: $success');

      if (success) {
        await _refreshFiles();
        _logger.info('Files refreshed after folder creation');
      }

      return success;
    } catch (e) {
      _logger.error('Failed to create folder', e);
      value = value.setError('Failed to create folder: ${e.toString()}');
      return false;
    }
  }

  /// Push changes to remote
  Future<bool> pushChanges() async {
    if (value.project == null) return false;

    try {
      final success = await _gitRepository.push(value.project!.path);

      if (success) {
        await refreshGitStatus();
      }

      return success;
    } catch (e) {
      _logger.error('Failed to push changes', e);
      value = value.setError('Failed to push changes: ${e.toString()}');
      return false;
    }
  }

  /// Pull changes from remote
  Future<bool> pullChanges() async {
    if (value.project == null) return false;

    try {
      final success = await _gitRepository.pull(value.project!.path);

      if (success) {
        await _refreshFiles();
        await refreshGitStatus();
        await _refreshCommitHistory();
      }

      return success;
    } catch (e) {
      _logger.error('Failed to pull changes', e);
      value = value.setError('Failed to pull changes: ${e.toString()}');
      return false;
    }
  }

  /// Clear error state
  void clearError() {
    value = value.clearError();
  }

  /// Start watching for file changes
  void _startFileWatching(String projectPath) {
    _fileWatchSubscription?.cancel();
    _fileWatchSubscription =
        _fileRepository.watchProjectFiles(projectPath).listen((files) {
      value = value.copyWith(files: files);
    });
  }

  /// Start auto-save timer
  void _startAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _saveCurrentFile(),
    );
  }

  /// Refresh file list
  Future<void> _refreshFiles() async {
    if (value.project == null) {
      _logger.warning('Cannot refresh files: no project loaded');
      return;
    }

    _logger.info('Refreshing files for project: ${value.project!.path}');

    try {
      final files = await _fileRepository.getProjectFiles(value.project!.path);
      _logger.info('Found ${files.length} files');
      
      final oldFileCount = value.files.length;
      value = value.copyWith(files: files);
      
      _logger.info('State updated: old count=$oldFileCount, new count=${value.files.length}');
    } catch (e) {
      _logger.error('Failed to refresh files', e);
    }
  }

  /// Refresh Git status
  Future<void> refreshGitStatus() async {
    if (value.project?.gitPath == null) return;

    try {
      final gitStatus = await _gitRepository.getStatus(value.project!.path);
      value = value.copyWith(gitStatus: gitStatus);
    } catch (e) {
      _logger.error('Failed to refresh Git status', e);
    }
  }

  /// Refresh commit history
  Future<void> _refreshCommitHistory() async {
    if (value.project?.gitPath == null) return;

    try {
      final commits = await _gitRepository.getCommitHistory(
        value.project!.path,
        limit: 10,
      );
      value = value.copyWith(recentCommits: commits);
    } catch (e) {
      _logger.error('Failed to refresh commit history', e);
    }
  }

  @override
  void dispose() {
    _fileWatchSubscription?.cancel();
    _autoSaveTimer?.cancel();

    // Stop watching files
    if (value.project != null) {
      _fileRepository.stopWatchingProject(value.project!.path);
    }

    super.dispose();
  }
}
