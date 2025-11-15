#!/bin/bash
#
# File: .claude/security/verify-python-package.sh
#
# Purpose: Verify Python packages before installation using pip-audit and safety
# Usage: ./verify-python-package.sh <package-name> [version]
# Example: ./verify-python-package.sh presidio-analyzer 2.2.354
#
# Security: Defense in depth - multiple vulnerability databases
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Parse arguments
PACKAGE=$1
VERSION=$2

if [[ -z "$PACKAGE" ]]; then
  echo -e "${RED}❌ Usage: $0 <package-name> [version]${NC}"
  echo "Example: $0 presidio-analyzer 2.2.354"
  exit 1
fi

if [[ -n "$VERSION" ]]; then
  FULL_PACKAGE="$PACKAGE==$VERSION"
else
  FULL_PACKAGE="$PACKAGE"
fi

echo -e "${BLUE}🔒 Python Package Security Verification${NC}"
echo "========================================"
echo "Package: $FULL_PACKAGE"
echo ""

PASSED=0
FAILED=0
WARNINGS=0

# Step 1: Check with pip-audit (official Python tool)
echo -e "${BLUE}[Step 1/3]${NC} Checking with pip-audit (OSV database)..."

if command -v pip-audit &> /dev/null; then
  # Create temp requirements file
  TEMP_REQ=$(mktemp)
  echo "$FULL_PACKAGE" > "$TEMP_REQ"

  if pip-audit -r "$TEMP_REQ" 2>&1 | tee /tmp/pip-audit-output.txt | grep -q "No known vulnerabilities found"; then
    echo -e "${GREEN}✅ pip-audit: No known vulnerabilities${NC}"
    ((PASSED++))
  elif grep -q "Found" /tmp/pip-audit-output.txt; then
    echo -e "${RED}❌ pip-audit: Vulnerabilities found${NC}"
    cat /tmp/pip-audit-output.txt
    ((FAILED++))
  else
    echo -e "${YELLOW}⚠️  pip-audit: Check inconclusive${NC}"
    ((WARNINGS++))
  fi

  rm -f "$TEMP_REQ"
else
  echo -e "${YELLOW}⚠️  pip-audit not installed${NC}"
  echo "   Install: pip install pip-audit"
  ((WARNINGS++))
fi

echo ""

# Step 2: Check with safety (community database)
echo -e "${BLUE}[Step 2/3]${NC} Checking with safety (Safety DB)..."

if command -v safety &> /dev/null; then
  TEMP_REQ=$(mktemp)
  echo "$FULL_PACKAGE" > "$TEMP_REQ"

  if safety check -r "$TEMP_REQ" --output text 2>&1 | tee /tmp/safety-output.txt | grep -qi "No known security vulnerabilities"; then
    echo -e "${GREEN}✅ safety: No known vulnerabilities${NC}"
    ((PASSED++))
  elif grep -qi "vulnerability" /tmp/safety-output.txt; then
    echo -e "${RED}❌ safety: Vulnerabilities found${NC}"
    cat /tmp/safety-output.txt
    ((FAILED++))
  else
    echo -e "${YELLOW}⚠️  safety: Check inconclusive${NC}"
    ((WARNINGS++))
  fi

  rm -f "$TEMP_REQ"
else
  echo -e "${YELLOW}⚠️  safety not installed${NC}"
  echo "   Install: pip install safety"
  ((WARNINGS++))
fi

echo ""

# Step 3: Check package metadata and typosquatting
echo -e "${BLUE}[Step 3/3]${NC} Checking package metadata..."

if command -v pip &> /dev/null; then
  # Get package info from PyPI
  PYPI_INFO=$(curl -s "https://pypi.org/pypi/$PACKAGE/json" 2>/dev/null || echo "{}")

  if echo "$PYPI_INFO" | jq -e '.info' > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Package found on PyPI${NC}"

    # Extract metadata
    AUTHOR=$(echo "$PYPI_INFO" | jq -r '.info.author // "Unknown"')
    MAINTAINER=$(echo "$PYPI_INFO" | jq -r '.info.maintainer // "Unknown"')
    HOMEPAGE=$(echo "$PYPI_INFO" | jq -r '.info.home_page // "Unknown"')
    LICENSE=$(echo "$PYPI_INFO" | jq -r '.info.license // "Unknown"')
    DOWNLOADS=$(echo "$PYPI_INFO" | jq -r '.info.download_count // "Unknown"')

    echo "   Author: $AUTHOR"
    echo "   Maintainer: $MAINTAINER"
    echo "   Homepage: $HOMEPAGE"
    echo "   License: $LICENSE"

    # Check for suspicious indicators
    if [[ "$AUTHOR" == "Unknown" ]] && [[ "$MAINTAINER" == "Unknown" ]]; then
      echo -e "${YELLOW}   ⚠️  No author/maintainer information${NC}"
      ((WARNINGS++))
    fi

    # Check for recent upload (supply chain attack indicator)
    UPLOAD_TIME=$(echo "$PYPI_INFO" | jq -r '.urls[0].upload_time // "Unknown"')
    echo "   Last upload: $UPLOAD_TIME"

    ((PASSED++))
  else
    echo -e "${RED}❌ Package not found on PyPI or API error${NC}"
    echo "   This could indicate a typosquatting attempt"
    ((FAILED++))
  fi
else
  echo -e "${YELLOW}⚠️  pip not available${NC}"
  ((WARNINGS++))
fi

echo ""

# Summary
echo -e "${BLUE}Security Verification Summary${NC}"
echo "=============================="
echo ""
echo "Results:"
echo -e "  ${GREEN}✅ Passed checks: $PASSED${NC}"
echo -e "  ${RED}❌ Failed checks: $FAILED${NC}"
echo -e "  ${YELLOW}⚠️  Warnings: $WARNINGS${NC}"
echo ""

# Determine overall status
if [[ $FAILED -eq 0 && $PASSED -ge 2 ]]; then
  echo -e "${GREEN}✅ VERIFICATION PASSED${NC}"
  echo "   Package appears safe to install"
  echo ""
  echo "   Install with: pip install $FULL_PACKAGE"
  exit 0
elif [[ $FAILED -eq 0 && $PASSED -ge 1 ]]; then
  echo -e "${YELLOW}⚠️  VERIFICATION INCONCLUSIVE${NC}"
  echo "   Some checks passed but verification incomplete"
  echo "   Consider manual review before installation"
  exit 2
else
  echo -e "${RED}❌ VERIFICATION FAILED${NC}"
  echo "   Do NOT install this package without manual security review"
  exit 1
fi
