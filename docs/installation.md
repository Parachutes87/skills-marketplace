# Installation Guide

Learn how to install and use skills from the Skills Marketplace.

## Prerequisites

- **Claude Code** installed and configured
- Access to the marketplace repository (public or via fork)

## Quick Start

### 1. Add the Marketplace

**From GitHub (Recommended):**

```bash
/plugin marketplace add token-eater/skills-marketplace
```

**From Local Clone:**

```bash
git clone https://github.com/token-eater/skills-marketplace.git
cd skills-marketplace
/plugin marketplace add .
```

### 2. Browse Available Skills

```bash
# List all skills in the marketplace
/plugin list

# Filter by category
/plugin list --category productivity
```

### 3. Install Skills

```bash
# Install a specific skill
/plugin install example-skill

# Install multiple skills
/plugin install skill-one skill-two skill-three
```

### 4. Use Your Skills

Once installed, skills are available in Claude Code. Refer to each skill's documentation for specific usage instructions.

## Catalog Options

The marketplace offers multiple catalogs for different needs:

### Stable Catalog (Default)

Production-ready skills, fully tested and documented:

```bash
/plugin marketplace add token-eater/skills-marketplace
```

**Best for:**
- Production environments
- Stability-focused workflows
- General use

### Preview Catalog

Beta and experimental skills for early adopters:

```bash
/plugin marketplace add token-eater/skills-marketplace?ref=.claude-plugin/marketplace-preview.json
```

**Best for:**
- Testing new features
- Providing feedback to skill authors
- Adventurous users

**Note:** Preview skills may have breaking changes or incomplete documentation.

## Managing Installed Skills

### Update Skills

```bash
# Update all skills from marketplace
/plugin update

# Update specific skill
/plugin update example-skill
```

### Remove Skills

```bash
# Remove a skill
/plugin uninstall example-skill

# Remove marketplace
/plugin marketplace remove skills-marketplace
```

### Check Installed Skills

```bash
# List installed skills
/plugin list --installed

# Show skill details
/plugin info example-skill
```

## Marketplace Commands

### Refresh Marketplace

After new skills are added to the marketplace:

```bash
/plugin marketplace refresh skills-marketplace
```

### Switch Catalogs

Change between stable and preview catalogs:

```bash
# Switch to preview
/plugin marketplace add token-eater/skills-marketplace?ref=.claude-plugin/marketplace-preview.json

# Switch back to stable
/plugin marketplace add token-eater/skills-marketplace
```

## Local Development

For skill developers or advanced users:

### 1. Clone the Repository

```bash
git clone https://github.com/token-eater/skills-marketplace.git
cd skills-marketplace
```

### 2. Add as Local Marketplace

```bash
/plugin marketplace add .
```

### 3. Make Changes

Edit skills in the `skills/` directory and update catalog files.

### 4. Test Changes

```bash
# Refresh to pick up changes
/plugin marketplace refresh

# Test modified skills
/plugin install your-modified-skill
```

### 5. Contribute Back

See [Contributing Guide](./contributing.md) for submitting your improvements.

## Troubleshooting

### Marketplace Not Loading

**Symptom:** Marketplace doesn't appear in `/plugin list`

**Solutions:**

```bash
# Verify JSON syntax
cat .claude-plugin/marketplace.json | jq .

# Re-add marketplace
/plugin marketplace remove skills-marketplace
/plugin marketplace add token-eater/skills-marketplace

# Check Claude Code logs for errors
```

### Skill Not Appearing

**Symptom:** Specific skill missing from `/plugin list`

**Solutions:**

- Verify skill exists in `skills/` directory
- Check catalog has correct `source` path
- Ensure SKILL.md has valid YAML frontmatter
- Refresh marketplace: `/plugin marketplace refresh`

### Installation Fails

**Symptom:** `/plugin install skill-name` fails

**Solutions:**

- Check skill dependencies are installed
- Verify SKILL.md structure is valid
- Look for error messages in Claude Code output
- Try removing and re-adding marketplace

### Updates Not Showing

**Symptom:** New versions don't appear after update

**Solutions:**

```bash
# Refresh marketplace catalog
/plugin marketplace refresh skills-marketplace

# Force reinstall
/plugin uninstall skill-name
/plugin install skill-name

# Clear cache (if applicable)
rm -rf ~/.claude/plugin-cache/
```

## Advanced Usage

### Multiple Marketplaces

You can add multiple marketplaces:

```bash
# Add official marketplace
/plugin marketplace add token-eater/skills-marketplace

# Add personal marketplace
/plugin marketplace add your-personal-username/my-skills

# Add team marketplace
/plugin marketplace add your-org/team-skills
```

Skills from all marketplaces will be available.

### Custom Catalog Files

Create custom catalog views:

```bash
# Team-specific skills
/plugin marketplace add your-org/skills-marketplace?ref=.claude-plugin/marketplace-team.json

# Organization-specific
/plugin marketplace add your-org/skills-marketplace?ref=.claude-plugin/marketplace-org.json
```

### Pin Specific Versions

Reference a specific git tag/branch:

```bash
# Pin to version tag
/plugin marketplace add token-eater/skills-marketplace@v1.0.0

# Pin to specific branch
/plugin marketplace add token-eater/skills-marketplace@main
```

## Best Practices

### For Users

- ✅ Start with stable catalog for production
- ✅ Test skills in preview catalog before adoption
- ✅ Keep skills updated with `/plugin update`
- ✅ Provide feedback via GitHub issues
- ✅ Star repos of useful skills

### For Developers

- ✅ Test locally before contributing
- ✅ Use semantic versioning
- ✅ Document usage clearly
- ✅ Respond to user issues
- ✅ Keep skills focused and granular

## Next Steps

- 📖 [Browse all skills](./skills.md)
- 🛠️ [Create your own skills](./creating-skills.md)
- 🤝 [Contribute to the marketplace](./contributing.md)
- 🏗️ [Learn about marketplace architecture](./architecture.md)

## Support

Need help?

- 💬 [GitHub Discussions](https://github.com/token-eater/skills-marketplace/discussions)
- 🐛 [Report Issues](https://github.com/token-eater/skills-marketplace/issues)
- 📚 [Read full documentation](../)
