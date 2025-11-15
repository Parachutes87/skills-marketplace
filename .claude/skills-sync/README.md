# Skills Sync for Claude Code Web

This directory contains packaged skills (`.skill` files) that can be extracted into Claude Code Web ephemeral containers.

## Why Skills Sync?

Claude Code Web runs in ephemeral containers that don't have access to your local `~/.claude/skills/` directory. This sync mechanism stores skill zip files in the GitHub repo, allowing them to be extracted into the container on demand.

## Quick Setup for Code Web (Automated)

**One command to set everything up:**

```bash
# Clone repo first (if not already cloned)
git clone https://github.com/Token-Eater/claude-harness.git

# Run automated setup (extracts skill, installs deps, runs self-check)
bash claude-harness/.claude/hooks/setup-code-web.sh
```

**What it does** (in ~15 seconds):
1. ✅ Locates the repository
2. ✅ Extracts security-verification skill to ~/.claude/skills/
3. ✅ Installs pip-audit, safety, cffi (latest versions)
4. ✅ Runs self-verification --quick

**Then use it:**
```bash
# Verify Python packages (works perfectly in Code Web)
~/.claude/skills/security-verification/scripts/verify-python-package.sh requests 2.32.0
```

### Limitations in Code Web

**⚠️ GitHub Release Verification**: The `verify-github-release.sh` script has limited functionality in Code Web due to:
- gh CLI commands require GitHub authentication
- `gh auth` and `gh release` commands are blocked by permissions
- GitHub API rate limits for unauthenticated access

**✅ What Works Perfectly**:
- Python package verification (`verify-python-package.sh`)
- pip-audit security scanning
- safety vulnerability checks
- PyPI metadata analysis

**For GitHub release verification**, use the skill in:
- Local Claude Code (Desktop)
- Full network mode environments with gh CLI authenticated
- CI/CD pipelines with GITHUB_TOKEN

---

## Available Skills

| Skill | Description | Works in Code Web? |
|-------|-------------|-------------------|
| `claude-code-web.skill` | Comprehensive Code Web documentation | ✅ Yes (documentation) |
| `screenshot-tool.skill` | Cross-platform screenshot workflow | ⚠️ Partial (manual attach only) |
| `thoughts-locator.skill` | Find thought documents in repos | ✅ Yes (filesystem-based) |
| `thoughts-analyzer.skill` | Deep document analysis | ✅ Yes (filesystem-based) |
| `pii-detection-anonymization.skill` | Detect/anonymize PII with Presidio | ✅ Yes (Python packages) |
| `document-processing.skill` | PDF/Excel/Word/PowerPoint processing | ✅ Yes (Python packages) |
| `azure-devops-backlog-importer.skill` | CSV export for Azure DevOps | ✅ Yes (CSV processing) |
| `security-verification.skill` | Defense-in-depth security verification for packages | ✅ Yes (requires Full network mode) |

## Updating Existing Skills (Streamlined Method)

**If skills are already installed and you need the latest version:**

```bash
# 1. Fetch latest changes (in your repo directory)
cd /home/user/claude-harness  # adjust to your repo path
git fetch origin main

# 2. Extract updated skill directly from remote (avoids merge conflicts)
git show origin/main:.claude/skills-sync/SKILL-NAME.skill > /tmp/SKILL-NAME-updated.skill

# 3. Re-extract to ~/.claude/skills (overwrites old version)
cd ~/.claude/skills
unzip -o /tmp/SKILL-NAME-updated.skill

# Example for security-verification:
git show origin/main:.claude/skills-sync/security-verification.skill > /tmp/security-verification-updated.skill
cd ~/.claude/skills
unzip -o /tmp/security-verification-updated.skill
```

**Benefits:**
- ✅ No merge conflicts or divergent branches issues
- ✅ Works without full `git pull`
- ✅ Fast and reliable in ephemeral containers

---

## Manual Extraction

### Quick Start (All Skills)

```bash
# In Code Web container
cd ~/.claude
mkdir -p skills
cd skills

# Extract all skills from repo (adjust path to your repo name)
for skill in /home/user/claude-harness/.claude/skills-sync/*.skill; do
  unzip -q "$skill"
done

# Or extract individually:
# unzip /home/user/claude-harness/.claude/skills-sync/claude-code-web.skill
# unzip /home/user/claude-harness/.claude/skills-sync/pii-detection-anonymization.skill
# unzip /home/user/claude-harness/.claude/skills-sync/document-processing.skill
# ... etc

# Skills now available (may require session restart)
```

### Individual Skill Extraction

```bash
# Extract specific skill (adjust path to your repo name)
cd ~/.claude/skills
unzip /home/user/claude-harness/.claude/skills-sync/claude-code-web.skill

# Verify extraction
ls -la claude-code-web/
```

## Automated Extraction (Recommended)

Use the provided automation script to extract skills automatically at session start.

### Setup

1. **Add SessionStart hook** to `.claude/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": ".*",
        "hooks": [
          {
            "type": "command",
            "command": "bash /home/user/.github/.claude/hooks/extract-skills.sh",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

2. **Run manually** (or restart session):

```bash
# Script now auto-detects repo path
bash /home/user/claude-harness/.claude/hooks/extract-skills.sh
```

## Troubleshooting

### Skills Not Appearing

**Problem**: Skills extracted but not showing up in Claude
**Solution**: Restart the session or check skill directory structure

```bash
ls -la ~/.claude/skills/
# Each skill should be a directory with SKILL.md or skill.md
```

### File Not Found Errors

**Problem**: Cannot find skills-sync directory
**Solution**: Ensure repo is cloned and skills-sync directory exists

```bash
# Check in your repo directory (replace 'claude-harness' with your repo name)
ls -la /home/user/claude-harness/.claude/skills-sync/
# Should show .skill files

# Or use find to locate it
find /home/user -type d -name "skills-sync" -path "*/.claude/skills-sync"
```

### Unzip Command Not Found

**Problem**: `unzip` command not available
**Solution**: Code Web containers should have unzip pre-installed. If not:

```bash
# Alternative: Use Python's zipfile module
python3 -c "import zipfile; zipfile.ZipFile('/path/to/skill.skill').extractall('~/.claude/skills/')"
```

## Skill Compatibility

### ✅ Code Web Compatible

- **Filesystem-based skills**: thoughts-locator, thoughts-analyzer
- **Documentation skills**: claude-code-web
- **Partial functionality**: screenshot-tool (manual attach)

### ❌ Code Web Incompatible

- **AgentDB-dependent**: context-rot-manager, reasoningbank-agentdb
- **MCP-required**: Skills that need Desktop Commander, Supermemory MCP
- **Persistent storage**: Skills requiring session memory between containers

## Adding New Skills

### 1. Package Skill

```bash
# From local machine (not Code Web)
python3 ~/.claude/skills/skill-creator/scripts/package_skill.py \
  ~/.claude/skills/your-skill-name \
  /path/to/repo/.claude/skills-sync
```

### 2. Validate Skill

```bash
python3 ~/.claude/skills/skill-creator/scripts/quick_validate.py \
  ~/.claude/skills/your-skill-name
```

### 3. Commit and Push

```bash
git add .claude/skills-sync/your-skill-name.skill
git commit -m "feat: Add your-skill-name to skills-sync"
git push
```

### 4. Update README

Add your skill to the "Available Skills" table above.

## Best Practices

1. **Only sync filesystem-based skills** - Don't sync AgentDB or MCP-dependent skills
2. **Validate before packaging** - Use `quick_validate.py` to catch errors
3. **Test in Code Web** - Verify extraction and functionality
4. **Document limitations** - Note if skill has reduced functionality in Code Web
5. **Keep skills updated** - Re-package when skills are updated locally

## Skill Development & Deployment Workflow

**CRITICAL: Understanding the complete workflow prevents confusion between local development and Code Web deployment.**

### The Complete Cycle

```
┌─────────────────────────────────────────────────────────┐
│ 1. DEVELOP LOCALLY                                      │
│    Edit files in: ~/.claude/skills/<skill-name>/       │
│    - Add features                                        │
│    - Fix bugs                                            │
│    - Test locally                                        │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│ 2. PACKAGE                                              │
│    python3 ~/.claude/skills/skill-creator/scripts/      │
│            package_skill.py <skill-path> <output-dir>   │
│    - Creates .skill ZIP file                            │
│    - Stores in .claude/skills-sync/                     │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│ 3. COMMIT & PUSH                                        │
│    git add .claude/skills-sync/<skill-name>.skill       │
│    git commit -m "feat: Update skill with new features" │
│    git push                                              │
│    - New .skill package now on GitHub                   │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│ 4. DEPLOY TO CODE WEB                                   │
│    # In Code Web container:                             │
│    git pull origin main                                  │
│    cd ~/.claude/skills                                   │
│    unzip -o /home/user/<repo>/.claude/skills-sync/      │
│             <skill-name>.skill                           │
│    - Code Web now has latest features!                  │
└─────────────────────────────────────────────────────────┘
```

### Common Pitfall

❌ **Testing old skill in Code Web after local changes**

**What happens:**
1. You develop Phase 2 features locally ✅
2. You package and push to GitHub ✅
3. You test in Code Web... but features aren't there ❌

**Why:** Code Web still has the OLD extracted skill. You need to **pull + re-extract**.

**Solution:**
```bash
# In Code Web
cd /home/user/claude-harness
git pull origin main
cd ~/.claude/skills
unzip -o /home/user/claude-harness/.claude/skills-sync/security-verification.skill

# Now test - features are present!
```

### Key Points

1. **Local development ≠ Code Web automatically**
   - Changes in ~/.claude/skills/ are local only
   - Must package → commit → push → pull + extract

2. **The .skill package is the bridge**
   - ZIP file containing skill directory
   - Stored in git for distribution
   - Must be re-extracted to apply updates

3. **Always re-extract after pulling**
   - `git pull` gets new .skill package
   - `unzip -o` applies the updates
   - Without re-extract, old version remains active

4. **Verify deployment worked**
   ```bash
   # Check file exists with recent timestamp
   ls -la ~/.claude/skills/<skill-name>/scripts/new-feature.py

   # Test new functionality
   ~/.claude/skills/<skill-name>/scripts/new-feature.py --help
   ```

### Example: Security Verification Phase 2

**Local development:**
```bash
# Edit cache_manager.py locally
vim ~/.claude/skills/security-verification/scripts/cache_manager.py

# Test locally
~/.claude/skills/security-verification/scripts/cache_manager.py list
# ✅ Works!
```

**Code Web deployment:**
```bash
# Package, commit, push (on local machine)
python3 package_skill.py ~/.claude/skills/security-verification \
  /path/to/repo/.claude/skills-sync
git add .claude/skills-sync/security-verification.skill
git commit -m "feat: Add Phase 2 cache features"
git push

# Deploy to Code Web (in Code Web container)
cd /home/user/claude-harness
git pull origin main
cd ~/.claude/skills
unzip -o /home/user/claude-harness/.claude/skills-sync/security-verification.skill

# Test in Code Web
python3 ~/.claude/skills/security-verification/scripts/cache_manager.py list
# ✅ Now works in Code Web too!
```

### Quick Reference

| Stage | Location | Command |
|-------|----------|---------|
| **Develop** | Local machine | Edit ~/.claude/skills/<skill>/ |
| **Package** | Local machine | python3 package_skill.py |
| **Commit** | Local machine | git add + commit + push |
| **Deploy** | Code Web | git pull + unzip -o |
| **Test** | Code Web | Run skill commands |

**Remember**: Code Web deployment requires **both** `git pull` (to get new package) AND `unzip -o` (to extract updates).

---

## File Locations Reference

| Location | Path |
|----------|------|
| **Skills-sync directory** | `/home/user/<repo-name>/.claude/skills-sync/` |
| **Extraction target** | `/home/user/.claude/skills/` |
| **Automation script** | `/home/user/<repo-name>/.claude/hooks/extract-skills.sh` |
| **Settings file** | `/home/user/<repo-name>/.claude/settings.json` |

**Note**: Replace `<repo-name>` with your actual repository name (e.g., `claude-harness`).

## Related Documentation

- [Claude Code Web Skill](/Users/kieransteele/.claude/skills/claude-code-web/SKILL.md)
- [Skill Creator Guide](/Users/kieransteele/.claude/skills/skill-creator/SKILL.md)
- [Git Workflow](/Users/kieransteele/.claude/skills/git-workflow/SKILL.md)

---

**Last Updated**: 2025-11-05
**Maintained By**: Kieran Steele (Token-Eater)
