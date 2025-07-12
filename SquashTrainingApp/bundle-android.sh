#!/bin/bash

# Bash script to generate JavaScript bundle for Android
echo "📦 Generating JavaScript bundle for Android..."

# Create assets directory if it doesn't exist
ASSETS_DIR="android/app/src/main/assets"
if [ ! -d "$ASSETS_DIR" ]; then
    echo "📁 Creating assets directory..."
    mkdir -p "$ASSETS_DIR"
fi

# Remove old bundle if exists
BUNDLE_PATH="$ASSETS_DIR/index.android.bundle"
if [ -f "$BUNDLE_PATH" ]; then
    echo "🗑️ Removing old bundle..."
    rm -f "$BUNDLE_PATH"
fi

# Generate new bundle
echo "🚀 Building JavaScript bundle..."
npx react-native bundle \
    --platform android \
    --dev false \
    --entry-file index.js \
    --bundle-output android/app/src/main/assets/index.android.bundle \
    --assets-dest android/app/src/main/res/

if [ $? -eq 0 ]; then
    echo -e "\n✅ Bundle generated successfully!"
    echo "📍 Bundle location: $BUNDLE_PATH"
    
    # Get bundle size
    if [ -f "$BUNDLE_PATH" ]; then
        SIZE=$(du -h "$BUNDLE_PATH" | cut -f1)
        echo "📊 Bundle size: $SIZE"
    fi
    
    echo -e "\n💡 Next step: Build the APK with:"
    echo "   cd android"
    echo "   ./gradlew assembleDebug"
else
    echo -e "\n❌ Bundle generation failed!"
    exit 1
fi