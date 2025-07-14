#!/bin/bash
# test-system.sh - Test the tmux automation system

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SESSION_NAME="squash-automation"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Testing Tmux Automation System ===${NC}"

# 1. Check prerequisites
echo -e "\n${YELLOW}1. Checking prerequisites...${NC}"

# Check tmux
if command -v tmux &> /dev/null; then
    echo -e "${GREEN}✓ tmux installed${NC}"
else
    echo -e "${RED}✗ tmux not found. Please install tmux.${NC}"
    exit 1
fi

# Check PowerShell
if command -v pwsh &> /dev/null; then
    PS_CMD="pwsh"
    echo -e "${GREEN}✓ PowerShell Core found${NC}"
elif command -v powershell &> /dev/null; then
    PS_CMD="powershell"
    echo -e "${GREEN}✓ PowerShell found${NC}"
else
    echo -e "${RED}✗ PowerShell not found. Please install PowerShell Core.${NC}"
    exit 1
fi

# Check if session already exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo -e "${YELLOW}! Existing session found. Killing it...${NC}"
    tmux kill-session -t "$SESSION_NAME"
fi

# 2. Test setup script
echo -e "\n${YELLOW}2. Testing TMUX-SETUP.sh...${NC}"
cd "$SCRIPT_DIR"
./TMUX-SETUP.sh

# Verify session created
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo -e "${GREEN}✓ Session created successfully${NC}"
else
    echo -e "${RED}✗ Failed to create session${NC}"
    exit 1
fi

# 3. Verify windows
echo -e "\n${YELLOW}3. Verifying tmux windows...${NC}"
WINDOWS=$(tmux list-windows -t "$SESSION_NAME" -F '#W' | tr '\n' ' ')
echo "Windows created: $WINDOWS"

EXPECTED_WINDOWS=("controller" "build" "test" "debug" "monitor" "logs")
for window in "${EXPECTED_WINDOWS[@]}"; do
    if tmux list-windows -t "$SESSION_NAME" -F '#W' | grep -q "^$window$"; then
        echo -e "${GREEN}✓ Window '$window' exists${NC}"
    else
        echo -e "${RED}✗ Window '$window' missing${NC}"
    fi
done

# 4. Test state file
echo -e "\n${YELLOW}4. Checking state management...${NC}"
if [ -f "$SCRIPT_DIR/state/automation-state.json" ]; then
    echo -e "${GREEN}✓ State file created${NC}"
    echo "State content:"
    cat "$SCRIPT_DIR/state/automation-state.json" | head -5
else
    echo -e "${RED}✗ State file not found${NC}"
fi

# 5. Test helper scripts
echo -e "\n${YELLOW}5. Verifying helper scripts...${NC}"
if [ -x "$SCRIPT_DIR/launch-automation.sh" ]; then
    echo -e "${GREEN}✓ launch-automation.sh is executable${NC}"
else
    echo -e "${RED}✗ launch-automation.sh not found or not executable${NC}"
fi

if [ -x "$SCRIPT_DIR/attach.sh" ]; then
    echo -e "${GREEN}✓ attach.sh is executable${NC}"
else
    echo -e "${RED}✗ attach.sh not found or not executable${NC}"
fi

# 6. Test PowerShell scripts syntax
echo -e "\n${YELLOW}6. Testing PowerShell scripts syntax...${NC}"
PS_SCRIPTS=(
    "TMUX-AUTOMATION-CONTROLLER.ps1"
    "TMUX-BUILD-WORKER.ps1"
    "TMUX-TEST-WORKER.ps1"
    "TMUX-DEBUG-WORKER.ps1"
    "TMUX-MONITOR.ps1"
)

for script in "${PS_SCRIPTS[@]}"; do
    if $PS_CMD -NoProfile -Command "& { \$null = Get-Content '$SCRIPT_DIR/$script' -Raw | Invoke-Expression } 2>&1"; then
        echo -e "${GREEN}✓ $script syntax OK${NC}"
    else
        echo -e "${RED}✗ $script has syntax errors${NC}"
    fi
done

# 7. Test monitor
echo -e "\n${YELLOW}7. Testing monitor (5 seconds)...${NC}"
tmux send-keys -t "$SESSION_NAME:monitor" "$PS_CMD -File './TMUX-MONITOR.ps1'" C-m
echo "Monitor started in window 5. Waiting 5 seconds..."
sleep 5

# 8. Summary
echo -e "\n${BLUE}=== Test Summary ===${NC}"
echo -e "${GREEN}System setup completed successfully!${NC}"
echo ""
echo "To use the system:"
echo "1. Attach to session: ./attach.sh"
echo "2. In controller window: ./launch-automation.sh"
echo ""
echo "Or run headless:"
echo "tmux send-keys -t $SESSION_NAME:controller './launch-automation.sh' C-m"
echo ""
echo -e "${YELLOW}Note: The session is still running. Use './attach.sh' to connect.${NC}"
echo -e "${YELLOW}To stop: tmux kill-session -t $SESSION_NAME${NC}"