import 'package:flutter/material.dart';
import 'package:markflow/src/core/theme/dimens.dart';
import 'package:markflow/src/datasource/models/project.dart';
import 'package:markflow/src/shared/components/atoms/basic_card.dart';
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
    return BasicCard(
      childPadding: const EdgeInsets.all(Dimens.desktopSpacing),
      borderRadius: BorderRadius.circular(Dimens.desktopCardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimens.desktopCardRadius),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: Dimens.desktopProjectCardHeight,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProjectHeader(
                project: project,
                onFavoriteToggle: onFavoriteToggle,
                onDelete: onDelete,
                onRename: onRename,
              ),
              const SizedBox(height: Dimens.spacing),
              _ProjectTitle(project: project),
              const SizedBox(height: Dimens.halfSpacing),
              _ProjectPath(project: project),
              const Spacer(),
              _ProjectFooter(project: project),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectHeader extends StatelessWidget {
  final Project project;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onDelete;
  final void Function(String) onRename;

  const _ProjectHeader({
    required this.project,
    required this.onFavoriteToggle,
    required this.onDelete,
    required this.onRename,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ProjectIcon(project: project),
        const Spacer(),
        _FavoriteButton(
          project: project,
          onFavoriteToggle: onFavoriteToggle,
        ),
        _MenuButton(
          project: project,
          onDelete: onDelete,
          onRename: onRename,
        ),
      ],
    );
  }
}

class _ProjectIcon extends StatelessWidget {
  final Project project;

  const _ProjectIcon({required this.project});

  @override
  Widget build(BuildContext context) {
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
    final color = colors[hash.abs() % colors.length];

    return Container(
      width: Dimens.desktopSpacingL,
      height: Dimens.desktopSpacingL,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(Dimens.desktopRadius),
      ),
      child: Icon(
        Icons.folder,
        color: Colors.white,
        size: Dimens.desktopIconSize,
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  final Project project;
  final VoidCallback onFavoriteToggle;

  const _FavoriteButton({
    required this.project,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onFavoriteToggle,
      icon: Icon(
        project.isFavorite ? Icons.favorite : Icons.favorite_border,
        color: project.isFavorite
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        size: Dimens.desktopIconSize,
      ),
      constraints: BoxConstraints(
        minWidth: Dimens.desktopButtonHeight,
        minHeight: Dimens.desktopButtonHeight,
      ),
      padding: EdgeInsets.zero,
    );
  }
}

class _MenuButton extends StatelessWidget {
  final Project project;
  final VoidCallback onDelete;
  final void Function(String) onRename;

  const _MenuButton({
    required this.project,
    required this.onDelete,
    required this.onRename,
  });

  @override
  Widget build(BuildContext context) {
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
        PopupMenuItem(
          value: 'rename',
          child: Row(
            children: [
              Icon(Icons.edit, size: Dimens.desktopIconSize),
              const SizedBox(width: Dimens.halfSpacing),
              const Text('Rename'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: Dimens.desktopIconSize),
              const SizedBox(width: Dimens.halfSpacing),
              const Text('Delete'),
            ],
          ),
        ),
      ],
      icon: Icon(
        Icons.more_vert,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        size: Dimens.desktopIconSize,
      ),
      constraints: BoxConstraints(
        minWidth: Dimens.desktopButtonHeight,
        minHeight: Dimens.desktopButtonHeight,
      ),
      padding: EdgeInsets.zero,
    );
  }

  void _showRenameDialog(BuildContext context) {
    final controller = TextEditingController(text: project.name);
    
    showDialog<String>(
      context: context,
      builder: (context) => Material(
        color: Colors.transparent,
        child: AlertDialog.adaptive(
          title: const Text('Rename Project'),
          content: Padding( 
            padding: const EdgeInsets.all(Dimens.spacing),
            child: TextField(
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
      ),
    ).then((newName) {
      if (newName != null && newName.isNotEmpty && newName != project.name) {
        onRename(newName);
      }
    });
  }
}

class _ProjectTitle extends StatelessWidget {
  final Project project;

  const _ProjectTitle({required this.project});

  @override
  Widget build(BuildContext context) {
    return Text(
      project.name,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _ProjectPath extends StatelessWidget {
  final Project project;

  const _ProjectPath({required this.project});

  @override
  Widget build(BuildContext context) {
    String displayPath;
    try {
      final homePath = path.dirname(path.dirname(project.path));
      if (project.path.startsWith(homePath)) {
        displayPath = '~/${path.relative(project.path, from: homePath)}';
      } else {
        displayPath = project.path;
      }
    } catch (e) {
      displayPath = project.path;
    }

    return Text(
      displayPath,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _ProjectFooter extends StatelessWidget {
  final Project project;

  const _ProjectFooter({required this.project});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _GitIndicator(project: project),
        const Spacer(),
        _LastOpenedText(project: project),
      ],
    );
  }
}

class _GitIndicator extends StatelessWidget {
  final Project project;

  const _GitIndicator({required this.project});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.desktopSpacing / 2,
        vertical: Dimens.desktopSpacing / 4,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Dimens.desktopRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.source,
            size: 12,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(width: Dimens.desktopSpacing / 4),
          Text(
            'Git',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}

class _LastOpenedText extends StatelessWidget {
  final Project project;

  const _LastOpenedText({required this.project});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final difference = now.difference(project.lastOpened);
    
    String timeText;
    if (difference.inDays > 0) {
      timeText = '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      timeText = '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      timeText = '${difference.inMinutes}m ago';
    } else {
      timeText = 'Just now';
    }

    return Text(
      timeText,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
    );
  }
}
