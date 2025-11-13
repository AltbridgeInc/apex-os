# Spec Requirements: Structural Refactoring and Data Integration Fix

## Initial Description

Comprehensive refactoring to align apex-os with agent-os architecture pattern. This addresses critical structural inconsistencies and incorrect skill implementations that prevent the framework from functioning properly according to agent-os standards.

## Requirements Discussion

### User's Confirmed Decisions

**Q1: Folder Structure Target**
**Answer:** Remove `.claude/` from path completely. Use agent-os pattern with `profiles/default/agents/`, `profiles/default/commands/`, `profiles/default/skills/`. Implementation should be done via script exactly as in agent-os.

**Q2: Skills Rebuild Approach**
**Answer:** Delete current `.claude/skills/` entirely - they are incorrect. Rebuild using agent-os way. CRITICAL: Use `reference/skill-creator/` as the reference for how to build skills correctly (FILES: LICENSE.txt, SKILL.md, scripts/).

**Q3: Commands Migration Priority**
**Answer:** Migrate ALL 6 commands. This is complete refactoring, not a shortcut. All commands must be migrated.

**Q4: FMP Data Integration Pattern**
**Answer:** Use dedicated `data/fmp/` folder (or similar) for saved files.

**Q5: YouTube Data Integration Scope**
**Answer:** Save transcripts (when implemented). Future support - NOT needed for financial or technical analysis in current scope. Create folder structure and basic script placeholders in `scripts/data-fetching/youtube/`, but implementation is deferred to future phase. Document the pattern so it's ready when needed, but not a blocker for this refactoring.

**Q6: Scripts Organization**
**Answer:** Yes, use recommended structure:
- `scripts/base-install.sh`
- `scripts/data-fetching/fmp/*.sh`
- `scripts/data-fetching/youtube/*.sh`
- `scripts/utils/*.sh`

**Q7: Migration Strategy**
**Answer:** Must be consistent with agent-os pattern for folder/file structure. This is a PRIMARY objective.

**Q8: Reference Priorities**
**Answer:**
- `reference/agent-os/` - VERY USEFUL, PRIMARY reference
- `reference/skill-creator/` - How to build skills correctly
- `reference/fmp/` - Data integration pattern
- `reference/servers/` - Not critical but could be useful

**Q9: Scope Exclusions**
**Answer:** No specific exclusions mentioned.

### Existing Code to Reference

**Similar Features Identified:**

From `reference/agent-os/` (PRIMARY STRUCTURAL REFERENCE):
- Path: `/home/kimandrik/workspace/apex/apex-trader/apex-os/reference/agent-os/`
- Key structure to model:
  - `profiles/default/agents/*.md` - Agent definitions
  - `profiles/default/commands/*/` - Command structures (multi-agent and single-agent variants)
  - `profiles/default/standards/` - Standards organization
  - `scripts/base-install.sh` - Installation script pattern
  - `scripts/project-install.sh` - Project installation logic
  - `config.yml` - Configuration structure

From `reference/skill-creator/` (SKILL BUILDING REFERENCE):
- Path: `/home/kimandrik/workspace/apex/apex-trader/apex-os/reference/skill-creator/`
- Files to reference:
  - `SKILL.md` - Comprehensive guide to creating effective skills
  - `scripts/init_skill.py` - Skill initialization script
  - `scripts/package_skill.py` - Skill packaging/validation script
  - `LICENSE.txt` - License template

From `reference/fmp/` (DATA INTEGRATION PATTERN):
- Path: `/home/kimandrik/workspace/apex/apex-trader/apex-os/reference/fmp/`
- Pattern: Bash scripts fetch JSON, Python scripts format output
- Files to reference:
  - `SKILL.md` - FMP skill structure showing data integration approach
  - `scripts/get_earnings_transcripts.sh` - API fetching pattern
  - `scripts/process_transcripts.py` - Data processing pattern
  - `scripts/get_financial_statements.sh` - Financial data fetching
  - `scripts/format_news.py` - News formatting

### Follow-up Questions

**Follow-up 1: YouTube Data Integration Scope - RESOLVED**

**Final Decision:** YouTube integration is structured for future support:
- Create folder structure: `scripts/data-fetching/youtube/`
- Create placeholder scripts documenting the pattern
- Create data directory: `data/youtube/`
- Implementation is DEFERRED to future phase
- NOT a blocker for this refactoring
- NOT required for financial or technical analysis workflow
- Will save transcripts when implemented in future

**Documented Pattern (for future implementation):**
- Fetch transcripts from company earnings videos on YouTube
- Two-step pattern: fetch raw data (JSON/metadata) then process to readable format
- File naming: `{symbol}-youtube-{video-id}-transcript.txt`
- Similar to FMP pattern: agents receive FILE PATHS, not raw data

## Visual Assets

### Files Provided:
No visual files found in `/home/kimandrik/workspace/apex/apex-trader/apex-os/agent-os/specs/2025-11-13-structural-refactoring/planning/visuals/`

### Visual Insights:
No visual assets provided for this refactoring spec. This is appropriate as structural refactoring doesn't require visual mockups.

## Requirements Summary

### Functional Requirements

#### 1. Folder Structure Migration

**Current State:**
- Agents: `.claude/agents/apex-os/*.md` (8 agents)
- Commands: `.claude/commands/*.md` (6 commands)
- Skills: `.claude/skills/*.skill.md` (16 skills - INCORRECTLY IMPLEMENTED)
- Config: `config.yml` references `.claude/` paths

**Target State (agent-os pattern):**
- Agents: `profiles/default/agents/*.md`
- Commands: `profiles/default/commands/*/` (with multi-agent and single-agent variants)
- Skills: `profiles/default/skills/*/` (proper skill structure with SKILL.md + bundled resources)
- Standards: `agent-os/standards/` (if not already correctly placed)
- Config: Update all path references

**Migration Scope:**
- 8 agents to migrate
- 6 commands to migrate (ALL must be migrated):
  1. scan-market
  2. analyze-stock
  3. write-thesis
  4. plan-position
  5. execute-entry
  6. monitor-portfolio
- 16 skills to REBUILD (not migrate - delete and recreate):
  - Fundamental: 5 skills
  - Technical: 4 skills
  - Risk Management: 4 skills
  - Behavioral: 3 skills

#### 2. Skills Rebuild (CRITICAL)

**Current State:**
- Skills at `.claude/skills/*.skill.md` are INCORRECTLY implemented
- Example incorrect structure (from fundamental-financial-health.skill.md):
  - Has frontmatter with `principle:` field pointing to external files
  - Has `auto_load: true` field
  - Only 31 lines - too minimal
  - No bundled resources (scripts/, references/, assets/)

**Target State (per reference/skill-creator/SKILL.md):**
- Proper skill structure:
  ```
  skill-name/
    SKILL.md (required)
       YAML frontmatter (name, description, license)
       Markdown instructions
    Bundled Resources (optional)
        scripts/          - Executable code
        references/       - Documentation
        assets/           - Templates/files
  ```
- Each skill must follow progressive disclosure principle
- Use imperative/infinitive form (not second person)
- Proper metadata quality (name + description determine when Claude uses it)

**Rebuild Approach:**
1. DELETE all files in `.claude/skills/`
2. For each of 16 skills, use `reference/skill-creator/scripts/init_skill.py` to initialize
3. Populate SKILL.md with proper content from principles/ and current knowledge
4. Add bundled resources where appropriate (references/ for detailed info)
5. Validate using `reference/skill-creator/scripts/quick_validate.py`
6. Package using `reference/skill-creator/scripts/package_skill.py`

#### 3. Commands Migration

**Current Commands (from .claude/commands/):**
1. apex-os-analyze-stock.md (160 lines)
2. apex-os-execute-entry.md (219 lines)
3. apex-os-monitor-portfolio.md (229 lines)
4. apex-os-plan-position.md (181 lines)
5. apex-os-scan-market.md (104 lines)
6. apex-os-write-thesis.md (153 lines)

**Current Agent-OS Commands (from .claude/commands/agent-os/):**
- Already has 6 agent-os workflow commands
- These should move to new structure as well

**Target Commands Structure (from reference/agent-os/):**
```
profiles/default/commands/
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
```

**Migration Requirements:**
- Migrate all 6 apex-os commands to `profiles/default/commands/apex-os/`
- Migrate all 6 agent-os workflow commands
- Decide on single-agent vs multi-agent variants (analyze current commands to determine)
- Update command references in agents
- Update config.yml to reflect new paths

#### 4. Data Integration Pattern

**FMP (Financial Modeling Prep) Data:**

**Current State:**
- Scripts at `scripts/fmp/*.sh` (12 bash scripts)
- Scripts appear functional but path references may be wrong
- Agents reference scripts with hardcoded paths like: `/Users/nazymazimbayev/apex-os-1/scripts/fmp`

**Target State:**
- Scripts at `scripts/data-fetching/fmp/*.sh`
- Data saved to `data/fmp/` (dedicated folder for FMP outputs)
- File naming pattern from reference/fmp:
  - Transcripts: `{symbol}-transcript-{year}-Q{quarter}.json` → `{symbol}-earnings-{year}-{period}.txt`
  - Statements: `{symbol}-{type}-{year}-{period}.json`
  - News: `{symbol}-news-{date}.json` → `{symbol}-news-{date}.md`

**Pattern (from reference/fmp/SKILL.md):**
1. Bash script fetches JSON from API
2. Python script processes JSON to formatted output (txt/md)
3. Agents receive FILE PATHS, not raw data
4. Agents read files as needed

**Migration Requirements:**
- Move scripts to `scripts/data-fetching/fmp/`
- Update path references in scripts
- Update agent definitions to use new paths
- Create `data/fmp/` directory structure
- Ensure scripts save to correct data/ locations

**YouTube Data Integration (FUTURE SUPPORT):**

**Scope: Structure Prepared, Implementation Deferred**
- Create `scripts/data-fetching/youtube/` folder structure
- Create placeholder scripts documenting the pattern:
  - `get_video_transcript.sh` (placeholder with usage pattern documented)
  - `process_transcript.py` (placeholder with expected format documented)
- Create `data/youtube/` directory structure
- Document in README or comments: "YouTube integration prepared for future implementation"
- Pattern to follow (when implemented):
  1. Fetch raw data (video metadata, captions/transcripts)
  2. Process to readable format (txt/md)
  3. Save as: `{symbol}-youtube-{video-id}-transcript.txt`
- NOT a blocker for this refactoring
- NOT required for current financial/technical analysis workflow

#### 5. Scripts Organization

**Current State:**
```
scripts/
  base-install.sh
  project-install.sh
  fmp/*.sh (12 scripts)
```

**Target State:**
```
scripts/
  base-install.sh
  project-install.sh
  data-fetching/
     fmp/*.sh (migrated from scripts/fmp/)
     youtube/*.sh (placeholder scripts for future)
  utils/*.sh (utility scripts as needed)
```

**Migration Requirements:**
- Reorganize fmp scripts into data-fetching/fmp/
- Create youtube placeholder scripts in data-fetching/youtube/
- Create utils/ for shared utility scripts
- Update all path references

#### 6. Installation Scripts

**Target:**
- Create `scripts/base-install.sh` following agent-os pattern
- Update `scripts/project-install.sh` to:
  - Install to `profiles/default/` structure
  - Handle apex-os specific components
  - Support configuration options via `config.yml`
  - Use common-functions.sh pattern from agent-os

**Reference Implementation:**
- Study `reference/agent-os/scripts/base-install.sh` (100+ lines)
- Study `reference/agent-os/scripts/project-install.sh` (100+ lines)
- Study `reference/agent-os/scripts/common-functions.sh` for shared utilities

#### 7. Configuration Updates

**Current config.yml:**
- References `.claude/agents/apex-os`
- References `.claude/commands/apex-os`
- References `.claude/skills`

**Target config.yml:**
- Update all paths to `profiles/default/` structure
- Add agent-os compatibility settings
- Maintain apex-os specific configuration (portfolio, quality_gates, etc.)

### Reusability Opportunities

**From reference/agent-os/:**
- Installation script patterns (base-install.sh, project-install.sh, common-functions.sh)
- Command structure patterns (multi-agent/single-agent organization)
- Configuration structure (config.yml format)
- Standards organization pattern

**From reference/skill-creator/:**
- Skill initialization script (init_skill.py)
- Skill validation script (quick_validate.py)
- Skill packaging script (package_skill.py)
- SKILL.md template structure

**From reference/fmp/:**
- Two-step data fetching pattern (bash fetch → python process)
- File naming conventions
- SKILL.md structure for data integration skills

### Scope Boundaries

**In Scope:**

1. Complete folder structure migration from `.claude/` to `profiles/default/`
2. Full rebuild of all 16 skills using proper skill structure
3. Migration of all 6 apex-os commands
4. Migration of all 6 agent-os workflow commands
5. Reorganization of FMP scripts to `scripts/data-fetching/fmp/`
6. Creation of `data/fmp/` for data storage
7. Update of all path references in agents, commands, config
8. Creation/update of installation scripts (base-install.sh, project-install.sh)
9. Config.yml updates to reflect new structure
10. YouTube folder structure creation and placeholder scripts (implementation deferred)

**Out of Scope:**

1. Functional changes to agents' analytical logic
2. Changes to trading principles content
3. Portfolio management logic modifications
4. Quality gates criteria changes
5. New feature development
6. UI/frontend development (this is backend/structure only)
7. Changes to agent-os core framework files (only apex-os specific adaptations)
8. YouTube data fetching implementation (structure prepared, implementation deferred to future phase)

**Dependencies/Blockers:**

NONE - All requirements are now clarified and confirmed.

### Technical Considerations

**Integration Points:**
- Commands must correctly reference agents via new paths
- Agents must reference skills via new paths
- Agents must reference data scripts via new paths (`scripts/data-fetching/fmp/` not `scripts/fmp/`)
- Installation scripts must handle profile-based structure
- Config must align with agent-os compatibility

**Existing System Constraints:**
- Must maintain apex-os functionality during/after migration
- Must preserve all 8 agents' capabilities
- Must preserve all 6 commands' orchestration logic
- Must maintain data integration with FMP API
- Must preserve principles/ structure and content

**Technology Preferences:**
- Follow agent-os patterns exactly (PRIMARY objective)
- Bash for data fetching scripts
- Python (stdlib only, no pip) for data processing
- YAML for configuration
- Markdown for documentation and agent/command definitions

**Similar Code Patterns to Follow:**
- agent-os installation script patterns
- skill-creator skill structure patterns
- FMP data integration patterns (two-step: fetch → process)
- Progressive disclosure principle for skills
- Imperative/infinitive form for skill instructions

## Requirements Finalization

**Status:** COMPLETE - All requirements confirmed and documented

**Key Decisions Made:**
1. Complete `.claude/` to `profiles/default/` migration
2. Full rebuild of 16 skills using proper structure
3. Migration of all 12 commands (6 apex-os + 6 agent-os workflow)
4. FMP data integration with dedicated `data/fmp/` folder
5. YouTube integration: Structure prepared, implementation deferred to future phase
6. Scripts reorganized to `scripts/data-fetching/{fmp,youtube}/`
7. Installation scripts following agent-os patterns

**No Blockers Remaining:** Ready for specification creation.
