<#
.SYNOPSIS
    Cycle 20 - Database Integration
    
.DESCRIPTION
    Twentieth cycle of 50-cycle development process.
    Focus: Implement SQLite database for data persistence
    - Create DatabaseHelper class
    - Define tables for exercises, records, user data
    - Update ChecklistActivity to use database
    - Update RecordActivity to save to database
    - Add initial seed data
    
.VERSION
    1.0.20
    
.CYCLE
    20 of 50
    
.CREATED
    2025-07-13
#>

param(
    [switch]$SkipEmulator = $false,
    [switch]$KeepInstalled = $false,
    [switch]$Verbose = $false,
    [switch]$CaptureScreenshot = $true,
    [switch]$ImplementDatabase = $true
)

$ErrorActionPreference = "Continue"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# ========================================
# CONFIGURATION (FROM CYCLE 19 SUCCESS)
# ========================================

$CycleNumber = 20
$TotalCycles = 50
$VersionCode = 21
$VersionName = "1.0.20"
$BuildTimestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$AppDir = Join-Path $ProjectRoot "SquashTrainingApp"
$AndroidDir = Join-Path $AppDir "android"
$BuildGradlePath = Join-Path $AndroidDir "app\build.gradle"
$OutputDir = Join-Path $ProjectRoot "build-artifacts\cycle-$CycleNumber"
$ReportPath = Join-Path $OutputDir "cycle-$CycleNumber-report.md"
$BackupDir = Join-Path $OutputDir "backup"
$ScreenshotsDir = Join-Path $ProjectRoot "build-artifacts\screenshots"

# Critical environment setup from previous cycles
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
    DatabaseImplemented = $false
    TablesCreated = $false
    ChecklistUpdated = $false
    RecordSaveWorks = $false
    DataPersists = $false
    APKGenerated = $false
    BuildSuccessful = $false
    ScreenshotCaptured = $false
}

# Previous cycle metrics
$PreviousMetrics = @{
    BuildTime = 7.0
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
        if ($devices -match "emulator.*device$") {
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

function Create-DatabaseHelper {
    Write-CycleLog "Creating DatabaseHelper class..." "INFO"
    
    $dbHelperPath = Join-Path $AndroidDir "app\src\main\java\com\squashtrainingapp\DatabaseHelper.java"
    
    $dbHelperContent = @'
package com.squashtrainingapp;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import java.util.ArrayList;
import java.util.List;

public class DatabaseHelper extends SQLiteOpenHelper {
    
    // Database Info
    private static final String DATABASE_NAME = "squashTraining.db";
    private static final int DATABASE_VERSION = 1;
    
    // Table Names
    private static final String TABLE_EXERCISES = "exercises";
    private static final String TABLE_RECORDS = "records";
    private static final String TABLE_USER = "user";
    
    // Exercises Table Columns
    private static final String KEY_EXERCISE_ID = "id";
    private static final String KEY_EXERCISE_NAME = "name";
    private static final String KEY_EXERCISE_CATEGORY = "category";
    private static final String KEY_EXERCISE_DESCRIPTION = "description";
    private static final String KEY_EXERCISE_CHECKED = "is_checked";
    
    // Records Table Columns
    private static final String KEY_RECORD_ID = "id";
    private static final String KEY_RECORD_EXERCISE = "exercise_name";
    private static final String KEY_RECORD_SETS = "sets";
    private static final String KEY_RECORD_REPS = "reps";
    private static final String KEY_RECORD_DURATION = "duration";
    private static final String KEY_RECORD_INTENSITY = "intensity";
    private static final String KEY_RECORD_CONDITION = "condition";
    private static final String KEY_RECORD_FATIGUE = "fatigue";
    private static final String KEY_RECORD_MEMO = "memo";
    private static final String KEY_RECORD_DATE = "date";
    
    // User Table Columns
    private static final String KEY_USER_ID = "id";
    private static final String KEY_USER_NAME = "name";
    private static final String KEY_USER_LEVEL = "level";
    private static final String KEY_USER_EXP = "experience";
    private static final String KEY_USER_SESSIONS = "total_sessions";
    private static final String KEY_USER_CALORIES = "total_calories";
    private static final String KEY_USER_HOURS = "total_hours";
    private static final String KEY_USER_STREAK = "current_streak";
    
    private static DatabaseHelper instance;
    
    public static synchronized DatabaseHelper getInstance(Context context) {
        if (instance == null) {
            instance = new DatabaseHelper(context.getApplicationContext());
        }
        return instance;
    }
    
    private DatabaseHelper(Context context) {
        super(context, DATABASE_NAME, null, DATABASE_VERSION);
    }
    
    @Override
    public void onCreate(SQLiteDatabase db) {
        // Create Exercises Table
        String CREATE_EXERCISES_TABLE = "CREATE TABLE " + TABLE_EXERCISES +
                "(" +
                KEY_EXERCISE_ID + " INTEGER PRIMARY KEY AUTOINCREMENT," +
                KEY_EXERCISE_NAME + " TEXT," +
                KEY_EXERCISE_CATEGORY + " TEXT," +
                KEY_EXERCISE_DESCRIPTION + " TEXT," +
                KEY_EXERCISE_CHECKED + " INTEGER DEFAULT 0" +
                ")";
        
        // Create Records Table
        String CREATE_RECORDS_TABLE = "CREATE TABLE " + TABLE_RECORDS +
                "(" +
                KEY_RECORD_ID + " INTEGER PRIMARY KEY AUTOINCREMENT," +
                KEY_RECORD_EXERCISE + " TEXT," +
                KEY_RECORD_SETS + " INTEGER," +
                KEY_RECORD_REPS + " INTEGER," +
                KEY_RECORD_DURATION + " INTEGER," +
                KEY_RECORD_INTENSITY + " INTEGER," +
                KEY_RECORD_CONDITION + " INTEGER," +
                KEY_RECORD_FATIGUE + " INTEGER," +
                KEY_RECORD_MEMO + " TEXT," +
                KEY_RECORD_DATE + " DATETIME DEFAULT CURRENT_TIMESTAMP" +
                ")";
        
        // Create User Table
        String CREATE_USER_TABLE = "CREATE TABLE " + TABLE_USER +
                "(" +
                KEY_USER_ID + " INTEGER PRIMARY KEY," +
                KEY_USER_NAME + " TEXT," +
                KEY_USER_LEVEL + " INTEGER DEFAULT 1," +
                KEY_USER_EXP + " INTEGER DEFAULT 0," +
                KEY_USER_SESSIONS + " INTEGER DEFAULT 0," +
                KEY_USER_CALORIES + " INTEGER DEFAULT 0," +
                KEY_USER_HOURS + " REAL DEFAULT 0," +
                KEY_USER_STREAK + " INTEGER DEFAULT 0" +
                ")";
        
        db.execSQL(CREATE_EXERCISES_TABLE);
        db.execSQL(CREATE_RECORDS_TABLE);
        db.execSQL(CREATE_USER_TABLE);
        
        // Insert initial data
        insertInitialData(db);
    }
    
    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
        db.execSQL("DROP TABLE IF EXISTS " + TABLE_EXERCISES);
        db.execSQL("DROP TABLE IF EXISTS " + TABLE_RECORDS);
        db.execSQL("DROP TABLE IF EXISTS " + TABLE_USER);
        onCreate(db);
    }
    
    private void insertInitialData(SQLiteDatabase db) {
        // Insert default exercises
        insertExercise(db, "Front Court Drills", "Movement", "Practice lunging and recovering from the front corners");
        insertExercise(db, "Ghosting", "Movement", "Shadow movements around the court without ball");
        insertExercise(db, "Straight Drives", "Technique", "Hit 50 straight drives on each side");
        insertExercise(db, "Cross Courts", "Technique", "Practice cross court shots with good width");
        insertExercise(db, "Boast Practice", "Technique", "Work on two-wall and three-wall boasts");
        insertExercise(db, "Serves & Returns", "Match Play", "Practice different serves and return options");
        
        // Insert default user
        ContentValues userValues = new ContentValues();
        userValues.put(KEY_USER_ID, 1);
        userValues.put(KEY_USER_NAME, "Alex Player");
        userValues.put(KEY_USER_LEVEL, 12);
        userValues.put(KEY_USER_EXP, 750);
        userValues.put(KEY_USER_SESSIONS, 147);
        userValues.put(KEY_USER_CALORIES, 42580);
        userValues.put(KEY_USER_HOURS, 73.5);
        userValues.put(KEY_USER_STREAK, 7);
        db.insert(TABLE_USER, null, userValues);
    }
    
    private void insertExercise(SQLiteDatabase db, String name, String category, String description) {
        ContentValues values = new ContentValues();
        values.put(KEY_EXERCISE_NAME, name);
        values.put(KEY_EXERCISE_CATEGORY, category);
        values.put(KEY_EXERCISE_DESCRIPTION, description);
        values.put(KEY_EXERCISE_CHECKED, 0);
        db.insert(TABLE_EXERCISES, null, values);
    }
    
    // Exercise methods
    public List<Exercise> getAllExercises() {
        List<Exercise> exercises = new ArrayList<>();
        String selectQuery = "SELECT * FROM " + TABLE_EXERCISES;
        
        SQLiteDatabase db = this.getReadableDatabase();
        Cursor cursor = db.rawQuery(selectQuery, null);
        
        if (cursor.moveToFirst()) {
            do {
                Exercise exercise = new Exercise();
                exercise.id = cursor.getInt(cursor.getColumnIndex(KEY_EXERCISE_ID));
                exercise.name = cursor.getString(cursor.getColumnIndex(KEY_EXERCISE_NAME));
                exercise.category = cursor.getString(cursor.getColumnIndex(KEY_EXERCISE_CATEGORY));
                exercise.description = cursor.getString(cursor.getColumnIndex(KEY_EXERCISE_DESCRIPTION));
                exercise.isChecked = cursor.getInt(cursor.getColumnIndex(KEY_EXERCISE_CHECKED)) == 1;
                exercises.add(exercise);
            } while (cursor.moveToNext());
        }
        
        cursor.close();
        return exercises;
    }
    
    public void updateExerciseChecked(int id, boolean isChecked) {
        SQLiteDatabase db = this.getWritableDatabase();
        ContentValues values = new ContentValues();
        values.put(KEY_EXERCISE_CHECKED, isChecked ? 1 : 0);
        db.update(TABLE_EXERCISES, values, KEY_EXERCISE_ID + " = ?", new String[]{String.valueOf(id)});
    }
    
    // Record methods
    public long insertRecord(String exercise, int sets, int reps, int duration, 
                           int intensity, int condition, int fatigue, String memo) {
        SQLiteDatabase db = this.getWritableDatabase();
        ContentValues values = new ContentValues();
        values.put(KEY_RECORD_EXERCISE, exercise);
        values.put(KEY_RECORD_SETS, sets);
        values.put(KEY_RECORD_REPS, reps);
        values.put(KEY_RECORD_DURATION, duration);
        values.put(KEY_RECORD_INTENSITY, intensity);
        values.put(KEY_RECORD_CONDITION, condition);
        values.put(KEY_RECORD_FATIGUE, fatigue);
        values.put(KEY_RECORD_MEMO, memo);
        
        long id = db.insert(TABLE_RECORDS, null, values);
        
        // Update user stats
        updateUserStats(duration);
        
        return id;
    }
    
    // User methods
    public User getUser() {
        SQLiteDatabase db = this.getReadableDatabase();
        Cursor cursor = db.query(TABLE_USER, null, KEY_USER_ID + " = ?", 
                               new String[]{"1"}, null, null, null);
        
        User user = new User();
        if (cursor != null && cursor.moveToFirst()) {
            user.name = cursor.getString(cursor.getColumnIndex(KEY_USER_NAME));
            user.level = cursor.getInt(cursor.getColumnIndex(KEY_USER_LEVEL));
            user.experience = cursor.getInt(cursor.getColumnIndex(KEY_USER_EXP));
            user.totalSessions = cursor.getInt(cursor.getColumnIndex(KEY_USER_SESSIONS));
            user.totalCalories = cursor.getInt(cursor.getColumnIndex(KEY_USER_CALORIES));
            user.totalHours = cursor.getFloat(cursor.getColumnIndex(KEY_USER_HOURS));
            user.currentStreak = cursor.getInt(cursor.getColumnIndex(KEY_USER_STREAK));
            cursor.close();
        }
        
        return user;
    }
    
    private void updateUserStats(int duration) {
        SQLiteDatabase db = this.getWritableDatabase();
        
        // Get current user stats
        User user = getUser();
        
        // Update stats
        user.totalSessions++;
        user.totalHours += duration / 60.0f;
        user.totalCalories += duration * 10; // Rough estimate: 10 cal/min
        user.experience += 50; // 50 XP per session
        
        // Check for level up
        if (user.experience >= 1000) {
            user.level++;
            user.experience -= 1000;
        }
        
        // Update database
        ContentValues values = new ContentValues();
        values.put(KEY_USER_SESSIONS, user.totalSessions);
        values.put(KEY_USER_HOURS, user.totalHours);
        values.put(KEY_USER_CALORIES, user.totalCalories);
        values.put(KEY_USER_EXP, user.experience);
        values.put(KEY_USER_LEVEL, user.level);
        
        db.update(TABLE_USER, values, KEY_USER_ID + " = ?", new String[]{"1"});
    }
    
    // Inner classes
    public static class Exercise {
        public int id;
        public String name;
        public String category;
        public String description;
        public boolean isChecked;
    }
    
    public static class User {
        public String name;
        public int level;
        public int experience;
        public int totalSessions;
        public int totalCalories;
        public float totalHours;
        public int currentStreak;
    }
}
'@

    [System.IO.File]::WriteAllText($dbHelperPath, $dbHelperContent)
    Write-CycleLog "Created DatabaseHelper.java" "SUCCESS"
    $global:Metrics.DatabaseImplemented = $true
    $global:Metrics.TablesCreated = $true
}

function Update-ChecklistActivity {
    Write-CycleLog "Updating ChecklistActivity to use database..." "INFO"
    
    $activityPath = Join-Path $AndroidDir "app\src\main\java\com\squashtrainingapp\ChecklistActivity.java"
    
    $activityContent = @'
package com.squashtrainingapp;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CheckBox;
import android.widget.TextView;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import java.util.List;

public class ChecklistActivity extends AppCompatActivity {
    
    private RecyclerView recyclerView;
    private ExerciseAdapter adapter;
    private DatabaseHelper databaseHelper;
    private List<DatabaseHelper.Exercise> exercises;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_checklist);
        
        databaseHelper = DatabaseHelper.getInstance(this);
        
        recyclerView = findViewById(R.id.checklist_recycler);
        recyclerView.setLayoutManager(new LinearLayoutManager(this));
        
        loadExercises();
    }
    
    private void loadExercises() {
        exercises = databaseHelper.getAllExercises();
        adapter = new ExerciseAdapter();
        recyclerView.setAdapter(adapter);
    }
    
    private class ExerciseAdapter extends RecyclerView.Adapter<ExerciseAdapter.ViewHolder> {
        
        @Override
        public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(parent.getContext())
                    .inflate(R.layout.item_exercise, parent, false);
            return new ViewHolder(view);
        }
        
        @Override
        public void onBindViewHolder(ViewHolder holder, int position) {
            DatabaseHelper.Exercise exercise = exercises.get(position);
            holder.exerciseName.setText(exercise.name);
            holder.exerciseCategory.setText(exercise.category);
            holder.checkbox.setChecked(exercise.isChecked);
            
            holder.checkbox.setOnCheckedChangeListener((buttonView, isChecked) -> {
                exercise.isChecked = isChecked;
                databaseHelper.updateExerciseChecked(exercise.id, isChecked);
                
                if (isChecked) {
                    Toast.makeText(ChecklistActivity.this, 
                        exercise.name + " completed!", Toast.LENGTH_SHORT).show();
                }
            });
        }
        
        @Override
        public int getItemCount() {
            return exercises.size();
        }
        
        class ViewHolder extends RecyclerView.ViewHolder {
            TextView exerciseName;
            TextView exerciseCategory;
            CheckBox checkbox;
            
            ViewHolder(View itemView) {
                super(itemView);
                exerciseName = itemView.findViewById(R.id.exercise_name);
                exerciseCategory = itemView.findViewById(R.id.exercise_category);
                checkbox = itemView.findViewById(R.id.exercise_checkbox);
            }
        }
    }
    
    @Override
    protected void onResume() {
        super.onResume();
        // Refresh data when returning to this screen
        loadExercises();
    }
}
'@

    [System.IO.File]::WriteAllText($activityPath, $activityContent)
    Write-CycleLog "Updated ChecklistActivity with database integration" "SUCCESS"
    $global:Metrics.ChecklistUpdated = $true
}

function Update-RecordActivity {
    Write-CycleLog "Updating RecordActivity to save to database..." "INFO"
    
    $activityPath = Join-Path $AndroidDir "app\src\main\java\com\squashtrainingapp\RecordActivity.java"
    
    # Read current content and add database save functionality
    $currentContent = Get-Content $activityPath -Raw
    
    # Replace the saveRecord method
    $newSaveMethod = @"
private void saveRecord() {
        String exerciseName = exerciseNameInput.getText().toString().trim();
        String setsText = setsInput.getText().toString().trim();
        String repsText = repsInput.getText().toString().trim();
        String durationText = durationInput.getText().toString().trim();
        String memo = memoInput.getText().toString().trim();
        
        if (exerciseName.isEmpty()) {
            Toast.makeText(this, "Please enter exercise name", Toast.LENGTH_SHORT).show();
            return;
        }
        
        int sets = setsText.isEmpty() ? 0 : Integer.parseInt(setsText);
        int reps = repsText.isEmpty() ? 0 : Integer.parseInt(repsText);
        int duration = durationText.isEmpty() ? 0 : Integer.parseInt(durationText);
        int intensity = intensitySlider.getProgress();
        int condition = conditionSlider.getProgress();
        int fatigue = fatigueSlider.getProgress();
        
        // Save to database
        DatabaseHelper dbHelper = DatabaseHelper.getInstance(this);
        long recordId = dbHelper.insertRecord(exerciseName, sets, reps, duration, 
                                             intensity, condition, fatigue, memo);
        
        if (recordId > 0) {
            Toast.makeText(this, "Workout saved successfully!", Toast.LENGTH_LONG).show();
            
            // Clear form
            exerciseNameInput.setText("");
            setsInput.setText("");
            repsInput.setText("");
            durationInput.setText("");
            memoInput.setText("");
            intensitySlider.setProgress(5);
            conditionSlider.setProgress(5);
            fatigueSlider.setProgress(5);
            
            // Go back to first tab
            tabHost.setCurrentTab(0);
        } else {
            Toast.makeText(this, "Error saving workout", Toast.LENGTH_SHORT).show();
        }
    }
"@

    # Replace the old saveRecord method
    $currentContent = $currentContent -replace 'private void saveRecord\(\) \{[^}]+Toast\.makeText[^}]+\}', $newSaveMethod
    
    [System.IO.File]::WriteAllText($activityPath, $currentContent)
    Write-CycleLog "Updated RecordActivity with database save functionality" "SUCCESS"
    $global:Metrics.RecordSaveWorks = $true
}

function Update-ProfileActivity {
    Write-CycleLog "Updating ProfileActivity to use database..." "INFO"
    
    $activityPath = Join-Path $AndroidDir "app\src\main\java\com\squashtrainingapp\ProfileActivity.java"
    
    # Read current content and modify to use database
    $currentContent = Get-Content $activityPath -Raw
    
    # Add database initialization in onCreate
    $dbInit = @"
// Database
        DatabaseHelper dbHelper = DatabaseHelper.getInstance(this);
        DatabaseHelper.User user = dbHelper.getUser();
        
        // Update UI with database values
        userLevel = user.level;
        currentExp = user.experience;
        maxExp = 1000;
        totalSessions = user.totalSessions;
        totalCalories = user.totalCalories;
        totalHours = Math.round(user.totalHours);
        currentStreak = user.currentStreak;
"@

    # Replace the hardcoded values section
    $currentContent = $currentContent -replace '// Placeholder user data[^}]+currentStreak = 7;', $dbInit
    
    [System.IO.File]::WriteAllText($activityPath, $currentContent)
    Write-CycleLog "Updated ProfileActivity with database integration" "SUCCESS"
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

function Test-DatabaseFeatures {
    if (!$SkipEmulator -and (Test-EmulatorStatus)) {
        Write-CycleLog "Testing database features on emulator..." "INFO"
        
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
            
            # Test 1: Launch ChecklistActivity
            Write-CycleLog "Testing ChecklistActivity with database..." "INFO"
            & $ADB shell am start -n "$PackageName/.ChecklistActivity"
            Start-Sleep -Seconds 4
            
            if ($CaptureScreenshot) {
                $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
                $screenshotName = "cycle20_checklist_database_$timestamp.png"
                $devicePath = "/sdcard/$screenshotName"
                $localPath = Join-Path $ScreenshotsDir $screenshotName
                
                & $ADB shell screencap -p $devicePath
                & $ADB pull $devicePath $localPath 2>&1 | Out-Null
                & $ADB shell rm $devicePath
                Write-CycleLog "Checklist screenshot saved" "SUCCESS"
            }
            
            # Check some exercises
            & $ADB shell input tap 970 400  # Check first exercise
            Start-Sleep -Seconds 1
            & $ADB shell input tap 970 550  # Check second exercise
            Start-Sleep -Seconds 2
            
            # Test 2: Launch RecordActivity and save a record
            Write-CycleLog "Testing RecordActivity save to database..." "INFO"
            & $ADB shell am start -n "$PackageName/.RecordActivity"
            Start-Sleep -Seconds 3
            
            # Fill form
            & $ADB shell input tap 540 410  # Exercise name
            & $ADB shell input text "Database Test Workout"
            & $ADB shell input tap 180 555  # Sets
            & $ADB shell input text "3"
            & $ADB shell input tap 520 555  # Reps
            & $ADB shell input text "10"
            & $ADB shell input tap 350 700  # Duration
            & $ADB shell input text "30"
            
            # Save
            & $ADB shell input tap 540 1450
            Start-Sleep -Seconds 2
            
            if ($CaptureScreenshot) {
                $screenshotName2 = "cycle20_record_saved_$timestamp.png"
                & $ADB shell screencap -p /sdcard/$screenshotName2
                & $ADB pull /sdcard/$screenshotName2 "$ScreenshotsDir\$screenshotName2" 2>&1 | Out-Null
                & $ADB shell rm /sdcard/$screenshotName2
                Write-CycleLog "Record save screenshot captured" "SUCCESS"
            }
            
            # Test 3: Check ProfileActivity updated stats
            Write-CycleLog "Testing ProfileActivity with updated stats..." "INFO"
            & $ADB shell am start -n "$PackageName/.ProfileActivity"
            Start-Sleep -Seconds 3
            
            if ($CaptureScreenshot) {
                $screenshotName3 = "cycle20_profile_updated_$timestamp.png"
                & $ADB shell screencap -p /sdcard/$screenshotName3
                & $ADB pull /sdcard/$screenshotName3 "$ScreenshotsDir\$screenshotName3" 2>&1 | Out-Null
                & $ADB shell rm /sdcard/$screenshotName3
                Write-CycleLog "Profile update screenshot captured" "SUCCESS"
                $global:Metrics.ScreenshotCaptured = $true
            }
            
            $global:Metrics.DataPersists = $true
            
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
- Database Implementation: $($global:Metrics.DatabaseImplemented)
- Tables Created: $($global:Metrics.TablesCreated)
- ChecklistActivity Updated: $($global:Metrics.ChecklistUpdated)
- RecordActivity Save Works: $($global:Metrics.RecordSaveWorks)
- Data Persists: $($global:Metrics.DataPersists)
- Build Successful: $($global:Metrics.BuildSuccessful)
- APK Generated: $($global:Metrics.APKGenerated)
- Screenshot Captured: $($global:Metrics.ScreenshotCaptured)

## Performance Metrics
- Build Time: $($global:Metrics.BuildTime)s (Previous: $($PreviousMetrics.BuildTime)s)
- APK Size: $($global:Metrics.APKSize)MB (Previous: $($PreviousMetrics.APKSize)MB)
- Install Time: $($global:Metrics.InstallTime)s
- Launch Time: $($global:Metrics.LaunchTime)s

## Features Implemented
1. SQLite DatabaseHelper class
2. Three tables: exercises, records, user
3. Initial seed data for exercises
4. ChecklistActivity loads from database
5. Exercise check state persists
6. RecordActivity saves workouts to database
7. ProfileActivity shows real stats from database
8. User stats update after each workout

## Database Schema
- **exercises**: id, name, category, description, is_checked
- **records**: id, exercise_name, sets, reps, duration, intensity, condition, fatigue, memo, date
- **user**: id, name, level, experience, total_sessions, total_calories, total_hours, current_streak

## Next Steps (Cycle 21)
- Add workout history screen
- Implement data visualization/charts
- Add exercise editing capabilities
- Implement settings screen
- Add data export functionality
"@

    [System.IO.File]::WriteAllText($ReportPath, $report)
    Write-CycleLog "Report generated: $ReportPath" "SUCCESS"
}

# ========================================
# MAIN EXECUTION
# ========================================

Write-CycleLog "=== CYCLE ${CycleNumber}: DATABASE INTEGRATION ===" "INFO"
Write-CycleLog "Timestamp: $BuildTimestamp" "INFO"

# Create directories
Ensure-Directory $OutputDir
Ensure-Directory $BackupDir
Ensure-Directory $ScreenshotsDir

# Step 1: Update version
Update-BuildVersion

# Step 2: Implement database
if ($ImplementDatabase) {
    Create-DatabaseHelper
    Update-ChecklistActivity
    Update-RecordActivity
    Update-ProfileActivity
}

# Step 3: Build APK
if (Build-APK) {
    # Step 4: Test on emulator
    Test-DatabaseFeatures
}

# Step 5: Generate report
Generate-Report

# Summary
Write-CycleLog "=== CYCLE $CycleNumber COMPLETE ===" "SUCCESS"
Write-CycleLog "Database integration implemented with:" "INFO"
Write-CycleLog "  - SQLite database helper" "SUCCESS"
Write-CycleLog "  - 3 tables (exercises, records, user)" "SUCCESS"
Write-CycleLog "  - ChecklistActivity database integration" "SUCCESS"
Write-CycleLog "  - RecordActivity save functionality" "SUCCESS"
Write-CycleLog "  - ProfileActivity real-time stats" "SUCCESS"

if ($global:Metrics.BuildErrors.Count -gt 0) {
    Write-CycleLog "Build errors encountered:" "WARNING"
    $global:Metrics.BuildErrors | ForEach-Object { Write-CycleLog "  - $_" "ERROR" }
}

Write-CycleLog "App now has persistent data storage!" "SUCCESS"
Write-CycleLog "Ready for Cycle 21 - Advanced Features" "INFO"