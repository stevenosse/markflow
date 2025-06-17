# Keyboard Shortcuts

MarkFlow supports comprehensive keyboard shortcuts for efficient navigation and editing.

## Global Shortcuts (Available Everywhere)

| Shortcut | Action | Description |
|----------|--------|--------------|
| `Cmd+N` (macOS) / `Ctrl+N` (Others) | Create New Project | Opens the create project dialog |
| `Cmd+,` (macOS) / `Ctrl+,` (Others) | Open Settings | Navigate to settings screen |
| `Cmd+W` (macOS) / `Ctrl+W` (Others) | Go Back | Navigate back to previous screen |
| `Escape` | Go Back | Alternative way to go back |

## Projects Screen Shortcuts

| Shortcut | Action | Description |
|----------|--------|--------------|
| `Cmd+N` (macOS) / `Ctrl+N` (Others) | New Project | Create a new project |
| `Cmd+O` (macOS) / `Ctrl+O` (Others) | Open Project | Open selected project |
| `Cmd+R` (macOS) / `Ctrl+R` (Others) | Refresh Projects | Reload the projects list |
| `Cmd+F` (macOS) / `Ctrl+F` (Others) | Focus Search | Focus on the search bar |
| `Delete` / `Backspace` | Delete Project | Delete selected project |
| `F2` | Rename Project | Rename selected project |
| `Enter` | Open Project | Open the selected project |
| `↑` / `↓` | Navigate Projects | Navigate through project list |

## Editor Shortcuts

### File Operations
| Shortcut | Action | Description |
|----------|--------|--------------|
| `Cmd+S` (macOS) / `Ctrl+S` (Others) | Save File | Save current file |
| `Cmd+N` (macOS) / `Ctrl+N` (Others) | New File | Create new file |
| `Cmd+Shift+N` (macOS) / `Ctrl+Shift+N` (Others) | New Folder | Create new folder |
| `Cmd+O` (macOS) / `Ctrl+O` (Others) | Open File | Open file dialog |
| `Cmd+W` (macOS) / `Ctrl+W` (Others) | Close Tab | Close current tab |
| `Cmd+Shift+W` (macOS) / `Ctrl+Shift+W` (Others) | Close All Tabs | Close all open tabs |

### Editor Actions
| Shortcut | Action | Description |
|----------|--------|--------------|
| `Cmd+Z` (macOS) / `Ctrl+Z` (Others) | Undo | Undo last action |
| `Cmd+Y` (macOS) / `Ctrl+Y` (Others) | Redo | Redo last undone action |
| `Cmd+F` (macOS) / `Ctrl+F` (Others) | Find | Open find dialog |
| `Cmd+H` (macOS) / `Ctrl+H` (Others) | Find & Replace | Open find and replace dialog |
| `Cmd+G` (macOS) / `Ctrl+G` (Others) | Find Next | Find next occurrence |
| `Cmd+Shift+G` (macOS) / `Ctrl+Shift+G` (Others) | Find Previous | Find previous occurrence |

### View Controls
| Shortcut | Action | Description |
|----------|--------|--------------|
| `Cmd+\` (macOS) / `Ctrl+\` (Others) | Toggle Sidebar | Show/hide file tree panel |
| `Cmd+Shift+P` (macOS) / `Ctrl+Shift+P` (Others) | Toggle Preview | Show/hide markdown preview |
| `Cmd+K, P` (macOS) / `Ctrl+K, P` (Others) | Preview Mode | Switch to preview-only mode |
| `Cmd+K, E` (macOS) / `Ctrl+K, E` (Others) | Editor Mode | Switch to editor-only mode |
| `Cmd+K, S` (macOS) / `Ctrl+K, S` (Others) | Split Mode | Switch to split editor/preview mode |
| `Cmd+K, G` (macOS) / `Ctrl+K, G` (Others) | Git Mode | Switch to git panel mode |

### Quick Actions
| Shortcut | Action | Description |
|----------|--------|--------------|
| `Cmd+P` (macOS) / `Ctrl+P` (Others) | Quick Open | Quick file opener |
| `Cmd+Shift+P` (macOS) / `Ctrl+Shift+P` (Others) | Command Palette | Open command palette |
| `Cmd+B` (macOS) / `Ctrl+B` (Others) | Toggle Bold | Toggle bold formatting |
| `Cmd+I` (macOS) / `Ctrl+I` (Others) | Toggle Italic | Toggle italic formatting |

### Zoom Controls
| Shortcut | Action | Description |
|----------|--------|--------------|
| `Cmd+=` (macOS) / `Ctrl+=` (Others) | Zoom In | Increase editor font size |
| `Cmd+-` (macOS) / `Ctrl+-` (Others) | Zoom Out | Decrease editor font size |
| `Cmd+0` (macOS) / `Ctrl+0` (Others) | Reset Zoom | Reset editor font size |

### File Tree Operations
| Shortcut | Action | Description |
|----------|--------|--------------|
| `Enter` | Open File | Open selected file |
| `Space` | Preview File | Quick preview of selected file |
| `Delete` / `Backspace` | Delete File | Delete selected file/folder |
| `F2` | Rename | Rename selected file/folder |
| `Cmd+C` (macOS) / `Ctrl+C` (Others) | Copy | Copy selected file/folder |
| `Cmd+X` (macOS) / `Ctrl+X` (Others) | Cut | Cut selected file/folder |
| `Cmd+V` (macOS) / `Ctrl+V` (Others) | Paste | Paste file/folder |
| `↑` / `↓` | Navigate | Navigate through file tree |
| `→` / `←` | Expand/Collapse | Expand or collapse folders |

### Tab Management
| Shortcut | Action | Description |
|----------|--------|--------------|
| `Cmd+T` (macOS) / `Ctrl+T` (Others) | New Tab | Open new tab |
| `Cmd+Shift+T` (macOS) / `Ctrl+Shift+T` (Others) | Reopen Tab | Reopen last closed tab |
| `Cmd+1-9` (macOS) / `Ctrl+1-9` (Others) | Switch Tab | Switch to tab by number |
| `Cmd+Tab` (macOS) / `Ctrl+Tab` (Others) | Next Tab | Switch to next tab |
| `Cmd+Shift+Tab` (macOS) / `Ctrl+Shift+Tab` (Others) | Previous Tab | Switch to previous tab |

## Implementation Details

The keyboard shortcuts are implemented using Flutter's `Shortcuts` and `Actions` widgets:

- **Global shortcuts** are defined at the application level and work throughout the app
- **Screen-specific shortcuts** are defined at the screen level (Projects, Editor)
- **Context-aware actions** automatically adapt based on the current screen and state

### Architecture

- `KeyboardShortcutsService`: Defines all shortcut mappings and intent classes
- `KeyboardActions`: Implements the actual action handlers
- Screen-level integration: Each major screen wraps its content with appropriate shortcuts

### Platform Differences

- **macOS**: Uses `Cmd` key for primary shortcuts
- **Windows/Linux**: Uses `Ctrl` key for primary shortcuts
- **Function keys**: Work consistently across all platforms
- **Arrow keys**: Standard navigation on all platforms

### Customization

To add new keyboard shortcuts:

1. Define the intent class in `KeyboardShortcutsService`
2. Add the shortcut mapping to the appropriate shortcut map
3. Implement the action handler in `KeyboardActions`
4. Ensure the screen includes the appropriate shortcuts wrapper

### Accessibility

All keyboard shortcuts are designed to be accessible and follow platform conventions for better user experience.