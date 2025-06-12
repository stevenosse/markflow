import 'package:flutter/material.dart';
import 'package:markflow/src/core/theme/dimens.dart';
import 'package:markflow/src/features/projects/logic/project_list/project_list_state.dart';

class ProjectFilterTabs extends StatelessWidget {
  final ProjectListFilter currentFilter;
  final ValueChanged<ProjectListFilter> onFilterChanged;
  final Map<ProjectListFilter, int> projectCounts;
  
  const ProjectFilterTabs({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
    required this.projectCounts,
  });
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: ProjectListFilter.values.map((filter) {
        return Expanded(
          child: _buildFilterTab(context, filter),
        );
      }).toList(),
    );
  }
  
  Widget _buildFilterTab(BuildContext context, ProjectListFilter filter) {
    final isSelected = currentFilter == filter;
    final count = projectCounts[filter] ?? 0;
    
    return GestureDetector(
      onTap: () => onFilterChanged(filter),
      child: Container(
        height: Dimens.buttonHeightS,
        margin: const EdgeInsets.symmetric(horizontal: Dimens.minSpacing),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(Dimens.buttonRadius),
          border: isSelected
              ? null
              : Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                  width: Dimens.borderWidth,
                ),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                filter.displayName,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: Dimens.minSpacing),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimens.halfSpacing,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.2)
                        : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(Dimens.fullRadius),
                  ),
                  child: Text(
                    count.toString(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}