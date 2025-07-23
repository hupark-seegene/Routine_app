#!/bin/bash
# fix-xml-encoding-issues.sh
# Bash equivalent of the PowerShell script for XML encoding fixes
# Created: 2025-07-23
# Category: FIX
# Description: Fixes Korean text encoding issues and replaces Korean text with English equivalents

set -e

# Default parameters
DRY_RUN=false
VERBOSE=false
BACKUP_DIR="backup_xml_$(date +%Y%m%d_%H%M%S)"
LOG_FILE="xml_encoding_fix_$(date +%Y%m%d).log"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --backup-dir)
            BACKUP_DIR="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Function to write log messages
log_message() {
    local message="$1"
    local level="${2:-INFO}"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_entry="[$timestamp] [$level] $message"
    
    echo "$log_entry"
    echo "$log_entry" >> "$LOG_FILE"
}

# Function to create backup
create_backup() {
    local source_file="$1"
    local backup_directory="$2"
    
    if [[ ! -d "$backup_directory" ]]; then
        mkdir -p "$backup_directory"
        log_message "Created backup directory: $backup_directory"
    fi
    
    local relative_path="${source_file#$(pwd)/}"
    local backup_path="$backup_directory/$relative_path"
    local backup_dir=$(dirname "$backup_path")
    
    mkdir -p "$backup_dir"
    cp "$source_file" "$backup_path"
    log_message "Backed up: $source_file -> $backup_path"
}

# Function to validate XML structure
validate_xml() {
    local file_path="$1"
    
    if xmllint --noout "$file_path" 2>/dev/null; then
        return 0
    else
        log_message "XML validation error in $file_path" "ERROR"
        return 1
    fi
}

# Function to fix encoding and replace Korean text
fix_xml_encoding() {
    local file_path="$1"
    local temp_file=$(mktemp)
    local changes_made=false
    
    log_message "Processing file: $file_path"
    
    # Copy original to temp file
    cp "$file_path" "$temp_file"
    
    # Define replacements (Korean -> English)
    declare -A replacements=(
        ["설정"]="Settings"
        ["목표 설정"]="Goal Setting"
        ["당신의 목표를 알려주세요"]="Tell us your goals"
        ["AI 코치가 맞춤형 트레이닝 계획을 만들어드립니다"]="AI Coach will create a personalized training plan for you"
        ["실력 수준"]="Skill Level"
        ["초급 - 스쿼시를 처음 시작해요"]="Beginner - New to squash"
        ["중급 - 기본기는 있지만 더 발전하고 싶어요"]="Intermediate - Have basics but want to improve"
        ["상급 - 경쟁 수준의 실력을 갖추고 있어요"]="Advanced - Competitive level skills"
        ["주요 목표"]="Primary Goal"
        ["체력 향상 및 다이어트"]="Fitness improvement & diet"
        ["기술 향상 및 폼 개선"]="Technique improvement & form"
        ["대회 준비 및 경쟁력 향상"]="Competition preparation"
        ["재미와 스트레스 해소"]="Fun and stress relief"
        ["운동 빈도"]="Workout Frequency"
        ["주 3회"]="3 times a week"
        ["선호하는 운동 시간 (복수 선택 가능)"]="Preferred workout time (multiple choices)"
        ["오전 (6시-12시)"]="Morning (6AM-12PM)"
        ["오후 (12시-18시)"]="Afternoon (12PM-6PM)"
        ["저녁 (18시-22시)"]="Evening (6PM-10PM)"
        ["계속하기"]="Continue"
    )
    
    # Apply replacements
    for korean in "${!replacements[@]}"; do
        english="${replacements[$korean]}"
        if grep -q "$korean" "$temp_file"; then
            sed -i "s|$korean|$english|g" "$temp_file"
            changes_made=true
            log_message "Replaced '$korean' with '$english' in $file_path"
        fi
    done
    
    # Ensure proper XML declaration
    if ! head -1 "$temp_file" | grep -q "<?xml"; then
        sed -i '1i<?xml version="1.0" encoding="utf-8"?>' "$temp_file"
        changes_made=true
        log_message "Added XML declaration to $file_path"
    fi
    
    if [[ "$changes_made" == true ]]; then
        if [[ "$DRY_RUN" == false ]]; then
            cp "$temp_file" "$file_path"
            log_message "Successfully updated $file_path" "SUCCESS"
        else
            log_message "DRY RUN: Would update $file_path" "INFO"
        fi
        rm "$temp_file"
        return 0
    else
        log_message "No changes needed for $file_path"
        rm "$temp_file"
        return 1
    fi
}

# Main execution
log_message "Starting XML Encoding Fix Script" "INFO"
log_message "Dry Run Mode: $DRY_RUN" "INFO"

# Target files
target_files=(
    "android/app/src/main/res/layout/activity_profile.xml"
    "android/app/src/main/res/layout/activity_goal_setting.xml"
)

# Discover all XML layout files with Korean text
log_message "Scanning for all XML layout files with Korean text..."

# Use a more comprehensive discovery method
mapfile -t discovered_files < <(find android/app/src/main/res/layout -name "*.xml" -type f 2>/dev/null || true)

for file in "${discovered_files[@]}"; do
    if [[ -f "$file" ]] && grep -q '[가-힣]' "$file" 2>/dev/null; then
        relative_path="${file#$(pwd)/}"
        # Check if not already in target_files
        if [[ ! " ${target_files[@]} " =~ " ${relative_path} " ]]; then
            target_files+=("$relative_path")
            log_message "Discovered file with Korean text: $relative_path"
        fi
    fi
done

log_message "Total files to process: ${#target_files[@]}"

# Process each target file
success_count=0
error_count=0
total_changes=0

for file_path in "${target_files[@]}"; do
    if [[ ! -f "$file_path" ]]; then
        log_message "File not found: $file_path" "WARNING"
        continue
    fi
    
    log_message "Processing: $file_path"
    
    # Create backup
    if [[ "$DRY_RUN" == false ]]; then
        if ! create_backup "$file_path" "$BACKUP_DIR"; then
            log_message "Skipping $file_path due to backup failure" "ERROR"
            ((error_count++))
            continue
        fi
    fi
    
    # Validate XML before processing (if xmllint is available)
    if command -v xmllint >/dev/null 2>&1; then
        if ! validate_xml "$file_path"; then
            log_message "Skipping $file_path due to invalid XML structure" "ERROR"
            ((error_count++))
            continue
        fi
    fi
    
    # Fix encoding and replace Korean text
    if fix_xml_encoding "$file_path"; then
        ((success_count++))
        ((total_changes++))
        
        # Validate XML after processing (if xmllint is available)
        if [[ "$DRY_RUN" == false ]] && command -v xmllint >/dev/null 2>&1; then
            if ! validate_xml "$file_path"; then
                log_message "XML validation failed after processing $file_path" "ERROR"
                ((error_count++))
            fi
        fi
    fi
done

# Summary
log_message "=== PROCESSING COMPLETE ===" "INFO"
log_message "Files processed successfully: $success_count" "INFO"
log_message "Files with errors: $error_count" "INFO"
log_message "Total changes made: $total_changes" "INFO"

if [[ "$DRY_RUN" == false ]] && [[ $success_count -gt 0 ]]; then
    log_message "Backup directory: $BACKUP_DIR" "INFO"
    
    # Verify all processed files are still valid XML (if xmllint is available)
    if command -v xmllint >/dev/null 2>&1; then
        log_message "Performing final XML validation..." "INFO"
        validation_errors=0
        
        for file_path in "${target_files[@]}"; do
            if [[ -f "$file_path" ]]; then
                if ! validate_xml "$file_path"; then
                    ((validation_errors++))
                    log_message "Final validation failed for $file_path" "ERROR"
                fi
            fi
        done
        
        if [[ $validation_errors -eq 0 ]]; then
            log_message "All XML files passed final validation!" "SUCCESS"
        else
            log_message "$validation_errors files failed final validation" "ERROR"
        fi
    fi
fi

log_message "XML Encoding Fix Script completed" "INFO"

# Return exit code
if [[ $error_count -gt 0 ]]; then
    exit 1
else
    exit 0
fi