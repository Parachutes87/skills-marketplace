#!/bin/bash
#
# File: .claude/security/verify-github-release.sh
#
# Purpose: Verify GitHub release assets using SLSA attestations + manual checks
# Usage: ./verify-github-release.sh <owner/repo> <tag> <asset-name>
# Example: ./verify-github-release.sh explosion/spacy-models en_core_web_lg-3.8.0 en_core_web_lg-3.8.0-py3-none-any.whl
#
# Security: Defense in depth - attestations first, manual verification fallback
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Parse arguments
REPO=$1
TAG=$2
ASSET_NAME=$3

if [[ -z "$REPO" || -z "$TAG" || -z "$ASSET_NAME" ]]; then
  echo -e "${RED}❌ Usage: $0 <owner/repo> <tag> <asset-name>${NC}"
  echo "Example: $0 explosion/spacy-models en_core_web_lg-3.8.0 en_core_web_lg-3.8.0-py3-none-any.whl"
  exit 1
fi

echo -e "${BLUE}🔒 Security Verification Pipeline${NC}"
echo "=================================="
echo "Repository: $REPO"
echo "Tag: $TAG"
echo "Asset: $ASSET_NAME"
echo ""

# Track verification results
PASSED=0
FAILED=0
WARNINGS=0

# Step 1: Check for SLSA Attestations
echo -e "${BLUE}[Step 1/5]${NC} Checking for SLSA attestations..."

if command -v gh &> /dev/null; then
  ATTESTATIONS=$(gh release view "$TAG" \
    --repo "$REPO" \
    --json assets \
    --jq '.assets[] | select(.name | contains("intoto") or contains("attestation")) | .name' 2>/dev/null || echo "")

  if [[ -n "$ATTESTATIONS" ]]; then
    echo -e "${GREEN}✅ SLSA attestations found:${NC}"
    echo "$ATTESTATIONS" | sed 's/^/   /'
    ((PASSED++))

    # Try to verify with slsa-verifier if available
    if command -v slsa-verifier &> /dev/null; then
      echo ""
      echo -e "${BLUE}   Attempting cryptographic verification...${NC}"
      # Download asset and attestation
      gh release download "$TAG" \
        --repo "$REPO" \
        --pattern "$ASSET_NAME" \
        --skip-existing 2>/dev/null || true

      # Find attestation file
      ATTESTATION_FILE=$(echo "$ATTESTATIONS" | grep "$ASSET_NAME" | head -1)
      if [[ -n "$ATTESTATION_FILE" ]]; then
        gh release download "$TAG" \
          --repo "$REPO" \
          --pattern "$ATTESTATION_FILE" \
          --skip-existing 2>/dev/null || true

        # Verify
        if slsa-verifier verify-artifact \
          --provenance-path "$ATTESTATION_FILE" \
          --source-uri "github.com/$REPO" \
          "$ASSET_NAME" 2>/dev/null; then
          echo -e "${GREEN}   ✅ Cryptographic verification PASSED${NC}"
          ((PASSED++))
        else
          echo -e "${RED}   ❌ Cryptographic verification FAILED${NC}"
          ((FAILED++))
        fi
      fi
    else
      echo -e "${YELLOW}   ⚠️  slsa-verifier not installed (optional)${NC}"
      echo "   Install: go install github.com/slsa-framework/slsa-verifier/v2/cli/slsa-verifier@latest"
      ((WARNINGS++))
    fi
  else
    echo -e "${YELLOW}⚠️  No SLSA attestations found - using manual verification${NC}"
    ((WARNINGS++))
  fi
else
  echo -e "${RED}❌ GitHub CLI (gh) not found - cannot check attestations${NC}"
  echo "Install: https://cli.github.com/"
  ((FAILED++))
fi

echo ""

# Step 2: Check Release Signatures
echo -e "${BLUE}[Step 2/5]${NC} Checking release signatures and metadata..."

if command -v gh &> /dev/null; then
  RELEASE_INFO=$(gh release view "$TAG" --repo "$REPO" 2>/dev/null || echo "")

  if [[ -n "$RELEASE_INFO" ]]; then
    echo -e "${GREEN}✅ Release metadata retrieved${NC}"

    # Check for verification badges
    if echo "$RELEASE_INFO" | grep -q "Verified"; then
      echo -e "${GREEN}   ✅ Release is verified by GitHub${NC}"
      ((PASSED++))
    else
      echo -e "${YELLOW}   ⚠️  Release verification status unknown${NC}"
      ((WARNINGS++))
    fi

    # Show release author
    AUTHOR=$(echo "$RELEASE_INFO" | grep "author:" | head -1 | awk '{print $2}')
    if [[ -n "$AUTHOR" ]]; then
      echo "   Release author: $AUTHOR"
    fi

    # Show release date
    DATE=$(echo "$RELEASE_INFO" | grep "published:" | head -1 | sed 's/published://')
    if [[ -n "$DATE" ]]; then
      echo "   Published:$DATE"
    fi
  else
    echo -e "${RED}❌ Could not retrieve release metadata${NC}"
    ((FAILED++))
  fi
else
  echo -e "${YELLOW}⚠️  GitHub CLI not available${NC}"
  ((WARNINGS++))
fi

echo ""

# Step 3: Verify Checksums
echo -e "${BLUE}[Step 3/5]${NC} Verifying checksums..."

# Look for checksum files
CHECKSUM_FILES=("SHA256SUMS" "SHA256SUMS.txt" "checksums.txt" "${ASSET_NAME}.sha256")

CHECKSUM_FOUND=false
for CHECKSUM_FILE in "${CHECKSUM_FILES[@]}"; do
  if gh release download "$TAG" \
    --repo "$REPO" \
    --pattern "$CHECKSUM_FILE" \
    --skip-existing 2>/dev/null; then

    echo -e "${GREEN}✅ Checksum file found: $CHECKSUM_FILE${NC}"
    CHECKSUM_FOUND=true

    # Download asset if not already present
    gh release download "$TAG" \
      --repo "$REPO" \
      --pattern "$ASSET_NAME" \
      --skip-existing 2>/dev/null || true

    # Verify checksum
    if [[ -f "$ASSET_NAME" ]]; then
      if sha256sum -c "$CHECKSUM_FILE" 2>/dev/null | grep -q "$ASSET_NAME: OK"; then
        echo -e "${GREEN}   ✅ Checksum verification PASSED${NC}"
        ((PASSED++))
      else
        echo -e "${RED}   ❌ Checksum verification FAILED${NC}"
        ((FAILED++))
      fi
    fi
    break
  fi
done

if [[ "$CHECKSUM_FOUND" == false ]]; then
  echo -e "${YELLOW}⚠️  No checksum file found in release${NC}"
  echo "   Checked: ${CHECKSUM_FILES[*]}"
  ((WARNINGS++))
fi

echo ""

# Step 4: Check OSV Database for Known Vulnerabilities
echo -e "${BLUE}[Step 4/5]${NC} Checking OSV database for known vulnerabilities..."

# Extract package name from asset (remove version and extension)
PACKAGE_NAME=$(echo "$ASSET_NAME" | sed -E 's/-[0-9]+\.[0-9]+\.[0-9]+.*//')

if command -v curl &> /dev/null && command -v jq &> /dev/null; then
  OSV_QUERY='{"package":{"name":"'"$PACKAGE_NAME"'","ecosystem":"PyPI"}}'
  OSV_RESULT=$(curl -s "https://api.osv.dev/v1/query" -d "$OSV_QUERY" | jq -r '.vulns // []')

  if [[ "$OSV_RESULT" == "[]" ]]; then
    echo -e "${GREEN}✅ No known vulnerabilities found in OSV database${NC}"
    ((PASSED++))
  else
    VULN_COUNT=$(echo "$OSV_RESULT" | jq 'length')
    echo -e "${RED}❌ Found $VULN_COUNT known vulnerabilities${NC}"
    echo "$OSV_RESULT" | jq -r '.[] | "   - \(.id): \(.summary)"'
    ((FAILED++))
  fi
else
  echo -e "${YELLOW}⚠️  curl or jq not available - skipping OSV check${NC}"
  ((WARNINGS++))
fi

echo ""

# Step 5: Security Summary
echo -e "${BLUE}[Step 5/5]${NC} Security verification summary..."
echo ""
echo "Results:"
echo -e "  ${GREEN}✅ Passed checks: $PASSED${NC}"
echo -e "  ${RED}❌ Failed checks: $FAILED${NC}"
echo -e "  ${YELLOW}⚠️  Warnings: $WARNINGS${NC}"
echo ""

# Determine overall status
if [[ $FAILED -eq 0 && $PASSED -ge 2 ]]; then
  echo -e "${GREEN}✅ VERIFICATION PASSED${NC}"
  echo "   Asset appears safe to use (passed $PASSED checks)"
  exit 0
elif [[ $FAILED -eq 0 && $PASSED -ge 1 ]]; then
  echo -e "${YELLOW}⚠️  VERIFICATION INCONCLUSIVE${NC}"
  echo "   Some checks passed but verification incomplete"
  echo "   Manual review recommended before use"
  exit 2
else
  echo -e "${RED}❌ VERIFICATION FAILED${NC}"
  echo "   Do NOT use this asset without manual security review"
  echo "   Failed checks must be investigated"
  exit 1
fi
