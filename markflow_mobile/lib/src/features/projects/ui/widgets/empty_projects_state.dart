import 'dart:math';

import 'package:flutter/material.dart';
import 'package:markflow/src/core/theme/dimens.dart';
import 'package:markflow/src/features/projects/logic/project_list/project_list_notifier.dart';
import 'package:markflow/src/features/projects/logic/project_list/project_list_state.dart';
import 'package:markflow/src/features/projects/ui/widgets/project_action_dialog.dart';
import 'package:provider/provider.dart';

class EmptyProjectsState extends StatelessWidget {
  final ProjectListFilter filter;
  final String searchQuery;

  const EmptyProjectsState({
    super.key,
    required this.filter,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    if (searchQuery.isNotEmpty) {
      return SearchEmptyState(
        searchQuery: searchQuery,
      );
    }

    switch (filter) {
      case ProjectListFilter.all:
        return const NoProjectsState();
      case ProjectListFilter.recent:
        return const NoRecentProjectsState();
      case ProjectListFilter.favorites:
        return const NoFavoritesState();
    }
  }
}

class SearchEmptyState extends StatelessWidget {
  const SearchEmptyState({super.key, required this.searchQuery});

  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimens.doubleSpacing),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: Dimens.iconSizeXL * 2,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.3),
            ),
            const SizedBox(height: Dimens.spacing),
            Text(
              'No projects found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: Dimens.halfSpacing),
            Text(
              'No projects match "$searchQuery"',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class NoProjectsState extends StatelessWidget {
  const NoProjectsState({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: min(
            500.0,
            constraints.maxWidth * 0.9,
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(Dimens.doubleSpacing),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_open,
                    size: Dimens.iconSizeXL * 2,
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: Dimens.spacing),
                  Text(
                    'Welcome to MarkFlow',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: Dimens.halfSpacing),
                  Text(
                    'Get started by creating your first project or importing an existing one.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.7),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Dimens.doubleSpacing),
                  const ProjectActionButtons(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class NoRecentProjectsState extends StatelessWidget {
  const NoRecentProjectsState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimens.doubleSpacing),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: Dimens.iconSizeXL * 2,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.3),
            ),
            const SizedBox(height: Dimens.spacing),
            Text(
              'No recent projects',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: Dimens.halfSpacing),
            Text(
              'Projects you\'ve worked on recently will appear here.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class NoFavoritesState extends StatelessWidget {
  const NoFavoritesState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimens.doubleSpacing),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: Dimens.iconSizeXL * 2,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.3),
            ),
            const SizedBox(height: Dimens.spacing),
            Text(
              'No favorite projects',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: Dimens.halfSpacing),
            Text(
              'Mark projects as favorites to quickly access them here.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class ProjectActionButtons extends StatelessWidget {
  const ProjectActionButtons({super.key});

  void _showCreateProjectDialog(BuildContext context) {
    ProjectActionDialog.show(
      context,
      initialAction: ProjectActionType.create,
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

  void _showImportProjectDialog(BuildContext context) {
    ProjectActionDialog.show(
      context,
      initialAction: ProjectActionType.import,
    ).then((result) async {
      if (result != null && context.mounted) {
        if (result is ImportProjectResult) {
          await context.read<ProjectListNotifier>().importProject(
            path: result.path,
            name: result.name,
          );
        }
      }
    });
  }

  void _showCloneRepositoryDialog(BuildContext context) {
    ProjectActionDialog.show(
      context,
      initialAction: ProjectActionType.clone,
    ).then((result) async {
      if (result != null && context.mounted) {
        if (result is CloneRepositoryResult) {
          await context.read<ProjectListNotifier>().cloneRepository(
            name: result.name ?? 'project',
            path: result.path ?? '',
            remoteUrl: result.url,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showCreateProjectDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Create new project'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(
                horizontal: Dimens.spacing,
                vertical: Dimens.spacing,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimens.buttonRadius),
              ),
            ),
          ),
        ),
        const SizedBox(height: Dimens.spacing),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showImportProjectDialog(context),
                icon: const Icon(Icons.folder_open),
                label: const Text('Import'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimens.spacing,
                    vertical: Dimens.spacing,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Dimens.buttonRadius),
                  ),
                ),
              ),
            ),
            const SizedBox(width: Dimens.spacing),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showCloneRepositoryDialog(context),
                icon: const Icon(Icons.cloud_download),
                label: const Text('Clone'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimens.spacing,
                    vertical: Dimens.spacing,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Dimens.buttonRadius),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
