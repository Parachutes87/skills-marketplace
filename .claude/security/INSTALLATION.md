# Security Verification Pipeline - Installation Guide

A comprehensive guide to installing and configuring the defense-in-depth security verification pipeline for safe external dependency management.

## Overview

This security pipeline provides:
- ✅ **SLSA attestation verification** (cryptographic build provenance)
- ✅ **Multi-database vulnerability scanning** (OSV, Safety DB, pip-audit)
- ✅ **Typosquatting detection** (PyPI metadata analysis)
- ✅ **Checksum verification** (SHA256)
- ✅ **CI/CD automation** (GitHub Actions)

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Quick Install](#quick-install)
3. [Detailed Installation](#detailed-installation)
4. [Verification](#verification)
5. [Usage](#usage)
6. [CI/CD Integration](#cicd-integration)
7. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required
- **Unix-like OS**: macOS, Linux, or WSL2 on Windows
- **Python 3.8+**: `python3 --version`
- **pip**: Python package installer
- **Bash shell**: `/bin/bash` or `/bin/zsh`

### Optional (Recommended)
- **GitHub CLI**: `gh` command for release verification
- **jq**: JSON processing for API queries
- **Go**: For SLSA verifier tool (maximum security)

---

## Quick Install

**For the impatient** - Full installation in under 2 minutes:

```bash
# 1. Clone the repository
git clone https://github.com/Token-Eater/claude-harness.git
cd claude-harness

# 2. Copy scripts to global config
mkdir -p ~/.claude/security
cp -v .claude/security/verify-*.sh ~/.claude/security/
chmod +x ~/.claude/security/verify-*.sh

# 3. Add to PATH (zsh)
echo '
# Claude Security Scripts - Global verification tools
export PATH="$HOME/.claude/security:$PATH"' >> ~/.zshrc

# 4. Load changes
source ~/.zshrc

# 5. Install security tools
pip install pip-audit safety

# 6. Test installation
verify-python-package.sh requests 2.32.4
```

**Expected output**: `✅ VERIFICATION PASSED`

---

## Detailed Installation

### Step 1: Clone the Repository

```bash
# Clone to your preferred location
cd ~/git/projects  # or your preferred directory
git clone https://github.com/Token-Eater/claude-harness.git
cd claude-harness

# Checkout main branch (contains latest stable release)
git checkout main

# Verify security scripts exist
ls -la .claude/security/
```

**Expected files**:
- `verify-github-release.sh`
- `verify-python-package.sh`
- `CODE-WEB-FULL-NETWORK-SETUP.md`
- `README.md`

---

### Step 2: Create Global Security Directory

```bash
# Create directory in your home config
mkdir -p ~/.claude/security

# Verify creation
ls -la ~/.claude/
```

---

### Step 3: Copy Scripts to Global Config

```bash
# Copy verification scripts
cp -v .claude/security/verify-github-release.sh ~/.claude/security/
cp -v .claude/security/verify-python-package.sh ~/.claude/security/

# Make executable
chmod +x ~/.claude/security/verify-github-release.sh
chmod +x ~/.claude/security/verify-python-package.sh

# Optional: Copy documentation
cp -v .claude/security/*.md ~/.claude/security/

# Verify permissions
ls -la ~/.claude/security/
```

**Expected output**:
```
-rwxr-xr-x  verify-github-release.sh
-rwxr-xr-x  verify-python-package.sh
```

The `x` indicates executable permissions.

---

### Step 4: Add Scripts to PATH

Choose your shell and follow the appropriate instructions:

#### For Zsh (macOS default, modern Linux)

```bash
# Check if already in PATH
grep -q 'PATH.*\.claude/security' ~/.zshrc && echo "Already configured" || echo "Not configured yet"

# Add to PATH (if not configured)
echo '
# Claude Security Scripts - Global verification tools
export PATH="$HOME/.claude/security:$PATH"' >> ~/.zshrc

# Load changes
source ~/.zshrc

# Verify
which verify-python-package.sh
```

#### For Bash (older Linux, some macOS users)

```bash
# Check if already in PATH
grep -q 'PATH.*\.claude/security' ~/.bashrc && echo "Already configured" || echo "Not configured yet"

# Add to PATH (if not configured)
echo '
# Claude Security Scripts - Global verification tools
export PATH="$HOME/.claude/security:$PATH"' >> ~/.bashrc

# Load changes
source ~/.bashrc

# Verify
which verify-python-package.sh
```

**Expected output**: `/Users/yourname/.claude/security/verify-python-package.sh`

---

### Step 5: Install Security Tools

```bash
# Install pip-audit (official Python security scanner)
pip install pip-audit

# Install safety (community vulnerability database)
pip install safety

# Verify installations
pip-audit --version
safety --version
```

**Expected output**:
```
pip-audit 2.x.x
safety 3.x.x
```

---

### Step 6: Install Optional Tools

#### GitHub CLI (for release verification)

**macOS**:
```bash
brew install gh

# Authenticate
gh auth login
```

**Linux**:
```bash
# Debian/Ubuntu
sudo apt install gh

# Fedora/RHEL
sudo dnf install gh

# Authenticate
gh auth login
```

**Verify**:
```bash
gh --version
gh auth status
```

#### jq (JSON processor)

**macOS**:
```bash
brew install jq
```

**Linux**:
```bash
# Debian/Ubuntu
sudo apt install jq

# Fedora/RHEL
sudo dnf install jq
```

**Verify**:
```bash
jq --version
```

#### SLSA Verifier (maximum security)

**Requires Go installed**:

```bash
# Install Go first if not present
# macOS: brew install go
# Linux: https://go.dev/doc/install

# Install slsa-verifier
go install github.com/slsa-framework/slsa-verifier/v2/cli/slsa-verifier@latest

# Add Go bin to PATH (if not already)
export PATH="$PATH:$(go env GOPATH)/bin"

# Verify
slsa-verifier version
```

---

## Verification

### Test 1: Python Package Verification (Clean Package)

```bash
# Test with a known-good package
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
   Author: [author info]
   ...

✅ VERIFICATION PASSED
   Package appears safe to install
```

**Exit code**: `0` (success)

---

### Test 2: Python Package Verification (Vulnerable Package)

```bash
# Test with a package with known vulnerabilities
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

[Step 3/3] Checking package metadata...
✅ Package found on PyPI

❌ VERIFICATION FAILED
   Do NOT install this package without manual security review
```

**Exit code**: `1` (failure)

---

### Test 3: GitHub Release Verification

```bash
# Test with a GitHub release (requires gh CLI)
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
✅ SLSA attestations found

[Step 2/5] Checking release signatures and metadata...
✅ Release metadata retrieved
✅ Release is verified by GitHub

[Step 3/5] Verifying checksums...
✅ Checksum verification PASSED

[Step 4/5] Checking OSV database for known vulnerabilities...
✅ No known vulnerabilities found

[Step 5/5] Security verification summary...
✅ VERIFICATION PASSED
```

**Exit code**: `0` (success)

---

## Usage

### Workflow 1: Installing Python Packages

**Before installing ANY Python package**:

```bash
# Step 1: Verify the package
verify-python-package.sh <package-name> <version>

# Step 2: Check exit code
echo $?
# 0 = Safe to install
# 1 = Do NOT install (vulnerabilities found)
# 2 = Inconclusive (some checks failed/missing tools)

# Step 3: If exit code is 0, install
pip install <package-name>==<version>
```

**Example**:
```bash
# Verify Django 5.0.0
verify-python-package.sh django 5.0.0

# If passed (exit code 0)
pip install django==5.0.0
```

---

### Workflow 2: Downloading GitHub Release Assets

**Before downloading external assets**:

```bash
# Step 1: Verify the release asset
verify-github-release.sh <owner/repo> <tag> <asset-name>

# Step 2: Check exit code
echo $?

# Step 3: If passed, download with gh CLI
gh release download <tag> \
  --repo <owner/repo> \
  --pattern "<asset-name>"

# Step 4: Install
pip install <asset-name>
```

**Example - spaCy model**:
```bash
# Verify spaCy large English model
verify-github-release.sh \
  explosion/spacy-models \
  en_core_web_lg-3.8.0 \
  en_core_web_lg-3.8.0-py3-none-any.whl

# If passed, download
gh release download en_core_web_lg-3.8.0 \
  --repo explosion/spacy-models \
  --pattern "en_core_web_lg-3.8.0-py3-none-any.whl"

# Install
pip install en_core_web_lg-3.8.0-py3-none-any.whl

# Test
python3 -c "import spacy; nlp = spacy.load('en_core_web_lg'); print('✅ Success!')"
```

---

### Workflow 3: Batch Verification

**Verify all packages in requirements.txt**:

```bash
# Create verification script
cat > verify-requirements.sh << 'EOF'
#!/bin/bash
while IFS= read -r line; do
  # Skip comments and empty lines
  [[ "$line" =~ ^#.*$ ]] && continue
  [[ -z "$line" ]] && continue

  # Extract package name and version
  package=$(echo "$line" | sed 's/[=<>].*//')

  echo "Verifying $package..."
  verify-python-package.sh "$line"

  if [[ $? -ne 0 ]]; then
    echo "❌ FAILED: $package"
    exit 1
  fi
done < requirements.txt

echo "✅ All packages verified"
EOF

chmod +x verify-requirements.sh

# Run verification
./verify-requirements.sh
```

---

## CI/CD Integration

### GitHub Actions Workflow

Create `.github/workflows/security-audit.yml`:

```yaml
name: Security Audit

on:
  pull_request:
    paths:
      - 'requirements.txt'
      - 'package.json'
  schedule:
    - cron: '0 0 * * 0'  # Weekly on Sunday
  workflow_dispatch:

jobs:
  python-security:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: Install security tools
        run: |
          pip install pip-audit safety

      - name: Copy verification scripts
        run: |
          mkdir -p ~/.local/bin
          cp .claude/security/verify-python-package.sh ~/.local/bin/
          chmod +x ~/.local/bin/verify-python-package.sh
          echo "$HOME/.local/bin" >> $GITHUB_PATH

      - name: Verify all dependencies
        run: |
          while IFS= read -r package; do
            [[ "$package" =~ ^#.*$ ]] && continue
            [[ -z "$package" ]] && continue

            verify-python-package.sh "$package"
            if [[ $? -ne 0 ]]; then
              echo "❌ FAILED: $package"
              exit 1
            fi
          done < requirements.txt
```

---

### Pre-commit Hook

Create `.git/hooks/pre-commit`:

```bash
#!/bin/bash

echo "🔒 Running security checks..."

# Check if requirements.txt changed
if git diff --cached --name-only | grep -q "requirements.txt"; then
  echo "requirements.txt modified, verifying packages..."

  # Get changed lines in requirements.txt
  git diff --cached requirements.txt | grep "^+" | grep -v "^+++" | sed 's/^+//' | while read -r line; do
    [[ "$line" =~ ^#.*$ ]] && continue
    [[ -z "$line" ]] && continue

    echo "Verifying $line..."
    verify-python-package.sh "$line"

    if [[ $? -ne 0 ]]; then
      echo "❌ Security check failed for $line"
      echo "Commit aborted. Fix vulnerabilities before committing."
      exit 1
    fi
  done
fi

echo "✅ Security checks passed"
```

Make executable:
```bash
chmod +x .git/hooks/pre-commit
```

---

## Troubleshooting

### Issue: Script Not Found After Installation

**Symptom**:
```bash
$ verify-python-package.sh
command not found: verify-python-package.sh
```

**Solution**:
```bash
# Check if PATH was added to shell config
grep 'claude/security' ~/.zshrc  # or ~/.bashrc

# If not found, add it
echo 'export PATH="$HOME/.claude/security:$PATH"' >> ~/.zshrc

# Reload shell config
source ~/.zshrc

# Verify
which verify-python-package.sh
```

---

### Issue: pip-audit or safety Not Found

**Symptom**:
```
⚠️  pip-audit not installed
⚠️  safety not installed
```

**Solution**:
```bash
# Install tools
pip install pip-audit safety

# Verify
pip-audit --version
safety --version

# If still not found, check pip installation location
pip show pip-audit

# May need to use pip3
pip3 install pip-audit safety
```

---

### Issue: GitHub CLI Authentication Required

**Symptom**:
```
gh: To get started with GitHub CLI, please run: gh auth login
```

**Solution**:
```bash
# Authenticate with GitHub
gh auth login

# Select:
# - GitHub.com
# - HTTPS
# - Login with a web browser
# - Follow the browser prompts

# Verify
gh auth status
```

---

### Issue: Permission Denied When Running Scripts

**Symptom**:
```bash
$ ~/.claude/security/verify-python-package.sh
permission denied: /Users/you/.claude/security/verify-python-package.sh
```

**Solution**:
```bash
# Make scripts executable
chmod +x ~/.claude/security/*.sh

# Verify permissions
ls -la ~/.claude/security/
# Should show: -rwxr-xr-x
```

---

### Issue: Exit Code 2 (Inconclusive)

**Symptom**:
```
⚠️  VERIFICATION INCONCLUSIVE
   Some checks passed but verification incomplete
   Consider manual review before installation
```

**Meaning**: Some security checks passed, but not all tools could verify the package.

**Common causes**:
- Missing security tools (pip-audit, safety)
- Network connectivity issues
- Package not found on PyPI
- API rate limits

**Solution**:
```bash
# 1. Install missing tools
pip install pip-audit safety

# 2. Check network connectivity
curl -I https://pypi.org

# 3. Verify package exists
curl -s https://pypi.org/pypi/<package>/json | jq .info.name

# 4. Re-run verification
verify-python-package.sh <package> <version>
```

---

### Issue: Scripts Work But Exit Code Always 0

**Symptom**: Scripts always return success even for vulnerable packages.

**Solution**:
```bash
# Check script execution
bash -x ~/.claude/security/verify-python-package.sh requests 2.31.0

# Verify script hasn't been modified
cd ~/git/projects/claude-harness
git diff .claude/security/verify-python-package.sh

# If modified, restore from git
git checkout .claude/security/verify-python-package.sh

# Re-copy to global config
cp .claude/security/verify-python-package.sh ~/.claude/security/
chmod +x ~/.claude/security/verify-python-package.sh
```

---

## Advanced Configuration

### Custom Security Thresholds

Edit `~/.claude/security/verify-python-package.sh` to customize behavior:

```bash
# Line ~159: Adjust pass/fail thresholds
if [[ $FAILED -eq 0 && $PASSED -ge 2 ]]; then
  # Currently requires 2+ checks to pass
  # Increase to 3 for stricter verification:
  # if [[ $FAILED -eq 0 && $PASSED -ge 3 ]]; then
  echo -e "${GREEN}✅ VERIFICATION PASSED${NC}"
  exit 0
```

---

### Add Custom Security Checks

Add additional verification steps:

```bash
# Example: Add check for package download count
echo -e "${BLUE}[Step 4/4]${NC} Checking package popularity..."

DOWNLOADS=$(echo "$PYPI_INFO" | jq -r '.info.download_count // 0')

if [[ "$DOWNLOADS" -lt 1000 ]]; then
  echo -e "${YELLOW}⚠️  Low download count: $DOWNLOADS${NC}"
  ((WARNINGS++))
else
  echo -e "${GREEN}✅ Package has $DOWNLOADS downloads${NC}"
  ((PASSED++))
fi
```

---

## Uninstallation

To remove the security pipeline:

```bash
# 1. Remove scripts
rm -rf ~/.claude/security

# 2. Remove PATH entry from shell config
# Edit ~/.zshrc or ~/.bashrc and remove:
# export PATH="$HOME/.claude/security:$PATH"

# 3. Uninstall security tools (optional)
pip uninstall pip-audit safety

# 4. Reload shell
source ~/.zshrc  # or source ~/.bashrc
```

---

## Additional Resources

- **Repository**: https://github.com/Token-Eater/claude-harness
- **Full Documentation**: `.claude/security/README.md`
- **Code Web Setup**: `.claude/security/CODE-WEB-FULL-NETWORK-SETUP.md`
- **pip-audit**: https://pypi.org/project/pip-audit/
- **safety**: https://pyup.io/safety/
- **SLSA Framework**: https://slsa.dev/
- **OSV Database**: https://osv.dev/

---

## Support

For issues, questions, or contributions:
- **GitHub Issues**: https://github.com/Token-Eater/claude-harness/issues
- **Documentation**: All docs in `.claude/security/` directory

---

**Version**: 1.0.0
**Last Updated**: 2025-11-05
**Maintained By**: Kieran Steele (Token-Eater)
