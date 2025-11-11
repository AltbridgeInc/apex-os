# APEX-OS Installation Guide

## Installation Methods

### Base Installation (One-time Setup)

Install APEX-OS to your home directory:

```bash
curl -sSL https://raw.githubusercontent.com/AltbridgeInc/apex-os/main/scripts/base-install.sh | bash
```

This installs APEX-OS to `~/apex-os` (your central APEX-OS repository).

### Project Installation (Per Project)

Install APEX-OS into your current project:

```bash
cd ~/your-trading-workspace
~/apex-os/scripts/project-install.sh
```

This copies APEX-OS files into your project with the correct structure for Claude Code.

## Directory Structure

### Source Structure (in apex-os repo)

```
~/apex-os/
└── profiles/default/.claude/
    ├── commands/apex-os/          ← SOURCE files (organized)
    │   ├── analyze-stock.md
    │   ├── scan-market.md
    │   └── ...
    └── agents/apex-os/            ← SOURCE files (organized)
        ├── fundamental-analyst.md
        ├── technical-analyst.md
        └── ...
```

### Installed Structure (in your project)

```
your-project/
└── .claude/
    ├── commands/                  ← FLATTENED structure
    │   ├── apex-os-analyze-stock.md
    │   ├── apex-os-scan-market.md
    │   └── ...
    └── agents/                    ← FLATTENED structure
        ├── apex-os-fundamental-analyst.md
        ├── apex-os-technical-analyst.md
        └── ...
```

## Why Flattening?

**Claude Code requires commands to be directly in `.claude/commands/`** — it doesn't support subdirectories.

The installation script:
1. Keeps source files organized in `apex-os/` subdirectories
2. Flattens them during installation with `apex-os-` prefix
3. This allows namespacing without breaking Claude Code compatibility

## Command Usage

After installation, commands are available with the `apex-os-` prefix:

```bash
/apex-os-scan-market              # Find opportunities
/apex-os-analyze-stock AAPL       # Analyze a stock
/apex-os-write-thesis AAPL        # Create investment thesis
/apex-os-plan-position AAPL       # Plan position size and risk
/apex-os-execute-entry AAPL       # Execute entry
/apex-os-monitor-portfolio        # Daily monitoring
```

## Updating APEX-OS

### Update Base Installation

```bash
cd ~/apex-os
git pull
```

### Re-install in Projects

After updating the base installation, re-run the project installer in each project:

```bash
cd ~/your-trading-workspace
~/apex-os/scripts/project-install.sh
```

The installer will skip existing directories and only update .claude components.

## Development Workflow

### For APEX-OS Contributors

1. **Edit source files** in `profiles/default/.claude/`
   - Keep the nested `apex-os/` structure
   - This keeps the repo organized

2. **Test installation** in a test project:
   ```bash
   cd ~/test-project
   ~/apex-os/scripts/project-install.sh
   ```

3. **Verify** commands work with `apex-os-` prefix

4. **Commit changes** to the apex-os repository

### For APEX-OS Users

1. **Pull updates** from the apex-os repo:
   ```bash
   cd ~/apex-os
   git pull
   ```

2. **Re-install** in your project:
   ```bash
   cd ~/your-trading-workspace
   ~/apex-os/scripts/project-install.sh
   ```

## Architecture Notes

This installation system is inspired by [Agent OS](https://github.com/buildermethods/agent-os), which uses a similar two-tier structure:

- **Source tier**: Organized, nested structure for development
- **Installation tier**: Flattened structure for Claude Code compatibility

The `project-install.sh` script handles the transformation automatically.

## Troubleshooting

### Commands not showing in Claude Code

1. Verify files are in `.claude/commands/`:
   ```bash
   ls -la .claude/commands/apex-os-*.md
   ```

2. Restart Claude Code

3. Check for errors in the installation output

### Updates not applying

1. The installer skips existing directories
2. Manually remove `.claude/` and re-run installer
3. Or manually copy updated files from `~/apex-os/`

### Wrong command names

Commands should have the `apex-os-` prefix after installation.

If you see commands without the prefix, you may have an old installation method. Re-run the latest `project-install.sh`.

## Support

For issues or questions:
- GitHub Issues: https://github.com/AltbridgeInc/apex-os/issues
- Documentation: See README.md
