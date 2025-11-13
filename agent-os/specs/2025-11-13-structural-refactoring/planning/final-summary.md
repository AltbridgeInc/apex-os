# Final Requirements Summary: Structural Refactoring and Data Integration Fix

**Date:** 2025-11-13
**Status:** REQUIREMENTS COMPLETE - READY FOR SPECIFICATION CREATION

---

## Executive Summary

This is a comprehensive structural refactoring to align apex-os with agent-os architecture patterns. The primary objective is to achieve complete structural consistency with agent-os standards, addressing critical inconsistencies that prevent the framework from functioning properly.

## Scope Overview

### What's Being Refactored

1. **Folder Structure** - Complete migration from `.claude/` to `profiles/default/` pattern
2. **Skills System** - Full rebuild of 16 skills with proper agent-os structure
3. **Commands** - Migration of all 12 commands (6 apex-os + 6 agent-os workflow)
4. **Data Integration** - FMP scripts reorganization + YouTube structure preparation
5. **Installation Scripts** - Update to follow agent-os patterns
6. **Configuration** - Path updates and agent-os compatibility

### Key Numbers

- 8 agents to migrate
- 12 commands to migrate (6 apex-os + 6 agent-os workflow)
- 16 skills to REBUILD (not migrate - delete and recreate)
- 12 FMP scripts to reorganize
- YouTube: Structure only (implementation deferred to future)

---

## Critical Decisions Made

### 1. YouTube Integration Scope - RESOLVED

**Decision:** Structure prepared, implementation deferred to future phase

**What This Means:**
- Create folder structure: `scripts/data-fetching/youtube/`
- Create placeholder scripts with documented patterns
- Create data directory: `data/youtube/`
- Implementation is NOT required for this refactoring
- NOT a blocker for financial/technical analysis workflow
- Will save transcripts when implemented in future

**Rationale:** YouTube support is for future enhancement, not critical for current investment research workflow which relies on FMP data.

### 2. Skills Rebuild Approach

**Decision:** DELETE current skills entirely and rebuild using agent-os standards

**Why:**
- Current skills at `.claude/skills/*.skill.md` are INCORRECTLY implemented
- Have wrong structure (single .skill.md files with external principle references)
- Missing bundled resources (scripts/, references/, assets/)
- Too minimal (e.g., only 31 lines)

**How:**
- Use `reference/skill-creator/` as the authoritative guide
- Initialize each skill with `init_skill.py`
- Populate with proper SKILL.md structure
- Add bundled resources where appropriate
- Validate with `quick_validate.py`
- Package with `package_skill.py`

### 3. Complete Migration (No Shortcuts)

**Decision:** Migrate ALL commands and components - this is complete refactoring

**Scope:**
- All 6 apex-os commands must be migrated
- All 6 agent-os workflow commands must be migrated
- All path references must be updated
- All installation scripts must be updated

---

## Reference Priorities

### PRIMARY: `reference/agent-os/`

**Path:** `/home/kimandrik/workspace/apex/apex-trader/apex-os/reference/agent-os/`

**Use For:**
- Folder structure patterns (`profiles/default/agents/`, `profiles/default/commands/`, `profiles/default/skills/`)
- Installation script patterns (`scripts/base-install.sh`, `scripts/project-install.sh`, `scripts/common-functions.sh`)
- Configuration structure (`config.yml`)
- Command organization (multi-agent vs single-agent variants)
- Standards organization

### CRITICAL: `reference/skill-creator/`

**Path:** `/home/kimandrik/workspace/apex/apex-trader/apex-os/reference/skill-creator/`

**Use For:**
- Proper skill structure (SKILL.md + bundled resources)
- Skill initialization script (`scripts/init_skill.py`)
- Skill validation script (`scripts/quick_validate.py`)
- Skill packaging script (`scripts/package_skill.py`)
- Progressive disclosure principle
- Imperative/infinitive form guidelines

### IMPORTANT: `reference/fmp/`

**Path:** `/home/kimandrik/workspace/apex/apex-trader/apex-os/reference/fmp/`

**Use For:**
- Data integration pattern (bash fetch → python process)
- File naming conventions for financial data
- How agents consume data (FILE PATHS, not raw data)
- Script structure examples:
  - `scripts/get_earnings_transcripts.sh` - API fetching pattern
  - `scripts/process_transcripts.py` - Data processing pattern
  - `scripts/get_financial_statements.sh` - Financial data fetching
  - `scripts/format_news.py` - News formatting

### OPTIONAL: `reference/servers/`

**Path:** `/home/kimandrik/workspace/apex/apex-trader/apex-os/reference/servers/`

**Use For:** May have useful patterns but not critical for this refactoring

---

## Migration Targets

### Folder Structure: Current → Target

```
CURRENT:
.claude/
  agents/apex-os/*.md (8 agents)
  commands/*.md (6 apex-os commands)
  commands/agent-os/*.md (6 agent-os workflow commands)
  skills/*.skill.md (16 skills - INCORRECT)

TARGET:
profiles/default/
  agents/*.md (8 agents)
  commands/
    apex-os/ (6 commands - determine single/multi-agent variants)
    orchestrate-tasks/orchestrate-tasks.md
    write-spec/
      multi-agent/write-spec.md
      single-agent/write-spec.md
    shape-spec/
      multi-agent/shape-spec.md
      single-agent/shape-spec.md
    plan-product/
      multi-agent/plan-product.md
      single-agent/plan-product.md
    create-tasks/create-tasks.md
    improve-skills/improve-skills.md
  skills/
    [skill-name]/
      SKILL.md
      scripts/ (optional)
      references/ (optional)
      assets/ (optional)
```

### Scripts Organization: Current → Target

```
CURRENT:
scripts/
  base-install.sh
  project-install.sh
  fmp/*.sh (12 scripts)

TARGET:
scripts/
  base-install.sh (updated to agent-os pattern)
  project-install.sh (updated to agent-os pattern)
  data-fetching/
    fmp/*.sh (12 scripts migrated)
    youtube/*.sh (placeholder scripts)
  utils/*.sh (utility scripts as needed)
```

### Data Storage: Current → Target

```
CURRENT:
- No dedicated data storage folder
- Scripts likely saving to various locations
- Hardcoded paths in agents

TARGET:
data/
  fmp/
    [symbol]-earnings-[year]-[period].txt
    [symbol]-[type]-[year]-[period].json
    [symbol]-news-[date].md
  youtube/ (prepared for future)
    [symbol]-youtube-[video-id]-transcript.txt
```

---

## Skills to Rebuild (16 Total)

### Fundamental Analysis (5 skills)
1. Financial Health Analysis
2. Valuation Analysis
3. Growth Analysis
4. Quality Analysis
5. Moat Analysis

### Technical Analysis (4 skills)
1. Price Action Analysis
2. Volume Analysis
3. Momentum Analysis
4. Trend Analysis

### Risk Management (4 skills)
1. Position Sizing
2. Stop Loss Management
3. Portfolio Risk Assessment
4. Risk-Reward Evaluation

### Behavioral Analysis (3 skills)
1. Market Sentiment Analysis
2. Bias Detection
3. Discipline Enforcement

**Rebuild Requirements:**
- Each skill gets its own folder: `profiles/default/skills/[skill-name]/`
- Each skill has `SKILL.md` with proper frontmatter and instructions
- Add bundled resources where appropriate (references/ for detailed principles)
- Follow progressive disclosure (high-level in SKILL.md, details in references/)
- Use imperative/infinitive form (not second person "you")
- Proper metadata (name + description determine when Claude uses the skill)

---

## Commands to Migrate (12 Total)

### Apex-OS Commands (6)
1. `scan-market` (104 lines)
2. `analyze-stock` (160 lines)
3. `write-thesis` (153 lines)
4. `plan-position` (181 lines)
5. `execute-entry` (219 lines)
6. `monitor-portfolio` (229 lines)

**Target:** `profiles/default/commands/apex-os/`
**Decision Needed:** Determine if these need multi-agent and single-agent variants (analyze current implementation)

### Agent-OS Workflow Commands (6)
1. `orchestrate-tasks`
2. `write-spec`
3. `shape-spec`
4. `plan-product`
5. `create-tasks`
6. `improve-skills`

**Target:** `profiles/default/commands/[command-name]/`
**Structure:** Follow reference/agent-os/ pattern with multi-agent/ and single-agent/ variants where applicable

---

## Data Integration Patterns

### FMP (Financial Modeling Prep)

**Pattern:**
1. Bash script fetches JSON from FMP API
2. Python script (stdlib only) processes JSON to formatted output (txt/md)
3. Agents receive FILE PATHS, not raw data
4. Agents read files as needed

**File Naming Conventions:**
- Earnings: `{symbol}-earnings-{year}-{period}.txt`
- Statements: `{symbol}-{type}-{year}-{period}.json`
- News: `{symbol}-news-{date}.md`

**Path Updates Required:**
- Scripts: `scripts/fmp/` → `scripts/data-fetching/fmp/`
- Data: Various locations → `data/fmp/`
- Agent references: Update hardcoded paths (e.g., `/Users/nazymazimbayev/apex-os-1/scripts/fmp`)

### YouTube (Future Support)

**Pattern (Documented for Future):**
1. Fetch raw data (video metadata, captions/transcripts via YouTube API)
2. Process to readable format (txt/md)
3. Save to `data/youtube/`
4. Agents receive FILE PATHS, not raw data

**File Naming Convention:**
- `{symbol}-youtube-{video-id}-transcript.txt`

**Implementation Status:**
- Folder created: `scripts/data-fetching/youtube/`
- Placeholder scripts created with documented patterns
- Data folder created: `data/youtube/`
- README or comments document: "YouTube integration prepared for future implementation"

---

## Configuration Updates

### config.yml Changes

**Current References:**
```yaml
agents: .claude/agents/apex-os
commands: .claude/commands/apex-os
skills: .claude/skills
```

**Target References:**
```yaml
agents: profiles/default/agents
commands: profiles/default/commands
skills: profiles/default/skills
```

**Additional Updates:**
- Add agent-os compatibility settings
- Maintain apex-os specific configuration (portfolio, quality_gates, etc.)
- Update any hardcoded paths to use relative paths or environment variables

---

## Installation Scripts Requirements

### base-install.sh

**Reference:** `reference/agent-os/scripts/base-install.sh`

**Requirements:**
- Follow agent-os pattern exactly
- Install to `profiles/default/` structure
- Handle common dependencies
- Use common-functions.sh pattern for shared utilities

### project-install.sh

**Reference:** `reference/agent-os/scripts/project-install.sh`

**Requirements:**
- Install apex-os specific components
- Support configuration options via config.yml
- Handle apex-os unique requirements (FMP scripts, data folders, etc.)
- Create necessary data directories (`data/fmp/`, `data/youtube/`)

---

## Scope Boundaries

### IN SCOPE

1. Complete folder structure migration from `.claude/` to `profiles/default/`
2. Full rebuild of all 16 skills using proper agent-os skill structure
3. Migration of all 6 apex-os commands
4. Migration of all 6 agent-os workflow commands
5. Reorganization of FMP scripts to `scripts/data-fetching/fmp/`
6. Creation of `data/fmp/` for data storage
7. Update of all path references in agents, commands, config
8. Creation/update of installation scripts (base-install.sh, project-install.sh)
9. Config.yml updates to reflect new structure
10. YouTube folder structure creation and placeholder scripts (implementation deferred)

### OUT OF SCOPE

1. Functional changes to agents' analytical logic
2. Changes to trading principles content (principles/ folder)
3. Portfolio management logic modifications
4. Quality gates criteria changes
5. New feature development
6. UI/frontend development (this is backend/structure only)
7. Changes to agent-os core framework files (only apex-os specific adaptations)
8. YouTube data fetching implementation (structure prepared, implementation deferred to future phase)

### NO BLOCKERS

All requirements confirmed. No dependencies or blockers remaining.

---

## Technical Constraints

### Must Preserve

- All 8 agents' capabilities
- All 6 commands' orchestration logic
- Data integration with FMP API
- Principles/ structure and content
- Apex-os functionality during/after migration

### Must Follow

- Agent-os patterns exactly (PRIMARY objective)
- Bash for data fetching scripts
- Python (stdlib only, no pip) for data processing
- YAML for configuration
- Markdown for documentation and agent/command definitions
- Progressive disclosure principle for skills
- Imperative/infinitive form for skill instructions

### Integration Points to Update

- Commands must correctly reference agents via new paths
- Agents must reference skills via new paths
- Agents must reference data scripts via new paths (`scripts/data-fetching/fmp/` not `scripts/fmp/`)
- Installation scripts must handle profile-based structure
- Config must align with agent-os compatibility

---

## Visual Assets

**Count:** 0
**Location:** `/home/kimandrik/workspace/apex/apex-trader/apex-os/agent-os/specs/2025-11-13-structural-refactoring/planning/visuals/`
**Status:** No visual assets needed for structural refactoring

---

## Next Steps for Spec-Writer

1. **Study Reference Implementations:**
   - `reference/agent-os/` for structural patterns
   - `reference/skill-creator/` for skill building patterns
   - `reference/fmp/` for data integration patterns

2. **Create Detailed Specification:**
   - Migration steps for folder structure
   - Skill rebuilding procedures (16 skills)
   - Command migration procedures (12 commands)
   - Script reorganization steps
   - Configuration update requirements
   - Installation script updates

3. **Document Pattern Following:**
   - How each component aligns with agent-os patterns
   - How skills follow skill-creator standards
   - How data integration follows FMP patterns

4. **Define Validation Criteria:**
   - How to verify successful migration
   - How to test that apex-os still functions correctly
   - How to validate skill structure compliance
   - How to confirm path references are correct

5. **Create Implementation Phases:**
   - Logical grouping of migration tasks
   - Dependencies between phases
   - Testing checkpoints

---

## Files Generated

1. `/home/kimandrik/workspace/apex/apex-trader/apex-os/agent-os/specs/2025-11-13-structural-refactoring/planning/initialization.md` - Initial spec idea
2. `/home/kimandrik/workspace/apex/apex-trader/apex-os/agent-os/specs/2025-11-13-structural-refactoring/planning/requirements.md` - Comprehensive requirements documentation
3. `/home/kimandrik/workspace/apex/apex-trader/apex-os/agent-os/specs/2025-11-13-structural-refactoring/planning/final-summary.md` - This summary document

---

## Status: READY FOR SPECIFICATION CREATION

All requirements gathered, clarified, and documented. No blockers remaining. Spec-writer can now proceed with creating the detailed specification document.
