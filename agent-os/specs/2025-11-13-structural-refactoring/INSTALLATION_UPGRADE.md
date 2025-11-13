# Installation Script Upgrade

**Date**: 2025-11-13
**Status**: ✅ UPGRADED TO MATCH AGENT-OS

---

## Issue Identified

The original apex-os `base-install.sh` script was too simplistic compared to the reference agent-os implementation:

### Old apex-os Behavior (Simple)
When `~/apex-os` already exists:
- Only option: "Do you want to update it? (y/n)"
- If yes: Run `git pull`
- If no: Cancel

### Agent-OS Behavior (Sophisticated)
When `~/agent-os` already exists:
- **6 options** presented to the user:

1. **Full update** - Updates profiles/default/, scripts/, CHANGELOG.md, and version in config.yml
2. **Update default profile only** - Only updates profiles/default/*
3. **Update scripts only** - Only updates scripts/*
4. **Update config.yml only** - Only updates config.yml
5. **Delete & reinstall fresh** - Creates backup, deletes everything, fresh install
6. **Cancel and abort** - Exits without changes

Each option (except cancel) creates a backup at `~/agent-os.backup` before making changes.

---

## Solution Implemented

### Replaced base-install.sh

1. **Backed up simple version**: `scripts/base-install.sh.backup-simple`
2. **Copied agent-os version**: `reference/agent-os/scripts/base-install.sh` → `scripts/base-install.sh`
3. **Customized for apex-os**:
   - Changed all `Agent OS` → `APEX-OS`
   - Changed all `agent-os` → `apex-os`
   - Changed repo: `buildermethods/agent-os` → `AltbridgeInc/apex-os`
   - Changed docs URL: `buildermethods.com/agent-os` → `github.com/AltbridgeInc/apex-os`
   - Changed `profiles/default/standards` → `profiles/default/principles`

---

## New Features in apex-os base-install.sh

### 1. Sophisticated Update Options
Users can now choose granular update options instead of all-or-nothing.

### 2. Automatic Backups
All update operations (except cancel) create `~/apex-os.backup` automatically.

### 3. Version Detection
- Reads current version from `~/apex-os/config.yml`
- Fetches latest version from GitHub
- Displays both versions to help user decide

### 4. Selective Updates
Users can update just what they need:
- Only profile (agents, commands, skills)
- Only scripts (installation, data-fetching, etc.)
- Only config
- Or everything

### 5. Common Functions Bootstrap
- Downloads `common-functions.sh` first
- Uses shared utility functions for consistent behavior
- Proper error handling and progress indicators

### 6. Spinner Animation
- Shows animated spinner during file downloads
- Hides cursor during installation
- Restores cursor on completion or error

---

## Comparison: Old vs New

### Old Script (90 lines)
```bash
# Simple git clone or git pull
if [ -d "$APEX_OS_DIR" ]; then
    read -p "Do you want to update it? (y/n) "
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cd "$APEX_OS_DIR"
        git pull origin "$BRANCH"
    fi
else
    git clone -b "$BRANCH" "$REPO_URL" "$APEX_OS_DIR"
fi
```

### New Script (701 lines)
- Bootstrap functions for common-functions.sh
- Version detection and comparison
- 6 different update strategies
- Backup creation before changes
- Selective file downloading from GitHub API
- Animated progress indicators
- Verbose mode for debugging
- Exclusion patterns for certain files
- Support for jq/python/sed JSON parsing

---

## Benefits for Users

1. **Safer Updates**: Always creates backups before making changes
2. **Flexibility**: Can update just one component instead of everything
3. **Version Awareness**: Shows current vs latest version
4. **Better UX**: Animated spinner, clear options, colored output
5. **Consistent with agent-os**: Same experience across both frameworks

---

## Next Steps Message

The new installation script shows proper next steps:

```
Next steps:

1) Customize your profile's principles in ~/apex-os/profiles/default/principles

2) Navigate to a project directory
   cd path/to/project-directory

3) Install APEX-OS in your project by running:
   ~/apex-os/scripts/project-install.sh

Visit the docs for guides on how to use APEX-OS: https://github.com/AltbridgeInc/apex-os
```

---

## Testing

To test the new installation script:

```bash
# If ~/apex-os doesn't exist - fresh install
curl -sSL https://raw.githubusercontent.com/AltbridgeInc/apex-os/main/scripts/base-install.sh | bash

# If ~/apex-os exists - shows 6 options
curl -sSL https://raw.githubusercontent.com/AltbridgeInc/apex-os/main/scripts/base-install.sh | bash
```

---

## Files Modified

- `scripts/base-install.sh` - Completely replaced with agent-os pattern
- `scripts/base-install.sh.backup-simple` - Backup of old simple version

---

## Status: ✅ COMPLETE

APEX-OS now has a professional-grade installation script that matches the agent-os standard with all 6 update options, automatic backups, and version detection.
