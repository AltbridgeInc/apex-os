# Spec Initialization: Structural Refactoring and Data Integration Fix

## Initial Idea

Comprehensive refactoring to align apex-os with agent-os architecture pattern:

1. **Remove `.claude/` path completely** - Migrate to agent-os pattern using `profiles/default/agents/`, `profiles/default/commands/`, `profiles/default/skills/`

2. **Rebuild skills correctly** - Delete current `.claude/skills/` (incorrect implementation) and rebuild using agent-os way, following `reference/skill-creator/` as the reference for proper skill structure

3. **Migrate all 6 commands** - Complete migration of all commands, no shortcuts

4. **Implement FMP data integration** - Use dedicated `data/fmp/` folder for saved financial data files

5. **YouTube data integration** - Scope to be clarified for investment research use case

6. **Reorganize scripts** structure:
   - `scripts/base-install.sh`
   - `scripts/data-fetching/fmp/*.sh`
   - `scripts/data-fetching/youtube/*.sh`
   - `scripts/utils/*.sh`

7. **Migration consistency** - Must be consistent with agent-os pattern for folder/file structure

8. **Reference priorities**:
   - `reference/agent-os/` - PRIMARY reference for structure
   - `reference/skill-creator/` - How to build skills correctly
   - `reference/fmp/` - Data integration pattern
   - `reference/servers/` - Could be useful

## Primary Objective

Complete structural consistency with agent-os - this is the core mission.

## Date Created

2025-11-13
