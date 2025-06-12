import 'dart:convert';
import 'package:markflow/src/shared/locator.dart';
import 'package:markflow/src/shared/services/storage/storage.dart';

import 'package:markflow/src/datasource/models/project.dart';
import 'package:markflow/src/core/services/file_service.dart';
import 'package:markflow/src/core/services/git_service.dart';
import 'package:markflow/src/shared/services/app_logger.dart';

/// Repository for managing MarkFlow projects
class ProjectRepository {
  static const String _projectsKey = 'markflow_projects';
  static const String _recentProjectsKey = 'markflow_recent_projects';
  
  final Storage _storage;
  final FileService _fileService;
  final GitService _gitService;
  final AppLogger _logger;
  
  ProjectRepository({
    Storage? storage,
    FileService? fileService,
    GitService? gitService,
    AppLogger? logger,
  }) : _storage = storage ?? locator<Storage>(),
       _fileService = fileService ?? locator<FileService>(),
       _gitService = gitService ?? locator<GitService>(),
       _logger = logger ?? locator<AppLogger>();
  
  /// Get all saved projects
  Future<List<Project>> getAllProjects() async {
    try {
      final projectsJson = _storage.getStringList(_projectsKey) ?? [];
      final projects = <Project>[];
      
      for (final projectJson in projectsJson) {
        try {
          final projectMap = jsonDecode(projectJson) as Map<String, dynamic>;
          final project = _projectFromMap(projectMap);
          
          // Verify project directory still exists
          if (await _fileService.directoryExists(project.path)) {
            projects.add(project);
          } else {
            _logger.warning('Project directory no longer exists: ${project.path}');
          }
        } catch (e) {
          _logger.error('Error parsing project JSON: $e');
        }
      }
      
      return projects;
    } catch (e) {
      _logger.error('Error getting all projects: $e');
      return [];
    }
  }
  
  /// Get recent projects (last 10)
  Future<List<Project>> getRecentProjects() async {
    try {
      final recentIds = _storage.getStringList(_recentProjectsKey) ?? [];
      final allProjects = await getAllProjects();
      
      final recentProjects = <Project>[];
      for (final id in recentIds) {
        final project = allProjects.where((p) => p.id == id).firstOrNull;
        if (project != null) {
          recentProjects.add(project);
        }
      }
      
      return recentProjects;
    } catch (e) {
      _logger.error('Error getting recent projects: $e');
      return [];
    }
  }
  
  /// Save a project
  Future<bool> saveProject(Project project) async {
    try {
      final allProjects = await getAllProjects();
      
      // Remove existing project with same ID if it exists
      allProjects.removeWhere((p) => p.id == project.id);
      
      // Add the new/updated project
      allProjects.add(project);
      
      // Save to preferences
      final projectsJson = allProjects
          .map((p) => jsonEncode(_projectToMap(p)))
          .toList();
      
      await _storage.writeStringList(key: _projectsKey, value: projectsJson);
      
      // Update recent projects
      await _addToRecentProjects(project.id);
      
      _logger.info('Project saved: ${project.name}');
      return true;
    } catch (e) {
      _logger.error('Error saving project: $e');
      return false;
    }
  }
  
  /// Delete a project
  Future<bool> deleteProject(Project project, {bool deleteFiles = false}) async {
    try {
      final projectId = project.id;
      final allProjects = await getAllProjects();
      final projectToDelete = allProjects.where((p) => p.id == projectId).firstOrNull;
      
      if (projectToDelete == null) {
        _logger.warning('Project not found for deletion: $projectId');
        return false;
      }
      
      // Delete project files if requested
      if (deleteFiles && project.path.isNotEmpty) {
        await _fileService.deleteDirectory(project.path);
        _logger.info('Project files deleted: ${project.path}');
      }
      
      // Remove from projects list
      allProjects.removeWhere((p) => p.id == projectId);
      
      // Save updated list
      final projectsJson = allProjects
          .map((p) => jsonEncode(_projectToMap(p)))
          .toList();
      
      await _storage.writeStringList(key: _projectsKey, value: projectsJson);
      
      // Remove from recent projects
      await _removeFromRecentProjects(projectId);
      
      _logger.info('Project deleted: ${projectToDelete.name}');
      return true;
    } catch (e) {
      _logger.error('Error deleting project: $e');
      return false;
    }
  }
  
  /// Create a new project
  Future<Project?> createProject({
    required String name,
    required String path,
    String? remoteUrl,
  }) async {
    try {
      // Create project directory
      if (!await _fileService.createDirectory(path)) {
        _logger.error('Failed to create project directory: $path');
        return null;
      }
      
      // Initialize Git repository
      if (!await _gitService.init(path)) {
        _logger.error('Failed to initialize Git repository: $path');
        return null;
      }
      
      // Create initial README.md file
      final readmePath = '$path/README.md';
      final readmeContent = '''# $name

Welcome to your MarkFlow project!

## Getting Started

This is your project's main documentation. You can:

- Create new markdown files
- Organize them in folders
- Use Git for version control
- Preview your content in real-time

Happy writing! 📝
''';
      
      if (!await _fileService.createFile(readmePath, readmeContent)) {
        _logger.warning('Failed to create initial README.md file');
      }
      
      // Create project object
      final project = Project(
        id: _generateProjectId(),
        name: name,
        path: path,
        gitPath: path,
        remoteUrl: remoteUrl,
        lastOpened: DateTime.now(),
      );
      
      // Save project
      if (await saveProject(project)) {
        _logger.info('New project created: $name at $path');
        return project;
      } else {
        _logger.error('Failed to save new project');
        return null;
      }
    } catch (e) {
      _logger.error('Error creating project: $e');
      return null;
    }
  }
  
  /// Clone an existing repository
  Future<Project?> cloneProject({
    required String name,
    required String url,
    required String path,
  }) async {
    try {
      // Clone the repository
      if (!await _gitService.clone(remoteUrl: url, localPath: path)) {
        _logger.error('Failed to clone repository: $url');
        return null;
      }
      
      // Create project object
      final project = Project(
        id: _generateProjectId(),
        name: name,
        path: path,
        gitPath: path,
        remoteUrl: url,
        lastOpened: DateTime.now(),
      );
      
      // Save project
      if (await saveProject(project)) {
        _logger.info('Repository cloned and project created: $name from $url');
        return project;
      } else {
        _logger.error('Failed to save cloned project');
        return null;
      }
    } catch (e) {
      _logger.error('Error cloning project: $e');
      return null;
    }
  }
  
  /// Update project's last opened time
  Future<bool> updateLastOpened(Project project) async {
    try {
      final allProjects = await getAllProjects();
      final projectIndex = allProjects.indexWhere((p) => p.id == project.id);
      
      if (projectIndex == -1) {
        _logger.warning('Project not found for update: ${project.id}');
        return false;
      }
      
      final updatedProject = allProjects[projectIndex].copyWith(
        lastOpened: DateTime.now(),
      );
      
      allProjects[projectIndex] = updatedProject;
      
      // Save updated list
      final projectsJson = allProjects
          .map((p) => jsonEncode(_projectToMap(p)))
          .toList();
      
      await _storage.writeStringList(key: _projectsKey, value: projectsJson);
      
      // Update recent projects
      await _addToRecentProjects(project.id);
      
      return true;
    } catch (e) {
      _logger.error('Error updating last opened: $e');
      return false;
    }
  }
  
  /// Toggle project favorite status
  Future<bool> toggleFavorite(String projectId) async {
    try {
      final allProjects = await getAllProjects();
      final projectIndex = allProjects.indexWhere((p) => p.id == projectId);
      
      if (projectIndex == -1) {
        _logger.warning('Project not found for favorite toggle: $projectId');
        return false;
      }
      
      final project = allProjects[projectIndex];
      final updatedProject = project.copyWith(
        isFavorite: !project.isFavorite,
      );
      
      allProjects[projectIndex] = updatedProject;
      
      // Save updated list
      final projectsJson = allProjects
          .map((p) => jsonEncode(_projectToMap(p)))
          .toList();
      
      await _storage.writeStringList(key: _projectsKey, value: projectsJson);
      
      _logger.info('Project favorite toggled: ${project.name}');
      return true;
    } catch (e) {
      _logger.error('Error toggling favorite: $e');
      return false;
    }
  }
  
  /// Import an existing project
  Future<Project?> importProject({
    required String path,
    String? name,
  }) async {
    try {
      // Check if directory exists
      if (!await _fileService.directoryExists(path)) {
        _logger.error('Directory does not exist: $path');
        return null;
      }
      
      // Use directory name as project name if not provided
      final projectName = name ?? _fileService.getBaseName(path);
      
      // Check if it's a Git repository
      final isGitRepo = await _gitService.isGitRepository(path);
      final gitPath = isGitRepo ? path : path; // Use path as default instead of null
      
      // Create project object
      final project = Project(
        id: _generateProjectId(),
        name: projectName,
        path: path,
        gitPath: gitPath,
        remoteUrl: null,
        lastOpened: DateTime.now(),
      );
      
      // Save project
      if (await saveProject(project)) {
        _logger.info('Project imported: $projectName from $path');
        return project;
      } else {
        _logger.error('Failed to save imported project');
        return null;
      }
    } catch (e) {
      _logger.error('Error importing project: $e');
      return null;
    }
  }
  
  /// Add project to recent projects list
  Future<void> _addToRecentProjects(String projectId) async {
    try {
      final recentIds = _storage.getStringList(_recentProjectsKey) ?? [];
      
      // Remove if already exists
      recentIds.remove(projectId);
      
      // Add to beginning
      recentIds.insert(0, projectId);
      
      // Keep only last 10
      if (recentIds.length > 10) {
        recentIds.removeRange(10, recentIds.length);
      }
      
      await _storage.writeStringList(key: _recentProjectsKey, value: recentIds);
    } catch (e) {
      _logger.error('Error adding to recent projects: $e');
    }
  }
  
  /// Remove project from recent projects list
  Future<void> _removeFromRecentProjects(String projectId) async {
    try {
      final recentIds = _storage.getStringList(_recentProjectsKey) ?? [];
      recentIds.remove(projectId);
      await _storage.writeStringList(key: _recentProjectsKey, value: recentIds);
    } catch (e) {
      _logger.error('Error removing from recent projects: $e');
    }
  }
  
  /// Generate a unique project ID
  String _generateProjectId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
  
  /// Convert Project to Map for JSON serialization
  Map<String, dynamic> _projectToMap(Project project) {
    return {
      'id': project.id,
      'name': project.name,
      'path': project.path,
      'gitPath': project.gitPath,
      'remoteUrl': project.remoteUrl,
      'lastOpened': project.lastOpened.millisecondsSinceEpoch,
      'isFavorite': project.isFavorite,
    };
  }
  
  /// Convert Map to Project from JSON deserialization
  Project _projectFromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] as String,
      name: map['name'] as String,
      path: map['path'] as String,
      gitPath: map['gitPath'] as String,
      remoteUrl: map['remoteUrl'] as String?,
      lastOpened: DateTime.fromMillisecondsSinceEpoch(map['lastOpened'] as int),
      isFavorite: map['isFavorite'] as bool? ?? false,
    );
  }
}