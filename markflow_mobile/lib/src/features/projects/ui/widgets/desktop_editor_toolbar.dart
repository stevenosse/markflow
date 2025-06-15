import 'package:flutter/material.dart';
import 'package:markflow/src/core/theme/dimens.dart';
import 'package:markflow/src/datasource/models/project.dart';
import 'package:markflow/src/datasource/models/markdown_file.dart';
import 'package:markflow/src/features/projects/logic/project_editor/project_editor_state.dart';
import 'package:auto_route/auto_route.dart';

class DesktopEditorToolbar extends StatelessWidget {
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
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final VoidCallback? onFind;
  final VoidCallback? onReplace;
  
  const DesktopEditorToolbar({
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
    this.onUndo,
    this.onRedo,
    this.onFind,
    this.onReplace,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(
        horizontal: Dimens.spacing,
        vertical: Dimens.halfSpacing,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildProjectInfo(context),
          const Spacer(),
          _buildFileActions(context),
          const SizedBox(width: Dimens.spacing),
          _buildEditActions(context),
          const SizedBox(width: Dimens.spacing),
          _buildViewModeToggle(context),
          const SizedBox(width: Dimens.spacing),
          _buildMainActions(context),
        ],
      ),
    );
  }

  Widget _buildProjectInfo(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.folder_outlined,
          size: Dimens.iconSizeS,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: Dimens.halfSpacing),
        Text(
          project.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (selectedFile != null) ...[
          Container(
            margin: const EdgeInsets.symmetric(horizontal: Dimens.halfSpacing),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
          ),
          Icon(
            _getFileIcon(selectedFile!.name),
            size: Dimens.iconSizeXS,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          const SizedBox(width: Dimens.quarterSpacing),
          Text(
            selectedFile!.name,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (hasUnsavedChanges)
            Container(
              margin: const EdgeInsets.only(left: Dimens.halfSpacing),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildFileActions(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ToolbarButton(
          icon: Icons.add,
          tooltip: 'New File (Cmd+N)',
          onPressed: onNewFile,
        ),
        _ToolbarButton(
          icon: Icons.create_new_folder_outlined,
          tooltip: 'New Folder',
          onPressed: onNewFolder,
        ),
      ],
    );
  }

  Widget _buildEditActions(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ToolbarButton(
          icon: Icons.undo,
          tooltip: 'Undo (Cmd+Z)',
          onPressed: onUndo,
          isEnabled: onUndo != null,
        ),
        _ToolbarButton(
          icon: Icons.redo,
          tooltip: 'Redo (Cmd+Shift+Z)',
          onPressed: onRedo,
          isEnabled: onRedo != null,
        ),
        const SizedBox(width: Dimens.halfSpacing),
        _ToolbarButton(
          icon: Icons.search,
          tooltip: 'Find (Cmd+F)',
          onPressed: onFind,
          isEnabled: onFind != null,
        ),
        _ToolbarButton(
          icon: Icons.find_replace,
          tooltip: 'Replace (Cmd+H)',
          onPressed: onReplace,
          isEnabled: onReplace != null,
        ),
      ],
    );
  }

  Widget _buildViewModeToggle(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
        borderRadius: BorderRadius.circular(Dimens.radius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ViewModeButton(
            icon: Icons.edit_outlined,
            tooltip: 'Editor',
            isSelected: viewMode == ProjectEditorView.editor,
            onPressed: () => onViewModeChanged(ProjectEditorView.editor),
          ),
          _ViewModeButton(
            icon: Icons.visibility_outlined,
            tooltip: 'Preview',
            isSelected: viewMode == ProjectEditorView.preview,
            onPressed: () => onViewModeChanged(ProjectEditorView.preview),
          ),
          _ViewModeButton(
            icon: Icons.view_column_outlined,
            tooltip: 'Split View',
            isSelected: viewMode == ProjectEditorView.split,
            onPressed: () => onViewModeChanged(ProjectEditorView.split),
          ),
          _ViewModeButton(
            icon: Icons.source_outlined,
            tooltip: 'Git',
            isSelected: viewMode == ProjectEditorView.git,
            onPressed: () => onViewModeChanged(ProjectEditorView.git),
          ),
        ],
      ),
    );
  }

  Widget _buildMainActions(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ToolbarButton(
          icon: Icons.save_outlined,
          tooltip: 'Save (Cmd+S)',
          onPressed: hasUnsavedChanges ? onSave : null,
          isEnabled: hasUnsavedChanges,
          isPrimary: hasUnsavedChanges,
        ),
        const SizedBox(width: Dimens.halfSpacing),
        _ToolbarButton(
          icon: Icons.close,
          tooltip: 'Close Project',
          onPressed: () => context.router.pop(),
        ),
      ],
    );
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'md':
      case 'markdown':
        return Icons.description_outlined;
      case 'txt':
        return Icons.text_snippet_outlined;
      case 'json':
        return Icons.data_object_outlined;
      case 'yaml':
      case 'yml':
        return Icons.settings_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool isEnabled;
  final bool isPrimary;

  const _ToolbarButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.isEnabled = true,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveEnabled = isEnabled && onPressed != null;
    
    return Tooltip(
      message: tooltip,
      child: Material(
        color: isPrimary && effectiveEnabled
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(Dimens.radius),
        child: InkWell(
          onTap: effectiveEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(Dimens.radius),
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 18,
              color: effectiveEnabled
                  ? (isPrimary
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface)
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ),
      ),
    );
  }
}

class _ViewModeButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool isSelected;
  final VoidCallback onPressed;

  const _ViewModeButton({
    required this.icon,
    required this.tooltip,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: isSelected
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(Dimens.radius - 1),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(Dimens.radius - 1),
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 16,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }
}