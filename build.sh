#!/bin/bash

# Exit on any error
set -e

echo "🚀 Starting Kanso build process..."

# Install Flutter
echo "📦 Installing Flutter..."

# Download and install Flutter
wget -O flutter_linux.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.35.4-stable.tar.xz
tar xf flutter_linux.tar.xz
export PATH="$PATH:$(pwd)/flutter/bin"

# Verify Flutter installation
flutter --version

# Enable web support
flutter config --enable-web

# Get dependencies
echo "📚 Getting Flutter dependencies..."
flutter pub get

# Build for web
echo "🔨 Building Flutter web app..."
flutter build web --release

echo "✅ Build completed successfully!"
echo "📁 Build output directory:"
ls -la build/web/
