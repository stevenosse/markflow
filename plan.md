# MarkFlow Development Plan

## Project Overview

MarkFlow is a Flutter-based desktop application for Markdown documentation management with Git integration. The project follows a clean architecture with custom state management and strict architectural principles.

## Current Status

✅ **Completed:**
- Flutter project structure with clean architecture
- Core infrastructure (routing, theming, i18n, dependency injection)
- Basic project scaffolding with proper folder structure
- Development tooling (Makefile, analysis options)

🔄 **In Progress:**
- Development planning and architecture refinement

## Development Phases

### Phase 1: MVP - Core Functionality (Weeks 1-8)

#### Week 1-2: Foundation & Architecture
- [ ] **Project Models & Data Layer**
  - Create project model (`Project`, `MarkdownFile`, `GitRepository`)
  - Implement file system repository for project management
  - Set up local storage for app settings
  - Create Git integration service (using `dart:io` for git commands)

- [ ] **Core State Management**
  - Implement project management notifier
  - Create file management notifier
  - Set up navigation state management

#### Week 3-4: Project Management
- [ ] **Project Setup & Onboarding**
  - Create project creation wizard
  - Implement "New Project" flow with Git repo initialization
  - Add "Clone Repository" functionality
  - Build project selection/recent projects screen

- [ ] **File Management Foundation**
  - Implement file system operations (create, rename, delete)
  - Create folder structure management
  - Set up file watching for external changes

#### Week 5-6: Markdown Editor Core
- [ ] **Basic Editor Implementation**
  - Integrate `flutter_markdown` for rendering
  - Create dual-pane editor layout (editor + preview)
  - Implement basic text editing with syntax highlighting
  - Add auto-save functionality

- [ ] **File Navigation**
  - Build sidebar file explorer tree
  - Implement file opening/switching
  - Add breadcrumb navigation

#### Week 7-8: Git Integration MVP
- [ ] **Basic Git Operations**
  - Implement staging and committing
  - Create "Changes" view for modified files
  - Add commit message input and commit functionality
  - Build basic push/pull operations

- [ ] **Git History**
  - Create simple commit history view
  - Implement basic diff viewing
  - Add branch switching (main/master)

### Phase 2: Enhanced Features (Weeks 9-16)

#### Week 9-10: Advanced Editor Features
- [ ] **Rich Markdown Support**
  - Enhance syntax highlighting
  - Add table editing assistance
  - Implement image drag-and-drop with auto-linking
  - Create markdown shortcuts and toolbar

- [ ] **Editor UX Improvements**
  - Add customizable themes (light/dark)
  - Implement spell checking
  - Create find/replace functionality
  - Add line numbers and code folding

#### Week 11-12: Enhanced Git Features
- [ ] **Advanced Git Operations**
  - Implement visual diff viewer (side-by-side)
  - Add file/commit revert functionality
  - Create stashing support
  - Build `.gitignore` management UI

- [ ] **Branch Management**
  - Add branch creation/deletion
  - Implement basic merging
  - Create branch switching UI
  - Add conflict resolution helpers

#### Week 13-14: Search & Navigation
- [ ] **Content Search**
  - Implement full-text search across project files
  - Add search result highlighting
  - Create search history and filters

- [ ] **Enhanced Navigation**
  - Add quick file switcher (Cmd+P style)
  - Implement bookmark/favorites system
  - Create document outline view

#### Week 15-16: Settings & Configuration
- [ ] **Application Settings**
  - Build settings screen with Git user configuration
  - Add editor preferences (font, theme, etc.)
  - Implement default remote repository settings
  - Create keyboard shortcuts customization

### Phase 3: Advanced Features (Weeks 17-24)

#### Week 17-18: Diagram Support
- [ ] **Mermaid Integration**
  - Add Mermaid diagram rendering in preview
  - Create diagram editing assistance
  - Implement diagram export functionality

#### Week 19-20: Export & Templates
- [ ] **Export Functionality**
  - Implement PDF export
  - Add HTML export with styling
  - Create batch export options

- [ ] **Template System**
  - Build template creation and management
  - Add common document templates
  - Implement template application to new files

#### Week 21-22: Advanced Git Features
- [ ] **Remote Management**
  - Support multiple remotes
  - Add SSH key management UI
  - Implement remote repository browsing

#### Week 23-24: Polish & Performance
- [ ] **Performance Optimization**
  - Optimize large file handling
  - Implement lazy loading for file trees
  - Add background operations for Git commands

- [ ] **UI/UX Polish**
  - Refine animations and transitions
  - Improve error handling and user feedback
  - Add comprehensive keyboard shortcuts

## Technical Architecture

### State Management Strategy
- **ValueNotifier-based controllers** for feature-specific state
- **Repository pattern** for data access
- **Dependency injection** via GetIt
- **Unidirectional data flow** with parent-managed state

### Key Dependencies
```yaml
# Core
flutter_markdown: ^0.6.18
path_provider: ^2.1.1
file_picker: ^6.1.1

# Git Integration
process: ^5.0.0  # For git command execution

# Editor
code_text_field: ^1.1.0  # For syntax highlighting
flutter_highlight: ^0.7.0

# Export
pdf: ^3.10.7
html: ^0.15.4

# Diagrams
mermaid: ^0.1.0  # If available, or web view integration
```

### Folder Structure
```
lib/src/
├── core/
│   ├── theme/dimens.dart          # All UI dimensions
│   ├── i18n/                      # Internationalization
│   └── services/
│       ├── git_service.dart       # Git operations
│       ├── file_service.dart      # File system operations
│       └── export_service.dart    # Export functionality
├── datasource/
│   ├── models/
│   │   ├── project.dart
│   │   ├── markdown_file.dart
│   │   └── git_models.dart
│   └── repositories/
│       ├── project_repository.dart
│       ├── file_repository.dart
│       └── git_repository.dart
├── features/
│   ├── project_management/
│   │   ├── ui/
│   │   │   ├── project_selection_screen.dart
│   │   │   ├── new_project_wizard.dart
│   │   │   └── widgets/
│   │   └── logic/
│   │       ├── project_notifier.dart
│   │       └── project_state.dart
│   ├── editor/
│   │   ├── ui/
│   │   │   ├── editor_screen.dart
│   │   │   ├── markdown_editor.dart
│   │   │   ├── preview_pane.dart
│   │   │   └── widgets/
│   │   └── logic/
│   │       ├── editor_notifier.dart
│   │       └── editor_state.dart
│   ├── file_explorer/
│   ├── git_integration/
│   └── settings/
└── shared/
    ├── components/
    │   ├── file_tree/
    │   ├── diff_viewer/
    │   └── markdown_toolbar/
    └── utils/
        ├── git_utils.dart
        ├── markdown_utils.dart
        └── file_utils.dart
```

## Progress Tracking

### Completed Tasks
- [x] Initial project setup and architecture
- [x] Development plan creation

### Current Sprint Goals
- [ ] Project models and data layer implementation
- [ ] Core state management setup
- [ ] Git service foundation

### Next Milestones
1. **Week 2 Goal**: Complete foundation and start project management
2. **Week 4 Goal**: Working project creation and file management
3. **Week 6 Goal**: Basic markdown editor with preview
4. **Week 8 Goal**: MVP with basic Git integration

## Risk Mitigation

### Technical Risks
- **Git Integration Complexity**: Start with simple command-line git operations, expand gradually
- **Performance with Large Files**: Implement streaming and lazy loading early
- **Cross-platform Compatibility**: Test on all target platforms regularly

### Development Risks
- **Scope Creep**: Stick to MVP features first, document enhancement ideas for later phases
- **Architecture Complexity**: Keep state management simple, avoid over-engineering

## Success Metrics

### Phase 1 (MVP)
- [ ] Can create and manage markdown projects
- [ ] Basic editing with live preview works
- [ ] Git operations (commit, push, pull) function correctly
- [ ] File management (create, edit, delete) works reliably

### Phase 2 (Enhanced)
- [ ] Advanced editor features improve productivity
- [ ] Git workflow supports typical development patterns
- [ ] Search and navigation features work efficiently

### Phase 3 (Advanced)
- [ ] Export features produce high-quality output
- [ ] Template system speeds up document creation
- [ ] Performance remains smooth with large projects

---

**Last Updated**: Initial Plan Creation
**Next Review**: After Week 2 completion