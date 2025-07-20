# UPDATE-PACKAGES.ps1
# Updates package declarations and imports for modularized Squash Training App

$PROJECT_ROOT = "C:\git\routine_app\SquashTrainingApp"
$JAVA_ROOT = "$PROJECT_ROOT\android\app\src\main\java\com\squashtrainingapp"

Write-Host "Updating package declarations and imports..." -ForegroundColor Green

# Update package declarations in moved files
$updates = @(
    @{
        Files = Get-ChildItem "$JAVA_ROOT\ui\activities\*.java"
        Package = "package com.squashtrainingapp.ui.activities;"
    },
    @{
        Files = Get-ChildItem "$JAVA_ROOT\ui\adapters\*.java"
        Package = "package com.squashtrainingapp.ui.adapters;"
    }
)

foreach ($update in $updates) {
    foreach ($file in $update.Files) {
        Write-Host "Updating $($file.Name)..." -ForegroundColor Yellow
        
        $content = Get-Content $file.FullName -Raw
        
        # Update package declaration
        $content = $content -replace "package com\.squashtrainingapp;", $update.Package
        
        # Add necessary imports
        if ($content -notmatch "import com\.squashtrainingapp\.R;") {
            $content = $content -replace "(package [^;]+;)", "`$1`n`nimport com.squashtrainingapp.R;"
        }
        
        # Update model imports
        $content = $content -replace "DatabaseHelper\.Exercise", "com.squashtrainingapp.models.Exercise"
        $content = $content -replace "DatabaseHelper\.User", "com.squashtrainingapp.models.User"
        $content = $content -replace "DatabaseHelper\.Record", "com.squashtrainingapp.models.Record"
        
        # Add model imports if needed
        if ($content -match "Exercise" -and $content -notmatch "import com\.squashtrainingapp\.models\.Exercise") {
            $content = $content -replace "(import com\.squashtrainingapp\.R;)", "`$1`nimport com.squashtrainingapp.models.Exercise;"
        }
        if ($content -match "\bUser\b" -and $content -notmatch "import com\.squashtrainingapp\.models\.User") {
            $content = $content -replace "(import com\.squashtrainingapp\.R;)", "`$1`nimport com.squashtrainingapp.models.User;"
        }
        if ($content -match "Record" -and $content -notmatch "import com\.squashtrainingapp\.models\.Record") {
            $content = $content -replace "(import com\.squashtrainingapp\.R;)", "`$1`nimport com.squashtrainingapp.models.Record;"
        }
        
        # Add database imports
        if ($content -match "DatabaseHelper") {
            $content = $content -replace "(import com\.squashtrainingapp\.R;)", "`$1`nimport com.squashtrainingapp.database.DatabaseHelper;"
        }
        
        # Update ExerciseAdapter import in ChecklistActivity
        if ($file.Name -eq "ChecklistActivity.java") {
            $content = $content -replace "import com\.squashtrainingapp\.ExerciseAdapter;", "import com.squashtrainingapp.ui.adapters.ExerciseAdapter;"
        }
        
        # Save with UTF-8 encoding without BOM
        $utf8NoBom = New-Object System.Text.UTF8Encoding $false
        [System.IO.File]::WriteAllText($file.FullName, $content, $utf8NoBom)
    }
}

# Update MainActivity to use navigation manager and correct imports
Write-Host "Updating MainActivity..." -ForegroundColor Yellow
$mainActivityPath = "$JAVA_ROOT\MainActivity.java"
$mainContent = Get-Content $mainActivityPath -Raw

# Add navigation manager import
if ($mainContent -notmatch "import com\.squashtrainingapp\.ui\.navigation\.HybridNavigationManager;") {
    $mainContent = $mainContent -replace "(package [^;]+;)", "`$1`n`nimport com.squashtrainingapp.ui.navigation.HybridNavigationManager;"
}

# Add activity imports
$activityImports = @(
    "import com.squashtrainingapp.ui.activities.ChecklistActivity;",
    "import com.squashtrainingapp.ui.activities.RecordActivity;",
    "import com.squashtrainingapp.ui.activities.ProfileActivity;",
    "import com.squashtrainingapp.ui.activities.CoachActivity;",
    "import com.squashtrainingapp.ui.activities.HistoryActivity;",
    "import com.squashtrainingapp.ui.activities.SettingsActivity;"
)

foreach ($import in $activityImports) {
    if ($mainContent -notmatch [regex]::Escape($import)) {
        $mainContent = $mainContent -replace "(import com\.squashtrainingapp\.ui\.navigation\.HybridNavigationManager;)", "`$1`n$import"
    }
}

$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($mainActivityPath, $mainContent, $utf8NoBom)

Write-Host "Package updates completed!" -ForegroundColor Green