import 'dart:io';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:markflow/src/core/theme/dimens.dart';
import 'package:markflow/src/core/services/path_config_service.dart';
import 'package:markflow/src/core/services/settings_service.dart';
import 'package:markflow/src/shared/locator.dart';
import 'package:markflow/src/shared/services/app_logger.dart';
import 'package:file_picker/file_picker.dart';
import 'package:markflow/src/core/routing/app_router.dart';
import 'package:markflow/src/features/settings/ui/widgets/ssh_key_management_dialog.dart';

@RoutePage()
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final PathConfigService _pathConfigService = locator<PathConfigService>();
  final SettingsService _settingsService = locator<SettingsService>();
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
              _DesktopSectionHeader(title: 'Editor Settings'),
              SizedBox(height: Dimens.desktopSpacing),
              _DesktopEditorSettingsCard(settingsService: _settingsService),
              SizedBox(height: Dimens.desktopSpacingL),
              _DesktopSectionHeader(title: 'Keyboard Shortcuts'),
              SizedBox(height: Dimens.desktopSpacing),
              _DesktopShortcutsCard(),
              SizedBox(height: Dimens.desktopSpacingL),
              _DesktopSectionHeader(title: 'SSH Key Management'),
              SizedBox(height: Dimens.desktopSpacing),
              const _DesktopSshKeyCard(),
              SizedBox(height: Dimens.desktopSpacingL),
              _DesktopSectionHeader(title: 'Platform Information'),
              SizedBox(height: Dimens.desktopSpacing),
              const _DesktopPlatformInfoCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopShortcutsCard extends StatelessWidget {
  const _DesktopShortcutsCard();

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
                  Icons.keyboard,
                  color: Theme.of(context).colorScheme.primary,
                  size: Dimens.desktopIconSize,
                ),
                SizedBox(width: Dimens.desktopSpacing / 2),
                Text(
                  'Keyboard Shortcuts',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: Dimens.desktopSpacing),
            Text(
              'View and search all available keyboard shortcuts for faster navigation and productivity.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: Dimens.desktopSpacing),
            ElevatedButton.icon(
              onPressed: () => context.router.push(const ShortcutsRoute()),
              icon: const Icon(Icons.launch, size: 18),
              label: const Text('View Shortcuts'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimens.desktopSpacing,
                  vertical: Dimens.desktopSpacing / 2,
                ),
              ),
            ),
          ],
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
      width: double.infinity,
      padding: EdgeInsets.all(Dimens.desktopMainPadding),
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
        fontWeight: FontWeight.w600,
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
                  Icons.folder_outlined,
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
                currentPath ?? 'No directory selected',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: 'SF Mono',
                  fontFamilyFallback: const ['Monaco', 'Consolas', 'monospace'],
                ),
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

class _DesktopSshKeyCard extends StatelessWidget {
  const _DesktopSshKeyCard();

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
                  Icons.key,
                  color: Theme.of(context).colorScheme.primary,
                  size: Dimens.desktopIconSize,
                ),
                SizedBox(width: Dimens.desktopSpacing / 2),
                Text(
                  'SSH Key Management',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: Dimens.desktopSpacing),
            Text(
              'Manage SSH keys for Git authentication. SSH keys provide a secure way to authenticate with remote repositories without entering your password each time.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: Dimens.desktopSpacing),
            SizedBox(
              height: Dimens.desktopButtonHeight,
              child: ElevatedButton.icon(
                onPressed: () => SshKeyManagementDialog.show(context),
                icon: const Icon(Icons.settings),
                label: const Text('Manage SSH Keys'),
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
            SizedBox(height: Dimens.desktopSpacing / 2),
            _DesktopInfoRow(
              label: 'Version',
              value: Platform.operatingSystemVersion,
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
    return Row(
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
    );
  }
}

class _DesktopEditorSettingsCard extends StatelessWidget {
  final SettingsService settingsService;
  
  const _DesktopEditorSettingsCard({required this.settingsService});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimens.desktopCardRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(Dimens.desktopSpacing),
        child: ListenableBuilder(
          listenable: settingsService,
          builder: (context, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.edit_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: Dimens.desktopIconSize,
                  ),
                  SizedBox(width: Dimens.desktopSpacing / 2),
                  Text(
                    'Editor Settings',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: Dimens.desktopSpacing),
              Text(
                'Customize your markdown editor experience with font size, line height, and other preferences.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: Dimens.desktopSpacing),
              
              // Font Size Setting
              _EditorSettingRow(
                label: 'Font Size',
                value: '${settingsService.editorFontSize.toInt()}px',
                onDecrease: settingsService.editorFontSize > settingsService.minFontSize
                    ? () => settingsService.decreaseFontSize()
                    : null,
                onIncrease: settingsService.editorFontSize < settingsService.maxFontSize
                    ? () => settingsService.increaseFontSize()
                    : null,
                onReset: () => settingsService.resetFontSize(),
              ),
              
              SizedBox(height: Dimens.desktopSpacing),
              
              // Line Height Setting
              _EditorSettingRow(
                label: 'Line Height',
                value: settingsService.editorLineHeight.toStringAsFixed(1),
                onDecrease: settingsService.editorLineHeight > 1.0
                    ? () => settingsService.setEditorLineHeight(
                        (settingsService.editorLineHeight - 0.1).clamp(1.0, 3.0))
                    : null,
                onIncrease: settingsService.editorLineHeight < 3.0
                    ? () => settingsService.setEditorLineHeight(
                        (settingsService.editorLineHeight + 0.1).clamp(1.0, 3.0))
                    : null,
                onReset: () => settingsService.setEditorLineHeight(1.5),
              ),
              
              SizedBox(height: Dimens.desktopSpacing),
              
              // Theme Setting
              _EditorDropdownRow(
                label: 'Theme',
                value: settingsService.editorTheme,
                options: const ['default', 'dark', 'light'],
                onChanged: (value) => settingsService.setEditorTheme(value!),
              ),
              
              SizedBox(height: Dimens.desktopSpacing),
              
              // Toggle Settings
              _EditorToggleRow(
                label: 'Auto Save',
                value: settingsService.autoSave,
                onChanged: (value) => settingsService.setAutoSave(value),
              ),
              
              SizedBox(height: Dimens.desktopSpacing / 2),
              
              _EditorToggleRow(
                label: 'Word Wrap',
                value: settingsService.wordWrap,
                onChanged: (value) => settingsService.setWordWrap(value),
              ),
              
              SizedBox(height: Dimens.desktopSpacing / 2),
              
              _EditorToggleRow(
                label: 'Show Line Numbers',
                value: settingsService.showLineNumbers,
                onChanged: (value) => settingsService.setShowLineNumbers(value),
              ),
              
              SizedBox(height: Dimens.desktopSpacing),
              
              // Reset Button
              ElevatedButton.icon(
                onPressed: () => _showResetDialog(context),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Reset to Defaults'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimens.desktopSpacing,
                    vertical: Dimens.desktopSpacing / 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Editor Settings'),
        content: const Text(
          'Are you sure you want to reset all editor settings to their default values?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              settingsService.resetToDefaults();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Editor settings reset to defaults'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class _EditorSettingRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;
  final VoidCallback? onReset;
  
  const _EditorSettingRow({
    required this.label,
    required this.value,
    this.onDecrease,
    this.onIncrease,
    this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
          child: Row(
            children: [
              IconButton(
                onPressed: onDecrease,
                icon: const Icon(Icons.remove, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: onDecrease != null
                      ? Theme.of(context).colorScheme.surfaceContainerHighest
                      : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  foregroundColor: onDecrease != null
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                  minimumSize: const Size(32, 32),
                ),
              ),
              SizedBox(width: Dimens.desktopSpacing / 2),
              SizedBox(
                width: 60,
                child: Text(
                  value,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: Dimens.desktopSpacing / 2),
              IconButton(
                onPressed: onIncrease,
                icon: const Icon(Icons.add, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: onIncrease != null
                      ? Theme.of(context).colorScheme.surfaceContainerHighest
                      : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  foregroundColor: onIncrease != null
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                  minimumSize: const Size(32, 32),
                ),
              ),
              if (onReset != null) ...[
                SizedBox(width: Dimens.desktopSpacing / 2),
                IconButton(
                  onPressed: onReset,
                  icon: const Icon(Icons.refresh, size: 16),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                    minimumSize: const Size(28, 28),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _EditorDropdownRow extends StatelessWidget {
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String?> onChanged;
  
  const _EditorDropdownRow({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
          child: DropdownButton<String>(
            value: value,
            onChanged: onChanged,
            items: options.map((option) {
              return DropdownMenuItem(
                value: option,
                child: Text(
                  option.substring(0, 1).toUpperCase() + option.substring(1),
                ),
              );
            }).toList(),
            underline: Container(
              height: 1,
              color: Theme.of(context).dividerColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _EditorToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  
  const _EditorToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
          child: Row(
            children: [
              Switch(
                value: value,
                onChanged: onChanged,
              ),
              SizedBox(width: Dimens.desktopSpacing / 2),
              Text(
                value ? 'Enabled' : 'Disabled',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}