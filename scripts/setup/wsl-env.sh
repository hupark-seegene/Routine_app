#!/bin/bash
# WSL environment setup for Windows Java and Android SDK

# Java home for Windows JDK (Eclipse Adoptium JDK 17)
export JAVA_HOME='/mnt/c/Program Files/Eclipse Adoptium/jdk-17.0.15.6-hotspot'
export PATH="$JAVA_HOME/bin:$PATH"

# Android SDK home
export ANDROID_HOME="/mnt/c/Users/hwpar/AppData/Local/Android/Sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools:$PATH"

echo "WSL environment configured:"
echo "JAVA_HOME: $JAVA_HOME"
echo "ANDROID_HOME: $ANDROID_HOME"