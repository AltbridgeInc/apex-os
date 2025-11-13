# Task Breakdown: Structural Refactoring and Data Integration Fix

## Overview

**Primary Objective:** Complete structural consistency with agent-os architecture patterns

**Scope Summary:**
- Migrate folder structure: `.claude/` → `profiles/default/`
- Rebuild all 16 skills using proper agent-os structure
- Migrate all 12 commands (6 apex-os + 6 agent-os workflow)
- Reorganize FMP data integration
- Prepare YouTube integration structure (implementation deferred)
- Update installation scripts and configuration

**Total Task Groups:** 7 (Phases 0-6)

---

## Phase 0: Preparation & Backup

**Purpose:** Study reference implementations, understand patterns, and create safety backups before structural changes.

**Dependencies:** None

### Task Group 0.1: Reference Study & Analysis

- [x] 0.1.1 Study agent-os structural patterns
  - Read `reference/agent-os/profiles/default/` structure
  - Understand agents/, commands/, skills/ organization
  - Note command variants (multi-agent vs single-agent)
  - Document key structural differences from current apex-os

- [x] 0.1.2 Study skill-creator patterns
  - Read `reference/skill-creator/SKILL.md` comprehensive guide
  - Understand proper skill folder structure (SKILL.md + bundled resources)
  - Review `scripts/init_skill.py`, `scripts/quick_validate.py`, `scripts/package_skill.py`
  - Document progressive disclosure principle and imperative/infinitive form requirements

- [x] 0.1.3 Study FMP data integration patterns
  - Read `reference/fmp/` structure and scripts
  - Understand two-step pattern: bash fetch JSON → python process to readable format
  - Note file naming conventions for different data types
  - Document how agents consume file paths (not raw data)

- [x] 0.1.4 Study installation script patterns
  - Read `reference/agent-os/scripts/base-install.sh`
  - Read `reference/agent-os/scripts/project-install.sh`
  - Read `reference/agent-os/scripts/common-functions.sh`
  - Document installation flow and directory creation patterns

- [x] 0.1.5 Analyze current apex-os structure
  - List all 8 agents in `.claude/agents/apex-os/` and `.claude/agents/agent-os/`
  - List all 16 skills in `.claude/skills/` with their current structure
  - List all 6 apex-os commands in `.claude/commands/`
  - List all 6 agent-os workflow commands in `.claude/commands/agent-os/`
  - List all 12 FMP scripts in `scripts/fmp/`
  - Document current hardcoded paths in agents and commands

**Acceptance Criteria:**
- Clear understanding of agent-os patterns documented
- Skill-creator requirements understood and documented
- FMP integration pattern documented
- Complete inventory of current apex-os structure created
- Reference patterns vs current structure comparison documented

### Task Group 0.2: Backup & Safety

- [x] 0.2.1 Create comprehensive backup
  - Backup entire `.claude/` directory to `.claude.backup-[timestamp]/`
  - Backup `scripts/` directory to `scripts.backup-[timestamp]/`
  - Backup `config.yml` to `config.yml.backup-[timestamp]`
  - Document backup locations for rollback if needed

- [x] 0.2.2 Create migration tracking document
  - Create `MIGRATION_STATUS.md` in spec folder
  - Document current state baseline
  - Create checklist for tracking migration progress
  - Document rollback procedure

**Acceptance Criteria:**
- Complete backup created and verified
- Migration tracking document created
- Rollback procedure documented
- Safe to proceed with structural changes

---

## Phase 1: Base Structure & Installation Scripts

**Purpose:** Create target folder structure and update installation scripts to support profiles/default/ pattern.

**Dependencies:** Phase 0 complete

### Task Group 1.1: Create Target Directory Structure

- [x] 1.1.1 Create profiles/default base structure
  - Create `profiles/` directory at apex-os root
  - Create `profiles/default/` directory
  - Create `profiles/default/agents/` directory
  - Create `profiles/default/commands/` directory
  - Create `profiles/default/skills/` directory

- [x] 1.1.2 Create data storage directories
  - Create `data/` directory at apex-os root
  - Create `data/fmp/` directory for FMP data files
  - Create `data/youtube/` directory for future YouTube transcripts
  - Add `.gitkeep` files to preserve empty directories
  - Add appropriate `.gitignore` entries for data files (preserve structure, ignore data)

- [x] 1.1.3 Create scripts organization structure
  - Create `scripts/data-fetching/` directory
  - Create `scripts/data-fetching/fmp/` directory
  - Create `scripts/data-fetching/youtube/` directory
  - Create `scripts/utils/` directory for shared utilities

**Acceptance Criteria:**
- All target directories created
- Directory structure matches agent-os pattern
- Data directories created with appropriate git handling
- Scripts organization structure ready

### Task Group 1.2: Update Installation Scripts

- [x] 1.2.1 Update base-install.sh
  - Follow `reference/agent-os/scripts/base-install.sh` pattern
  - Update to install to `profiles/default/` structure
  - Add common-functions.sh bootstrapping pattern
  - Add version management if needed
  - Test base-install.sh execution (dry run)

- [x] 1.2.2 Update project-install.sh
  - Follow `reference/agent-os/scripts/project-install.sh` pattern
  - Update to create `profiles/default/` directories
  - Update to create `data/fmp/` and `data/youtube/` directories
  - Update to reference new paths for agents, commands, skills
  - Preserve apex-os specific installation logic (FMP setup, etc.)
  - Test project-install.sh execution (dry run)

- [x] 1.2.3 Create shared utilities (if needed)
  - Review `reference/agent-os/scripts/common-functions.sh`
  - Create `scripts/utils/common-functions.sh` if shared utilities needed
  - Add logging functions, path validation, directory creation utilities
  - Source common-functions.sh in installation scripts

**Acceptance Criteria:**
- base-install.sh follows agent-os pattern
- project-install.sh creates correct directory structure
- Installation scripts handle profiles/default/ correctly
- Installation scripts tested (dry run successful)
- Shared utilities created if needed

---

## Phase 2: Skills Complete Rebuild

**Purpose:** DELETE incorrect skills and rebuild all 16 skills using proper agent-os structure with skill-creator tools.

**Dependencies:** Phase 1 complete (target directories created)

**CRITICAL NOTE:** This is NOT a migration - this is a complete rebuild. Current skills are incorrectly implemented and must be deleted.

### Task Group 2.1: Skills Preparation

- [x] 2.1.1 Extract content from current skills
  - Review all 16 current `.skill.md` files in `.claude/skills/`
  - Extract skill descriptions, metadata, auto_load settings
  - Document principle file references for each skill
  - Create content mapping document: current skill → new skill folder name

- [x] 2.1.2 Extract content from principles/ directory
  - Review `principles/fundamental/` content
  - Review `principles/technical/` content
  - Review `principles/risk-management/` content
  - Review `principles/behavioral/` content
  - Identify which principle content should be incorporated into skills
  - Document high-level vs detailed content split (SKILL.md vs references/)

- [x] 2.1.3 DELETE current incorrect skills
  - Remove all `.skill.md` files from `.claude/skills/`
  - Document what was deleted for verification
  - VERIFY: `.claude/skills/` directory is empty

**Acceptance Criteria:**
- All skill content extracted and documented
- All principle content reviewed and mapped
- Current incorrect skills DELETED
- Content mapping complete for rebuild

### Task Group 2.2: Rebuild Fundamental Analysis Skills (5 skills)

- [x] 2.2.1 Initialize financial-health-analysis skill
  - Use `reference/skill-creator/scripts/init_skill.py` to create folder structure
  - Location: `profiles/default/skills/financial-health-analysis/`
  - Populate SKILL.md with proper YAML frontmatter (name, description, license)
  - Write imperative/infinitive form instructions in SKILL.md body
  - Add `references/` subdirectory with detailed financial health principles
  - Validate with `quick_validate.py`

- [x] 2.2.2 Initialize valuation-analysis skill
  - Use `init_skill.py` to create `profiles/default/skills/valuation-analysis/`
  - Populate SKILL.md with valuation metrics and approaches
  - Add `references/` with detailed valuation frameworks
  - Validate with `quick_validate.py`

- [x] 2.2.3 Initialize growth-analysis skill
  - Use `init_skill.py` to create `profiles/default/skills/growth-analysis/`
  - Populate SKILL.md with growth evaluation instructions
  - Add `references/` with growth metrics and frameworks
  - Validate with `quick_validate.py`

- [x] 2.2.4 Initialize quality-analysis skill
  - Use `init_skill.py` to create `profiles/default/skills/quality-analysis/`
  - Populate SKILL.md with business quality evaluation instructions
  - Add `references/` with quality metrics and frameworks
  - Validate with `quick_validate.py`

- [x] 2.2.5 Initialize moat-analysis skill
  - Use `init_skill.py` to create `profiles/default/skills/moat-analysis/`
  - Populate SKILL.md with competitive advantage evaluation instructions
  - Add `references/` with moat types and assessment frameworks
  - Validate with `quick_validate.py`

**Acceptance Criteria:**
- All 5 fundamental analysis skills created with proper structure
- Each skill has SKILL.md with correct YAML frontmatter
- Each skill uses imperative/infinitive form (not second person)
- Each skill follows progressive disclosure (high-level in SKILL.md, details in references/)
- All 5 skills pass `quick_validate.py` validation

### Task Group 2.3: Rebuild Technical Analysis Skills (4 skills)

- [x] 2.3.1 Initialize price-action-analysis skill
  - Use `init_skill.py` to create `profiles/default/skills/price-action-analysis/`
  - Populate SKILL.md with price action reading instructions
  - Add `references/` with candlestick patterns, support/resistance principles
  - Validate with `quick_validate.py`

- [x] 2.3.2 Initialize volume-analysis skill
  - Use `init_skill.py` to create `profiles/default/skills/volume-analysis/`
  - Populate SKILL.md with volume interpretation instructions
  - Add `references/` with volume patterns and confirmation signals
  - Validate with `quick_validate.py`

- [x] 2.3.3 Initialize momentum-analysis skill
  - Use `init_skill.py` to create `profiles/default/skills/momentum-analysis/`
  - Populate SKILL.md with momentum evaluation instructions
  - Add `references/` with momentum indicators and interpretation
  - Validate with `quick_validate.py`

- [x] 2.3.4 Initialize trend-analysis skill
  - Use `init_skill.py` to create `profiles/default/skills/trend-analysis/`
  - Populate SKILL.md with trend identification instructions
  - Add `references/` with trend types, phases, and confirmation
  - Validate with `quick_validate.py`

**Acceptance Criteria:**
- All 4 technical analysis skills created with proper structure
- Each skill has proper SKILL.md with correct frontmatter
- Each skill uses imperative/infinitive form
- Each skill follows progressive disclosure principle
- All 4 skills pass validation

### Task Group 2.4: Rebuild Risk Management Skills (4 skills)

- [x] 2.4.1 Initialize position-sizing skill
  - Use `init_skill.py` to create `profiles/default/skills/position-sizing/`
  - Populate SKILL.md with position size calculation instructions
  - Add `references/` with sizing formulas and risk allocation frameworks
  - Validate with `quick_validate.py`

- [x] 2.4.2 Initialize stop-loss-management skill
  - Use `init_skill.py` to create `profiles/default/skills/stop-loss-management/`
  - Populate SKILL.md with stop-loss placement and adjustment instructions
  - Add `references/` with stop-loss strategies and principles
  - Validate with `quick_validate.py`

- [x] 2.4.3 Initialize portfolio-risk-assessment skill
  - Use `init_skill.py` to create `profiles/default/skills/portfolio-risk-assessment/`
  - Populate SKILL.md with portfolio risk evaluation instructions
  - Add `references/` with diversification principles and correlation analysis
  - Validate with `quick_validate.py`

- [x] 2.4.4 Initialize risk-reward-evaluation skill
  - Use `init_skill.py` to create `profiles/default/skills/risk-reward-evaluation/`
  - Populate SKILL.md with risk-reward ratio calculation instructions
  - Add `references/` with trade setup evaluation frameworks
  - Validate with `quick_validate.py`

**Acceptance Criteria:**
- All 4 risk management skills created with proper structure
- Each skill has proper SKILL.md with correct frontmatter
- Each skill uses imperative/infinitive form
- Each skill follows progressive disclosure principle
- All 4 skills pass validation

### Task Group 2.5: Rebuild Behavioral Analysis Skills (3 skills)

- [x] 2.5.1 Initialize market-sentiment-analysis skill
  - Use `init_skill.py` to create `profiles/default/skills/market-sentiment-analysis/`
  - Populate SKILL.md with sentiment evaluation instructions
  - Add `references/` with sentiment indicators and interpretation
  - Validate with `quick_validate.py`

- [x] 2.5.2 Initialize bias-detection skill
  - Use `init_skill.py` to create `profiles/default/skills/bias-detection/`
  - Populate SKILL.md with cognitive bias identification instructions
  - Add `references/` with bias types and mitigation strategies
  - Validate with `quick_validate.py`

- [x] 2.5.3 Initialize discipline-enforcement skill
  - Use `init_skill.py` to create `profiles/default/skills/discipline-enforcement/`
  - Populate SKILL.md with trading discipline instructions
  - Add `references/` with discipline frameworks and rule compliance
  - Validate with `quick_validate.py`

**Acceptance Criteria:**
- All 3 behavioral analysis skills created with proper structure
- Each skill has proper SKILL.md with correct frontmatter
- Each skill uses imperative/infinitive form
- Each skill follows progressive disclosure principle
- All 3 skills pass validation

### Task Group 2.6: Skills Validation & Verification

- [x] 2.6.1 Run validation on all 16 skills
  - Run `quick_validate.py` on all 16 skill folders
  - Verify all YAML frontmatter is correct
  - Verify all descriptions are clear and descriptive
  - Fix any validation errors

- [x] 2.6.2 Verify skill structure compliance
  - Verify each skill folder contains SKILL.md
  - Verify each skill has proper YAML frontmatter (name, description, license)
  - Verify progressive disclosure: high-level in SKILL.md, details in references/
  - Verify imperative/infinitive form (not second person)

- [x] 2.6.3 Document skill rebuild completion
  - Update MIGRATION_STATUS.md with skills rebuild status
  - Document any deviations from standard structure (if any)
  - List all 16 skills with their new paths

**Acceptance Criteria:**
- All 16 skills pass validation
- All skills follow proper structure
- Skills rebuild documented in migration status
- Ready for agent integration

---

## Phase 3: Commands Migration

**Purpose:** Migrate all 12 commands (6 apex-os + 6 agent-os workflow) to profiles/default/commands/ with proper structure.

**Dependencies:** Phase 1 complete (target directories created)

### Task Group 3.1: Analyze Command Structure Requirements

- [x] 3.1.1 Analyze apex-os commands for variant needs
  - Review `scan-market.md` - determine if multi-agent/single-agent variants needed
  - Review `analyze-stock.md` - determine if multi-agent/single-agent variants needed
  - Review `write-thesis.md` - determine if multi-agent/single-agent variants needed
  - Review `plan-position.md` - determine if multi-agent/single-agent variants needed
  - Review `execute-entry.md` - determine if multi-agent/single-agent variants needed
  - Review `monitor-portfolio.md` - determine if multi-agent/single-agent variants needed
  - Document variant structure decision for each command

- [x] 3.1.2 Review agent-os workflow command structure from reference
  - Review `reference/agent-os/profiles/default/commands/` structure
  - Note which commands have multi-agent/single-agent variants
  - Note which commands have single file structure
  - Document pattern to follow for agent-os workflow commands

**Acceptance Criteria:**
- Variant requirements documented for all 6 apex-os commands
- Agent-os workflow command pattern understood
- Command migration plan created

### Task Group 3.2: Migrate Apex-OS Commands (6 commands)

- [x] 3.2.1 Migrate scan-market command
  - Create `profiles/default/commands/apex-os/scan-market/` (or appropriate structure)
  - Copy scan-market.md to new location with proper structure
  - Update agent path references to `profiles/default/agents/[agent-name].md`
  - Update skill path references to `profiles/default/skills/[skill-name]/`
  - Update data script references to `scripts/data-fetching/fmp/`
  - Verify orchestration logic preserved

- [x] 3.2.2 Migrate analyze-stock command
  - Create appropriate structure in `profiles/default/commands/apex-os/analyze-stock/`
  - Copy analyze-stock.md with structure (single or multi-agent variant)
  - Update all path references (agents, skills, scripts)
  - Verify orchestration logic preserved

- [x] 3.2.3 Migrate write-thesis command
  - Create appropriate structure in `profiles/default/commands/apex-os/write-thesis/`
  - Copy write-thesis.md with structure
  - Update all path references
  - Verify orchestration logic preserved

- [x] 3.2.4 Migrate plan-position command
  - Create appropriate structure in `profiles/default/commands/apex-os/plan-position/`
  - Copy plan-position.md with structure
  - Update all path references
  - Verify orchestration logic preserved

- [x] 3.2.5 Migrate execute-entry command
  - Create appropriate structure in `profiles/default/commands/apex-os/execute-entry/`
  - Copy execute-entry.md with structure
  - Update all path references
  - Verify orchestration logic preserved

- [x] 3.2.6 Migrate monitor-portfolio command
  - Create appropriate structure in `profiles/default/commands/apex-os/monitor-portfolio/`
  - Copy monitor-portfolio.md with structure
  - Update all path references
  - Verify orchestration logic preserved

**Acceptance Criteria:**
- All 6 apex-os commands migrated to new structure
- All path references updated to profiles/default/ pattern
- All data script references updated to scripts/data-fetching/fmp/
- Orchestration logic preserved in all commands
- Commands follow agent-os structural pattern

### Task Group 3.3: Migrate Agent-OS Workflow Commands (6 commands)

- [x] 3.3.1 Migrate orchestrate-tasks command
  - Follow `reference/agent-os/profiles/default/commands/orchestrate-tasks/` pattern
  - Create `profiles/default/commands/orchestrate-tasks/orchestrate-tasks.md`
  - Update agent path references
  - Verify command structure matches reference pattern

- [x] 3.3.2 Migrate write-spec command
  - Follow `reference/agent-os/profiles/default/commands/write-spec/` pattern
  - Create `profiles/default/commands/write-spec/multi-agent/write-spec.md`
  - Create `profiles/default/commands/write-spec/single-agent/write-spec.md`
  - Update agent path references in both variants
  - Verify command structure matches reference pattern

- [x] 3.3.3 Migrate shape-spec command
  - Follow `reference/agent-os/profiles/default/commands/shape-spec/` pattern
  - Create multi-agent and single-agent variants
  - Update agent path references
  - Verify command structure matches reference pattern

- [x] 3.3.4 Migrate plan-product command
  - Follow `reference/agent-os/profiles/default/commands/plan-product/` pattern
  - Create multi-agent and single-agent variants
  - Update agent path references
  - Verify command structure matches reference pattern

- [x] 3.3.5 Migrate create-tasks command
  - Follow `reference/agent-os/profiles/default/commands/create-tasks/` pattern
  - Create `profiles/default/commands/create-tasks/create-tasks.md`
  - Update agent path references
  - Verify command structure matches reference pattern

- [x] 3.3.6 Migrate improve-skills command
  - Follow `reference/agent-os/profiles/default/commands/improve-skills/` pattern
  - Create `profiles/default/commands/improve-skills/improve-skills.md`
  - Update agent path references
  - Verify command structure matches reference pattern

**Acceptance Criteria:**
- All 6 agent-os workflow commands migrated
- Commands follow exact reference/agent-os/ pattern
- Multi-agent and single-agent variants created where applicable
- All agent path references updated to profiles/default/agents/
- Command structure matches reference implementation

---

## Phase 4: Agents Migration

**Purpose:** Migrate all 8 apex-os agents + 6 agent-os agents to profiles/default/agents/.

**Dependencies:** Phase 1 complete (target directories created)

### Task Group 4.1: Migrate Apex-OS Agents (8 agents)

- [x] 4.1.1 Migrate market-scanner agent
  - Copy from `.claude/agents/apex-os-market-scanner.md`
  - Save to `profiles/default/agents/apex-os-market-scanner.md`
  - Update skill path references to `profiles/default/skills/[skill-name]/`
  - Update data script references to `scripts/data-fetching/fmp/`
  - Remove hardcoded paths (e.g., `/Users/nazymazimbayev/apex-os-1/scripts/fmp`)
  - Verify agent definition complete

- [x] 4.1.2 Migrate fundamental-analyst agent
  - Copy from `.claude/agents/apex-os-fundamental-analyst.md`
  - Save to `profiles/default/agents/apex-os-fundamental-analyst.md`
  - Update all path references
  - Verify agent definition complete

- [x] 4.1.3 Migrate technical-analyst agent
  - Copy from `.claude/agents/apex-os-technical-analyst.md`
  - Save to `profiles/default/agents/apex-os-technical-analyst.md`
  - Update all path references
  - Verify agent definition complete

- [x] 4.1.4 Migrate thesis-writer agent
  - Copy from `.claude/agents/apex-os-thesis-writer.md`
  - Save to `profiles/default/agents/apex-os-thesis-writer.md`
  - Update all path references
  - Verify agent definition complete

- [x] 4.1.5 Migrate risk-manager agent
  - Copy from `.claude/agents/apex-os-risk-manager.md`
  - Save to `profiles/default/agents/apex-os-risk-manager.md`
  - Update all path references
  - Verify agent definition complete

- [x] 4.1.6 Migrate executor agent
  - Copy from `.claude/agents/apex-os-executor.md`
  - Save to `profiles/default/agents/apex-os-executor.md`
  - Update all path references
  - Verify agent definition complete

- [x] 4.1.7 Migrate portfolio-monitor agent
  - Copy from `.claude/agents/apex-os-portfolio-monitor.md`
  - Save to `profiles/default/agents/apex-os-portfolio-monitor.md`
  - Update all path references
  - Verify agent definition complete

- [x] 4.1.8 Migrate post-mortem-analyst agent
  - Copy from `.claude/agents/apex-os-post-mortem-analyst.md`
  - Save to `profiles/default/agents/apex-os-post-mortem-analyst.md`
  - Update all path references
  - Verify agent definition complete

**Acceptance Criteria:**
- All 8 apex-os agents migrated to profiles/default/agents/
- All skill path references updated
- All data script references updated
- All hardcoded paths removed
- Agent capabilities preserved

### Task Group 4.2: Migrate Agent-OS Agents (6 agents)

- [x] 4.2.1 Migrate spec-writer agent
  - Copy from `.claude/agents/agent-os/spec-writer.md`
  - Save to `profiles/default/agents/spec-writer.md`
  - Update path references
  - Follow agent-os reference pattern

- [x] 4.2.2 Migrate spec-shaper agent
  - Copy from `.claude/agents/agent-os/spec-shaper.md`
  - Save to `profiles/default/agents/spec-shaper.md`
  - Update path references
  - Follow agent-os reference pattern

- [x] 4.2.3 Migrate product-planner agent
  - Copy from `.claude/agents/agent-os/product-planner.md`
  - Save to `profiles/default/agents/product-planner.md`
  - Update path references
  - Follow agent-os reference pattern

- [x] 4.2.4 Migrate tasks-list-creator agent
  - Copy from `.claude/agents/agent-os/tasks-list-creator.md`
  - Save to `profiles/default/agents/tasks-list-creator.md`
  - Update path references
  - Follow agent-os reference pattern

- [x] 4.2.5 Migrate implementer agent
  - Copy from `.claude/agents/agent-os/implementer.md`
  - Save to `profiles/default/agents/implementer.md`
  - Update path references
  - Follow agent-os reference pattern

- [x] 4.2.6 Migrate implementation-verifier agent
  - Copy from `.claude/agents/agent-os/implementation-verifier.md`
  - Save to `profiles/default/agents/implementation-verifier.md`
  - Update path references
  - Follow agent-os reference pattern

**Acceptance Criteria:**
- All 6 agent-os agents migrated to profiles/default/agents/
- All path references updated
- Agents follow agent-os reference pattern
- Agent capabilities preserved

---

## Phase 5: Data Integration Reorganization

**Purpose:** Reorganize FMP data integration scripts and prepare YouTube integration structure (implementation deferred).

**Dependencies:** Phase 1 complete (data directories created)

### Task Group 5.1: FMP Scripts Migration

- [x] 5.1.1 Move FMP scripts to new location
  - Move all 12 scripts from `scripts/fmp/` to `scripts/data-fetching/fmp/`
  - Preserve executable permissions (chmod +x)
  - Verify all 12 scripts moved successfully
  - List moved scripts in MIGRATION_STATUS.md

- [x] 5.1.2 Update FMP scripts to save to data/fmp/
  - Review each FMP script output handling
  - Update bash scripts to save outputs to `data/fmp/` directory
  - Apply file naming conventions from reference/fmp pattern:
    - Earnings: `{symbol}-earnings-{year}-{period}.txt`
    - Statements: `{symbol}-{type}-{year}-{period}.json`
    - News: `{symbol}-news-{date}.md`
  - Verify scripts maintain two-step pattern: bash fetch → python process

- [x] 5.1.3 Update Python processing scripts
  - Ensure Python scripts use stdlib only (no pip dependencies)
  - Update to read from appropriate input location
  - Update to save formatted output to `data/fmp/`
  - Verify output format (txt/md) matches reference pattern

- [x] 5.1.4 Test FMP scripts (dry run)
  - Test one earnings transcript fetch + process
  - Test one financial statement fetch
  - Test one news fetch + format
  - Verify outputs saved to `data/fmp/` with correct naming
  - Verify agents can read file paths (not inline data)

**Acceptance Criteria:**
- All 12 FMP scripts moved to scripts/data-fetching/fmp/
- Executable permissions preserved
- Scripts save outputs to data/fmp/ with correct naming
- Two-step pattern maintained (bash → python)
- Test execution successful

### Task Group 5.2: YouTube Integration Preparation (Structure Only)

- [x] 5.2.1 Create YouTube placeholder scripts
  - Create `scripts/data-fetching/youtube/get_video_transcript.sh` placeholder
  - Add usage documentation in comments: pattern for fetching transcripts
  - Document API requirements (future implementation)
  - Create `scripts/data-fetching/youtube/process_transcript.py` placeholder
  - Add processing pattern documentation in comments
  - Document expected output format: `{symbol}-youtube-{video-id}-transcript.txt`

- [x] 5.2.2 Create YouTube integration README
  - Create `scripts/data-fetching/youtube/README.md`
  - Document that YouTube integration is prepared for future implementation
  - Explain NOT required for current financial/technical analysis workflow
  - Document two-step pattern: fetch raw data → process to readable format
  - Document file naming convention
  - Document that agents will receive file paths (not raw data)

- [x] 5.2.3 Document YouTube deferred scope
  - Update MIGRATION_STATUS.md with YouTube structure status
  - Note that implementation is deferred to future phase
  - Document that this is NOT a blocker for refactoring completion

**Acceptance Criteria:**
- YouTube placeholder scripts created with documented patterns
- README documents future implementation scope
- Clear documentation that implementation is deferred
- Structure ready for future YouTube integration
- NOT a blocker for refactoring completion

---

## Phase 6: Configuration & Path Updates

**Purpose:** Update config.yml and ensure all path references throughout codebase use profiles/default/ pattern.

**Dependencies:** Phases 2, 3, 4 complete (agents, commands, skills migrated)

### Task Group 6.1: Configuration File Updates

- [x] 6.1.1 Update config.yml path references
  - Update `agents:` path from `.claude/agents/apex-os` to `profiles/default/agents`
  - Update `commands:` path from `.claude/commands/apex-os` to `profiles/default/commands`
  - Update `skills:` path from `.claude/skills` to `profiles/default/skills`
  - Preserve apex-os specific configuration (portfolio settings, quality_gates, workflow_directories)
  - Add agent-os compatibility settings if needed

- [x] 6.1.2 Validate config.yml structure
  - Compare with `reference/agent-os/config.yml` structure
  - Ensure compatibility with agent-os framework
  - Verify YAML syntax is correct
  - Document any apex-os specific deviations from agent-os config

**Acceptance Criteria:**
- config.yml updated with profiles/default/ paths
- Apex-os specific configuration preserved
- Agent-os compatibility maintained
- YAML syntax valid

### Task Group 6.2: Comprehensive Path Reference Audit

- [x] 6.2.1 Search and verify agent path references
  - Search all command files for agent references
  - Verify all use `profiles/default/agents/[agent-name].md` pattern
  - Fix any remaining `.claude/agents/` references
  - Document fixed references

- [x] 6.2.2 Search and verify skill path references
  - Search all agent files for skill references
  - Verify all use `profiles/default/skills/[skill-name]/` pattern
  - Fix any remaining `.claude/skills/` references
  - Document fixed references

- [x] 6.2.3 Search and verify data script references
  - Search all agent files for script references
  - Verify all use `scripts/data-fetching/fmp/` pattern
  - Fix any remaining hardcoded paths (e.g., `/Users/*/scripts/fmp`)
  - Document fixed references

- [x] 6.2.4 Search and verify command path references
  - Search config and orchestration files for command references
  - Verify all use `profiles/default/commands/` pattern
  - Fix any remaining `.claude/commands/` references
  - Document fixed references

**Acceptance Criteria:**
- All agent references use profiles/default/agents/ pattern
- All skill references use profiles/default/skills/ pattern
- All script references use scripts/data-fetching/fmp/ pattern
- All command references use profiles/default/commands/ pattern
- No hardcoded paths remain
- All fixes documented

### Task Group 6.3: Remove Legacy .claude/ Directory

- [x] 6.3.1 Verify all content migrated
  - Verify all 8+6=14 agents migrated
  - Verify all 6+6=12 commands migrated
  - Verify all 16 skills rebuilt (old skills deleted)
  - Cross-reference MIGRATION_STATUS.md checklist
  - Ensure no files left in `.claude/` that should be migrated

- [x] 6.3.2 Remove .claude/ directory
  - VERIFY backup exists at `.claude.backup-[timestamp]/`
  - Remove `.claude/` directory completely
  - VERIFY removal successful
  - Document removal in MIGRATION_STATUS.md

**Acceptance Criteria:**
- All content verified as migrated
- Backup verified before removal
- .claude/ directory removed completely
- Removal documented

---

## Phase 7: Validation & Testing

**Purpose:** Comprehensive validation that refactoring is complete, structure is correct, and apex-os functions properly.

**Dependencies:** All previous phases complete

### Task Group 7.1: Structural Validation

- [x] 7.1.1 Validate directory structure
  - Verify `profiles/default/agents/` contains 14 agent files (8 apex-os + 6 agent-os)
  - Verify `profiles/default/commands/` contains 12 commands with correct structure
  - Verify `profiles/default/skills/` contains 16 skill folders
  - Verify `scripts/data-fetching/fmp/` contains 12 FMP scripts
  - Verify `scripts/data-fetching/youtube/` contains placeholder scripts
  - Verify `data/fmp/` and `data/youtube/` directories exist
  - Document structure validation results

- [x] 7.1.2 Validate skills structure compliance
  - Run `quick_validate.py` on all 16 skills
  - Verify all skills have SKILL.md with proper frontmatter
  - Verify all skills follow progressive disclosure principle
  - Verify all skills use imperative/infinitive form
  - Document validation results

- [x] 7.1.3 Validate path references
  - Grep for any remaining `.claude/` references
  - Grep for any hardcoded absolute paths
  - Verify all path references use profiles/default/ pattern
  - Document any remaining issues

**Acceptance Criteria:**
- Directory structure matches agent-os pattern
- All 16 skills pass validation
- No legacy .claude/ references remain
- All path references correct
- Structural validation complete

### Task Group 7.2: Functional Testing

- [x] 7.2.1 Test installation scripts
  - Run base-install.sh in test environment
  - Run project-install.sh in test environment
  - Verify correct directories created
  - Verify correct permissions set
  - Document test results

- [x] 7.2.2 Test FMP data integration
  - Run one FMP script end-to-end (fetch + process)
  - Verify data saved to data/fmp/ with correct naming
  - Verify agent can read file path and access data
  - Document test results

- [x] 7.2.3 Test agent execution (spot check)
  - Test one apex-os agent can execute (e.g., market-scanner)
  - Verify agent can access skills
  - Verify agent can access data scripts
  - Document test results

- [x] 7.2.4 Test command execution (spot check)
  - Test one apex-os command can execute (e.g., scan-market)
  - Verify command can invoke agents
  - Verify orchestration works
  - Document test results

**Acceptance Criteria:**
- Installation scripts work correctly
- FMP data integration functions properly
- Agents can execute and access skills/scripts
- Commands can execute and orchestrate agents
- Functional testing complete

### Task Group 7.3: Documentation & Completion

- [x] 7.3.1 Update MIGRATION_STATUS.md
  - Mark all task groups as complete
  - Document any deviations from plan
  - Document any issues encountered and resolutions
  - Document YouTube deferred status

- [x] 7.3.2 Create migration summary document
  - Document what was changed (comprehensive list)
  - Document new structure vs old structure
  - Document validation results
  - Document testing results
  - Note YouTube integration prepared but implementation deferred

- [x] 7.3.3 Update apex-os README (if exists)
  - Update installation instructions to reference new structure
  - Update developer documentation for new paths
  - Document skill structure changes
  - Document data integration pattern

- [x] 7.3.4 Final verification checklist
  - [ ] All 14 agents migrated to profiles/default/agents/
  - [ ] All 12 commands migrated to profiles/default/commands/
  - [ ] All 16 skills rebuilt in profiles/default/skills/
  - [ ] All FMP scripts moved to scripts/data-fetching/fmp/
  - [ ] YouTube structure prepared (implementation deferred)
  - [ ] config.yml updated with new paths
  - [ ] All path references updated
  - [ ] .claude/ directory removed
  - [ ] Installation scripts updated
  - [ ] Structural validation passed
  - [ ] Functional testing passed
  - [ ] Documentation updated

**Acceptance Criteria:**
- Migration status fully documented
- Summary document created
- README updated if applicable
- Final verification checklist complete
- Refactoring complete and validated

---

## Execution Strategy

### Recommended Implementation Order

1. **Phase 0: Preparation & Backup** (CRITICAL - do this first)
   - Study references
   - Create backups
   - Understand patterns before making changes

2. **Phase 1: Base Structure** (Foundation)
   - Create target directories
   - Update installation scripts
   - Establishes foundation for migration

3. **Phase 2: Skills Rebuild** (Can run parallel with Phase 3-4)
   - Complete rebuild of all 16 skills
   - Most complex and time-consuming phase
   - Can be done independently of agents/commands migration

4. **Phase 3: Commands Migration** (Can run parallel with Phase 2)
   - Migrate all commands
   - Can be done before or after agents

5. **Phase 4: Agents Migration** (Can run parallel with Phase 2-3)
   - Migrate all agents
   - Should update path references as part of migration

6. **Phase 5: Data Integration** (Can run parallel with Phase 2-4)
   - Reorganize FMP scripts
   - Prepare YouTube structure
   - Relatively independent of agents/commands/skills

7. **Phase 6: Configuration & Path Updates** (After Phases 2-5)
   - Update config.yml
   - Audit and fix any remaining path issues
   - Remove .claude/ directory

8. **Phase 7: Validation & Testing** (Final Phase)
   - Validate structure
   - Test functionality
   - Document completion

### Parallel Execution Opportunities

- **Phases 2, 3, 4, 5 can be executed in parallel** after Phase 1 completes
- Skills rebuild (Phase 2) is independent
- Commands and agents migration (Phase 3-4) have some interdependency but can largely be parallel
- Data integration (Phase 5) is independent

### Critical Dependencies

- **Phase 1 MUST complete before Phases 2-5** (need target directories)
- **Phase 6 MUST complete after Phases 2-5** (need all migrations done to update paths)
- **Phase 7 MUST be last** (validates everything)

---

## Success Metrics

**Structural Alignment:**
- All components follow agent-os patterns exactly
- Directory structure matches reference/agent-os/
- Skills follow reference/skill-creator/ standards

**Completeness:**
- 14 agents migrated (8 apex-os + 6 agent-os)
- 12 commands migrated (6 apex-os + 6 agent-os workflow)
- 16 skills properly rebuilt
- 12 FMP scripts reorganized
- YouTube structure prepared

**Quality:**
- All 16 skills pass validation (quick_validate.py)
- All path references use profiles/default/ pattern
- No hardcoded absolute paths remain
- No legacy .claude/ references remain

**Functionality:**
- Installation scripts work correctly
- FMP data integration functions properly
- Agents can execute and access skills/scripts
- Commands can execute and orchestrate agents
- Apex-os functionality preserved

---

## File References

**Spec Documents:**
- `/home/kimandrik/workspace/apex/apex-trader/apex-os/agent-os/specs/2025-11-13-structural-refactoring/spec.md`
- `/home/kimandrik/workspace/apex/apex-trader/apex-os/agent-os/specs/2025-11-13-structural-refactoring/planning/requirements.md`
- `/home/kimandrik/workspace/apex/apex-trader/apex-os/agent-os/specs/2025-11-13-structural-refactoring/planning/final-summary.md`

**Reference Implementations:**
- `/home/kimandrik/workspace/apex/apex-trader/apex-os/reference/agent-os/` - Primary structural pattern
- `/home/kimandrik/workspace/apex/apex-trader/apex-os/reference/skill-creator/` - Skill building standards
- `/home/kimandrik/workspace/apex/apex-trader/apex-os/reference/fmp/` - Data integration pattern

**Current Apex-OS Structure:**
- `.claude/agents/` - Current agents location (to be migrated)
- `.claude/commands/` - Current commands location (to be migrated)
- `.claude/skills/` - Current skills location (to be DELETED and rebuilt)
- `scripts/fmp/` - Current FMP scripts location (to be reorganized)

**Target Structure:**
- `profiles/default/agents/` - Target agents location
- `profiles/default/commands/` - Target commands location
- `profiles/default/skills/` - Target skills location
- `scripts/data-fetching/fmp/` - Target FMP scripts location
- `scripts/data-fetching/youtube/` - YouTube structure (implementation deferred)
- `data/fmp/` - FMP data storage
- `data/youtube/` - YouTube data storage (future)

---

## Notes

**Testing Approach:**
- Follow minimal testing standard from standards/testing/test-writing.md
- Focus on critical paths during development
- Defer comprehensive testing to dedicated phase
- Write 2-8 focused tests maximum per component if testing is needed
- Prioritize functional validation over exhaustive test coverage

**YouTube Integration:**
- Structure prepared but implementation deferred
- NOT a blocker for refactoring completion
- NOT required for current financial/technical analysis workflow
- Clear documentation that it's for future implementation

**Skills Rebuild:**
- This is NOT a migration - it's a complete rebuild
- Current skills are incorrectly implemented and must be deleted
- Use skill-creator tools for proper initialization
- Follow progressive disclosure principle strictly
- Use imperative/infinitive form (not second person)

**Path References:**
- All paths must use profiles/default/ pattern
- No hardcoded absolute paths allowed
- Remove all `.claude/` references
- Use relative paths from apex-os root where appropriate

**Backup & Safety:**
- ALWAYS backup before structural changes
- Document rollback procedures
- Verify backups before deleting legacy structure
- Keep migration tracking document updated
