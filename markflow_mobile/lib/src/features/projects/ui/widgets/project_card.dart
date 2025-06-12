import 'package:flutter/material.dart';
import 'package:markflow/src/core/theme/dimens.dart';
import 'package:markflow/src/datasource/models/project.dart';
import 'package:path/path.dart' as path;

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onDelete;
  final void Function(String) onRename;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.onDelete,
    required this.onRename,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: Dimens.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimens.cardRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimens.cardRadius),
        child: Container(
          height: Dimens.projectCardHeight,
          padding: const EdgeInsets.all(Dimens.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: Dimens.halfSpacing),
              _buildTitle(context),
              const SizedBox(height: Dimens.minSpacing),
              _buildPath(context),
              const Spacer(),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        _buildProjectIcon(context),
        const Spacer(),
        _buildFavoriteButton(context),
        _buildMenuButton(context),
      ],
    );
  }

  Widget _buildProjectIcon(BuildContext context) {
    return Container(
      width: Dimens.iconSizeL,
      height: Dimens.iconSizeL,
      decoration: BoxDecoration(
        color: _getProjectColor(context),
        borderRadius: BorderRadius.circular(Dimens.buttonRadius),
      ),
      child: Icon(
        _getProjectIcon(),
        color: Colors.white,
        size: Dimens.iconSizeM,
      ),
    );
  }

  Widget _buildFavoriteButton(BuildContext context) {
    return IconButton(
      onPressed: onFavoriteToggle,
      icon: Icon(
        project.isFavorite ? Icons.favorite : Icons.favorite_border,
        color: project.isFavorite
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        size: Dimens.iconSizeM,
      ),
      constraints: const BoxConstraints(
        minWidth: Dimens.iconSize,
        minHeight: Dimens.iconSize,
      ),
      padding: EdgeInsets.zero,
    );
  }

  Widget _buildMenuButton(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'rename':
            _showRenameDialog(context);
            break;
          case 'delete':
            onDelete();
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'rename',
          child: Row(
            children: [
              Icon(Icons.edit, size: Dimens.iconSizeS),
              SizedBox(width: Dimens.halfSpacing),
              Text('Rename'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: Dimens.iconSizeS),
              SizedBox(width: Dimens.halfSpacing),
              Text('Delete'),
            ],
          ),
        ),
      ],
      icon: Icon(
        Icons.more_vert,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        size: Dimens.iconSizeM,
      ),
      constraints: const BoxConstraints(
        minWidth: Dimens.iconSize,
        minHeight: Dimens.iconSize,
      ),
      padding: EdgeInsets.zero,
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      project.name,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildPath(BuildContext context) {
    final displayPath = _getDisplayPath();

    return Text(
      displayPath,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      children: [
        _buildGitIndicator(context),
        const Spacer(),
        _buildLastOpenedText(context),
      ],
    );
  }

  Widget _buildGitIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimens.halfSpacing,
        vertical: Dimens.minSpacing,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Dimens.buttonRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.source,
            size: Dimens.iconSizeXS,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: Dimens.minSpacing),
          Text(
            'Git',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastOpenedText(BuildContext context) {
    final lastOpenedText = _getLastOpenedText();

    return Text(
      lastOpenedText,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
    );
  }

  Color _getProjectColor(BuildContext context) {
    // Generate a color based on project name hash
    final hash = project.name.hashCode;
    final colors = [
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.secondary,
      Theme.of(context).colorScheme.tertiary,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];

    return colors[hash.abs() % colors.length];
  }

  IconData _getProjectIcon() => Icons.folder;

  String _getDisplayPath() {
    try {
      // Show relative path from home directory if possible
      final homePath = path.dirname(path.dirname(project.path));
      if (project.path.startsWith(homePath)) {
        return '~/${path.relative(project.path, from: homePath)}';
      }
      return project.path;
    } catch (e) {
      return project.path;
    }
  }

  String _getLastOpenedText() {
    final now = DateTime.now();
    final lastOpened = project.lastOpened;
    final difference = now.difference(lastOpened);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
  
  void _showRenameDialog(BuildContext context) {
    final controller = TextEditingController(text: project.name);
    
    showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Project'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Project Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              Navigator.of(context).pop(value.trim());
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
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != project.name) {
                Navigator.of(context).pop(newName);
              } else {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    ).then((newName) {
      if (newName != null && newName.isNotEmpty && newName != project.name) {
        onRename(newName);
      }
    });
  }
}
