import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Service for managing keyboard shortcuts throughout the app
class KeyboardShortcutsService {
  static KeyboardShortcutsService? _instance;
  static KeyboardShortcutsService get instance => _instance ??= KeyboardShortcutsService._();
  
  KeyboardShortcutsService._();

  /// Global shortcuts that work across the entire app
  Map<ShortcutActivator, Intent> get globalShortcuts => {
    // Navigation shortcuts
    const SingleActivator(LogicalKeyboardKey.keyN, meta: true): const CreateProjectIntent(),
    const SingleActivator(LogicalKeyboardKey.comma, meta: true): const OpenSettingsIntent(),
    const SingleActivator(LogicalKeyboardKey.keyW, meta: true): const GoBackIntent(),
    const SingleActivator(LogicalKeyboardKey.escape): const GoBackIntent(),
    
    // File operations
    const SingleActivator(LogicalKeyboardKey.keyS, meta: true): const SaveFileIntent(),
    const SingleActivator(LogicalKeyboardKey.keyS, meta: true, shift: true): const SaveAllFilesIntent(),
    
    // Editor shortcuts
    const SingleActivator(LogicalKeyboardKey.keyF, meta: true): const FindInFileIntent(),
    const SingleActivator(LogicalKeyboardKey.keyF, meta: true, shift: true): const FindInProjectIntent(),
    const SingleActivator(LogicalKeyboardKey.keyR, meta: true): const ReplaceInFileIntent(),
    
    // View shortcuts
    const SingleActivator(LogicalKeyboardKey.keyB, meta: true): const ToggleSidebarIntent(),
    const SingleActivator(LogicalKeyboardKey.keyP, meta: true, shift: true): const TogglePreviewIntent(),
    const SingleActivator(LogicalKeyboardKey.keyG, meta: true, shift: true): const ToggleGitPanelIntent(),
    
    // Quick actions
    const SingleActivator(LogicalKeyboardKey.keyP, meta: true): const QuickOpenIntent(),
    const SingleActivator(LogicalKeyboardKey.keyK, meta: true): const CommandPaletteIntent(),
    
    // Zoom
    const SingleActivator(LogicalKeyboardKey.equal, meta: true): const ZoomInIntent(),
    const SingleActivator(LogicalKeyboardKey.minus, meta: true): const ZoomOutIntent(),
    const SingleActivator(LogicalKeyboardKey.digit0, meta: true): const ResetZoomIntent(),
  };

  /// Project editor specific shortcuts
  Map<ShortcutActivator, Intent> get editorShortcuts => {
    // File tree operations
    const SingleActivator(LogicalKeyboardKey.keyN, meta: true, alt: true): const NewFileIntent(),
    const SingleActivator(LogicalKeyboardKey.keyN, meta: true, shift: true, alt: true): const NewFolderIntent(),
    const SingleActivator(LogicalKeyboardKey.delete): const DeleteFileIntent(),
    const SingleActivator(LogicalKeyboardKey.f2): const RenameFileIntent(),
    
    // Editor operations
    const SingleActivator(LogicalKeyboardKey.keyD, meta: true): const DuplicateLineIntent(),
    const SingleActivator(LogicalKeyboardKey.keyL, meta: true): const GoToLineIntent(),
    const SingleActivator(LogicalKeyboardKey.slash, meta: true): const ToggleCommentIntent(),
    
    // Tab management
    const SingleActivator(LogicalKeyboardKey.keyT, meta: true): const NewTabIntent(),
    const SingleActivator(LogicalKeyboardKey.keyW, meta: true): const CloseTabIntent(),
    const SingleActivator(LogicalKeyboardKey.tab, meta: true): const NextTabIntent(),
    const SingleActivator(LogicalKeyboardKey.tab, meta: true, shift: true): const PreviousTabIntent(),
  };

  /// Projects screen specific shortcuts
  Map<ShortcutActivator, Intent> get projectsShortcuts => {
    const SingleActivator(LogicalKeyboardKey.keyN, meta: true): const CreateNewProjectIntent(),
    const SingleActivator(LogicalKeyboardKey.keyO, meta: true): const OpenProjectIntent(),
    const SingleActivator(LogicalKeyboardKey.keyF, meta: true): const SearchProjectsIntent(),
    const SingleActivator(LogicalKeyboardKey.enter): const OpenSelectedProjectIntent(),
    const SingleActivator(LogicalKeyboardKey.delete): const DeleteSelectedProjectIntent(),
  };
}

// Intent classes for different actions
class CreateNewProjectIntent extends Intent {
  const CreateNewProjectIntent();
}

class OpenProjectIntent extends Intent {
  const OpenProjectIntent();
}

class OpenSettingsIntent extends Intent {
  const OpenSettingsIntent();
}

class CloseTabIntent extends Intent {
  const CloseTabIntent();
}

class QuitAppIntent extends Intent {
  const QuitAppIntent();
}

class SaveFileIntent extends Intent {
  const SaveFileIntent();
}

class SaveAllFilesIntent extends Intent {
  const SaveAllFilesIntent();
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

class ToggleSidebarIntent extends Intent {
  const ToggleSidebarIntent();
}

class TogglePreviewIntent extends Intent {
  const TogglePreviewIntent();
}

class ToggleGitPanelIntent extends Intent {
  const ToggleGitPanelIntent();
}

class QuickOpenIntent extends Intent {
  const QuickOpenIntent();
}

class CommandPaletteIntent extends Intent {
  const CommandPaletteIntent();
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

class NewFileIntent extends Intent {
  const NewFileIntent();
}

class NewFolderIntent extends Intent {
  const NewFolderIntent();
}

class DeleteFileIntent extends Intent {
  const DeleteFileIntent();
}

class RenameFileIntent extends Intent {
  const RenameFileIntent();
}

class DuplicateLineIntent extends Intent {
  const DuplicateLineIntent();
}

class GoToLineIntent extends Intent {
  const GoToLineIntent();
}

class ToggleCommentIntent extends Intent {
  const ToggleCommentIntent();
}

class NewTabIntent extends Intent {
  const NewTabIntent();
}

class NextTabIntent extends Intent {
  const NextTabIntent();
}

class PreviousTabIntent extends Intent {
  const PreviousTabIntent();
}

class SearchProjectsIntent extends Intent {
  const SearchProjectsIntent();
}

class OpenSelectedProjectIntent extends Intent {
  const OpenSelectedProjectIntent();
}

class DeleteSelectedProjectIntent extends Intent {
  const DeleteSelectedProjectIntent();
}

class CreateProjectIntent extends Intent {
  const CreateProjectIntent();
}

class GoBackIntent extends Intent {
  const GoBackIntent();
}