# Security Verification Pipeline

**Defense-in-depth security verification for external dependencies and assets.**

## Overview

This directory contains a comprehensive security verification pipeline designed to protect against supply chain attacks when working with external packages and assets, particularly in Claude Code Web environments.

## Philosophy

**Attestation-First, Defense-in-Depth**:

1. **SLSA Attestations** (strongest) - Cryptographic build provenance from GitHub
2. **Checksum Verification** - Integrity checks for downloaded assets
3. **Vulnerability Scanning** - Multiple CVE databases (OSV, Safety DB, pip-audit)
4. **Metadata Analysis** - Typosquatting detection and author verification
5. **Manual Review** - Human oversight for inconclusive results

## Components

### Verification Scripts

| Script | Purpose | Use Case |
|--------|---------|----------|
| `verify-github-release.sh` | Verify GitHub release assets | spaCy models, ML weights, binary downloads |
| `verify-python-package.sh` | Verify Python packages before install | PyPI packages, dependencies |
| `CODE-WEB-FULL-NETWORK-SETUP.md` | Documentation for Full network mode | Code Web environment setup |

### Automated Workflows

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `.github/workflows/security-audit.yml` | PR, push, weekly | Continuous security monitoring |

## Quick Start

### 1. Verify GitHub Release Asset

```bash
# Example: Verify spaCy model before download
.claude/security/verify-github-release.sh \
  explosion/spacy-models \
  en_core_web_lg-3.8.0 \
  en_core_web_lg-3.8.0-py3-none-any.whl

# Exit codes:
# 0 = PASSED (safe to download)
# 1 = FAILED (do NOT download)
# 2 = INCONCLUSIVE (manual review required)
```

### 2. Verify Python Package

```bash
# Example: Verify package before pip install
.claude/security/verify-python-package.sh presidio-analyzer 2.2.354

# If passed (exit code 0), install:
pip install presidio-analyzer==2.2.354
```

### 3. Set Up Full Network Mode (Code Web)

See [`CODE-WEB-FULL-NETWORK-SETUP.md`](/Users/kieransteele/git/containers/projects/claude-harness/.claude/security/CODE-WEB-FULL-NETWORK-SETUP.md) for complete instructions.

**Summary**:
1. Create "development-verified" environment with Full network access
2. Clone repository and checkout dev branch
3. Install verification tools (pip-audit, safety, gh)
4. Run verification scripts before downloading external assets

## Security Checks Performed

### verify-github-release.sh (5 Steps)

1. **SLSA Attestations** - Check for cryptographic build provenance
2. **Release Signatures** - Verify GitHub release metadata and author
3. **Checksum Verification** - Validate SHA256 checksums
4. **OSV Database** - Check for known vulnerabilities
5. **Security Summary** - Color-coded results and exit code

### verify-python-package.sh (3 Steps)

1. **pip-audit** - Official Python tool, OSV database
2. **safety** - Community-maintained vulnerability database
3. **PyPI Metadata** - Author, maintainer, typosquatting detection

### GitHub Actions Workflow (4 Jobs)

1. **Python Security** - pip-audit, safety, OSV API, typosquatting
2. **Node.js Security** - npm audit for JavaScript dependencies
3. **GitHub Releases Check** - Verify security scripts exist
4. **Report Generation** - Consolidated security summary

## Output Interpretation

### Color Coding

- 🟢 **GREEN** (✅) - Check passed, no issues found
- 🔴 **RED** (❌) - Check failed, vulnerabilities detected
- 🟡 **YELLOW** (⚠️) - Warning, inconclusive, or tool not available

### Exit Codes

| Exit Code | Status | Action |
|-----------|--------|--------|
| `0` | PASSED | Safe to proceed (2+ checks passed) |
| `1` | FAILED | Do NOT proceed (vulnerabilities found) |
| `2` | INCONCLUSIVE | Manual review required (1 check passed, warnings present) |

### Example Output

```bash
$ .claude/security/verify-github-release.sh explosion/spacy-models en_core_web_lg-3.8.0 en_core_web_lg-3.8.0-py3-none-any.whl

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

## Use Cases

### Code Web Development (Primary)

**Problem**: Code Web Limited network mode blocks GitHub release assets with HTTP 403.

**Solution**:
1. Create "development-verified" environment with Full network access
2. Run verification scripts before downloading
3. Switch back to Limited mode after installation

**See**: [`CODE-WEB-FULL-NETWORK-SETUP.md`](/Users/kieransteele/git/containers/projects/claude-harness/.claude/security/CODE-WEB-FULL-NETWORK-SETUP.md)

### Local Development

**Use verification scripts before installing new packages**:

```bash
# Check package before adding to requirements.txt
.claude/security/verify-python-package.sh numpy 1.26.0

# Add to requirements.txt
echo "numpy==1.26.0" >> requirements.txt

# Install safely
pip install -r requirements.txt
```

### CI/CD Pipeline

**Automated security checks on every PR**:

```yaml
# .github/workflows/security-audit.yml automatically runs:
# - pip-audit on all Python dependencies
# - safety check for known vulnerabilities
# - OSV API queries for each package
# - Typosquatting detection
# - npm audit for Node.js dependencies
```

## When to Use Each Mode

### Limited Network Mode (Default)

✅ **Use for:**
- Standard development work
- Working with PyPI/npm packages
- Git operations
- Common API calls

❌ **Blocked:**
- GitHub release asset downloads
- Custom CDNs
- External binary downloads

### Full Network Mode (development-verified)

✅ **Use for:**
- Installing packages with external model downloads (spaCy, transformers)
- Downloading GitHub release assets
- Custom package registries
- External API testing

⚠️ **Security Requirements:**
- Run verification scripts BEFORE downloading
- Check for SLSA attestations when available
- Verify checksums for all binary downloads
- Scan packages with pip-audit and safety

## Installation

### Prerequisites

```bash
# Install security tools
pip install pip-audit safety

# Verify GitHub CLI (usually pre-installed in Code Web)
gh --version

# Optional: Install SLSA verifier for maximum security
go install github.com/slsa-framework/slsa-verifier/v2/cli/slsa-verifier@latest
```

### Make Scripts Executable

```bash
chmod +x .claude/security/verify-github-release.sh
chmod +x .claude/security/verify-python-package.sh
```

## Troubleshooting

### Script Not Found

```bash
# Check current directory
pwd
# Should be: /home/user/claude-harness (Code Web)
# Or: /Users/kieransteele/git/containers/projects/claude-harness (local)

# Verify scripts exist
ls -la .claude/security/
```

### Permission Denied

```bash
chmod +x .claude/security/*.sh
```

### pip-audit Not Found

```bash
pip install pip-audit safety
```

### GitHub CLI Not Authenticated

```bash
gh auth login
# Follow prompts to authenticate
```

## Advanced Usage

### Custom Verification Rules

Edit scripts to add custom checks:

```bash
# Add custom domain checks in verify-github-release.sh
if [[ "$REPO" == "explosion/spacy-models" ]]; then
  # Additional verification for spaCy models
  echo "Running spaCy-specific checks..."
fi
```

### Integration with Pre-commit Hooks

```bash
# .claude/hooks/pre-commit
#!/bin/bash
if [[ -f "requirements.txt" ]]; then
  while IFS= read -r package; do
    [[ "$package" =~ ^#.*$ ]] && continue
    [[ -z "$package" ]] && continue

    .claude/security/verify-python-package.sh "$package"
    [[ $? -ne 0 ]] && exit 1
  done < requirements.txt
fi
```

### Custom OSV Queries

```bash
# Query specific version ranges
curl -s "https://api.osv.dev/v1/query" \
  -d '{"package":{"name":"requests","ecosystem":"PyPI"},"version":"2.28.0"}' \
  | jq '.vulns'
```

## Security Best Practices

1. **Principle of Least Privilege**
   - Default to Limited network mode
   - Switch to Full mode only when necessary
   - Switch back immediately after installation

2. **Attestation-First Verification**
   - Always check for SLSA attestations (strongest security)
   - Fall back to checksum verification if unavailable
   - Use multiple vulnerability databases

3. **Documentation and Auditing**
   - Document why Full network mode was needed
   - Record verification results
   - Review dependencies regularly

4. **Team Coordination**
   - Share verification results
   - Standardize on approved packages
   - Automate security checks in CI/CD

## Related Documentation

- **Setup Guide**: [`CODE-WEB-FULL-NETWORK-SETUP.md`](/Users/kieransteele/git/containers/projects/claude-harness/.claude/security/CODE-WEB-FULL-NETWORK-SETUP.md)
- **Code Web Skill**: `/Users/kieransteele/.claude/skills/claude-code-web/SKILL.md`
- **Skills Sync**: `/Users/kieransteele/git/containers/projects/claude-harness/.claude/skills-sync/README.md`
- **Git Workflow**: `/Users/kieransteele/.claude/skills/git-workflow/SKILL.md`

## Security Resources

### Official Tools

- **pip-audit**: https://pypi.org/project/pip-audit/
- **safety**: https://pyup.io/safety/
- **SLSA Framework**: https://slsa.dev/
- **OSV Database**: https://osv.dev/

### Vulnerability Databases

- **OSV.dev**: https://osv.dev/ (Open Source Vulnerabilities)
- **Safety DB**: https://github.com/pyupio/safety-db
- **GitHub Advisory**: https://github.com/advisories
- **NVD**: https://nvd.nist.gov/ (National Vulnerability Database)

### Supply Chain Security

- **SLSA Attestations**: https://slsa.dev/attestation-model
- **Sigstore**: https://www.sigstore.dev/
- **in-toto**: https://in-toto.io/
- **npm audit**: https://docs.npmjs.com/cli/v10/commands/npm-audit

## Contributing

To improve the security pipeline:

1. **Add new verification checks** - Suggest additional security tools
2. **Report false positives** - Help refine detection rules
3. **Document new threats** - Share supply chain attack patterns
4. **Test new environments** - Verify compatibility with different setups

## Support

- **GitHub Issues**: Report security concerns or bugs
- **Security Contact**: Use GitHub Issues for security questions
- **Documentation**: All docs in `/Users/kieransteele/git/containers/projects/claude-harness/.claude/security/`

---

**Last Updated**: 2025-11-05
**Maintained By**: Kieran Steele (Token-Eater)
**Version**: 1.0.0
**License**: Private Repository
