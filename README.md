# Kanso - Simplicity in Living

A minimalist decluttering app inspired by Japanese Zen rock gardens (Karesansui). Built with Flutter for iOS and Android.

## Design Philosophy

Kanso follows the Japanese aesthetic principle of "simplicity" - using only essential elements to create a clean, focused experience. The app uses a strict grayscale palette and geometric forms inspired by the flowing lines and concentric ripples found in Zen rock gardens.

## Features

### Core Functionality
- **Sign Up/Login**: Simple authentication with email and password
- **Home Dashboard**: Welcome screen with user stats and session management
- **Declutter Setup**: Add and manage items for decluttering
- **Declutter Process**: Tinder-style swipe interface for decision making
- **Summary**: Review kept vs. discarded items with photo upload capability
- **Memory Archive**: Grid/list view of all discarded items with timestamps
- **Account Management**: User profile, statistics, and language settings

### Design System
- **Color Palette**: 5 grayscale shades only (#000000, #333333, #777777, #BBBBBB, #FFFFFF)
- **Typography**: Clean sans-serif fonts (SF Pro Display/Text)
- **Layout**: Grid-based with generous whitespace
- **Components**: Flat, geometric, no shadows or gradients
- **Animations**: Subtle ripple effects inspired by Karesansui

## Technical Stack

- **Framework**: Flutter 3.0+
- **State Management**: Provider
- **Local Storage**: SQLite (via sqflite)
- **Image Handling**: image_picker
- **Preferences**: shared_preferences
- **Internationalization**: intl

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── theme/
│   └── app_theme.dart       # Design system and theme
├── models/
│   ├── user.dart            # User data model
│   └── declutter_item.dart  # Item data model
├── services/
│   └── app_state.dart       # State management
├── screens/
│   ├── splash_screen.dart   # App launch screen
│   ├── auth/
│   │   └── login_screen.dart
│   ├── home_screen.dart     # Dashboard
│   ├── declutter/
│   │   ├── declutter_setup_screen.dart
│   │   └── declutter_process_screen.dart
│   ├── summary_screen.dart  # Session results
│   ├── memory_screen.dart   # Archive view
│   ├── account_screen.dart  # User settings
│   └── main_navigation.dart # Bottom navigation
└── widgets/                 # Reusable components
```

## Getting Started

1. Ensure Flutter is installed and configured
2. Clone the repository
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the app

## Key Design Elements

### Karesansui-Inspired Logo
The app features a custom-drawn ripple animation that mimics the concentric patterns found in Japanese rock gardens, created using Flutter's CustomPainter.

### Minimalist Navigation
Bottom navigation with essential icons only - no decorative elements, just functional symbols.

### Swipe Interface
The declutter process uses a Tinder-style swipe mechanism where users swipe right to keep items and left to let them go, with smooth animations and haptic feedback.

### Clean Typography
Uses system fonts (SF Pro on iOS) with careful weight and spacing to create clear hierarchy without visual clutter.

## Future Enhancements

- Chinese language support
- Photo capture for discarded items
- AI suggestions for decluttering decisions
- Export functionality for memory archive
- Cloud sync capabilities
- Advanced analytics and insights

## License

This project is created for demonstration purposes. All rights reserved.
