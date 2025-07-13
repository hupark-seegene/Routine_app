<#
.SYNOPSIS
    Fix Record Navigation Issue
    
.DESCRIPTION
    Fix the Record screen navigation by updating MainActivity 
    to keep the current activity instead of starting new ones
#>

$ErrorActionPreference = "Continue"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Configuration
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$AppDir = Join-Path $ProjectRoot "SquashTrainingApp"
$MainActivityPath = Join-Path $AppDir "android\app\src\main\java\com\squashtrainingapp\MainActivity.java"
$BackupPath = Join-Path $AppDir "android\app\src\main\java\com\squashtrainingapp\MainActivity.java.backup"

Write-Host "Fixing Record Navigation Issue..." -ForegroundColor Cyan

# Backup original
Copy-Item $MainActivityPath $BackupPath -Force

# Fix MainActivity to handle navigation properly
$mainActivityContent = @'
package com.squashtrainingapp;

import android.content.Intent;
import android.os.Bundle;
import android.view.MenuItem;
import android.widget.FrameLayout;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import com.google.android.material.bottomnavigation.BottomNavigationView;

public class MainActivity extends AppCompatActivity {
    
    private FrameLayout contentFrame;
    private TextView contentText;
    private BottomNavigationView navigation;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main_navigation);
        
        contentFrame = findViewById(R.id.content_frame);
        contentText = findViewById(R.id.content_text);
        navigation = findViewById(R.id.bottom_navigation);
        
        navigation.setOnNavigationItemSelectedListener(new BottomNavigationView.OnNavigationItemSelectedListener() {
            @Override
            public boolean onNavigationItemSelected(@NonNull MenuItem item) {
                int itemId = item.getItemId();
                
                if (itemId == R.id.navigation_home) {
                    showContent("Home Screen");
                    return true;
                } else if (itemId == R.id.navigation_checklist) {
                    // Start ChecklistActivity with proper flags
                    Intent intent = new Intent(MainActivity.this, ChecklistActivity.class);
                    intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
                    startActivity(intent);
                    // Don't finish MainActivity
                    return true;
                } else if (itemId == R.id.navigation_record) {
                    // Start RecordActivity with proper flags
                    Intent intent = new Intent(MainActivity.this, RecordActivity.class);
                    intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
                    startActivity(intent);
                    // Don't finish MainActivity
                    return true;
                } else if (itemId == R.id.navigation_profile) {
                    showContent("Profile Screen");
                    return true;
                } else if (itemId == R.id.navigation_coach) {
                    showContent("Coach Screen");
                    return true;
                }
                
                return false;
            }
        });
        
        // Set default selection
        navigation.setSelectedItemId(R.id.navigation_home);
    }
    
    @Override
    protected void onResume() {
        super.onResume();
        // Reset to home when returning from other activities
        if (navigation != null) {
            navigation.setSelectedItemId(R.id.navigation_home);
        }
    }
    
    private void showContent(String screenName) {
        contentText.setText(screenName);
    }
}
'@

# Write the fixed MainActivity
[System.IO.File]::WriteAllText($MainActivityPath, $mainActivityContent)

Write-Host "MainActivity updated successfully!" -ForegroundColor Green

# Now rebuild the APK
Write-Host "Rebuilding APK with navigation fix..." -ForegroundColor Cyan

Set-Location $AppDir\android
$buildResult = & .\gradlew.bat assembleDebug 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "APK built successfully!" -ForegroundColor Green
    
    # Get APK size
    $apkPath = Join-Path $AppDir "android\app\build\outputs\apk\debug\app-debug.apk"
    if (Test-Path $apkPath) {
        $apkSize = [math]::Round((Get-Item $apkPath).Length / 1MB, 2)
        Write-Host "APK Size: $apkSize MB" -ForegroundColor Cyan
    }
} else {
    Write-Host "Build failed!" -ForegroundColor Red
    Write-Host $buildResult
}

Set-Location $ProjectRoot

Write-Host "`nNavigation fix complete!" -ForegroundColor Green
Write-Host "The Record screen should now work properly when tapped." -ForegroundColor Yellow