#!/bin/bash
#
# APEX-OS Project Installation Script
# Installs APEX-OS to current directory
#
# Usage:
#   cd ~/my-trading-workspace
#   ~/apex-os/scripts/project-install.sh
#

set -e

APEX_OS_DIR="$HOME/apex-os"
PROFILE="default"

echo "🚀 APEX-OS Project Installation"
echo "================================"
echo ""

# Check if ~/apex-os exists
if [ ! -d "$APEX_OS_DIR" ]; then
    echo "❌ Error: APEX-OS is not installed."
    echo ""
    echo "Please run the base installation first:"
    echo "  curl -sSL https://raw.githubusercontent.com/AltbridgeInc/apex-os/main/scripts/base-install.sh | bash"
    echo ""
    exit 1
fi

# Check if profile exists
if [ ! -d "$APEX_OS_DIR/profiles/$PROFILE" ]; then
    echo "❌ Error: Profile '$PROFILE' not found."
    exit 1
fi

# Get current directory
CURRENT_DIR=$(pwd)
echo "📍 Installing APEX-OS to: $CURRENT_DIR"
echo ""

# Warning if directory is not empty
if [ "$(ls -A $CURRENT_DIR)" ]; then
    echo "⚠️  Warning: Current directory is not empty."
    read -p "Continue installation? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "ℹ️  Installation cancelled."
        exit 0
    fi
fi

echo "📦 Copying APEX-OS files..."
echo ""

# Create .claude directory structure
echo "📦 Installing .claude components..."
mkdir -p .claude/commands
mkdir -p .claude/agents
mkdir -p .claude/skills

# Install COMMANDS with flattening (apex-os/*.md → apex-os-*.md)
echo "  Installing commands..."
COMMANDS_INSTALLED=0
if [ -d "$APEX_OS_DIR/profiles/$PROFILE/.claude/commands/apex-os" ]; then
    for file in "$APEX_OS_DIR/profiles/$PROFILE/.claude/commands/apex-os"/*.md; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            cp "$file" ".claude/commands/apex-os-$filename"
            COMMANDS_INSTALLED=$((COMMANDS_INSTALLED + 1))
        fi
    done
    echo "  ✅ Installed $COMMANDS_INSTALLED commands (as /apex-os-*)"
else
    echo "  ⚠️  No commands found"
fi

# Install AGENTS with flattening (apex-os/*.md → apex-os-*.md)
echo "  Installing agents..."
AGENTS_INSTALLED=0
if [ -d "$APEX_OS_DIR/profiles/$PROFILE/.claude/agents/apex-os" ]; then
    for file in "$APEX_OS_DIR/profiles/$PROFILE/.claude/agents/apex-os"/*.md; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            cp "$file" ".claude/agents/apex-os-$filename"
            AGENTS_INSTALLED=$((AGENTS_INSTALLED + 1))
        fi
    done
    echo "  ✅ Installed $AGENTS_INSTALLED agents"
else
    echo "  ⚠️  No agents found"
fi

# Install SKILLS (these don't need flattening)
echo "  Installing skills..."
if [ -d "$APEX_OS_DIR/profiles/$PROFILE/.claude/skills" ]; then
    cp -r "$APEX_OS_DIR/profiles/$PROFILE/.claude/skills/"* .claude/skills/ 2>/dev/null || true
    SKILLS_COUNT=$(find .claude/skills -name "*.skill.md" -type f | wc -l | tr -d ' ')
    echo "  ✅ Installed $SKILLS_COUNT skills"
else
    echo "  ⚠️  No skills found"
fi

echo "✅ Installed .claude/ (agents, commands, skills)"

# Copy principles directory
if [ -d "principles" ]; then
    echo "⚠️  principles directory already exists, skipping..."
else
    cp -r "$APEX_OS_DIR/profiles/$PROFILE/principles" .
    echo "✅ Installed principles/"
fi

# Copy portfolio directory (template)
if [ -d "portfolio" ]; then
    echo "⚠️  portfolio directory already exists, skipping..."
else
    cp -r "$APEX_OS_DIR/profiles/$PROFILE/portfolio" .
    echo "✅ Installed portfolio/ (configure this for your needs)"
fi

# Create workflow directories
echo ""
echo "📁 Creating workflow directories..."
mkdir -p opportunities
mkdir -p analysis
mkdir -p positions
mkdir -p reports
echo "✅ Created opportunities/, analysis/, positions/, reports/"

# Copy documentation
if [ -f "$APEX_OS_DIR/README.md" ]; then
    cp "$APEX_OS_DIR/README.md" .
    echo "✅ Copied README.md"
fi

if [ -f "$APEX_OS_DIR/apex-os_description.md" ]; then
    cp "$APEX_OS_DIR/apex-os_description.md" .
    echo "✅ Copied apex-os_description.md"
fi

echo ""
echo "✨ APEX-OS installation complete!"
echo ""
echo "📋 Next steps:"
echo ""
echo "1. Configure your portfolio:"
echo "   Edit portfolio/portfolio-config.yaml"
echo "   - Set your portfolio value"
echo "   - Choose risk per trade (1-2%)"
echo "   - Adjust position limits"
echo ""
echo "2. Open in Claude Code:"
echo "   code ."
echo ""
echo "3. Start using APEX-OS:"
echo "   /apex-os-scan-market           # Find opportunities"
echo "   /apex-os-analyze-stock AAPL    # Analyze a stock"
echo "   /apex-os-write-thesis AAPL     # Create investment thesis"
echo "   /apex-os-plan-position AAPL    # Plan position size and risk"
echo "   /apex-os-execute-entry AAPL    # Execute entry"
echo "   /apex-os-monitor-portfolio     # Daily monitoring"
echo ""
echo "📚 Read README.md for complete documentation"
echo ""
