import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:markflow/src/core/theme/dimens.dart';
import 'package:markflow/src/datasource/models/project.dart';
import 'package:markflow/src/features/projects/logic/project_editor/project_editor_notifier.dart';
import 'package:markflow/src/features/projects/logic/project_editor/project_editor_state.dart';
import 'package:markflow/src/features/projects/ui/widgets/file_tree_panel.dart';
import 'package:markflow/src/features/projects/ui/widgets/markdown_editor.dart';
import 'package:markflow/src/features/projects/ui/widgets/markdown_preview.dart';
import 'package:markflow/src/features/projects/ui/widgets/git_panel.dart';

@RoutePage()
class ProjectEditorScreen extends StatefulWidget {
  final Project project;

  const ProjectEditorScreen({
    super.key,
    required this.project,
  });

  @override
  State<ProjectEditorScreen> createState() => _ProjectEditorScreenState();
}

class _ProjectEditorScreenState extends State<ProjectEditorScreen> {
  late final ProjectEditorNotifier _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = ProjectEditorNotifier();
    _notifier.loadProject(widget.project);
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ProjectEditorState>(
      valueListenable: _notifier,
      builder: (context, state, child) {
        if (state.isLoading) {
          return Scaffold(
            body: Column(
              children: [
                _DesktopEditorHeader(
                  project: widget.project,
                  selectedFile: null,
                  hasUnsavedChanges: false,
                  viewMode: ProjectEditorView.editor,
                  isPreviewVisible: false,
                  onSave: () {},
                  onViewModeChanged: (_) {},
                  onTogglePreview: () {},
                  onNewFile: () {},
                  onNewFolder: () {},
                ),
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ],
            ),
          );
        }

        if (state.error != null) {
          return Scaffold(
            body: Column(
              children: [
                _DesktopEditorHeader(
                  project: widget.project,
                  selectedFile: null,
                  hasUnsavedChanges: false,
                  viewMode: ProjectEditorView.editor,
                  isPreviewVisible: false,
                  onSave: () {},
                  onViewModeChanged: (_) {},
                  onTogglePreview: () {},
                  onNewFile: () {},
                  onNewFolder: () {},
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        SizedBox(height: Dimens.desktopSpacing),
                        Text(
                          'Error loading project',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        SizedBox(height: Dimens.desktopSpacing / 2),
                        Text(
                          state.error!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: Dimens.desktopSpacingL),
                        ElevatedButton(
                          onPressed: () => _notifier.loadProject(widget.project),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          body: Column(
            children: [
              _DesktopEditorHeader(
                project: state.project!,
                selectedFile: state.currentFile,
                hasUnsavedChanges: state.hasUnsavedChanges,
                viewMode: state.currentView,
                isPreviewVisible: state.isPreviewMode,
                onSave: _notifier.saveCurrentFile,
                onViewModeChanged: _notifier.setView,
                onTogglePreview: _notifier.togglePreviewMode,
                onNewFile: () => _showCreateFileDialog(context),
                onNewFolder: () => _showCreateFolderDialog(context),
              ),
              Expanded(
                child: _buildDesktopBody(context, state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDesktopBody(BuildContext context, ProjectEditorState state) {
    switch (state.currentView) {
      case ProjectEditorView.editor:
        return _buildDesktopEditorView(context, state);
      case ProjectEditorView.preview:
        return _buildDesktopPreviewView(context, state);
      case ProjectEditorView.split:
        return _buildDesktopSplitView(context, state);
      case ProjectEditorView.git:
        return _buildDesktopGitView(context, state);
      case ProjectEditorView.fileTree:
        return _buildDesktopEditorView(context, state);
    }
  }

  Widget _buildDesktopEditorView(BuildContext context, ProjectEditorState state) {
    return Row(
      children: [
        SizedBox(
          width: Dimens.desktopSidebarWidth,
          child: FileTreePanel(
            files: state.files,
            selectedFile: state.currentFile,
            onFileSelected: _notifier.openFile,
            onFileDeleted: _notifier.deleteFile,
            onFileRenamed: _notifier.renameFile,
            onFolderCreated: _notifier.createFolder,
            onFileCreated: _notifier.createFile,
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: state.currentFile != null
              ? MarkdownEditor(
                  file: state.currentFile!,
                  content: state.currentContent,
                  onContentChanged: _notifier.updateContent,
                  isLoading: state.isSaving,
                )
              : _buildDesktopNoFileSelected(context),
        ),
      ],
    );
  }

  Widget _buildDesktopPreviewView(BuildContext context, ProjectEditorState state) {
    return Row(
      children: [
        SizedBox(
          width: Dimens.desktopSidebarWidth,
          child: FileTreePanel(
            files: state.files,
            selectedFile: state.currentFile,
            onFileSelected: _notifier.openFile,
            onFileDeleted: _notifier.deleteFile,
            onFileRenamed: _notifier.renameFile,
            onFolderCreated: _notifier.createFolder,
            onFileCreated: _notifier.createFile,
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: state.currentFile != null
              ? MarkdownPreview(
                  content: state.currentContent,
                  fileName: state.currentFile!.name,
                )
              : _buildDesktopNoFileSelected(context),
        ),
      ],
    );
  }

  Widget _buildDesktopSplitView(BuildContext context, ProjectEditorState state) {
    return Row(
      children: [
        SizedBox(
          width: Dimens.desktopSidebarWidth,
          child: FileTreePanel(
            files: state.files,
            selectedFile: state.currentFile,
            onFileSelected: _notifier.openFile,
            onFileDeleted: _notifier.deleteFile,
            onFileRenamed: _notifier.renameFile,
            onFolderCreated: _notifier.createFolder,
            onFileCreated: _notifier.createFile,
          ),
        ),
        const VerticalDivider(width: 1),
        if (state.currentFile != null) ...[
          Expanded(
            child: MarkdownEditor(
              file: state.currentFile!,
              content: state.currentContent,
              onContentChanged: _notifier.updateContent,
              isLoading: state.isSaving,
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: MarkdownPreview(
              content: state.currentContent,
              fileName: state.currentFile!.name,
            ),
          ),
        ] else
          Expanded(
            flex: 2,
            child: _buildDesktopNoFileSelected(context),
          ),
      ],
    );
  }

  Widget _buildDesktopGitView(BuildContext context, ProjectEditorState state) {
    return Row(
      children: [
        SizedBox(
          width: Dimens.desktopSidebarWidth,
          child: FileTreePanel(
            files: state.files,
            selectedFile: state.currentFile,
            onFileSelected: _notifier.openFile,
            onFileDeleted: _notifier.deleteFile,
            onFileRenamed: _notifier.renameFile,
            onFolderCreated: _notifier.createFolder,
            onFileCreated: _notifier.createFile,
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: GitPanel(
            gitStatus: state.gitStatus,
            recentCommits: state.recentCommits,
            currentBranch: state.currentBranch,
            onStageFile: _notifier.stageFile,
            onUnstageFile: _notifier.unstageFile,
            onCommit: _notifier.commitChanges,
            onPush: _notifier.pushChanges,
            onPull: _notifier.pullChanges,
            onRefresh: _notifier.refreshGitStatus,
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopNoFileSelected(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 96,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          SizedBox(height: Dimens.desktopSpacing),
          Text(
            'No file selected',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
          ),
          SizedBox(height: Dimens.desktopSpacing / 2),
          Text(
            'Select a file from the tree to start editing',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
                ),
          ),
        ],
      ),
    );
  }

  void _showCreateFileDialog(BuildContext context) {
    String fileName = '';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: const Text('Create New File'),
        content: TextField(
          decoration: const InputDecoration(
            labelText: 'File name',
            hintText: 'example.md',
          ),
          onChanged: (value) => fileName = value,
          onSubmitted: (name) {
            if (name.isNotEmpty) {
              _notifier.createFileWithOptions(fileName: name);
              Navigator.of(context).pop();
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
              if (fileName.isNotEmpty) {
                _notifier.createFileWithOptions(fileName: fileName);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showCreateFolderDialog(BuildContext context) {
    String folderName = '';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: const Text('Create New Folder'),
        content: TextField(
          decoration: const InputDecoration(
            labelText: 'Folder name',
            hintText: 'docs',
          ),
          onChanged: (value) => folderName = value,
          onSubmitted: (name) {
            if (name.isNotEmpty) {
              _notifier.createFolder(name);
              Navigator.of(context).pop();
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
              if (folderName.isNotEmpty) {
                _notifier.createFolder(folderName);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class _DesktopEditorHeader extends StatelessWidget {
  final Project project;
  final dynamic selectedFile;
  final bool hasUnsavedChanges;
  final ProjectEditorView viewMode;
  final bool isPreviewVisible;
  final VoidCallback onSave;
  final void Function(ProjectEditorView) onViewModeChanged;
  final VoidCallback onTogglePreview;
  final VoidCallback onNewFile;
  final VoidCallback onNewFolder;

  const _DesktopEditorHeader({
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
  Widget build(BuildContext context) {
    return Container(
      height: Dimens.desktopToolbarHeight,
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.desktopMainPadding,
        vertical: Dimens.desktopSpacing / 2,
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
          Text(
            project.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (selectedFile != null) ...[
            const Text(' • '),
            Text(
              selectedFile.name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (hasUnsavedChanges)
            Container(
              margin: EdgeInsets.only(left: Dimens.desktopSpacing / 2),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          const Spacer(),
          _DesktopToolbarButton(
            icon: Icons.add,
            tooltip: 'New File',
            onPressed: onNewFile,
          ),
          _DesktopToolbarButton(
            icon: Icons.create_new_folder,
            tooltip: 'New Folder',
            onPressed: onNewFolder,
          ),
          const SizedBox(width: 8),
          _DesktopViewModeToggle(
            currentView: viewMode,
            onViewModeChanged: onViewModeChanged,
          ),
          const SizedBox(width: 8),
          _DesktopToolbarButton(
            icon: Icons.save,
            tooltip: 'Save',
            onPressed: hasUnsavedChanges ? onSave : null,
            isEnabled: hasUnsavedChanges,
          ),
          _DesktopToolbarButton(
            icon: Icons.close,
            tooltip: 'Close',
            onPressed: () => context.router.pop(),
          ),
        ],
      ),
    );
  }
}

class _DesktopToolbarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool isEnabled;

  const _DesktopToolbarButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: isEnabled ? onPressed : null,
        icon: Icon(icon),
        iconSize: Dimens.desktopIconSize,
        constraints: BoxConstraints(
          minWidth: Dimens.desktopButtonHeight,
          minHeight: Dimens.desktopButtonHeight,
        ),
        style: IconButton.styleFrom(
          foregroundColor: isEnabled
              ? Theme.of(context).colorScheme.onSurface
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

class _DesktopViewModeToggle extends StatelessWidget {
  final ProjectEditorView currentView;
  final void Function(ProjectEditorView) onViewModeChanged;

  const _DesktopViewModeToggle({
    required this.currentView,
    required this.onViewModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
        borderRadius: BorderRadius.circular(Dimens.desktopRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ViewModeButton(
            icon: Icons.edit,
            tooltip: 'Editor',
            isSelected: currentView == ProjectEditorView.editor,
            onPressed: () => onViewModeChanged(ProjectEditorView.editor),
          ),
          _ViewModeButton(
            icon: Icons.visibility,
            tooltip: 'Preview',
            isSelected: currentView == ProjectEditorView.preview,
            onPressed: () => onViewModeChanged(ProjectEditorView.preview),
          ),
          _ViewModeButton(
            icon: Icons.view_column,
            tooltip: 'Split',
            isSelected: currentView == ProjectEditorView.split,
            onPressed: () => onViewModeChanged(ProjectEditorView.split),
          ),
          _ViewModeButton(
            icon: Icons.source,
            tooltip: 'Git',
            isSelected: currentView == ProjectEditorView.git,
            onPressed: () => onViewModeChanged(ProjectEditorView.git),
          ),
        ],
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
        borderRadius: BorderRadius.circular(Dimens.desktopRadius),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(Dimens.desktopRadius),
          child: Container(
            width: Dimens.desktopButtonHeight,
            height: Dimens.desktopButtonHeight,
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: Dimens.desktopIconSize,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
