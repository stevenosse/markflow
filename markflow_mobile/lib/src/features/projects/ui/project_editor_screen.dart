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
import 'package:markflow/src/shared/components/dialogs/create_file_dialog.dart';
import 'package:markflow/src/shared/components/dialogs/create_folder_dialog.dart';
import 'package:markflow/src/shared/components/shortcuts/editor_shortcuts.dart';

@RoutePage()
class ProjectEditorScreen extends StatefulWidget {
  final Project project;

  const ProjectEditorScreen({
    super.key,
    required this.project,
  });

  @override
  State<ProjectEditorScreen> createState() => ProjectEditorScreenState();
}

class ProjectEditorScreenState extends State<ProjectEditorScreen> {
  late final ProjectEditorNotifier notifier;

  @override
  void initState() {
    super.initState();
    notifier = ProjectEditorNotifier();
    notifier.loadProject(widget.project);
  }

  @override
  void dispose() {
    notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ProjectEditorState>(
      valueListenable: notifier,
      builder: (context, state, child) {
        if (state.isLoading) {
          return Scaffold(
            body: Column(
              children: [
                EditorAppBar(
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
                EditorAppBar(
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
                          onPressed: () => notifier.loadProject(widget.project),
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

        return EditorShortcuts(
          notifier: notifier,
          state: state,
          child: Scaffold(
            body: Column(
              children: [
                EditorAppBar(
                  project: state.project!,
                  selectedFile: state.currentFile,
                  hasUnsavedChanges: state.hasUnsavedChanges,
                  viewMode: state.currentView,
                  isPreviewVisible: state.isPreviewMode,
                  onSave: notifier.saveCurrentFile,
                  onViewModeChanged: notifier.setView,
                  onTogglePreview: notifier.togglePreviewMode,
                  onNewFile: () => _showCreateFileDialog(context),
                  onNewFolder: () => _showCreateFolderDialog(context),
                ),
                Expanded(
                  child: _buildDesktopBody(context, state),
                ),
              ],
            ),
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
            onFileSelected: notifier.openFile,
                  onFileDeleted: notifier.deleteFile,
                  onFileRenamed: notifier.renameFile,
                  onFolderCreated: notifier.createFolder,
                  onFileCreated: notifier.createFile,
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: state.currentFile != null
              ? MarkdownEditor(
                  openFiles: state.openFiles,
                  activeFile: state.currentFile!,
                  content: state.currentContent,
                  onContentChanged: notifier.updateContent,
                  onFileSelected: notifier.switchToFile,
                  onFileClose: notifier.closeFile,
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
            onFileSelected: notifier.openFile,
                    onFileDeleted: notifier.deleteFile,
                    onFileRenamed: notifier.renameFile,
                    onFolderCreated: notifier.createFolder,
                    onFileCreated: notifier.createFile,
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
            onFileSelected: notifier.openFile,
                onFileDeleted: notifier.deleteFile,
                onFileRenamed: notifier.renameFile,
                onFolderCreated: notifier.createFolder,
                onFileCreated: notifier.createFile,
          ),
        ),
        const VerticalDivider(width: 1),
        if (state.currentFile != null) ...[
          Expanded(
            child: MarkdownEditor(
              openFiles: state.openFiles,
              activeFile: state.currentFile!,
              content: state.currentContent,
              onContentChanged: notifier.updateContent,
                onFileSelected: notifier.switchToFile,
                onFileClose: notifier.closeFile,
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
            onFileSelected: notifier.openFile,
                onFileDeleted: notifier.deleteFile,
                onFileRenamed: notifier.renameFile,
                onFolderCreated: notifier.createFolder,
                onFileCreated: notifier.createFile,
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: GitPanel(
            gitStatus: state.gitStatus,
            recentCommits: state.recentCommits,
            currentBranch: state.currentBranch,
            onStageFile: notifier.stageFile,
                onUnstageFile: notifier.unstageFile,
                onCommit: notifier.commitChanges,
                onPush: notifier.pushChanges,
                onPull: notifier.pullChanges,
                onRefresh: notifier.refreshGitStatus,
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

  void _showCreateFileDialog(BuildContext context) async {
    final fileName = await CreateFileDialog.show(
      context: context,
      initialPath: notifier.value.project?.path,
    );
    
    if (fileName != null && fileName.isNotEmpty) {
      notifier.createFileWithOptions(fileName: fileName);
    }
  }

  void _showCreateFolderDialog(BuildContext context) async {
    final folderName = await CreateFolderDialog.show(
      context: context,
      initialPath: notifier.value.project?.path,
    );
    
    if (folderName != null && folderName.isNotEmpty) {
      notifier.createFolder(folderName);
    }
  }
}
