#!/bin/bash
# fix-all-xml-korean-text.sh
# Enhanced bash script to fix Korean text in ALL Android layout files
# Created: 2025-07-23
# Category: FIX
# Description: Processes all discovered XML files with Korean text

set -e

# Default parameters
DRY_RUN=false
VERBOSE=false
BACKUP_DIR="backup_all_xml_$(date +%Y%m%d_%H%M%S)"
LOG_FILE="xml_all_fix_$(date +%Y%m%d).log"

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
    
    if command -v xmllint >/dev/null 2>&1; then
        if xmllint --noout "$file_path" 2>/dev/null; then
            return 0
        else
            log_message "XML validation error in $file_path" "ERROR"
            return 1
        fi
    else
        # If xmllint not available, just return success
        return 0
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
    
    # Define comprehensive replacements (Korean -> English)
    declare -A replacements=(
        # Original request mappings
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
        
        # Additional common terms
        ["커스텀 운동"]="Custom Exercises"
        ["운동 프로그램"]="Workout Programs"
        ["AI 코치"]="AI Coach"
        ["당신의 통계"]="Your Stats"
        ["첫 운동"]="First Workout"
        ["기술 조언"]="Technique Advice"
        ["운동 제안"]="Workout Suggestion"
        ["AI 코치에게 물어보기"]="Ask AI Coach"
        ["AI 코치 채팅"]="AI Coach Chat"
        ["AI 설정"]="AI Settings"
        ["설정됨"]="Configured"
        ["설정 안 됨"]="Not Configured"
        
        # Common UI elements
        ["로그인"]="Login"
        ["회원가입"]="Sign Up"
        ["저장"]="Save"
        ["취소"]="Cancel"
        ["확인"]="Confirm"
        ["삭제"]="Delete"
        ["수정"]="Edit"
        ["추가"]="Add"
        ["검색"]="Search"
        ["필터"]="Filter"
        ["정렬"]="Sort"
        ["목록"]="List"
        ["상세"]="Details"
        ["프로필"]="Profile"
        ["사용자"]="User"
        ["계정"]="Account"
        ["비밀번호"]="Password"
        ["이메일"]="Email"
        ["이름"]="Name"
        ["알림"]="Notifications"
        ["메시지"]="Message"
        ["채팅"]="Chat"
        ["질문"]="Question"
        ["답변"]="Answer"
        ["도움말"]="Help"
        ["가이드"]="Guide"
        ["튜토리얼"]="Tutorial"
        ["시작하기"]="Get Started"
        ["완료"]="Complete"
        ["진행 중"]="In Progress"
        ["오류"]="Error"
        ["성공"]="Success"
        ["실패"]="Failed"
        ["로딩"]="Loading"
        ["업데이트"]="Update"
        ["공유"]="Share"
        ["좋아요"]="Like"
        ["즐겨찾기"]="Favorite"
        ["구독"]="Subscribe"
        ["팀"]="Team"
        ["그룹"]="Group"
        ["점수"]="Score"
        ["레벨"]="Level"
        ["경험치"]="Experience"
        ["성취"]="Achievement"
        ["보상"]="Reward"
        ["포인트"]="Points"
        ["구매"]="Purchase"
        ["무료"]="Free"
        ["유료"]="Paid"
        ["프리미엄"]="Premium"
    )
    
    # Apply replacements
    for korean in "${!replacements[@]}"; do
        english="${replacements[$korean]}"
        if grep -Fq "$korean" "$temp_file"; then
            sed -i "s|$(printf '%s\n' "$korean" | sed 's/[][\.*^$()+?{|}/]/\\&/g')|$english|g" "$temp_file"
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
log_message "Starting Enhanced XML Korean Text Fix Script" "INFO"
log_message "Dry Run Mode: $DRY_RUN" "INFO"

# All XML files that were discovered to contain Korean text
all_files_with_korean=(
    "android/app/src/main/res/layout/activity_profile.xml"
    "android/app/src/main/res/layout/activity_goal_setting.xml"
    "android/app/src/main/res/layout/dialog_exercise_details.xml"
    "android/app/src/main/res/layout/item_workout_program.xml"
    "android/app/src/main/res/layout/item_custom_exercise.xml"
    "android/app/src/main/res/layout/global_voice_overlay.xml"
    "android/app/src/main/res/layout/dialog_create_exercise.xml"
    "android/app/src/main/res/layout/activity_voice_record.xml"
    "android/app/src/main/res/layout/activity_voice_guided_workout.xml"
    "android/app/src/main/res/layout/activity_login.xml"
    "android/app/src/main/res/layout/activity_achievements.xml"
    "android/app/src/main/res/layout/activity_settings.xml"
    "android/app/src/main/res/layout/item_video_tutorial.xml"
    "android/app/src/main/res/layout/item_referral.xml"
    "android/app/src/main/res/layout/item_purchased_content.xml"
    "android/app/src/main/res/layout/item_onboarding_page.xml"
    "android/app/src/main/res/layout/item_marketplace_content.xml"
    "android/app/src/main/res/layout/item_creator_content.xml"
    "android/app/src/main/res/layout/item_challenge.xml"
    "android/app/src/main/res/layout/fragment_my_library.xml"
    "android/app/src/main/res/layout/fragment_my_content.xml"
    "android/app/src/main/res/layout/floating_voice_button.xml"
    "android/app/src/main/res/layout/dialog_premium_feature.xml"
    "android/app/src/main/res/layout/dialog_invite_friends.xml"
    "android/app/src/main/res/layout/banner_guest_mode.xml"
    "android/app/src/main/res/layout/dialog_content_filter.xml"
    "android/app/src/main/res/layout/activity_voice_assistant.xml"
    "android/app/src/main/res/layout/activity_subscription.xml"
    "android/app/src/main/res/layout/activity_splash.xml"
    "android/app/src/main/res/layout/activity_simple_placeholder.xml"
    "android/app/src/main/res/layout/activity_referral.xml"
    "android/app/src/main/res/layout/activity_premium_coach.xml"
    "android/app/src/main/res/layout/activity_onboarding.xml"
    "android/app/src/main/res/layout/activity_marketplace.xml"
    "android/app/src/main/res/layout/activity_leaderboard.xml"
    "android/app/src/main/res/layout/activity_edit_content.xml"
    "android/app/src/main/res/layout/activity_content_stats.xml"
    "android/app/src/main/res/layout/activity_create_content.xml"
    "android/app/src/main/res/layout/activity_content_detail.xml"
    "android/app/src/main/res/layout/activity_challenges.xml"
    "android/app/src/main/res/layout/activity_analytics_dashboard.xml"
    "android/app/src/main/res/layout/activity_video_tutorials.xml"
    "android/app/src/main/res/layout/item_achievement.xml"
    "android/app/src/main/res/layout/activity_custom_exercise.xml"
    "android/app/src/main/res/layout/activity_workout_program.xml"
)

log_message "Total files to process: ${#all_files_with_korean[@]}"

# Process each target file
success_count=0
error_count=0
total_changes=0

for file_path in "${all_files_with_korean[@]}"; do
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
    if ! validate_xml "$file_path"; then
        log_message "Skipping $file_path due to invalid XML structure" "ERROR"
        ((error_count++))
        continue
    fi
    
    # Fix encoding and replace Korean text
    if fix_xml_encoding "$file_path"; then
        ((success_count++))
        ((total_changes++))
        
        # Validate XML after processing (if xmllint is available)
        if [[ "$DRY_RUN" == false ]] && ! validate_xml "$file_path"; then
            log_message "XML validation failed after processing $file_path" "ERROR"
            ((error_count++))
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
        
        for file_path in "${all_files_with_korean[@]}"; do
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

log_message "Enhanced XML Korean Text Fix Script completed" "INFO"

# Return exit code
if [[ $error_count -gt 0 ]]; then
    exit 1
else
    exit 0
fi