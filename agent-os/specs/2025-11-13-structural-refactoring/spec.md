# Specification: Structural Refactoring and Data Integration Fix

## Goal
Complete structural consistency with agent-os architecture patterns through comprehensive migration of apex-os folder structure, proper skill rebuilding, data integration reorganization, and installation script updates.

## User Stories
- As a framework maintainer, I want apex-os to follow agent-os architecture patterns so that the framework functions correctly and consistently with established standards
- As a developer, I want all skills properly structured with bundled resources so that Claude can leverage them effectively for investment analysis

## Specific Requirements

**Folder Structure Migration from .claude/ to profiles/default/**
- Remove all `.claude/` paths completely from apex-os project structure
- Migrate 8 agents from `.claude/agents/` to `profiles/default/agents/` preserving all agent definitions and capabilities
- Migrate 6 apex-os commands from `.claude/commands/` to `profiles/default/commands/apex-os/` with proper single-agent or multi-agent variant structure
- Migrate 6 agent-os workflow commands from `.claude/commands/agent-os/` to `profiles/default/commands/[command-name]/` following reference pattern (multi-agent/ and single-agent/ subdirectories where applicable)
- Create `profiles/default/skills/` directory structure for skill folders
- Update `config.yml` to reference new paths: `profiles/default/agents`, `profiles/default/commands`, `profiles/default/skills`
- Ensure all path references throughout the codebase are updated from `.claude/` to `profiles/default/` pattern

**Complete Skills Rebuild Using Proper agent-os Structure**
- DELETE all 16 current skills at `.claude/skills/*.skill.md` (incorrectly implemented with external principle references and missing bundled resources)
- Rebuild each skill using `reference/skill-creator/scripts/init_skill.py` to create proper folder structure
- Each skill folder at `profiles/default/skills/[skill-name]/` must contain SKILL.md with proper YAML frontmatter (name, description, license)
- Populate SKILL.md with imperative/infinitive form instructions (not second person) following progressive disclosure principle
- Extract content from current `principles/` folder and current skill files to populate new SKILL.md files with comprehensive trading knowledge
- Add `references/` subdirectory with detailed principle documentation for skills requiring extensive reference material (keep SKILL.md lean, details in references/)
- Skills to rebuild: 5 fundamental analysis skills (financial-health-analysis, valuation-analysis, growth-analysis, quality-analysis, moat-analysis), 4 technical analysis skills (price-action-analysis, volume-analysis, momentum-analysis, trend-analysis), 4 risk management skills (position-sizing, stop-loss-management, portfolio-risk-assessment, risk-reward-evaluation), 3 behavioral analysis skills (market-sentiment-analysis, bias-detection, discipline-enforcement)
- Validate each skill using `reference/skill-creator/scripts/quick_validate.py` to ensure proper structure and metadata quality

**FMP Data Integration Reorganization**
- Move all 12 FMP scripts from `scripts/fmp/` to `scripts/data-fetching/fmp/` maintaining executable permissions
- Create dedicated `data/fmp/` directory for storing fetched financial data files
- Update all FMP scripts to save outputs to `data/fmp/` using file naming conventions from reference/fmp pattern (earnings: `{symbol}-earnings-{year}-{period}.txt`, statements: `{symbol}-{type}-{year}-{period}.json`, news: `{symbol}-news-{date}.md`)
- Update all agent definitions to reference new script paths `scripts/data-fetching/fmp/` instead of hardcoded paths like `/Users/nazymazimbayev/apex-os-1/scripts/fmp`
- Maintain two-step FMP data pattern: bash scripts fetch JSON from API, Python scripts (stdlib only) process JSON to formatted output
- Ensure agents receive FILE PATHS to data files, not raw data inline

**YouTube Data Integration Preparation (Implementation Deferred)**
- Create `scripts/data-fetching/youtube/` directory structure for future implementation
- Create placeholder scripts with documented patterns: `get_video_transcript.sh` and `process_transcript.py` with usage examples in comments
- Create `data/youtube/` directory for future transcript storage
- Document file naming convention in comments: `{symbol}-youtube-{video-id}-transcript.txt`
- Add README.md in `scripts/data-fetching/youtube/` documenting that YouTube integration is prepared for future implementation and NOT required for current financial analysis workflow
- NO actual YouTube API integration or transcript fetching implementation required in this phase

**Scripts Organization and Utilities**
- Maintain `scripts/base-install.sh` at root scripts/ level, update to follow agent-os installation pattern from reference
- Maintain `scripts/project-install.sh` at root scripts/ level, update to install to `profiles/default/` structure and create necessary data directories
- Create `scripts/utils/` directory for shared utility scripts as needed
- Study `reference/agent-os/scripts/common-functions.sh` pattern for shared installation utilities
- Ensure installation scripts handle profile-based structure correctly and create all necessary directories (`profiles/default/agents/`, `profiles/default/commands/`, `profiles/default/skills/`, `data/fmp/`, `data/youtube/`)

**Commands Migration Strategy**
- Analyze current apex-os commands (scan-market, analyze-stock, write-thesis, plan-position, execute-entry, monitor-portfolio) to determine if multi-agent and single-agent variants are needed
- Follow reference/agent-os command structure pattern with dedicated folders per command containing variant subdirectories
- Update command files to reference new agent paths at `profiles/default/agents/[agent-name].md`
- Ensure orchestration logic and agent handoffs remain functional after path updates
- Agent-os workflow commands (orchestrate-tasks, write-spec, shape-spec, plan-product, create-tasks, improve-skills) must follow exact reference pattern with multi-agent/ and single-agent/ variants where applicable

**Configuration and Path Reference Updates**
- Update `config.yml` agents location from `.claude/agents/apex-os` to `profiles/default/agents`
- Update `config.yml` commands location from `.claude/commands/apex-os` to `profiles/default/commands`
- Update `config.yml` skills location from `.claude/skills` to `profiles/default/skills`
- Add agent-os compatibility settings to config while preserving apex-os specific configuration (portfolio settings, quality_gates, workflow_directories)
- Search and replace all hardcoded path references throughout agent and command markdown files
- Update any relative path references to use consistent `profiles/default/` base pattern

## Visual Design
No visual assets required for this structural refactoring specification.

## Existing Code to Leverage

**reference/agent-os/ - Primary Structural Pattern**
- Use `profiles/default/agents/*.md` structure as exact model for agent file organization and path references
- Use `profiles/default/commands/[command-name]/multi-agent/` and `profiles/default/commands/[command-name]/single-agent/` pattern for command organization
- Study `scripts/base-install.sh` (100+ lines) for installation script architecture including common functions bootstrapping and version management
- Study `scripts/project-install.sh` for profile-based installation logic and directory creation patterns
- Reference `scripts/common-functions.sh` for shared utility functions used across installation scripts
- Use `config.yml` structure as template for path configuration and framework settings

**reference/skill-creator/ - Skill Building Standards**
- Use `scripts/init_skill.py` to initialize each of 16 skills with proper directory structure and SKILL.md template
- Use `scripts/quick_validate.py` to validate each skill's structure, frontmatter, and metadata quality before finalizing
- Use `scripts/package_skill.py` pattern to understand skill packaging requirements (though packaging may not be needed for internal framework skills)
- Follow SKILL.md progressive disclosure principle: metadata always in context, SKILL.md body when triggered, bundled resources loaded as needed
- Follow imperative/infinitive form writing style from SKILL.md guide (not second person "you")

**reference/fmp/ - Data Integration Pattern**
- Replicate two-step data fetching pattern: bash scripts fetch JSON from API, Python scripts process to readable format
- Use file naming conventions: transcripts `{symbol}-transcript-{year}-Q{quarter}.json` → `{symbol}-earnings-{year}-{period}.txt`, statements `{symbol}-{type}-{year}-{period}.json`
- Follow pattern where agents receive FILE PATHS not raw data, enabling agents to read files as needed
- Reference script structure examples: `scripts/get_earnings_transcripts.sh`, `scripts/process_transcripts.py`, `scripts/format_news.py`
- Apply same pattern principles to YouTube integration placeholders (fetch raw data → process to readable format → save with consistent naming)

**Current .claude/skills/ - Content Source for Rebuild**
- Extract existing skill descriptions and auto_load settings from current `.skill.md` files before deletion
- Preserve skill categorization (fundamental: 5, technical: 4, risk_management: 4, behavioral: 3)
- Map current skill names to new folder names (e.g., `fundamental-financial-health.skill.md` → `financial-health-analysis/`)
- Review principle file references to understand what content should be incorporated into new SKILL.md files

**Current principles/ Directory - Knowledge Base**
- Extract detailed trading principles and analytical frameworks from principles/fundamental/, principles/technical/, principles/risk-management/, principles/behavioral/ folders
- Incorporate principle content into new skill SKILL.md files or references/ subdirectories following progressive disclosure (high-level instructions in SKILL.md, detailed frameworks in references/)
- Maintain principles/ directory structure for any content not appropriate for skills (system-level trading philosophy)

## Out of Scope
- Functional changes to agents' analytical logic or decision-making algorithms
- Changes to trading principles content beyond reorganization into skills
- Portfolio management logic modifications or quality gates criteria changes
- New feature development not directly related to structural alignment
- UI or frontend development (this is purely backend/structure refactoring)
- Changes to agent-os core framework files (only apex-os specific adaptations)
- Actual YouTube API integration or transcript fetching implementation (structure prepared only)
- Modifications to FMP API integration logic (only path reorganization)
- Database schema changes or data model modifications
- Performance optimization beyond structural improvements
