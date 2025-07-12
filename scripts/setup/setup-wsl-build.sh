#!/bin/bash
# Setup script for building React Native app in WSL using Windows Java/Android SDK

echo "========================================="
echo " WSL Build Environment Setup"
echo " for React Native Android"
echo "========================================="
echo ""

# Check if running in WSL
if ! grep -q Microsoft /proc/version; then
    echo "⚠️  This script is designed for WSL. Exiting..."
    exit 1
fi

# Windows paths
WIN_JAVA_HOME="/mnt/c/Program Files/Eclipse Adoptium/jdk-17.0.15.6-hotspot"
WIN_ANDROID_HOME="/mnt/c/Users/hwpar/AppData/Local/Android/Sdk"

# Check if Java exists
if [ ! -f "$WIN_JAVA_HOME/bin/java.exe" ]; then
    echo "❌ Windows Java not found at: $WIN_JAVA_HOME"
    echo "   Please install Java 17 on Windows first."
    exit 1
fi

# Check if Android SDK exists
if [ ! -d "$WIN_ANDROID_HOME" ]; then
    echo "❌ Windows Android SDK not found at: $WIN_ANDROID_HOME"
    echo "   Please install Android SDK on Windows first."
    exit 1
fi

echo "✅ Found Windows Java at: $WIN_JAVA_HOME"
echo "✅ Found Windows Android SDK at: $WIN_ANDROID_HOME"
echo ""

# Create or update .bashrc.react-native
cat > ~/.bashrc.react-native << EOF
# React Native build environment for WSL
export JAVA_HOME="$WIN_JAVA_HOME"
export ANDROID_HOME="$WIN_ANDROID_HOME"
export PATH="\$JAVA_HOME/bin:\$ANDROID_HOME/platform-tools:\$ANDROID_HOME/tools:\$PATH"

# Alias for easier building
alias rn-build="npx react-native build-android --mode=debug"
alias rn-clean="cd android && ./gradlew clean && cd .."
EOF

echo "Environment configuration saved to ~/.bashrc.react-native"
echo ""

# Check if already in .bashrc
if ! grep -q "bashrc.react-native" ~/.bashrc; then
    echo "" >> ~/.bashrc
    echo "# React Native build environment" >> ~/.bashrc
    echo "[ -f ~/.bashrc.react-native ] && source ~/.bashrc.react-native" >> ~/.bashrc
    echo "✅ Added to ~/.bashrc"
else
    echo "✅ Already configured in ~/.bashrc"
fi

echo ""
echo "========================================="
echo " Setup Complete!"
echo "========================================="
echo ""
echo "To activate the environment:"
echo "  source ~/.bashrc"
echo ""
echo "To build the app:"
echo "  cd /mnt/c/Git/Routine_app/SquashTrainingApp"
echo "  npx react-native build-android --mode=debug"
echo ""
echo "Or use the alias:"
echo "  rn-build"
echo ""
echo "⚠️  Note: Building from WSL may be slower than PowerShell"
echo "   due to filesystem translation overhead."
echo ""