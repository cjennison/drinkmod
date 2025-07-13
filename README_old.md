# Drinkmod - Development Guide

A Flutter application for alcohol moderation through goal-setting and tracking.

## Quick Start

### Development with Hot Reload

**Using npm scripts (recommended):**
```bash
# Start development server with hot reload (Chrome)
npm run dev

# Start for mobile development
npm run dev:mobile

# Start web server on localhost:3000
npm run dev:web
```

**Using shell script:**
```bash
# Chrome (default)
./scripts/dev.sh

# Web server
./scripts/dev.sh web

# Mobile platforms
./scripts/dev.sh android
./scripts/dev.sh ios
```

**Manual Flutter commands:**
```bash
# Chrome with hot reload
flutter run -d chrome --hot

# Web server with hot reload
flutter run -d web-server --web-port=3000 --hot

# Mobile with hot reload
flutter run --hot
```

### Hot Reload Commands

When the development server is running, you can use these commands in the terminal:

- **`r`** - Hot reload (rebuilds changed widgets)
- **`R`** - Hot restart (restarts the entire app)
- **`h`** - Show all available commands
- **`q`** - Quit the development server

### Other Development Commands

```bash
# Run tests
npm run test

# Run tests in watch mode
npm run test:watch

# Clean and rebuild
npm run clean

# Analyze code for issues
npm run analyze

# Format code
npm run format

# Generate code (database models, etc.)
npm run generate

# Generate code in watch mode
npm run generate:watch
```

### Build Commands

```bash
# Build for web
npm run build

# Build Android APK
npm run build:android

# Build iOS (requires macOS and Xcode)
npm run build:ios
```

## Hot Reload Features

With hot reload enabled, you can:

✅ **Modify UI instantly** - Change widgets, styling, and layouts
✅ **Update text and colors** - See changes immediately
✅ **Add new widgets** - Test new components live
✅ **Modify business logic** - Update functions and methods
✅ **Change conversation scripts** - Update JSON files (may require restart)

**Note:** Some changes require a hot restart (`R`):
- Adding new files
- Changing app structure
- Modifying database schemas
- Updating assets

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── core/                             # Core infrastructure
│   ├── database/                     # Database setup
│   ├── navigation/                   # App routing
│   ├── theme/                        # App theming
│   └── utils/                        # Utilities
└── features/                         # Feature modules
    └── onboarding/                   # Onboarding feature
        ├── screens/                  # UI screens
        ├── widgets/                  # UI components
        └── services/                 # Business logic

assets/
└── scripts/                          # JSON conversation scripts

test/                                 # Unit and widget tests
```

## Development Workflow

1. **Start development server:**
   ```bash
   npm run dev
   ```

2. **Make changes to code** - Files save automatically trigger hot reload

3. **Test changes** - Changes appear instantly in browser/emulator

4. **Use hot restart if needed** - Press `R` for full app restart

5. **Run tests** - Use `npm run test` to ensure quality

## Troubleshooting

**Hot reload not working?**
- Try hot restart with `R`
- Restart the development server
- Check for compilation errors in terminal

**Assets not updating?**
- Hot restart with `R` (assets require restart)
- Check assets are properly listed in `pubspec.yaml`

**Database changes not reflecting?**
- Run `npm run generate` to rebuild database code
- Hot restart with `R`

**Performance issues?**
- Use `flutter clean` and restart
- Check Chrome DevTools for performance insights
