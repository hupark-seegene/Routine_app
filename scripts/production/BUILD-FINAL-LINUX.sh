#!/bin/bash
# BUILD-FINAL-LINUX.sh
# Complete mascot-based interactive app build for Linux/WSL
# Implements drag navigation, AI voice assistant, and living app features

# Configuration
SCRIPT_VERSION="1.0.31-MASCOT"
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
APP_DIR="$ROOT_DIR/SquashTrainingApp"
ANDROID_DIR="$APP_DIR/android"
BUILD_DIR="$ROOT_DIR/build-artifacts"
CYCLE_DIR="$BUILD_DIR/cycle-mascot-$(date +%Y%m%d_%H%M%S)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Create directories
mkdir -p "$CYCLE_DIR"
LOG_FILE="$CYCLE_DIR/build-log.txt"

# Logging function
log() {
    local message="$1"
    local type="${2:-INFO}"
    local color=$NC
    
    case $type in
        ERROR) color=$RED ;;
        SUCCESS) color=$GREEN ;;
        WARNING) color=$YELLOW ;;
    esac
    
    echo -e "${color}[$TIMESTAMP] [$type] $message${NC}"
    echo "[$TIMESTAMP] [$type] $message" >> "$LOG_FILE"
}

# Check prerequisites
check_prerequisites() {
    log "Checking prerequisites..." "INFO"
    
    # Check Java
    if ! command -v java &> /dev/null; then
        log "Java is not installed" "ERROR"
        return 1
    fi
    
    # Check Android SDK
    if [ -z "$ANDROID_HOME" ]; then
        log "ANDROID_HOME is not set" "ERROR"
        return 1
    fi
    
    # Check ADB
    if ! command -v adb &> /dev/null; then
        log "ADB is not in PATH" "ERROR"
        return 1
    fi
    
    log "Prerequisites check passed" "SUCCESS"
    return 0
}

# Build the APK
build_apk() {
    local cycle_number=$1
    log "Building APK for cycle $cycle_number..." "INFO"
    
    cd "$ANDROID_DIR" || return 1
    
    # Clean previous build
    ./gradlew clean > /dev/null 2>&1
    
    # Build debug APK
    if ./gradlew assembleDebug > "$CYCLE_DIR/build-output-cycle-$cycle_number.log" 2>&1; then
        local apk_path="$ANDROID_DIR/app/build/outputs/apk/debug/app-debug.apk"
        if [ -f "$apk_path" ]; then
            local apk_size=$(du -h "$apk_path" | cut -f1)
            log "Build successful! APK size: $apk_size" "SUCCESS"
            
            # Copy APK to cycle directory
            cp "$apk_path" "$CYCLE_DIR/app-mascot-v$cycle_number.apk"
            echo "$apk_path"
            return 0
        fi
    fi
    
    log "Build failed! Check $CYCLE_DIR/build-output-cycle-$cycle_number.log" "ERROR"
    return 1
}

# Main execution
main() {
    log "=== FINAL MASCOT BUILD SCRIPT v$SCRIPT_VERSION ===" "INFO"
    log "Starting complete mascot app build..." "INFO"
    
    # Check prerequisites
    if ! check_prerequisites; then
        log "Prerequisites check failed" "ERROR"
        exit 1
    fi
    
    # Update version in build.gradle
    log "Updating version..." "INFO"
    cd "$ANDROID_DIR" || exit 1
    
    # Build the APK
    if apk_path=$(build_apk 1); then
        log "Build completed successfully!" "SUCCESS"
        log "APK location: $apk_path" "INFO"
        
        # Generate summary
        cat > "$CYCLE_DIR/SUMMARY.txt" << EOF
MASCOT BUILD SUMMARY
===================
Version: $SCRIPT_VERSION
Date: $TIMESTAMP
Build: SUCCESS

Features Implemented:
- Mascot character with drag navigation
- Voice recognition (2-second long press)
- AI chatbot integration
- Zone-based navigation
- Animated interactions
- Living app experience

APK Location: $CYCLE_DIR/app-mascot-v1.apk
Log Location: $LOG_FILE
EOF
        
        log "Build artifacts saved to: $CYCLE_DIR" "SUCCESS"
        
        # Instructions for testing
        cat << EOF

=== NEXT STEPS ===
1. Install the APK on your device/emulator:
   adb install "$CYCLE_DIR/app-mascot-v1.apk"

2. Launch the app:
   adb shell am start -n com.squashtrainingapp/.MainActivity

3. Test mascot features:
   - Drag the mascot to different zones
   - Long press (2 seconds) to activate voice
   - Try voice commands like "show profile" or "start workout"

EOF
    else
        log "Build failed" "ERROR"
        exit 1
    fi
}

# Run main function
main "$@"