#!/bin/bash

# Drinkmod Development Server with Hot Reload
# Usage: ./scripts/dev.sh [platform]
# Platforms: web, android, ios, chrome

PLATFORM=${1:-chrome}

echo "🚀 Starting Drinkmod development server..."
echo "📱 Platform: $PLATFORM"
echo "🔥 Hot reload: ENABLED"
echo ""

case $PLATFORM in
  "web")
    echo "🌐 Starting web server on http://localhost:3000"
    flutter run -d web-server --web-port=3000 --hot
    ;;
  "chrome")
    echo "🌐 Starting Chrome browser"
    flutter run -d chrome --hot
    ;;
  "android")
    echo "📱 Starting Android emulator/device"
    flutter run --hot
    ;;
  "ios")
    echo "📱 Starting iOS simulator"
    flutter run -d ios --hot
    ;;
  *)
    echo "❌ Unknown platform: $PLATFORM"
    echo "Available platforms: web, chrome, android, ios"
    exit 1
    ;;
esac
