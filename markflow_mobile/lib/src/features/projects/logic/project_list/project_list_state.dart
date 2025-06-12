import 'package:equatable/equatable.dart';
import 'package:markflow/src/datasource/models/project.dart';

/// State for the project list feature
class ProjectListState extends Equatable {
  final List<Project> projects;
  final List<Project> recentProjects;
  final List<Project> favoriteProjects;
  final bool isLoading;
  final String? error;
  final ProjectListFilter filter;
  final String searchQuery;
  
  const ProjectListState({
    this.projects = const [],
    this.recentProjects = const [],
    this.favoriteProjects = const [],
    this.isLoading = false,
    this.error,
    this.filter = ProjectListFilter.all,
    this.searchQuery = '',
  });
  
  /// Get filtered projects based on current filter and search query
  List<Project> get filteredProjects {
    List<Project> baseList;
    
    switch (filter) {
      case ProjectListFilter.all:
        baseList = projects;
        break;
      case ProjectListFilter.recent:
        baseList = recentProjects;
        break;
      case ProjectListFilter.favorites:
        baseList = favoriteProjects;
        break;
    }
    
    if (searchQuery.isEmpty) {
      return baseList;
    }
    
    final query = searchQuery.toLowerCase();
    return baseList.where((project) {
      return project.name.toLowerCase().contains(query) ||
             project.path.toLowerCase().contains(query) ||
             (project.remoteUrl?.toLowerCase().contains(query) ?? false);
    }).toList();
  }
  
  /// Check if there are any projects
  bool get hasProjects => projects.isNotEmpty;
  
  /// Check if there are any recent projects
  bool get hasRecentProjects => recentProjects.isNotEmpty;
  
  /// Check if there are any favorite projects
  bool get hasFavoriteProjects => favoriteProjects.isNotEmpty;
  
  /// Check if currently showing empty state
  bool get showEmptyState {
    return !isLoading && filteredProjects.isEmpty && error == null;
  }
  
  /// Check if currently showing error state
  bool get showErrorState => error != null;
  
  ProjectListState copyWith({
    List<Project>? projects,
    List<Project>? recentProjects,
    List<Project>? favoriteProjects,
    bool? isLoading,
    String? error,
    ProjectListFilter? filter,
    String? searchQuery,
  }) {
    return ProjectListState(
      projects: projects ?? this.projects,
      recentProjects: recentProjects ?? this.recentProjects,
      favoriteProjects: favoriteProjects ?? this.favoriteProjects,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
  
  /// Clear error state
  ProjectListState clearError() {
    return copyWith(error: null);
  }
  
  /// Set loading state
  ProjectListState setLoading(bool loading) {
    return copyWith(isLoading: loading, error: null);
  }
  
  /// Set error state
  ProjectListState setError(String errorMessage) {
    return copyWith(error: errorMessage, isLoading: false);
  }
  
  @override
  List<Object?> get props => [
    projects,
    recentProjects,
    favoriteProjects,
    isLoading,
    error,
    filter,
    searchQuery,
  ];
}

/// Filter options for project list
enum ProjectListFilter {
  all,
  recent,
  favorites,
}

extension ProjectListFilterExtension on ProjectListFilter {
  String get displayName {
    switch (this) {
      case ProjectListFilter.all:
        return 'All Projects';
      case ProjectListFilter.recent:
        return 'Recent';
      case ProjectListFilter.favorites:
        return 'Favorites';
    }
  }
  
  String get key {
    switch (this) {
      case ProjectListFilter.all:
        return 'all';
      case ProjectListFilter.recent:
        return 'recent';
      case ProjectListFilter.favorites:
        return 'favorites';
    }
  }
}