#!/bin/bash
# TMUX-SETUP.sh - Initialize tmux environment for continuous automation
# This script sets up the tmux session structure for the automation system

set -e

# Configuration
SESSION_NAME="squash-automation"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
PRODUCTION_DIR="$PROJECT_ROOT/SquashTrainingApp/scripts/production"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Squash Automation Tmux Setup ===${NC}"
echo -e "Session: ${SESSION_NAME}"
echo -e "Project Root: ${PROJECT_ROOT}"

# Kill existing session if it exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo -e "${YELLOW}Killing existing session...${NC}"
    tmux kill-session -t "$SESSION_NAME"
fi

# Create new tmux session with main window
echo -e "${GREEN}Creating tmux session...${NC}"
tmux new-session -d -s "$SESSION_NAME" -n "controller" -c "$SCRIPT_DIR"

# Create windows for different workers
echo -e "${GREEN}Creating worker windows...${NC}"
tmux new-window -t "$SESSION_NAME:2" -n "build" -c "$SCRIPT_DIR"
tmux new-window -t "$SESSION_NAME:3" -n "test" -c "$SCRIPT_DIR"
tmux new-window -t "$SESSION_NAME:4" -n "debug" -c "$SCRIPT_DIR"
tmux new-window -t "$SESSION_NAME:5" -n "monitor" -c "$SCRIPT_DIR"
tmux new-window -t "$SESSION_NAME:6" -n "logs" -c "$SCRIPT_DIR/logs"

# Setup controller window with panes
echo -e "${GREEN}Setting up controller layout...${NC}"
tmux select-window -t "$SESSION_NAME:controller"
tmux split-window -h -p 50
tmux split-window -v -p 50
tmux select-pane -t 0
tmux split-window -v -p 50

# Label panes in controller window
tmux select-pane -t "$SESSION_NAME:controller.0"
tmux send-keys "echo 'CONTROL PANEL'" C-m
tmux select-pane -t "$SESSION_NAME:controller.1"
tmux send-keys "echo 'STATUS MONITOR'" C-m
tmux select-pane -t "$SESSION_NAME:controller.2"
tmux send-keys "echo 'PROGRESS TRACKER'" C-m
tmux select-pane -t "$SESSION_NAME:controller.3"
tmux send-keys "echo 'LOG VIEWER'" C-m

# Setup monitor window with dashboard layout
tmux select-window -t "$SESSION_NAME:monitor"
tmux split-window -h -p 50
tmux split-window -v -p 70
tmux select-pane -t 0
tmux split-window -v -p 30

# Create state directory if it doesn't exist
mkdir -p "$SCRIPT_DIR/state"
mkdir -p "$SCRIPT_DIR/logs/build-logs"
mkdir -p "$SCRIPT_DIR/logs/test-logs"
mkdir -p "$SCRIPT_DIR/logs/debug-logs"

# Initialize state file
STATE_FILE="$SCRIPT_DIR/state/automation-state.json"
if [ ! -f "$STATE_FILE" ]; then
    echo '{
  "currentIteration": 0,
  "targetIterations": 50,
  "buildSuccesses": 0,
  "buildFailures": 0,
  "testSuccesses": 0,
  "testFailures": 0,
  "status": "initialized",
  "startTime": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'",
  "lastUpdate": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'"
}' > "$STATE_FILE"
fi

# Create helper scripts in each window
echo -e "${GREEN}Preparing worker environments...${NC}"

# Build window setup
tmux send-keys -t "$SESSION_NAME:build" "clear" C-m
tmux send-keys -t "$SESSION_NAME:build" "echo -e '${BLUE}BUILD WORKER${NC}'" C-m
tmux send-keys -t "$SESSION_NAME:build" "echo 'Ready to start build process...'" C-m

# Test window setup
tmux send-keys -t "$SESSION_NAME:test" "clear" C-m
tmux send-keys -t "$SESSION_NAME:test" "echo -e '${YELLOW}TEST WORKER${NC}'" C-m
tmux send-keys -t "$SESSION_NAME:test" "echo 'Ready to start testing...'" C-m

# Debug window setup
tmux send-keys -t "$SESSION_NAME:debug" "clear" C-m
tmux send-keys -t "$SESSION_NAME:debug" "echo -e '${RED}DEBUG WORKER${NC}'" C-m
tmux send-keys -t "$SESSION_NAME:debug" "echo 'Ready to debug issues...'" C-m

# Create launch script
LAUNCH_SCRIPT="$SCRIPT_DIR/launch-automation.sh"
cat > "$LAUNCH_SCRIPT" << 'EOF'
#!/bin/bash
# Launch the automation controller

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if PowerShell is available
if command -v pwsh &> /dev/null; then
    PS_CMD="pwsh"
elif command -v powershell &> /dev/null; then
    PS_CMD="powershell"
else
    echo "Error: PowerShell not found. Please install PowerShell Core."
    exit 1
fi

echo "Starting automation controller..."
cd "$SCRIPT_DIR"
$PS_CMD -File "./TMUX-AUTOMATION-CONTROLLER.ps1"
EOF

chmod +x "$LAUNCH_SCRIPT"

# Create attach helper
ATTACH_SCRIPT="$SCRIPT_DIR/attach.sh"
cat > "$ATTACH_SCRIPT" << 'EOF'
#!/bin/bash
# Attach to the automation session

SESSION_NAME="squash-automation"

if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "Attaching to $SESSION_NAME session..."
    tmux attach-session -t "$SESSION_NAME"
else
    echo "No session found. Run TMUX-SETUP.sh first."
    exit 1
fi
EOF

chmod +x "$ATTACH_SCRIPT"

# Final setup
echo -e "${GREEN}Setup complete!${NC}"
echo ""
echo "To start the automation:"
echo "  1. Attach to session: ./attach.sh"
echo "  2. In controller window: ./launch-automation.sh"
echo ""
echo "Or run headless:"
echo "  tmux send-keys -t $SESSION_NAME:controller './launch-automation.sh' C-m"
echo ""
echo -e "${BLUE}Session '$SESSION_NAME' is ready.${NC}"

# Optionally attach to the session
if [ "$1" == "--attach" ]; then
    tmux attach-session -t "$SESSION_NAME"
fi