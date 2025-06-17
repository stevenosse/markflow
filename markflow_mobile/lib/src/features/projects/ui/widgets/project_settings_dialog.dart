import 'package:flutter/material.dart';
import 'package:markflow/src/core/theme/dimens.dart';
import 'package:markflow/src/datasource/models/project.dart';
import 'package:markflow/src/datasource/models/git_models.dart';
import 'package:markflow/src/datasource/repositories/git_repository.dart';
import 'package:markflow/src/shared/locator.dart';
import 'package:markflow/src/shared/services/app_logger.dart';

class ProjectSettingsDialog extends StatefulWidget {
  final Project project;

  const ProjectSettingsDialog({
    super.key,
    required this.project,
  });

  static Future<ProjectSettingsResult?> show(
    BuildContext context,
    Project project,
  ) {
    return showDialog<ProjectSettingsResult>(
      context: context,
      builder: (context) => ProjectSettingsDialog(project: project),
    );
  }

  @override
  State<ProjectSettingsDialog> createState() => _ProjectSettingsDialogState();
}

class _ProjectSettingsDialogState extends State<ProjectSettingsDialog> {
  final _formKey = GlobalKey<FormState>();
  final _remoteNameController = TextEditingController();
  final _remoteUrlController = TextEditingController();
  final GitRepository _gitRepository = locator<GitRepository>();
  final AppLogger _logger = locator<AppLogger>();
  
  List<GitRemote> _remotes = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRemotes();
  }

  @override
  void dispose() {
    _remoteNameController.dispose();
    _remoteUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadRemotes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final remotes = await _gitRepository.getRemotes(widget.project.path);
      setState(() {
        _remotes = remotes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load remotes: $e';
        _isLoading = false;
      });
      _logger.error('Error loading remotes: $e');
    }
  }

  Future<void> _addRemote() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _remoteNameController.text.trim();
    final url = _remoteUrlController.text.trim();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await _gitRepository.addRemote(
        widget.project.path,
        name,
        url,
      );

      if (success) {
        _remoteNameController.clear();
        _remoteUrlController.clear();
        await _loadRemotes();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Remote "$name" added successfully')),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to add remote';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error adding remote: $e';
        _isLoading = false;
      });
      _logger.error('Error adding remote: $e');
    }
  }

  Future<void> _removeRemote(String remoteName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Remote'),
        content: Text('Are you sure you want to remove the remote "$remoteName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await _gitRepository.removeRemote(
        widget.project.path,
        remoteName,
      );

      if (success) {
        await _loadRemotes();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Remote "$remoteName" removed successfully')),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to remove remote';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error removing remote: $e';
        _isLoading = false;
      });
      _logger.error('Error removing remote: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Project Settings - ${widget.project.name}'),
      content: SizedBox(
        width: 500,
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Remote Repositories',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: Dimens.spacing),
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(Dimens.spacing),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(Dimens.radius),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: Dimens.spacing / 2),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (_errorMessage != null) const SizedBox(height: Dimens.spacing),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildRemotesList(),
            ),
            const SizedBox(height: Dimens.spacing),
            _buildAddRemoteForm(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildRemotesList() {
    if (_remotes.isEmpty) {
      return const Center(
        child: Text(
          'No remote repositories configured',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: _remotes.length,
      itemBuilder: (context, index) {
        final remote = _remotes[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.cloud),
            title: Text(remote.name),
            subtitle: Text(
              remote.url,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _removeRemote(remote.name),
              tooltip: 'Remove remote',
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddRemoteForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add Remote Repository',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: Dimens.spacing / 2),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: TextFormField(
                  controller: _remoteNameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'origin',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }
                    if (_remotes.any((r) => r.name == value.trim())) {
                      return 'Already exists';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: Dimens.spacing),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _remoteUrlController,
                  decoration: const InputDecoration(
                    labelText: 'URL',
                    hintText: 'git@github.com:user/repo.git',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: Dimens.spacing),
              ElevatedButton(
                onPressed: _isLoading ? null : _addRemote,
                child: const Text('Add'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProjectSettingsResult {
  final bool hasChanges;

  const ProjectSettingsResult({this.hasChanges = false});
}