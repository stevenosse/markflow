import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:markflow/src/core/theme/dimens.dart';

enum ProjectActionType {
  create,
  import,
  clone,
}

class ProjectActionDialog extends StatefulWidget {
  final ProjectActionType initialAction;
  final bool hasExistingProjects;

  const ProjectActionDialog({
    super.key,
    this.initialAction = ProjectActionType.create,
    this.hasExistingProjects = false,
  });

  @override
  State<ProjectActionDialog> createState() => _ProjectActionDialogState();

  static Future<ProjectActionResult?> show(
    BuildContext context, {
    ProjectActionType initialAction = ProjectActionType.create,
    bool hasExistingProjects = false,
  }) {
    return showDialog<ProjectActionResult>(
      context: context,
      useRootNavigator: true,
      builder: (context) => ProjectActionDialog(
        initialAction: initialAction,
        hasExistingProjects: hasExistingProjects,
      ),
    );
  }
}

class _ProjectActionDialogState extends State<ProjectActionDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ProjectActionType _currentAction;

  // Create project fields
  final _createFormKey = GlobalKey<FormState>();
  final _createNameController = TextEditingController();

  // Import project fields
  final _importFormKey = GlobalKey<FormState>();
  final _importPathController = TextEditingController();
  final _importNameController = TextEditingController();

  // Clone repository fields
  final _cloneFormKey = GlobalKey<FormState>();
  final _cloneUrlController = TextEditingController();
  final _cloneNameController = TextEditingController();
  final _clonePathController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentAction = widget.initialAction;
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: _currentAction.index,
    );

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentAction = ProjectActionType.values[_tabController.index];
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _createNameController.dispose();
    _importPathController.dispose();
    _importNameController.dispose();
    _cloneUrlController.dispose();
    _cloneNameController.dispose();
    _clonePathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimens.modalRadius),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: Dimens.modalMaxWidth * 1.2,
          maxHeight: Dimens.modalMaxWidth,
        ),
        child: Padding(
          padding: const EdgeInsets.all(Dimens.modalPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: Dimens.spacing),
              _buildTabs(),
              const SizedBox(height: Dimens.spacing),
              Expanded(
                child: widget.hasExistingProjects
                    ? _buildActionContent(_currentAction)
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildCreateContent(),
                          _buildImportContent(),
                          _buildCloneContent(),
                        ],
                      ),
              ),
              const SizedBox(height: Dimens.spacing),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    String title;
    switch (_currentAction) {
      case ProjectActionType.create:
        title = 'Create New project';
        break;
      case ProjectActionType.import:
        title = 'Import existing project';
        break;
      case ProjectActionType.clone:
        title = 'Clone git repository';
        break;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Close',
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return TabBar(
      controller: _tabController,
      tabs: const [
        Tab(text: 'Create'),
        Tab(text: 'Import'),
        Tab(text: 'Clone'),
      ],
      labelColor: Theme.of(context).colorScheme.primary,
      unselectedLabelColor:
          Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
      indicatorColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildActionContent(ProjectActionType action) {
    switch (action) {
      case ProjectActionType.create:
        return _buildCreateContent();
      case ProjectActionType.import:
        return _buildImportContent();
      case ProjectActionType.clone:
        return _buildCloneContent();
    }
  }

  Widget _buildCreateContent() {
    return Form(
      key: _createFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create a new MarkFlow project with Git initialization.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
          ),
          const SizedBox(height: Dimens.spacing),
          TextFormField(
            controller: _createNameController,
            decoration: const InputDecoration(
              labelText: 'Project Name',
              hintText: 'my-awesome-project',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a project name';
              }
              return null;
            },
          ),
          const SizedBox(height: Dimens.spacing),
          Text(
            'Your project will be created in the configured projects directory.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
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

  Widget _buildImportContent() {
    return Form(
      key: _importFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Import an existing project from your file system.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
          ),
          const SizedBox(height: Dimens.spacing),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _importPathController,
                  decoration: const InputDecoration(
                    labelText: 'Project Path',
                    hintText: '/path/to/existing/project',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a project directory';
                    }
                    return null;
                  },
                  readOnly: true,
                ),
              ),
              const SizedBox(width: Dimens.spacing),
              ElevatedButton(
                onPressed: _selectImportDirectory,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(Dimens.buttonHeight, Dimens.inputHeight),
                ),
                child: const Text('Browse'),
              ),
            ],
          ),
          const SizedBox(height: Dimens.spacing),
          TextFormField(
            controller: _importNameController,
            decoration: const InputDecoration(
              labelText: 'Project Name (Optional)',
              hintText: 'Leave empty to use folder name',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloneContent() {
    return Form(
      key: _cloneFormKey,
      child: ListView(
        children: [
          Text(
            'Clone a Git repository to create a new project.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
          ),
          const SizedBox(height: Dimens.spacing),
          TextFormField(
            controller: _cloneUrlController,
            decoration: const InputDecoration(
              labelText: 'Repository URL',
              hintText: 'https://github.com/username/repo.git',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a repository URL';
              }
              // Simple URL validation
              if (!value.startsWith('http') && !value.startsWith('git@')) {
                return 'Please enter a valid repository URL';
              }
              return null;
            },
          ),
          const SizedBox(height: Dimens.spacing),
          TextFormField(
            controller: _cloneNameController,
            decoration: const InputDecoration(
              labelText: 'Project Name (Optional)',
              hintText: 'Leave empty to use repository name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: Dimens.spacing),
          TextFormField(
            controller: _clonePathController,
            decoration: const InputDecoration(
              labelText: 'Clone Path (Optional)',
              hintText: 'Leave empty to use default location',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: Dimens.spacing),
        ElevatedButton(
          onPressed: _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          child: Text(_getActionButtonText()),
        ),
      ],
    );
  }

  String _getActionButtonText() {
    switch (_currentAction) {
      case ProjectActionType.create:
        return 'Create Project';
      case ProjectActionType.import:
        return 'Import Project';
      case ProjectActionType.clone:
        return 'Clone Repository';
    }
  }

  Future<void> _selectImportDirectory() async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      setState(() {
        _importPathController.text = result;
        // Extract folder name as default project name
        final folderName = result.split('/').last;
        if (_importNameController.text.isEmpty) {
          _importNameController.text = folderName;
        }
      });
    }
  }

  void _handleSubmit() {
    bool isValid = false;
    ProjectActionResult? result;

    switch (_currentAction) {
      case ProjectActionType.create:
        isValid = _createFormKey.currentState?.validate() ?? false;
        if (isValid) {
          result = CreateProjectResult(
            name: _createNameController.text.trim(),
          );
        }
        break;

      case ProjectActionType.import:
        isValid = _importFormKey.currentState?.validate() ?? false;
        if (isValid) {
          result = ImportProjectResult(
            path: _importPathController.text.trim(),
            name: _importNameController.text.trim().isNotEmpty
                ? _importNameController.text.trim()
                : null,
          );
        }
        break;

      case ProjectActionType.clone:
        isValid = _cloneFormKey.currentState?.validate() ?? false;
        if (isValid) {
          final cloneName = _cloneNameController.text.trim().isNotEmpty
              ? _cloneNameController.text.trim()
              : _extractRepoNameFromUrl(_cloneUrlController.text.trim());
          final clonePath = _clonePathController.text.trim().isNotEmpty
              ? _clonePathController.text.trim()
              : null;

          result = CloneRepositoryResult(
            url: _cloneUrlController.text.trim(),
            name: cloneName,
            path: clonePath,
          );
        }
        break;
    }

    if (result != null) {
      Navigator.of(context).pop(result);
    }
  }

  String _extractRepoNameFromUrl(String url) {
    // Extract repository name from URL
    final uri = Uri.tryParse(url);
    if (uri != null) {
      final segments = uri.pathSegments;
      if (segments.isNotEmpty) {
        String repoName = segments.last;
        // Remove .git extension if present
        if (repoName.endsWith('.git')) {
          repoName = repoName.substring(0, repoName.length - 4);
        }
        return repoName.isNotEmpty ? repoName : 'project';
      }
    }
    return 'project';
  }
}

class ProjectActionResult {}

class CreateProjectResult extends ProjectActionResult {
  final String name;

  CreateProjectResult({required this.name});
}

class ImportProjectResult extends ProjectActionResult {
  final String path;
  final String? name;

  ImportProjectResult({required this.path, this.name});
}

class CloneRepositoryResult extends ProjectActionResult {
  final String url;
  final String? name;
  final String? path;

  CloneRepositoryResult({required this.url, this.name, this.path});
}
