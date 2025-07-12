#!/bin/bash

# WSL Environment setup for React Native development
# Sets Windows Java and Android SDK paths for WSL usage

# Windows Java JDK path (adjust username if different)
export JAVA_HOME="/mnt/c/Program Files/Eclipse Adoptium/jdk-17.0.15.6-hotspot"

# Windows Android SDK path
export ANDROID_HOME="/mnt/c/Users/hwpar/AppData/Local/Android/Sdk"

# Add to PATH
export PATH="$JAVA_HOME/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools:$PATH"

echo "✅ Environment variables set:"
echo "JAVA_HOME: $JAVA_HOME"
echo "ANDROID_HOME: $ANDROID_HOME"
echo ""
echo "📋 You can now run Android builds:"
echo "   cd android"
echo "   ./gradlew clean"
echo "   ./gradlew assembleDebug"