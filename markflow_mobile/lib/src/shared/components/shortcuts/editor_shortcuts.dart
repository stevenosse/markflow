import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markflow/src/features/projects/logic/project_editor/project_editor_notifier.dart';
import 'package:markflow/src/features/projects/logic/project_editor/project_editor_state.dart';
import 'package:markflow/src/shared/components/dialogs/create_file_dialog.dart';
import 'package:markflow/src/shared/components/dialogs/find_dialog.dart';
import 'package:markflow/src/shared/components/dialogs/replace_dialog.dart';
import 'package:markflow/src/shared/components/dialogs/go_to_line_dialog.dart';
import 'package:markflow/src/shared/components/dialogs/confirmation_dialog.dart';

/// Widget that provides editor-specific keyboard shortcuts
class EditorShortcuts extends StatelessWidget {
  final Widget child;
  final ProjectEditorNotifier notifier;
  final ProjectEditorState state;

  const EditorShortcuts({
    super.key,
    required this.child,
    required this.notifier,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: _buildShortcuts(),
      child: Actions(
        actions: _buildActions(context),
        child: child,
      ),
    );
  }

  Map<ShortcutActivator, Intent> _buildShortcuts() {
    return {
      // File operations
      const SingleActivator(LogicalKeyboardKey.keyT, meta: true, shift: true):
          const CreateFileIntent(),
      const SingleActivator(LogicalKeyboardKey.keyS, meta: true):
          const SaveFileIntent(),
      const SingleActivator(LogicalKeyboardKey.keyS, meta: true, shift: true):
          const SaveAllFilesIntent(),
      const SingleActivator(LogicalKeyboardKey.keyW, meta: true):
          const CloseTabIntent(),
      const SingleActivator(LogicalKeyboardKey.delete, meta: true):
          const DeleteFileIntent(),
      const SingleActivator(LogicalKeyboardKey.enter, meta: true):
          const RenameFileIntent(),

      // Search and replace
      const SingleActivator(LogicalKeyboardKey.keyF, meta: true):
          const FindInFileIntent(),
      const SingleActivator(LogicalKeyboardKey.keyF, meta: true, shift: true):
          const FindInProjectIntent(),
      const SingleActivator(LogicalKeyboardKey.keyR, meta: true):
          const ReplaceInFileIntent(),

      // Navigation
      const SingleActivator(LogicalKeyboardKey.tab, meta: true):
          const NextTabIntent(),
      const SingleActivator(LogicalKeyboardKey.tab, meta: true, shift: true):
          const PreviousTabIntent(),
      const SingleActivator(LogicalKeyboardKey.keyG, meta: true):
          const GoToLineIntent(),

      // View controls
      const SingleActivator(LogicalKeyboardKey.keyB, meta: true):
          const ToggleSidebarIntent(),
      const SingleActivator(LogicalKeyboardKey.keyP, meta: true, shift: true):
          const TogglePreviewIntent(),
      const SingleActivator(LogicalKeyboardKey.keyG, meta: true, shift: true):
          const ToggleGitPanelIntent(),

      // Editor operations
      const SingleActivator(LogicalKeyboardKey.keyD, meta: true):
          const DuplicateLineIntent(),
      const SingleActivator(LogicalKeyboardKey.slash, meta: true):
          const ToggleCommentIntent(),

      // Zoom
      const SingleActivator(LogicalKeyboardKey.equal, meta: true):
          const ZoomInIntent(),
      const SingleActivator(LogicalKeyboardKey.minus, meta: true):
          const ZoomOutIntent(),
      const SingleActivator(LogicalKeyboardKey.digit0, meta: true):
          const ResetZoomIntent(),
    };
  }

  Map<Type, Action<Intent>> _buildActions(BuildContext context) {
    return {
      CreateFileIntent: CallbackAction<CreateFileIntent>(
        onInvoke: (_) => _createFile(context),
      ),
      SaveFileIntent: CallbackAction<SaveFileIntent>(
        onInvoke: (_) => _saveFile(),
      ),
      SaveAllFilesIntent: CallbackAction<SaveAllFilesIntent>(
        onInvoke: (_) => _saveAllFiles(),
      ),
      CloseTabIntent: CallbackAction<CloseTabIntent>(
        onInvoke: (_) => _closeTab(),
      ),
      DeleteFileIntent: CallbackAction<DeleteFileIntent>(
        onInvoke: (_) => _deleteFile(context),
      ),
      RenameFileIntent: CallbackAction<RenameFileIntent>(
        onInvoke: (_) => _renameFile(context),
      ),
      FindInFileIntent: CallbackAction<FindInFileIntent>(
        onInvoke: (_) => _findInFile(context),
      ),
      FindInProjectIntent: CallbackAction<FindInProjectIntent>(
        onInvoke: (_) => _findInProject(context),
      ),
      ReplaceInFileIntent: CallbackAction<ReplaceInFileIntent>(
        onInvoke: (_) => _replaceInFile(context),
      ),
      NextTabIntent: CallbackAction<NextTabIntent>(
        onInvoke: (_) => _nextTab(),
      ),
      PreviousTabIntent: CallbackAction<PreviousTabIntent>(
        onInvoke: (_) => _previousTab(),
      ),
      GoToLineIntent: CallbackAction<GoToLineIntent>(
        onInvoke: (_) => _goToLine(context),
      ),
      ToggleSidebarIntent: CallbackAction<ToggleSidebarIntent>(
        onInvoke: (_) => _toggleSidebar(),
      ),
      TogglePreviewIntent: CallbackAction<TogglePreviewIntent>(
        onInvoke: (_) => _togglePreview(),
      ),
      ToggleGitPanelIntent: CallbackAction<ToggleGitPanelIntent>(
        onInvoke: (_) => _toggleGitPanel(),
      ),
      DuplicateLineIntent: CallbackAction<DuplicateLineIntent>(
        onInvoke: (_) => _duplicateLine(),
      ),
      ToggleCommentIntent: CallbackAction<ToggleCommentIntent>(
        onInvoke: (_) => _toggleComment(),
      ),
      ZoomInIntent: CallbackAction<ZoomInIntent>(
        onInvoke: (_) => _zoomIn(),
      ),
      ZoomOutIntent: CallbackAction<ZoomOutIntent>(
        onInvoke: (_) => _zoomOut(),
      ),
      ResetZoomIntent: CallbackAction<ResetZoomIntent>(
        onInvoke: (_) => _resetZoom(),
      ),
    };
  }

  // Action implementations
  void _saveFile() {
    try {
      notifier.saveCurrentFile();
    } catch (e) {
      debugPrint('Error saving file: $e');
    }
  }

  void _saveAllFiles() {
    try {
      notifier.saveCurrentFile();
    } catch (e) {
      debugPrint('Error saving all files: $e');
    }
  }

  void _createFile(BuildContext context) async {
    try {
      final fileName = await CreateFileDialog.show(
        context: context,
        initialPath: state.project?.path,
      );
      
      if (fileName != null && fileName.isNotEmpty) {
        notifier.createFileWithOptions(fileName: fileName);
      }
    } catch (e) {
      debugPrint('Error creating file: $e');
    }
  }

  void _closeTab() {
    try {
      if (state.currentFile != null) {
        notifier.closeFile(state.currentFile!);
      }
    } catch (e) {
      debugPrint('Error closing tab: $e');
    }
  }

  void _deleteFile(BuildContext context) async {
    try {
      if (state.currentFile == null) return;

      final confirmed = await ConfirmationDialog.show(
        context: context,
        title: 'Delete File',
        message:
            'Are you sure you want to delete "${state.currentFile!.name}"?',
        confirmText: 'Delete',
      );

      if (confirmed == true) {
        notifier.deleteFile(state.currentFile!);
      }
    } catch (e) {
      debugPrint('Error deleting file: $e');
    }
  }

  void _renameFile(BuildContext context) async {
    try {
      if (state.currentFile == null) return;

      final controller = TextEditingController(text: state.currentFile!.name);
      final newName = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Rename File'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'File name',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) => Navigator.of(context).pop(value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Rename'),
            ),
          ],
        ),
      );

      if (newName != null &&
          newName.isNotEmpty &&
          newName != state.currentFile!.name) {
        notifier.renameFile(state.currentFile!, newName);
      }
    } catch (e) {
      debugPrint('Error renaming file: $e');
    }
  }

  void _findInFile(BuildContext context) async {
    try {
      final query = await FindDialog.show(
        context: context,
        title: 'Find in File',
      );

      if (query != null && query.isNotEmpty) {
        notifier.setSearchQuery(query);
      }
    } catch (e) {
      debugPrint('Error in find dialog: $e');
    }
  }

  void _findInProject(BuildContext context) async {
    try {
      final query = await FindDialog.show(
        context: context,
        title: 'Find in Project',
      );

      if (query != null && query.isNotEmpty) {
        notifier.setGlobalSearchQuery(query);
      }
    } catch (e) {
      debugPrint('Error in find dialog: $e');
    }
  }

  void _replaceInFile(BuildContext context) async {
    try {
      final result = await ReplaceDialog.show(
        context: context,
      );

      if (result != null) {
        await notifier.replaceInCurrentFile(result.findText, result.replaceText);
      }
    } catch (e) {
      debugPrint('Error in replace dialog: $e');
    }
  }

  void _nextTab() {
    try {
      if (state.openFiles.isEmpty) return;

      final currentIndex = state.openFiles.indexOf(state.currentFile!);
      final nextIndex = (currentIndex + 1) % state.openFiles.length;
      notifier.switchToFile(state.openFiles[nextIndex]);
    } catch (e) {
      debugPrint('Error switching to next tab: $e');
    }
  }

  void _previousTab() {
    try {
      if (state.openFiles.isEmpty) return;

      final currentIndex = state.openFiles.indexOf(state.currentFile!);
      final previousIndex =
          (currentIndex - 1 + state.openFiles.length) % state.openFiles.length;
      notifier.switchToFile(state.openFiles[previousIndex]);
    } catch (e) {
      debugPrint('Error switching to previous tab: $e');
    }
  }

  void _goToLine(BuildContext context) async {
    try {
      final lineNumber = await GoToLineDialog.show(
        context: context,
        maxLineNumber: notifier.getCurrentLineCount(),
      );

      if (lineNumber != null) {
        notifier.goToLine(lineNumber);
      }
    } catch (e) {
      debugPrint('Error in go to line dialog: $e');
    }
  }

  void _toggleSidebar() {
    try {
      final newView = state.currentView == ProjectEditorView.fileTree
          ? ProjectEditorView.editor
          : ProjectEditorView.fileTree;
      notifier.setView(newView);
    } catch (e) {
      debugPrint('Error toggling sidebar: $e');
    }
  }

  void _togglePreview() {
    try {
      notifier.togglePreviewMode();
    } catch (e) {
      debugPrint('Error toggling preview: $e');
    }
  }

  void _toggleGitPanel() {
    try {
      final newView = state.currentView == ProjectEditorView.git
          ? ProjectEditorView.editor
          : ProjectEditorView.git;
      notifier.setView(newView);
    } catch (e) {
      debugPrint('Error toggling git panel: $e');
    }
  }

  void _duplicateLine() {
    try {
      notifier.duplicateCurrentLine();
    } catch (e) {
      debugPrint('Error duplicating line: $e');
    }
  }

  void _toggleComment() {
    try {
      notifier.toggleCommentOnCurrentLine();
    } catch (e) {
      debugPrint('Error toggling comment: $e');
    }
  }

  void _zoomIn() {
    try {
      notifier.increaseFontSize();
    } catch (e) {
      debugPrint('Error zooming in: $e');
    }
  }

  void _zoomOut() {
    try {
      notifier.decreaseFontSize();
    } catch (e) {
      debugPrint('Error zooming out: $e');
    }
  }

  void _resetZoom() {
    try {
      notifier.resetFontSize();
    } catch (e) {
      debugPrint('Error resetting zoom: $e');
    }
  }
}

// Intent classes
class SaveFileIntent extends Intent {
  const SaveFileIntent();
}

class SaveAllFilesIntent extends Intent {
  const SaveAllFilesIntent();
}

class CreateFileIntent extends Intent {
  const CreateFileIntent();
}

class CloseTabIntent extends Intent {
  const CloseTabIntent();
}

class DeleteFileIntent extends Intent {
  const DeleteFileIntent();
}

class RenameFileIntent extends Intent {
  const RenameFileIntent();
}

class FindInFileIntent extends Intent {
  const FindInFileIntent();
}

class FindInProjectIntent extends Intent {
  const FindInProjectIntent();
}

class ReplaceInFileIntent extends Intent {
  const ReplaceInFileIntent();
}

class NextTabIntent extends Intent {
  const NextTabIntent();
}

class PreviousTabIntent extends Intent {
  const PreviousTabIntent();
}

class GoToLineIntent extends Intent {
  const GoToLineIntent();
}

class ToggleSidebarIntent extends Intent {
  const ToggleSidebarIntent();
}

class TogglePreviewIntent extends Intent {
  const TogglePreviewIntent();
}

class ToggleGitPanelIntent extends Intent {
  const ToggleGitPanelIntent();
}

class DuplicateLineIntent extends Intent {
  const DuplicateLineIntent();
}

class ToggleCommentIntent extends Intent {
  const ToggleCommentIntent();
}

class ZoomInIntent extends Intent {
  const ZoomInIntent();
}

class ZoomOutIntent extends Intent {
  const ZoomOutIntent();
}

class ResetZoomIntent extends Intent {
  const ResetZoomIntent();
}
