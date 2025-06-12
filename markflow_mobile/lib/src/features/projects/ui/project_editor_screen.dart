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
import 'package:markflow/src/features/projects/ui/widgets/editor_app_bar.dart';

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
            appBar: AppBar(
              title: Text(widget.project.name),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state.error != null) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.project.name),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: Dimens.iconSizeXL,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: Dimens.spacing),
                  Text(
                    'Error loading project',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: Dimens.halfSpacing),
                  Text(
                    state.error!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Dimens.doubleSpacing),
                  ElevatedButton(
                    onPressed: () => _notifier.loadProject(widget.project),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: EditorAppBar(
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
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ProjectEditorState state) {
    switch (state.currentView) {
      case ProjectEditorView.editor:
        return _buildEditorView(context, state);
      case ProjectEditorView.preview:
        return _buildPreviewView(context, state);
      case ProjectEditorView.split:
        return _buildSplitView(context, state);
      case ProjectEditorView.git:
        return _buildGitView(context, state);
      case ProjectEditorView.fileTree:
        return _buildEditorView(context, state);
    }
  }

  Widget _buildEditorView(BuildContext context, ProjectEditorState state) {
    return Row(
      children: [
        SizedBox(
          width: Dimens.fileTreeWidth,
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
              : _buildNoFileSelected(context),
        ),
      ],
    );
  }

  Widget _buildPreviewView(BuildContext context, ProjectEditorState state) {
    return Row(
      children: [
        SizedBox(
          width: Dimens.fileTreeWidth,
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
              : _buildNoFileSelected(context),
        ),
      ],
    );
  }

  Widget _buildSplitView(BuildContext context, ProjectEditorState state) {
    return Row(
      children: [
        SizedBox(
          width: Dimens.fileTreeWidth,
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
            child: _buildNoFileSelected(context),
          ),
      ],
    );
  }

  Widget _buildGitView(BuildContext context, ProjectEditorState state) {
    return Row(
      children: [
        SizedBox(
          width: Dimens.fileTreeWidth,
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

  Widget _buildNoFileSelected(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: Dimens.iconSizeXL * 2,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: Dimens.spacing),
          Text(
            'No file selected',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
          ),
          const SizedBox(height: Dimens.halfSpacing),
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
