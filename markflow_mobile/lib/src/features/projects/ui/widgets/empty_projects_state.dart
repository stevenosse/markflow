import 'package:flutter/material.dart';
import 'package:markflow/src/core/theme/dimens.dart';
import 'package:markflow/src/features/projects/logic/project_list/project_list_state.dart';

class EmptyProjectsState extends StatelessWidget {
  final ProjectListFilter filter;
  final String searchQuery;
  final VoidCallback onCreateProject;
  final VoidCallback onImportProject;
  final VoidCallback onCloneRepository;

  const EmptyProjectsState({
    super.key,
    required this.filter,
    required this.searchQuery,
    required this.onCreateProject,
    required this.onImportProject,
    required this.onCloneRepository,
  });

  @override
  Widget build(BuildContext context) {
    if (searchQuery.isNotEmpty) {
      return _buildSearchEmptyState(context);
    }

    switch (filter) {
      case ProjectListFilter.all:
        return _buildNoProjectsState(context);
      case ProjectListFilter.recent:
        return _buildNoRecentProjectsState(context);
      case ProjectListFilter.favorites:
        return _buildNoFavoritesState(context);
    }
  }

  Widget _buildSearchEmptyState(BuildContext context) {
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

  Widget _buildNoProjectsState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimens.doubleSpacing),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: Dimens.iconSizeXL * 2,
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
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
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildNoRecentProjectsState(BuildContext context) {
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

  Widget _buildNoFavoritesState(BuildContext context) {
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

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onCreateProject,
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
                onPressed: onImportProject,
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
                onPressed: onCloneRepository,
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
