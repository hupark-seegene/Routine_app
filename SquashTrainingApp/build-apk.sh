#!/bin/bash
# Build APK for Squash Training App
# Created: 2025-07-22

echo "========================================"
echo "   Squash Training App - APK Builder"
echo "   Version: 2025.07.22"
echo "========================================"
echo ""

# Navigate to project directory
cd /mnt/c/Git/Routine_app/SquashTrainingApp

echo "📦 Creating JavaScript bundle..."
npx react-native bundle \
    --platform android \
    --dev false \
    --entry-file index.js \
    --bundle-output android/app/src/main/assets/index.android.bundle \
    --assets-dest android/app/src/main/res/

if [ $? -ne 0 ]; then
    echo "❌ Bundle creation failed!"
    exit 1
fi

echo "✅ Bundle created successfully"
echo ""

# Navigate to android directory
cd android

echo "🔨 Building APK..."
echo "This may take several minutes..."

# Clean build directories
./gradlew clean

# Build debug APK
./gradlew assembleDebug

if [ $? -ne 0 ]; then
    echo "❌ APK build failed!"
    exit 1
fi

echo ""
echo "✅ Build completed successfully!"
echo ""

# Copy APK to output directory
OUTPUT_DIR="../apk-output"
mkdir -p $OUTPUT_DIR

APK_PATH="app/build/outputs/apk/debug/app-debug.apk"
if [ -f "$APK_PATH" ]; then
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    NEW_NAME="SquashTrainingApp_${TIMESTAMP}.apk"
    cp $APK_PATH "$OUTPUT_DIR/$NEW_NAME"
    echo "📱 APK saved to: $OUTPUT_DIR/$NEW_NAME"
    echo "📊 APK size: $(du -h $APK_PATH | cut -f1)"
else
    echo "❌ APK file not found at expected location"
    exit 1
fi

echo ""
echo "🎉 Build process completed!"
echo "📍 APK location: $OUTPUT_DIR/$NEW_NAME"