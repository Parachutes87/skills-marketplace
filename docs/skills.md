# Skills Reference

Complete catalog of skills available in the Skills Marketplace.

## What Are Skills?

Skills are **domain-specific expertise packages** for Claude Code. Each skill provides specialized knowledge, workflows, and tools for specific tasks.

### Key Characteristics

- 🎯 **Single-purpose** - Focused on one domain or task
- 📦 **Self-contained** - All necessary documentation included
- ✅ **Validated** - Tested and verified before inclusion
- 📝 **Documented** - Clear usage examples and instructions

## Skill Categories

Skills are organized into categories for easy discovery:

### 🎨 Productivity

Task management, workflows, and automation tools.

| Skill | Description | Version | Status |
|-------|-------------|---------|--------|
| `example-skill` | Demonstrates skill structure and best practices | 1.0.0 | Stable |

### 💻 Development

Git, testing, code quality, and deployment tools.

| Skill | Description | Version | Status |
|-------|-------------|---------|--------|
| `example-visibility-test` | Tests marketplace visibility configurations | 1.0.0 | Preview |

### 📊 Data & Analytics

Data processing, visualization, and reporting skills.

| Skill | Description | Version | Status |
|-------|-------------|---------|--------|
| *(Coming soon)* | - | - | - |

### 📝 Documentation

Markdown, diagrams, and API documentation tools.

| Skill | Description | Version | Status |
|-------|-------------|---------|--------|
| *(Coming soon)* | - | - | - |

### 🔧 DevOps

CI/CD, containers, and infrastructure management.

| Skill | Description | Version | Status |
|-------|-------------|---------|--------|
| *(Coming soon)* | - | - | - |

### 🤖 AI & ML

Model integration, training, and evaluation tools.

| Skill | Description | Version | Status |
|-------|-------------|---------|--------|
| *(Coming soon)* | - | - | - |

### 🔒 Security

Security scanning, verification, and compliance tools.

| Skill | Description | Version | Status |
|-------|-------------|---------|--------|
| *(Coming soon)* | - | - | - |

### 🌐 Web

Web scraping, APIs, and frontend development tools.

| Skill | Description | Version | Status |
|-------|-------------|---------|--------|
| *(Coming soon)* | - | - | - |

### 📚 Knowledge

Research, memory management, and note-taking tools.

| Skill | Description | Version | Status |
|-------|-------------|---------|--------|
| *(Coming soon)* | - | - | - |

### 🎯 Examples

Templates and learning resources for skill development.

| Skill | Description | Version | Status |
|-------|-------------|---------|--------|
| `example-skill` | Demonstrates skill structure and best practices | 1.0.0 | Stable |

## Skill Details

### example-skill

**Category:** Examples
**Version:** 1.0.0
**Status:** Stable
**Author:** Skills Marketplace Team

**Description:**
Demonstrates the proper structure and frontmatter format for marketplace skills. Use this as a template when creating your own skills.

**Installation:**

```bash
/plugin install example-skill
```

**Usage:**

See skill documentation after installation for specific usage instructions.

**Dependencies:** None

---

### example-visibility-test

**Category:** Examples
**Version:** 1.0.0
**Status:** Preview
**Author:** Skills Marketplace Team

**Description:**
Tests different visibility configurations for marketplace skills. Used for development and testing purposes.

**Installation:**

```bash
# Available in preview catalog only
/plugin marketplace add token-eater/skills-marketplace?ref=.claude-plugin/marketplace-preview.json
/plugin install example-visibility-test
```

**Usage:**

See skill documentation after installation.

**Dependencies:** None

---

## Skill Status

Skills have one of these statuses:

### ✅ Stable

- Fully tested and documented
- Production-ready
- Available in default marketplace catalog
- Semantic versioning guaranteed

### 🧪 Preview

- Beta or experimental
- Early access features
- May have breaking changes
- Available in preview catalog only

### 🚧 Deprecated

- No longer maintained
- Replacement available
- Will be removed in future release

## Finding Skills

### By Category

```bash
# List skills in a category
/plugin list --category productivity
```

### By Tag

```bash
# Search by tag
/plugin search automation
```

### By Name

```bash
# Direct install if you know the name
/plugin install skill-name
```

## Using Skills

After installation, skills are available in your Claude Code environment. Each skill provides:

1. **Documentation** - Usage instructions and examples
2. **Workflows** - Predefined processes and templates
3. **Tools** - Utilities and automation scripts
4. **References** - Additional resources and guides

Refer to individual skill documentation for specific usage.

## Contributing Skills

Have a skill to share? See the [Contributing Guide](./contributing.md) for submission process.

### Quality Standards

All marketplace skills must meet these requirements:

- ✅ Valid YAML frontmatter in SKILL.md
- ✅ Clear description and purpose
- ✅ Usage examples and documentation
- ✅ Tested in Claude Code
- ✅ Semantic versioning
- ✅ No hardcoded secrets
- ✅ Appropriate category and tags

## Skill Versions

Skills follow [Semantic Versioning](https://semver.org/):

- **MAJOR.MINOR.PATCH** (e.g., 2.1.3)
- **MAJOR** - Breaking changes
- **MINOR** - New features (backward compatible)
- **PATCH** - Bug fixes (backward compatible)

## Next Steps

- 📥 [Install skills from the marketplace](./installation.md)
- 🛠️ [Create your own skills](./creating-skills.md)
- 🤝 [Submit skills to the marketplace](./contributing.md)
- 🏗️ [Learn marketplace architecture](./architecture.md)

## Support

- 💬 [Discuss skills](https://github.com/token-eater/skills-marketplace/discussions)
- 🐛 [Report issues](https://github.com/token-eater/skills-marketplace/issues)
- 📖 [Read documentation](../)
