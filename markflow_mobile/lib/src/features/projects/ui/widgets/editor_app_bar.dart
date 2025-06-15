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
      title: _buildTitleSection(context),
      actions: _buildActionSection(context),
    );
  }

  Widget _buildTitleSection(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildProjectTitle(context),
              if (selectedFile != null) _buildFileSubtitle(context),
            ],
          ),
        ),
        if (hasUnsavedChanges) _buildUnsavedBadge(context),
      ],
    );
  }

  Widget _buildProjectTitle(BuildContext context) {
    return Text(
      project.name,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }

  Widget _buildFileSubtitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Icon(
            Icons.description_outlined,
            size: 12,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              selectedFile!.name,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnsavedBadge(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: Dimens.halfSpacing),
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Unsaved',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActionSection(BuildContext context) {
    return [
      if (hasUnsavedChanges) _buildSaveButton(context),
      _buildViewModeButton(context),
      _buildMoreOptionsButton(context),
      const SizedBox(width: Dimens.halfSpacing),
    ];
  }

  Widget _buildSaveButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: Dimens.halfSpacing),
      height: 36,
      child: IconButton(
        onPressed: onSave,
        icon: const Icon(Icons.save_outlined),
        iconSize: 20,
        tooltip: 'Save (Cmd+S)',
        style: IconButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          foregroundColor: Theme.of(context).colorScheme.primary,
          padding: const EdgeInsets.all(8),
          minimumSize: const Size(36, 36),
          maximumSize: const Size(36, 36),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildViewModeButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: Dimens.halfSpacing),
      height: 36,
      child: PopupMenuButton<ProjectEditorView>(
        icon: Icon(_getViewModeIcon(viewMode)),
        iconSize: 20,
        tooltip: 'View Mode',
        onSelected: onViewModeChanged,
        style: IconButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          padding: const EdgeInsets.all(8),
          minimumSize: const Size(36, 36),
          maximumSize: const Size(36, 36),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        itemBuilder: (context) => [
          _buildViewModeMenuItem(context, ProjectEditorView.editor, Icons.edit_outlined, 'Editor'),
          _buildViewModeMenuItem(context, ProjectEditorView.preview, Icons.visibility_outlined, 'Preview'),
          _buildViewModeMenuItem(context, ProjectEditorView.split, Icons.view_column_outlined, 'Split'),
          _buildViewModeMenuItem(context, ProjectEditorView.git, Icons.source_outlined, 'Git'),
        ],
      ),
    );
  }

  Widget _buildMoreOptionsButton(BuildContext context) {
    return SizedBox(
      height: 36,
      child: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert),
        iconSize: 20,
        tooltip: 'More Options',
        style: IconButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          padding: const EdgeInsets.all(8),
          minimumSize: const Size(36, 36),
          maximumSize: const Size(36, 36),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onSelected: (value) {
          switch (value) {
            case 'new_file':
              onNewFile();
              break;
            case 'new_folder':
              onNewFolder();
              break;
            case 'toggle_preview':
              onTogglePreview();
              break;
          }
        },
        itemBuilder: (context) => [
          _buildMenuItem(context, 'new_file', Icons.insert_drive_file_outlined, 'New File'),
          _buildMenuItem(context, 'new_folder', Icons.folder_outlined, 'New Folder'),
          if (viewMode == ProjectEditorView.editor || viewMode == ProjectEditorView.preview)
            _buildMenuItem(
              context,
              'toggle_preview',
              isPreviewVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              isPreviewVisible ? 'Hide Preview' : 'Show Preview',
            ),
        ],
      ),
    );
  }

  PopupMenuItem<ProjectEditorView> _buildViewModeMenuItem(
    BuildContext context,
    ProjectEditorView value,
    IconData icon,
    String label,
  ) {
    final isSelected = viewMode == value;
    return PopupMenuItem(
      value: value,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              )
            : null,
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isSelected ? Theme.of(context).colorScheme.primary : null,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(
    BuildContext context,
    String value,
    IconData icon,
    String label,
  ) {
    return PopupMenuItem(
      value: value,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 12),
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
}