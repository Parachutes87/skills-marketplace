# Slide Extraction & Generation - Lessons Learned

**Version**: 1.0
**Date**: 2025-10-13
**Purpose**: Capture all feedback and improvements from V1-V4 extraction iterations and generation workflows

---

## Overview

This document consolidates all lessons learned from iterative improvements to the PowerPoint slide extraction and Obsidian note generation workflow. **Use this as a checklist when implementing new extraction or generation features.**

---

## V4 Extraction - Production Ready Features

### ✅ Implemented Improvements

#### 1. **Navigation Breadcrumb Handling**
- **Problem**: Slides contained repeated navigation text (`Introduction | Research | Industry | Politics | Safety | Survey | Predictions`)
- **Solution**:
  - **Detect** breadcrumbs for slide classification (helps identify slide type)
  - **Remove** from output markdown (no longer clutters notes)
- **Implementation**: `extract_v4_clean.py:41-43`, `NAV_PATTERN` regex
- **Why**: Breadcrumbs are UI chrome, not content - they pollute synthesis documents

#### 2. **Hybrid H1 Title Detection (70% Accuracy)**
- **Problem**: Cannot reliably detect slide titles from font size alone (18-22pt range overlaps)
- **Solution**: Multi-factor detection combining:
  1. **Font size**: 22pt+ bold = H1 (high confidence)
  2. **Semantic analysis**: 18-21pt bold + looks like title (medium confidence)
  3. **Position**: Top 2 inches of slide favors H1 classification
- **Implementation**: `extract_v4_clean.py:76-101`
- **Why**: Single-factor detection fails on mixed-format decks

#### 3. **Logo and Icon Filtering**
- **Problem**: Small decorative images (logos, icons, badges) extracted as "main graphics"
- **Solution**: Area-based classification - **skip images < 1 square inch**
- **Implementation**: `extract_v4_clean.py:254-256`
- **Rationale**:
  - Charts/graphs: typically > 2-5 sq in
  - Logos: typically < 1 sq in
  - Default threshold: 2.0 sq in for "main graphics"
  - Aggressive filtering: 1.0 sq in minimum (for logo-heavy decks)

#### 4. **Slide Number Removal**
- **Problem**: Slide numbers like `| 42` appearing in output
- **Solution**: Filter common header patterns during extraction
- **Implementation**: `extract_v4_clean.py:36-39`, `HEADER_PATTERNS`
- **Why**: Slide numbers are presentation metadata, not content

#### 5. **Speaker Notes Cleaning**
- **Problem**: Raw speaker notes include formatting artifacts
- **Solution**: Clean and structure citations from notes
- **Implementation**: `extract_v4_clean.py:291-298`
- **Features**:
  - Extract only URLs (citations)
  - Remove duplicates, preserve order
  - Skip descriptive text (not citations)

#### 6. **PNG Transparency Fix**
- **Problem**: RGBA images render gray/opaque in Obsidian
- **Solution**: Convert RGBA → RGB with white background during extraction
- **Implementation**: `extract_year.py:104-113`
- **Why**: Markdown viewers don't always respect alpha channels

#### 7. **"Key Points" Section Conditional**
- **Problem**: Single bullet points labeled as "## Key Points" section looks awkward
- **Solution**: Only add "## Key Points" heading if **more than 1 bullet**
- **Implementation**: `extract_v4_clean.py:338-342`
- **Why**: Single items are better inline without section headers

---

## Generation Workflow (Markdown Note Creation)

### File Naming Convention
```
State of AI YYYY - Slide XXX - [Topic].md
```
- **YYYY**: Year (2020-2025)
- **XXX**: Zero-padded slide number (001, 042, 313)
- **[Topic]**: First meaningful text line (up to 60 chars)

**Example**: `State of AI 2025 - Slide 013 - Reasoning Models.md`

### Markdown Structure (V4 Format)

```markdown
---
slide_number: 13
source_file: State of AI Report - 2025 ONLINE.pptx
extraction_version: v4
date_extracted: 2025-10-13
layout_type: balanced
has_navigation: true
has_header: false
has_images: true
image_count: 2
citation_count: 3
---

# [H1 Title or "Slide N"]

**[Header]:** [Any non-nav headers]

[Body paragraphs]

## [H2 Sections]

## Key Points
(only if >1 bullet)

• **Bold bullet label**
• Regular bullet

---

## Visual Data

![](images/slide-013-graphic-0.png)

---

## Citations

1. https://example.com/paper
2. https://arxiv.org/abs/2501.12345

---

## Extraction Metadata (V4)

```json
{
  "h1": "Reasoning Models",
  "has_navigation": true,
  "body_count": 3,
  "bullet_count": 5,
  "images": [...]
}
```

## Tags
#source #state-of-ai-2025 #slide-13 #extraction-v4 #layout-balanced
```

### Frontmatter Fields (YAML)

**Required**:
- `slide_number`: Integer
- `source_file`: Original PowerPoint filename
- `extraction_version`: v4 (or current version)
- `date_extracted`: YYYY-MM-DD

**Metadata**:
- `layout_type`: text-heavy | balanced | balanced-dual | visual-heavy
- `has_navigation`: boolean (true if breadcrumb detected)
- `has_header`: boolean (non-nav headers present)
- `has_images`: boolean
- `image_count`: integer
- `citation_count`: integer

---

## What NOT to Include in Output

### ❌ Excluded Elements

1. **Navigation breadcrumbs** - `Introduction | Research | Industry | Politics...`
2. **Slide numbers** - `| 42` or standalone numbers
3. **Year headers** - `stateof.ai 2025`
4. **Small logos** - Images < 1 sq in
5. **Repeated boilerplate** - Standard footers/headers

### Why Exclude?
- These are **presentation chrome**, not content
- They clutter synthesis documents with noise
- Original context preserved in metadata for reconstruction

---

## Citation Date Extraction

### Policy
- **Extract**: Publication Date, Last Modified Date
- **Do NOT extract**: Date Accessed (not relevant for this workflow)

### Multi-Method Date Extraction

#### Method 1: arXiv URLs (100% success)
```
https://arxiv.org/abs/2501.12345
Extract: 2025-01-01 (from YYMM pattern)
```

#### Method 2: HTML Metadata (~70% success)
- Unix timestamps: `data-unix-time="1234567890"`
- Meta tags: `<meta property="article:published_time" content="2025-01-15">`
- JSON-LD: `"datePublished": "2025-01-15"`

#### Method 3: Fallback
- Return `"Unknown"` (not "Date Accessed")

### Success Rates by Source Type
| Source Type | Success Rate | Method |
|-------------|--------------|--------|
| arXiv papers | 100% | URL parsing |
| News sites (TechCrunch, Forbes) | ~90% | HTML meta tags |
| Academic journals | ~80% | Meta tags / JSON-LD |
| Company blogs | ~50% | Varies by platform |
| Dashboards / databases | ~10% | Often no pub date |

---

## Image Handling Best Practices

### Area-Based Classification Thresholds

**Always confirm threshold with user before bulk extraction**

| Deck Type | Threshold (sq in) | Rationale |
|-----------|-------------------|-----------|
| Technical reports (default) | 2.0 | Charts/graphs are large |
| Logo-heavy presentations | 3.0-4.0 | More decorative elements |
| Dense technical slides | 1.0-1.5 | Smaller but meaningful |
| Aggressive logo filtering | 1.0 | Minimum for any "main graphic" |

### Image File Naming
```
slide-NNN-graphic-X.png
```
- **NNN**: Zero-padded slide number (001-313)
- **X**: Image index (0-based)

**Example**: `slide-013-graphic-0.png`, `slide-013-graphic-1.png`

---

## Layout Classification

### Layout Types

1. **text-heavy**: No images OR >5 text elements
2. **visual-heavy**: 3+ images
3. **balanced-dual**: Exactly 2 images with moderate text
4. **balanced**: 1 image with moderate text (default)

### Why Classify?
- Helps with:
  - **Reconstruction**: Know original visual emphasis
  - **Search**: Find visual-heavy slides quickly
  - **Quality assurance**: Detect extraction issues (e.g., missing images)

---

## Known Limitations & Issues

### ⚠️ Attempted but Not Implemented

#### 1. Auto-Sizing Text Shapes
- **Attempted**: `MSO_AUTO_SIZE.SHAPE_TO_FIT_TEXT`
- **Issue**: Implementation problems (python-pptx limitations)
- **Status**: Not included in V4
- **Impact**: Text may overflow bounding boxes in reconstructed slides

#### 2. Image Display Issues - "Picture Can't Be Displayed"
- **Problem**: V4 test extraction produced markdown with broken image links when viewed in Obsidian
- **Status**: ✅ RESOLVED - Root cause identified (2025-10-13)
- **Root Cause**:
  - `extract_v4_clean.py` was a **test script** that outputs to Downloads folder, NOT Obsidian vault
  - Image paths: `/Downloads/.../v4_final_test/images/slide-060-graphic-0_v4.png`
  - Markdown refs: `![](images/slide-060-graphic-0_v4.png)` (relative paths)
  - When markdown moved to Obsidian vault (`Sources/`), images not found
- **Solution**:
  - **Use production script** `extract_year.py` which outputs directly to Obsidian vault
  - V4 test was for **feature testing only** (breadcrumbs, H1 detection, logos)
  - All V4 improvements already integrated into `extract_year.py`
- **Lesson**: Test scripts are for feature validation, not production extraction
- **Feedback**: Always verify output paths before bulk extraction - test AND production scripts may have different configurations

#### 3. Broken Image References in Test PowerPoint Files
- **Problem**: Test PPTXs created by copying slides may have broken image references
- **Error**: `KeyError: "no relationship with key 'rId3'"` when accessing `shape.image.blob`
- **Root Cause**: PowerPoint's internal relationship IDs break when slides are copied to new files
- **Solution**: Wrap image extraction in try/except to skip broken references
```python
try:
    img = fix_image_transparency(shape.image.blob)
    # ... save image
except (KeyError, Exception) as e:
    print(f"⚠️ Skipping broken image: {e}")
    pass  # Continue processing other content
```
- **Lesson**: Original source files are most reliable; test files may have artifacts
- **Feedback**: Always add error handling for image extraction - broken references are common in edited PPTXs
- **Important**: PowerPoint relationship IDs (rId) are file-specific - cannot preserve images when copying slides between files programmatically
- **Testing Strategy**: Extract directly from original source files; creating subset test PPTXs will always break image references

### ⚠️ When to Use Alternative Tools

#### Chrome DevTools MCP (Not python-pptx)
Use when:
- Google Slides (not PowerPoint)
- Password-protected files
- Complex visual layouts need screenshot context
- Quality checking visual appearance

#### OCR (Not python-pptx)
Use when:
- Password-protected files
- Only screenshots available
- Embedded images contain text

---

## Testing & Quality Assurance

### V4 Test Slides (Diverse Sample)
```python
TEST_SLIDES = [60, 84, 121, 138, 152, 198, 210, 263, 276, 312]
```

### QA Checklist
- [ ] H1 detection accuracy (manual review of 10 slides)
- [ ] Navigation breadcrumbs removed from output
- [ ] No small logos in extracted images
- [ ] PNG transparency fixed (check in Obsidian)
- [ ] **Images display correctly in Obsidian** (not "picture can't be displayed")
- [ ] Image file paths match markdown references
- [ ] Citations extracted with publication dates
- [ ] Frontmatter YAML is valid
- [ ] Wikilinks resolve correctly in Obsidian
- [ ] Progress log created

---

## Performance Metrics

### V4 Production Run (2025 Report)
- **Slides processed**: 313
- **Images extracted**: 434
- **Citations extracted**: 941
- **Processing time**: ~60 seconds (5 slides/second)
- **H1 detection accuracy**: ~70% (hybrid approach)
- **Date extraction success**: ~36% (varies by source type)

### Performance Tips
- `python-pptx` is **very fast** (no rendering overhead)
- Date extraction is **slow** (network calls to fetch HTML)
- Use `--max-time` and `timeout` for date extraction
- Progress logs every 10 slides for long-running extractions

---

## Future Enhancements (Not Yet Implemented)

1. **ML-based date extraction**: Train model on unstructured text
2. **Zotero integration**: Auto-populate citation metadata
3. **Chart data extraction**: Get underlying data from PowerPoint charts
4. **Version tracking**: Monitor when source URLs change
5. **Speaker notes parsing**: Structured parsing of citation formats
6. **Video timestamp links**: Link citations to video timestamps

---

## Critical Reminders for Next Implementation

### Before Starting New Extraction:
1. ✅ **Use production script** (`extract_year.py`) NOT test scripts (`extract_v4_clean.py`)
2. ✅ **Verify output paths** point to Obsidian vault, not Downloads folder
3. ✅ **Confirm image area threshold** with user (don't assume 2.0 sq in)
4. ✅ **Test on 5-10 slides first** before bulk extraction
5. ✅ **Verify navigation breadcrumbs removed** from output (not just detected)
6. ✅ **Check H1 detection accuracy** on sample (should be ~70%)
7. ✅ **Validate PNG transparency fix** (open in Obsidian to verify)
8. ✅ **Test image display IN Obsidian** (not just that files exist)

### During Implementation:
- **Use V4 as base** (`extract_v4_clean.py`) - it's production-ready
- **Don't reintroduce removed features** (breadcrumbs, slide numbers, logos)
- **Progress logs every 10 slides** for user visibility
- **Handle errors gracefully** (skip problematic slides, log them)

### After Extraction:
- **Review sample notes in Obsidian** (5-10 random slides)
- **Check wikilinks resolve** (use "Show unresolved links")
- **Validate frontmatter YAML** (use Obsidian's frontmatter editor)
- **Spot-check date extraction** (compare to manual inspection)

---

## Related Documentation

- [Citation Lineage Tools and Process](../Citation-Lineage-Tools-and-Process.md) - Main workflow guide
- [Citation Lineage Workflow](.claude/Citation-Lineage-Workflow.md) - Code examples
- [CLAUDE.md (Secret Handling)](.claude/CLAUDE.md#secret-handling-policy) - Security policy
- [WORKFLOW.md](.github/WORKFLOW.md) - Git workflow (if exists)

---

## Version History

- **V4 (2025-10-13)**: Production-ready extraction with all improvements
  - **Session note**: Spent significant time trying to create test PPTX by copying slides - discovered this fundamentally doesn't work due to PowerPoint's image relationship architecture. Don't repeat this mistake - extract from original files only.
- **V3 (2025-10-12)**: Hybrid H1 detection, color preservation
- **V2 (2025-10-11)**: Enhanced metadata, PNG transparency fix
- **V1 (2025-10-10)**: Initial extraction with basic functionality

---

## Quick Reference - Key Commands

```bash
# Extract single year
python3 extract_year.py 2025

# Extract specific slides (V4 test)
python3 extract_v4_clean.py

# Check extraction progress
cat slide_extraction_progress_2025.md

# Verify image transparency fix
python3 -c "from PIL import Image; print(Image.open('slide-001-graphic-0.png').mode)"
# Should print "RGB" not "RGBA"
```

---

**Remember**: This is a **living document**. Update it with new lessons learned after each extraction iteration!
