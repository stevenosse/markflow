import 'package:flutter/material.dart';
import 'package:markflow/src/core/theme/dimens.dart';
import 'package:markflow/src/datasource/models/markdown_file.dart';
import 'package:markflow/src/shared/components/dialogs/confirmation_dialog.dart';
import 'package:markflow/src/shared/components/dialogs/create_file_dialog.dart';
import 'package:markflow/src/shared/components/dialogs/create_folder_dialog.dart';
import 'package:markflow/src/shared/components/popovers/rename_popover.dart';

class FileTreePanel extends StatefulWidget {
  final List<MarkdownFile> files;
  final MarkdownFile? selectedFile;
  final Function(MarkdownFile) onFileSelected;
  final Function(MarkdownFile) onFileDeleted;
  final Function(MarkdownFile, String) onFileRenamed;
  final Function(String) onFolderCreated;
  final Future<void> Function(String) onFileCreated;

  const FileTreePanel({
    super.key,
    required this.files,
    required this.selectedFile,
    required this.onFileSelected,
    required this.onFileDeleted,
    required this.onFileRenamed,
    required this.onFolderCreated,
    required this.onFileCreated,
  });

  @override
  State<FileTreePanel> createState() => _FileTreePanelState();
}

class _FileTreePanelState extends State<FileTreePanel> {
  final Set<String> _expandedFolders = {};

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _DesktopFileTreeHeader(
            onFileCreated: widget.onFileCreated,
            onFolderCreated: widget.onFolderCreated,
          ),
          Expanded(
            child: _buildFileTree(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFileTree(BuildContext context) {
    if (widget.files.isEmpty) {
      return _DesktopEmptyState();
    }

    final fileTree = _buildFileTreeStructure(widget.files);

    return ListView(
      padding: EdgeInsets.symmetric(
        vertical: Dimens.desktopSpacing / 2,
        horizontal: Dimens.desktopFileTreePadding,
      ),
      children: _buildTreeNodes(context, fileTree, 0),
    );
  }

  Map<String, dynamic> _buildFileTreeStructure(List<MarkdownFile> files) {
    final tree = <String, dynamic>{};

    for (final file in files) {
      final parts = file.relativePath.split('/');
      Map<String, dynamic> current = tree;

      for (int i = 0; i < parts.length; i++) {
        final part = parts[i];

        if (i == parts.length - 1) {
          // This is a file
          current[part] = file;
        } else {
          // This is a folder
          current[part] ??= <String, dynamic>{};
          current = current[part] as Map<String, dynamic>;
        }
      }
    }

    return tree;
  }

  List<Widget> _buildTreeNodes(
      BuildContext context, Map<String, dynamic> tree, int depth) {
    final nodes = <Widget>[];
    final sortedKeys = tree.keys.toList()
      ..sort((a, b) {
        final aIsFile = tree[a] is MarkdownFile;
        final bIsFile = tree[b] is MarkdownFile;

        if (aIsFile && !bIsFile) return 1;
        if (!aIsFile && bIsFile) return -1;

        return a.compareTo(b);
      });

    for (final key in sortedKeys) {
      final value = tree[key];

      if (value is MarkdownFile) {
        nodes.add(_buildFileNode(context, key, value, depth));
      } else if (value is Map<String, dynamic>) {
        nodes.add(_buildFolderNode(context, key, value, depth));
      }
    }

    return nodes;
  }

  Widget _buildFileNode(
      BuildContext context, String name, MarkdownFile file, int depth) {
    final isSelected = widget.selectedFile?.id == file.id;

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
            : null,
        border: isSelected
            ? Border.all(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                width: 1,
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onFileSelected(file),
          borderRadius: BorderRadius.circular(Dimens.desktopRadius),
          hoverColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.04),
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
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                        : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    _getFileIcon(file.name),
                    size: Dimens.desktopFileTreeIconSize,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
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
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
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

  const _DesktopFileTreeHeader({
    required this.onFileCreated,
    required this.onFolderCreated,
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
              'Files',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 14,
                    letterSpacing: 0.1,
                  ),
            ),
          ),
          _DesktopAddButton(
            onFileCreated: onFileCreated,
            onFolderCreated: onFolderCreated,
          ),
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
