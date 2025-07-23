# FIX-ALL-XML-KOREAN-TEXT.ps1
# Enhanced PowerShell script to fix Korean text in ALL Android layout files
# Created: 2025-07-23
# Category: FIX
# Description: Processes all discovered XML files with Korean text

param(
    [switch]$DryRun = $false,
    [switch]$Verbose = $false,
    [string]$BackupDir = "backup_all_xml_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
)

# Function to write log messages
function Write-LogMessage {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    Write-Host $logMessage
    
    # Also write to log file
    $logFile = "xml_all_fix_$(Get-Date -Format 'yyyyMMdd').log"
    Add-Content -Path $logFile -Value $logMessage
}

# Function to create backup
function Create-Backup {
    param([string]$SourceFile, [string]$BackupDirectory)
    
    try {
        if (-not (Test-Path $BackupDirectory)) {
            New-Item -ItemType Directory -Path $BackupDirectory -Force | Out-Null
            Write-LogMessage "Created backup directory: $BackupDirectory"
        }
        
        $relativePath = $SourceFile -replace [regex]::Escape((Get-Location).Path), ""
        $relativePath = $relativePath.TrimStart('\', '/')
        $backupPath = Join-Path $BackupDirectory $relativePath
        $backupDir = Split-Path $backupPath -Parent
        
        if (-not (Test-Path $backupDir)) {
            New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
        }
        
        Copy-Item -Path $SourceFile -Destination $backupPath -Force
        Write-LogMessage "Backed up: $SourceFile -> $backupPath"
        return $true
    }
    catch {
        Write-LogMessage "Error creating backup for $SourceFile : $($_.Exception.Message)" "ERROR"
        return $false
    }
}

# Function to validate XML structure
function Test-XmlStructure {
    param([string]$FilePath)
    
    try {
        [xml]$xmlContent = Get-Content -Path $FilePath -Encoding UTF8
        return $true
    }
    catch {
        Write-LogMessage "XML validation error in $FilePath : $($_.Exception.Message)" "ERROR"
        return $false
    }
}

# Function to fix encoding and replace Korean text
function Fix-XmlEncoding {
    param(
        [string]$FilePath,
        [hashtable]$Replacements
    )
    
    try {
        Write-LogMessage "Processing file: $FilePath"
        
        # Read file content as UTF-8
        $content = Get-Content -Path $FilePath -Encoding UTF8 -Raw
        $originalContent = $content
        $changesMade = $false
        
        # Apply all replacements
        foreach ($korean in $Replacements.Keys) {
            $english = $Replacements[$korean]
            if ($content.Contains($korean)) {
                $content = $content -replace [regex]::Escape($korean), $english
                $changesMade = $true
                Write-LogMessage "Replaced '$korean' with '$english' in $FilePath"
            }
        }
        
        # Fix XML declaration if needed
        if ($content -match '^\s*&lt;\?xml[^?]*\?&gt;') {
            $content = $content -replace '^\s*&lt;\?xml[^?]*\?&gt;', '<?xml version="1.0" encoding="utf-8"?>'
            $changesMade = $true
            Write-LogMessage "Fixed XML declaration in $FilePath"
        }
        
        # Ensure proper XML declaration exists
        if (-not ($content -match '^\s*<\?xml')) {
            $content = '<?xml version="1.0" encoding="utf-8"?>' + "`n" + $content
            $changesMade = $true
            Write-LogMessage "Added XML declaration to $FilePath"
        }
        
        if ($changesMade) {
            if (-not $DryRun) {
                # Write file with UTF-8 encoding without BOM
                $utf8NoBom = New-Object System.Text.UTF8Encoding $false
                [System.IO.File]::WriteAllText($FilePath, $content, $utf8NoBom)
                Write-LogMessage "Successfully updated $FilePath" "SUCCESS"
            } else {
                Write-LogMessage "DRY RUN: Would update $FilePath" "INFO"
            }
            
            return $true
        } else {
            Write-LogMessage "No changes needed for $FilePath"
            return $false
        }
    }
    catch {
        Write-LogMessage "Error processing $FilePath : $($_.Exception.Message)" "ERROR"
        return $false
    }
}

# Main execution
Write-LogMessage "Starting Enhanced XML Korean Text Fix Script" "INFO"
Write-LogMessage "Dry Run Mode: $DryRun" "INFO"

# Comprehensive Korean to English replacements
$koreanToEnglish = @{
    # Original request mappings
    "설정" = "Settings"
    "목표 설정" = "Goal Setting"
    "당신의 목표를 알려주세요" = "Tell us your goals"
    "AI 코치가 맞춤형 트레이닝 계획을 만들어드립니다" = "AI Coach will create a personalized training plan for you"
    "실력 수준" = "Skill Level"
    "초급 - 스쿼시를 처음 시작해요" = "Beginner - New to squash"
    "중급 - 기본기는 있지만 더 발전하고 싶어요" = "Intermediate - Have basics but want to improve"
    "상급 - 경쟁 수준의 실력을 갖추고 있어요" = "Advanced - Competitive level skills"
    "주요 목표" = "Primary Goal"
    "체력 향상 및 다이어트" = "Fitness improvement & diet"
    "기술 향상 및 폼 개선" = "Technique improvement & form"
    "대회 준비 및 경쟁력 향상" = "Competition preparation"
    "재미와 스트레스 해소" = "Fun and stress relief"
    "운동 빈도" = "Workout Frequency"
    "주 3회" = "3 times a week"
    "선호하는 운동 시간 (복수 선택 가능)" = "Preferred workout time (multiple choices)"
    "오전 (6시-12시)" = "Morning (6AM-12PM)"
    "오후 (12시-18시)" = "Afternoon (12PM-6PM)"
    "저녁 (18시-22시)" = "Evening (6PM-10PM)"
    "계속하기" = "Continue"
    
    # Additional common Korean terms found in the codebase
    "커스텀 운동" = "Custom Exercises"
    "운동 프로그램" = "Workout Programs"
    "AI 코치" = "AI Coach"
    "당신의 통계" = "Your Stats"
    "첫 운동" = "First Workout"
    "기술 조언" = "Technique Advice"
    "운동 제안" = "Workout Suggestion"
    "AI 코치에게 물어보기" = "Ask AI Coach"
    "AI 코치 채팅" = "AI Coach Chat"
    "안녕하세요! 저는 당신의 AI 스쿼시 코치입니다. 오늘 어떻게 도와드릴까요?" = "Hello! I'm your AI Squash Coach. How can I help you today?"
    "AI 설정" = "AI Settings"
    "설정됨" = "Configured"
    "설정 안 됨" = "Not Configured"
    
    # Additional UI elements
    "로그인" = "Login"
    "회원가입" = "Sign Up"
    "저장" = "Save"
    "취소" = "Cancel"
    "확인" = "Confirm"
    "삭제" = "Delete"
    "수정" = "Edit"
    "추가" = "Add"
    "검색" = "Search"
    "필터" = "Filter"
    "정렬" = "Sort"
    "목록" = "List"
    "상세" = "Details"
    "프로필" = "Profile"
    "사용자" = "User"
    "계정" = "Account"
    "비밀번호" = "Password"
    "이메일" = "Email"
    "이름" = "Name"
    "전화번호" = "Phone Number"
    "주소" = "Address"
    "생년월일" = "Date of Birth"
    "성별" = "Gender"
    "남성" = "Male"
    "여성" = "Female"
    "알림" = "Notifications"
    "메시지" = "Message"
    "채팅" = "Chat"
    "대화" = "Conversation"
    "질문" = "Question"
    "답변" = "Answer"
    "도움말" = "Help"
    "가이드" = "Guide"
    "튜토리얼" = "Tutorial"
    "시작하기" = "Get Started"
    "완료" = "Complete"
    "진행 중" = "In Progress"
    "대기 중" = "Waiting"
    "오류" = "Error"
    "성공" = "Success"
    "실패" = "Failed"
    "로딩" = "Loading"
    "새로고침" = "Refresh"
    "업데이트" = "Update"
    "다운로드" = "Download"
    "업로드" = "Upload"
    "공유" = "Share"
    "좋아요" = "Like"
    "싫어요" = "Dislike"
    "즐겨찾기" = "Favorite"
    "북마크" = "Bookmark"
    "구독" = "Subscribe"
    "팔로우" = "Follow"
    "언팔로우" = "Unfollow"
    "친구" = "Friend"
    "팀" = "Team"
    "그룹" = "Group"
    "커뮤니티" = "Community"
    "리더보드" = "Leaderboard"
    "랭킹" = "Ranking"
    "점수" = "Score"
    "레벨" = "Level"
    "경험치" = "Experience"
    "성취" = "Achievement"
    "뱃지" = "Badge"
    "보상" = "Reward"
    "포인트" = "Points"
    "코인" = "Coins"
    "크레딧" = "Credits"
    "구매" = "Purchase"
    "결제" = "Payment"
    "무료" = "Free"
    "유료" = "Paid"
    "프리미엄" = "Premium"
    "구독료" = "Subscription Fee"
    "할인" = "Discount"
    "쿠폰" = "Coupon"
}

# All XML files that were discovered to contain Korean text
$allFilesWithKorean = @(
    "android/app/src/main/res/layout/activity_profile.xml",
    "android/app/src/main/res/layout/activity_goal_setting.xml",
    "android/app/src/main/res/layout/dialog_exercise_details.xml",
    "android/app/src/main/res/layout/item_workout_program.xml",
    "android/app/src/main/res/layout/item_custom_exercise.xml",
    "android/app/src/main/res/layout/global_voice_overlay.xml",
    "android/app/src/main/res/layout/dialog_create_exercise.xml",
    "android/app/src/main/res/layout/activity_voice_record.xml",
    "android/app/src/main/res/layout/activity_voice_guided_workout.xml",
    "android/app/src/main/res/layout/activity_login.xml",
    "android/app/src/main/res/layout/activity_achievements.xml",
    "android/app/src/main/res/layout/activity_settings.xml",
    "android/app/src/main/res/layout/item_video_tutorial.xml",
    "android/app/src/main/res/layout/item_referral.xml",
    "android/app/src/main/res/layout/item_purchased_content.xml",
    "android/app/src/main/res/layout/item_onboarding_page.xml",
    "android/app/src/main/res/layout/item_marketplace_content.xml",
    "android/app/src/main/res/layout/item_creator_content.xml",
    "android/app/src/main/res/layout/item_challenge.xml",
    "android/app/src/main/res/layout/fragment_my_library.xml",
    "android/app/src/main/res/layout/fragment_my_content.xml",
    "android/app/src/main/res/layout/floating_voice_button.xml",
    "android/app/src/main/res/layout/dialog_premium_feature.xml",
    "android/app/src/main/res/layout/dialog_invite_friends.xml",
    "android/app/src/main/res/layout/banner_guest_mode.xml",
    "android/app/src/main/res/layout/dialog_content_filter.xml",
    "android/app/src/main/res/layout/activity_voice_assistant.xml",
    "android/app/src/main/res/layout/activity_subscription.xml",
    "android/app/src/main/res/layout/activity_splash.xml",
    "android/app/src/main/res/layout/activity_simple_placeholder.xml",
    "android/app/src/main/res/layout/activity_referral.xml",
    "android/app/src/main/res/layout/activity_premium_coach.xml",
    "android/app/src/main/res/layout/activity_onboarding.xml",
    "android/app/src/main/res/layout/activity_marketplace.xml",
    "android/app/src/main/res/layout/activity_leaderboard.xml",
    "android/app/src/main/res/layout/activity_edit_content.xml",
    "android/app/src/main/res/layout/activity_content_stats.xml",
    "android/app/src/main/res/layout/activity_create_content.xml",
    "android/app/src/main/res/layout/activity_content_detail.xml",
    "android/app/src/main/res/layout/activity_challenges.xml",
    "android/app/src/main/res/layout/activity_analytics_dashboard.xml",
    "android/app/src/main/res/layout/activity_video_tutorials.xml",
    "android/app/src/main/res/layout/item_achievement.xml",
    "android/app/src/main/res/layout/activity_custom_exercise.xml",
    "android/app/src/main/res/layout/activity_workout_program.xml"
)

Write-LogMessage "Total files to process: $($allFilesWithKorean.Count)"

# Process each target file
$successCount = 0
$errorCount = 0
$totalChanges = 0

foreach ($filePath in $allFilesWithKorean) {
    if (-not (Test-Path $filePath)) {
        Write-LogMessage "File not found: $filePath" "WARNING"
        continue
    }
    
    Write-LogMessage "Processing: $filePath"
    
    # Create backup
    if (-not $DryRun) {
        if (-not (Create-Backup -SourceFile $filePath -BackupDirectory $BackupDir)) {
            Write-LogMessage "Skipping $filePath due to backup failure" "ERROR"
            $errorCount++
            continue
        }
    }
    
    # Validate XML before processing
    if (-not (Test-XmlStructure -FilePath $filePath)) {
        Write-LogMessage "Skipping $filePath due to invalid XML structure" "ERROR"
        $errorCount++
        continue
    }
    
    # Fix encoding and replace Korean text
    if (Fix-XmlEncoding -FilePath $filePath -Replacements $koreanToEnglish) {
        $successCount++
        $totalChanges++
        
        # Validate XML after processing
        if (-not $DryRun -and -not (Test-XmlStructure -FilePath $filePath)) {
            Write-LogMessage "XML validation failed after processing $filePath" "ERROR"
            $errorCount++
        }
    }
}

# Summary
Write-LogMessage "=== PROCESSING COMPLETE ===" "INFO"
Write-LogMessage "Files processed successfully: $successCount" "INFO"
Write-LogMessage "Files with errors: $errorCount" "INFO"
Write-LogMessage "Total changes made: $totalChanges" "INFO"

if (-not $DryRun -and $successCount -gt 0) {
    Write-LogMessage "Backup directory: $BackupDir" "INFO"
    
    # Verify all processed files are still valid XML
    Write-LogMessage "Performing final XML validation..." "INFO"
    $validationErrors = 0
    
    foreach ($filePath in $allFilesWithKorean) {
        if (Test-Path $filePath) {
            if (-not (Test-XmlStructure -FilePath $filePath)) {
                $validationErrors++
                Write-LogMessage "Final validation failed for $filePath" "ERROR"
            }
        }
    }
    
    if ($validationErrors -eq 0) {
        Write-LogMessage "All XML files passed final validation!" "SUCCESS"
    } else {
        Write-LogMessage "$validationErrors files failed final validation" "ERROR"
    }
}

Write-LogMessage "Enhanced XML Korean Text Fix Script completed" "INFO"

# Return exit code
if ($errorCount -gt 0) {
    exit 1
} else {
    exit 0
}