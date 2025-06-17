import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markflow/src/core/theme/dimens.dart';
import 'package:markflow/src/core/services/ssh_key_service.dart';
import 'package:markflow/src/core/services/settings_service.dart';
import 'package:markflow/src/shared/locator.dart';
import 'package:markflow/src/shared/services/app_logger.dart';

class SshKeyManagementDialog extends StatefulWidget {
  const SshKeyManagementDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const SshKeyManagementDialog(),
    );
  }

  @override
  State<SshKeyManagementDialog> createState() => _SshKeyManagementDialogState();
}

class _SshKeyManagementDialogState extends State<SshKeyManagementDialog> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final SshKeyService _sshKeyService = locator<SshKeyService>();
  final SettingsService _settingsService = locator<SettingsService>();
  final AppLogger _logger = locator<AppLogger>();
  
  List<String> _availableKeys = [];
  String? _selectedKeyPath;
  String? _publicKeyContent;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  bool _isGenerating = false;
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    _loadSshKeyData();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadSshKeyData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final keys = await _sshKeyService.getAvailableSshKeys();
      final currentKeyPath = _settingsService.defaultSshKeyPath;
      final email = await _sshKeyService.getSshKeyEmail();
      
      setState(() {
        _availableKeys = keys;
        _selectedKeyPath = currentKeyPath;
        _emailController.text = email ?? '';
        _isLoading = false;
      });
      
      if (currentKeyPath != null) {
        await _loadPublicKey(currentKeyPath);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load SSH key data: $e';
        _isLoading = false;
      });
      _logger.error('Error loading SSH key data: $e');
    }
  }

  Future<void> _loadPublicKey(String keyPath) async {
    try {
      final publicKey = await _sshKeyService.getPublicKeyContent(keyPath);
      setState(() {
        _publicKeyContent = publicKey;
      });
    } catch (e) {
      _logger.error('Error loading public key: $e');
    }
  }

  Future<void> _generateNewKey() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    
    setState(() {
      _isGenerating = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final success = await _sshKeyService.generateSshKey(email: email);
      
      if (success) {
        final newKeyPath = await _sshKeyService.getSshKeyPath();
        await _settingsService.setDefaultSshKeyPath(newKeyPath);
        
        setState(() {
          _successMessage = 'SSH key generated successfully!';
          _isGenerating = false;
        });
        
        await _loadSshKeyData();
      } else {
        setState(() {
          _errorMessage = 'Failed to generate SSH key';
          _isGenerating = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error generating SSH key: $e';
        _isGenerating = false;
      });
      _logger.error('Error generating SSH key: $e');
    }
  }

  Future<void> _selectExistingKey(String keyPath) async {
    await _settingsService.setDefaultSshKeyPath(keyPath);
    setState(() {
      _selectedKeyPath = keyPath;
    });
    await _loadPublicKey(keyPath);
  }

  Future<void> _copyPublicKey() async {
    if (_publicKeyContent != null) {
      await Clipboard.setData(ClipboardData(text: _publicKeyContent!));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Public key copied to clipboard')),
        );
      }
    }
  }

  Future<void> _testGitHubConnection() async {
    setState(() {
      _isTesting = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final success = await _sshKeyService.testSshConnection('git@github.com');
      
      setState(() {
        if (success) {
          _successMessage = 'GitHub SSH connection successful!';
        } else {
          _errorMessage = 'GitHub SSH connection failed. Make sure your public key is added to GitHub.';
        }
        _isTesting = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error testing connection: $e';
        _isTesting = false;
      });
      _logger.error('Error testing SSH connection: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('SSH Keys'),
      content: SizedBox(
        width: 600,
        height: 500,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_errorMessage != null) _buildErrorMessage(),
          if (_successMessage != null) _buildSuccessMessage(),
          _buildExistingKeysSection(),
          const SizedBox(height: Dimens.spacingL),
          _buildGenerateKeySection(),
          if (_publicKeyContent != null) ...[
            const SizedBox(height: Dimens.spacingL),
            _buildPublicKeySection(),
          ],
          const SizedBox(height: Dimens.spacingL),
          _buildTestConnectionSection(),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimens.spacing),
      margin: const EdgeInsets.only(bottom: Dimens.spacing),
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
    );
  }

  Widget _buildSuccessMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimens.spacing),
      margin: const EdgeInsets.only(bottom: Dimens.spacing),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(Dimens.radius),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: Dimens.spacing / 2),
          Expanded(
            child: Text(
              _successMessage!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExistingKeysSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Existing SSH Keys',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: Dimens.spacing),
        if (_availableKeys.isEmpty)
          const Text(
            'No SSH keys found in ~/.ssh directory',
            style: TextStyle(color: Colors.grey),
          )
        else
          ..._availableKeys.map((keyPath) => Card(
            child: ListTile(
              leading: Icon(
                Icons.vpn_key,
                color: _selectedKeyPath == keyPath
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              title: Text(
                keyPath.split('/').last,
                style: TextStyle(
                  fontWeight: _selectedKeyPath == keyPath
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              subtitle: Text(
                keyPath,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
              trailing: _selectedKeyPath == keyPath
                  ? Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
              onTap: () => _selectExistingKey(keyPath),
            ),
          )),
      ],
    );
  }

  Widget _buildGenerateKeySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Generate New SSH Key',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: Dimens.spacing),
        Form(
          key: _formKey,
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'your.email@example.com',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: Dimens.spacing),
              ElevatedButton(
                onPressed: _isGenerating ? null : _generateNewKey,
                child: _isGenerating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Generate'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPublicKeySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Public Key',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _copyPublicKey,
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Copy'),
            ),
          ],
        ),
        const SizedBox(height: Dimens.spacing / 2),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(Dimens.spacing),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(Dimens.radius),
            border: Border.all(
              color: Theme.of(context).dividerColor,
            ),
          ),
          child: Text(
            _publicKeyContent ?? 'Failed to load public key',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: Dimens.spacing / 2),
        Text(
          'Copy this public key and add it to your Git hosting service (GitHub, GitLab, etc.)',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildTestConnectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Test Connection',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: Dimens.spacing),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _isTesting || _selectedKeyPath == null ? null : _testGitHubConnection,
              icon: _isTesting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud, size: 16),
              label: const Text('Test GitHub'),
            ),
            const SizedBox(width: Dimens.spacing),
            Text(
              'Test SSH connection to GitHub',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}