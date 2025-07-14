# Tmux-Based Continuous Build Automation System

This system provides a comprehensive tmux-based automation framework for running continuous build-test-debug cycles (50+ iterations) in the background.

## System Overview

The automation system consists of:
- **TMUX-SETUP.sh**: Initializes the tmux environment
- **TMUX-AUTOMATION-CONTROLLER.ps1**: Main orchestrator managing the entire process
- **TMUX-BUILD-WORKER.ps1**: Handles Android APK builds
- **TMUX-TEST-WORKER.ps1**: Runs automated tests on emulator
- **TMUX-DEBUG-WORKER.ps1**: Analyzes failures and applies fixes
- **TMUX-MONITOR.ps1**: Real-time monitoring dashboard

## Quick Start

### 1. Initial Setup
```bash
cd SquashTrainingApp/scripts/production/tmux-automation
./TMUX-SETUP.sh
```

This creates a tmux session named `squash-automation` with dedicated windows for each component.

### 2. Attach to Session
```bash
./attach.sh
```

### 3. Start Automation
In the controller window (window 1):
```bash
./launch-automation.sh
```

Or run headless:
```bash
tmux send-keys -t squash-automation:controller './launch-automation.sh' C-m
```

### 4. Monitor Progress
The monitor window (window 5) displays real-time status. You can also run:
```bash
tmux attach -t squash-automation:monitor
```

## Tmux Windows Layout

1. **controller**: Main control panel with 4 panes
   - Control Panel: Launch automation
   - Status Monitor: Current state
   - Progress Tracker: Iteration progress
   - Log Viewer: Recent logs

2. **build**: Build worker output
3. **test**: Test worker output
4. **debug**: Debug worker output
5. **monitor**: Real-time dashboard
6. **logs**: Log file viewer

## Navigation

- Switch windows: `Ctrl+b` then window number (1-6)
- Switch panes: `Ctrl+b` then arrow keys
- Detach: `Ctrl+b` then `d`
- Scroll: `Ctrl+b` then `[`, then use arrow keys/Page Up/Down

## Configuration

### Controller Options
```powershell
# Run 100 iterations instead of 50
pwsh -File TMUX-AUTOMATION-CONTROLLER.ps1 -TargetIterations 100

# Continue from last state
pwsh -File TMUX-AUTOMATION-CONTROLLER.ps1 -ContinueFromLastState

# Enable debug mode
pwsh -File TMUX-AUTOMATION-CONTROLLER.ps1 -DebugMode
```

### Monitor Options
```powershell
# Change refresh interval
pwsh -File TMUX-MONITOR.ps1 -RefreshInterval 5

# One-time snapshot
pwsh -File TMUX-MONITOR.ps1 -Continuous:$false
```

## State Management

The system maintains state in `state/automation-state.json`:
- Current iteration
- Build/test statistics
- Error tracking
- Timestamp information

## Logs Structure

```
logs/
├── build-logs/
│   ├── build-N.log         # Build output
│   ├── metrics-N.json      # Build metrics
│   └── app-DDDNNN.apk      # Built APKs
├── test-logs/
│   ├── test-N.log          # Test output
│   ├── report-N.json       # Test results
│   └── screenshots-N/      # Test screenshots
└── debug-logs/
    ├── debug-N-phase.log   # Debug output
    └── report-N-phase.json # Debug results
```

## Common Commands

### Check Status
```bash
# View automation state
cat state/automation-state.json | jq .

# Check latest build log
tail -f logs/build-logs/build-$(cat state/automation-state.json | jq -r .currentIteration).log

# Count successful builds
ls logs/build-logs/metrics-*.json | xargs grep -l '"status":"success"' | wc -l
```

### Control Automation
```bash
# Pause automation (from controller window)
Ctrl+C

# Resume from current state
pwsh -File TMUX-AUTOMATION-CONTROLLER.ps1 -ContinueFromLastState

# Kill entire session
tmux kill-session -t squash-automation
```

### View Screenshots
```bash
# List all test screenshots
ls -la logs/test-logs/screenshots-*/

# Open specific screenshot (WSL)
explorer.exe logs/test-logs/screenshots-1/01-app-launch.png
```

## Troubleshooting

### Emulator Not Connected
```bash
# Check ADB connection
/mnt/c/Users/hwpar/AppData/Local/Android/Sdk/platform-tools/adb.exe devices

# Restart ADB
adb kill-server
adb start-server
```

### Build Failures
Check `logs/build-logs/build-N.log` for detailed error messages. The debug worker will attempt to fix common issues automatically.

### Test Failures
Review screenshots in `logs/test-logs/screenshots-N/` to see what went wrong visually.

### Session Issues
```bash
# List tmux sessions
tmux ls

# Force kill stuck session
tmux kill-session -t squash-automation

# Recreate session
./TMUX-SETUP.sh
```

## Expected Behavior

1. **Build Phase**: Compiles APK with incremented DDD version
2. **Test Phase**: Installs APK, tests all features, captures screenshots
3. **Debug Phase**: Analyzes failures and applies automated fixes
4. **Repeat**: Continues until target iterations or zero failures

The system will stop early if it achieves a perfect run (no failures) after at least 10 iterations.

## Performance Tips

- Close unnecessary applications to free memory
- Ensure emulator has sufficient resources
- Build cache is cleaned every 5 iterations
- Deep clean happens every 10 iterations

## Final Output

Upon completion:
- Summary report in `logs/automation-report-TIMESTAMP.txt`
- All APKs in `logs/build-logs/`
- Complete test screenshot history
- Metrics and statistics in JSON format