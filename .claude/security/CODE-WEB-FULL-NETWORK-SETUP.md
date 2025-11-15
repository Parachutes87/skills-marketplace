# Code Web Full Network Mode Setup

**Purpose**: Enable secure package downloads in Claude Code Web with defense-in-depth verification.

## Why Full Network Mode?

Claude Code Web offers three network access levels:

| Mode | Access | Use Case | Risk Level |
|------|--------|----------|-----------|
| **None** | No network access | Completely isolated work | None |
| **Limited** | Allowlist only | Standard development | Low |
| **Full** | Unrestricted | Package installation, external APIs | Medium-High |

**Problem**: GitHub release assets (like spaCy models) are blocked in Limited mode with HTTP 403.

**Solution**: Create a dedicated "development-verified" environment with Full network access and security verification pipeline.

---

## Security Philosophy

**Defense in Depth**: Multiple verification layers protect against supply chain attacks:

```
Layer 1: SLSA Attestations (cryptographic provenance)
    ↓
Layer 2: Checksum Verification (integrity)
    ↓
Layer 3: OSV Database (known vulnerabilities)
    ↓
Layer 4: pip-audit + safety (multiple CVE databases)
    ↓
Layer 5: PyPI Metadata (typosquatting detection)
```

**Attestation-First Approach**: GitHub's October 2025 SLSA attestations provide cryptographic build provenance. When available, this is the strongest verification method.

---

## Setup Instructions

### 1. Create Named Environment

In Claude Code Web interface:

1. **Access Settings** → Navigate to project settings
2. **Environment Configuration** → Create new named environment
3. **Name**: `development-verified`
4. **Description**: "Full network access with security verification pipeline"
5. **Network Access**: Select **Full** (unrestricted)

### 2. Clone Repository

```bash
# In Code Web terminal
git clone https://github.com/Token-Eater/claude-harness.git
cd claude-harness

# Checkout dev branch (where skills-sync exists)
git fetch origin
git checkout dev
```

### 3. Extract Security Scripts

```bash
# Verify security scripts are present
ls -la .claude/security/
# Should show:
#   verify-github-release.sh
#   verify-python-package.sh
#   CODE-WEB-FULL-NETWORK-SETUP.md (this file)

# Make scripts executable (should already be)
chmod +x .claude/security/verify-*.sh
```

### 4. Install Verification Tools

```bash
# Install pip-audit (official Python security tool)
pip install pip-audit

# Install safety (community vulnerability database)
pip install safety

# Install GitHub CLI (for SLSA attestation checks)
# Usually pre-installed in Code Web containers
gh --version

# Install jq (for JSON parsing)
# Usually pre-installed in Code Web containers
jq --version
```

---

## Usage Workflow

### Verifying GitHub Release Assets

**Use Case**: Downloading spaCy models, pre-trained weights, large binary assets

```bash
# Step 1: Identify release information
REPO="explosion/spacy-models"
TAG="en_core_web_lg-3.8.0"
ASSET="en_core_web_lg-3.8.0-py3-none-any.whl"

# Step 2: Run verification script
.claude/security/verify-github-release.sh "$REPO" "$TAG" "$ASSET"

# Step 3: Check exit code
# 0 = PASSED (safe to download)
# 1 = FAILED (do NOT download)
# 2 = INCONCLUSIVE (manual review required)
```

**Example Output**:
```
🔒 Security Verification Pipeline
==================================
Repository: explosion/spacy-models
Tag: en_core_web_lg-3.8.0
Asset: en_core_web_lg-3.8.0-py3-none-any.whl

[Step 1/5] Checking for SLSA attestations...
✅ SLSA attestations found:
   en_core_web_lg-3.8.0-py3-none-any.whl.intoto.jsonl

[Step 2/5] Checking release signatures and metadata...
✅ Release metadata retrieved
✅ Release is verified by GitHub
   Release author: adrianeboyd
   Published: 2024-09-15

[Step 3/5] Verifying checksums...
✅ Checksum file found: SHA256SUMS
✅ Checksum verification PASSED

[Step 4/5] Checking OSV database for known vulnerabilities...
✅ No known vulnerabilities found in OSV database

[Step 5/5] Security verification summary...
Results:
  ✅ Passed checks: 4
  ❌ Failed checks: 0
  ⚠️  Warnings: 0

✅ VERIFICATION PASSED
   Asset appears safe to use (passed 4 checks)
```

### Verifying Python Packages

**Use Case**: Installing packages from PyPI before pip install

```bash
# Step 1: Verify package before installation
.claude/security/verify-python-package.sh presidio-analyzer 2.2.354

# Step 2: Check results
# 0 = PASSED (safe to install)
# 1 = FAILED (do NOT install)
# 2 = INCONCLUSIVE (manual review required)

# Step 3: If passed, install safely
pip install presidio-analyzer==2.2.354
```

**Example Output**:
```
🔒 Python Package Security Verification
========================================
Package: presidio-analyzer==2.2.354

[Step 1/3] Checking with pip-audit (OSV database)...
✅ pip-audit: No known vulnerabilities

[Step 2/3] Checking with safety (Safety DB)...
✅ safety: No known vulnerabilities

[Step 3/3] Checking package metadata...
✅ Package found on PyPI
   Author: Microsoft Corporation
   Maintainer: Microsoft Corporation
   Homepage: https://github.com/microsoft/presidio
   License: MIT
   Last upload: 2024-03-15

Security Verification Summary
==============================
Results:
  ✅ Passed checks: 3
  ❌ Failed checks: 0
  ⚠️  Warnings: 0

✅ VERIFICATION PASSED
   Package appears safe to install

   Install with: pip install presidio-analyzer==2.2.354
```

---

## When to Use Each Mode

### Limited Network Mode (Default)

**Use for:**
- Standard development work
- Working with allowlisted domains (github.com, pypi.org, npm.org)
- Package installation from PyPI/npm with standard dependencies
- Git operations
- API calls to common services

**Blocked:**
- GitHub release asset downloads (release-assets.githubusercontent.com)
- Custom CDNs and mirrors
- External APIs outside allowlist
- Direct binary downloads

### Full Network Mode (development-verified)

**Use for:**
- Installing packages with external model downloads (spaCy, transformers, etc.)
- Downloading GitHub release assets
- Working with custom package registries
- Testing external API integrations
- Research tasks requiring broad internet access

**Security Requirements:**
- ✅ Run verification scripts BEFORE downloading
- ✅ Check for SLSA attestations when available
- ✅ Verify checksums for all binary downloads
- ✅ Scan packages with pip-audit and safety
- ✅ Review PyPI metadata for suspicious indicators

---

## Security Checklist

Before downloading any external asset in Full network mode:

### GitHub Release Assets

- [ ] Run `verify-github-release.sh` script
- [ ] Check for SLSA attestations (strongest verification)
- [ ] Verify checksum matches (if no attestations)
- [ ] Confirm release is from official repository
- [ ] Check release date (recent uploads may indicate compromise)
- [ ] Review OSV database for known vulnerabilities
- [ ] Exit code = 0 (passed) before proceeding

### Python Packages

- [ ] Run `verify-python-package.sh` script
- [ ] Check pip-audit results (OSV database)
- [ ] Check safety results (Safety DB)
- [ ] Verify PyPI metadata (author, maintainer, homepage)
- [ ] Check package age and download count
- [ ] Look for typosquatting indicators
- [ ] Exit code = 0 (passed) before proceeding

### If Verification Fails

**DO NOT PROCEED** with download/installation. Instead:

1. **Review failure reason** - What check failed?
2. **Check official sources** - Is there an advisory?
3. **Search for alternatives** - Can you use a different package?
4. **Consult security team** - If enterprise/team environment
5. **Document decision** - If proceeding despite warnings

---

## Automation Integration

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

      - name: Run pip-audit
        run: pip-audit -r requirements.txt

      - name: Run safety check
        run: safety check -r requirements.txt --output text

      - name: Check for known vulnerabilities
        run: |
          # Custom script to query OSV database
          python .github/scripts/osv-check.py requirements.txt
```

### Pre-commit Hook

Create `.claude/hooks/security-check.sh`:

```bash
#!/bin/bash
# Pre-commit hook to verify packages before installation

if [[ -f "requirements.txt" ]]; then
  echo "🔒 Running security checks on requirements.txt..."

  while IFS= read -r package; do
    # Skip comments and empty lines
    [[ "$package" =~ ^#.*$ ]] && continue
    [[ -z "$package" ]] && continue

    # Run verification
    .claude/security/verify-python-package.sh "$package"

    if [[ $? -ne 0 ]]; then
      echo "❌ Security check failed for $package"
      exit 1
    fi
  done < requirements.txt

  echo "✅ All security checks passed"
fi
```

---

## Troubleshooting

### Issue: Verification Script Not Found

**Symptom**: `bash: .claude/security/verify-github-release.sh: No such file or directory`

**Solution**:
```bash
# Check if you're in the right directory
pwd
# Should be: /home/user/claude-harness

# Verify scripts exist
ls -la .claude/security/

# If not found, re-clone or switch branches
git fetch origin
git checkout dev
```

### Issue: Permission Denied

**Symptom**: `bash: .claude/security/verify-github-release.sh: Permission denied`

**Solution**:
```bash
chmod +x .claude/security/verify-github-release.sh
chmod +x .claude/security/verify-python-package.sh
```

### Issue: pip-audit Not Found

**Symptom**: `pip-audit: command not found`

**Solution**:
```bash
pip install pip-audit
# or
pip3 install pip-audit
```

### Issue: GitHub CLI Not Authenticated

**Symptom**: `gh: To get started with GitHub CLI, please run: gh auth login`

**Solution**:
```bash
# Authenticate with GitHub
gh auth login

# Select: GitHub.com
# Authentication method: Login with a web browser
# Follow the prompts
```

### Issue: SLSA Verifier Not Found

**Symptom**: `slsa-verifier: command not found`

**Note**: SLSA verifier is optional but recommended for maximum security.

**Solution**:
```bash
# Install Go (if not present)
# Check: go version

# Install slsa-verifier
go install github.com/slsa-framework/slsa-verifier/v2/cli/slsa-verifier@latest

# Add to PATH
export PATH="$PATH:$(go env GOPATH)/bin"
```

---

## Advanced: Manual Verification

If automated scripts fail or you need additional verification:

### Manual SLSA Attestation Check

```bash
# 1. List release assets
gh release view <tag> --repo <owner/repo> --json assets

# 2. Look for .intoto.jsonl files (SLSA attestations)
# Example: en_core_web_lg-3.8.0-py3-none-any.whl.intoto.jsonl

# 3. Download asset + attestation
gh release download <tag> --repo <owner/repo> --pattern "<asset-name>"
gh release download <tag> --repo <owner/repo> --pattern "<asset-name>.intoto.jsonl"

# 4. Verify with slsa-verifier
slsa-verifier verify-artifact \
  --provenance-path "<asset-name>.intoto.jsonl" \
  --source-uri "github.com/<owner/repo>" \
  "<asset-name>"
```

### Manual Checksum Verification

```bash
# 1. Download checksum file
gh release download <tag> --repo <owner/repo> --pattern "SHA256SUMS"

# 2. Download asset
gh release download <tag> --repo <owner/repo> --pattern "<asset-name>"

# 3. Verify checksum
sha256sum -c SHA256SUMS | grep "<asset-name>"
# Should output: <asset-name>: OK

# Alternative: Compute manually
sha256sum "<asset-name>"
# Compare output with SHA256SUMS file
```

### Manual OSV Database Query

```bash
# Query OSV API for vulnerabilities
PACKAGE_NAME="presidio-analyzer"
ECOSYSTEM="PyPI"

curl -s "https://api.osv.dev/v1/query" \
  -d "{\"package\":{\"name\":\"$PACKAGE_NAME\",\"ecosystem\":\"$ECOSYSTEM\"}}" \
  | jq '.vulns'

# Empty array [] = no vulnerabilities found
```

---

## Best Practices

### 1. Principle of Least Privilege

- **Default to Limited mode** for all standard work
- **Switch to Full mode** only when necessary
- **Switch back** to Limited mode after completing package installation
- **Never use Full mode** for routine development

### 2. Attestation-First Verification

- **Always check** for SLSA attestations first (strongest security)
- **Fall back** to checksum verification if no attestations
- **Use multiple** vulnerability databases (defense in depth)
- **Manual review** if verification is inconclusive

### 3. Documentation and Auditing

- **Document** why Full network mode was needed
- **Record** which packages were installed and verification results
- **Review regularly** for new vulnerabilities (weekly/monthly)
- **Update** verification scripts as new security tools emerge

### 4. Team Coordination

- **Share** verification results with team
- **Standardize** on approved packages list
- **Automate** security checks in CI/CD pipeline
- **Train** team members on verification process

---

## Related Documentation

- **Verification Scripts**:
  - `/Users/kieransteele/git/containers/projects/claude-harness/.claude/security/verify-github-release.sh`
  - `/Users/kieransteele/git/containers/projects/claude-harness/.claude/security/verify-python-package.sh`

- **Code Web Skills**:
  - `/Users/kieransteele/git/containers/projects/claude-harness/.claude/skills-sync/README.md`
  - `/Users/kieransteele/.claude/skills/claude-code-web/SKILL.md`

- **Git Workflow**:
  - `/Users/kieransteele/.claude/skills/git-workflow/SKILL.md`

---

**Last Updated**: 2025-11-05
**Maintained By**: Kieran Steele (Token-Eater)
**Security Contact**: Use GitHub Issues for security concerns
