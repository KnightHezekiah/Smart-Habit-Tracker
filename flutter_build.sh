#!/bin/bash

# Exit on error
set -e

echo "Starting Flutter web build process..."

# Check if Flutter SDK is available, use local or install if needed
if ! command -v flutter &> /dev/null; then
  echo "Flutter SDK not found, installing..."
  git clone https://github.com/flutter/flutter.git -b stable flutter_sdk
  export PATH="$PATH:$(pwd)/flutter_sdk/bin"
  flutter precache
else
  echo "Flutter SDK found, continuing with build"
fi

# Make sure Flutter is up to date
flutter --version
flutter upgrade

# Enable web support
flutter config --enable-web

# Fetch dependencies
echo "Fetching dependencies..."
flutter pub get

# Build for web
echo "Building Flutter web application..."
flutter build web --release

# Copy build output to web directory
echo "Copying build output to web directory..."
mkdir -p web
cp -R build/web/* web/

echo "Flutter web build completed successfully!"