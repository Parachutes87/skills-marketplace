# Blocker Handling Policy

**CRITICAL: Always ask for user guidance before accepting degraded outcomes.**

## When You Hit a Blocker

**Definition of blocker**: Any situation where the optimal path is blocked (permissions, network restrictions, missing tools, etc.)

**REQUIRED response pattern:**

1. **STOP** - Don't immediately pivot to workaround
2. **IDENTIFY** - Clearly state what's blocked and why
3. **ASK** - Present options and ask user which path to take
4. **WAIT** - Get user decision before proceeding

**Example:**
```
❌ WRONG: "SpaCy download blocked. Let me create a test without the model..."

✅ RIGHT: "❌ Blocker: SpaCy model download blocked (HTTP 403 - network restrictions)

Options:
1. Switch to Development-Verified network mode and retry
2. Request Anthropic to whitelist github.com/explosion/spacy-models
3. Work around it (degraded: no model-based PII detection)

Which approach should I take?"
```

## Why This Matters

**Degraded outcomes are acceptable ONLY when user chooses them:**
- User may prefer to fix the root cause
- User may have context you don't (e.g., whitelist already requested)
- Workarounds mask problems that should be solved permanently

**Common blockers to watch for:**
- Network restrictions (HTTP 403, blocked domains)
- Permission errors (403 push errors, sudo required)
- Missing tools (command not found)
- Version conflicts (package not available)

### Network Restriction Blockers (Code Web)

**Symptom**: HTTP 403, connection refused, domain blocked

**CRITICAL: You MUST get explicit user approval before ANY action.**

**STOP-IDENTIFY-ASK-WAIT Pattern for Network Blockers**:

1. **IDENTIFY the blocked domain**:
   - Extract from error: `HTTP 403: https://objects.githubusercontent.com/...`
   - Note the specific path if available

2. **ASK which approach and WAIT FOR RESPONSE**:
   ```
   ❌ Blocker: <operation> blocked (HTTP 403 - network restrictions)
   Domain: <specific-domain-pattern>

   Options:
   1. Test in Full network mode + verify with security pipeline
      (Requires: User switches environment, then I verify and test)
   2. Skip and document for whitelist PR (defer testing)
   3. Use degraded workaround (reduced functionality)

   ⚠️ I will WAIT for your explicit choice before proceeding.
   ⚠️ I will NOT auto-select any option, even if one seems better.

   Which approach should I take? (Please type 1, 2, or 3)
   ```

3. **STOP and WAIT**:
   - Do NOT proceed with any option until user explicitly chooses
   - Do NOT say "I'll proceed with Option X" and continue
   - Do NOT try workarounds without approval
   - User response required: "1", "2", "3", or custom instruction

4. **ONLY IF USER EXPLICITLY APPROVES Option 1**, workflow:

   **Step A: Request environment switch**
   ```
   ⚠️ Action Required: Please switch to "development-verified" or custom environment with Full network mode.

   Once you've switched, let me know and I'll proceed with security verification.

   (I cannot switch environments - only you can do this in Code Web settings)
   ```

   **Step B: WAIT for user confirmation**
   - Do NOT proceed until user says "switched", "ready", "done", or similar
   - User must explicitly confirm environment change

   **Step C: After user confirms, run verification**
   ```bash
   # Run security verification FIRST (MANDATORY)
   verify-github-release.sh <owner/repo> <tag> <asset>
   # Or: verify-python-package-with-fix.sh <package> <version>

   # ONLY if exit code 0, then attempt download
   python -m spacy download en_core_web_lg

   # Document what happened (success or still blocked)
   ```

5. **After test completes**, document findings:
   - **Domains tested**: List specific domains attempted
   - **Result**: Success (downloaded) or Still Blocked (HTTP 403)
   - **Specificity level**: Rate as ⭐⭐⭐ (specific) → ⭐ (broad)
   - **Security verification**: Exit code and results (if verification ran)
   - **Date tested**: YYYY-MM-DD
   - **Skill affected**: Name of skill requiring access
   - **Environment**: Which network mode was tested (development-verified, Full, etc.)

6. **Output whitelist PR information**:
   ```
   ✅ Verified domains for whitelist PR:

   Domain: github.com/explosion/spacy-models/releases/*
   Specificity: ⭐⭐⭐ (path-specific, recommended)
   Security: Verified with verify-github-release.sh (exit 0)
   Tested: 2025-11-06
   Skill: pii-detection-anonymization

   Alternative patterns if needed:
   - objects.githubusercontent.com (⭐⭐ - subdomain level)
   - release-assets.githubusercontent.com (⭐⭐ - subdomain level)

   Ready to create PR for "default plus whitelist" environment.
   ```

**Start specific, widen only when necessary**:
- ⭐⭐⭐ Preferred: `github.com/explosion/spacy-models/releases/*`
- ⭐⭐ If needed: `objects.githubusercontent.com`
- ⭐ Last resort: `*.githubusercontent.com`

**Security Integration**:
- Always use security-verification pipeline in Full network mode
- Exit code 0 required before proceeding
- Document verification results for whitelist PR
- See: `/Users/kieransteele/.claude/skills/security-verification/SKILL.md`

**CRITICAL: Workaround Prohibitions**:

❌ **DO NOT do these without explicit approval:**
- Create "pattern-only" or "degraded" versions without asking first
- Try "different approaches" or "workarounds" without user approval
- Bypass requirements by removing dependencies
- Create test files that avoid the blocker
- Auto-proceed with any fallback option

✅ **DO this instead:**
- STOP when hitting the blocker
- ASK which approach to take
- WAIT for explicit user response
- Document what's blocked
- Let user decide between: test, defer, or degrade

**Example of what NOT to do:**
```
❌ WRONG: "Let me try a different approach - bypass NLP engine..."
❌ WRONG: "I'll create a pattern-only version instead..."
❌ WRONG: "Let me make a test without the model..."

✅ RIGHT: "Which approach should I take? (waiting for your response)"
```

**CRITICAL: When User-Approved Action Fails**:

If the user approves an approach and it doesn't work:

**YOU MUST STOP AND ASK AGAIN**

1. **STOP** - Don't auto-pivot to variations or workarounds
2. **IDENTIFY** - Explain what failed and why (be specific)
3. **ASK** - Present NEW options based on the failure
4. **WAIT** - Get explicit approval for the next attempt

**Approval is per-attempt, not blanket permission.**

❌ **DO NOT do after failure:**
- "Let me document this and proceed with..."
- "Let me try a different approach..."
- "Let me create a simpler test..."
- Keep trying variations without asking
- Assume user wants you to keep going

✅ **DO after failure:**
```
❌ Blocker Update: Download still blocked even in Full network mode

Result: HTTP 403 from release-assets.githubusercontent.com
Environment tested: development-verified (Full network)

Options:
1. Try manual download and security verification
2. Document findings and create whitelist PR (defer testing)
3. Use pattern-only PII detection (degraded functionality)

⚠️ The original approach failed. I need new approval.

Which approach should I take? (Please type 1, 2, or 3)
```

**Real example from this session:**
```
❌ WRONG: User approved "Option 1", download failed, then Code Web:
  - "Let me document this and proceed..."
  - Created test files without asking
  - Modified files without asking
  - Kept trying workarounds

✅ RIGHT: User approved "Option 1", download failed, should have:
  - STOPPED immediately
  - Reported failure clearly
  - Asked which approach to take next
  - WAITED for new approval
```

## Decision Hierarchy

**When blocked, follow this order:**

1. **Fix root cause** - Preferred (switch mode, get permission, install tool)
2. **Document and defer** - If fixing requires external action (whitelist request)
3. **Degraded workaround** - ONLY if user explicitly approves

**Never automatically choose degraded paths.**

---

# Secret Handling Policy

**CRITICAL: This policy applies to ALL outputs, including tool results, responses, and documentation.**

## When Using Tools (Read, Bash, Grep, etc.)

**BEFORE displaying any tool output to the user:**
- Check if output contains secrets (API keys, tokens, passwords, UUIDs, connection strings)
- If secrets detected, STOP and redact them BEFORE showing output
- Never display raw tool results that contain sensitive data

**High-risk paths that ALWAYS require redaction:**
- `*_1p.env` files (1Password environment files)
- `.env` files
- `config.json` files with credentials
- Database connection strings
- API endpoint URLs with embedded tokens
- Git URLs with credentials

## Redaction Format

Replace all API keys, tokens, and secrets with `<descriptive-placeholder>`:
- Use format: `<service-name-credential-type>` (e.g., `<smithery-api-key>`)
- Use descriptive placeholders: `<smithery-api-key-from-1password>` not just `<key>`
- For line-by-line output, show structure but redact values:
  ```
  L1_mcp_key_playwright_server=<smithery-api-key-from-1password>
  L1_github_pat=<github-pat-from-1password>
  ```

## Automatically Redact

When you see these patterns, IMMEDIATELY redact:
- UUIDs (format: 8-4-4-4-12, e.g., `a1b2c3d4-e5f6-7890-abcd-ef1234567890`)
- Long hex strings (40+ characters)
- GitHub PATs (starting with `ghp_`, `github_pat_`, etc.)
- Anthropic API keys (starting with `sk-ant-`)
- Personal URLs with unique IDs
- Database connection strings with credentials
- Any environment variable ending in `_KEY`, `_TOKEN`, `_SECRET`, `_PAT`, `_PASSWORD`

## Command Execution with Secrets

**CRITICAL: Bash commands are visible to the user BEFORE execution.**

**NEVER use secrets in command parameters that will be displayed:**
- ❌ `curl -H "x-api-key: $SECRET"` (visible in tool execution)
- ❌ `git clone https://user:$TOKEN@github.com/repo` (token exposed)
- ❌ Testing APIs with real keys in visible curl commands

**Safe alternatives:**
- ✅ Use wrapper scripts that hide the secret injection
- ✅ Test only that secrets are **loaded** (check length: `${#VAR_NAME}`)
- ✅ For API testing, verify wrapper scripts work, don't run raw curl
- ✅ If you must test, ask user to run the command directly

**Testing API Keys - SAFE pattern:**
```bash
# ✅ Check key is loaded (length only)
op run --env-file=... -- bash -c 'echo "API key length: ${#L1_api_key}"'

# ❌ NEVER test like this (exposes key in command)
op run --env-file=... -- bash -c 'curl -H "x-api-key: $L1_api_key" ...'
```

## If Secrets Are Exposed

If you accidentally display secrets or user shares them:
- Acknowledge the exposure immediately
- Suggest they rotate the exposed credentials
- Reference 1Password instead of hardcoding
- Offer to help update the affected configuration safely

## Self-Referential Documentation Risk

**When writing or modifying this CLAUDE.md file or any security documentation:**

- **NEVER use real secrets as examples** - even when demonstrating what to redact
- Use obviously fake/synthetic examples:
  - UUIDs: `a1b2c3d4-e5f6-7890-abcd-ef1234567890` (sequential pattern)
  - API keys: `xxxx-yyyy-zzzz-1111` (clear placeholder pattern)
  - GitHub PATs: `ghp_exampleFakeToken123NotReal456`
  - Tokens: `abc123def456` (short, obviously fake)
- If you see a real secret in conversation context, do NOT copy it into documentation as an example
- The policy itself must not become a leak vector

**Before committing changes to security documentation:**
1. Scan all examples for UUID patterns (8-4-4-4-12)
2. Check for actual GitHub PAT prefixes followed by real tokens
3. Verify all example values are synthetic/placeholder-style
4. When in doubt, use obvious patterns like `xxxxx` or sequential values

## Example - Correct Behavior

❌ **Wrong:**
```
Read(/Users/user/envs/app_1p.env)
API_KEY=abc123def456
DATABASE_URL=postgres://user:pass@host:5432/db
```

✅ **Right:**
```
Read(/Users/user/envs/app_1p.env)
API_KEY=<api-key-from-1password>
DATABASE_URL=<postgres-connection-string-from-1password>
```

---

# System Configuration

## Sudo Askpass Helper

**Purpose**: Enable Claude to run `sudo` commands via GUI password prompts instead of requiring terminal interaction.

### Why This Matters

Claude Code's Bash tool doesn't have TTY (terminal) access, which means standard `sudo` commands fail with:
```
sudo: a terminal is required to read the password
```

**Solution**: Use macOS's native askpass mechanism to prompt for passwords via GUI dialog.

### Setup

The askpass helper is already configured at `~/.claude/utils/askpass-helper.sh` and enabled in your shell:

```bash
# In ~/.zshrc
export SUDO_ASKPASS="$HOME/.claude/utils/askpass-helper.sh"
```

### How Claude Uses It

When Claude needs administrator access, it uses `sudo -A` instead of `sudo`:

```bash
# ✅ Correct - Shows GUI password dialog
sudo -A chown -R user:group /some/path
sudo -A brew install package

# ❌ Avoid - Fails without TTY
sudo chown -R user:group /some/path
```

### Implementation

The askpass helper (`~/.claude/utils/askpass-helper.sh`):
```bash
#!/bin/bash
# AppleScript-based askpass helper for sudo commands

osascript -e 'Tell application "System Events" to display dialog "Claude Code needs administrator access:" default answer "" with title "Sudo Password Required" with icon caution with hidden answer' -e 'text returned of result' 2>/dev/null
```

### Benefits

- ✅ **No workarounds**: Direct sudo access without complexity
- ✅ **Secure**: Password never appears in logs or conversation
- ✅ **Native UX**: Standard macOS password dialog
- ✅ **Works everywhere**: Functions in Claude Code, scripts, automation

### Troubleshooting

If `sudo -A` fails:
1. Verify `SUDO_ASKPASS` is set: `echo $SUDO_ASKPASS`
2. Check helper is executable: `ls -la ~/.claude/utils/askpass-helper.sh`
3. Test manually: `sudo -A ls /root`

---

# Environment Separation & Code Web Workflow

**CRITICAL: Claude Code Desktop and Claude Code Web are separate environments that coordinate via git.**

## Understanding the Environments

### Two Separate Claude Instances

**Claude Code Desktop (CLI)**
- **Location**: Running on local machine (macOS)
- **Path**: `/Users/kieransteele/git/containers/projects/claude-harness/`
- **Filesystem**: Your local filesystem
- **MCP Access**: Full access to Desktop Commander, Supermemory, Obsidian
- **Persistence**: Files persist between sessions
- **Git**: Can push to origin

**Claude Code Web (Browser)**
- **Location**: Running in ephemeral container
- **Path**: `/home/user/claude-harness/`
- **Filesystem**: Separate container filesystem
- **MCP Access**: Limited (no Desktop Commander by default)
- **Persistence**: Container resets between sessions (git persists)
- **Git**: Can push to origin (when on proper branch)

### The Bridge: Git

Files created in one environment **DO NOT automatically appear** in the other. They must go through git:

```
Desktop → commit → push → origin → pull → Code Web
Code Web → commit → push → origin → pull → Desktop
```

## Working Across Environments

### Pattern 1: Desktop Creates, Code Web Uses

```bash
# On Desktop (CLI):
Write /Users/kieransteele/project/requirements.txt
git add requirements.txt
git commit -m "feat: Add requirements"
git push origin main

# In Code Web:
git pull origin main
# Now requirements.txt is available
```

### Pattern 2: Code Web Creates, Desktop Reviews

```bash
# In Code Web:
# Get session ID
SESSION_ID=$(git branch --show-current | grep -oE '[0-9a-zA-Z]{24}$')

# Create branch with correct naming (claude/<name>-<session-id>)
git checkout -b claude/new-feature-$SESSION_ID

# Create file and commit
git add .
git commit -m "feat: Add new feature"

# Push to origin
git push -u origin claude/new-feature-$SESSION_ID

# Click "Create PR" button (now active!)

# On Desktop:
# Review PR, merge when ready
```

### Pattern 3: Quick Tests (No Git)

For quick tests, create files directly in the target environment:

```bash
# In Code Web (for testing):
cat > /home/user/claude-harness/requirements.txt <<EOF
requests==2.32.3
pytest==8.0.0
EOF
# File exists in Code Web only, not in git
```

## Code Web "Create PR" Button

### Why It's Often Greyed Out

The "Create PR" button shows **"no remote branch yet"** when:

1. **Ephemeral Session Branch**: Code Web starts on `claude/new-session-XXXXX` branches
   - These are temporary, not tracked in origin
   - Can't create PRs from ephemeral branches

2. **No Commits**: Nothing has been committed yet

3. **Not Pushed**: Local commits not pushed to origin

### How to Activate "Create PR" Button

**CRITICAL**: Code Web requires specific branch naming pattern due to permission constraints.

**Required Pattern**: `claude/<description>-<session-id>`

**Step 1: Get Session ID and Create Branch**
```bash
# In Code Web:
# Extract session ID from current branch
SESSION_ID=$(git branch --show-current | grep -oE '[0-9a-zA-Z]{24}$')

# Create branch with correct naming pattern
git checkout -b claude/my-changes-$SESSION_ID

# Example result: claude/my-changes-011CUqMHLYQmHwzDWrCVFXuW
```

**Step 2: Make Changes and Commit**
```bash
# Create/modify files
git add .
git commit -m "feat: Add my changes"
```

**Step 3: Push to Origin**
```bash
# Push with correct branch name
git push -u origin claude/my-changes-$SESSION_ID
```

**Step 4: Click "Create PR"** ✅
- Button is now active!
- Creates PR against main (or configured base branch)
- You can review/merge from Desktop or browser

**Why This Branch Pattern?**
- Code Web has permission restrictions
- Can only push to branches starting with `claude/` and ending with session ID
- Prevents modifying arbitrary branches from ephemeral containers
- Security feature to isolate Code Web sessions

## Bidirectional Workflow Pattern

This enables Code Web to **propose changes** that Desktop can review:

```
┌─────────────────────────────────────────────────────────┐
│ Code Web Proposes                                       │
│ - Creates requirements.txt                              │
│ - Commits to feature branch                             │
│ - Pushes to origin                                      │
│ - Creates PR via button                                 │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│ Desktop Reviews                                         │
│ - Reviews PR in GitHub                                  │
│ - Runs tests, validates                                 │
│ - Merges to main                                        │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│ Code Web Applies                                        │
│ - git pull origin main                                  │
│ - Now has merged changes                                │
│ - Can use new files                                     │
└─────────────────────────────────────────────────────────┘
```

## Reminders for Claude

**When creating files:**
- ✅ Ask: "Where should this file be created?" (Desktop or Code Web?)
- ✅ If for Code Web: "Do you want me to push this via git or create it directly there?"
- ✅ Remember: Files created in one environment don't appear in the other without git

**When proposing changes from Code Web:**
- ✅ Suggest: "I can create a PR for you to review" (not "I'll create the file directly")
- ✅ Use `claude/<name>-<session-id>` pattern, NOT arbitrary branch names
- ✅ Extract session ID: `SESSION_ID=$(git branch --show-current | grep -oE '[0-9a-zA-Z]{24}$')`
- ✅ Push before clicking "Create PR"

**When user says "create feature" in Code Web:**
- ✅ Ask: "What should I name this feature?"
- ✅ Extract session ID automatically
- ✅ Create branch: `git checkout -b claude/<user-name>-$SESSION_ID`
- ✅ Confirm: "Created branch: claude/<name>-<session-id>"

**When user says "install requirements" in Code Web:**
- ✅ Check if requirements.txt exists in Code Web filesystem
- ✅ If not: "I don't see requirements.txt. Should I create one and propose it via PR?"
- ✅ Don't assume files from Desktop are available in Code Web

## Mobile/Remote Workflow

When user is **on mobile** (only has Code Web access):

1. **Code Web is self-sufficient** for creating PRs
2. **"Create PR" button** enables proposing changes without Desktop Claude
3. **GitHub mobile app** can review/merge PRs
4. **Next Code Web session** pulls merged changes

This enables fully remote workflows without needing Desktop Claude access.

## Environment Detection

**For Claude Desktop:**
- Check path: `/Users/kieransteele/` indicates Desktop environment
- Full tool access: MCP servers, Supermemory, etc.

**For Claude Code Web:**
- Check path: `/home/user/` indicates Code Web environment
- Limited tools: No Desktop Commander by default
- Use `git branch --show-current` to check for ephemeral vs feature branches

---

# Clickable File Path Output

**CRITICAL: Always output file paths in a format that VS Code terminal can detect and make clickable.**

## File Path Guidelines

When referencing files in conversation output:

1. **Always use absolute paths** - Never use relative paths or tilde (`~`)
2. **Include line numbers** when referencing specific code locations using format: `file_path:line_number`
3. **Expand `~` to full path** - Replace `~` with `/Users/kieransteele`

## Examples

❌ **Non-clickable (WRONG):**
```
~/.claude/skills/document-processing/skill.md
.claude/CLAUDE.md
../configs/settings.json
skills-for-desktop/TOP-20-SKILLS-GUIDE.md
```

✅ **Clickable (CORRECT):**
```
/Users/kieransteele/.claude/skills/document-processing/skill.md
/Users/kieransteele/git/containers/projects/claude-harness/.claude/CLAUDE.md
/Users/kieransteele/git/containers/projects/claude-harness/configs/settings.json:42
/Users/kieransteele/.claude/skills-for-desktop/TOP-20-SKILLS-GUIDE.md
```

## Code References

When discussing code, use the pattern `file_path:line_number` for easy navigation:

```
The authentication logic is in /Users/kieransteele/git/myproject/src/auth/login.ts:156
The error handling happens in /Users/kieransteele/git/myproject/src/services/api.ts:89-102
```

## Why This Matters

- VS Code terminal link detection requires absolute paths
- Users can `Cmd+Click` (macOS) or `Ctrl+Click` (Windows/Linux) to open files directly
- Line numbers enable jumping to exact locations in code
- Improves workflow efficiency by reducing manual file navigation

---

# Skill Creation Policy

**CRITICAL: This policy applies to ALL skill creation and modification tasks.**

## When Creating or Modifying Skills

**MANDATORY**: Use the skill-creator automation toolkit. Do NOT manually create skills.

### Required Workflow

**1. Creating New Skills**
```bash
# Use init_skill.py to generate proper template
python3 /Users/kieransteele/.claude/skills/skill-creator/scripts/init_skill.py \
  <skill-name> \
  --path /Users/kieransteele/.claude/skills

# This generates:
# - Proper SKILL.md with YAML frontmatter
# - Example directories: scripts/, references/, assets/
# - All files WITHOUT frontmatter (except SKILL.md)
```

**2. Validating Skills**
```bash
# ALWAYS validate before packaging or committing
python3 /Users/kieransteele/.claude/skills/skill-creator/scripts/quick_validate.py \
  /Users/kieransteele/.claude/skills/<skill-name>

# Checks:
# - YAML frontmatter format
# - Required fields (name, description)
# - Directory structure
# - No frontmatter in subdirectory markdown files
```

**3. Packaging Skills**
```bash
# Create .skill package for distribution
python3 /Users/kieransteele/.claude/skills/skill-creator/scripts/package_skill.py \
  /Users/kieransteele/.claude/skills/<skill-name> \
  /Users/kieransteele/.claude/skills-for-desktop/batch-<date>
```

### Why This Matters

**Manual skill creation causes recurring issues:**
- ❌ Forgetting to add YAML frontmatter
- ❌ Adding frontmatter to reference files (validation errors)
- ❌ Inconsistent directory structure
- ❌ Missing required fields
- ❌ Non-uniform formatting

**Automation prevents all of these:**
- ✅ Templates ensure correct structure
- ✅ Validation catches errors early
- ✅ Packaging creates consistent .skill files
- ✅ Reference files created WITHOUT frontmatter
- ✅ Uniform output across all skills

### Enforcement

**BEFORE creating any skill, ask yourself:**
1. Did I invoke skill-creator? (NO → STOP, use automation)
2. Did I run init_skill.py? (NO → STOP, use script)
3. Did I validate the skill? (NO → STOP, run quick_validate.py)

**This is a HARD REQUIREMENT, not a suggestion.**

**Location**: skill-creator automation at /Users/kieransteele/.claude/skills/skill-creator/scripts/

---

# Skills-Based Architecture

This project uses Claude's Skills system to organize domain-specific expertise. Skills are only loaded when needed, keeping context lean.

## Available Skills

Skills are automatically discovered from `~/.claude/skills/`. Use Claude's skill invocation by mentioning relevant topics:

- **document-processing**: PDF, Excel, Word, PowerPoint file handling
- **mcp-server-setup**: Configuring MCP servers across environments
- **git-workflow**: Branch management and PR workflows
- **azure-devops-backlog-importer**: Import tasks to Azure DevOps

## Creating New Skills

When working on domain-specific tasks, consider creating a new skill if:
- The expertise is used intermittently (not every conversation)
- The knowledge is substantial (would bloat CLAUDE.md)
- The domain is self-contained (document processing, deployment, testing, etc.)

Skills should be created in `~/.claude/skills/[skill-name]/` for personal use, or `.claude/skills/[skill-name]/` for team-shared project skills.

---

# Skills Marketplace Context

This repository contains a **platform for sharing and discovering Claude Code skills**. It enables the community to publish, browse, and download .skill packages.

## Project Vision

Create a centralized marketplace where:
- **Skill Creators** can publish their .skill packages
- **Users** can discover, download, and install skills
- **The Community** can rate, review, and recommend skills
- **Quality** is ensured through validation and testing

## Core Features (Planned)

### Phase 1: MVP
- [ ] Skill metadata model (name, description, author, version, tags)
- [ ] Basic skill upload/download system
- [ ] Skill validation (YAML frontmatter, structure)
- [ ] Simple web interface for browsing

### Phase 2: Community
- [ ] User accounts and authentication
- [ ] Ratings and reviews
- [ ] Search and filtering
- [ ] Featured/trending skills

### Phase 3: Advanced
- [ ] Skill dependencies and compatibility checking
- [ ] Automated testing for uploaded skills
- [ ] CLI tool for publishing skills
- [ ] Analytics and usage tracking

## Technology Stack

**Current**: To be determined
**Considering**:
- Backend: Python (FastAPI/Flask) or Node.js
- Frontend: React/Vue or static generator
- Database: SQLite (dev), PostgreSQL (prod)
- Hosting: Vercel/Netlify/Railway

## Development Workflow

This project uses the claude-harness workflow infrastructure:
- **.claude/**: Claude Code configuration and policies
- **Git workflow**: Feature branches → main
- **Skills**: Leverages personal skills from `~/.claude/skills/`

## Current Status

🚧 **Project Status:** Initial Setup (November 2025)

- ✅ Project structure created
- ✅ README and CLAUDE.md configured
- [ ] Technology stack selected
- [ ] Data model defined
- [ ] MVP implementation started

## Key Files

- `/README.md` - Project overview and documentation
- `/.claude/CLAUDE.md` - This file (Claude-specific instructions)
- `/src/` - Source code (to be created)
- `/tests/` - Test suite (to be created)
- `/docs/` - Additional documentation (to be created)
