# Architecture

Understanding how the Skills Marketplace works under the hood.

## Overview

The Skills Marketplace is a **catalog-based distribution system** for Claude Code skills. It uses JSON catalog files to reference skill packages stored in a Git repository.

## Core Components

### 1. Skills Directory

**Location:** `skills/`

Contains individual skill packages:

```
skills/
├── example-skill/
│   ├── SKILL.md
│   └── scripts/
├── your-skill/
│   ├── SKILL.md
│   ├── references/
│   └── assets/
└── another-skill/
    └── SKILL.md
```

**Purpose:**
- Centralized storage for all skills
- Version controlled via Git
- Easy to browse and contribute

### 2. Catalog Files

**Location:** `.claude-plugin/`

JSON files that define which skills are available:

```
.claude-plugin/
├── marketplace.json           # Stable catalog
├── marketplace-preview.json   # Preview catalog
└── marketplace-team.json      # Team catalog (optional)
```

**Purpose:**
- Define skill metadata (name, version, category, etc.)
- Control visibility (stable vs. preview)
- Enable multiple catalog views

### 3. SKILL.md Format

Each skill has a `SKILL.md` file with YAML frontmatter:

```markdown
---
name: skill-name
description: What it does
version: 1.0.0
author: Author Name
category: productivity
tags: [tag1, tag2]
---

# Skill Documentation

[Content here]
```

**Purpose:**
- Single source of truth for skill metadata
- Human-readable documentation
- Parseable by tooling

## Catalog System

### Two-Tier Architecture

The marketplace uses a **two-tier catalog system**:

```
┌──────────────────────────────────────┐
│     marketplace-preview.json         │
│   (Beta skills, early access)        │
│                                      │
│  ┌────────────────────────────────┐ │
│  │    marketplace.json            │ │
│  │  (Stable, production-ready)    │ │
│  └────────────────────────────────┘ │
└──────────────────────────────────────┘
```

**Flow:**
1. New skills enter **preview catalog**
2. Community tests and provides feedback
3. After testing period, promoted to **stable catalog**
4. Stable skills remain in both catalogs

### Catalog Structure

Each catalog is a JSON file:

```json
{
  "name": "Skills Marketplace",
  "description": "Community marketplace for Claude Code skills",
  "version": "1.0.0",
  "plugins": [
    {
      "name": "example-skill",
      "description": "Demonstrates skill structure",
      "version": "1.0.0",
      "author": "Skills Team",
      "category": "examples",
      "tags": ["template", "documentation"],
      "source": "./skills/example-skill"
    }
  ]
}
```

**Key fields:**
- `source` - Relative path to skill directory
- `version` - Semantic version for tracking updates
- `category` - Primary classification
- `tags` - Searchable keywords

## Distribution Model

### Git-Based Distribution

Skills are distributed via Git repositories:

```
GitHub Repository
      ↓
   git clone
      ↓
Local Clone → Claude Code → /plugin marketplace add
      ↓
Skills Installed
```

**Benefits:**
- Version control built-in
- Easy forking and contributions
- Branch-based testing (main, preview, etc.)
- Standard collaboration workflows

### Installation Flow

1. **User adds marketplace:**
   ```bash
   /plugin marketplace add username/skills-marketplace
   ```

2. **Claude Code:**
   - Clones repository (or uses local path)
   - Parses catalog JSON file
   - Indexes available skills

3. **User installs skill:**
   ```bash
   /plugin install skill-name
   ```

4. **Claude Code:**
   - Locates skill via `source` path
   - Reads SKILL.md
   - Installs to user environment

### Update Flow

1. **Maintainer updates skill:**
   - Increment version in SKILL.md
   - Update catalog JSON
   - Commit and push

2. **User refreshes:**
   ```bash
   /plugin marketplace refresh
   ```

3. **Claude Code:**
   - Pulls latest changes
   - Re-parses catalog
   - Shows updated versions

4. **User updates skills:**
   ```bash
   /plugin update
   ```

## Validation Pipeline

### Skill Validation

Skills are validated at multiple stages:

```
Creation → Local Testing → Submission → Automated Checks → Review → Approval
```

**Automated Checks:**
1. **Structure validation** - Directory layout correct
2. **YAML validation** - Frontmatter syntax valid
3. **Required fields** - All mandatory fields present
4. **No secrets** - No hardcoded credentials
5. **Version format** - Semantic versioning (X.Y.Z)

**Manual Review:**
1. **Code quality** - Well-documented, tested
2. **Security** - No vulnerabilities
3. **Usefulness** - Solves real problem
4. **Uniqueness** - Doesn't duplicate existing skills

### Tools

**skill-creator toolkit** - Automated skill creation and validation:

```bash
# Create skill
python3 ~/.claude/skills/skill-creator/scripts/init_skill.py skill-name

# Validate skill
python3 ~/.claude/skills/skill-creator/scripts/quick_validate.py ./skills/skill-name
```

## Categories and Tags

### Category System

Skills are organized into **10 primary categories**:

- 🎨 Productivity
- 💻 Development
- 📊 Data & Analytics
- 📝 Documentation
- 🔧 DevOps
- 🤖 AI & ML
- 🔒 Security
- 🌐 Web
- 📚 Knowledge
- 🎯 Examples

**Purpose:**
- Help users find relevant skills
- Organize marketplace visually
- Enable category filtering

### Tag System

Skills have **2-5 searchable tags**:

```yaml
tags:
  - automation
  - git
  - workflow
```

**Purpose:**
- Fine-grained search
- Cross-category discovery
- Trend identification

## Versioning Strategy

### Skill Versioning

Each skill uses [Semantic Versioning](https://semver.org/):

```
MAJOR.MINOR.PATCH
  2  .  1  .  3
```

- **MAJOR** - Breaking changes (API changes, removed features)
- **MINOR** - New features (backward compatible)
- **PATCH** - Bug fixes (backward compatible)

**Version tracking:**
- SKILL.md frontmatter: `version: 1.0.0`
- Catalog JSON: `"version": "1.0.0"`
- Both must match

### Marketplace Versioning

The marketplace itself has a version:

```json
{
  "name": "Skills Marketplace",
  "version": "1.0.0",
  "plugins": [...]
}
```

**Incremented when:**
- Catalog structure changes
- New categories added
- Breaking changes to format

## Security Model

### No Hardcoded Secrets

Skills must **never** contain:

- ❌ API keys
- ❌ Passwords
- ❌ Tokens
- ❌ Connection strings
- ❌ Personal credentials

**Instead:**
- ✅ Document how to configure secrets
- ✅ Reference environment variables
- ✅ Use 1Password, secret managers
- ✅ Provide `.env.example` templates

### Review Process

All submissions are reviewed for:

1. **Malicious code** - No harmful operations
2. **Data exfiltration** - No unauthorized data collection
3. **Credential exposure** - No secrets in code
4. **Dependency risks** - External packages vetted

## Extensibility

### Custom Catalogs

Organizations can create custom catalog views:

```bash
# Create team catalog
cp .claude-plugin/marketplace.json .claude-plugin/marketplace-team.json

# Remove internal-only skills
# Edit marketplace-team.json

# Share with team
/plugin marketplace add org/skills?ref=.claude-plugin/marketplace-team.json
```

### Multiple Marketplaces

Users can install multiple marketplaces:

```bash
# Official marketplace
/plugin marketplace add skills-marketplace/official

# Organization marketplace
/plugin marketplace add company/internal-skills

# Personal marketplace
/plugin marketplace add username/my-skills
```

Skills from all marketplaces are available simultaneously.

### Marketplace Forking

Create derivative marketplaces:

1. Fork repository
2. Modify catalog (add/remove skills)
3. Customize metadata (name, description)
4. Publish as new marketplace

## Performance Considerations

### Catalog Size

- Catalogs are JSON files (fast to parse)
- No limit on number of skills
- Skills loaded on-demand (not all at once)

### Git Operations

- Initial clone can be slow for large repos
- Updates are incremental (fast)
- Consider shallow clones for large histories

### Local vs Remote

**Local marketplace** (faster):
```bash
/plugin marketplace add ./path/to/marketplace
```

**Remote marketplace** (always up-to-date):
```bash
/plugin marketplace add username/marketplace
```

## Future Architecture

### Planned Enhancements

- **Dependency management** - Skill dependencies on other skills
- **Automated testing** - CI/CD pipeline for skill validation
- **Version constraints** - Minimum Claude Code version requirements
- **Skill discovery** - Better search and filtering
- **Analytics** - Usage tracking and popularity metrics

### Potential Features

- **Skill packages** - `.skill` file format for distribution
- **Private marketplaces** - Authentication for private repos
- **Mirrors** - CDN distribution for faster downloads
- **Web interface** - Browse skills via website
- **CLI tool** - Dedicated CLI for marketplace management

## Technical Stack

### Current

- **Storage:** Git repositories
- **Format:** JSON catalogs + Markdown skills
- **Distribution:** GitHub (or any Git hosting)
- **Validation:** Python scripts (skill-creator)
- **Installation:** Claude Code built-in plugin system

### Dependencies

- Git 2.0+
- Claude Code (latest version)
- Python 3.8+ (for validation tools, optional)

## Contributing to Architecture

Have ideas for improving the marketplace architecture?

1. 💬 [Open a discussion](https://github.com/token-eater/skills-marketplace/discussions)
2. 💡 [Submit feature request](https://github.com/token-eater/skills-marketplace/issues/new?template=feature_request.md)
3. 📖 [Read contributing guide](./contributing.md)

## Next Steps

- 📖 [Browse skills](./skills.md)
- 🛠️ [Create a skill](./creating-skills.md)
- 🤝 [Contribute](./contributing.md)
- 📥 [Install skills](./installation.md)

## References

- [Claude Code Plugin Marketplaces](https://code.claude.com/docs/en/plugin-marketplaces)
- [Semantic Versioning](https://semver.org/)
- [Git Documentation](https://git-scm.com/doc)
