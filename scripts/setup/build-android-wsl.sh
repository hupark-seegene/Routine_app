#!/bin/bash
# Build Android app from WSL using Windows Java and Android SDK

# Set environment variables for Windows Java and Android SDK
export JAVA_HOME="/mnt/c/Program Files/Eclipse Adoptium/jdk-17.0.15.6-hotspot"
export ANDROID_HOME="/mnt/c/Users/hwpar/AppData/Local/Android/Sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$JAVA_HOME/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools:$PATH"

# Check if Java is accessible
if [ -f "$JAVA_HOME/bin/java.exe" ]; then
    echo "✓ Java found at: $JAVA_HOME"
else
    echo "✗ Java not found at: $JAVA_HOME"
    exit 1
fi

# Check if Android SDK is accessible
if [ -d "$ANDROID_HOME" ]; then
    echo "✓ Android SDK found at: $ANDROID_HOME"
else
    echo "✗ Android SDK not found at: $ANDROID_HOME"
    exit 1
fi

# Navigate to android directory
cd android

# Run the build
echo "Starting Android build..."
./gradlew assembleDebug

if [ $? -eq 0 ]; then
    echo "✓ Build successful!"
    echo "APK location: android/app/build/outputs/apk/debug/app-debug.apk"
else
    echo "✗ Build failed"
    exit 1
fi