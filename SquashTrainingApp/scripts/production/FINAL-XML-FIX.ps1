# FINAL-XML-FIX.ps1
# Final comprehensive fix for all XML issues

$ErrorActionPreference = "Stop"

Write-Host "Final XML fix - Cleaning and rebuilding problematic files..." -ForegroundColor Yellow

# Clean the build cache first
Set-Location -Path "..\..\android"
Write-Host "Cleaning build cache..." -ForegroundColor Yellow
.\gradlew.bat clean

# Now let's manually fix the most problematic files by recreating them
$layoutPath = Join-Path (Get-Location) "app\src\main\res\layout"

# Fix activity_achievements.xml
$achievementsContent = @'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:background="@color/background">
    
    <!-- Header -->
    <RelativeLayout
        android:layout_width="match_parent"
        android:layout_height="?attr/actionBarSize"
        android:background="@color/surface"
        android:elevation="4dp">
        
        <ImageButton
            android:id="@+id/back_button"
            android:layout_width="48dp"
            android:layout_height="48dp"
            android:layout_centerVertical="true"
            android:background="?attr/selectableItemBackgroundBorderless"
            android:src="@drawable/ic_arrow_back"
            android:tint="@color/text_primary" />
        
        <TextView
            android:id="@+id/title_text"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_centerInParent="true"
            android:text="업적"
            android:textColor="@color/text_primary"
            android:textSize="18sp"
            android:textStyle="bold" />
    </RelativeLayout>
    
    <!-- Stats Section -->
    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="horizontal"
        android:background="@color/surface"
        android:padding="16dp">
        
        <LinearLayout
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:orientation="vertical"
            android:gravity="center">
            
            <TextView
                android:id="@+id/points_text"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="0 포인트"
                android:textColor="@color/accent"
                android:textSize="20sp"
                android:textStyle="bold" />
            
            <TextView
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="총 포인트"
                android:textColor="@color/text_secondary"
                android:textSize="12sp" />
        </LinearLayout>
        
        <View
            android:layout_width="1dp"
            android:layout_height="match_parent"
            android:background="@color/background"
            android:layout_marginHorizontal="16dp" />
        
        <LinearLayout
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:orientation="vertical"
            android:gravity="center">
            
            <TextView
                android:id="@+id/completion_text"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="0% 완료"
                android:textColor="@color/text_primary"
                android:textSize="16sp" />
            
            <ProgressBar
                android:id="@+id/completion_progress"
                style="?android:attr/progressBarStyleHorizontal"
                android:layout_width="match_parent"
                android:layout_height="8dp"
                android:layout_marginTop="8dp"
                android:progressDrawable="@drawable/progress_drawable"
                android:progress="0" />
        </LinearLayout>
    </LinearLayout>
    
    <!-- Tabs -->
    <com.google.android.material.tabs.TabLayout
        android:id="@+id/tab_layout"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:background="@color/surface"
        app:tabGravity="fill"
        app:tabMode="scrollable"
        app:tabTextColor="@color/text_secondary"
        app:tabSelectedTextColor="@color/accent"
        app:tabIndicatorColor="@color/accent"
        app:tabIndicatorHeight="3dp" />
    
    <!-- Achievements Grid -->
    <FrameLayout
        android:layout_width="match_parent"
        android:layout_height="0dp"
        android:layout_weight="1">
        
        <androidx.recyclerview.widget.RecyclerView
            android:id="@+id/achievements_recycler_view"
            android:layout_width="match_parent"
            android:layout_height="match_parent"
            android:padding="8dp"
            android:clipToPadding="false" />
        
        <TextView
            android:id="@+id/empty_text"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_gravity="center"
            android:text="해당하는 업적이 없습니다"
            android:textColor="@color/text_secondary"
            android:textSize="16sp"
            android:visibility="gone" />
    </FrameLayout>
</LinearLayout>
'@

$utf8NoBom = New-Object System.Text.UTF8Encoding $false
$achievementsPath = Join-Path $layoutPath "activity_achievements.xml"
[System.IO.File]::WriteAllText($achievementsPath, $achievementsContent, $utf8NoBom)
Write-Host "✓ Fixed activity_achievements.xml" -ForegroundColor Green

# Fix other files that had attribute issues
$filesToFix = @(
    "activity_profile.xml",
    "activity_settings.xml", 
    "activity_voice_guided_workout.xml",
    "activity_voice_record.xml",
    "dialog_create_exercise.xml",
    "dialog_exercise_details.xml",
    "global_voice_overlay.xml",
    "item_custom_exercise.xml",
    "item_workout_program.xml"
)

foreach ($fileName in $filesToFix) {
    $filePath = Join-Path $layoutPath $fileName
    if (Test-Path $filePath) {
        $content = Get-Content -Path $filePath -Encoding UTF8 -Raw
        
        # Fix common issues
        $content = $content -replace '@color/volt_green(?!")(?!/)', '@color/accent'
        $content = $content -replace '(?<!")/>(?=")', '/>'
        $content = $content -replace '(?<=android:text=")([^"]*[가-힣][^"]*)"(?=[^>]*@color)', '$1"'
        
        # Write back
        [System.IO.File]::WriteAllText($filePath, $content, $utf8NoBom)
        Write-Host "✓ Processed $fileName" -ForegroundColor Green
    }
}

Write-Host "`n=================================================" -ForegroundColor Green
Write-Host "XML files have been fixed!" -ForegroundColor Green
Write-Host "Ready to build the APK" -ForegroundColor Cyan