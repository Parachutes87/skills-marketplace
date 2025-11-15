#!/bin/bash
# Screenshot workflow for Claude Code
# Usage: Called via /screenshot command or "let me show you" trigger

set -e

# Configuration
SCREENSHOT_DIR="$HOME/Screenshots/for-claude"
mkdir -p "$SCREENSHOT_DIR"

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
SCREENSHOT_PATH="$SCREENSHOT_DIR/screenshot-$TIMESTAMP.png"

echo "🎯 Screenshot to Claude Workflow"
echo "=================================="

# Step 1: Capture screenshot and annotate
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS: Use AppleScript wrapper for GUI access
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    RESULT=$(osascript "$SCRIPT_DIR/screenshot.applescript" 2>&1)

    if [[ $? -eq 0 ]]; then
        # Extract screenshot path from AppleScript output
        echo "$RESULT"
        SCREENSHOT_PATH=$(echo "$RESULT" | grep "SCREENSHOT_PATH=" | cut -d'=' -f2)
    else
        echo "❌ Screenshot cancelled or failed"
        exit 1
    fi

elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux: Use gnome-screenshot or scrot
    if command -v gnome-screenshot &> /dev/null; then
        echo "📸 Drag to select screenshot area..."
        gnome-screenshot -a -f "$SCREENSHOT_PATH"
    elif command -v scrot &> /dev/null; then
        echo "📸 Drag to select screenshot area..."
        scrot -s "$SCREENSHOT_PATH"
    else
        echo "❌ No screenshot tool found (install gnome-screenshot or scrot)"
        exit 1
    fi

    if [[ ! -f "$SCREENSHOT_PATH" ]]; then
        echo "❌ Screenshot cancelled or not saved"
        exit 1
    fi

    echo "✅ Screenshot captured: $SCREENSHOT_PATH"
    echo "🖊️  Opening for annotation..."
    if command -v gimp &> /dev/null; then
        gimp "$SCREENSHOT_PATH" &
    else
        xdg-open "$SCREENSHOT_PATH"
    fi

    echo "Press Enter when done annotating..."
    read -r
    echo "SCREENSHOT_PATH=$SCREENSHOT_PATH"

elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    # Windows: Use Snipping Tool
    echo "📸 Use Snipping Tool, then save to:"
    echo "   $SCREENSHOT_PATH"
    powershell.exe -Command "Start-Process SnippingTool.exe"
    echo "Press Enter when screenshot is saved and annotated..."
    read -r

    if [[ ! -f "$SCREENSHOT_PATH" ]]; then
        echo "❌ Screenshot not saved"
        exit 1
    fi

    echo "SCREENSHOT_PATH=$SCREENSHOT_PATH"
else
    echo "❌ Unsupported OS: $OSTYPE"
    exit 1
fi
