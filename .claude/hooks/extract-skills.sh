#!/bin/bash
#
# File: .claude/hooks/extract-skills.sh
#
# Purpose: Automatically extract skills from GitHub repo to ~/.claude/skills/
# Usage: Called by SessionStart hook in Code Web containers
# Context: Runs in ephemeral Code Web containers at session initialization
#
# ---

set -e  # Exit on error

echo "🎯 Skills Extraction Hook"
echo "=================================="

# Configuration
# Detect repo directory dynamically (Code Web clones to /home/user/<repo-name>/)
if [[ -d "/home/user/claude-harness/.claude/skills-sync" ]]; then
  SKILLS_SYNC_DIR="/home/user/claude-harness/.claude/skills-sync"
elif [[ -d "$PWD/.claude/skills-sync" ]]; then
  SKILLS_SYNC_DIR="$PWD/.claude/skills-sync"
else
  # Fallback to searching for it
  SKILLS_SYNC_DIR=$(find /home/user -type d -name "skills-sync" -path "*/.claude/skills-sync" 2>/dev/null | head -1)
fi
SKILLS_TARGET_DIR="$HOME/.claude/skills"

# Detect environment
if [[ "$CLAUDE_CODE_REMOTE" == "true" ]]; then
  echo "📍 Environment: Code Web (ephemeral container)"
else
  echo "📍 Environment: Local Code (skipping extraction)"
  echo "ℹ️  Local environments use ~/.claude/skills/ directly"
  exit 0
fi

# Verify skills-sync directory exists
if [[ ! -d "$SKILLS_SYNC_DIR" ]]; then
  echo "⚠️  Skills-sync directory not found: $SKILLS_SYNC_DIR"
  echo "   This is expected if the repo doesn't have .claude/skills-sync/"
  exit 0
fi

# Count available skills
SKILL_COUNT=$(ls -1 "$SKILLS_SYNC_DIR"/*.skill 2>/dev/null | wc -l)
if [[ $SKILL_COUNT -eq 0 ]]; then
  echo "ℹ️  No .skill files found in $SKILLS_SYNC_DIR"
  exit 0
fi

echo "📦 Found $SKILL_COUNT skill(s) to extract"

# Create target directory
mkdir -p "$SKILLS_TARGET_DIR"
cd "$SKILLS_TARGET_DIR"

# Extract each skill
EXTRACTED=0
SKIPPED=0

for skill_file in "$SKILLS_SYNC_DIR"/*.skill; do
  skill_name=$(basename "$skill_file" .skill)

  # Check if skill already extracted
  if [[ -d "$SKILLS_TARGET_DIR/$skill_name" ]]; then
    echo "⏭️  Skipping $skill_name (already extracted)"
    ((SKIPPED++))
    continue
  fi

  echo "📂 Extracting: $skill_name"

  # Extract skill (unzip quietly)
  if unzip -q "$skill_file" 2>/dev/null; then
    echo "   ✅ Extracted: $skill_name/"
    ((EXTRACTED++))
  else
    echo "   ❌ Failed to extract: $skill_name"
  fi
done

# Summary
echo ""
echo "✅ Skills extraction complete!"
echo "   Extracted: $EXTRACTED"
echo "   Skipped: $SKIPPED"
echo "   Target: $SKILLS_TARGET_DIR"

# List extracted skills
echo ""
echo "📋 Available skills:"
ls -1 "$SKILLS_TARGET_DIR" | sed 's/^/   - /'

echo ""
echo "💡 Tip: Skills are now available. Restart session if needed."
