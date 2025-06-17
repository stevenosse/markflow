import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:markflow/src/core/routing/app_router.dart';
import 'package:markflow/src/core/theme/dimens.dart';
import 'package:markflow/src/datasource/models/project.dart';
import 'package:markflow/src/features/projects/logic/project_list/project_list_notifier.dart';
import 'package:markflow/src/features/projects/logic/project_list/project_list_state.dart';
import 'package:markflow/src/features/projects/ui/widgets/project_card.dart';
import 'package:markflow/src/features/projects/ui/widgets/project_search_bar.dart';
import 'package:markflow/src/features/projects/ui/widgets/project_filter_tabs.dart';
import 'package:markflow/src/features/projects/ui/widgets/empty_projects_state.dart';
import 'package:markflow/src/features/projects/ui/widgets/project_action_dialog.dart';
import 'package:markflow/src/shared/components/shortcuts/projects_shortcuts.dart';
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

  void _openProject(BuildContext context, Project project) {
    context.read<ProjectListNotifier>().updateLastOpened(project);
    context.router.push(ProjectEditorRoute(project: project));
  }

  void _showCreateProjectDialog(BuildContext context) {
    ProjectActionDialog.show(
      context,
      initialAction: ProjectActionType.create,
      hasExistingProjects: true,
    ).then((result) async {
      if (result != null && context.mounted) {
        if (result is CreateProjectResult) {
          await context.read<ProjectListNotifier>().createProject(
            name: result.name,
          );
        } else if (result is ImportProjectResult) {
          await context.read<ProjectListNotifier>().importProject(
            path: result.path,
            name: result.name,
          );
        } else if (result is CloneRepositoryResult) {
          await context.read<ProjectListNotifier>().cloneRepository(
            name: result.name ?? 'project',
            path: result.path ?? '',
            remoteUrl: result.url,
          );
        }
      }
    });
  }

  void _showDeleteProjectDialog(BuildContext context, Project project) {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
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

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ProjectListState>(
      valueListenable: context.read<ProjectListNotifier>(),
      builder: (context, state, child) {
        return ProjectsShortcuts(
          notifier: context.read<ProjectListNotifier>(),
          state: state,
          child: Scaffold(
            body: Column(
              children: [
                DesktopHeader(
                  state: state,
                  onCreateProject: () => _showCreateProjectDialog(context),
                ),
                Expanded(
                  child: DesktopBody(
                    state: state,
                    onOpenProject: (project) =>
                        _openProject(context, project),
                    onDeleteProject: (project) =>
                        _showDeleteProjectDialog(context, project),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class DesktopHeader extends StatelessWidget {
  final ProjectListState state;
  final VoidCallback onCreateProject;

  const DesktopHeader({
    super.key,
    required this.state,
    required this.onCreateProject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Dimens.desktopHeaderHeight,
      padding: const EdgeInsets.symmetric(
        horizontal: Dimens.desktopMainPadding,
        vertical: Dimens.spacing,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            'MarkFlow',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const Spacer(),
          SizedBox(
            width: Dimens.desktopSearchBarWidth,
            child: ProjectSearchBar(
              searchQuery: state.searchQuery,
              onSearchChanged:
                  context.read<ProjectListNotifier>().setSearchQuery,
            ),
          ),
          const SizedBox(width: Dimens.desktopSpacing),
          ElevatedButton.icon(
            onPressed: onCreateProject,
            icon: Icon(Icons.add, size: Dimens.desktopIconSize),
            label: const Text('New project'),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(120, Dimens.desktopButtonHeight),
            ),
          ),
          const SizedBox(width: Dimens.spacing),
          IconButton(
            icon: Icon(Icons.settings, size: Dimens.desktopIconSize),
            onPressed: () => context.router.push(SettingsRoute()),
            tooltip: 'Settings',
            style: IconButton.styleFrom(
              minimumSize:
                  Size(Dimens.desktopButtonHeight, Dimens.desktopButtonHeight),
            ),
          ),
        ],
      ),
    );
  }
}

class DesktopBody extends StatelessWidget {
  final ProjectListState state;
  final Function(Project) onOpenProject;
  final Function(Project) onDeleteProject;

  const DesktopBody({
    super.key,
    required this.state,
    required this.onOpenProject,
    required this.onDeleteProject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimens.desktopMainPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProjectFilterTabs(
            currentFilter: state.filter,
            onFilterChanged: context.read<ProjectListNotifier>().setFilter,
            projectCounts: {
              ProjectListFilter.all: state.projects.length,
              ProjectListFilter.recent: state.recentProjects.length,
              ProjectListFilter.favorites: state.favoriteProjects.length,
            },
          ),
          const SizedBox(height: Dimens.desktopSpacing),
          Expanded(
            child: DesktopContent(
              state: state,
              onOpenProject: onOpenProject,
              onDeleteProject: onDeleteProject,
            ),
          ),
        ],
      ),
    );
  }
}

class DesktopContent extends StatelessWidget {
  final ProjectListState state;
  final Function(Project) onOpenProject;
  final Function(Project) onDeleteProject;

  const DesktopContent({
    super.key,
    required this.state,
    required this.onOpenProject,
    required this.onDeleteProject,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.showErrorState) {
      return ErrorStateWidget(
        error: state.error!,
        onRetry: () {
          context.read<ProjectListNotifier>().clearError();
          context.read<ProjectListNotifier>().loadProjects();
        },
      );
    }

    if (state.showEmptyState) {
      return Center(
        child: EmptyProjectsState(
          filter: state.filter,
          searchQuery: state.searchQuery,
        ),
      );
    }

    return ProjectGrid(
      projects: state.filteredProjects,
      onOpenProject: onOpenProject,
      onDeleteProject: onDeleteProject,
    );
  }
}

class ErrorStateWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const ErrorStateWidget({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
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
            error,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Dimens.doubleSpacing),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class ProjectGrid extends StatelessWidget {
  final List<Project> projects;
  final Function(Project) onOpenProject;
  final Function(Project) onDeleteProject;

  const ProjectGrid({
    super.key,
    required this.projects,
    required this.onOpenProject,
    required this.onDeleteProject,
  });

  int _calculateDesktopCrossAxisCount(double width) {
    final cardWidth =
        Dimens.desktopProjectCardWidth + Dimens.desktopCardSpacing;
    final availableWidth = width - (Dimens.desktopMainPadding * 2);
    final maxColumns = (availableWidth / cardWidth).floor();
    return maxColumns.clamp(2, 5);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount =
            _calculateDesktopCrossAxisCount(constraints.maxWidth);

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: Dimens.desktopProjectCardWidth /
                Dimens.desktopProjectCardHeight,
            crossAxisSpacing: Dimens.desktopCardSpacing,
            mainAxisSpacing: Dimens.desktopCardSpacing,
          ),
          itemCount: projects.length,
          itemBuilder: (context, index) {
            final project = projects[index];
            return ProjectCard(
              project: project,
              onTap: () => onOpenProject(project),
              onFavoriteToggle: () =>
                  context.read<ProjectListNotifier>().toggleFavorite(project),
              onDelete: () => onDeleteProject(project),
              onRename: (newName) => context
                  .read<ProjectListNotifier>()
                  .renameProject(project, newName),
            );
          },
        );
      },
    );
  }
}
