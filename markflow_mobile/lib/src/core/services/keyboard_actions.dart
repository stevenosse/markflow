import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:markflow/src/core/routing/app_router.dart';
import 'keyboard_shortcuts_service.dart';
import 'package:markflow/src/features/projects/ui/widgets/project_action_dialog.dart';
import 'package:markflow/src/shared/components/dialogs/create_file_dialog.dart';
import 'package:markflow/src/shared/components/dialogs/create_folder_dialog.dart';
import 'package:markflow/src/features/projects/logic/project_editor/project_editor_notifier.dart';
import 'package:markflow/src/features/projects/ui/project_editor_screen.dart';
import 'package:markflow/src/shared/locator.dart';

/// Action handlers for keyboard shortcuts
class KeyboardActions {
  // Global actions available throughout the app
  static final Map<Type, Action<Intent>> globalActions = {
    CreateProjectIntent: _CreateProjectAction(),
    OpenSettingsIntent: _OpenSettingsAction(),
    GoBackIntent: _GoBackAction(),
    CloseTabIntent: CallbackAction<CloseTabIntent>(
      onInvoke: (intent) => _closeTab(),
    ),
    QuitAppIntent: CallbackAction<QuitAppIntent>(
      onInvoke: (intent) => _quitApp(),
    ),
    SaveFileIntent: CallbackAction<SaveFileIntent>(
      onInvoke: (intent) => _saveFile(),
    ),
    SaveAllFilesIntent: CallbackAction<SaveAllFilesIntent>(
      onInvoke: (intent) => _saveAllFiles(),
    ),
    FindInFileIntent: CallbackAction<FindInFileIntent>(
      onInvoke: (intent) => _findInFile(),
    ),
    FindInProjectIntent: CallbackAction<FindInProjectIntent>(
      onInvoke: (intent) => _findInProject(),
    ),
    ReplaceInFileIntent: CallbackAction<ReplaceInFileIntent>(
      onInvoke: (intent) => _replaceInFile(),
    ),
    ToggleSidebarIntent: CallbackAction<ToggleSidebarIntent>(
      onInvoke: (intent) => _toggleSidebar(),
    ),
    TogglePreviewIntent: CallbackAction<TogglePreviewIntent>(
      onInvoke: (intent) => _togglePreview(),
    ),
    ToggleGitPanelIntent: CallbackAction<ToggleGitPanelIntent>(
      onInvoke: (intent) => _toggleGitPanel(),
    ),
    QuickOpenIntent: CallbackAction<QuickOpenIntent>(
      onInvoke: (intent) => _quickOpen(),
    ),
    CommandPaletteIntent: CallbackAction<CommandPaletteIntent>(
      onInvoke: (intent) => _commandPalette(),
    ),
    ZoomInIntent: CallbackAction<ZoomInIntent>(
      onInvoke: (intent) => _zoomIn(),
    ),
    ZoomOutIntent: CallbackAction<ZoomOutIntent>(
      onInvoke: (intent) => _zoomOut(),
    ),
    ResetZoomIntent: CallbackAction<ResetZoomIntent>(
      onInvoke: (intent) => _resetZoom(),
    ),
  };

  /// Editor-specific action handlers
  static Map<Type, Action<Intent>> get editorActions => {
        NewFileIntent: _NewFileAction(),
        NewFolderIntent: _NewFolderAction(),
        DeleteFileIntent: CallbackAction<DeleteFileIntent>(
          onInvoke: (intent) => _deleteFile(),
        ),
        RenameFileIntent: CallbackAction<RenameFileIntent>(
          onInvoke: (intent) => _renameFile(),
        ),
        DuplicateLineIntent: CallbackAction<DuplicateLineIntent>(
          onInvoke: (intent) => _duplicateLine(),
        ),
        GoToLineIntent: CallbackAction<GoToLineIntent>(
          onInvoke: (intent) => _goToLine(),
        ),
        ToggleCommentIntent: CallbackAction<ToggleCommentIntent>(
          onInvoke: (intent) => _toggleComment(),
        ),
        NewTabIntent: _NewTabAction(),
        NextTabIntent: _NextTabAction(),
        PreviousTabIntent: _PreviousTabAction(),
        CloseTabIntent: _CloseTabAction(),
      };

  /// Projects screen specific action handlers
  static Map<Type, Action<Intent>> get projectsActions => {
        SearchProjectsIntent: CallbackAction<SearchProjectsIntent>(
          onInvoke: (intent) => _searchProjects(),
        ),
        OpenSelectedProjectIntent: CallbackAction<OpenSelectedProjectIntent>(
          onInvoke: (intent) => _openSelectedProject(),
        ),
        DeleteSelectedProjectIntent:
            CallbackAction<DeleteSelectedProjectIntent>(
          onInvoke: (intent) => _deleteSelectedProject(),
        ),
      };

  // Global action implementations - now handled by custom Action classes

  static void _closeTab() {
    try {
      final notifier = locator<ProjectEditorNotifier>();
      final currentFile = notifier.value.currentFile;

      if (currentFile != null) {
        notifier.closeFile(currentFile);
      } else {
        // Fallback to navigation pop if no file is open
        final context = _getCurrentContext();
        if (context != null && context.router.canPop()) {
          context.router.pop();
        }
      }
    } catch (e) {
      debugPrint('Error closing tab: $e');
      // Fallback to navigation pop
      final context = _getCurrentContext();
      if (context != null && context.router.canPop()) {
        context.router.pop();
      }
    }
  }

  static void _quitApp() {
    // On desktop, this would close the app
    // For now, we'll just show a debug message
    debugPrint('Quit app shortcut triggered');
  }

  static void _saveFile() {
    // This would trigger save in the current editor
    debugPrint('Save file shortcut triggered');
  }

  static void _saveAllFiles() {
    // This would trigger save all in the editor
    debugPrint('Save all files shortcut triggered');
  }

  static void _findInFile() {
    // This would open find dialog in current file
    debugPrint('Find in file shortcut triggered');
  }

  static void _findInProject() {
    // This would open project-wide search
    debugPrint('Find in project shortcut triggered');
  }

  static void _replaceInFile() {
    // This would open replace dialog
    debugPrint('Replace in file shortcut triggered');
  }

  static void _toggleSidebar() {
    // This would toggle the file tree sidebar
    debugPrint('Toggle sidebar shortcut triggered');
  }

  static void _togglePreview() {
    // This would toggle markdown preview
    debugPrint('Toggle preview shortcut triggered');
  }

  static void _toggleGitPanel() {
    // This would toggle git panel
    debugPrint('Toggle git panel shortcut triggered');
  }

  static void _quickOpen() {
    // This would open quick file picker
    debugPrint('Quick open shortcut triggered');
  }

  static void _commandPalette() {
    // This would open command palette
    debugPrint('Command palette shortcut triggered');
  }

  static void _zoomIn() {
    // This would increase editor font size
    debugPrint('Zoom in shortcut triggered');
  }

  static void _zoomOut() {
    // This would decrease editor font size
    debugPrint('Zoom out shortcut triggered');
  }

  static void _resetZoom() {
    // This would reset editor font size
    debugPrint('Reset zoom shortcut triggered');
  }

  // Editor action implementations



  static void _deleteFile() {
    debugPrint('Delete file shortcut triggered');
  }

  static void _renameFile() {
    debugPrint('Rename file shortcut triggered');
  }

  static void _duplicateLine() {
    debugPrint('Duplicate line shortcut triggered');
  }

  static void _goToLine() {
    debugPrint('Go to line shortcut triggered');
  }

  static void _toggleComment() {
    debugPrint('Toggle comment shortcut triggered');
  }

  // Projects action implementations
  static void _searchProjects() {
    debugPrint('Search projects shortcut triggered');
  }

  static void _openSelectedProject() {
    debugPrint('Open selected project shortcut triggered');
  }

  static void _deleteSelectedProject() {
    debugPrint('Delete selected project shortcut triggered');
  }

  // Helper method to get current context
  static BuildContext? _getCurrentContext() {
    // For now, return null - actions will need to be triggered from widgets with context
    // In a real implementation, you'd use a global navigator key or context provider
    return null;
  }
}

// Custom Action classes that can access context properly
class _CreateProjectAction extends Action<CreateProjectIntent> {
  @override
  Object? invoke(CreateProjectIntent intent) {
    final context = primaryFocus?.context;
    if (context != null) {
      showDialog(
        context: context,
        builder: (context) =>
            const ProjectActionDialog(hasExistingProjects: false),
      );
    }
    return null;
  }
}

class _OpenSettingsAction extends Action<OpenSettingsIntent> {
  @override
  Object? invoke(OpenSettingsIntent intent) {
    final context = primaryFocus?.context;
    if (context != null) {
      context.router.push(const SettingsRoute());
    }
    return null;
  }
}

class _GoBackAction extends Action<GoBackIntent> {
  @override
  Object? invoke(GoBackIntent intent) {
    final context = primaryFocus?.context;
    if (context != null && context.router.canPop()) {
      context.router.pop();
    }
    return null;
  }
}

class _NewFileAction extends Action<NewFileIntent> {
  @override
  Object? invoke(NewFileIntent intent) {
    final context = primaryFocus?.context;
    if (context != null) {
      try {
        // Find the ProjectEditorNotifier from the widget tree
        final notifier = context
            .findAncestorStateOfType<ProjectEditorScreenState>()
            ?.notifier;
        final projectPath = notifier?.value.project?.path;

        if (projectPath != null) {
          CreateFileDialog.show(context: context, initialPath: projectPath);
        }
      } catch (e) {
        debugPrint('Error showing create file dialog: $e');
      }
    }
    return null;
  }
}

class _NewFolderAction extends Action<NewFolderIntent> {
  @override
  Object? invoke(NewFolderIntent intent) {
    final context = primaryFocus?.context;
    if (context != null) {
      try {
        // Find the ProjectEditorNotifier from the widget tree
        final notifier = context
            .findAncestorStateOfType<ProjectEditorScreenState>()
            ?.notifier;
        final projectPath = notifier?.value.project?.path;

        if (projectPath != null) {
          CreateFolderDialog.show(context: context, initialPath: projectPath);
        }
      } catch (e) {
        debugPrint('Error showing create folder dialog: $e');
      }
    }
    return null;
  }
}

class _NewTabAction extends Action<NewTabIntent> {
  @override
  Object? invoke(NewTabIntent intent) {
    final context = primaryFocus?.context;
    if (context != null) {
      try {
        // Find the ProjectEditorNotifier from the widget tree
        final notifier = context
            .findAncestorStateOfType<ProjectEditorScreenState>()
            ?.notifier;
        final projectPath = notifier?.value.project?.path;

        if (projectPath != null) {
          CreateFileDialog.show(context: context, initialPath: projectPath);
        }
      } catch (e) {
        debugPrint('Error showing create file dialog: $e');
      }
    }
    return null;
  }
}

class _NextTabAction extends Action<NextTabIntent> {
  @override
  Object? invoke(NextTabIntent intent) {
    final context = primaryFocus?.context;
    if (context != null) {
      try {
        final notifier = context
            .findAncestorStateOfType<ProjectEditorScreenState>()
            ?.notifier;
        final state = notifier?.value;

        if (state != null && state.openFiles.isNotEmpty) {
          final currentIndex = state.openFiles.indexWhere(
            (file) => file.absolutePath == state.currentFile?.absolutePath,
          );

          if (currentIndex != -1) {
            final nextIndex = (currentIndex + 1) % state.openFiles.length;
            notifier?.switchToFile(state.openFiles[nextIndex]);
          }
        }
      } catch (e) {
        debugPrint('Error navigating to next tab: $e');
      }
    }
    return null;
  }
}

class _PreviousTabAction extends Action<PreviousTabIntent> {
  @override
  Object? invoke(PreviousTabIntent intent) {
    final context = primaryFocus?.context;
    if (context != null) {
      try {
        final notifier = context
            .findAncestorStateOfType<ProjectEditorScreenState>()
            ?.notifier;
        final state = notifier?.value;

        if (state != null && state.openFiles.isNotEmpty) {
          final currentIndex = state.openFiles.indexWhere(
            (file) => file.absolutePath == state.currentFile?.absolutePath,
          );

          if (currentIndex != -1) {
            final nextIndex = currentIndex == 0
                ? state.openFiles.length - 1
                : currentIndex - 1;
            notifier?.switchToFile(state.openFiles[nextIndex]);
          }
        }
      } catch (e) {
        debugPrint('Error navigating to previous tab: $e');
      }
    }
    return null;
  }
}

class _CloseTabAction extends Action<CloseTabIntent> {
  @override
  Object? invoke(CloseTabIntent intent) {
    final context = primaryFocus?.context;
    if (context != null) {
      try {
        final notifier = context
            .findAncestorStateOfType<ProjectEditorScreenState>()
            ?.notifier;
        final state = notifier?.value;

        if (state?.currentFile != null) {
          notifier?.closeFile(state!.currentFile!);
        } else {
          context.router.pop();
        }
      } catch (e) {
        debugPrint('Error closing tab: $e');
        context.router.pop();
      }
    }
    return null;
  }
}