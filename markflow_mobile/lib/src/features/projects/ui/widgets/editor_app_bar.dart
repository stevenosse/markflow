import 'package:flutter/material.dart';
import 'package:markflow/src/core/theme/dimens.dart';
import 'package:markflow/src/datasource/models/project.dart';
import 'package:markflow/src/datasource/models/markdown_file.dart';
import 'package:markflow/src/features/projects/logic/project_editor/project_editor_state.dart';
import 'package:markflow/src/features/projects/ui/widgets/project_settings_dialog.dart';

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
  final VoidCallback? onProjectSettings;

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
    this.onProjectSettings,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kToolbarHeight + Dimens.spacing,
      padding: const EdgeInsets.symmetric(
        horizontal: Dimens.spacing,
        vertical: Dimens.halfSpacing,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildTitleSection(context),
          const Spacer(),
          _buildViewModeSection(context),
          const SizedBox(width: Dimens.spacing),
          _buildActionSection(context),
        ],
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: 'Home',
          child: Material(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(Dimens.radiusS),
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(Dimens.radiusS),
              child: Container(
                padding: const EdgeInsets.all(Dimens.halfSpacing),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimens.radiusS),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.home_outlined,
                  size: Dimens.iconSizeS,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: Dimens.spacing),
        const Text('•'),
        const SizedBox(width: Dimens.spacing),

        // Project icon
        Container(
          padding: const EdgeInsets.all(Dimens.halfSpacing),
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(Dimens.radiusS),
          ),
          child: Icon(
            Icons.folder_outlined,
            size: Dimens.iconSizeS,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: Dimens.spacing),

        // Title and file info
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              project.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                    height: 1.2,
                  ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            if (selectedFile != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      selectedFile!.name,
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
                  ],
                ),
              ),
          ],
        ),

        // Unsaved indicator
        if (hasUnsavedChanges) ...[
          const SizedBox(width: Dimens.spacing),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimens.halfSpacing,
              vertical: Dimens.minSpacing,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .tertiary
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(Dimens.fullRadius),
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .tertiary
                    .withValues(alpha: 0.2),
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
          ),
        ],
      ],
    );
  }

  Widget _buildViewModeSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(Dimens.buttonRadius),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildViewModeButton(
              context, ProjectEditorView.editor, Icons.edit_outlined, 'Editor'),
          _buildViewModeButton(context, ProjectEditorView.preview,
              Icons.visibility_outlined, 'Preview'),
          _buildViewModeButton(context, ProjectEditorView.split,
              Icons.view_column_outlined, 'Split'),
          _buildViewModeButton(
              context, ProjectEditorView.git, Icons.source_outlined, 'Git'),
        ],
      ),
    );
  }

  Widget _buildViewModeButton(
    BuildContext context,
    ProjectEditorView mode,
    IconData icon,
    String tooltip,
  ) {
    final isSelected = viewMode == mode;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Colors.transparent,
        borderRadius: BorderRadius.circular(Dimens.radiusS),
        child: InkWell(
          onTap: () => onViewModeChanged(mode),
          borderRadius: BorderRadius.circular(Dimens.radiusS),
          child: Container(
            margin: const EdgeInsets.all(2),
            padding: const EdgeInsets.all(Dimens.halfSpacing),
            child: Icon(
              icon,
              size: Dimens.iconSizeS,
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionSection(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Save button (only when there are unsaved changes)
        if (hasUnsavedChanges) ...[
          _buildActionButton(
            context,
            icon: Icons.save_outlined,
            tooltip: 'Save (Cmd+S)',
            onPressed: onSave,
            isPrimary: true,
          ),
          const SizedBox(width: Dimens.halfSpacing),
        ],

        // New file button
        _buildActionButton(
          context,
          icon: Icons.note_add_outlined,
          tooltip: 'New File',
          onPressed: onNewFile,
        ),
        const SizedBox(width: Dimens.halfSpacing),

        // New folder button
        _buildActionButton(
          context,
          icon: Icons.create_new_folder_outlined,
          tooltip: 'New Folder',
          onPressed: onNewFolder,
        ),

        // Project settings button
        if (onProjectSettings != null) ...[
          const SizedBox(width: Dimens.halfSpacing),
          _buildActionButton(
            context,
            icon: Icons.settings_outlined,
            tooltip: 'Project Settings',
            onPressed: () => _showProjectSettings(context),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: isPrimary
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(Dimens.radiusS),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(Dimens.radiusS),
          child: Container(
            padding: const EdgeInsets.all(Dimens.halfSpacing),
            decoration: isPrimary
                ? null
                : BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimens.radiusS),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
            child: Icon(
              icon,
              size: Dimens.iconSizeS,
              color: isPrimary
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }

  void _showProjectSettings(BuildContext context) {
    if (onProjectSettings != null) {
      ProjectSettingsDialog.show(context, project).then((result) {
        if (result?.hasChanges == true) {
          onProjectSettings!();
        }
      });
    }
  }
}
