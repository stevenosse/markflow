# Custom Window Implementation

This document describes the custom window implementation using the `bitsdojo_window` package for MarkFlow's desktop application.

## Overview

The application now features a custom window frame that replaces the standard macOS title bar with a custom-designed one that matches the app's theme and provides a more integrated user experience.

## Implementation Details

### Dependencies

- **bitsdojo_window**: ^0.1.6 - Provides custom window frame functionality for Flutter desktop apps

### Key Components

#### 1. Window Configuration (`main.dart`)

```dart
doWhenWindowReady(() {
  const initialSize = Size(1200, 800);
  appWindow.minSize = const Size(800, 600);
  appWindow.size = initialSize;
  appWindow.alignment = Alignment.center;
  appWindow.title = "MarkFlow";
  appWindow.show();
});
```

- Sets initial window size to 1200x800
- Minimum window size of 800x600
- Centers the window on screen
- Shows the window after configuration

#### 2. macOS Configuration (`MainFlutterWindow.swift`)

```swift
import bitsdojo_window_macos

class MainFlutterWindow: BitsdojoWindow {
  override func bitsdojo_window_configure() -> UInt {
    return BDW_CUSTOM_FRAME | BDW_HIDE_ON_STARTUP
  }
}
```

- Enables custom frame mode
- Hides window on startup (shown programmatically)
- Inherits from `BitsdojoWindow` instead of `NSWindow`

#### 3. Custom Window Frame (`WindowFrame` widget)

The `WindowFrame` widget provides:

- **Custom Title Bar**: 40px height with app title centered
- **Window Controls**: Minimize, maximize, and close buttons
- **Theme Integration**: Matches the app's color scheme
- **Draggable Area**: Entire title bar area for window movement

### Features

#### Title Bar
- Displays "MarkFlow" as the application title
- Themed background matching the app's surface color
- Bottom border for visual separation

#### Window Controls
- **Minimize Button**: Standard minimize functionality
- **Maximize Button**: Toggle between windowed and maximized states
- **Close Button**: Red hover state for clear close indication
- **Hover Effects**: Visual feedback on button interactions

#### Responsive Design
- Adapts to light and dark themes
- Proper color contrast for accessibility
- Smooth hover transitions

### Usage

The custom window frame is automatically applied to the entire application through the `Application` widget:

```dart
return WindowFrame(
  child: Shortcuts(
    // ... rest of the app
  ),
);
```

### Platform Support

Currently configured for:
- ✅ **macOS**: Fully implemented and tested
- ⚠️ **Windows**: Requires additional configuration in `windows/runner/main.cpp`
- ⚠️ **Linux**: Requires additional configuration in `linux/my_application.cc`

### Customization

To customize the window appearance:

1. **Title Bar Height**: Modify the `height` property in `WindowFrame`
2. **Window Controls**: Customize `WindowButtonColors` in `WindowButtons`
3. **Title Text**: Change the title text in the `WindowFrame` widget
4. **Initial Size**: Update values in `main.dart`'s `doWhenWindowReady` callback

### Benefits

1. **Consistent Branding**: Custom title bar matches app design
2. **Better UX**: Integrated window controls feel native to the app
3. **Theme Consistency**: Window frame adapts to light/dark themes
4. **Professional Appearance**: Modern, clean window design
5. **Cross-Platform**: Same experience across desktop platforms

### Notes

- The window is hidden on startup and shown programmatically for better control
- Custom frame removes the standard OS title bar completely
- Window controls maintain platform-appropriate behavior
- The implementation follows Flutter's widget composition patterns