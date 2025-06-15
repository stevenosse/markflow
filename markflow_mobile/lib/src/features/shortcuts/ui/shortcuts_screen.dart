import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:markflow/src/core/theme/dimens.dart';
import 'package:markflow/src/shared/extensions/context_extensions.dart';

@RoutePage()
class ShortcutsScreen extends StatefulWidget {
  const ShortcutsScreen({super.key});

  @override
  State<ShortcutsScreen> createState() => _ShortcutsScreenState();
}

class _ShortcutsScreenState extends State<ShortcutsScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  List<ShortcutCategory> _filteredCategories = [];

  final List<ShortcutCategory> _categories = [
    ShortcutCategory(
      title: 'Global Shortcuts',
      description: 'Available throughout the application',
      shortcuts: [
        KeyboardShortcut(
          keys: ['Cmd+N', 'Ctrl+N'],
          description: 'Create new project',
          context: 'Global',
        ),
        KeyboardShortcut(
          keys: ['Cmd+,', 'Ctrl+,'],
          description: 'Open settings',
          context: 'Global',
        ),
        KeyboardShortcut(
          keys: ['Cmd+W', 'Escape'],
          description: 'Go back',
          context: 'Global',
        ),
      ],
    ),
    ShortcutCategory(
      title: 'Editor Shortcuts',
      description: 'Available in the project editor',
      shortcuts: [
        KeyboardShortcut(
          keys: ['Cmd+S', 'Ctrl+S'],
          description: 'Save file',
          context: 'Editor',
        ),
        KeyboardShortcut(
          keys: ['Cmd+Shift+S', 'Ctrl+Shift+S'],
          description: 'Save all files',
          context: 'Editor',
        ),
        KeyboardShortcut(
          keys: ['Cmd+F', 'Ctrl+F'],
          description: 'Find in file',
          context: 'Editor',
        ),
        KeyboardShortcut(
          keys: ['Cmd+T', 'Ctrl+T'],
          description: 'New file',
          context: 'Editor',
        ),
        KeyboardShortcut(
          keys: ['Cmd+Shift+T', 'Ctrl+Shift+T'],
          description: 'Toggle sidebar',
          context: 'Editor',
        ),
        KeyboardShortcut(
          keys: ['Cmd+Shift+F', 'Ctrl+Shift+F'],
          description: 'Search projects',
          context: 'Editor',
        ),
        KeyboardShortcut(
          keys: ['Cmd+Option+Right', 'Ctrl+Tab'],
          description: 'Next tab',
          context: 'Editor',
        ),
      ],
    ),
    ShortcutCategory(
      title: 'Projects Screen Shortcuts',
      description: 'Available on the projects screen',
      shortcuts: [
        KeyboardShortcut(
          keys: ['Cmd+N', 'Ctrl+N'],
          description: 'Create new project',
          context: 'Projects',
        ),
        KeyboardShortcut(
          keys: ['Cmd+O', 'Ctrl+O'],
          description: 'Open project',
          context: 'Projects',
        ),
        KeyboardShortcut(
          keys: ['Cmd+Shift+F', 'Ctrl+Shift+F'],
          description: 'Search projects',
          context: 'Projects',
        ),
      ],
    ),
  ];

  void _updateFilteredCategories() {
    if (_searchQuery.isEmpty) {
      _filteredCategories = _categories;
      return;
    }
    
    _filteredCategories = _categories.map((category) {
      final filteredShortcuts = category.shortcuts.where((shortcut) {
        return shortcut.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               shortcut.keys.any((key) => key.toLowerCase().contains(_searchQuery.toLowerCase()));
      }).toList();
      
      return ShortcutCategory(
        title: category.title,
        description: category.description,
        shortcuts: filteredShortcuts,
      );
    }).where((category) => category.shortcuts.isNotEmpty).toList();
  }

  @override
  void initState() {
    super.initState();
    _filteredCategories = _categories;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keyboard Shortcuts'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.router.pop(),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(Dimens.desktopSpacing),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _updateFilteredCategories();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search shortcuts...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                            _updateFilteredCategories();
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimens.desktopRadius),
                ),
              ),
            ),
          ),
          // Shortcuts list
          Expanded(
            child: _filteredCategories.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: context.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: Dimens.desktopSpacing),
                        Text(
                          'No shortcuts found',
                          style: context.textTheme.titleMedium?.copyWith(
                            color: context.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: Dimens.desktopSpacing / 2),
                        Text(
                          'Try a different search term',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimens.desktopSpacing,
                      vertical: Dimens.desktopSpacing / 2,
                    ),
                    itemCount: _filteredCategories.length,
                    itemBuilder: (context, index) {
                      final category = _filteredCategories[index];
                      return _CategoryCard(category: category);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final ShortcutCategory category;

  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: Dimens.desktopSpacing),
      child: Padding(
        padding: const EdgeInsets.all(Dimens.desktopSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category header
            Row(
              children: [
                Icon(
                  _getCategoryIcon(category.title),
                  color: context.colorScheme.primary,
                ),
                const SizedBox(width: Dimens.desktopSpacing / 2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.title,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        category.description,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimens.desktopSpacing),
            // Shortcuts list
            ...category.shortcuts.map((shortcut) => _ShortcutItem(shortcut: shortcut)),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String title) {
    switch (title) {
      case 'Global Shortcuts':
        return Icons.public;
      case 'Editor Shortcuts':
        return Icons.edit;
      case 'Projects Screen Shortcuts':
        return Icons.folder;
      default:
        return Icons.keyboard;
    }
  }
}

class _ShortcutItem extends StatelessWidget {
  final KeyboardShortcut shortcut;

  const _ShortcutItem({required this.shortcut});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimens.desktopSpacing / 4),
      child: Row(
        children: [
          // Key combinations
          Expanded(
            flex: 2,
            child: Wrap(
              spacing: Dimens.desktopSpacing / 4,
              runSpacing: Dimens.desktopSpacing / 4,
              children: shortcut.keys.map((key) => _KeyChip(keyText: key)).toList(),
            ),
          ),
          const SizedBox(width: Dimens.desktopSpacing),
          // Description
          Expanded(
            flex: 3,
            child: Text(
              shortcut.description,
              style: context.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _KeyChip extends StatelessWidget {
  final String keyText;

  const _KeyChip({required this.keyText});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimens.desktopSpacing / 2,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: context.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        keyText,
        style: context.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w500,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}

// Data models
class ShortcutCategory {
  final String title;
  final String description;
  final List<KeyboardShortcut> shortcuts;

  ShortcutCategory({
    required this.title,
    required this.description,
    required this.shortcuts,
  });
}

class KeyboardShortcut {
  final List<String> keys;
  final String description;
  final String context;

  KeyboardShortcut({
    required this.keys,
    required this.description,
    required this.context,
  });
}