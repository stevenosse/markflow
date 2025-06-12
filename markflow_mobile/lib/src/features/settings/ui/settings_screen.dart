import 'dart:io';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:markflow/src/core/theme/dimens.dart';
import 'package:markflow/src/core/services/path_config_service.dart';
import 'package:markflow/src/shared/locator.dart';
import 'package:markflow/src/shared/services/app_logger.dart';
import 'package:file_picker/file_picker.dart';

@RoutePage()
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final PathConfigService _pathConfigService = locator<PathConfigService>();
  final AppLogger _logger = locator<AppLogger>();
  
  String? _currentPath;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentPath();
  }

  Future<void> _loadCurrentPath() async {
    try {
      final path = await _pathConfigService.getProjectsBasePath();
      setState(() {
        _currentPath = path;
        _isLoading = false;
      });
    } catch (e) {
      _logger.error('Error loading current path: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectNewPath() async {
    try {
      final result = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Select projects directory',
        initialDirectory: _currentPath,
      );
      
      if (result != null && result.isNotEmpty) {
        final success = await _pathConfigService.setProjectsBasePath(result);
        if (success && mounted) {
          setState(() {
            _currentPath = result;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Projects directory updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update projects directory'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      _logger.error('Error selecting new path: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error selecting directory'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildSettingsContent(),
    );
  }

  Widget _buildSettingsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Dimens.spacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Project Storage'),
          const SizedBox(height: Dimens.spacing),
          _buildProjectPathCard(),
          const SizedBox(height: Dimens.doubleSpacing),
          _buildSectionHeader('Platform Information'),
          const SizedBox(height: Dimens.spacing),
          _buildPlatformInfoCard(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildProjectPathCard() {
    return Card(
      elevation: Dimens.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimens.cardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Dimens.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.folder,
                  color: Theme.of(context).colorScheme.primary,
                  size: Dimens.iconSize,
                ),
                const SizedBox(width: Dimens.halfSpacing),
                Text(
                  'Projects Directory',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimens.spacing),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Dimens.spacing),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(Dimens.inputRadius),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: Dimens.borderWidth,
                ),
              ),
              child: Text(
                _currentPath ?? 'Not set',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: Dimens.spacing),
            Text(
              'All new projects will be created in this directory. Existing projects will not be moved.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Dimens.spacing),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _selectNewPath,
                icon: const Icon(Icons.folder_open),
                label: const Text('Change Directory'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: Dimens.spacing,
                    horizontal: Dimens.doubleSpacing,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformInfoCard() {
    return Card(
      elevation: Dimens.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimens.cardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Dimens.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Platform.isMacOS ? Icons.laptop_mac : Icons.computer,
                  color: Theme.of(context).colorScheme.primary,
                  size: Dimens.iconSize,
                ),
                const SizedBox(width: Dimens.halfSpacing),
                Text(
                  'Platform',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimens.spacing),
            _buildInfoRow('Operating System', Platform.operatingSystem),
            _buildInfoRow('Version', Platform.operatingSystemVersion),
            _buildInfoRow('Optimized for', Platform.isMacOS ? 'macOS Desktop' : 'Desktop'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimens.minSpacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}