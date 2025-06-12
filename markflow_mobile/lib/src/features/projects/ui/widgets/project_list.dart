import 'package:flutter/material.dart';
import 'package:markflow/src/core/theme/dimens.dart';
import 'package:markflow/src/datasource/models/project.dart';
import 'package:markflow/src/features/projects/ui/widgets/project_card.dart';

class ProjectList extends StatelessWidget {
  final List<Project> projects;
  final Function(Project) onProjectSelected;
  final Function(Project) onProjectDeleted;
  final Function(Project) onProjectRenamed;
  final Function(Project) onToggleFavorite;
  
  const ProjectList({
    super.key,
    required this.projects,
    required this.onProjectSelected,
    required this.onProjectDeleted,
    required this.onProjectRenamed,
    required this.onToggleFavorite,
  });
  
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(Dimens.spacing),
      itemCount: projects.length,
      separatorBuilder: (context, index) => const SizedBox(height: Dimens.spacing),
      itemBuilder: (context, index) {
        final project = projects[index];
        return ProjectCard(
          project: project,
          onTap: () => onProjectSelected(project),
          onDelete: () => onProjectDeleted(project),
          onRename: (newName) => onProjectRenamed(project.copyWith(name: newName)),
          onFavoriteToggle: () => onToggleFavorite(project),
        );
      },
    );
  }
}