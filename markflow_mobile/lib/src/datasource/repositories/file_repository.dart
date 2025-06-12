import 'dart:async';
import 'dart:io';
import 'package:markflow/src/shared/locator.dart';
import 'package:path/path.dart' as path;
import 'package:markflow/src/datasource/models/markdown_file.dart';
import 'package:markflow/src/core/services/file_service.dart';
import 'package:markflow/src/shared/services/app_logger.dart';

/// Repository for managing markdown files within projects
class FileRepository {
  final FileService _fileService;
  final AppLogger _logger;

  // Cache for file contents to avoid frequent disk reads
  final Map<String, String> _contentCache = {};

  // Stream controllers for file watching
  final Map<String, StreamController<List<MarkdownFile>>> _fileListControllers =
      {};
  final Map<String, StreamSubscription> _fileWatchSubscriptions = {};

  FileRepository({
    FileService? fileService,
    AppLogger? logger,
  })  : _fileService = fileService ?? locator<FileService>(),
        _logger = logger ?? locator<AppLogger>();

  /// Get all markdown files in a project directory
  Future<List<MarkdownFile>> getProjectFiles(String projectPath) async {
    try {
      return await _fileService.getMarkdownFiles(projectPath);
    } catch (e) {
      _logger.error('Error getting project files: $e');
      return [];
    }
  }

  /// Get a specific file with its content loaded
  Future<MarkdownFile?> getFile(String filePath) async {
    try {
      if (!await _fileService.fileExists(filePath)) {
        _logger.warning('File does not exist: $filePath');
        return null;
      }

      final stat = await _fileService.getFileStat(filePath);
      if (stat == null) {
        _logger.error('Could not get file stats: $filePath');
        return null;
      }

      final content = await _fileService.readFile(filePath);
      if (content == null) {
        _logger.error('Could not read file content: $filePath');
        return null;
      }

      // Cache the content
      _contentCache[filePath] = content;

      final fileName = path.basename(filePath);

      return MarkdownFile(
        id: filePath,
        name: fileName,
        relativePath: fileName, // Will be updated by caller if needed
        absolutePath: filePath,
        content: content,
        lastModified: stat.modified,
        sizeBytes: stat.size,
      );
    } catch (e) {
      _logger.error('Error getting file $filePath: $e');
      return null;
    }
  }

  /// Create a new markdown file
  Future<MarkdownFile?> createFile({
    required String projectPath,
    required String fileName,
    String? content,
    String? subdirectory,
  }) async {
    try {
      // Ensure .md extension
      final finalFileName =
          fileName.endsWith('.md') ? fileName : '$fileName.md';

      // Build full path
      String filePath = projectPath;
      if (subdirectory != null && subdirectory.isNotEmpty) {
        filePath = path.join(filePath, subdirectory);
      }
      filePath = path.join(filePath, finalFileName);

      // Create the file
      final initialContent = content ??
          '''# ${path.basenameWithoutExtension(finalFileName)}

Your content here...
''';

      if (!await _fileService.createFile(filePath, initialContent)) {
        _logger.error('Failed to create file: $filePath');
        return null;
      }

      // Get the created file
      final createdFile = await getFile(filePath);
      if (createdFile != null) {
        // Update relative path
        final relativePath = path.relative(filePath, from: projectPath);
        final updatedFile = createdFile.copyWith(
          relativePath: relativePath,
        );

        _logger.info('File created: $filePath');
        return updatedFile;
      }

      return null;
    } catch (e) {
      _logger.error('Error creating file: $e');
      return null;
    }
  }

  /// Save file content
  Future<bool> saveFile(MarkdownFile file, String content) async {
    try {
      if (!await _fileService.writeFile(file.absolutePath, content)) {
        _logger.error('Failed to save file: ${file.absolutePath}');
        return false;
      }

      // Update cache
      _contentCache[file.absolutePath] = content;

      _logger.info('File saved: ${file.absolutePath}');
      return true;
    } catch (e) {
      _logger.error('Error saving file ${file.absolutePath}: $e');
      return false;
    }
  }

  /// Delete a file
  Future<bool> deleteFile(String filePath) async {
    try {
      if (!await _fileService.deleteFile(filePath)) {
        _logger.error('Failed to delete file: $filePath');
        return false;
      }

      // Remove from cache
      _contentCache.remove(filePath);

      _logger.info('File deleted: $filePath');
      return true;
    } catch (e) {
      _logger.error('Error deleting file $filePath: $e');
      return false;
    }
  }

  /// Rename a file
  Future<bool> renameFile(String oldPath, String newPath) async {
    try {
      if (!await _fileService.rename(oldPath, newPath)) {
        _logger.error('Failed to rename file: $oldPath to $newPath');
        return false;
      }

      // Update cache
      final content = _contentCache.remove(oldPath);
      if (content != null) {
        _contentCache[newPath] = content;
      }

      _logger.info('File renamed: $oldPath to $newPath');
      return true;
    } catch (e) {
      _logger.error('Error renaming file $oldPath to $newPath: $e');
      return false;
    }
  }

  /// Create a new directory
  Future<bool> createDirectory(String directoryPath) async {
    try {
      return await _fileService.createDirectory(directoryPath);
    } catch (e) {
      _logger.error('Error creating directory $directoryPath: $e');
      return false;
    }
  }

  /// Delete a directory
  Future<bool> deleteDirectory(String directoryPath) async {
    try {
      return await _fileService.deleteDirectory(directoryPath);
    } catch (e) {
      _logger.error('Error deleting directory $directoryPath: $e');
      return false;
    }
  }

  /// Get directory tree structure
  Future<List<FileSystemEntity>> getDirectoryTree(String directoryPath) async {
    try {
      return await _fileService.getDirectoryTree(directoryPath);
    } catch (e) {
      _logger.error('Error getting directory tree: $e');
      return [];
    }
  }

  /// Watch for file changes in a project directory
  Stream<List<MarkdownFile>> watchProjectFiles(String projectPath) {
    // Return existing stream if already watching
    if (_fileListControllers.containsKey(projectPath)) {
      return _fileListControllers[projectPath]!.stream;
    }

    // Create new stream controller
    final controller = StreamController<List<MarkdownFile>>.broadcast();
    _fileListControllers[projectPath] = controller;

    // Start watching the directory
    final watchSubscription = _fileService.watchDirectory(projectPath).listen(
      (event) async {
        try {
          // Debounce rapid file changes
          await Future.delayed(const Duration(milliseconds: 100));

          // Get updated file list
          final files = await getProjectFiles(projectPath);
          controller.add(files);
        } catch (e) {
          _logger.error('Error handling file watch event: $e');
        }
      },
      onError: (error) {
        _logger.error('File watch error for $projectPath: $error');
      },
    );

    _fileWatchSubscriptions[projectPath] = watchSubscription;

    // Add initial file list
    getProjectFiles(projectPath).then((files) {
      if (!controller.isClosed) {
        controller.add(files);
      }
    });

    // Clean up when stream is cancelled
    controller.onCancel = () {
      _stopWatchingProject(projectPath);
    };

    return controller.stream;
  }

  /// Stop watching a project directory
  void stopWatchingProject(String projectPath) {
    _stopWatchingProject(projectPath);
  }

  /// Internal method to stop watching
  void _stopWatchingProject(String projectPath) {
    final subscription = _fileWatchSubscriptions.remove(projectPath);
    subscription?.cancel();

    final controller = _fileListControllers.remove(projectPath);
    if (controller != null && !controller.isClosed) {
      controller.close();
    }
  }

  /// Search for files containing specific text
  Future<List<MarkdownFile>> searchFiles(
      String projectPath, String query) async {
    try {
      final allFiles = await getProjectFiles(projectPath);
      final matchingFiles = <MarkdownFile>[];

      for (final file in allFiles) {
        // Check filename first
        if (file.name.toLowerCase().contains(query.toLowerCase())) {
          matchingFiles.add(file);
          continue;
        }

        // Check content
        final content = await _fileService.readFile(file.absolutePath);
        if (content != null &&
            content.toLowerCase().contains(query.toLowerCase())) {
          matchingFiles.add(file.copyWith(
            content: () => content,
          ));
        }
      }

      return matchingFiles;
    } catch (e) {
      _logger.error('Error searching files: $e');
      return [];
    }
  }

  /// Get cached content for a file
  String? getCachedContent(String filePath) {
    return _contentCache[filePath];
  }

  /// Clear content cache
  void clearCache() {
    _contentCache.clear();
  }

  /// Clear cache for specific file
  void clearFileCache(String filePath) {
    _contentCache.remove(filePath);
  }

  /// Dispose of all resources
  void dispose() {
    // Cancel all file watch subscriptions
    for (final subscription in _fileWatchSubscriptions.values) {
      subscription.cancel();
    }
    _fileWatchSubscriptions.clear();

    // Close all stream controllers
    for (final controller in _fileListControllers.values) {
      if (!controller.isClosed) {
        controller.close();
      }
    }
    _fileListControllers.clear();

    // Clear cache
    _contentCache.clear();
  }
}
