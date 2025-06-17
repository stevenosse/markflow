import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:markflow/src/datasource/models/project.dart';
import 'package:markflow/src/datasource/repositories/project_repository.dart';
import 'package:markflow/src/features/projects/logic/project_list/project_list_state.dart';
import 'package:markflow/src/shared/locator.dart';
import 'package:markflow/src/shared/services/app_logger.dart';

/// Notifier for managing project list state
class ProjectListNotifier extends ValueNotifier<ProjectListState> {
  final ProjectRepository _projectRepository;
  final AppLogger _logger;

  ProjectListNotifier({
    ProjectRepository? projectRepository,
    AppLogger? logger,
  })  : _projectRepository = projectRepository ?? locator<ProjectRepository>(),
        _logger = logger ?? locator<AppLogger>(),
        super(const ProjectListState());

  /// Load all projects
  Future<void> loadProjects() async {
    value = value.setLoading(true);

    try {
      final projects = await _projectRepository.getAllProjects();
      final recentProjects = await _projectRepository.getRecentProjects();
      final favoriteProjects = projects.where((p) => p.isFavorite).toList();

      value = value.copyWith(
        projects: projects,
        recentProjects: recentProjects,
        favoriteProjects: favoriteProjects,
        isLoading: false,
      );
    } catch (e) {
      _logger.error('Failed to load projects', e);
      value = value.setError('Failed to load projects: ${e.toString()}');
    }
  }

  /// Create a new project
  Future<Project?> createProject({
    required String name,
    String? path,
  }) async {
    try {
      final project = await _projectRepository.createProject(
        name: name,
        path: path,
      );

      if (project != null) {
        await _refreshProjects();
      }

      return project;
    } catch (e) {
      _logger.error('Failed to create project', e);
      value = value.setError('Failed to create project: ${e.toString()}');
      return null;
    }
  }

  /// Clone a Git repository as a new project
  Future<Project?> cloneRepository({
    required String name,
    required String path,
    required String remoteUrl,
    String? branch,
  }) async {
    try {
      final project = await _projectRepository.cloneProject(
        name: name,
        path: path,
        url: remoteUrl,
      );

      if (project != null) {
        await _refreshProjects();
      }

      return project;
    } catch (e) {
      _logger.error('Failed to clone repository', e);
      value = value.setError('Failed to clone repository: ${e.toString()}');
      return null;
    }
  }

  /// Import an existing project
  Future<Project?> importProject({
    required String path,
    String? name,
  }) async {
    try {
      final project = await _projectRepository.importProject(
        path: path,
        name: name,
      );

      if (project != null) {
        await _refreshProjects();
      }

      return project;
    } catch (e) {
      _logger.error('Failed to import project', e);
      value = value.setError('Failed to import project: ${e.toString()}');
      return null;
    }
  }

  /// Delete a project
  Future<bool> deleteProject(Project project,
      {bool deleteFiles = false}) async {
    try {
      final success = await _projectRepository.deleteProject(
        project,
        deleteFiles: deleteFiles,
      );

      if (success) {
        await _refreshProjects();
      }

      return success;
    } catch (e) {
      _logger.error('Failed to delete project', e);
      value = value.setError('Failed to delete project: ${e.toString()}');
      return false;
    }
  }

  /// Toggle favorite status for a project
  Future<void> toggleFavorite(Project project) async {
    try {
      final updatedProject = project.copyWith(
        isFavorite: !project.isFavorite,
      );

      // Update state immediately for UI responsiveness
      final updatedProjects = List<Project>.from(value.projects);
      final index = updatedProjects.indexWhere((p) => p.id == project.id);
      if (index != -1) {
        updatedProjects[index] = updatedProject;
      }

      final updatedFavorites = updatedProject.isFavorite
          ? [...value.favoriteProjects, updatedProject]
          : value.favoriteProjects.where((p) => p.id != project.id).toList();

      value = value.copyWith(
        projects: updatedProjects,
        favoriteProjects: updatedFavorites,
      );

      // Then save to repository and refresh
      await _projectRepository.saveProject(updatedProject);
      await _refreshProjects();
    } catch (e) {
      _logger.error('Failed to toggle favorite status', e);
      value = value.setError('Failed to update project: ${e.toString()}');
    }
  }

  /// Rename a project
  Future<void> renameProject(Project project, String newName) async {
    try {
      final updatedProject = project.copyWith(name: newName);

      // Update state immediately for UI responsiveness
      final updatedProjects = List<Project>.from(value.projects);
      final index = updatedProjects.indexWhere((p) => p.id == project.id);
      if (index != -1) {
        updatedProjects[index] = updatedProject;
      }

      // Update in favorites list if present
      final updatedFavorites = List<Project>.from(value.favoriteProjects);
      final favoriteIndex =
          updatedFavorites.indexWhere((p) => p.id == project.id);
      if (favoriteIndex != -1) {
        updatedFavorites[favoriteIndex] = updatedProject;
      }

      // Update in recent projects list if present
      final updatedRecents = List<Project>.from(value.recentProjects);
      final recentIndex = updatedRecents.indexWhere((p) => p.id == project.id);
      if (recentIndex != -1) {
        updatedRecents[recentIndex] = updatedProject;
      }

      value = value.copyWith(
        projects: updatedProjects,
        favoriteProjects: updatedFavorites,
        recentProjects: updatedRecents,
      );

      // Then save to repository and refresh
      await _projectRepository.saveProject(updatedProject);
      await _refreshProjects();
    } catch (e) {
      _logger.error('Failed to rename project', e);
      value = value.setError('Failed to rename project: ${e.toString()}');
    }
  }

  /// Update project last opened time
  Future<void> updateLastOpened(Project project) async {
    try {
      await _projectRepository.updateLastOpened(project);
      await _refreshProjects();
    } catch (e) {
      _logger.error('Failed to update last opened time', e);
      // Don't show error to user for this non-critical operation
    }
  }

  /// Set filter for project list
  void setFilter(ProjectListFilter filter) {
    value = value.copyWith(filter: filter);
  }

  /// Set search query
  void setSearchQuery(String query) {
    value = value.copyWith(searchQuery: query);
  }

  /// Clear error state
  void clearError() {
    value = value.clearError();
  }

  /// Refresh projects from repository
  Future<void> _refreshProjects() async {
    try {
      final projects = await _projectRepository.getAllProjects();
      final recentProjects = await _projectRepository.getRecentProjects();
      final favoriteProjects = projects.where((p) => p.isFavorite).toList();

      value = value.copyWith(
        projects: projects,
        recentProjects: recentProjects,
        favoriteProjects: favoriteProjects,
      );
    } catch (e) {
      _logger.error('Failed to refresh projects', e);
      // Don't update error state here to avoid disrupting the UI
      // during background refreshes
    }
  }
}
