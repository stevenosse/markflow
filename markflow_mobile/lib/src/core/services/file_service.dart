import 'dart:io';
import 'dart:convert';
import 'package:markflow/src/shared/locator.dart';
import 'package:path/path.dart' as path;
import 'package:markflow/src/datasource/models/markdown_file.dart';
import 'package:markflow/src/shared/services/app_logger.dart';

/// Service for handling file system operations
class FileService {
  final AppLogger _logger;
  
  FileService({
    AppLogger? logger,
  }) : _logger = logger ?? locator<AppLogger>();
  
  /// Create a new directory
  Future<bool> createDirectory(String directoryPath) async {
    try {
      final directory = Directory(directoryPath);
      if (await directory.exists()) {
        _logger.warning('Directory already exists: $directoryPath');
        return true;
      }
      
      await directory.create(recursive: true);
      _logger.info('Directory created: $directoryPath');
      return true;
    } catch (e) {
      _logger.error('Error creating directory $directoryPath: $e');
      return false;
    }
  }
  
  /// Create a new file with optional content
  Future<bool> createFile(String filePath, [String? content]) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        _logger.warning('File already exists: $filePath');
        return false;
      }
      
      // Ensure parent directory exists
      final parentDir = Directory(path.dirname(filePath));
      if (!await parentDir.exists()) {
        await parentDir.create(recursive: true);
      }
      
      await file.writeAsString(content ?? '', encoding: utf8);
      _logger.info('File created: $filePath');
      return true;
    } catch (e) {
      _logger.error('Error creating file $filePath: $e');
      return false;
    }
  }
  
  /// Read file content
  Future<String?> readFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        _logger.warning('File does not exist: $filePath');
        return null;
      }
      
      final content = await file.readAsString(encoding: utf8);
      return content;
    } catch (e) {
      _logger.error('Error reading file $filePath: $e');
      return null;
    }
  }
  
  /// Write content to file
  Future<bool> writeFile(String filePath, String content) async {
    try {
      final file = File(filePath);
      
      // Ensure parent directory exists
      final parentDir = Directory(path.dirname(filePath));
      if (!await parentDir.exists()) {
        await parentDir.create(recursive: true);
      }
      
      await file.writeAsString(content, encoding: utf8);
      _logger.info('File written: $filePath');
      return true;
    } catch (e) {
      _logger.error('Error writing file $filePath: $e');
      return false;
    }
  }
  
  /// Delete a file
  Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        _logger.warning('File does not exist: $filePath');
        return true;
      }
      
      await file.delete();
      _logger.info('File deleted: $filePath');
      return true;
    } catch (e) {
      _logger.error('Error deleting file $filePath: $e');
      return false;
    }
  }
  
  /// Delete a directory and its contents
  Future<bool> deleteDirectory(String directoryPath) async {
    try {
      final directory = Directory(directoryPath);
      if (!await directory.exists()) {
        _logger.warning('Directory does not exist: $directoryPath');
        return true;
      }
      
      await directory.delete(recursive: true);
      _logger.info('Directory deleted: $directoryPath');
      return true;
    } catch (e) {
      _logger.error('Error deleting directory $directoryPath: $e');
      return false;
    }
  }
  
  /// Rename/move a file or directory
  Future<bool> rename(String oldPath, String newPath) async {
    try {
      final oldEntity = FileSystemEntity.typeSync(oldPath);
      
      if (oldEntity == FileSystemEntityType.notFound) {
        _logger.warning('Source does not exist: $oldPath');
        return false;
      }
      
      // Ensure parent directory of new path exists
      final parentDir = Directory(path.dirname(newPath));
      if (!await parentDir.exists()) {
        await parentDir.create(recursive: true);
      }
      
      if (oldEntity == FileSystemEntityType.file) {
        await File(oldPath).rename(newPath);
      } else if (oldEntity == FileSystemEntityType.directory) {
        await Directory(oldPath).rename(newPath);
      }
      
      _logger.info('Renamed $oldPath to $newPath');
      return true;
    } catch (e) {
      _logger.error('Error renaming $oldPath to $newPath: $e');
      return false;
    }
  }
  
  /// Get all markdown files in a directory recursively
  Future<List<MarkdownFile>> getMarkdownFiles(String directoryPath) async {
    try {
      _logger.info('Scanning for markdown files in: $directoryPath');
      
      final directory = Directory(directoryPath);
      if (!await directory.exists()) {
        _logger.warning('Directory does not exist: $directoryPath');
        return [];
      }
      
      final files = <MarkdownFile>[];
      await for (final entity in directory.list(recursive: true)) {
        if (entity is File) {
          final fileName = path.basename(entity.path);
          _logger.debug('Found file: $fileName');
          
          if (_isMarkdownFile(fileName)) {
            _logger.info('Adding markdown file: $fileName');
            
            final stat = await entity.stat();
            final relativePath = path.relative(entity.path, from: directoryPath);
            
            files.add(MarkdownFile(
              id: relativePath,
              name: fileName,
              relativePath: relativePath,
              absolutePath: entity.path,
              lastModified: stat.modified,
              sizeBytes: stat.size,
            ));
          }
        }
      }
      
      _logger.info('Found ${files.length} markdown files total');
      return files;
    } catch (e) {
      _logger.error('Error getting markdown files from $directoryPath: $e');
      return [];
    }
  }
  
  /// Get directory structure as a tree
  Future<List<FileSystemEntity>> getDirectoryTree(String directoryPath) async {
    try {
      final directory = Directory(directoryPath);
      if (!await directory.exists()) {
        _logger.warning('Directory does not exist: $directoryPath');
        return [];
      }
      
      final entities = <FileSystemEntity>[];
      await for (final entity in directory.list()) {
        entities.add(entity);
      }
      
      // Sort: directories first, then files, both alphabetically
      entities.sort((a, b) {
        final aIsDir = a is Directory;
        final bIsDir = b is Directory;
        
        if (aIsDir && !bIsDir) return -1;
        if (!aIsDir && bIsDir) return 1;
        
        return path.basename(a.path).toLowerCase()
            .compareTo(path.basename(b.path).toLowerCase());
      });
      
      return entities;
    } catch (e) {
      _logger.error('Error getting directory tree for $directoryPath: $e');
      return [];
    }
  }
  
  /// Check if a file exists
  Future<bool> fileExists(String filePath) async {
    try {
      return await File(filePath).exists();
    } catch (e) {
      _logger.error('Error checking if file exists $filePath: $e');
      return false;
    }
  }
  
  /// Check if a directory exists
  Future<bool> directoryExists(String directoryPath) async {
    try {
      return await Directory(directoryPath).exists();
    } catch (e) {
      _logger.error('Error checking if directory exists $directoryPath: $e');
      return false;
    }
  }
  
  /// Get file statistics
  Future<FileStat?> getFileStat(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return null;
      }
      
      return await file.stat();
    } catch (e) {
      _logger.error('Error getting file stat for $filePath: $e');
      return null;
    }
  }
  
  /// Watch a directory for changes
  Stream<FileSystemEvent> watchDirectory(String directoryPath) {
    try {
      final directory = Directory(directoryPath);
      return directory.watch(recursive: true);
    } catch (e) {
      _logger.error('Error watching directory $directoryPath: $e');
      return const Stream.empty();
    }
  }
  
  /// Copy a file
  Future<bool> copyFile(String sourcePath, String destinationPath) async {
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        _logger.warning('Source file does not exist: $sourcePath');
        return false;
      }
      
      // Ensure parent directory exists
      final parentDir = Directory(path.dirname(destinationPath));
      if (!await parentDir.exists()) {
        await parentDir.create(recursive: true);
      }
      
      await sourceFile.copy(destinationPath);
      _logger.info('File copied from $sourcePath to $destinationPath');
      return true;
    } catch (e) {
      _logger.error('Error copying file from $sourcePath to $destinationPath: $e');
      return false;
    }
  }
  
  /// Get the size of a directory
  Future<int> getDirectorySize(String directoryPath) async {
    try {
      final directory = Directory(directoryPath);
      if (!await directory.exists()) {
        return 0;
      }
      
      int totalSize = 0;
      await for (final entity in directory.list(recursive: true)) {
        if (entity is File) {
          final stat = await entity.stat();
          totalSize += stat.size;
        }
      }
      
      return totalSize;
    } catch (e) {
      _logger.error('Error getting directory size for $directoryPath: $e');
      return 0;
    }
  }
  
  /// Check if a file name represents a markdown file
  bool _isMarkdownFile(String fileName) {
    final extension = path.extension(fileName).toLowerCase();
    return extension == '.md' || 
           extension == '.markdown' || 
           extension == '.mdown';
  }
  
  /// Get the base name (last segment) of a path
  String getBaseName(String filePath) {
    try {
      return path.basename(filePath);
    } catch (e) {
      _logger.error('Error getting base name for $filePath: $e');
      return filePath.split(Platform.pathSeparator).last;
    }
  }
}