# Comprehensive App Testing Guide

## Quick Start

1. **Start the Android Emulator**:
   ```powershell
   cd scripts/production
   .\START-EMULATOR-AND-TEST.ps1
   ```
   This will:
   - Show available emulators
   - Let you choose which one to start
   - Wait for emulator to boot
   - Automatically run the comprehensive test

2. **Or if emulator is already running**:
   ```powershell
   cd scripts/production
   .\COMPLETE-APP-TEST-V028.ps1
   ```

## What the Test Does

The comprehensive test will:

### A. MainActivity Tests
- Launch the app
- Test home screen display
- Test History button

### B. Navigation Tests
- Test all 5 bottom navigation tabs
- Verify each screen loads correctly
- Take screenshots of each screen

### C. ChecklistActivity Tests
- Open exercise checklist
- Check/uncheck exercises
- Verify data persistence

### D. RecordActivity Tests
- Test all 3 tabs (Exercise, Ratings, Memo)
- Fill in exercise data
- Adjust rating sliders
- Add memo text
- Save workout record

### E. ProfileActivity Tests
- View user profile and stats
- Test Settings button
- Scroll through achievements

### F. CoachActivity Tests
- View coaching tips
- Test Refresh Tips button
- Test AI Coach button

### G. HistoryActivity Tests
- View saved workout records
- Test delete functionality
- Verify data persistence

### H. Navigation Persistence Tests
- **CRITICAL**: Verify Cycle 28 fix is working
- Navigate to different tabs
- Open activities
- Go back and verify tab selection remains

### I. App Restart Test
- Kill and restart app
- Verify all data persists

## Test Results

After testing completes:
- **Screenshots**: `build-artifacts/screenshots/complete-test-v028/`
- **Logs**: `build-artifacts/logs/complete-test-v028/`
- **Report**: `build-artifacts/TEST-REPORT-V028.txt`

The test will capture **50+ screenshots** documenting every feature!

## If Tests Fail

1. **No emulator running**: Start emulator first using `START-EMULATOR-AND-TEST.ps1`
2. **APK not found**: Build the app first in Android Studio
3. **Installation failed**: Check emulator is fully booted
4. **App crashes**: Check logcat output in logs directory

## Success Criteria

✅ All tests pass (100% success rate)
✅ 50+ screenshots captured
✅ Navigation persistence working (Cycle 28 fix verified)
✅ Data persists after app restart
✅ No crashes or errors

## Running Individual Tests

If you want to test specific features:

```powershell
# Test only navigation
.\SIMPLE-CYCLE-28-COMPLETE.ps1

# Debug crashes
.\DEBUG-APP-STABILITY-TEST.ps1
```