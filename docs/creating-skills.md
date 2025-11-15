# Creating Skills

Learn how to build Claude Code skills for the marketplace.

## What Makes a Good Skill?

A well-designed skill is:

- 🎯 **Focused** - Solves one problem well
- 📝 **Documented** - Clear usage examples
- ✅ **Tested** - Validated in Claude Code
- 🔒 **Secure** - No hardcoded secrets
- 📦 **Self-contained** - Minimal external dependencies

## Skill Structure

### Required Files

Every skill must have this structure:

```
skills/
└── your-skill-name/
    └── SKILL.md           # Required: Main skill definition
```

### Optional Directories

Add these for more complex skills:

```
skills/
└── your-skill-name/
    ├── SKILL.md           # Required
    ├── scripts/           # Optional: Helper scripts
    ├── references/        # Optional: Reference docs
    └── assets/            # Optional: Images, templates
```

## SKILL.md Format

The `SKILL.md` file contains YAML frontmatter followed by documentation.

### Minimal Example

```markdown
---
name: my-skill
description: Brief description of what this skill does
version: 1.0.0
author: Your Name
category: productivity
tags:
  - automation
  - workflow
---

# My Skill

Detailed documentation for your skill.

## Usage

How to use this skill...

## Examples

Example usage...
```

### Complete Example

```markdown
---
name: git-automation
description: Automates common git workflows and best practices
version: 1.2.0
author: Jane Developer
category: development
tags:
  - git
  - automation
  - workflow
license: MIT
repository: https://github.com/username/git-automation-skill
homepage: https://example.com/docs/git-automation
---

# Git Automation Skill

This skill provides automated workflows for common git operations.

## Features

- Automated branch creation
- Commit message templates
- PR creation workflows
- Git hooks management

## Usage

### Creating a Feature Branch

[Usage instructions...]

### Submitting a PR

[PR workflow...]

## Configuration

[Configuration options...]

## Examples

[Code examples...]

## Dependencies

- Git 2.30+
- GitHub CLI (optional)

## Troubleshooting

[Common issues and solutions...]
```

## Frontmatter Fields

### Required Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `name` | string | Unique skill identifier (kebab-case) | `my-skill` |
| `description` | string | Brief summary (1-2 sentences) | `Automates task management` |
| `version` | string | Semantic version | `1.0.0` |
| `author` | string | Your name or organization | `Jane Doe` |
| `category` | string | Primary category | `productivity` |
| `tags` | array | Searchable keywords | `[automation, tasks]` |

### Optional Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `license` | string | License type | `MIT` |
| `repository` | string | Source code URL | `https://github.com/user/repo` |
| `homepage` | string | Documentation URL | `https://example.com/docs` |
| `dependencies` | array | Required tools/packages | `[docker, node]` |

## Categories

Choose the most appropriate category:

- `productivity` - Task management, workflows, automation
- `development` - Git, testing, code quality, deployment
- `data` - Data processing, visualization, reporting
- `documentation` - Markdown, diagrams, API docs
- `devops` - CI/CD, containers, infrastructure
- `ai-ml` - AI/ML integration, training, evaluation
- `security` - Security scanning, verification, compliance
- `web` - Web scraping, APIs, frontend tools
- `knowledge` - Research, memory, note-taking
- `examples` - Templates and learning resources

## Tags

Add 2-5 relevant tags:

**Good tags:**
- `git`, `automation`, `testing`, `docker`, `api`
- Lowercase, specific, descriptive
- Relevant to skill functionality

**Avoid:**
- Generic tags: `cool`, `awesome`, `best`
- Duplicate categories: If category is `development`, don't tag `dev`
- Too many tags: Keep it focused

## Versioning

Use [Semantic Versioning](https://semver.org/):

```
MAJOR.MINOR.PATCH
```

- **MAJOR** (1.0.0 → 2.0.0): Breaking changes
- **MINOR** (1.0.0 → 1.1.0): New features, backward compatible
- **PATCH** (1.0.0 → 1.0.1): Bug fixes, backward compatible

**Examples:**
- Adding new features: `1.2.0` → `1.3.0`
- Fixing bugs: `1.2.0` → `1.2.1`
- Breaking changes: `1.2.0` → `2.0.0`

## Development Workflow

### 1. Initialize Skill (Recommended)

Use the skill-creator toolkit:

```bash
# Create skill structure automatically
python3 ~/.claude/skills/skill-creator/scripts/init_skill.py \
  your-skill-name \
  --path ./skills

# Creates:
# - skills/your-skill-name/SKILL.md (with frontmatter)
# - skills/your-skill-name/scripts/ (empty)
# - skills/your-skill-name/references/ (empty)
# - skills/your-skill-name/assets/ (empty)
```

### 2. Manual Creation (Alternative)

Create the structure manually:

```bash
# Create directory
mkdir -p skills/your-skill-name

# Create SKILL.md
cat > skills/your-skill-name/SKILL.md <<'EOF'
---
name: your-skill-name
description: What this skill does
version: 1.0.0
author: Your Name
category: productivity
tags:
  - tag1
  - tag2
---

# Your Skill Name

[Documentation here]
EOF
```

### 3. Write Documentation

In `SKILL.md`, include:

- **Overview** - What the skill does
- **Features** - Key capabilities
- **Usage** - How to use it
- **Examples** - Code samples
- **Configuration** - Setup instructions (if needed)
- **Dependencies** - Required tools
- **Troubleshooting** - Common issues

### 4. Test Locally

```bash
# Add marketplace locally
cd /path/to/skills-marketplace
/plugin marketplace add .

# Install your skill
/plugin install your-skill-name

# Test in Claude Code
# [Use the skill and verify it works]
```

### 5. Validate

```bash
# Validate structure and frontmatter
python3 ~/.claude/skills/skill-creator/scripts/quick_validate.py \
  ./skills/your-skill-name

# Expected output:
# ✅ YAML frontmatter is valid
# ✅ Required fields present
# ✅ No frontmatter in subdirectories
```

### 6. Add to Catalog

Edit `.claude-plugin/marketplace-preview.json`:

```json
{
  "plugins": [
    {
      "name": "your-skill-name",
      "description": "What this skill does",
      "version": "1.0.0",
      "author": "Your Name",
      "category": "productivity",
      "tags": ["tag1", "tag2"],
      "source": "./skills/your-skill-name"
    }
  ]
}
```

### 7. Submit

See [Contributing Guide](./contributing.md) for submission process.

## Best Practices

### Documentation

- ✅ Write clear, concise descriptions
- ✅ Include usage examples
- ✅ Document all dependencies
- ✅ Provide troubleshooting tips
- ✅ Use code blocks for commands

### Structure

- ✅ Keep skills focused (single purpose)
- ✅ Use semantic versioning
- ✅ Organize files logically
- ✅ Include only necessary files
- ✅ Use descriptive file names

### Security

- ⚠️ **Never** hardcode API keys, tokens, or passwords
- ⚠️ **Never** commit `.env` files or credentials
- ✅ Document how to configure secrets (e.g., via environment variables)
- ✅ Use `.gitignore` for sensitive files
- ✅ Reference 1Password or secret managers

### Testing

- ✅ Test in Claude Code before submitting
- ✅ Verify all examples work
- ✅ Check for typos and errors
- ✅ Test with fresh installation
- ✅ Validate frontmatter format

## Advanced Features

### Helper Scripts

Add executable scripts in `scripts/` directory:

```bash
skills/your-skill-name/
├── SKILL.md
└── scripts/
    ├── setup.sh
    ├── validate.py
    └── cleanup.sh
```

Reference scripts in your documentation:

```markdown
## Setup

Run the setup script:

```bash
bash scripts/setup.sh
```
```

### Reference Documentation

Store additional docs in `references/`:

```bash
skills/your-skill-name/
├── SKILL.md
└── references/
    ├── api-reference.md
    ├── configuration-guide.md
    └── troubleshooting.md
```

**Important:** Reference files should **NOT** have YAML frontmatter.

### Assets

Include images, templates, or data files:

```bash
skills/your-skill-name/
├── SKILL.md
└── assets/
    ├── diagram.png
    ├── template.json
    └── example-data.csv
```

Reference in documentation:

```markdown
## Architecture

![System Diagram](./assets/diagram.png)
```

## Common Patterns

### Workflow Skill

Automates a multi-step process:

```markdown
---
name: deployment-workflow
description: Automated deployment workflow with validation
version: 1.0.0
category: devops
tags: [deployment, ci-cd, automation]
---

# Deployment Workflow

## Steps

1. Run tests
2. Build artifacts
3. Deploy to staging
4. Verify deployment
5. Deploy to production
```

### Tool Integration Skill

Integrates external tools:

```markdown
---
name: docker-helper
description: Docker container management and troubleshooting
version: 1.0.0
category: devops
tags: [docker, containers]
dependencies: [docker]
---

# Docker Helper

## Prerequisites

- Docker 20.10+

## Usage

[Docker commands and workflows...]
```

### Knowledge Skill

Provides reference information:

```markdown
---
name: api-patterns
description: RESTful API design patterns and best practices
version: 1.0.0
category: development
tags: [api, rest, best-practices]
---

# API Design Patterns

## Common Patterns

### Resource Naming

[Best practices...]

### Error Handling

[Error patterns...]
```

## Troubleshooting

### Validation Fails

**Problem:** `quick_validate.py` reports errors

**Solutions:**
- Check YAML frontmatter syntax (indentation, colons, dashes)
- Ensure all required fields present
- Remove frontmatter from reference files
- Verify version format (X.Y.Z)

### Skill Not Loading

**Problem:** Skill doesn't appear in `/plugin list`

**Solutions:**
- Verify `source` path in marketplace JSON
- Check SKILL.md filename (must be uppercase)
- Ensure valid frontmatter
- Refresh marketplace: `/plugin marketplace refresh`

### Frontmatter Errors

**Problem:** "Invalid YAML" or parsing errors

**Solutions:**
- Use online YAML validator
- Check indentation (2 spaces, no tabs)
- Ensure arrays use `- item` format
- Verify strings with special characters are quoted

## Examples

See example skills in the marketplace:

- `example-skill` - Basic skill structure
- `example-visibility-test` - Testing configurations

## Next Steps

- 📖 [Browse existing skills](./skills.md)
- 🤝 [Submit your skill](./contributing.md)
- 📥 [Install from marketplace](./installation.md)
- 🏗️ [Learn marketplace architecture](./architecture.md)

## Support

- 💬 [Ask questions](https://github.com/token-eater/skills-marketplace/discussions)
- 🐛 [Report issues](https://github.com/token-eater/skills-marketplace/issues)
- 📚 [Read documentation](../)
