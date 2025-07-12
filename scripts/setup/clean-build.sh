#!/bin/bash

# Bash script to clean all React Native build caches
echo "🧹 Starting complete React Native clean..."

# 1. Kill any running Metro bundler processes
echo -e "\n📦 Stopping Metro bundler..."
pkill -f "react-native.*metro" 2>/dev/null || true

# 2. Clear Metro bundler cache
echo -e "\n🗑️ Clearing Metro bundler cache..."
rm -rf $TMPDIR/metro-* 2>/dev/null || true
rm -rf $TMPDIR/react-* 2>/dev/null || true
rm -rf $TMPDIR/haste-* 2>/dev/null || true

# 3. Delete node_modules cache
echo -e "\n🗑️ Clearing node_modules cache..."
rm -rf node_modules/.cache

# 4. Clean Android build
echo -e "\n🤖 Cleaning Android build..."
rm -rf android/app/build
rm -rf android/build
rm -rf android/.gradle

# 5. Remove old JavaScript bundle
echo -e "\n📄 Removing old JavaScript bundle..."
rm -f android/app/src/main/assets/index.android.bundle

# 6. Clean watchman cache (if installed)
if command -v watchman &> /dev/null; then
    echo -e "\n👁️ Clearing watchman cache..."
    watchman watch-del-all 2>/dev/null || true
fi

# 7. Clean gradle cache from Windows side
echo -e "\n🏗️ Running gradle clean..."
cd android && ./gradlew clean && cd ..

echo -e "\n✅ Clean complete! Now you can rebuild:"
echo "   cd android"
echo "   ./gradlew assembleDebug"
echo -e "\n💡 Tip: Run Metro bundler separately with:"
echo "   npx react-native start"