import 'package:flutter/material.dart';
import 'package:markflow/src/core/theme/dimens.dart';
import 'package:markflow/src/datasource/models/markdown_file.dart';

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
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: Dimens.borderWidth,
          ),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          const Divider(height: 1),
          Expanded(
            child: _buildFileTree(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimens.spacing,
        vertical: Dimens.spacing,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
            width: Dimens.borderWidth,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(Dimens.minSpacing),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Dimens.radiusS),
            ),
            child: Icon(
              Icons.folder_outlined,
              size: Dimens.iconSizeS,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: Dimens.halfSpacing),
          Expanded(
            child: Text(
              'Files',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimens.radiusS),
            ),
            child: PopupMenuButton<String>(
              icon: Icon(
                Icons.add,
                size: Dimens.iconSizeS,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
              ),
              tooltip: 'Add new file or folder',
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
                        size: Dimens.iconSizeS,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: Dimens.halfSpacing),
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
                        size: Dimens.iconSizeS,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(width: Dimens.halfSpacing),
                      const Text('New Folder'),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFileTree(BuildContext context) {
    if (widget.files.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(Dimens.spacing),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.folder_open,
                size: Dimens.iconSizeL,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.3),
              ),
              const SizedBox(height: Dimens.halfSpacing),
              Text(
                'No files',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                    ),
              ),
            ],
          ),
        ),
      );
    }

    final fileTree = _buildFileTreeStructure(widget.files);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: Dimens.halfSpacing),
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
        left: Dimens.halfSpacing + (depth * Dimens.fileTreeIndent),
        right: Dimens.halfSpacing,
        bottom: 2,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimens.radiusS),
        color: isSelected
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onFileSelected(file),
          borderRadius: BorderRadius.circular(Dimens.radiusS),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimens.halfSpacing,
              vertical: Dimens.halfSpacing,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(Dimens.radiusXS),
                  ),
                  child: Icon(
                    _getFileIcon(file.name),
                    size: Dimens.iconSizeS,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : _getFileIconColor(context, file.name),
                  ),
                ),
                const SizedBox(width: Dimens.halfSpacing),
                Expanded(
                  child: Text(
                    name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.w500 : FontWeight.w400,
                          fontSize: 14,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (file.hasUnsavedChanges)
                  Container(
                    margin: const EdgeInsets.only(right: Dimens.minSpacing),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .tertiary
                                .withValues(alpha: 0.3),
                            blurRadius: 2,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_horiz,
                    size: Dimens.iconSizeXS,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.4),
                  ),
                  tooltip: 'File options',
                  onSelected: (value) {
                    switch (value) {
                      case 'rename':
                        _showRenameFileDialog(context, file);
                        break;
                      case 'delete':
                        _showDeleteFileDialog(context, file);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'rename',
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: Dimens.iconSizeS,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: Dimens.halfSpacing),
                          const Text('Rename'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: Dimens.iconSizeS,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(width: Dimens.halfSpacing),
                          const Text('Delete'),
                        ],
                      ),
                    ),
                  ],
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
    final folderPath = name; // Simplified for this example
    final isExpanded = _expandedFolders.contains(folderPath);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(
            left: Dimens.halfSpacing + (depth * Dimens.fileTreeIndent),
            right: Dimens.halfSpacing,
            bottom: 2,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimens.radiusS),
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
              borderRadius: BorderRadius.circular(Dimens.radiusS),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimens.halfSpacing,
                  vertical: Dimens.halfSpacing,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(Dimens.radiusXS),
                      ),
                      child: Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_right,
                        size: Dimens.iconSizeS,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(Dimens.radiusXS),
                      ),
                      child: Icon(
                        isExpanded ? Icons.folder_open : Icons.folder,
                        size: Dimens.iconSizeS,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(width: Dimens.halfSpacing),
                    Expanded(
                      child: Text(
                        name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
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
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              widget.onFileCreated(value);
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
                widget.onFileCreated(fileName);
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
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              widget.onFolderCreated(value);
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
                widget.onFolderCreated(folderName);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showRenameFileDialog(BuildContext context, MarkdownFile file) {
    String newName = file.name;

    showDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: const Text('Rename File'),
        content: TextField(
          decoration: const InputDecoration(
            labelText: 'New name',
          ),
          controller: TextEditingController(text: newName),
          onChanged: (value) => newName = value,
          onSubmitted: (value) {
            if (value.isNotEmpty && value != file.name) {
              widget.onFileRenamed(file, value);
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
              if (newName.isNotEmpty && newName != file.name) {
                widget.onFileRenamed(file, newName);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showDeleteFileDialog(BuildContext context, MarkdownFile file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: const Text('Delete File'),
        content: Text('Are you sure you want to delete "${file.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              widget.onFileDeleted(file);
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
