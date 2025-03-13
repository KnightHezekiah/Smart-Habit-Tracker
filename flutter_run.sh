#!/bin/bash

# Exit on error
set -e

echo "Starting Flutter web development server..."

# Check if Flutter SDK is available, use local or install if needed
if ! command -v flutter &> /dev/null; then
  echo "Flutter SDK not found, installing..."
  git clone https://github.com/flutter/flutter.git -b stable flutter_sdk
  export PATH="$PATH:$(pwd)/flutter_sdk/bin"
  flutter precache
else
  echo "Flutter SDK found, continuing with run"
fi

# Enable web support
flutter config --enable-web

# Fetch dependencies
echo "Fetching dependencies..."
flutter pub get

# Run Flutter for web
echo "Running Flutter web application in debug mode..."
flutter run -d web-server --web-port 8080