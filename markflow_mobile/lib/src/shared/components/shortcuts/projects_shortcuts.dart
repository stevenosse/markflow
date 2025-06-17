import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_route/auto_route.dart';
import 'package:markflow/src/core/routing/app_router.dart';
import 'package:markflow/src/features/projects/logic/project_list/project_list_notifier.dart';
import 'package:markflow/src/features/projects/logic/project_list/project_list_state.dart';
import 'package:markflow/src/features/projects/ui/widgets/project_action_dialog.dart';
import 'package:markflow/src/shared/components/dialogs/confirmation_dialog.dart';

/// Widget that provides projects screen specific keyboard shortcuts
class ProjectsShortcuts extends StatelessWidget {
  final Widget child;
  final ProjectListNotifier notifier;
  final ProjectListState state;

  const ProjectsShortcuts({
    super.key,
    required this.child,
    required this.notifier,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: _buildShortcuts(),
      child: Actions(
        actions: _buildActions(context),
        child: child,
      ),
    );
  }

  Map<ShortcutActivator, Intent> _buildShortcuts() {
    return {
      // Project operations
      const SingleActivator(LogicalKeyboardKey.keyN, meta: true): const NewProjectIntent(),
      const SingleActivator(LogicalKeyboardKey.keyO, meta: true): const OpenProjectIntent(),
      const SingleActivator(LogicalKeyboardKey.keyI, meta: true): const ImportProjectIntent(),
      const SingleActivator(LogicalKeyboardKey.keyF, meta: true): const SearchProjectsIntent(),
      const SingleActivator(LogicalKeyboardKey.enter): const OpenSelectedProjectIntent(),
      const SingleActivator(LogicalKeyboardKey.delete): const DeleteSelectedProjectIntent(),
      
      // Navigation
      const SingleActivator(LogicalKeyboardKey.arrowUp): const NavigateUpIntent(),
      const SingleActivator(LogicalKeyboardKey.arrowDown): const NavigateDownIntent(),
      
      // View controls
      const SingleActivator(LogicalKeyboardKey.keyL, meta: true): const ToggleViewModeIntent(),
      const SingleActivator(LogicalKeyboardKey.keyR, meta: true): const RefreshProjectsIntent(),
    };
  }

  Map<Type, Action<Intent>> _buildActions(BuildContext context) {
    return {
      NewProjectIntent: CallbackAction<NewProjectIntent>(
        onInvoke: (_) => _newProject(context),
      ),
      OpenProjectIntent: CallbackAction<OpenProjectIntent>(
        onInvoke: (_) => _openProject(context),
      ),
      ImportProjectIntent: CallbackAction<ImportProjectIntent>(
        onInvoke: (_) => _importProject(context),
      ),
      SearchProjectsIntent: CallbackAction<SearchProjectsIntent>(
        onInvoke: (_) => _searchProjects(),
      ),
      OpenSelectedProjectIntent: CallbackAction<OpenSelectedProjectIntent>(
        onInvoke: (_) => _openSelectedProject(),
      ),
      DeleteSelectedProjectIntent: CallbackAction<DeleteSelectedProjectIntent>(
        onInvoke: (_) => _deleteSelectedProject(context),
      ),
      NavigateUpIntent: CallbackAction<NavigateUpIntent>(
        onInvoke: (_) => _navigateUp(),
      ),
      NavigateDownIntent: CallbackAction<NavigateDownIntent>(
        onInvoke: (_) => _navigateDown(),
      ),
      ToggleViewModeIntent: CallbackAction<ToggleViewModeIntent>(
        onInvoke: (_) => _toggleViewMode(),
      ),
      RefreshProjectsIntent: CallbackAction<RefreshProjectsIntent>(
        onInvoke: (_) => _refreshProjects(),
      ),
    };
  }

  // Action implementations
  void _newProject(BuildContext context) async {
    try {
      await ProjectActionDialog.show(
        context,
        initialAction: ProjectActionType.create,
      );
    } catch (e) {
        // Error handled silently
      }
  }

  void _openProject(BuildContext context) async {
    try {
      await ProjectActionDialog.show(
        context,
        initialAction: ProjectActionType.import,
      );
    } catch (e) {
        // Error handled silently
      }
  }

  void _importProject(BuildContext context) async {
    try {
      await ProjectActionDialog.show(
        context,
        initialAction: ProjectActionType.import,
      );
    } catch (e) {
        // Error handled silently
      }
  }

  void _searchProjects() {
    try {
      // Focus on the search field by requesting focus
      // The search field will be focused when the user starts typing
      final context = primaryFocus?.context;
      if (context != null) {
        // Find the search field in the widget tree and focus it
        FocusScope.of(context).requestFocus();
        // Clear any existing search to start fresh
        notifier.setSearchQuery('');
      }
    } catch (e) {
        // Error handled silently
      }
  }

  void _openSelectedProject() {
    try {
      // Open the first project in the filtered list if available
      final filteredProjects = notifier.value.filteredProjects;
      if (filteredProjects.isNotEmpty) {
        final project = filteredProjects.first;
        final context = primaryFocus?.context;
        if (context != null) {
          notifier.updateLastOpened(project);
          context.router.push(ProjectEditorRoute(project: project));
        }
      }
    } catch (e) {
        // Error handled silently
      }
  }

  void _deleteSelectedProject(BuildContext context) async {
    try {
      // Delete the first project in the filtered list with confirmation
      final filteredProjects = notifier.value.filteredProjects;
      if (filteredProjects.isNotEmpty) {
        final project = filteredProjects.first;
        
        final confirmed = await ConfirmationDialog.show(
          context: context,
          title: 'Delete Project',
          message: 'Are you sure you want to delete "${project.name}"?',
          confirmText: 'Delete',
          confirmButtonColor: Theme.of(context).colorScheme.error,
        );
        
        if (confirmed == true) {
          await notifier.deleteProject(project);
        }
      }
    } catch (e) {
        // Error handled silently
      }
  }

  void _navigateUp() {
    try {
      // Scroll up in the project list
      // This is a basic implementation - in a real app you'd want
      // to maintain selection state and scroll to selected item
      final context = primaryFocus?.context;
      if (context != null) {
        // Find any scrollable widget and scroll up
        Scrollable.maybeOf(context)?.position.animateTo(
          Scrollable.of(context).position.pixels - 100,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      }
    } catch (e) {
        // Error handled silently
      }
  }

  void _navigateDown() {
    try {
      // Scroll down in the project list
      final context = primaryFocus?.context;
      if (context != null) {
        // Find any scrollable widget and scroll down
        Scrollable.maybeOf(context)?.position.animateTo(
          Scrollable.of(context).position.pixels + 100,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      }
    } catch (e) {
        // Error handled silently
      }
  }

  void _toggleViewMode() {
    try {
      // Cycle through the available filters as a form of view mode toggle
      final currentFilter = notifier.value.filter;
      final nextFilter = switch (currentFilter) {
        ProjectListFilter.all => ProjectListFilter.recent,
        ProjectListFilter.recent => ProjectListFilter.favorites,
        ProjectListFilter.favorites => ProjectListFilter.all,
      };
      notifier.setFilter(nextFilter);
    } catch (e) {
        // Error handled silently
      }
  }

  void _refreshProjects() {
    try {
      notifier.loadProjects();
    } catch (e) {
        // Error handled silently
      }
  }
}

// Intent classes
class NewProjectIntent extends Intent {
  const NewProjectIntent();
}

class OpenProjectIntent extends Intent {
  const OpenProjectIntent();
}

class ImportProjectIntent extends Intent {
  const ImportProjectIntent();
}

class SearchProjectsIntent extends Intent {
  const SearchProjectsIntent();
}

class OpenSelectedProjectIntent extends Intent {
  const OpenSelectedProjectIntent();
}

class DeleteSelectedProjectIntent extends Intent {
  const DeleteSelectedProjectIntent();
}

class NavigateUpIntent extends Intent {
  const NavigateUpIntent();
}

class NavigateDownIntent extends Intent {
  const NavigateDownIntent();
}

class ToggleViewModeIntent extends Intent {
  const ToggleViewModeIntent();
}

class RefreshProjectsIntent extends Intent {
  const RefreshProjectsIntent();
}