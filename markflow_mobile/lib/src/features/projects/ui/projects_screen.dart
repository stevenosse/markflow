import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:markflow/src/core/theme/dimens.dart';
import 'package:markflow/src/datasource/models/project.dart';
import 'package:markflow/src/features/projects/logic/project_list/project_list_notifier.dart';
import 'package:markflow/src/features/projects/logic/project_list/project_list_state.dart';
import 'package:markflow/src/features/projects/ui/widgets/project_card.dart';
import 'package:markflow/src/features/projects/ui/widgets/project_search_bar.dart';
import 'package:markflow/src/features/projects/ui/widgets/project_filter_tabs.dart';
import 'package:markflow/src/features/projects/ui/widgets/empty_projects_state.dart';
import 'package:provider/provider.dart';

@RoutePage()
class ProjectsScreen extends StatefulWidget implements AutoRouteWrapper {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProjectListNotifier(),
      child: this,
    );
  }
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  @override
  void initState() {
    super.initState();
    // Load projects when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectListNotifier>().loadProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MarkFlow'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: ValueListenableBuilder<ProjectListState>(
        valueListenable: context.read<ProjectListNotifier>(),
        builder: (context, state, child) {
          return Column(
            children: [
              _buildHeader(context, state),
              Expanded(
                child: _buildBody(context, state),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateProjectDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ProjectListState state) {
    return Container(
      padding: const EdgeInsets.all(Dimens.spacing),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: Dimens.dividerThickness,
          ),
        ),
      ),
      child: Column(
        children: [
          ProjectSearchBar(
            searchQuery: state.searchQuery,
            onSearchChanged: context.read<ProjectListNotifier>().setSearchQuery,
          ),
          const SizedBox(height: Dimens.spacing),
          ProjectFilterTabs(
            currentFilter: state.filter,
            onFilterChanged: context.read<ProjectListNotifier>().setFilter,
            projectCounts: {
              ProjectListFilter.all: state.projects.length,
              ProjectListFilter.recent: state.recentProjects.length,
              ProjectListFilter.favorites: state.favoriteProjects.length,
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProjectListState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.showErrorState) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: Dimens.iconSizeXL,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: Dimens.spacing),
            Text(
              'Error loading projects',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: Dimens.halfSpacing),
            Text(
              state.error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Dimens.doubleSpacing),
            ElevatedButton(
              onPressed: () {
                context.read<ProjectListNotifier>().clearError();
                context.read<ProjectListNotifier>().loadProjects();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.showEmptyState) {
      return EmptyProjectsState(
        filter: state.filter,
        searchQuery: state.searchQuery,
        onCreateProject: () => _showCreateProjectDialog(context),
        onImportProject: () => _showImportProjectDialog(context),
        onCloneRepository: () => _showCloneRepositoryDialog(context),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<ProjectListNotifier>().loadProjects(),
      child: _buildProjectGrid(context, state),
    );
  }

  Widget _buildProjectGrid(BuildContext context, ProjectListState state) {
    final projects = state.filteredProjects;

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _calculateCrossAxisCount(constraints.maxWidth);

        return GridView.builder(
          padding: const EdgeInsets.all(Dimens.spacing),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio:
                Dimens.projectCardWidth / Dimens.projectCardHeight,
            crossAxisSpacing: Dimens.spacing,
            mainAxisSpacing: Dimens.spacing,
          ),
          itemCount: projects.length,
          itemBuilder: (context, index) {
            final project = projects[index];
            return ProjectCard(
              project: project,
              onTap: () => _openProject(context, project),
              onFavoriteToggle: () => context.read<ProjectListNotifier>().toggleFavorite(project),
              onDelete: () => _showDeleteProjectDialog(context, project),
              onRename: (newName) =>
                  context.read<ProjectListNotifier>().renameProject(project, newName),
            );
          },
        );
      },
    );
  }

  int _calculateCrossAxisCount(double width) {
    if (width >= Dimens.desktopBreakpoint) {
      return 4;
    } else if (width >= Dimens.tabletBreakpoint) {
      return 3;
    } else if (width >= Dimens.mobileBreakpoint) {
      return 2;
    } else {
      return 1;
    }
  }

  void _openProject(BuildContext context, Project project) {
    // Update last opened time
    context.read<ProjectListNotifier>().updateLastOpened(project);

    // Navigate to project editor
    Navigator.of(context).pushNamed(
      '/project-editor',
      arguments: project,
    );
  }

  void _showCreateProjectDialog(BuildContext context) {
    String projectName = '';
    showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New project'),
        content: TextField(
          decoration: const InputDecoration(
            labelText: 'Project name',
            hintText: 'my-project',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          onChanged: (value) => projectName = value,
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              Navigator.of(context).pop(value);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (projectName.isNotEmpty) {
                Navigator.of(context).pop(projectName);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    ).then((name) async {
      if (name != null && name.isNotEmpty && context.mounted) {
        // Default path is the project name in the documents directory
        final project = await context.read<ProjectListNotifier>().createProject(
          name: name,
          path: '/documents/$name',
        );
        if (project != null && context.mounted) {
          _openProject(context, project);
        }
      }
    });
  }

  void _showImportProjectDialog(BuildContext context) {
    // TODO: Implement import project dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Import project feature coming soon'),
      ),
    );
  }

  void _showCloneRepositoryDialog(BuildContext context) {
    // TODO: Implement clone repository dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Clone repository feature coming soon'),
      ),
    );
  }

  void _showDeleteProjectDialog(BuildContext context, Project project) {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "${project.name}"?'),
            const SizedBox(height: Dimens.spacing),
            const Text(
              'This will only remove the project from MarkFlow. '
              'Your files will remain on disk.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && context.mounted) {
        context.read<ProjectListNotifier>().deleteProject(project);
      }
    });
  }
}
