#!/bin/bash
#
# APEX-OS Project Installation Script
# Installs APEX-OS to current directory
#

set -e

APEX_OS_DIR="$HOME/apex-os"
PROFILE="default"
PROJECT_DIR=$(pwd)

# Colors
BLUE='\033[0;36m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

print_section() { echo -e "${BLUE}=== $1 ===${NC}"; }
print_status() { echo -e "${BLUE}$1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }
print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠  $1${NC}"; }

print_section "APEX-OS Project Installation"
echo ""

# Check if ~/apex-os exists
if [ ! -d "$APEX_OS_DIR" ]; then
    print_error "APEX-OS is not installed."
    echo ""
    echo "Please run the base installation first:"
    echo "  curl -sSL https://raw.githubusercontent.com/AltbridgeInc/apex-os/main/scripts/base-install.sh | bash"
    exit 1
fi

echo -e "📍 Installing APEX-OS to: ${YELLOW}$PROJECT_DIR${NC}"
echo ""

print_status "Installing APEX-OS components..."
echo ""

# Create .claude directory structure (for Claude Code)
print_status "Creating .claude directory structure..."
mkdir -p .claude/agents/apex-os
mkdir -p .claude/commands/apex-os
mkdir -p .claude/skills
echo "✓ Created .claude structure for Claude Code"
echo ""

# Install agents to .claude
print_status "Installing agents to .claude..."
if [ -d "$APEX_OS_DIR/profiles/$PROFILE/agents" ]; then
    cp "$APEX_OS_DIR/profiles/$PROFILE/agents/"*.md .claude/agents/apex-os/ 2>/dev/null || true
    AGENTS=$(ls -1 .claude/agents/apex-os/*.md 2>/dev/null | wc -l)
    echo "✓ Installed $AGENTS agents to .claude/agents/apex-os/"
fi
echo ""

# Install commands to .claude
print_status "Installing commands to .claude..."
if [ -d "$APEX_OS_DIR/profiles/$PROFILE/commands" ]; then
    cp -r "$APEX_OS_DIR/profiles/$PROFILE/commands/"* .claude/commands/apex-os/ 2>/dev/null || true
    COMMANDS=$(find .claude/commands/apex-os -name "*.md" 2>/dev/null | wc -l)
    echo "✓ Installed $COMMANDS commands to .claude/commands/apex-os/"
fi
echo ""

# Install skills to .claude
print_status "Installing skills to .claude..."
if [ -d "$APEX_OS_DIR/profiles/$PROFILE/skills" ]; then
    cp -r "$APEX_OS_DIR/profiles/$PROFILE/skills/"* .claude/skills/ 2>/dev/null || true
    SKILLS=$(ls -1d .claude/skills/*/ 2>/dev/null | wc -l)
    echo "✓ Installed $SKILLS skills to .claude/skills/"
fi
echo ""

# Create apex-os meta folder (for trading-specific content)
print_status "Creating apex-os meta folder..."
mkdir -p apex-os
echo "✓ Created apex-os/ folder"
echo ""

# Copy principles to apex-os folder
if [ -d "$APEX_OS_DIR/profiles/$PROFILE/principles" ]; then
    cp -r "$APEX_OS_DIR/profiles/$PROFILE/principles" apex-os/
    echo "✓ Installed apex-os/principles/"
fi

# Create data directories in apex-os
mkdir -p apex-os/data/fmp
mkdir -p apex-os/data/youtube
echo "✓ Created apex-os/data/ directories"

# Create workflow directories in apex-os
mkdir -p apex-os/opportunities
mkdir -p apex-os/analysis
mkdir -p apex-os/positions
mkdir -p apex-os/reports
echo "✓ Created apex-os workflow directories"

# Copy FMP scripts to apex-os
if [ -d "$APEX_OS_DIR/scripts/data-fetching/fmp" ]; then
    mkdir -p apex-os/scripts/data-fetching/fmp
    cp "$APEX_OS_DIR/scripts/data-fetching/fmp/"* apex-os/scripts/data-fetching/fmp/ 2>/dev/null || true
    chmod +x apex-os/scripts/data-fetching/fmp/*.sh 2>/dev/null || true
    FMP_SCRIPTS=$(ls -1 apex-os/scripts/data-fetching/fmp/*.sh 2>/dev/null | wc -l)
    echo "✓ Installed $FMP_SCRIPTS FMP scripts to apex-os/scripts/"
fi

# Copy config to apex-os
if [ -f "$APEX_OS_DIR/config.yml" ]; then
    cp "$APEX_OS_DIR/config.yml" apex-os/
    echo "✓ Copied config.yml to apex-os/"
fi

echo ""
print_success "APEX-OS installation complete!"
echo ""
echo -e "${GREEN}Installation Summary:${NC}"
echo -e "  Agents: ${YELLOW}$AGENTS${NC} (.claude/agents/apex-os/)"
echo -e "  Commands: ${YELLOW}$COMMANDS${NC} (.claude/commands/apex-os/)"
echo -e "  Skills: ${YELLOW}$SKILLS${NC} (.claude/skills/)"
echo -e "  FMP Scripts: ${YELLOW}$FMP_SCRIPTS${NC} (apex-os/scripts/)"
echo ""
echo -e "${GREEN}Structure:${NC}"
echo -e "  .claude/          ${YELLOW}# Claude Code reads from here${NC}"
echo -e "  apex-os/          ${YELLOW}# Your trading workspace${NC}"
echo ""
echo -e "${GREEN}Next steps:${NC}"
echo -e "  1. Set FMP API key: ${YELLOW}export FMP_API_KEY='your-key'${NC}"
echo -e "  2. Use commands: ${YELLOW}/scan-market, /analyze-stock AAPL${NC}"
echo ""
