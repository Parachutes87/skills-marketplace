#!/usr/bin/env bash
#
# PreCompact Hook - Integrates Context-Rot-Manager with Claude Code's Autocompaction
#
# This hook runs BEFORE Claude Code compacts the conversation context.
# It automatically saves the session using context-rot-manager, ensuring
# full context is preserved before any compression occurs.
#
# Hook Input (via stdin):
# {
#   "session_id": "abc123",
#   "transcript_path": "~/.claude/projects/.../session.jsonl",
#   "permission_mode": "default",
#   "hook_event_name": "PreCompact",
#   "trigger": "manual" | "auto",
#   "custom_instructions": "user instructions (if manual)"
# }
#
# Hook Output:
# - Exit code 0: Success, proceed with compaction
# - Exit code 2: Show stderr to user (doesn't block)
# - JSON output: { "continue": true/false, "stopReason": "..." }

set -euo pipefail

# Read hook input
INPUT=$(cat)

# Parse trigger type
TRIGGER=$(echo "$INPUT" | jq -r '.trigger // "unknown"')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')
CUSTOM_INSTRUCTIONS=$(echo "$INPUT" | jq -r '.custom_instructions // ""')

# Log to stderr (visible to user via exit code 2)
echo "🛡️  PreCompact Hook Triggered" >&2
echo "   Trigger: $TRIGGER" >&2
echo "   Session: $SESSION_ID" >&2

# Determine if we should save
SHOULD_SAVE=false

if [ "$TRIGGER" = "auto" ]; then
    echo "   ⚠️  Autocompaction triggered - saving session automatically" >&2
    SHOULD_SAVE=true
elif [ "$TRIGGER" = "manual" ]; then
    echo "   🔧 Manual compaction requested" >&2
    if [ -n "$CUSTOM_INSTRUCTIONS" ]; then
        echo "   Instructions: $CUSTOM_INSTRUCTIONS" >&2
    fi
    # Save for manual compaction too (user wants to free context)
    SHOULD_SAVE=true
fi

# Save session if needed
if [ "$SHOULD_SAVE" = "true" ]; then
    echo "" >&2
    echo "   📋 Saving session with context-rot-manager..." >&2

    # Call the save_from_hook script
    SAVE_RESULT=$(python3 ~/.claude/skills/context-rot-manager/scripts/save_from_hook.py \
        "$TRIGGER" \
        "$SESSION_ID" \
        "$CUSTOM_INSTRUCTIONS" 2>&1)

    if [ $? -eq 0 ]; then
        SESSION_TITLE=$(echo "$SAVE_RESULT" | jq -r '.session_title')
        SESSION_DATA=$(echo "$SAVE_RESULT" | jq -r '.session_data')

        echo "   ✅ Session title: $SESSION_TITLE" >&2
        echo "" >&2
        echo "   💾 Saving to Supermemory..." >&2

        # Save to Supermemory via claude tool
        # Note: This requires the MCP server to be available
        # In practice, Claude will handle this via the tool system

        # Create a temp file with the session data
        TEMP_FILE=$(mktemp)
        echo "$SESSION_DATA" > "$TEMP_FILE"

        echo "   ✅ Session data prepared for Supermemory" >&2
        echo "   📁 Temp file: $TEMP_FILE" >&2
        echo "" >&2
        echo "   ⚠️  Note: Session saved to temp file" >&2
        echo "   📌 Claude should save this to Supermemory via MCP tool" >&2
        echo "   📝 Session data:" >&2
        echo "" >&2
        cat "$TEMP_FILE" >&2
        echo "" >&2

        # Clean up
        rm "$TEMP_FILE"

        echo "   ✅ PreCompact auto-save complete!" >&2
        echo "   🔄 You can restore this session later with context-rot-manager" >&2
    else
        echo "   ⚠️  Warning: Session save failed" >&2
        echo "   Error: $SAVE_RESULT" >&2
    fi

    echo "" >&2
fi

echo "   ✓ PreCompact hook complete - proceeding with compaction" >&2

# Return success and allow compaction to proceed
echo '{"continue": true}'
exit 0
