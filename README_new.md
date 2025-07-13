# Drinkmod

A Flutter mobile application designed to help users practice alcohol moderation through goal-setting, tracking, and positive reinforcement.

## Development Setup

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK (included with Flutter)
- Chrome browser (for web development)
- Android Studio / Xcode (for mobile development)

### Getting Started

1. **Clone the repository**
   ```bash
   git clone https://github.com/cjennison/drinkmod.git
   cd drinkmod
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code (database models, etc.)**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the app**
   ```bash
   # For web development (recommended for quick iteration)
   flutter run -d chrome
   
   # For Android
   flutter run -d android
   
   # For iOS
   flutter run -d ios
   ```

### Development Commands

You can use either direct Flutter commands or the provided Makefile shortcuts:

#### Using Flutter CLI (Standard)
```bash
# Development with hot reload
flutter run -d chrome                    # Web development
flutter run -d android                   # Android development
flutter run -d ios                       # iOS development

# Testing
flutter test                             # Run all tests
flutter test --watch                     # Run tests in watch mode

# Code maintenance
flutter analyze                          # Check for issues
dart format .                           # Format code
flutter clean && flutter pub get        # Clean and reinstall

# Building
flutter build web                        # Build for web
flutter build apk                        # Build Android APK
flutter build ios                        # Build iOS app
```

#### Using Makefile (Optional shortcuts)
```bash
make help                               # Show all available commands
make dev                                # Start web development
make test                               # Run tests
make clean                              # Clean and reinstall
make analyze                            # Analyze code
```

### Hot Reload

Flutter has hot reload built-in when using `flutter run`. During development:

- **Hot Reload**: Press `r` in the terminal to reload your changes instantly
- **Hot Restart**: Press `R` in the terminal to restart the app completely
- **Quit**: Press `q` to quit the development server

### Project Structure

```
lib/
├── core/                              # Core application code
│   ├── database/                      # Database models and setup
│   ├── theme/                         # App theming
│   ├── navigation/                    # App routing
│   └── utils/                         # Utility classes
├── features/                          # Feature-based modules
│   └── onboarding/                    # Onboarding flow
│       ├── screens/                   # UI screens
│       ├── widgets/                   # Reusable widgets
│       └── services/                  # Business logic
└── main.dart                          # App entry point

test/                                  # Test files
assets/                                # Static assets
└── scripts/                           # JSON conversation scripts
```

### Testing

Run tests with:
```bash
flutter test                           # Run all tests once
flutter test --watch                   # Run tests continuously
```

### Architecture

- **State Management**: BLoC pattern
- **Database**: Drift ORM with SQLite
- **Navigation**: go_router
- **UI**: Material Design 3
- **Platform Support**: Web, Android, iOS

### Contributing

1. Create a feature branch
2. Make your changes
3. Run tests: `flutter test`
4. Format code: `dart format .`
5. Analyze code: `flutter analyze`
6. Submit a pull request

## Stage Development Progress

- ✅ **Stage 1**: Foundation & Core Infrastructure
- 🚧 **Stage 2**: Onboarding & Initial Setup (In Progress)
- ⏳ **Stage 3**: Core Tracking & Control Panel
- ⏳ **Stage 4**: Streak Tracking & Basic Analytics
- ⏳ **Stage 5**: Milestone System & Rewards

See [`docs/PROJECT.md`](docs/PROJECT.md) for detailed development plan.
