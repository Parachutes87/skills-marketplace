# Validate Plan

You are tasked with validating that an implementation plan was correctly executed, verifying all success criteria and identifying any deviations or issues.

## Initial Setup

When invoked:
1. **Determine context** - Are you in an existing conversation or starting fresh?
   - If existing: Review what was implemented in this session
   - If fresh: Need to discover what was done through git and codebase analysis

2. **Locate the plan**:
   - If plan path provided, use it
   - Otherwise, search recent commits for plan references or ask user

3. **Gather implementation evidence**:
   ```bash
   # Check recent commits
   git log --oneline -n 20
   git diff HEAD~N..HEAD  # Where N covers implementation commits

   # Run comprehensive checks
   {{TEST_COMMAND}}
   ```

## Validation Process

### Step 1: Context Discovery

If starting fresh or need more context:

1. **Read the implementation plan** completely
2. **Identify what should have changed**:
   - List all files that should be modified
   - Note all success criteria (automated and manual)
   - Identify key functionality to verify

3. **Spawn parallel research tasks** to discover implementation:
   ```
   Task 1 - Verify database changes:
   Research if migration [N] was added and schema changes match plan.
   Check: migration files, schema version, table structure
   Return: What was implemented vs what plan specified

   Task 2 - Verify code changes:
   Find all modified files related to [feature].
   Compare actual changes to plan specifications.
   Return: File-by-file comparison of planned vs actual

   Task 3 - Verify test coverage:
   Check if tests were added/modified as specified.
   Run test commands and capture results.
   Return: Test status and any missing coverage
   ```

### Step 2: Systematic Validation

For each phase in the plan:

1. **Check completion status**:
   - Look for checkmarks in the plan (- [x])
   - Verify the actual code matches claimed completion

2. **Run automated verification**:
   - Execute each command from "Automated Verification"
   - Document pass/fail status
   - If failures, investigate root cause

3. **Assess manual criteria**:
   - List what needs manual testing
   - Provide clear steps for user verification

4. **Think deeply about edge cases**:
   - Were error conditions handled?
   - Are there missing validations?
   - Could the implementation break existing functionality?

### Step 3: Generate Validation Report

Create comprehensive validation summary:

```markdown
## Validation Report: [Plan Name]

### Implementation Status
✓ Phase 1: [Name] - Fully implemented
✓ Phase 2: [Name] - Fully implemented
⚠️ Phase 3: [Name] - Partially implemented (see issues)

### Automated Verification Results
✓ Build passes: {{BUILD_COMMAND}}
✓ Tests pass: {{TEST_COMMAND}}
✗ Linting issues: {{LINT_COMMAND}} (3 warnings)

### Code Review Findings

#### Matches Plan:
- Database migration correctly adds [table]
- API endpoints implement specified methods
- Error handling follows plan

#### Deviations from Plan:
- Used different variable names in [file:line]
- Added extra validation in [file:line] (improvement)

#### Potential Issues:
- Missing index on foreign key could impact performance
- No rollback handling in migration

### Manual Testing Required:
1. UI functionality:
   - [ ] Verify [feature] appears correctly
   - [ ] Test error states with invalid input

2. Integration:
   - [ ] Confirm works with existing [component]
   - [ ] Check performance with large datasets

### Recommendations:
- Address linting warnings before merge
- Consider adding integration test for [scenario]
- Document new API endpoints
```

## Working with Existing Context

If you were part of the implementation:
- Review the conversation history
- Check your todo list for what was completed
- Focus validation on work done in this session
- Be honest about any shortcuts or incomplete items

## Important Guidelines

1. **Be thorough but practical** - Focus on what matters
2. **Run all automated checks** - Don't skip verification commands
3. **Document everything** - Both successes and issues
4. **Think critically** - Question if the implementation truly solves the problem
5. **Consider maintenance** - Will this be maintainable long-term?

## Validation Checklist

Always verify:
- [ ] All phases marked complete are actually done
- [ ] Automated tests pass
- [ ] Code follows existing patterns
- [ ] No regressions introduced
- [ ] Error handling is robust
- [ ] Documentation updated if needed
- [ ] Manual test steps are clear

## 🆕 Phase 2C: Pattern Extraction After Validation

**NEW**: After successful validation, automatically extract patterns to ReasoningBank for future learning.

### When to Extract Patterns

Extract patterns when:
- Validation report shows "Implementation Status: Fully implemented" for all phases
- Automated verification passes (tests, build, linting)
- No critical issues identified

**Do NOT extract patterns if:**
- Implementation is incomplete or partially working
- Tests are failing
- Major issues or regressions identified

### Pattern Extraction Workflow

#### Step 1: Determine Pattern Domain

Extract the domain from the validated implementation:
```bash
# From plan filename or implementation focus
# Examples: "authentication", "database-optimization", "api-design", "ui-component"
```

#### Step 2: Calculate Validation Score

```python
validation_score = (
  (phases_completed / total_phases) * 0.4 +
  (tests_passing_ratio) * 0.3 +
  (has_no_critical_issues ? 1 : 0) * 0.3
)
# Range: 0.0 to 1.0
```

#### Step 3: Build Pattern Object

```python
pattern = {
  "domain": "extracted-domain",              # e.g., "api-authentication"
  "approach": "summary from plan",           # High-level approach used
  "outcome": "success",                      # or "partial_success" if score < 0.8
  "metrics": {
    "phasesCompleted": 4,
    "totalPhases": 4,
    "iterationCount": 2,                     # From plan revisions
    "validationScore": 0.92,
    "timeToComplete": 7200,                  # seconds (from git commits)
    "linesOfCode": 450,                      # from git diff --stat
    "testsAdded": 12
  },
  "context": {
    "planPath": "thoughts/shared/plans/...",
    "validationPath": "thoughts/shared/validations/...",
    "technologies": ["React", "TypeScript", "JWT"]  # From plan state
  }
}
```

#### Step 4: Store Pattern in AgentDB

```bash
# Use SQLite to store in reasoningbank-patterns namespace
sqlite3 .swarm/memory.db << EOF
INSERT INTO memory_entries (key, value, namespace, metadata, created_at, updated_at)
VALUES (
  'pattern_$(uuidgen | tr '[:upper:]' '[:lower:]' | tr -d '-' | cut -c1-12)',
  '$(echo "$pattern" | jq -c .)',
  'reasoningbank-patterns',
  '{"confidence": 0.92, "usage_count": 0, "success_count": 1}',
  strftime('%s', 'now'),
  strftime('%s', 'now')
);
EOF
```

#### Step 5: Confirm Pattern Extraction

```
✅ Validation complete! Pattern extracted to ReasoningBank.

**Pattern Summary**:
- Domain: api-authentication
- Approach: JWT with refresh tokens
- Validation Score: 0.92
- Pattern ID: pattern_a1b2c3d4e5f6

This pattern will be suggested during future planning for similar features.
```

### Pattern Schema

```typescript
interface ReasoningBankPattern {
  domain: string;                    // Feature domain/category
  approach: string;                  // Implementation approach summary
  outcome: 'success' | 'partial_success' | 'failure';
  metrics: {
    phasesCompleted: number;
    totalPhases: number;
    iterationCount: number;          // How many times plan was revised
    validationScore: number;         // 0.0 to 1.0
    timeToComplete: number;          // seconds
    linesOfCode?: number;
    testsAdded?: number;
  };
  context: {
    planPath: string;
    validationPath: string;
    technologies: string[];
  };
}
```

### Benefits

- **Learning from Success**: Future plans benefit from proven approaches
- **Avoid Pitfalls**: Learn from iterations and challenges
- **Faster Planning**: See what worked before in similar domains
- **Continuous Improvement**: Build organizational knowledge over time

## Relationship to Other Commands

Recommended workflow:
1. `/implement_plan` - Execute the implementation
2. `/commit` - Create atomic commits for changes
3. `/validate_plan` - Verify implementation correctness
4. **NEW**: Pattern automatically extracted to ReasoningBank
5. `/describe_pr` - Generate PR description

The validation works best after commits are made, as it can analyze the git history to understand what was implemented.

Remember: Good validation catches issues before they reach production. Be constructive but thorough in identifying gaps or improvements.
