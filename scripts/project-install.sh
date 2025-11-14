#!/bin/bash
#
# APEX-OS Project Installation Script
# Installs APEX-OS to current directory
#

set -e

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE_DIR="$HOME/apex-os"
PROJECT_DIR="$(pwd)"
PROFILE="default"
DRY_RUN="false"
VERBOSE="false"

# Source common functions for compilation
source "$SCRIPT_DIR/common-functions.sh"

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
if [ ! -d "$BASE_DIR" ]; then
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

# Set effective configuration flags (needed for compilation)
EFFECTIVE_PROFILE="$PROFILE"
EFFECTIVE_CLAUDE_CODE_COMMANDS="true"
EFFECTIVE_USE_CLAUDE_CODE_SUBAGENTS="true"
EFFECTIVE_STANDARDS_AS_CLAUDE_CODE_SKILLS="true"

# Create .claude directory structure (for Claude Code)
print_status "Creating .claude directory structure..."
mkdir -p .claude/agents/apex-os
mkdir -p .claude/commands/apex-os
mkdir -p .claude/skills
echo "✓ Created .claude structure for Claude Code"
echo ""

# Install and compile agents to .claude
print_status "Installing and compiling agents to .claude..."
AGENTS=0
if [ -d "$BASE_DIR/profiles/$PROFILE/agents" ]; then
    # Iterate through agent files and compile each one
    for source_file in "$BASE_DIR/profiles/$PROFILE/agents/"*.md; do
        if [ -f "$source_file" ]; then
            filename=$(basename "$source_file")
            dest_file="$PROJECT_DIR/.claude/agents/apex-os/$filename"

            # Compile agent with workflow injection
            compile_agent "$source_file" "$dest_file" "$BASE_DIR" "$EFFECTIVE_PROFILE" ""
            ((AGENTS++)) || true
        fi
    done
    echo "✓ Compiled and installed $AGENTS agents to .claude/agents/apex-os/"
fi
echo ""

# Install and compile commands to .claude
print_status "Installing and compiling commands to .claude..."
COMMANDS=0
if [ -d "$BASE_DIR/profiles/$PROFILE/commands" ]; then
    # Iterate through command files and compile each one
    for source_file in "$BASE_DIR/profiles/$PROFILE/commands/"*.md; do
        if [ -f "$source_file" ]; then
            filename=$(basename "$source_file")
            dest_file="$PROJECT_DIR/.claude/commands/apex-os/$filename"

            # Compile command with workflow injection
            compile_command "$source_file" "$dest_file" "$BASE_DIR" "$EFFECTIVE_PROFILE" ""
            ((COMMANDS++)) || true
        fi
    done
    echo "✓ Compiled and installed $COMMANDS commands to .claude/commands/apex-os/"
fi
echo ""

# Install skills to .claude (skills don't need compilation)
print_status "Installing skills to .claude..."
if [ -d "$BASE_DIR/profiles/$PROFILE/skills" ]; then
    cp -r "$BASE_DIR/profiles/$PROFILE/skills/"* .claude/skills/ 2>/dev/null || true
    SKILLS=$(ls -1d .claude/skills/*/ 2>/dev/null | wc -l)
    echo "✓ Installed $SKILLS skills to .claude/skills/"
fi
echo ""

# Create apex-os meta folder (for trading-specific content)
print_status "Creating apex-os meta folder..."
mkdir -p apex-os
echo "✓ Created apex-os/ folder"
echo ""

# Copy standards to apex-os folder
if [ -d "$BASE_DIR/profiles/$PROFILE/standards" ]; then
    cp -r "$BASE_DIR/profiles/$PROFILE/standards" apex-os/
    echo "✓ Installed apex-os/standards/"
fi

# Copy FMP scripts to apex-os (needed by agents/workflows)
if [ -d "$BASE_DIR/scripts/data-fetching/fmp" ]; then
    mkdir -p apex-os/scripts/data-fetching/fmp
    cp "$BASE_DIR/scripts/data-fetching/fmp/"* apex-os/scripts/data-fetching/fmp/ 2>/dev/null || true
    chmod +x apex-os/scripts/data-fetching/fmp/*.sh 2>/dev/null || true
    echo "✓ Installed FMP scripts to apex-os/scripts/"
fi

# Copy config to apex-os
if [ -f "$BASE_DIR/config.yml" ]; then
    cp "$BASE_DIR/config.yml" apex-os/
    echo "✓ Copied config.yml to apex-os/"
fi

echo ""
print_success "APEX-OS installation complete!"
echo ""
echo -e "${GREEN}Installation Summary:${NC}"
echo -e "  Agents: ${YELLOW}$AGENTS${NC} (compiled with workflows) (.claude/agents/apex-os/)"
echo -e "  Commands: ${YELLOW}$COMMANDS${NC} (compiled with workflows) (.claude/commands/apex-os/)"
echo -e "  Skills: ${YELLOW}$SKILLS${NC} (.claude/skills/)"
echo -e "  Standards: ${YELLOW}apex-os/standards/${NC}"
echo ""
echo -e "${GREEN}Structure:${NC}"
echo -e "  .claude/          ${YELLOW}# Claude Code reads from here${NC}"
echo -e "  apex-os/          ${YELLOW}# Your trading workspace${NC}"
echo ""
echo -e "${GREEN}Next steps:${NC}"
echo -e "  1. Set FMP API key: ${YELLOW}export FMP_API_KEY='your-key'${NC}"
echo -e "  2. Use commands: ${YELLOW}/scan-market, /analyze-stock AAPL${NC}"
echo ""
