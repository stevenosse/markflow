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
      body: Column(
        children: [
          _DesktopHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildDesktopSettingsContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopSettingsContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(Dimens.desktopMainPadding),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: Dimens.desktopContentMaxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DesktopSectionHeader(title: 'Project Storage'),
              SizedBox(height: Dimens.desktopSpacing),
              _DesktopProjectPathCard(
                currentPath: _currentPath,
                onSelectNewPath: _selectNewPath,
              ),
              SizedBox(height: Dimens.desktopSpacingL),
              _DesktopSectionHeader(title: 'Platform Information'),
              SizedBox(height: Dimens.desktopSpacing),
              _DesktopPlatformInfoCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopHeader extends StatelessWidget {
  const _DesktopHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Dimens.desktopHeaderHeight,
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.desktopMainPadding,
        vertical: Dimens.desktopSpacing,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Settings',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => context.router.pop(),
            icon: const Icon(Icons.close),
            iconSize: Dimens.desktopIconSize,
            constraints: BoxConstraints(
              minWidth: Dimens.desktopButtonHeight,
              minHeight: Dimens.desktopButtonHeight,
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopSectionHeader extends StatelessWidget {
  final String title;

  const _DesktopSectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _DesktopProjectPathCard extends StatelessWidget {
  final String? currentPath;
  final VoidCallback onSelectNewPath;

  const _DesktopProjectPathCard({
    required this.currentPath,
    required this.onSelectNewPath,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimens.desktopCardRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(Dimens.desktopSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.folder,
                  color: Theme.of(context).colorScheme.primary,
                  size: Dimens.desktopIconSize,
                ),
                SizedBox(width: Dimens.desktopSpacing / 2),
                Text(
                  'Projects Directory',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: Dimens.desktopSpacing),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(Dimens.desktopSpacing),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(Dimens.desktopRadius),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
              child: Text(
                currentPath ?? 'Not set',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ),
            SizedBox(height: Dimens.desktopSpacing),
            Text(
              'All new projects will be created in this directory. Existing projects will not be moved.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: Dimens.desktopSpacing),
            SizedBox(
              height: Dimens.desktopButtonHeight,
              child: ElevatedButton.icon(
                onPressed: onSelectNewPath,
                icon: const Icon(Icons.folder_open),
                label: const Text('Change Directory'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimens.desktopSpacing,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopPlatformInfoCard extends StatelessWidget {
  const _DesktopPlatformInfoCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimens.desktopCardRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(Dimens.desktopSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Platform.isMacOS ? Icons.laptop_mac : Icons.computer,
                  color: Theme.of(context).colorScheme.primary,
                  size: Dimens.desktopIconSize,
                ),
                SizedBox(width: Dimens.desktopSpacing / 2),
                Text(
                  'Platform',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: Dimens.desktopSpacing),
            _DesktopInfoRow(
              label: 'Operating System',
              value: Platform.operatingSystem,
            ),
            _DesktopInfoRow(
              label: 'Version',
              value: Platform.operatingSystemVersion,
            ),
            _DesktopInfoRow(
              label: 'Optimized for',
              value: Platform.isMacOS ? 'macOS Desktop' : 'Desktop',
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _DesktopInfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Dimens.desktopSpacing / 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
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