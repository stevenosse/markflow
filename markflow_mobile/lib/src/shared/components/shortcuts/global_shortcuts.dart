import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_route/auto_route.dart';
import 'package:markflow/src/core/routing/app_router.dart';
import 'package:markflow/src/features/projects/ui/widgets/project_action_dialog.dart';

/// Widget that provides global keyboard shortcuts available throughout the app
class GlobalShortcuts extends StatelessWidget {
  final Widget child;

  const GlobalShortcuts({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: _buildShortcuts(),
      child: Actions(
        actions: _buildActions(context),
        child: child,
      ),
    );
  }

  Map<ShortcutActivator, Intent> _buildShortcuts() {
    return {
      // App-level shortcuts
      const SingleActivator(LogicalKeyboardKey.keyN, meta: true, shift: true): const CreateProjectIntent(),
      const SingleActivator(LogicalKeyboardKey.comma, meta: true): const OpenSettingsIntent(),
      const SingleActivator(LogicalKeyboardKey.escape): const GoBackIntent(),
      const SingleActivator(LogicalKeyboardKey.keyQ, meta: true): const QuitAppIntent(),
      
      // Quick actions
      const SingleActivator(LogicalKeyboardKey.keyO, meta: true, shift: true): const QuickOpenIntent(),
      const SingleActivator(LogicalKeyboardKey.keyP, meta: true): const CommandPaletteIntent(),
    };
  }

  Map<Type, Action<Intent>> _buildActions(BuildContext context) {
    return {
      CreateProjectIntent: CallbackAction<CreateProjectIntent>(
        onInvoke: (_) => _createProject(context),
      ),
      OpenSettingsIntent: CallbackAction<OpenSettingsIntent>(
        onInvoke: (_) => _openSettings(context),
      ),
      GoBackIntent: CallbackAction<GoBackIntent>(
        onInvoke: (_) => _goBack(context),
      ),
      QuitAppIntent: CallbackAction<QuitAppIntent>(
        onInvoke: (_) => _quitApp(),
      ),
      QuickOpenIntent: CallbackAction<QuickOpenIntent>(
        onInvoke: (_) => _quickOpen(context),
      ),
      CommandPaletteIntent: CallbackAction<CommandPaletteIntent>(
        onInvoke: (_) => _commandPalette(context),
      ),
    };
  }

  // Action implementations
  void _createProject(BuildContext context) async {
    try {
      await ProjectActionDialog.show(
        context,
        initialAction: ProjectActionType.create,
      );
    } catch (e) {
        // Error handled silently
      }
  }

  void _openSettings(BuildContext context) {
    try {
      context.router.push(SettingsRoute());
    } catch (e) {
        // Error handled silently
      }
  }

  void _goBack(BuildContext context) {
    try {
      if (context.router.canPop()) {
        context.router.pop();
      }
    } catch (e) {
        // Error handled silently
      }
  }

  void _quitApp() {
    try {
      // On mobile, this would minimize the app
      // On desktop, this would close the app
      // Quit app requested
      } catch (e) {
        // Error handled silently
      }
  }

  void _quickOpen(BuildContext context) {
    try {
      // Show quick open dialog for file navigation
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Quick Open'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Type to search files...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                onSubmitted: (value) {
                  Navigator.of(context).pop();
                  // Quick open file: $value
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Start typing to search for files in your project.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
    } catch (e) {
        // Error handled silently
      }
  }

  void _commandPalette(BuildContext context) {
    try {
      // Show command palette with available actions
      final commands = [
        'Create New Project',
        'Open Project',
        'Import Project',
        'Save All Files',
        'Find in Files',
        'Toggle Sidebar',
        'Toggle Preview',
        'Settings',
      ];
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Command Palette'),
          content: SizedBox(
            width: 400,
            height: 300,
            child: Column(
              children: [
                TextField(
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Type a command...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.terminal),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: commands.length,
                    itemBuilder: (context, index) => ListTile(
                      leading: const Icon(Icons.play_arrow),
                      title: Text(commands[index]),
                      onTap: () {
                        Navigator.of(context).pop();
                        // Execute command: ${commands[index]}
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
    } catch (e) {
        // Error handled silently
      }
  }
}

// Intent classes
class CreateProjectIntent extends Intent {
  const CreateProjectIntent();
}

class OpenSettingsIntent extends Intent {
  const OpenSettingsIntent();
}

class GoBackIntent extends Intent {
  const GoBackIntent();
}

class QuitAppIntent extends Intent {
  const QuitAppIntent();
}

class QuickOpenIntent extends Intent {
  const QuickOpenIntent();
}

class CommandPaletteIntent extends Intent {
  const CommandPaletteIntent();
}