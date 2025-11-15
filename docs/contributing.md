# Contributing Guide

Want to contribute skills to the marketplace? This guide will walk you through the process.

## Quick Links

- 📋 [Full Contributing Guidelines](../.github/CONTRIBUTING.md) - Detailed contribution policies
- 🛠️ [Creating Skills Guide](./creating-skills.md) - How to build skills
- 📥 [Installation Guide](./installation.md) - How to test skills locally

## Overview

Contributing to the Skills Marketplace involves:

1. **Creating** a skill that solves a specific problem
2. **Testing** it locally in Claude Code
3. **Submitting** via Pull Request for community review
4. **Maintaining** your skill after acceptance

## Quick Start

### 1. Fork the Repository

```bash
# Click "Fork" on GitHub, then:
git clone https://github.com/YOUR-USERNAME/skills-marketplace.git
cd skills-marketplace
```

### 2. Create Your Skill

```bash
# Create skill structure (recommended)
python3 ~/.claude/skills/skill-creator/scripts/init_skill.py \
  your-skill-name \
  --path ./skills

# Or create manually
mkdir -p skills/your-skill-name
```

### 3. Write Your Skill

Edit `skills/your-skill-name/SKILL.md`:

```markdown
---
name: your-skill-name
description: Brief description of what it does
version: 1.0.0
author: Your Name
category: productivity
tags:
  - automation
  - workflow
---

# Your Skill Name

[Documentation here]
```

See [Creating Skills Guide](./creating-skills.md) for detailed instructions.

### 4. Test Locally

```bash
# Add marketplace locally
/plugin marketplace add .

# Install your skill
/plugin install your-skill-name

# Test in Claude Code
```

### 5. Validate

```bash
# Check structure and frontmatter
python3 ~/.claude/skills/skill-creator/scripts/quick_validate.py \
  ./skills/your-skill-name
```

### 6. Add to Preview Catalog

Edit `.claude-plugin/marketplace-preview.json`:

```json
{
  "plugins": [
    {
      "name": "your-skill-name",
      "description": "Brief description",
      "version": "1.0.0",
      "author": "Your Name",
      "category": "productivity",
      "tags": ["automation", "workflow"],
      "source": "./skills/your-skill-name"
    }
  ]
}
```

**Note:** New skills start in the **preview catalog**. After testing and positive feedback, they're promoted to the stable catalog.

### 7. Create Pull Request

```bash
# Commit your changes
git add skills/your-skill-name/
git add .claude-plugin/marketplace-preview.json
git commit -m "feat: Add your-skill-name skill"

# Push to your fork
git push origin main

# Create PR on GitHub
```

## Pull Request Guidelines

Your PR should include:

### Required Information

- **Skill name and purpose** - What does it do?
- **Category** - Which category does it belong to?
- **Usage example** - Show how to use it
- **Testing** - How did you test it?
- **Dependencies** - Any required tools or packages?

### PR Template

```markdown
## Skill Submission: [Skill Name]

**Description:** Brief description of what the skill does

**Category:** productivity | development | data | documentation | devops | ai-ml | security | web | knowledge | examples

**Usage Example:**
```bash
# Show how to use the skill
```

**Testing:**
- [x] Tested locally in Claude Code
- [x] Validated with skill-creator toolkit
- [x] Checked for secrets/credentials
- [x] Documentation complete

**Dependencies:**
- List any external dependencies

**Additional Notes:**
Any other relevant information
```

## Review Process

After submission:

1. **Automated Validation** - GitHub Actions validates structure
2. **Community Review** - Other contributors provide feedback
3. **Maintainer Review** - Project maintainers approve changes
4. **Preview Catalog** - Skill added to beta catalog
5. **Testing Period** - Community tests and provides feedback
6. **Stable Promotion** - After successful testing, moved to stable catalog

## Quality Standards

All skills must meet these requirements:

### Structure

- ✅ Valid `SKILL.md` with YAML frontmatter
- ✅ Proper directory structure
- ✅ No frontmatter in reference files
- ✅ Required fields present

### Documentation

- ✅ Clear description (1-2 sentences)
- ✅ Usage examples
- ✅ Dependencies listed
- ✅ Troubleshooting section (if applicable)

### Security

- ✅ No hardcoded secrets or credentials
- ✅ No sensitive data in examples
- ✅ Secure credential handling documented

### Testing

- ✅ Tested in Claude Code
- ✅ All examples verified
- ✅ Error handling works
- ✅ Dependencies documented

## Contribution Types

### New Skills

Most common contribution - add a new skill to the marketplace.

**Process:** Create → Test → Submit to preview catalog → Review → Promote

### Skill Updates

Improve existing skills with bug fixes or new features.

**Process:** Fork → Update → Test → Submit PR → Review

**Versioning:**
- Bug fixes: Increment PATCH (1.0.0 → 1.0.1)
- New features: Increment MINOR (1.0.0 → 1.1.0)
- Breaking changes: Increment MAJOR (1.0.0 → 2.0.0)

### Documentation

Improve guides, examples, or README.

**Process:** Fork → Edit → Submit PR → Review

### Bug Reports

Found an issue? Report it!

**Process:** [Create issue](https://github.com/token-eater/skills-marketplace/issues/new?template=bug_report.md) → Describe problem → Provide details

### Feature Requests

Have an idea for improvement?

**Process:** [Create issue](https://github.com/token-eater/skills-marketplace/issues/new?template=feature_request.md) → Describe feature → Explain benefits

## Catalog Tiers

Skills progress through catalog tiers:

### Preview Catalog (`marketplace-preview.json`)

**Purpose:** Beta testing and community feedback
**Requirements:** Basic quality standards met
**Audience:** Early adopters and testers

### Stable Catalog (`marketplace.json`)

**Purpose:** Production-ready skills
**Requirements:** Tested, documented, stable
**Audience:** General users

Skills start in **preview** and are promoted to **stable** after successful testing.

## Maintaining Your Skills

After your skill is accepted:

### Respond to Issues

- Monitor issues labeled with your skill name
- Provide helpful responses
- Submit fixes via PR

### Keep Updated

- Update dependencies as needed
- Fix bugs promptly
- Add new features based on feedback

### Versioning

Follow semantic versioning:

```bash
# Bug fix
# Update version: 1.0.0 → 1.0.1

# New feature
# Update version: 1.0.0 → 1.1.0

# Breaking change
# Update version: 1.0.0 → 2.0.0
```

Update version in:
- `SKILL.md` frontmatter
- Marketplace catalog JSON

### Deprecation

If you can no longer maintain a skill:

1. Open an issue to notify maintainers
2. Mark skill as "looking for maintainer"
3. Help transition to new maintainer if found
4. Skill may be moved to deprecated catalog

## Code of Conduct

This project adheres to a [Code of Conduct](../.github/CODE_OF_CONDUCT.md). By contributing, you agree to:

- Be respectful and inclusive
- Provide constructive feedback
- Focus on what's best for the community
- Accept responsibility for your contributions

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (MIT License).

## Getting Help

Need assistance?

### Resources

- 📖 [Creating Skills Guide](./creating-skills.md)
- 📥 [Installation Guide](./installation.md)
- 🏗️ [Architecture Guide](./architecture.md)
- 📋 [Full Contributing Guidelines](../.github/CONTRIBUTING.md)

### Support Channels

- 💬 [GitHub Discussions](https://github.com/token-eater/skills-marketplace/discussions) - Ask questions
- 🐛 [GitHub Issues](https://github.com/token-eater/skills-marketplace/issues) - Report problems
- 📧 Contact maintainers via GitHub

## Examples

See existing skills for reference:

- `example-skill` - Basic structure and frontmatter
- `example-visibility-test` - Testing configurations

Browse the [Skills Reference](./skills.md) for more examples.

## Recognition

Contributors are recognized in:

- Skill authorship (frontmatter `author` field)
- GitHub contributors page
- Release notes (for significant contributions)
- Community discussions and documentation

Thank you for contributing to the Skills Marketplace! 🎉

## Next Steps

1. 🛠️ [Create your skill](./creating-skills.md)
2. 📥 [Test it locally](./installation.md)
3. 🚀 Submit your PR
4. 🎉 Share with the community!
