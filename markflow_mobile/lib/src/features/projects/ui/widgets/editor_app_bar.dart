import 'package:flutter/material.dart';
import 'package:markflow/src/core/theme/dimens.dart';
import 'package:markflow/src/datasource/models/project.dart';
import 'package:markflow/src/datasource/models/markdown_file.dart';
import 'package:markflow/src/features/projects/logic/project_editor/project_editor_state.dart';

class EditorAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Project project;
  final MarkdownFile? selectedFile;
  final bool hasUnsavedChanges;
  final ProjectEditorView viewMode;
  final bool isPreviewVisible;
  final VoidCallback onSave;
  final ValueChanged<ProjectEditorView> onViewModeChanged;
  final VoidCallback onTogglePreview;
  final VoidCallback onNewFile;
  final VoidCallback onNewFolder;

  const EditorAppBar({
    super.key,
    required this.project,
    required this.selectedFile,
    required this.hasUnsavedChanges,
    required this.viewMode,
    required this.isPreviewVisible,
    required this.onSave,
    required this.onViewModeChanged,
    required this.onTogglePreview,
    required this.onNewFile,
    required this.onNewFolder,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      titleSpacing: Dimens.spacing,
      title: const _TitleSection(),
      actions: const [
        _ActionSection(),
      ],
    );
  }
}

class _TitleSection extends StatelessWidget {
  const _TitleSection();

  @override
  Widget build(BuildContext context) {
    final appBar = context.findAncestorWidgetOfExactType<EditorAppBar>()!;

    return Row(
      children: [
        const _ProjectIcon(),
        const SizedBox(width: Dimens.spacing),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _ProjectTitle(project: appBar.project),
              if (appBar.selectedFile != null)
                _FileSubtitle(file: appBar.selectedFile!),
            ],
          ),
        ),
        if (appBar.hasUnsavedChanges) const _UnsavedIndicator(),
      ],
    );
  }
}

class _ProjectIcon extends StatelessWidget {
  const _ProjectIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimens.halfSpacing),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(Dimens.radiusS),
      ),
      child: Icon(
        Icons.folder_outlined,
        size: Dimens.iconSizeS,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
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
            letterSpacing: -0.3,
            height: 1.2,
          ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }
}

class _FileSubtitle extends StatelessWidget {
  final MarkdownFile file;

  const _FileSubtitle({required this.file});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 3,
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: Dimens.halfSpacing),
          Flexible(
            child: Text(
              file.name,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    height: 1.3,
                  ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _UnsavedIndicator extends StatelessWidget {
  const _UnsavedIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: Dimens.spacing),
      padding: const EdgeInsets.symmetric(
        horizontal: Dimens.halfSpacing,
        vertical: Dimens.minSpacing,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Dimens.fullRadius),
        border: Border.all(
          color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.tertiary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Unsaved',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.tertiary,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                  letterSpacing: 0.2,
                ),
          ),
        ],
      ),
    );
  }
}

class _ActionSection extends StatelessWidget {
  const _ActionSection();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _PrimaryActionsGroup(),
        SizedBox(width: Dimens.halfSpacing),
        _SecondaryActionsGroup(),
        SizedBox(width: Dimens.spacing),
      ],
    );
  }
}

class _PrimaryActionsGroup extends StatelessWidget {
  const _PrimaryActionsGroup();

  @override
  Widget build(BuildContext context) {
    final appBar = context.findAncestorWidgetOfExactType<EditorAppBar>()!;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(Dimens.buttonRadius),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (appBar.hasUnsavedChanges) _SaveAction(onSave: appBar.onSave),
          _ViewModeAction(
            viewMode: appBar.viewMode,
            onViewModeChanged: appBar.onViewModeChanged,
          ),
        ],
      ),
    );
  }
}

class _SaveAction extends StatelessWidget {
  final VoidCallback onSave;

  const _SaveAction({required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(2),
      child: Material(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(Dimens.radiusS),
        child: InkWell(
          onTap: onSave,
          borderRadius: BorderRadius.circular(Dimens.radiusS),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimens.spacing,
              vertical: Dimens.halfSpacing,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.save_outlined,
                  size: Dimens.iconSizeS,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                const SizedBox(width: Dimens.halfSpacing),
                Text(
                  'Save',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ViewModeAction extends StatelessWidget {
  final ProjectEditorView viewMode;
  final ValueChanged<ProjectEditorView> onViewModeChanged;

  const _ViewModeAction({
    required this.viewMode,
    required this.onViewModeChanged,
  });

  IconData _getViewModeIcon(ProjectEditorView mode) {
    switch (mode) {
      case ProjectEditorView.editor:
        return Icons.edit_outlined;
      case ProjectEditorView.preview:
        return Icons.visibility_outlined;
      case ProjectEditorView.split:
        return Icons.view_column_outlined;
      case ProjectEditorView.git:
        return Icons.source_outlined;
      case ProjectEditorView.fileTree:
        return Icons.folder_outlined;
    }
  }

  String _getViewModeLabel(ProjectEditorView mode) {
    switch (mode) {
      case ProjectEditorView.editor:
        return 'Editor';
      case ProjectEditorView.preview:
        return 'Preview';
      case ProjectEditorView.split:
        return 'Split';
      case ProjectEditorView.git:
        return 'Git';
      case ProjectEditorView.fileTree:
        return 'Files';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(2),
      child: PopupMenuButton<ProjectEditorView>(
        tooltip: 'View Mode',
        onSelected: onViewModeChanged,
        style: IconButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          padding: const EdgeInsets.symmetric(
            horizontal: Dimens.spacing,
            vertical: Dimens.halfSpacing,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimens.radiusS),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getViewModeIcon(viewMode),
              size: Dimens.iconSizeS,
            ),
            const SizedBox(width: Dimens.halfSpacing),
            Text(
              _getViewModeLabel(viewMode),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(width: Dimens.minSpacing),
            Icon(
              Icons.keyboard_arrow_down,
              size: Dimens.iconSizeS,
            ),
          ],
        ),
        itemBuilder: (context) => [
          _ViewModeMenuItem(
            context: context,
            value: ProjectEditorView.editor,
            icon: Icons.edit_outlined,
            label: 'Editor',
            isSelected: viewMode == ProjectEditorView.editor,
          ),
          _ViewModeMenuItem(
            context: context,
            value: ProjectEditorView.preview,
            icon: Icons.visibility_outlined,
            label: 'Preview',
            isSelected: viewMode == ProjectEditorView.preview,
          ),
          _ViewModeMenuItem(
            context: context,
            value: ProjectEditorView.split,
            icon: Icons.view_column_outlined,
            label: 'Split View',
            isSelected: viewMode == ProjectEditorView.split,
          ),
          _ViewModeMenuItem(
            context: context,
            value: ProjectEditorView.git,
            icon: Icons.source_outlined,
            label: 'Git',
            isSelected: viewMode == ProjectEditorView.git,
          ),
        ],
      ),
    );
  }
}

class _ViewModeMenuItem extends PopupMenuItem<ProjectEditorView> {
  _ViewModeMenuItem({
    required BuildContext context,
    required ProjectEditorView value,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) : super(
          value: value,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimens.spacing,
              vertical: Dimens.halfSpacing,
            ),
            decoration: isSelected
                ? BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(Dimens.radiusS),
                  )
                : null,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(Dimens.minSpacing),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.1)
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(Dimens.radiusXS),
                  ),
                  child: Icon(
                    icon,
                    size: Dimens.iconSizeS,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(width: Dimens.spacing),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : null,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                ),
                if (isSelected) ...[
                  const Spacer(),
                  Icon(
                    Icons.check,
                    size: Dimens.iconSizeS,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ],
            ),
          ),
        );
}

class _SecondaryActionsGroup extends StatelessWidget {
  const _SecondaryActionsGroup();

  @override
  Widget build(BuildContext context) {
    final appBar = context.findAncestorWidgetOfExactType<EditorAppBar>()!;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(Dimens.buttonRadius),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: PopupMenuButton<String>(
        tooltip: 'More Options',
        style: IconButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          padding: const EdgeInsets.all(Dimens.spacing),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimens.buttonRadius),
          ),
        ),
        icon: Icon(
          Icons.more_horiz,
          size: Dimens.iconSizeM,
        ),
        onSelected: (value) {
          switch (value) {
            case 'new_file':
              appBar.onNewFile();
              break;
            case 'new_folder':
              appBar.onNewFolder();
              break;
            case 'toggle_preview':
              appBar.onTogglePreview();
              break;
          }
        },
        itemBuilder: (context) => [
          _MenuItem(
            context: context,
            value: 'new_file',
            icon: Icons.note_add_outlined,
            label: 'New File',
          ),
          _MenuItem(
            context: context,
            value: 'new_folder',
            icon: Icons.create_new_folder_outlined,
            label: 'New Folder',
          ),
          if (appBar.viewMode == ProjectEditorView.editor ||
              appBar.viewMode == ProjectEditorView.preview)
            _MenuItem(
              context: context,
              value: 'toggle_preview',
              icon: appBar.isPreviewVisible
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              label: appBar.isPreviewVisible ? 'Hide Preview' : 'Show Preview',
            ),
        ],
      ),
    );
  }
}

class _MenuItem extends PopupMenuItem<String> {
  _MenuItem({
    required BuildContext context,
    required String value,
    required IconData icon,
    required String label,
  }) : super(
          value: value,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimens.spacing,
              vertical: Dimens.halfSpacing,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(Dimens.minSpacing),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(Dimens.radiusXS),
                  ),
                  child: Icon(
                    icon,
                    size: Dimens.iconSizeS,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(width: Dimens.spacing),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        );
}
