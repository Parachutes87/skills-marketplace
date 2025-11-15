# Network Environment Testing Findings

## Testing Date: 2025-11-06

### Critical Finding: GitHub Releases Blocked in All Modes

**Tested**: SpaCy model download from GitHub releases
**URL**: `https://github.com/explosion/spacy-models/releases/download/en_core_web_lg-3.8.0/`
**Redirect**: `https://release-assets.githubusercontent.com/...`

### Results by Environment Mode

| Mode | Result | Domain Blocked |
|------|--------|----------------|
| **Limited** | ❌ HTTP 403 | `release-assets.githubusercontent.com` |
| **Development-Verified** | ❌ HTTP 403 | `release-assets.githubusercontent.com` |
| **Full** | ❌ HTTP 403 | `release-assets.githubusercontent.com` |

**Full Mode Testing (2025-11-06 Session 011CUrY7Q7xgTQAMEgcwq9wp)**:
- User switched to Full network mode
- SpaCy download still returned HTTP 403
- Direct curl download also blocked (13 bytes: "Access denied")
- Confirms domain-level blocking, not tool-specific
- `gh CLI` unavailable in Code Web (security verification cannot run)

### Key Insights

**ALL Code Web network modes block GitHub release assets**, including Full mode. This means:
- Whitelist requirement is CRITICAL for skills requiring GitHub releases
- Custom environment with explicit domain whitelist is the ONLY solution
- Full network mode does NOT grant access to `release-assets.githubusercontent.com`
- Domain blocking appears to be at infrastructure level, not configurable per-mode

**Code Web Environment Limitations**:
- `gh CLI` (GitHub CLI) not available → security verification scripts cannot run
- Cannot verify SLSA attestations in Code Web
- Security verification must be performed on Desktop environment
- Testing in Code Web limited to connectivity checks only

### Blocked Domains Identified

1. **release-assets.githubusercontent.com** (⭐⭐ - subdomain level)
   - CDN for GitHub release assets
   - Blocks: SpaCy models, ML weights, binary releases

2. **objects.githubusercontent.com** (⭐⭐ - subdomain level)
   - Alternative CDN for GitHub releases
   - Also blocked in development-verified

3. **Recommended specific pattern** (⭐⭐⭐ - most specific):
   - `github.com/explosion/spacy-models/releases/*`
   - Path-specific to SpaCy models only

### Whitelist Recommendation

**Option 1: Specific** (Start here)
```
github.com/explosion/spacy-models/releases/*
```

**Option 2: Moderate** (If Option 1 fails)
```
release-assets.githubusercontent.com
objects.githubusercontent.com
```

**Option 3: Broad** (Last resort)
```
*.githubusercontent.com
```

**Security verification**: All options require verify-github-release.sh (exit 0) before whitelisting.

### Test Methodology

**Tests Performed (Session 011CUrY7Q7xgTQAMEgcwq9wp)**:
1. ✅ Verified Limited mode: PyPI accessible, GitHub releases blocked
2. ✅ User switched to Full network mode
3. ✅ Tested SpaCy download: `python -m spacy download en_core_web_lg` → HTTP 403
4. ✅ Tested direct curl: `curl -L github.com/.../en_core_web_lg-3.8.0.whl` → HTTP 403
5. ✅ Attempted security verification: `gh CLI` not available
6. ✅ Confirmed domain blocking: `release-assets.githubusercontent.com` returns "Access denied"

**Conclusion**: GitHub release assets blocked at infrastructure level in ALL modes.

### Next Steps

1. ✅ ~~Test in "Full" network mode~~ (COMPLETED - still blocked)
2. **Request Anthropic whitelist** `release-assets.githubusercontent.com` for Code Web
3. Document in pii-detection-anonymization skill requirements
4. Create whitelist PR with test evidence from this session
5. Perform security verification on Desktop environment (requires `gh CLI`)

### Questions for Anthropic

1. Can `release-assets.githubusercontent.com` be added to default Limited mode allowlist?
2. Is custom domain whitelist feature available in Code Web?
3. What is the format for custom environment domain configuration?

---

**Tested by**: Claude (Desktop) via Code Web session  
**User**: kieransteele  
**Date**: 2025-11-06
