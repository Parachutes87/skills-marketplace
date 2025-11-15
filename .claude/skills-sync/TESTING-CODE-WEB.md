# Testing Security Verification Skill in Claude Code Web

Complete guide for testing the security-verification skill in Code Web environments.

## Overview

This guide covers:
1. Testing skill extraction in default (Limited network) environment
2. Creating a Full network mode environment
3. Testing security verification with actual spaCy model downloads
4. Validating the complete workflow
5. Updating skills efficiently (streamlined method)

---

## Quick Update: Getting Latest Skill Version

**If the skill is already installed and you need to update it:**

```bash
# 1. Fetch latest from GitHub
cd /home/user/claude-harness  # adjust path if needed
git fetch origin main

# 2. Extract updated skill directly from remote (avoids merge conflicts)
git show origin/main:.claude/skills-sync/security-verification.skill > /tmp/security-verification-updated.skill

# 3. Re-extract to ~/.claude/skills (overwrites old version)
cd ~/.claude/skills
unzip -o /tmp/security-verification-updated.skill

# 4. Verify new files
ls -lh security-verification/requirements.txt
ls -lh security-verification/scripts/self-verify.sh
```

**Why this method?**
- ✅ No merge conflicts or divergent branches
- ✅ Works without full `git pull`
- ✅ Faster in ephemeral containers
- ✅ Reliable even with local changes

---

## Prerequisites

- Access to Claude Code Web: https://claude.ai/code
- GitHub account (Token-Eater) with access to claude-harness repo
- Basic familiarity with Linux terminal commands

---

## Phase 1: Test Skill Extraction (Limited Network Mode)

### Step 1: Open Code Web

1. Navigate to: https://claude.ai/code
2. Create or open project: "claude-harness-testing"
3. Use default environment (Limited network mode)

### Step 2: Clone Repository

```bash
# In Code Web terminal
git clone https://github.com/Token-Eater/claude-harness.git
cd claude-harness

# Verify skill exists
ls -lh .claude/skills-sync/security-verification.skill
# Expected: -rw-r--r-- ... 25K ... security-verification.skill
```

### Step 3: Extract Skill

```bash
# Create skills directory
mkdir -p ~/.claude/skills
cd ~/.claude/skills

# Extract security-verification skill
unzip /home/user/claude-harness/.claude/skills-sync/security-verification.skill

# Verify extraction
ls -la security-verification/
```

**Expected output**:
```
drwxr-xr-x security-verification/
-rw-r--r-- SKILL.md
drwxr-xr-x references/
drwxr-xr-x scripts/
```

### Step 4: Verify Scripts

```bash
# Check scripts are executable
ls -la security-verification/scripts/

# Expected:
# -rwxr-xr-x verify-python-package.sh
# -rwxr-xr-x verify-github-release.sh
```

### Step 5: Add to PATH

```bash
# Add to PATH for current session
export PATH="$HOME/.claude/skills/security-verification/scripts:$PATH"

# Verify
which verify-python-package.sh
# Expected: /home/user/.claude/skills/security-verification/scripts/verify-python-package.sh
```

### Step 6: Install Security Tools

```bash
# Install verification tools
pip install pip-audit safety

# Verify installations
pip-audit --version
safety --version
```

**Expected output**:
```
pip-audit 2.x.x
safety 3.x.x
```

### Step 7: Test Python Package Verification

```bash
# Test with a clean package (should pass)
verify-python-package.sh flask 3.0.0
```

**Expected output**:
```
🔒 Python Package Security Verification
========================================
Package: flask==3.0.0

[Step 1/3] Checking with pip-audit (OSV database)...
✅ pip-audit: No known vulnerabilities

[Step 2/3] Checking with safety (Safety DB)...
✅ safety: No known vulnerabilities

[Step 3/3] Checking package metadata...
✅ Package found on PyPI

✅ VERIFICATION PASSED
   Package appears safe to install
```

**Exit code check**:
```bash
echo $?
# Expected: 0
```

### Step 8: Test with Vulnerable Package

```bash
# Test with known vulnerable package
verify-python-package.sh requests 2.31.0
```

**Expected output**:
```
🔒 Python Package Security Verification
========================================
Package: requests==2.31.0

[Step 1/3] Checking with pip-audit (OSV database)...
❌ pip-audit: Vulnerabilities found
Found 2 known vulnerabilities:
- GHSA-9wx4-h78v-vm56 → Fix: 2.32.0
- GHSA-9hjg-9r4m-mvj7 → Fix: 2.32.4

[Step 2/3] Checking with safety (Safety DB)...
❌ safety: Vulnerabilities found
CVE-2024-35195, CVE-2024-47081

❌ VERIFICATION FAILED
   Do NOT install this package without manual security review
```

**Exit code check**:
```bash
echo $?
# Expected: 1
```

### ✅ Phase 1 Complete

If all tests pass, the skill is correctly installed and Python package verification works in Limited network mode.

---

## Phase 2: Create Full Network Mode Environment

### Why Full Network Mode?

**Problem**: Limited network mode blocks GitHub release assets (like spaCy models) with HTTP 403 errors.

**Solution**: Create a dedicated "development-verified" environment with Full network access + security verification.

### Step 1: Create New Environment

1. In Code Web, click **Settings** → **Environments**
2. Click **"New Environment"**
3. Configure:
   - **Name**: `development-verified`
   - **Description**: "Full network access with security verification pipeline"
   - **Network Access**: Select **Full** (unrestricted)
4. Click **Create**

### Step 2: Switch to New Environment

1. In project settings, select **Environment**: `development-verified`
2. Start new session in this environment

### Step 3: Re-setup in Full Network Environment

```bash
# Clone repository (in new environment)
git clone https://github.com/Token-Eater/claude-harness.git
cd claude-harness

# Extract skills
mkdir -p ~/.claude/skills
cd ~/.claude/skills
unzip /home/user/claude-harness/.claude/skills-sync/security-verification.skill

# Add to PATH
export PATH="$HOME/.claude/skills/security-verification/scripts:$PATH"

# Install tools
pip install pip-audit safety

# Optional: Install GitHub CLI for release verification
# (May need additional setup)
```

---

## Phase 3: Test GitHub Release Verification (Full Network Mode)

### Prerequisites

- Must be in "development-verified" environment (Full network mode)
- GitHub CLI may need authentication: `gh auth login`

### Test 1: Verify spaCy Small Model

```bash
# Test with smallest spaCy model first
verify-github-release.sh \
  explosion/spacy-models \
  en_core_web_sm-3.8.0 \
  en_core_web_sm-3.8.0-py3-none-any.whl
```

**Expected output**:
```
🔒 Security Verification Pipeline
==================================
Repository: explosion/spacy-models
Tag: en_core_web_sm-3.8.0
Asset: en_core_web_sm-3.8.0-py3-none-any.whl

[Step 1/5] Checking for SLSA attestations...
✅ SLSA attestations found:
   en_core_web_sm-3.8.0-py3-none-any.whl.intoto.jsonl

[Step 2/5] Checking release signatures and metadata...
✅ Release metadata retrieved
✅ Release is verified by GitHub
   Release author: adrianeboyd
   Published: 2024-09-15

[Step 3/5] Verifying checksums...
✅ Checksum file found: SHA256SUMS
✅ Checksum verification PASSED

[Step 4/5] Checking OSV database...
✅ No known vulnerabilities found

✅ VERIFICATION PASSED
   Asset appears safe to use (passed 4 checks)
```

**Exit code**:
```bash
echo $?
# Expected: 0
```

### Test 2: Download Verified Model

**ONLY if verification passed**:

```bash
# Download the verified model
gh release download en_core_web_sm-3.8.0 \
  --repo explosion/spacy-models \
  --pattern "en_core_web_sm-3.8.0-py3-none-any.whl"

# Verify download
ls -lh en_core_web_sm-3.8.0-py3-none-any.whl
```

**Expected**: File should be ~12 MB

### Test 3: Install and Test Model

```bash
# Install the verified model
pip install en_core_web_sm-3.8.0-py3-none-any.whl

# Test it works
python3 -c "import spacy; nlp = spacy.load('en_core_web_sm'); print('✅ Model loaded successfully')"
```

**Expected output**:
```
✅ Model loaded successfully
```

### Test 4: Verify Large Model (Optional)

```bash
# Test with large model (original blocker case)
verify-github-release.sh \
  explosion/spacy-models \
  en_core_web_lg-3.8.0 \
  en_core_web_lg-3.8.0-py3-none-any.whl
```

**Expected**: Same verification process, all checks should pass.

**Note**: Large model is ~560 MB - only download if needed for testing.

---

## Phase 4: End-to-End Workflow Test

### Scenario: Installing a Python Package with External Assets

**Workflow**: Presidio analyzer (has model dependencies)

```bash
# Step 1: Verify the package
verify-python-package.sh presidio-analyzer 2.2.354

# Step 2: Check exit code
if [[ $? -eq 0 ]]; then
  echo "✅ Verification passed, installing..."
  pip install presidio-analyzer==2.2.354
else
  echo "❌ Verification failed, installation blocked"
fi

# Step 3: Test installation
python3 -c "from presidio_analyzer import AnalyzerEngine; print('✅ Presidio installed successfully')"
```

---

## Validation Checklist

### Phase 1: Limited Network Mode ✅
- [ ] Skill extracted successfully
- [ ] Scripts have executable permissions
- [ ] Scripts added to PATH
- [ ] pip-audit and safety installed
- [ ] Clean package verification works (flask 3.0.0)
- [ ] Vulnerable package detection works (requests 2.31.0)
- [ ] Exit codes correct (0=pass, 1=fail)

### Phase 2: Full Network Environment ✅
- [ ] "development-verified" environment created
- [ ] Network access set to Full
- [ ] Skill re-extracted in new environment
- [ ] Tools re-installed
- [ ] GitHub CLI authenticated (optional)

### Phase 3: GitHub Release Verification ✅
- [ ] spaCy small model verification passes
- [ ] SLSA attestations detected
- [ ] Checksum verification works
- [ ] Model download succeeds
- [ ] Model installation and loading works

### Phase 4: End-to-End Workflow ✅
- [ ] Complete package installation workflow
- [ ] Verification → Installation → Testing
- [ ] Security checks enforce blocking

---

## Known Issues & Solutions

### Issue: HTTP 403 in Limited Mode

**Symptom**: GitHub release download blocked

**Solution**: Switch to "development-verified" environment (Full network mode)

### Issue: gh CLI Not Authenticated

**Symptom**: `gh: To get started with GitHub CLI, please run: gh auth login`

**Solution**:
```bash
gh auth login
# Follow browser authentication flow
```

### Issue: Scripts Not in PATH

**Symptom**: `command not found: verify-python-package.sh`

**Solution**:
```bash
export PATH="$HOME/.claude/skills/security-verification/scripts:$PATH"
```

### Issue: pip-audit Missing

**Symptom**: `⚠️ pip-audit not installed`

**Solution**:
```bash
pip install pip-audit safety
```

---

## Comparison: Limited vs Full Network Mode

| Feature | Limited Network | Full Network |
|---------|----------------|--------------|
| **PyPI package verification** | ✅ Works | ✅ Works |
| **GitHub release download** | ❌ Blocked (HTTP 403) | ✅ Works |
| **pip-audit** | ✅ Works | ✅ Works |
| **safety** | ✅ Works | ✅ Works |
| **SLSA attestation download** | ❌ Blocked | ✅ Works |
| **Checksum verification** | ❌ Can't download checksums | ✅ Works |
| **Use case** | Python packages from PyPI | External assets + PyPI |

---

## Success Criteria

**Phase 1 Success** (Limited Network):
- Skill extracts without errors
- Python package verification works for PyPI packages
- Vulnerability detection functional

**Phase 2 Success** (Full Network Setup):
- Environment created with Full network access
- Skill works in new environment
- Tools installed

**Phase 3 Success** (GitHub Release):
- spaCy model verification passes all 5 checks
- Model downloads successfully
- Model installs and loads in Python

**Phase 4 Success** (End-to-End):
- Complete workflow tested
- Security verification enforced
- No manual intervention needed

---

## Next Steps After Testing

1. **Document results** - Note any issues or improvements needed
2. **Prepare for marketplace** - Ensure all tests pass
3. **Create release** - Package for Claude Code Marketplace
4. **Update documentation** - Reflect any Code Web-specific quirks

---

## Marketplace Upload Preparation

Once testing is complete:

1. **Skill Package**: `security-verification.skill` (25 KB)
2. **Gists**:
   - Installation Guide: https://gist.github.com/Token-Eater/a4d1d6ce67e8450e1a8f456b468e3599
   - Skill README: https://gist.github.com/Token-Eater/3d3edb1aabe326b71377581a9ce3b805
3. **Repository**: https://github.com/Token-Eater/claude-harness
4. **Marketplace Category**: Security / DevOps
5. **Requirements**: Full network mode for GitHub release verification

---

**Version**: 1.0.0
**Last Updated**: 2025-11-05
**Testing Environment**: Claude Code Web
**Maintained By**: Kieran Steele (Token-Eater)
