import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markflow/src/core/theme/dimens.dart';
import 'package:markflow/src/datasource/models/markdown_file.dart';
import 'package:markflow/src/datasource/repositories/file_repository.dart';
import 'package:markflow/src/shared/components/dialogs/confirmation_dialog.dart';
import 'package:markflow/src/shared/components/dialogs/create_file_dialog.dart';
import 'package:markflow/src/shared/components/dialogs/create_folder_dialog.dart';
import 'package:markflow/src/shared/components/popovers/rename_popover.dart';
import 'package:markflow/src/shared/locator.dart';

class FileTreePanel extends StatefulWidget {
  final List<MarkdownFile> files;
  final MarkdownFile? selectedFile;
  final Function(MarkdownFile) onFileSelected;
  final Function(MarkdownFile, String) onFileRenamed;
  final Function(MarkdownFile) onFileDeleted;
  final Future<void> Function(String) onFileCreated;
  final Function(String) onFolderCreated;

  const FileTreePanel({
    super.key,
    required this.files,
    this.selectedFile,
    required this.onFileSelected,
    required this.onFileRenamed,
    required this.onFileDeleted,
    required this.onFileCreated,
    required this.onFolderCreated,
  });

  @override
  State<FileTreePanel> createState() => _FileTreePanelState();
}

class _FileTreePanelState extends State<FileTreePanel> {
  final Set<String> _expandedFolders = <String>{};
  final Set<String> _selectedFiles = <String>{};
  bool _isMultiSelectMode = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          _DesktopFileTreeHeader(
            onFileCreated: widget.onFileCreated,
            onFolderCreated: widget.onFolderCreated,
            isMultiSelectMode: _isMultiSelectMode,
            selectedFilesCount: _selectedFiles.length,
            onToggleMultiSelect: _toggleMultiSelectMode,
            onCopySelectedFiles: _copySelectedFiles,
            onClearSelection: _clearSelection,
          ),
          Expanded(
            child: widget.files.isEmpty
                ? _DesktopEmptyState()
                : _buildFileTreeStructure(),
          ),
        ],
      ),
    );
  }

  Widget _buildFileTreeStructure() {
    // Group files by directory structure
    final Map<String, dynamic> fileTree = {};
    
    for (final file in widget.files) {
      final pathParts = file.relativePath.split('/');
      Map<String, dynamic> currentLevel = fileTree;
      
      // Navigate through directory structure
      for (int i = 0; i < pathParts.length - 1; i++) {
        final part = pathParts[i];
        currentLevel[part] ??= <String, dynamic>{};
        currentLevel = currentLevel[part] as Map<String, dynamic>;
      }
      
      // Add the file at the final level
      final fileName = pathParts.last;
      currentLevel[fileName] = file;
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(Dimens.desktopFileTreePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildTreeNodes(context, fileTree, 0),
      ),
    );
  }

  List<Widget> _buildTreeNodes(BuildContext context, Map<String, dynamic> nodes, int depth) {
    final List<Widget> widgets = [];
    
    // Sort entries: folders first, then files
    final entries = nodes.entries.toList();
    entries.sort((a, b) {
      final aIsFile = a.value is MarkdownFile;
      final bIsFile = b.value is MarkdownFile;
      
      if (aIsFile && !bIsFile) return 1;
      if (!aIsFile && bIsFile) return -1;
      return a.key.compareTo(b.key);
    });
    
    for (final entry in entries) {
      final name = entry.key;
      final value = entry.value;
      
      if (value is MarkdownFile) {
        widgets.add(_buildFileNode(context, name, value, depth));
      } else if (value is Map<String, dynamic>) {
        widgets.add(_buildFolderNode(context, name, value, depth));
      }
    }
    
    return widgets;
  }

  Widget _buildFileNode(BuildContext context, String name, MarkdownFile file, int depth) {
    final isSelected = widget.selectedFile?.id == file.id;
    final isMultiSelected = _selectedFiles.contains(file.id);

    return Container(
      margin: EdgeInsets.only(
        left: depth * Dimens.desktopFileTreeIndent,
        bottom: 2,
      ),
      height: Dimens.desktopFileTreeItemHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimens.desktopRadius),
        color: isSelected
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)
            : isMultiSelected
                ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.08)
                : null,
        border: isSelected
            ? Border.all(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                width: 1,
              )
            : isMultiSelected
                ? Border.all(
                    color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3),
                    width: 1,
                  )
                : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleFileTap(file),
          onLongPress: () => _handleFileLongPress(file),
          borderRadius: BorderRadius.circular(Dimens.desktopRadius),
          hoverColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.04),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimens.desktopSpacing / 2,
              vertical: 4,
            ),
            child: Row(
              children: [
                if (_isMultiSelectMode)
                  Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.only(right: 4),
                    child: Checkbox(
                      value: isMultiSelected,
                      onChanged: (value) => _toggleFileSelection(file.id),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                        : isMultiSelected
                            ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1)
                            : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    _getFileIcon(file.name),
                    size: Dimens.desktopFileTreeIconSize,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : isMultiSelected
                            ? Theme.of(context).colorScheme.secondary
                            : _getFileIconColor(context, file.name),
                  ),
                ),
                const SizedBox(width: Dimens.desktopSpacing / 2),
                Expanded(
                  child: Text(
                    name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : isMultiSelected
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(context).colorScheme.onSurface,
                          fontWeight: (isSelected || isMultiSelected) ? FontWeight.w500 : FontWeight.w400,
                          fontSize: 13,
                          letterSpacing: 0.1,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (file.hasUnsavedChanges)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                if (!_isMultiSelectMode)
                  _DesktopFileOptionsButton(
                    file: file,
                    onFileRenamed: (file, newName) => widget.onFileRenamed(file, newName),
                    onDelete: () => _showDeleteFileDialog(context, file),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFolderNode(BuildContext context, String name,
      Map<String, dynamic> children, int depth) {
    final folderPath = name;
    final isExpanded = _expandedFolders.contains(folderPath);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(
            left: depth * Dimens.desktopFileTreeIndent,
            bottom: 2,
          ),
          height: Dimens.desktopFileTreeItemHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimens.desktopRadius),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  if (isExpanded) {
                    _expandedFolders.remove(folderPath);
                  } else {
                    _expandedFolders.add(folderPath);
                  }
                });
              },
              borderRadius: BorderRadius.circular(Dimens.desktopRadius),
              hoverColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimens.desktopSpacing / 2,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        isExpanded ? Icons.folder_open : Icons.folder,
                        size: Dimens.desktopFileTreeIconSize,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Icon(
                        isExpanded ? Icons.expand_less : Icons.chevron_right,
                        size: 12,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    const SizedBox(width: Dimens.desktopSpacing / 2),
                    Expanded(
                      child: Text(
                        name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              letterSpacing: 0.1,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (isExpanded) ...(_buildTreeNodes(context, children, depth + 1)),
      ],
    );
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();

    switch (extension) {
      case 'md':
      case 'markdown':
        return Icons.description;
      case 'txt':
        return Icons.text_snippet;
      case 'json':
        return Icons.data_object;
      case 'yaml':
      case 'yml':
        return Icons.settings;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileIconColor(BuildContext context, String fileName) {
    final extension = fileName.split('.').last.toLowerCase();

    switch (extension) {
      case 'md':
      case 'markdown':
        return Theme.of(context).colorScheme.primary.withValues(alpha: 0.8);
      case 'txt':
        return Theme.of(context).colorScheme.secondary.withValues(alpha: 0.8);
      case 'json':
        return Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.8);
      case 'yaml':
      case 'yml':
        return Theme.of(context).colorScheme.outline;
      default:
        return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    }
  }

  void _handleFileTap(MarkdownFile file) {
    if (_isMultiSelectMode) {
      _toggleFileSelection(file.id);
    } else {
      widget.onFileSelected(file);
    }
  }

  void _handleFileLongPress(MarkdownFile file) {
    if (!_isMultiSelectMode) {
      setState(() {
        _isMultiSelectMode = true;
        _selectedFiles.add(file.id);
      });
    }
  }

  void _toggleFileSelection(String fileId) {
    setState(() {
      if (_selectedFiles.contains(fileId)) {
        _selectedFiles.remove(fileId);
      } else {
        _selectedFiles.add(fileId);
      }
    });
  }

  void _toggleMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = !_isMultiSelectMode;
      if (!_isMultiSelectMode) {
        _selectedFiles.clear();
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedFiles.clear();
      _isMultiSelectMode = false;
    });
  }

  void _copySelectedFiles() async {
    if (_selectedFiles.isEmpty) return;

    final selectedFilesList = widget.files
        .where((file) => _selectedFiles.contains(file.id))
        .toList();

    final StringBuffer buffer = StringBuffer();
    
    // Import the file repository to load content
    final fileRepository = locator<FileRepository>();
    
    for (int i = 0; i < selectedFilesList.length; i++) {
      final file = selectedFilesList[i];
      buffer.writeln('=== ${file.name} ===');
      
      try {
        // Load the file content if not already loaded
        String? content = file.content;
        if (content == null || content.isEmpty) {
          final loadedFile = await fileRepository.getFile(file.absolutePath);
          content = loadedFile?.content;
        }
        
        if (content != null && content.isNotEmpty) {
          buffer.writeln(content);
        } else {
          buffer.writeln('[File content could not be loaded]');
        }
      } catch (e) {
        buffer.writeln('[Error loading file: $e]');
      }
      
      if (i < selectedFilesList.length - 1) {
        buffer.writeln('\n');
      }
    }

    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Copied ${selectedFilesList.length} file(s) to clipboard'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
    
    _clearSelection();
  }

  void _showDeleteFileDialog(BuildContext context, MarkdownFile file) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Delete File',
      message: 'Are you sure you want to delete "${file.name}"?',
      confirmText: 'Delete',
      confirmButtonColor: Theme.of(context).colorScheme.error,
    );
    
    if (confirmed) {
      widget.onFileDeleted(file);
    }
  }
}

class _DesktopFileTreeHeader extends StatelessWidget {
  final Future<void> Function(String) onFileCreated;
  final Function(String) onFolderCreated;
  final bool isMultiSelectMode;
  final int selectedFilesCount;
  final VoidCallback onToggleMultiSelect;
  final VoidCallback onCopySelectedFiles;
  final VoidCallback onClearSelection;

  const _DesktopFileTreeHeader({
    required this.onFileCreated,
    required this.onFolderCreated,
    required this.isMultiSelectMode,
    required this.selectedFilesCount,
    required this.onToggleMultiSelect,
    required this.onCopySelectedFiles,
    required this.onClearSelection,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Dimens.desktopFileTreeHeaderHeight,
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.desktopFileTreePadding,
        vertical: Dimens.desktopSpacing / 2,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.folder_outlined,
              size: Dimens.desktopFileTreeIconSize,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: Dimens.desktopSpacing / 2),
          Expanded(
            child: Text(
              isMultiSelectMode ? '$selectedFilesCount selected' : 'Files',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 14,
                    letterSpacing: 0.1,
                  ),
            ),
          ),
          if (isMultiSelectMode) ...[
            if (selectedFilesCount > 0)
              IconButton(
                onPressed: onCopySelectedFiles,
                icon: const Icon(Icons.copy),
                tooltip: 'Copy selected files content',
                iconSize: Dimens.desktopFileTreeIconSize,
              ),
            IconButton(
              onPressed: onClearSelection,
              icon: const Icon(Icons.close),
              tooltip: 'Exit multi-select mode',
              iconSize: Dimens.desktopFileTreeIconSize,
            ),
          ] else ...[
            IconButton(
              onPressed: onToggleMultiSelect,
              icon: const Icon(Icons.checklist),
              tooltip: 'Multi-select mode',
              iconSize: Dimens.desktopFileTreeIconSize,
            ),
            _DesktopAddButton(
              onFileCreated: onFileCreated,
              onFolderCreated: onFolderCreated,
            ),
          ],
        ],
      ),
    );
  }
}

class _DesktopAddButton extends StatelessWidget {
  final Future<void> Function(String) onFileCreated;
  final Function(String) onFolderCreated;

  const _DesktopAddButton({
    required this.onFileCreated,
    required this.onFolderCreated,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
      ),
      child: PopupMenuButton<String>(
        icon: Icon(
          Icons.add,
          size: Dimens.desktopFileTreeIconSize,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        tooltip: 'Add new file or folder',
        padding: EdgeInsets.zero,
        onSelected: (value) {
          switch (value) {
            case 'new_file':
              _showCreateFileDialog(context);
              break;
            case 'new_folder':
              _showCreateFolderDialog(context);
              break;
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'new_file',
            child: Row(
              children: [
                Icon(
                  Icons.insert_drive_file_outlined,
                  size: Dimens.desktopFileTreeIconSize,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: Dimens.desktopSpacing / 2),
                const Text('New File'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'new_folder',
            child: Row(
              children: [
                Icon(
                  Icons.create_new_folder_outlined,
                  size: Dimens.desktopFileTreeIconSize,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: Dimens.desktopSpacing / 2),
                const Text('New Folder'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateFileDialog(BuildContext context) async {
    final fileName = await CreateFileDialog.show(
      context: context,
    );
    
    if (fileName != null && fileName.isNotEmpty) {
      onFileCreated(fileName);
    }
  }

  void _showCreateFolderDialog(BuildContext context) async {
    final folderName = await CreateFolderDialog.show(
      context: context,
    );
    
    if (folderName != null && folderName.isNotEmpty) {
      onFolderCreated(folderName);
    }
  }
}

class _DesktopEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Dimens.desktopSpacing),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(Dimens.desktopCardRadius),
              ),
              child: Icon(
                Icons.folder_open_outlined,
                size: 32,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: Dimens.desktopSpacing),
            Text(
              'No files yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: Dimens.desktopSpacing / 2),
            Text(
              'Create your first file to get started',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopFileOptionsButton extends StatelessWidget {
  final MarkdownFile file;
  final Function(MarkdownFile, String) onFileRenamed;
  final VoidCallback onDelete;

  const _DesktopFileOptionsButton({
    required this.file,
    required this.onFileRenamed,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Rename button with popover
        RenamePopover(
          initialValue: file.name,
          title: 'Rename File',
          hintText: 'Enter new file name',
          onRename: (newName) => onFileRenamed(file, newName),
          onCancel: () {},
          child: SizedBox(
            width: 20,
            height: 20,
            child: Icon(
              Icons.edit_outlined,
              size: 12,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
            ),
          ),
        ),
        const SizedBox(width: 4),
        // Delete button with popup menu
        SizedBox(
          width: 20,
          height: 20,
          child: PopupMenuButton<String>(
            icon: Icon(
              Icons.more_horiz,
              size: 12,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            tooltip: 'More options',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onSelected: (value) {
              if (value == 'delete') {
                onDelete();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: Dimens.desktopFileTreeIconSize,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: Dimens.desktopSpacing / 2),
                    const Text('Delete'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
