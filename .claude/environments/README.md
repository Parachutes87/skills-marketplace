# Code Web Environment Configurations

This directory tracks network whitelist configurations for Claude Code Web environments.

## Purpose

Code Web has three network access modes:
- **None**: No network access
- **Limited**: Default allowlist only (Python, npm, container registries, etc.)
- **Full**: Unrestricted internet access

The `default-plus-whitelist.json` configuration tracks additional domains to be added to Limited mode for skill-specific requirements.

## File Format

**Note**: This format is proposed and may need adjustment based on Code Web's actual environment configuration format.

```json
{
  "name": "environment-name",
  "network_mode": "limited",
  "include_defaults": true,
  "custom_domains": [
    {
      "domain": "example.com/path/*",
      "purpose": "Why this domain is needed",
      "skill": "skill-name",
      "specificity": "specific|moderate|broad",
      "verified_date": "YYYY-MM-DD",
      "verification_tool": "verify-github-release.sh",
      "verification_exit_code": 0
    }
  ],
  "quarterly_review": {
    "last_reviewed": "YYYY-MM-DD",
    "next_review": "YYYY-MM-DD"
  }
}
```

## Specificity Levels

Always start with the most specific pattern and only widen if necessary:

- ⭐⭐⭐ **Specific** (Preferred): `github.com/owner/repo/releases/*`
- ⭐⭐ **Moderate**: `objects.githubusercontent.com`
- ⭐ **Broad** (Last resort): `*.githubusercontent.com`

## Workflow

### 1. Discovery Phase
1. Hit HTTP 403 blocker in Code Web Limited mode
2. Claude presents options (STOP-IDENTIFY-ASK-WAIT)
3. User approves Full network mode + verification

### 2. Verification Phase
1. Switch to Full network environment in Code Web
2. Run security verification:
   ```bash
   verify-github-release.sh <owner/repo> <tag> <asset>
   ```
3. If exit 0, proceed with operation
4. Document successful domains

### 3. Whitelist PR Phase
1. Add domains to this configuration file
2. Document in skill's SKILL.md
3. Create PR with security justification
4. Review quarterly (3 months)

## Security Requirements

**All whitelist additions must**:
- Pass security verification (exit code 0)
- Document verification tool and date
- Start with most specific pattern
- Include justification and use case
- Reference affected skill

See `/Users/kieransteele/.claude/skills/security-verification/SKILL.md` for verification procedures.

## Related Documentation

- **Blocker Handling Policy**: `/Users/kieransteele/git/containers/projects/claude-harness/.claude/CLAUDE.md` (Network Restriction Blockers section)
- **Git Workflow**: `/Users/kieransteele/.claude/skills/git-workflow/SKILL.md` (Code Web Network Whitelist PRs)
- **Skill Template**: `/Users/kieransteele/git/containers/projects/claude-harness/.claude/templates/skill-network-requirements.md`

## Quarterly Review Process

Every 3 months:
1. Re-verify all domains still required
2. Check for security updates
3. Update "Last Verified" dates
4. Review specificity (can patterns be narrowed?)
5. Remove obsolete entries

**Next Review**: See `quarterly_review.next_review` in configuration files.
