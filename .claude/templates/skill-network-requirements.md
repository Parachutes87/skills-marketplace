## Network Access Requirements

**⚠️ This skill requires network access beyond Code Web's default Limited mode allowlist.**

### Required Domains

**Last Verified**: YYYY-MM-DD
**Verification Method**: security-verification pipeline
**Recommended Environment**: Default plus whitelist (see domains below)

| Domain Pattern | Purpose | Specificity | Verification |
|---------------|---------|-------------|--------------|
| `example.com/specific/path/*` | Description | ⭐⭐⭐ | Exit 0 on YYYY-MM-DD |

### Specificity Legend
- ⭐⭐⭐ **Specific** (Preferred): Exact path pattern
- ⭐⭐ **Moderate**: Subdomain-specific
- ⭐ **Broad** (Last resort): Wildcard or top-level domain

### Code Web Workflow

**Phase 1: Discovery & Verification** (First time setup)
1. Start in Limited mode, hit HTTP 403 blocker
2. Claude presents options (STOP-IDENTIFY-ASK-WAIT)
3. User approves Full network mode + verification
4. Switch to Full network environment in Code Web
5. Run security verification:
   ```bash
   verify-github-release.sh <owner/repo> <tag> <asset>
   # Or verify-python-package-with-fix.sh <package> <version>
   ```
6. If verification passes (exit 0), proceed with operation
7. Document successful domains with verification results
8. Create PR to whitelist domains in "default plus whitelist" environment

**Phase 2: Production Use** (After whitelist PR merged)
1. Use "default plus whitelist" environment for all sessions
2. Limited mode + custom domains = secure and functional
3. No need for Full network mode
4. Periodic verification (quarterly review)

### Whitelist PR Data

**For human to submit**:
```
Domains to whitelist:
- github.com/explosion/spacy-models/releases/* (⭐⭐⭐)

Verification:
- Tool: verify-github-release.sh
- Exit code: 0
- Date: YYYY-MM-DD

Security justification:
- Required for SpaCy NLP model initialization
- Verified with security pipeline
- Common dependency for NLP/ML skills

Skill: <skill-name>
```

### Blocker Response Template

When hitting network blocker, use this pattern:
```
❌ Blocker: SpaCy model download blocked (HTTP 403)
Domain: github.com/explosion/spacy-models/releases/*

Options:
1. Switch to Full network + verify (test domains for whitelist)
2. Document and defer (add to whitelist PR later)
3. Degrade functionality (skip model download)

Recommendation: Option 1 - Test in Full mode, then whitelist

Which approach should I take?
```

### Security Integration

**Always use security-verification pipeline**:
- See: `/Users/kieransteele/.claude/skills/security-verification/SKILL.md`
- Verify before ANY downloads in Full network mode
- Document verification results
- Include in whitelist PR justification

### Quarterly Review

**Every 3 months**:
- Re-verify all domains still required
- Check for security updates
- Update "Last Verified" date
- Review specificity (can we narrow patterns?)
