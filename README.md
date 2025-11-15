# Skills Marketplace

> ⚡ **Community marketplace for Claude Code skills** - Install granular, single-purpose skills optimized for specific tasks

A curated collection of Claude Code skills built by the community. Install only what you need, not the entire marketplace.

**Currently featuring example skills** (real skills coming soon after visibility testing)

## Overview

The Skills Marketplace is a **public-facing catalog** where developers can discover, install, and contribute Claude Code skills. Each skill is:

- 🎯 **Focused** - Single-purpose tools for specific tasks
- 📦 **Granular** - Install only what you need
- ✅ **Validated** - Tested and documented
- 🤝 **Community-driven** - Built and maintained by users like you

## Key Features

- **Two-tier catalog system** - Stable releases + preview/beta skills
- **Category-based organization** - Find skills by domain (productivity, development, data, etc.)
- **Semantic versioning** - Track updates and compatibility
- **Easy installation** - One command to add skills to Claude Code
- **Open contribution** - Submit your own skills to the marketplace

## How It Works

Skills are distributed through **catalog files** that reference skill packages:

```json
{
  "plugins": [
    {
      "name": "example-skill",
      "description": "Demonstrates skill structure",
      "version": "1.0.0",
      "category": "examples",
      "source": "./skills/example-skill"
    }
  ]
}
```

Install the marketplace, browse available skills, and add them to your Claude Code environment.

## Quick Start

### 1. Install the Marketplace

**From GitHub:**

```bash
/plugin marketplace add token-eater/skills-marketplace
```

**From local clone:**

```bash
git clone https://github.com/token-eater/skills-marketplace.git
/plugin marketplace add ./skills-marketplace
```

### 2. Install Skills

```bash
# Browse available skills
/plugin list

# Install a specific skill
/plugin install example-skill

# Update skills
/plugin update
```

## Documentation

Comprehensive guides for users and contributors:

→ [**Installation Guide**](./docs/installation.md) - How to add and use marketplace skills
→ [**Skills Reference**](./docs/skills.md) - Complete catalog of available skills
→ [**Creating Skills**](./docs/creating-skills.md) - Build your own skills
→ [**Contributing Guide**](./docs/contributing.md) - Submit skills to the marketplace
→ [**Architecture**](./docs/architecture.md) - How the marketplace works

## What's New

### Marketplace Features

- **Dual Catalog System** - Separate stable and preview catalogs
- **Category Organization** - Skills organized by domain and use case
- **Validation Pipeline** - Automated skill testing before acceptance
- **Semantic Versioning** - Clear version tracking and compatibility

## Popular Use Cases

**Install productivity skills:**

```bash
/plugin install task-management
```

**Add development tools:**

```bash
/plugin install git-workflow
```

**Get data processing skills:**

```bash
/plugin install document-processing
```

**Install all recommended skills:**

```bash
/plugin marketplace refresh && /plugin install --recommended
```

## Skill Categories

Skills are organized into focused categories for easy discovery:

- 🎨 **Productivity** - Task management, workflows, automation
- 💻 **Development** - Git, testing, code quality, deployment
- 📊 **Data & Analytics** - Processing, visualization, reporting
- 📝 **Documentation** - Markdown, diagrams, API docs
- 🔧 **DevOps** - CI/CD, containers, infrastructure
- 🤖 **AI & ML** - Model integration, training, evaluation
- 🔒 **Security** - Scanning, verification, compliance
- 🌐 **Web** - Scraping, APIs, frontend tools
- 📚 **Knowledge** - Research, memory, note-taking
- 🎯 **Examples** - Templates and learning resources

## Architecture Highlights

### Two-Tier Catalog System

**`marketplace.json`** - Stable, production-ready skills

- Vetted and tested
- Semantic versioning
- Full documentation
- Suitable for production use

**`marketplace-preview.json`** - Beta and experimental skills

- Early access to new features
- Community testing
- May have breaking changes
- Perfect for adventurous users

### Skill Structure

Each skill follows a standardized format:

```text
skills/
└── skill-name/
    ├── SKILL.md           # Main skill definition (YAML frontmatter + content)
    ├── scripts/           # Optional: Helper scripts
    ├── references/        # Optional: Reference documentation
    └── assets/            # Optional: Images, templates, etc.
```

### Quality Standards

All marketplace skills must include:

- ✅ Valid YAML frontmatter in SKILL.md
- ✅ Clear description and usage examples
- ✅ Semantic version number
- ✅ Category and tags for discovery
- ✅ Author information

## Contributing

We welcome contributions! Here's how to add your skills:

### 1. Create Your Skill

- Follow the [Creating Skills Guide](./docs/creating-skills.md)
- Test locally using `/plugin marketplace add ./your-skill-path`
- Validate with the skill-creator toolkit

### 2. Submit for Review

- Fork this repository
- Add your skill to `skills/` directory
- Update `marketplace-preview.json` (beta skills)
- Open a Pull Request with description

### 3. Review Process

- Automated validation checks
- Community review and feedback
- Approval by maintainers

### 4. Promotion to Stable

- After testing period in preview catalog
- Based on user feedback and stability
- Moved to `marketplace.json` (stable catalog)

### 5. Maintenance

- Update your skill as needed
- Respond to issues and feedback
- Submit updates via Pull Requests

→ See full [Contributing Guidelines](./.github/CONTRIBUTING.md)

## Resources

**Official Documentation:**

- [Claude Code Plugin Marketplaces](https://code.claude.com/docs/en/plugin-marketplaces)
- [Claude Code Skills Documentation](https://code.claude.com/docs/en/skills)

**Community:**

- [GitHub Discussions](https://github.com/token-eater/skills-marketplace/discussions)
- [Report Issues](https://github.com/token-eater/skills-marketplace/issues)

**Examples:**

- [wshobson/agents](https://github.com/wshobson/agents) - Excellent reference marketplace

## Catalog Reference

### Stable Catalog (marketplace.json)

Production-ready skills, fully tested and documented:

```bash
/plugin marketplace add token-eater/skills-marketplace
```

### Preview Catalog (marketplace-preview.json)

Beta skills for early adopters:

```bash
/plugin marketplace add token-eater/skills-marketplace?ref=.claude-plugin/marketplace-preview.json
```

### Custom Catalogs

Create your own filtered views:

```bash
# Team-specific catalog
/plugin marketplace add your-org/skills-marketplace?ref=.claude-plugin/marketplace-team.json

# Personal development
/plugin marketplace add ./skills-marketplace
```

## License

MIT License - See [LICENSE](./LICENSE) for details

---

**Ready to get started?** Install the marketplace and browse available skills:

```bash
/plugin marketplace add token-eater/skills-marketplace
/plugin list
```

---

Built with [Claude Code](https://claude.com/claude-code) | Star this repo to support the project! ⭐
