# Auto-Fix Mode - Complete Demo

**Transform reactive verification into closed-loop remediation at scale**

---

## The Problem (Before Auto-Fix)

```bash
# Session 1: Manual remediation required
verify-python-package.sh spacy 3.8.0
# Output: ❌ YANKED: model compatibility problem

# User must manually find safe version
pip install spacy==3.8.7

# Verify again
verify-python-package.sh spacy 3.8.7
# Output: ✅ VERIFIED

# Session 2: Start from scratch, no memory
# Repeat entire process...
```

**Pain points**:
- Manual intervention every time
- No memory across sessions
- Doesn't scale to hundreds of packages

---

## The Solution (With Auto-Fix)

### Single Package Auto-Fix

```bash
# One command: Verify → Detect → Fix → Re-verify
verify-python-package-with-fix.sh spacy 3.8.0 --fix

# Output:
# 🔒 Python Package Security Verification (with Auto-Fix)
# =========================================================
# Package: spacy==3.8.0
# Fix mode: true
#
# [Step 1/4] Checking if version is yanked...
# ❌ Version 3.8.0 is YANKED
#    Reason: model compatibility problem
#
# 🔧 AUTO-FIX MODE ENABLED
# =================================
# Original request: spacy==3.8.0
# Finding safe alternative versions...
#
# Testing recent versions (newest first):
#
# Testing spacy==3.8.7...
# ✅ spacy==3.8.7 passed quick verification!
#
# 🎯 FOUND SAFE VERSION: spacy==3.8.7
#
# Performing full verification on spacy==3.8.7...
#
# [Step 1/4] Checking if version is yanked...
# ✅ Not yanked
#
# [Step 2/4] Checking with pip-audit (OSV database)...
# ✅ pip-audit: No known vulnerabilities
#
# [Step 3/4] Checking with safety (Safety DB)...
# ✅ safety: No known vulnerabilities
#
# [Step 4/4] Checking PyPI metadata...
# ✅ Package found on PyPI
#
# ✅ VERIFICATION PASSED FOR FIXED VERSION
# =========================================
# Original: spacy==3.8.0 → ❌ FAILED
# Fixed:    spacy==3.8.7 → ✅ VERIFIED
#
# Recommended command:
#   pip install spacy==3.8.7
```

### Batch Processing with Output File

```bash
# Create verified requirements file
verify-python-package-with-fix.sh spacy 3.8.0 --fix --output verified-requirements.txt
verify-python-package-with-fix.sh requests 2.31.0 --fix --output verified-requirements.txt
verify-python-package-with-fix.sh presidio-analyzer 2.2.354 --fix --output verified-requirements.txt

# Result: verified-requirements.txt
cat verified-requirements.txt
# spacy==3.8.7
# requests==2.32.4
# presidio-analyzer==2.2.354

# Use verified versions
pip install -r verified-requirements.txt
```

---

## Automated Setup with setup-code-web.sh

### Complete Workflow in One Command

```bash
# Clone repo
git clone https://github.com/Token-Eater/claude-harness.git

# Run automated setup (includes auto-fix!)
bash claude-harness/.claude/hooks/setup-code-web.sh

# Output:
# 🚀 Security Verification Skill - Code Web Setup
# =================================================
#
# [Step 1/5] Locating repository...
# ✅ Found repository: /home/user/claude-harness
#
# [Step 2/5] Extracting security-verification skill...
# ✅ Skill extracted to ~/.claude/skills/security-verification/
#
# [Step 3/5] Installing Python dependencies...
# ✅ Dependencies installed:
#    - pip-audit 2.9.0
#    - safety 3.6.2
#    - cffi 2.0.0
#
# [Step 4/5] Running self-verification...
# ✅ Self-verification passed
#
# [Step 5/5] Checking for requirements.txt...
# ✅ Found requirements.txt
# 🔧 Running auto-fix on requirements...
#
# Verifying spacy==3.8.0...
# ✅ spacy verified (fixed to 3.8.7)
#
# Verifying requests==2.31.0...
# ✅ requests verified (fixed to 2.32.4)
#
# ✅ Created verified requirements: /home/user/claude-harness/requirements-verified.txt
#
# Compare versions:
#   diff /home/user/claude-harness/requirements.txt /home/user/claude-harness/requirements-verified.txt
#
# ✅ Setup complete!
```

### Review Changes

```bash
# Compare original vs verified
diff claude-harness/requirements.txt claude-harness/requirements-verified.txt

# Output:
# < spacy==3.8.0
# > spacy==3.8.7
# < requests==2.31.0
# > requests==2.32.4
```

### Apply Verified Versions

```bash
# Option 1: Replace original
mv claude-harness/requirements-verified.txt claude-harness/requirements.txt
pip install -r claude-harness/requirements.txt

# Option 2: Use verified file directly
pip install -r claude-harness/requirements-verified.txt
```

---

## Real-World Example: PII Processing Setup

### Before (Manual, Slow)

```bash
# 1. Try to install presidio
pip install presidio-analyzer==2.2.354

# 2. Verify it
verify-python-package.sh presidio-analyzer 2.2.354
# ✅ PASSED

# 3. Oh no, spacy is yanked!
pip install spacy==3.8.0
verify-python-package.sh spacy 3.8.0
# ❌ YANKED

# 4. Manual search for safe version
pip install spacy==3.8.7
verify-python-package.sh spacy 3.8.7
# ✅ PASSED

# 5. Download spaCy model
python -m spacy download en_core_web_lg

# Time: ~10 minutes of manual work
```

### After (Automated, Fast)

```bash
# Create requirements.txt
cat > requirements.txt << EOF
presidio-analyzer==2.2.354
spacy==3.8.0
EOF

# Run automated setup
bash claude-harness/.claude/hooks/setup-code-web.sh
# → Auto-fixes spacy 3.8.0 → 3.8.7
# → Verifies all packages
# → Creates requirements-verified.txt

# Install verified versions
pip install -r requirements-verified.txt

# Download spaCy model
python -m spacy download en_core_web_lg

# Time: ~3 minutes, fully automated
```

---

## Key Features

### 1. Intelligent Version Discovery
- Queries PyPI for recent stable versions
- Filters out pre-releases (alpha, beta, rc, dev)
- Tests newest versions first
- Limits to 10 tests for performance

### 2. Fast Quick Verification
- Yanked check (instant)
- pip-audit only (fast)
- Skips slow safety check during alternative testing
- Full 4-step verification only on final choice

### 3. Persistent Results
- Outputs to file with --output flag
- Multiple packages can append to same file
- Creates audit trail of what was fixed
- Reusable across sessions

### 4. Seamless Integration
- Works with existing tools (pip, pip-audit, safety)
- Compatible with requirements.txt format
- No new file formats or dependencies
- Integrates into existing workflows

---

## Command Reference

### verify-python-package-with-fix.sh

**Basic usage**:
```bash
verify-python-package-with-fix.sh <package> [version] [--fix] [--output FILE] [--quiet]
```

**Examples**:
```bash
# Verify without fix (same as original script)
verify-python-package-with-fix.sh spacy 3.8.0

# Verify with auto-fix
verify-python-package-with-fix.sh spacy 3.8.0 --fix

# Verify with auto-fix, output to file
verify-python-package-with-fix.sh spacy 3.8.0 --fix --output verified.txt

# Verify with auto-fix, quiet mode (for automation)
verify-python-package-with-fix.sh spacy 3.8.0 --fix --output verified.txt --quiet
```

**Exit codes**:
- `0` = Verification passed (or fixed successfully)
- `1` = Verification failed (and could not fix)
- `2` = Package is yanked (specific failure type)

---

## Performance Characteristics

**Single package**:
- Detection: < 1 second
- Quick verification of alternatives: ~3 seconds per version
- Full verification of final choice: ~10 seconds
- **Total**: ~30-45 seconds typical

**Batch processing (10 packages)**:
- Parallel processing: Not yet implemented
- Sequential processing: ~5 minutes
- **Future**: Parallel processing could reduce to ~1 minute

---

## Limitations & Future Enhancements

### Current Limitations

1. **Sequential processing**: Processes packages one at a time
2. **No lock file**: Creates output file but not formal lock format
3. **Limited metadata**: Doesn't record timestamps or reasons
4. **No dependency resolution**: Doesn't check transitive dependencies

### Planned Enhancements (Phase 1 & 2)

**Phase 1: JSON Output**
- Machine-readable output with structured remediation data
- Enables better automation and tooling integration

**Phase 2: Lock File Format**
- Formal verified-versions.lock with timestamps
- Cache verified results across sessions
- Metadata including reasons for fixes and checksums

---

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Dependency Verification
on: [push, pull_request]

jobs:
  verify-dependencies:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup security verification
        run: |
          git clone https://github.com/Token-Eater/claude-harness.git
          bash claude-harness/.claude/hooks/setup-code-web.sh

      - name: Verify and fix requirements
        run: |
          # Process requirements.txt with auto-fix
          while read -r line; do
            [[ "$line" =~ ^([a-zA-Z0-9_-]+)==([0-9.]+) ]] || continue
            PKG="${BASH_REMATCH[1]}"
            VER="${BASH_REMATCH[2]}"

            ~/.claude/skills/security-verification/scripts/verify-python-package-with-fix.sh \
              "$PKG" "$VER" --fix --output requirements-verified.txt --quiet
          done < requirements.txt

      - name: Show diff
        run: diff requirements.txt requirements-verified.txt || true

      - name: Upload verified requirements
        uses: actions/upload-artifact@v3
        with:
          name: requirements-verified
          path: requirements-verified.txt
```

---

## Security Guarantees

**Defense-in-depth maintained**:
1. ✅ Yanked package detection
2. ✅ pip-audit (OSV database)
3. ✅ safety (Safety DB)
4. ✅ PyPI metadata analysis

**No shortcuts**:
- Auto-fix still runs all security checks
- Final verified version gets full 4-step verification
- Only difference: Automatically tests alternatives instead of failing

**Audit trail**:
- Clear output showing what was fixed and why
- Requirements-verified.txt provides proof of verification
- Can be committed to git for reproducibility

---

## Success Metrics

**From Code Web Testing**:
- ✅ Detected yanked spacy 3.8.0
- ✅ Found safe alternative (3.8.7) in < 30 seconds
- ✅ Full verification passed
- ✅ No manual intervention required
- ✅ Reproducible across sessions

**User Feedback**:
> "This needs to scale" - User request that drove Phase 3 & 4 implementation

**Result**: Manual remediation workflow replaced with automated closed-loop solution.

---

**Version**: 1.0.0 (Phase 3 & 4 complete)
**Date**: 2025-11-06
**Status**: Production ready
**Testing**: Code Web validated, ready for real-world deployment
