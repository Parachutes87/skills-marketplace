#!/bin/bash
#
# File: setup-code-web.sh
#
# Purpose: Automated setup for security-verification skill in Code Web
# Usage: bash /path/to/setup-code-web.sh
#
# This script automates the complete installation process:
# 1. Extracts security-verification skill
# 2. Installs Python dependencies (pip-audit, safety, cffi)
# 3. Runs self-verification
#
# Note: GitHub CLI (gh) installation is optional and has permission
# limitations in Code Web. Python package verification works perfectly
# without it.
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Security Verification Skill - Code Web Setup${NC}"
echo "================================================="
echo ""

# Step 1: Detect repository location
echo -e "${BLUE}[Step 1/4]${NC} Locating repository..."

REPO_PATHS=(
  "/home/user/claude-harness"
  "$HOME/claude-harness"
  "$(pwd)"
)

REPO_DIR=""
for path in "${REPO_PATHS[@]}"; do
  if [[ -f "$path/.claude/skills-sync/security-verification.skill" ]]; then
    REPO_DIR="$path"
    echo -e "${GREEN}✅ Found repository: $REPO_DIR${NC}"
    break
  fi
done

if [[ -z "$REPO_DIR" ]]; then
  echo -e "${RED}❌ Error: Could not find claude-harness repository${NC}"
  echo "   Expected locations:"
  echo "   - /home/user/claude-harness"
  echo "   - $HOME/claude-harness"
  echo ""
  echo "   Clone it first:"
  echo "   git clone https://github.com/Token-Eater/claude-harness.git"
  exit 1
fi

echo ""

# Step 2: Extract skill
echo -e "${BLUE}[Step 2/4]${NC} Extracting security-verification skill..."

mkdir -p ~/.claude/skills
cd ~/.claude/skills

if unzip -o "$REPO_DIR/.claude/skills-sync/security-verification.skill" > /dev/null 2>&1; then
  echo -e "${GREEN}✅ Skill extracted to ~/.claude/skills/security-verification/${NC}"
else
  echo -e "${RED}❌ Failed to extract skill${NC}"
  exit 1
fi

echo ""

# Step 3: Install dependencies
echo -e "${BLUE}[Step 3/4]${NC} Installing Python dependencies..."

if pip install -q -r ~/.claude/skills/security-verification/requirements.txt; then
  echo -e "${GREEN}✅ Dependencies installed:${NC}"
  pip show pip-audit safety cffi 2>/dev/null | grep "^Name:\|^Version:" | paste - - | awk '{print "   - "$1" "$2}'
else
  echo -e "${RED}❌ Failed to install dependencies${NC}"
  exit 1
fi

echo ""

# Step 4: Self-verification
echo -e "${BLUE}[Step 4/5]${NC} Running self-verification..."
echo ""

if ~/.claude/skills/security-verification/scripts/self-verify.sh --quick; then
  echo -e "${GREEN}✅ Self-verification passed${NC}"
else
  echo -e "${RED}❌ Self-verification failed${NC}"
  exit 1
fi

echo ""

# Step 5: Verify and fix requirements.txt if present
echo -e "${BLUE}[Step 5/5]${NC} Checking for requirements.txt..."

if [[ -f "$REPO_DIR/requirements.txt" ]]; then
  echo -e "${GREEN}✅ Found requirements.txt${NC}"
  echo -e "${CYAN}🔧 Running auto-fix on requirements...${NC}"
  echo ""

  # Create verified requirements file
  VERIFIED_REQ="$REPO_DIR/requirements-verified.txt"
  rm -f "$VERIFIED_REQ"

  # Process each package
  while IFS= read -r line; do
    # Skip empty lines and comments
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

    # Extract package and version
    if [[ "$line" =~ ^([a-zA-Z0-9_-]+)==([0-9.]+) ]]; then
      PKG="${BASH_REMATCH[1]}"
      VER="${BASH_REMATCH[2]}"

      echo -e "${CYAN}Verifying $PKG==$VER...${NC}"

      # Try to verify and fix
      if ~/.claude/skills/security-verification/scripts/verify-python-package-with-fix.sh \
        "$PKG" "$VER" --fix --output "$VERIFIED_REQ" --quiet; then
        echo -e "${GREEN}✅ $PKG verified${NC}"
      else
        echo -e "${YELLOW}⚠️  $PKG could not be auto-fixed, keeping original${NC}"
        echo "$line" >> "$VERIFIED_REQ"
      fi
    else
      # Keep lines that don't match package==version format
      echo "$line" >> "$VERIFIED_REQ"
    fi
  done < "$REPO_DIR/requirements.txt"

  echo ""
  echo -e "${GREEN}✅ Created verified requirements: $VERIFIED_REQ${NC}"
  echo ""
  echo "Compare versions:"
  echo "  diff $REPO_DIR/requirements.txt $VERIFIED_REQ"
  echo ""
else
  echo -e "${YELLOW}⚠️  No requirements.txt found (skipping)${NC}"
fi

# Step 6: Extract python-environment skill (teaches Claude to handle requirements.txt)
echo -e "${BLUE}[Step 6/6]${NC} Activating Python environment skill..."
echo ""

if [[ -f "$REPO_DIR/.claude/skills-sync/python-environment.skill" ]]; then
  cd ~/.claude/skills
  if unzip -o "$REPO_DIR/.claude/skills-sync/python-environment.skill" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Python environment skill activated${NC}"
    echo "   Claude now automatically knows how to handle requirements.txt files!"
  else
    echo -e "${YELLOW}⚠️  Failed to extract python-environment skill (optional)${NC}"
  fi
else
  echo -e "${YELLOW}⚠️  python-environment skill not found (optional)${NC}"
fi

echo ""
echo -e "${GREEN}✅ Setup complete!${NC}"
echo ""
echo "You can now:"
echo "  1. Just say 'install requirements' - Claude handles it automatically!"
echo "  2. Or manually verify: ~/.claude/skills/security-verification/scripts/install-requirements.sh requirements.txt"
echo ""
echo -e "${CYAN}Pro tip:${NC} With python-environment skill active, Claude recognizes requirements.txt"
echo "         and uses security-verified installation automatically. No commands to remember!"
echo ""
echo -e "${YELLOW}⚠️  Note:${NC} GitHub release verification (verify-github-release.sh) has limited"
echo "   functionality in Code Web due to gh CLI permission restrictions."
echo "   Python package verification works perfectly without gh CLI."
exit 0
