#!/bin/bash
#
# APEX-OS Base Installation Script
# Installs APEX-OS to ~/apex-os
#
# Usage:
#   curl -sSL https://raw.githubusercontent.com/yourusername/apex-os/main/scripts/base-install.sh | bash
#

set -e

APEX_OS_DIR="$HOME/apex-os"
REPO_URL="https://github.com/yourusername/apex-os.git"
BRANCH="main"

echo "🚀 APEX-OS Base Installation"
echo "=============================="
echo ""

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "❌ Error: git is not installed. Please install git first."
    exit 1
fi

# Check if ~/apex-os already exists
if [ -d "$APEX_OS_DIR" ]; then
    echo "⚠️  Warning: ~/apex-os already exists."
    read -p "Do you want to update it? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "📥 Updating APEX-OS..."
        cd "$APEX_OS_DIR"
        git pull origin "$BRANCH"
        echo "✅ APEX-OS updated successfully!"
    else
        echo "ℹ️  Installation cancelled."
        exit 0
    fi
else
    echo "📥 Cloning APEX-OS repository..."
    git clone -b "$BRANCH" "$REPO_URL" "$APEX_OS_DIR"
    echo "✅ APEX-OS cloned successfully!"
fi

echo ""
echo "✨ APEX-OS base installation complete!"
echo ""
echo "Next steps:"
echo "1. Create a trading workspace directory:"
echo "   mkdir ~/my-trading && cd ~/my-trading"
echo ""
echo "2. Install APEX-OS to your workspace:"
echo "   ~/apex-os/scripts/project-install.sh"
echo ""
echo "3. Open in Claude Code:"
echo "   code ~/my-trading"
echo ""
echo "4. Start using APEX-OS commands:"
echo "   /scan-market"
echo "   /analyze-stock AAPL"
echo ""
echo "📚 Documentation: https://github.com/yourusername/apex-os"
echo ""
