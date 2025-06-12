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
      title: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  project.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (selectedFile != null)
                  Text(
                    selectedFile!.name,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (hasUnsavedChanges)
            Container(
              margin: const EdgeInsets.only(left: Dimens.halfSpacing),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
      actions: [
        // Save button
        if (hasUnsavedChanges)
          IconButton(
            onPressed: onSave,
            icon: const Icon(Icons.save),
            tooltip: 'Save (Cmd+S)',
          ),
        
        // View mode selector
        PopupMenuButton<ProjectEditorView>(
          icon: Icon(_getViewModeIcon(viewMode)),
          tooltip: 'View Mode',
          onSelected: onViewModeChanged,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: ProjectEditorView.editor,
              child: Row(
                children: [
                  Icon(
                    Icons.edit,
                    size: Dimens.iconSizeS,
                    color: viewMode == ProjectEditorView.editor
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  const SizedBox(width: Dimens.halfSpacing),
                  Text(
                    'Editor',
                    style: TextStyle(
                      color: viewMode == ProjectEditorView.editor
                          ? Theme.of(context).colorScheme.primary
                          : null,
                      fontWeight: viewMode == ProjectEditorView.editor
                          ? FontWeight.w600
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: ProjectEditorView.preview,
              child: Row(
                children: [
                  Icon(
                    Icons.visibility,
                    size: Dimens.iconSizeS,
                    color: viewMode == ProjectEditorView.preview
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  const SizedBox(width: Dimens.halfSpacing),
                  Text(
                    'Preview',
                    style: TextStyle(
                      color: viewMode == ProjectEditorView.preview
                          ? Theme.of(context).colorScheme.primary
                          : null,
                      fontWeight: viewMode == ProjectEditorView.preview
                          ? FontWeight.w600
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: ProjectEditorView.split,
              child: Row(
                children: [
                  Icon(
                    Icons.view_column,
                    size: Dimens.iconSizeS,
                    color: viewMode == ProjectEditorView.split
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  const SizedBox(width: Dimens.halfSpacing),
                  Text(
                    'Split',
                    style: TextStyle(
                      color: viewMode == ProjectEditorView.split
                          ? Theme.of(context).colorScheme.primary
                          : null,
                      fontWeight: viewMode == ProjectEditorView.split
                          ? FontWeight.w600
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: ProjectEditorView.git,
              child: Row(
                children: [
                  Icon(
                    Icons.source,
                    size: Dimens.iconSizeS,
                    color: viewMode == ProjectEditorView.git
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  const SizedBox(width: Dimens.halfSpacing),
                  Text(
                    'Git',
                    style: TextStyle(
                      color: viewMode == ProjectEditorView.git
                          ? Theme.of(context).colorScheme.primary
                          : null,
                      fontWeight: viewMode == ProjectEditorView.git
                          ? FontWeight.w600
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        // More options
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
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
            const PopupMenuItem(
              value: 'new_file',
              child: Row(
                children: [
                  Icon(Icons.insert_drive_file, size: Dimens.iconSizeS),
                  SizedBox(width: Dimens.halfSpacing),
                  Text('New File'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'new_folder',
              child: Row(
                children: [
                  Icon(Icons.folder, size: Dimens.iconSizeS),
                  SizedBox(width: Dimens.halfSpacing),
                  Text('New Folder'),
                ],
              ),
            ),
            if (viewMode == ProjectEditorView.editor || viewMode == ProjectEditorView.preview)
              PopupMenuItem(
                value: 'toggle_preview',
                child: Row(
                  children: [
                    Icon(
                      isPreviewVisible ? Icons.visibility_off : Icons.visibility,
                      size: Dimens.iconSizeS,
                    ),
                    const SizedBox(width: Dimens.halfSpacing),
                    Text(isPreviewVisible ? 'Hide Preview' : 'Show Preview'),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
  
  IconData _getViewModeIcon(ProjectEditorView mode) {
    switch (mode) {
      case ProjectEditorView.editor:
        return Icons.edit;
      case ProjectEditorView.preview:
        return Icons.visibility;
      case ProjectEditorView.split:
        return Icons.view_column;
      case ProjectEditorView.git:
        return Icons.source;
      case ProjectEditorView.fileTree:
        return Icons.folder;
    }
  }
}