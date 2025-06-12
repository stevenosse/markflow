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
      childPadding: EdgeInsets.all(Dimens.spacing),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimens.cardRadius),
        child: Container(
          height: Dimens.projectCardHeight,
          padding: const EdgeInsets.all(Dimens.cardMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _ProjectHeader(),
              const SizedBox(height: Dimens.halfSpacing),
              const _ProjectTitle(),
              const SizedBox(height: Dimens.minSpacing),
              const _ProjectPath(),
              const SizedBox(height: Dimens.minSpacing),
              const _ProjectFooter(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectHeader extends StatelessWidget {
  const _ProjectHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _ProjectIcon(),
        const Spacer(),
        const _FavoriteButton(),
        const _MenuButton(),
      ],
    );
  }
}

class _ProjectIcon extends StatelessWidget {
  const _ProjectIcon();

  @override
  Widget build(BuildContext context) {
    final project = context.findAncestorWidgetOfExactType<ProjectCard>()!.project;
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
      width: Dimens.iconSizeL,
      height: Dimens.iconSizeL,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(Dimens.buttonRadius),
      ),
      child: const Icon(
        Icons.folder,
        color: Colors.white,
        size: Dimens.iconSizeM,
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton();

  @override
  Widget build(BuildContext context) {
    final projectCard = context.findAncestorWidgetOfExactType<ProjectCard>()!;
    return IconButton(
      onPressed: projectCard.onFavoriteToggle,
      icon: Icon(
        projectCard.project.isFavorite ? Icons.favorite : Icons.favorite_border,
        color: projectCard.project.isFavorite
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
}

class _MenuButton extends StatelessWidget {
  const _MenuButton();

  @override
  Widget build(BuildContext context) {
    final projectCard = context.findAncestorWidgetOfExactType<ProjectCard>()!;
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'rename':
            _showRenameDialog(context);
            break;
          case 'delete':
            projectCard.onDelete();
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

  void _showRenameDialog(BuildContext context) {
    final projectCard = context.findAncestorWidgetOfExactType<ProjectCard>()!;
    final controller = TextEditingController(text: projectCard.project.name);
    
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
              if (newName.isNotEmpty && newName != projectCard.project.name) {
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
      if (newName != null && newName.isNotEmpty && newName != projectCard.project.name) {
        projectCard.onRename(newName);
      }
    });
  }
}

class _ProjectTitle extends StatelessWidget {
  const _ProjectTitle();

  @override
  Widget build(BuildContext context) {
    final project = context.findAncestorWidgetOfExactType<ProjectCard>()!.project;
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
  const _ProjectPath();

  @override
  Widget build(BuildContext context) {
    final project = context.findAncestorWidgetOfExactType<ProjectCard>()!.project;
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
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _ProjectFooter extends StatelessWidget {
  const _ProjectFooter();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _GitIndicator(),
        Spacer(),
        _LastOpenedText(),
      ],
    );
  }
}

class _GitIndicator extends StatelessWidget {
  const _GitIndicator();

  @override
  Widget build(BuildContext context) {
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
}

class _LastOpenedText extends StatelessWidget {
  const _LastOpenedText();

  @override
  Widget build(BuildContext context) {
    final project = context.findAncestorWidgetOfExactType<ProjectCard>()!.project;
    final now = DateTime.now();
    final difference = now.difference(project.lastOpened);
    
    String lastOpenedText;
    if (difference.inDays > 0) {
      lastOpenedText = '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      lastOpenedText = '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      lastOpenedText = '${difference.inMinutes}m ago';
    } else {
      lastOpenedText = 'Just now';
    }

    return Text(
      lastOpenedText,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
    );
  }
}
