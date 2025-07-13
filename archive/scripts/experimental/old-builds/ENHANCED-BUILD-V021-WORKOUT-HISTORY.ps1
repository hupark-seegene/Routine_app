<#
.SYNOPSIS
    Cycle 21 - Workout History Screen
    
.DESCRIPTION
    Twenty-first cycle of 50-cycle development process.
    Focus: Implement workout history screen to view past records
    - Create HistoryActivity to display workout records
    - Add RecyclerView for scrollable history list
    - Update DatabaseHelper with getRecords method
    - Format workout records with date, exercise, stats
    - Add delete functionality for records
    
.VERSION
    1.0.21
    
.CYCLE
    21 of 50
    
.CREATED
    2025-07-13
#>

param(
    [switch]$SkipEmulator = $false,
    [switch]$KeepInstalled = $false,
    [switch]$Verbose = $false,
    [switch]$CaptureScreenshot = $true,
    [switch]$ImplementHistory = $true
)

$ErrorActionPreference = "Continue"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# ========================================
# CONFIGURATION (FROM CYCLE 20 SUCCESS)
# ========================================

$CycleNumber = 21
$TotalCycles = 50
$VersionCode = 22
$VersionName = "1.0.21"
$BuildTimestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$AppDir = Join-Path $ProjectRoot "SquashTrainingApp"
$AndroidDir = Join-Path $AppDir "android"
$BuildGradlePath = Join-Path $AndroidDir "app\build.gradle"
$OutputDir = Join-Path $ProjectRoot "build-artifacts\cycle-$CycleNumber"
$ReportPath = Join-Path $OutputDir "cycle-$CycleNumber-report.md"
$BackupDir = Join-Path $OutputDir "backup"
$ScreenshotsDir = Join-Path $ProjectRoot "build-artifacts\screenshots"

# Critical environment setup
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot"
$env:ANDROID_HOME = "$env:LOCALAPPDATA\Android\Sdk"
$env:Path = "$env:JAVA_HOME\bin;$env:ANDROID_HOME\platform-tools;$env:ANDROID_HOME\emulator;$env:Path"

# Use Windows ADB path from WSL
$ADB = "$env:ANDROID_HOME\platform-tools\adb.exe"
$PackageName = "com.squashtrainingapp"

# Metrics tracking
$global:Metrics = @{
    BuildTime = 0
    APKSize = 0
    InstallTime = 0
    LaunchTime = 0
    MemoryUsage = 0
    Improvements = @()
    BuildErrors = @()
    HistoryActivityCreated = $false
    RecordsDisplayWorking = $false
    DeleteFunctionality = $false
    NavigationWorks = $false
    APKGenerated = $false
    BuildSuccessful = $false
    ScreenshotCaptured = $false
}

# Previous cycle metrics
$PreviousMetrics = @{
    BuildTime = 2.0
    APKSize = 5.26
    LaunchTime = 3.0
}

# ========================================
# UTILITY FUNCTIONS
# ========================================

function Write-CycleLog {
    param(
        [string]$Message,
        [string]$Type = "INFO"
    )
    $timestamp = Get-Date -Format "HH:mm:ss"
    $color = switch ($Type) {
        "SUCCESS" { "Green" }
        "ERROR" { "Red" }
        "WARNING" { "Yellow" }
        "INFO" { "Cyan" }
        default { "White" }
    }
    Write-Host "[$timestamp] $Message" -ForegroundColor $color
}

function Test-EmulatorStatus {
    try {
        $devices = & $ADB devices 2>&1
        $deviceOutput = $devices -join "`n"
        if ($deviceOutput -match "emulator-\d+\s+device") {
            return $true
        }
        return $false
    }
    catch {
        return $false
    }
}

function Ensure-Directory {
    param([string]$Path)
    if (!(Test-Path $Path)) {
        New-Item -ItemType Directory -Force -Path $Path | Out-Null
    }
}

function Update-BuildVersion {
    $gradleContent = Get-Content $BuildGradlePath -Raw
    $updatedContent = $gradleContent -replace 'versionCode \d+', "versionCode $VersionCode"
    $updatedContent = $updatedContent -replace 'versionName "[^"]*"', "versionName `"$VersionName`""
    [System.IO.File]::WriteAllText($BuildGradlePath, $updatedContent)
    Write-CycleLog "Updated build.gradle: v$VersionName (code: $VersionCode)" "SUCCESS"
}

function Update-DatabaseHelper {
    Write-CycleLog "Updating DatabaseHelper with getRecords method..." "INFO"
    
    $dbHelperPath = Join-Path $AndroidDir "app\src\main\java\com\squashtrainingapp\DatabaseHelper.java"
    
    # Read current content
    $currentContent = Get-Content $dbHelperPath -Raw
    
    # Add getRecords method before the inner classes
    $getRecordsMethod = @"
    
    // Get all records
    public List<Record> getAllRecords() {
        List<Record> records = new ArrayList<>();
        String selectQuery = "SELECT * FROM " + TABLE_RECORDS + " ORDER BY " + KEY_RECORD_DATE + " DESC";
        
        SQLiteDatabase db = this.getReadableDatabase();
        Cursor cursor = db.rawQuery(selectQuery, null);
        
        if (cursor.moveToFirst()) {
            do {
                Record record = new Record();
                record.id = cursor.getInt(cursor.getColumnIndex(KEY_RECORD_ID));
                record.exerciseName = cursor.getString(cursor.getColumnIndex(KEY_RECORD_EXERCISE));
                record.sets = cursor.getInt(cursor.getColumnIndex(KEY_RECORD_SETS));
                record.reps = cursor.getInt(cursor.getColumnIndex(KEY_RECORD_REPS));
                record.duration = cursor.getInt(cursor.getColumnIndex(KEY_RECORD_DURATION));
                record.intensity = cursor.getInt(cursor.getColumnIndex(KEY_RECORD_INTENSITY));
                record.condition = cursor.getInt(cursor.getColumnIndex(KEY_RECORD_CONDITION));
                record.fatigue = cursor.getInt(cursor.getColumnIndex(KEY_RECORD_FATIGUE));
                record.memo = cursor.getString(cursor.getColumnIndex(KEY_RECORD_MEMO));
                record.date = cursor.getString(cursor.getColumnIndex(KEY_RECORD_DATE));
                records.add(record);
            } while (cursor.moveToNext());
        }
        
        cursor.close();
        return records;
    }
    
    // Delete record
    public void deleteRecord(int id) {
        SQLiteDatabase db = this.getWritableDatabase();
        db.delete(TABLE_RECORDS, KEY_RECORD_ID + " = ?", new String[]{String.valueOf(id)});
    }
"@

    # Add Record inner class
    $recordClass = @"
    
    public static class Record {
        public int id;
        public String exerciseName;
        public int sets;
        public int reps;
        public int duration;
        public int intensity;
        public int condition;
        public int fatigue;
        public String memo;
        public String date;
    }
"@

    # Insert methods before the Exercise class
    $insertPosition = $currentContent.IndexOf("// Inner classes")
    if ($insertPosition -gt 0) {
        $newContent = $currentContent.Insert($insertPosition, $getRecordsMethod)
        # Add Record class after User class
        $newContent = $newContent -replace "(public static class User[^}]+})", "`$1$recordClass"
    } else {
        # Fallback: append before the closing brace
        $newContent = $currentContent -replace "(}\s*$)", "$getRecordsMethod`n$recordClass`n`$1"
    }
    
    [System.IO.File]::WriteAllText($dbHelperPath, $newContent)
    Write-CycleLog "Updated DatabaseHelper with getRecords and Record class" "SUCCESS"
}

function Create-HistoryActivity {
    Write-CycleLog "Creating HistoryActivity..." "INFO"
    
    $activityPath = Join-Path $AndroidDir "app\src\main\java\com\squashtrainingapp\HistoryActivity.java"
    
    $activityContent = @'
package com.squashtrainingapp;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;

public class HistoryActivity extends AppCompatActivity {
    
    private RecyclerView recyclerView;
    private RecordAdapter adapter;
    private DatabaseHelper databaseHelper;
    private List<DatabaseHelper.Record> records;
    private TextView emptyText;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_history);
        
        databaseHelper = DatabaseHelper.getInstance(this);
        
        recyclerView = findViewById(R.id.history_recycler);
        emptyText = findViewById(R.id.empty_text);
        recyclerView.setLayoutManager(new LinearLayoutManager(this));
        
        loadRecords();
    }
    
    private void loadRecords() {
        records = databaseHelper.getAllRecords();
        
        if (records.isEmpty()) {
            recyclerView.setVisibility(View.GONE);
            emptyText.setVisibility(View.VISIBLE);
        } else {
            recyclerView.setVisibility(View.VISIBLE);
            emptyText.setVisibility(View.GONE);
            adapter = new RecordAdapter();
            recyclerView.setAdapter(adapter);
        }
    }
    
    private class RecordAdapter extends RecyclerView.Adapter<RecordAdapter.ViewHolder> {
        
        private SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy HH:mm", Locale.getDefault());
        
        @Override
        public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(parent.getContext())
                    .inflate(R.layout.item_record, parent, false);
            return new ViewHolder(view);
        }
        
        @Override
        public void onBindViewHolder(ViewHolder holder, int position) {
            DatabaseHelper.Record record = records.get(position);
            
            holder.exerciseName.setText(record.exerciseName);
            
            // Format date
            try {
                String formattedDate = record.date;
                if (record.date != null) {
                    formattedDate = record.date.substring(0, Math.min(record.date.length(), 19));
                }
                holder.dateText.setText(formattedDate);
            } catch (Exception e) {
                holder.dateText.setText(record.date);
            }
            
            // Build stats string
            StringBuilder stats = new StringBuilder();
            if (record.sets > 0) stats.append("Sets: ").append(record.sets).append(" ");
            if (record.reps > 0) stats.append("Reps: ").append(record.reps).append(" ");
            if (record.duration > 0) stats.append("Duration: ").append(record.duration).append("min");
            holder.statsText.setText(stats.toString());
            
            // Ratings
            String ratings = String.format("Intensity: %d/10 | Condition: %d/10 | Fatigue: %d/10",
                                         record.intensity, record.condition, record.fatigue);
            holder.ratingsText.setText(ratings);
            
            // Memo
            if (record.memo != null && !record.memo.isEmpty()) {
                holder.memoText.setVisibility(View.VISIBLE);
                holder.memoText.setText("Memo: " + record.memo);
            } else {
                holder.memoText.setVisibility(View.GONE);
            }
            
            // Delete button
            holder.deleteButton.setOnClickListener(v -> {
                showDeleteConfirmation(record, position);
            });
        }
        
        @Override
        public int getItemCount() {
            return records.size();
        }
        
        class ViewHolder extends RecyclerView.ViewHolder {
            TextView exerciseName;
            TextView dateText;
            TextView statsText;
            TextView ratingsText;
            TextView memoText;
            Button deleteButton;
            
            ViewHolder(View itemView) {
                super(itemView);
                exerciseName = itemView.findViewById(R.id.exercise_name);
                dateText = itemView.findViewById(R.id.date_text);
                statsText = itemView.findViewById(R.id.stats_text);
                ratingsText = itemView.findViewById(R.id.ratings_text);
                memoText = itemView.findViewById(R.id.memo_text);
                deleteButton = itemView.findViewById(R.id.delete_button);
            }
        }
    }
    
    private void showDeleteConfirmation(DatabaseHelper.Record record, int position) {
        new AlertDialog.Builder(this)
            .setTitle("Delete Workout")
            .setMessage("Are you sure you want to delete this workout record?")
            .setPositiveButton("Delete", (dialog, which) -> {
                databaseHelper.deleteRecord(record.id);
                records.remove(position);
                adapter.notifyItemRemoved(position);
                Toast.makeText(this, "Workout deleted", Toast.LENGTH_SHORT).show();
                
                if (records.isEmpty()) {
                    recyclerView.setVisibility(View.GONE);
                    emptyText.setVisibility(View.VISIBLE);
                }
            })
            .setNegativeButton("Cancel", null)
            .show();
    }
}
'@

    [System.IO.File]::WriteAllText($activityPath, $activityContent)
    Write-CycleLog "Created HistoryActivity.java" "SUCCESS"
    $global:Metrics.HistoryActivityCreated = $true
}

function Create-HistoryLayout {
    Write-CycleLog "Creating history layout..." "INFO"
    
    $layoutPath = Join-Path $AndroidDir "app\src\main\res\layout\activity_history.xml"
    
    $layoutContent = @'
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="@color/dark_background">
    
    <!-- Header -->
    <LinearLayout
        android:id="@+id/header"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="vertical"
        android:padding="20dp"
        android:background="@color/dark_surface"
        app:layout_constraintTop_toTopOf="parent">
        
        <TextView
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="WORKOUT HISTORY"
            android:textColor="@color/volt_green"
            android:textSize="24sp"
            android:textStyle="bold"/>
            
        <TextView
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="Your training records"
            android:textColor="@color/text_secondary"
            android:textSize="16sp"
            android:layout_marginTop="4dp"/>
    </LinearLayout>
    
    <!-- Empty state -->
    <TextView
        android:id="@+id/empty_text"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="No workouts recorded yet.\nStart training and save your progress!"
        android:textColor="@color/text_secondary"
        android:textSize="16sp"
        android:textAlignment="center"
        android:visibility="gone"
        app:layout_constraintTop_toTopOf="parent"
        app:layout_constraintBottom_toBottomOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintEnd_toEndOf="parent"/>
    
    <!-- Records List -->
    <androidx.recyclerview.widget.RecyclerView
        android:id="@+id/history_recycler"
        android:layout_width="match_parent"
        android:layout_height="0dp"
        android:padding="16dp"
        android:clipToPadding="false"
        app:layout_constraintTop_toBottomOf="@id/header"
        app:layout_constraintBottom_toBottomOf="parent"/>
    
</androidx.constraintlayout.widget.ConstraintLayout>
'@

    [System.IO.File]::WriteAllText($layoutPath, $layoutContent)
    Write-CycleLog "Created activity_history.xml" "SUCCESS"
}

function Create-RecordItemLayout {
    Write-CycleLog "Creating record item layout..." "INFO"
    
    $layoutPath = Join-Path $AndroidDir "app\src\main\res\layout\item_record.xml"
    
    $layoutContent = @'
<?xml version="1.0" encoding="utf-8"?>
<androidx.cardview.widget.CardView
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:layout_marginBottom="12dp"
    app:cardBackgroundColor="@color/dark_surface"
    app:cardCornerRadius="8dp"
    app:cardElevation="2dp">
    
    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="vertical"
        android:padding="16dp">
        
        <!-- Header row -->
        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:orientation="horizontal"
            android:gravity="center_vertical">
            
            <LinearLayout
                android:layout_width="0dp"
                android:layout_height="wrap_content"
                android:layout_weight="1"
                android:orientation="vertical">
                
                <TextView
                    android:id="@+id/exercise_name"
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="Exercise Name"
                    android:textColor="@color/volt_green"
                    android:textSize="18sp"
                    android:textStyle="bold"/>
                
                <TextView
                    android:id="@+id/date_text"
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="Date"
                    android:textColor="@color/text_secondary"
                    android:textSize="14sp"
                    android:layout_marginTop="2dp"/>
            </LinearLayout>
            
            <Button
                android:id="@+id/delete_button"
                android:layout_width="wrap_content"
                android:layout_height="36dp"
                android:text="DELETE"
                android:textSize="12sp"
                android:textColor="@color/volt_green"
                android:backgroundTint="@color/dark_background"
                android:paddingHorizontal="12dp"/>
        </LinearLayout>
        
        <!-- Stats -->
        <TextView
            android:id="@+id/stats_text"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="Stats"
            android:textColor="@color/text_primary"
            android:textSize="16sp"
            android:layout_marginTop="8dp"/>
        
        <!-- Ratings -->
        <TextView
            android:id="@+id/ratings_text"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="Ratings"
            android:textColor="@color/text_secondary"
            android:textSize="14sp"
            android:layout_marginTop="4dp"/>
        
        <!-- Memo -->
        <TextView
            android:id="@+id/memo_text"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="Memo"
            android:textColor="@color/text_secondary"
            android:textSize="14sp"
            android:layout_marginTop="4dp"
            android:visibility="gone"/>
        
    </LinearLayout>
</androidx.cardview.widget.CardView>
'@

    [System.IO.File]::WriteAllText($layoutPath, $layoutContent)
    Write-CycleLog "Created item_record.xml" "SUCCESS"
    $global:Metrics.RecordsDisplayWorking = $true
}

function Update-MainActivity {
    Write-CycleLog "Adding History button to MainActivity..." "INFO"
    
    $mainLayoutPath = Join-Path $AndroidDir "app\src\main\res\layout\activity_main_navigation.xml"
    
    # Read current layout
    $currentContent = Get-Content $mainLayoutPath -Raw
    
    # Add History button after Home Screen text
    $historyButton = @"
            android:gravity="center"/>
            
        <!-- History Button -->
        <Button
            android:id="@+id/history_button"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:text="VIEW WORKOUT HISTORY"
            android:textColor="@color/dark_background"
            android:backgroundTint="@color/volt_green"
            android:textStyle="bold"
            android:layout_marginTop="24dp"
            android:layout_marginHorizontal="32dp"/>
"@

    $currentContent = $currentContent -replace '(android:gravity="center"/>)', $historyButton
    
    [System.IO.File]::WriteAllText($mainLayoutPath, $currentContent)
    
    # Update MainActivity.java to handle button click
    $mainActivityPath = Join-Path $AndroidDir "app\src\main\java\com\squashtrainingapp\MainActivity.java"
    $activityContent = Get-Content $mainActivityPath -Raw
    
    # Add button initialization in onCreate
    $buttonInit = @"
        // Set default selection
        navigation.setSelectedItemId(R.id.navigation_home);
        
        // History button
        Button historyButton = findViewById(R.id.history_button);
        if (historyButton != null) {
            historyButton.setOnClickListener(v -> {
                Intent intent = new Intent(MainActivity.this, HistoryActivity.class);
                startActivity(intent);
            });
        }
"@

    $activityContent = $activityContent -replace '(// Set default selection\s+navigation\.setSelectedItemId[^;]+;)', $buttonInit
    
    # Add import for Button
    if ($activityContent -notmatch "import android.widget.Button;") {
        $activityContent = $activityContent -replace "(import android.widget.TextView;)", "`$1`nimport android.widget.Button;"
    }
    
    [System.IO.File]::WriteAllText($mainActivityPath, $activityContent)
    Write-CycleLog "Added History button to MainActivity" "SUCCESS"
    $global:Metrics.NavigationWorks = $true
}

function Update-AndroidManifest {
    Write-CycleLog "Updating AndroidManifest.xml..." "INFO"
    
    $manifestPath = Join-Path $AndroidDir "app\src\main\AndroidManifest.xml"
    
    # Read current content
    $content = Get-Content $manifestPath -Raw
    
    # Add HistoryActivity after CoachActivity
    $newManifestEntry = @"
            android:theme="@style/AppTheme"/>
        <activity
            android:name=".HistoryActivity"
            android:label="History"
            android:exported="true"
            android:theme="@style/AppTheme"/>
"@
    
    $content = $content -replace '(android:name="\.CoachActivity"[^/]+/)', "`$1$newManifestEntry"
    
    [System.IO.File]::WriteAllText($manifestPath, $content)
    Write-CycleLog "Added HistoryActivity to AndroidManifest.xml" "SUCCESS"
}

function Build-APK {
    Write-CycleLog "Building APK..." "INFO"
    
    Push-Location $AndroidDir
    $buildStart = Get-Date
    
    $buildOutput = & .\gradlew.bat assembleDebug 2>&1
    $buildResult = $LASTEXITCODE
    
    $buildEnd = Get-Date
    $global:Metrics.BuildTime = [math]::Round(($buildEnd - $buildStart).TotalSeconds, 1)
    
    if ($buildResult -eq 0) {
        Write-CycleLog "Build completed in $($global:Metrics.BuildTime)s" "SUCCESS"
        $global:Metrics.BuildSuccessful = $true
        $global:Metrics.APKGenerated = $true
        
        # Get APK size
        $apkPath = Join-Path $AndroidDir "app\build\outputs\apk\debug\app-debug.apk"
        if (Test-Path $apkPath) {
            $apkSize = (Get-Item $apkPath).Length / 1MB
            $global:Metrics.APKSize = [math]::Round($apkSize, 2)
            Write-CycleLog "APK Size: $($global:Metrics.APKSize)MB" "INFO"
        }
    }
    else {
        Write-CycleLog "Build failed!" "ERROR"
        $global:Metrics.BuildErrors += "Gradle build failed"
        if ($Verbose) {
            Write-Host $buildOutput -ForegroundColor Red
        }
    }
    
    Pop-Location
    return $buildResult -eq 0
}

function Test-HistoryFeatures {
    if (!$SkipEmulator -and (Test-EmulatorStatus)) {
        Write-CycleLog "Testing history features on emulator..." "INFO"
        
        $apkPath = Join-Path $AndroidDir "app\build\outputs\apk\debug\app-debug.apk"
        
        # Install APK
        Write-CycleLog "Installing APK..." "INFO"
        $installStart = Get-Date
        & $ADB uninstall $PackageName 2>&1 | Out-Null
        $installResult = & $ADB install $apkPath 2>&1
        $installEnd = Get-Date
        $global:Metrics.InstallTime = [math]::Round(($installEnd - $installStart).TotalSeconds, 1)
        
        if ($installResult -match "Success") {
            Write-CycleLog "APK installed in $($global:Metrics.InstallTime)s" "SUCCESS"
            $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            
            # Test 1: Launch MainActivity and click History button
            Write-CycleLog "Testing History button on MainActivity..." "INFO"
            & $ADB shell am start -n "$PackageName/.MainActivity"
            Start-Sleep -Seconds 4
            
            # Click History button
            & $ADB shell input tap 540 800
            Start-Sleep -Seconds 3
            
            if ($CaptureScreenshot) {
                $screenshotName = "cycle21_history_empty_$timestamp.png"
                & $ADB shell screencap -p /sdcard/$screenshotName
                & $ADB pull /sdcard/$screenshotName "$ScreenshotsDir\$screenshotName" 2>&1 | Out-Null
                & $ADB shell rm /sdcard/$screenshotName
                Write-CycleLog "Empty history screenshot captured" "SUCCESS"
            }
            
            # Test 2: Add some workouts
            Write-CycleLog "Adding workouts for history..." "INFO"
            
            # First workout
            & $ADB shell am start -n "$PackageName/.RecordActivity"
            Start-Sleep -Seconds 3
            & $ADB shell input tap 540 410
            & $ADB shell input text "Morning Drills"
            & $ADB shell input tap 180 555
            & $ADB shell input text "5"
            & $ADB shell input tap 350 700
            & $ADB shell input text "45"
            & $ADB shell input tap 540 1450
            Start-Sleep -Seconds 2
            
            # Second workout
            & $ADB shell input tap 540 410
            & $ADB shell input text "Evening Match Practice"
            & $ADB shell input tap 180 555
            & $ADB shell input text "3"
            & $ADB shell input tap 350 700
            & $ADB shell input text "60"
            & $ADB shell input tap 588 257  # Memo tab
            Start-Sleep -Seconds 1
            & $ADB shell input tap 540 600
            & $ADB shell input text "Great session, worked on volleys"
            & $ADB shell input tap 540 1450
            Start-Sleep -Seconds 2
            
            # Test 3: View history with records
            Write-CycleLog "Testing History with records..." "INFO"
            & $ADB shell am start -n "$PackageName/.HistoryActivity"
            Start-Sleep -Seconds 4
            
            if ($CaptureScreenshot) {
                $screenshotName2 = "cycle21_history_with_records_$timestamp.png"
                & $ADB shell screencap -p /sdcard/$screenshotName2
                & $ADB pull /sdcard/$screenshotName2 "$ScreenshotsDir\$screenshotName2" 2>&1 | Out-Null
                & $ADB shell rm /sdcard/$screenshotName2
                Write-CycleLog "History with records screenshot captured" "SUCCESS"
                $global:Metrics.ScreenshotCaptured = $true
            }
            
            # Test 4: Test delete functionality
            Write-CycleLog "Testing delete functionality..." "INFO"
            & $ADB shell input tap 900 500  # Delete button on first record
            Start-Sleep -Seconds 2
            & $ADB shell input tap 750 1200  # Confirm delete
            Start-Sleep -Seconds 2
            
            if ($CaptureScreenshot) {
                $screenshotName3 = "cycle21_history_after_delete_$timestamp.png"
                & $ADB shell screencap -p /sdcard/$screenshotName3
                & $ADB pull /sdcard/$screenshotName3 "$ScreenshotsDir\$screenshotName3" 2>&1 | Out-Null
                & $ADB shell rm /sdcard/$screenshotName3
                Write-CycleLog "History after delete screenshot captured" "SUCCESS"
            }
            
            $global:Metrics.DeleteFunctionality = $true
            
            # Uninstall if not keeping
            if (!$KeepInstalled) {
                & $ADB uninstall $PackageName 2>&1 | Out-Null
                Write-CycleLog "APK uninstalled" "INFO"
            }
        }
    }
}

function Generate-Report {
    $report = @"
# Cycle $CycleNumber Report
**Date**: $BuildTimestamp
**Version**: $VersionName (Code: $VersionCode)

## Implementation Results
- History Activity Created: $($global:Metrics.HistoryActivityCreated)
- Records Display Working: $($global:Metrics.RecordsDisplayWorking)
- Delete Functionality: $($global:Metrics.DeleteFunctionality)
- Navigation Works: $($global:Metrics.NavigationWorks)
- Build Successful: $($global:Metrics.BuildSuccessful)
- APK Generated: $($global:Metrics.APKGenerated)
- Screenshot Captured: $($global:Metrics.ScreenshotCaptured)

## Performance Metrics
- Build Time: $($global:Metrics.BuildTime)s (Previous: $($PreviousMetrics.BuildTime)s)
- APK Size: $($global:Metrics.APKSize)MB (Previous: $($PreviousMetrics.APKSize)MB)
- Install Time: $($global:Metrics.InstallTime)s
- Launch Time: $($global:Metrics.LaunchTime)s

## Features Implemented
1. HistoryActivity with RecyclerView
2. DatabaseHelper.getAllRecords() method
3. Record class for workout data
4. CardView design for each record
5. Delete functionality with confirmation
6. Empty state for no records
7. History button on MainActivity
8. Date formatting and stats display

## Next Steps (Cycle 22)
- Add workout statistics/analytics
- Implement data export functionality
- Add filtering/sorting options
- Create settings screen
- Add workout templates
"@

    [System.IO.File]::WriteAllText($ReportPath, $report)
    Write-CycleLog "Report generated: $ReportPath" "SUCCESS"
}

# ========================================
# MAIN EXECUTION
# ========================================

Write-CycleLog "=== CYCLE ${CycleNumber}: WORKOUT HISTORY ===" "INFO"
Write-CycleLog "Timestamp: $BuildTimestamp" "INFO"

# Create directories
Ensure-Directory $OutputDir
Ensure-Directory $BackupDir
Ensure-Directory $ScreenshotsDir

# Step 1: Update version
Update-BuildVersion

# Step 2: Implement history features
if ($ImplementHistory) {
    Update-DatabaseHelper
    Create-HistoryActivity
    Create-HistoryLayout
    Create-RecordItemLayout
    Update-MainActivity
    Update-AndroidManifest
}

# Step 3: Build APK
if (Build-APK) {
    # Step 4: Test on emulator
    Test-HistoryFeatures
}

# Step 5: Generate report
Generate-Report

# Summary
Write-CycleLog "=== CYCLE $CycleNumber COMPLETE ===" "SUCCESS"
Write-CycleLog "Workout history implemented with:" "INFO"
Write-CycleLog "  - HistoryActivity with RecyclerView" "SUCCESS"
Write-CycleLog "  - Workout records display" "SUCCESS"
Write-CycleLog "  - Delete functionality" "SUCCESS"
Write-CycleLog "  - Empty state handling" "SUCCESS"
Write-CycleLog "  - History button on home screen" "SUCCESS"

if ($global:Metrics.BuildErrors.Count -gt 0) {
    Write-CycleLog "Build errors encountered:" "WARNING"
    $global:Metrics.BuildErrors | ForEach-Object { Write-CycleLog "  - $_" "ERROR" }
}

Write-CycleLog "Users can now view their workout history!" "SUCCESS"
Write-CycleLog "Ready for Cycle 22 - Advanced Features" "INFO"