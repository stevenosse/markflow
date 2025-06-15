import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:markflow/src/core/routing/app_router.dart';
import 'package:markflow/src/core/theme/dimens.dart';
import 'package:markflow/src/core/services/keyboard_shortcuts_service.dart';
import 'package:markflow/src/core/services/keyboard_actions.dart';
import 'package:markflow/src/datasource/models/project.dart';
import 'package:markflow/src/features/projects/logic/project_list/project_list_notifier.dart';
import 'package:markflow/src/features/projects/logic/project_list/project_list_state.dart';
import 'package:markflow/src/features/projects/ui/widgets/project_card.dart';
import 'package:markflow/src/features/projects/ui/widgets/project_search_bar.dart';
import 'package:markflow/src/features/projects/ui/widgets/project_filter_tabs.dart';
import 'package:markflow/src/features/projects/ui/widgets/empty_projects_state.dart';
import 'package:markflow/src/features/projects/ui/widgets/project_action_dialog.dart';
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
    return Shortcuts(
      shortcuts: KeyboardShortcutsService.instance.projectsShortcuts,
      child: Actions(
        actions: KeyboardActions.projectsActions,
        child: Scaffold(
          body: ValueListenableBuilder<ProjectListState>(
            valueListenable: context.read<ProjectListNotifier>(),
            builder: (context, state, child) {
              return Column(
                children: [
                  _buildDesktopHeader(context, state),
                  Expanded(
                    child: _buildDesktopBody(context, state),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopHeader(BuildContext context, ProjectListState state) {
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
              onSearchChanged: context.read<ProjectListNotifier>().setSearchQuery,
            ),
          ),
          const SizedBox(width: Dimens.desktopSpacing),
          ElevatedButton.icon(
            onPressed: () => _showCreateProjectDialog(context),
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
              minimumSize: Size(Dimens.desktopButtonHeight, Dimens.desktopButtonHeight),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopBody(BuildContext context, ProjectListState state) {
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
            child: _buildDesktopContent(context, state),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopContent(BuildContext context, ProjectListState state) {
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
      );
    }

    return _buildDesktopProjectGrid(context, state);
  }

  Widget _buildDesktopProjectGrid(BuildContext context, ProjectListState state) {
    final projects = state.filteredProjects;

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _calculateDesktopCrossAxisCount(constraints.maxWidth);

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio:
                Dimens.desktopProjectCardWidth / Dimens.desktopProjectCardHeight,
            crossAxisSpacing: Dimens.desktopCardSpacing,
            mainAxisSpacing: Dimens.desktopCardSpacing,
          ),
          itemCount: projects.length,
          itemBuilder: (context, index) {
            final project = projects[index];
            return ProjectCard(
              project: project,
              onTap: () => _openProject(context, project),
              onFavoriteToggle: () =>
                  context.read<ProjectListNotifier>().toggleFavorite(project),
              onDelete: () => _showDeleteProjectDialog(context, project),
              onRename: (newName) => context
                  .read<ProjectListNotifier>()
                  .renameProject(project, newName),
            );
          },
        );
      },
    );
  }

  int _calculateDesktopCrossAxisCount(double width) {
    final cardWidth = Dimens.desktopProjectCardWidth + Dimens.desktopCardSpacing;
    final availableWidth = width - (Dimens.desktopMainPadding * 2);
    final maxColumns = (availableWidth / cardWidth).floor();
    
    // Ensure minimum 2 columns and maximum 5 columns for desktop
    return maxColumns.clamp(2, 5);
  }

  void _openProject(BuildContext context, Project project) {
    // Update last opened time
    context.read<ProjectListNotifier>().updateLastOpened(project);

    // Navigate to project editor
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
}
