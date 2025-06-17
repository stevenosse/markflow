# MarkFlow

A powerful, cross-platform markdown editor built with Flutter, designed for seamless writing and project management with integrated Git version control.

![MarkFlow Logo](assets/images/mflogo.png)

## ✨ Features

### 📝 Advanced Markdown Editor
- **Rich Editing Experience**: Full-featured markdown editor with syntax highlighting
- **Live Preview**: Real-time markdown preview with synchronized scrolling
- **Multi-tab Support**: Work on multiple files simultaneously with tab navigation
- **Auto-save**: Automatic saving with configurable intervals
- **Line Numbers**: Optional line number display for better navigation
- **Word Wrap**: Toggle word wrapping for optimal text flow
- **Go to Line**: Quick navigation to specific line numbers
- **Find & Replace**: Powerful search and replace functionality
- **Zoom Controls**: Adjustable font size for comfortable editing

### 🗂️ Project Management
- **Project Organization**: Create and manage multiple markdown projects
- **File Explorer**: Intuitive file tree navigation with context menus
- **File Operations**: Create, rename, delete files and folders
- **Project Templates**: Quick project setup with predefined structures
- **Recent Projects**: Easy access to recently opened projects

### 🔧 Git Integration
- **Repository Management**: Initialize, clone, and manage Git repositories
- **Visual Git Status**: Real-time display of file changes and repository status
- **Staging & Commits**: Stage files and create commits with descriptive messages
- **Branch Management**: Create, switch, and manage Git branches
- **Push/Pull Operations**: Sync with remote repositories
- **Commit History**: View and navigate through project history
- **SSH Support**: Secure authentication for remote repositories

### ⚙️ Customization & Settings
- **Theme Support**: Multiple editor themes (Light, Dark, High Contrast)
- **Font Customization**: Adjustable font size and line height
- **Layout Options**: Configurable sidebar and preview panel visibility
- **Keyboard Shortcuts**: Comprehensive keyboard shortcuts for efficient workflow
- **Settings Persistence**: All preferences automatically saved

### 🖥️ Cross-Platform Support
- **Desktop**: Native support for macOS, Windows, and Linux
- **Mobile**: Optimized for iOS and Android devices
- **Responsive Design**: Adaptive UI for different screen sizes
- **Performance Optimized**: Smooth editing experience even with large files

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0 or higher
- Dart SDK 3.0 or higher
- Git (for version control features)
- Xcode (for macOS/iOS development)
- Android Studio (for Android development)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/markflow.git
   cd markflow_mobile
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate required code**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Generate internationalization files**
   ```bash
   dart run intl_utils:generate
   ```

5. **Run the application**
   ```bash
   flutter run
   ```

### Development Commands

The project includes a Makefile with convenient development commands:

```bash
# Install dependencies
make get

# Generate code (routes, models, etc.)
make codegen

# Generate internationalization files
make i18n

# Build for macOS
make build-macos

# Create DMG package (macOS)
make pkg

# Clean iOS build files
make clean-ios
```

## 📖 Usage

### Creating Your First Project
1. Launch MarkFlow
2. Click "New Project" or press `Cmd+N` (macOS) / `Ctrl+N` (Windows/Linux)
3. Choose a project name and location
4. Optionally initialize with Git
5. Start writing!

### Editor Shortcuts
| Action | macOS | Windows/Linux |
|--------|-------|---------------|
| New File | `Cmd+N` | `Ctrl+N` |
| Save File | `Cmd+S` | `Ctrl+S` |
| Save All | `Cmd+Shift+S` | `Ctrl+Shift+S` |
| Find | `Cmd+F` | `Ctrl+F` |
| Replace | `Cmd+R` | `Ctrl+R` |
| Go to Line | `Cmd+G` | `Ctrl+G` |
| Toggle Sidebar | `Cmd+B` | `Ctrl+B` |
| Toggle Preview | `Cmd+P` | `Ctrl+P` |
| Zoom In | `Cmd++` | `Ctrl++` |
| Zoom Out | `Cmd+-` | `Ctrl+-` |

### Git Workflow
1. **Initialize Repository**: Create a new Git repository for your project
2. **Stage Changes**: Select files to include in your next commit
3. **Commit**: Create commits with descriptive messages
4. **Push/Pull**: Sync with remote repositories
5. **Branch Management**: Create and switch between branches as needed

### Customizing Settings
Access settings through:
- Menu: `Settings > Preferences`
- Keyboard shortcut: `Cmd+,` (macOS) / `Ctrl+,` (Windows/Linux)

Customize:
- Editor theme and appearance
- Font size and line height
- Auto-save behavior
- Git configuration
- Keyboard shortcuts

## 🏗️ Architecture

MarkFlow follows a clean, modular architecture:

```
lib/src/
├── core/                 # Core application logic
│   ├── services/         # Business services
│   ├── theme/           # Theme and styling
│   ├── routing/         # Navigation and routing
│   └── i18n/           # Internationalization
├── features/            # Feature modules
│   ├── onboarding/     # App onboarding
│   ├── projects/       # Project management
│   ├── settings/       # Application settings
│   └── shortcuts/      # Keyboard shortcuts
├── datasource/         # Data layer
│   ├── models/         # Data models
│   ├── repositories/   # Repository pattern
│   └── http/          # API communication
└── shared/             # Shared components
    ├── components/     # Reusable UI components
    ├── extensions/     # Dart extensions
    └── services/       # Shared services
```

### Key Principles
- **Clean Architecture**: Separation of concerns with clear layer boundaries
- **Feature-based Organization**: Modular structure for maintainability
- **Repository Pattern**: Abstracted data access layer
- **ValueNotifier State Management**: Lightweight, reactive state management
- **Dependency Injection**: Constructor-based dependency injection

## 🛠️ Development

### Code Style
- Follow Flutter/Dart conventions
- Use meaningful variable and function names
- Prefer composition over inheritance
- Write self-documenting code
- Use const constructors where possible

### Testing
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```

### Building for Production

**macOS:**
```bash
flutter build macos --release
```

**Windows:**
```bash
flutter build windows --release
```

**Linux:**
```bash
flutter build linux --release
```

**iOS:**
```bash
flutter build ios --release
```

**Android:**
```bash
flutter build apk --release
```

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Follow the existing code style and architecture
4. Write tests for new functionality
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Development Guidelines
- Follow the established architecture patterns
- Write comprehensive tests
- Update documentation for new features
- Ensure all tests pass before submitting
- Use meaningful commit messages

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support, feature requests, or bug reports:
- Open an issue on GitHub
- Check existing issues for similar problems
- Provide detailed information about your environment
- Include steps to reproduce any bugs

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- The open-source community for inspiration and libraries
- Contributors who help make MarkFlow better

---

**Built with ❤️ using Flutter**

*MarkFlow - Where markdown meets modern editing*