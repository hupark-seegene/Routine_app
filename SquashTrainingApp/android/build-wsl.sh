#!/bin/bash
# Build script for WSL to use Windows gradle

# Change to the script directory
cd "$(dirname "$0")"

# Source the environment variables
source ./wsl-env.sh

echo "Starting Android build from WSL..."

# Use Windows gradlew.bat through PowerShell with JAVA_HOME
if [ "$1" = "clean" ]; then
    echo "Running clean build..."
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "\$env:JAVA_HOME = 'C:\\Program Files\\Eclipse Adoptium\\jdk-17.0.15.6-hotspot'; \$env:Path = \"\$env:JAVA_HOME\\bin;\$env:Path\"; .\\gradlew.bat clean assembleDebug"
else
    echo "Running assembleDebug..."
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "\$env:JAVA_HOME = 'C:\\Program Files\\Eclipse Adoptium\\jdk-17.0.15.6-hotspot'; \$env:Path = \"\$env:JAVA_HOME\\bin;\$env:Path\"; .\\gradlew.bat assembleDebug"
fi

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "Build completed successfully!"
    echo "APK location: app/build/outputs/apk/debug/app-debug.apk"
else
    echo "Build failed. Check the error messages above."
    exit 1
fi