# Reference Paths for Spec Development

This document provides quick access to all reference implementations and current state files needed for the specification.

## Reference Implementations (Study These)

### PRIMARY: agent-os Architecture
**Path:** `/home/kimandrik/workspace/apex/apex-trader/apex-os/reference/agent-os/`

**Key Files:**
- `profiles/default/agents/*.md` - Agent definition patterns
- `profiles/default/commands/*/multi-agent/*.md` - Multi-agent command patterns
- `profiles/default/commands/*/single-agent/*.md` - Single-agent command patterns
- `scripts/base-install.sh` - Base installation script pattern
- `scripts/project-install.sh` - Project installation script pattern
- `scripts/common-functions.sh` - Shared utility functions
- `config.yml` - Configuration structure

### CRITICAL: skill-creator Standards
**Path:** `/home/kimandrik/workspace/apex/apex-trader/apex-os/reference/skill-creator/`

**Key Files:**
- `SKILL.md` - Comprehensive guide to creating effective skills
- `scripts/init_skill.py` - Skill initialization script
- `scripts/quick_validate.py` - Skill validation script
- `scripts/package_skill.py` - Skill packaging script
- `LICENSE.txt` - License template

### IMPORTANT: FMP Data Integration
**Path:** `/home/kimandrik/workspace/apex/apex-trader/apex-os/reference/fmp/`

**Key Files:**
- `SKILL.md` - FMP skill structure showing data integration approach
- `scripts/get_earnings_transcripts.sh` - API fetching pattern
- `scripts/process_transcripts.py` - Data processing pattern
- `scripts/get_financial_statements.sh` - Financial data fetching example
- `scripts/format_news.py` - News formatting example

### OPTIONAL: Servers Reference
**Path:** `/home/kimandrik/workspace/apex/apex-trader/apex-os/reference/servers/`

**Note:** May have useful patterns but not critical for this refactoring

---

## Current State Files (What Needs Migration)

### Agents (8 total)
**Current Path:** `/home/kimandrik/workspace/apex/apex-trader/apex-os/.claude/agents/apex-os/`

**Files to Migrate:**
- All `.md` files in this directory
- Target: `/home/kimandrik/workspace/apex/apex-trader/apex-os/profiles/default/agents/`

### Apex-OS Commands (6 total)
**Current Path:** `/home/kimandrik/workspace/apex/apex-trader/apex-os/.claude/commands/`

**Files to Migrate:**
1. `apex-os-scan-market.md` (104 lines)
2. `apex-os-analyze-stock.md` (160 lines)
3. `apex-os-write-thesis.md` (153 lines)
4. `apex-os-plan-position.md` (181 lines)
5. `apex-os-execute-entry.md` (219 lines)
6. `apex-os-monitor-portfolio.md` (229 lines)

**Target:** `/home/kimandrik/workspace/apex/apex-trader/apex-os/profiles/default/commands/apex-os/`

### Agent-OS Workflow Commands (6 total)
**Current Path:** `/home/kimandrik/workspace/apex/apex-trader/apex-os/.claude/commands/agent-os/`

**Files to Migrate:**
- All command files in this directory
- Target: `/home/kimandrik/workspace/apex/apex-trader/apex-os/profiles/default/commands/[command-name]/`

### Skills (16 total - DELETE AND REBUILD)
**Current Path:** `/home/kimandrik/workspace/apex/apex-trader/apex-os/.claude/skills/`

**Files to DELETE:**
- All `.skill.md` files in this directory (INCORRECT implementation)

**Content Source for Rebuild:**
- `/home/kimandrik/workspace/apex/apex-trader/apex-os/principles/` - Trading principles to incorporate into skills

**Target:** `/home/kimandrik/workspace/apex/apex-trader/apex-os/profiles/default/skills/[skill-name]/`

### FMP Scripts (12 total)
**Current Path:** `/home/kimandrik/workspace/apex/apex-trader/apex-os/scripts/fmp/`

**Files to Migrate:**
- All `.sh` files in this directory
- Target: `/home/kimandrik/workspace/apex/apex-trader/apex-os/scripts/data-fetching/fmp/`

### Installation Scripts
**Current Paths:**
- `/home/kimandrik/workspace/apex/apex-trader/apex-os/scripts/base-install.sh` (UPDATE)
- `/home/kimandrik/workspace/apex/apex-trader/apex-os/scripts/project-install.sh` (UPDATE)

### Configuration
**Current Path:** `/home/kimandrik/workspace/apex/apex-trader/apex-os/config.yml` (UPDATE)

---

## New Directories to Create

### Skills Structure
```
/home/kimandrik/workspace/apex/apex-trader/apex-os/profiles/default/skills/
  [skill-name]/
    SKILL.md
    scripts/ (optional)
    references/ (optional)
    assets/ (optional)
```

### Data Storage
```
/home/kimandrik/workspace/apex/apex-trader/apex-os/data/
  fmp/
  youtube/ (prepared for future)
```

### YouTube Scripts (Placeholders)
```
/home/kimandrik/workspace/apex/apex-trader/apex-os/scripts/data-fetching/
  youtube/
    get_video_transcript.sh (placeholder)
    process_transcript.py (placeholder)
    README.md (documents future implementation pattern)
```

### Utilities
```
/home/kimandrik/workspace/apex/apex-trader/apex-os/scripts/
  utils/
    (shared utility scripts as needed)
```

---

## Skills List (16 to Rebuild)

### Fundamental Analysis (5)
1. `financial-health-analysis`
2. `valuation-analysis`
3. `growth-analysis`
4. `quality-analysis`
5. `moat-analysis`

### Technical Analysis (4)
6. `price-action-analysis`
7. `volume-analysis`
8. `momentum-analysis`
9. `trend-analysis`

### Risk Management (4)
10. `position-sizing`
11. `stop-loss-management`
12. `portfolio-risk-assessment`
13. `risk-reward-evaluation`

### Behavioral Analysis (3)
14. `market-sentiment-analysis`
15. `bias-detection`
16. `discipline-enforcement`

**For Each Skill:**
- Initialize: `python reference/skill-creator/scripts/init_skill.py`
- Populate: Content from `principles/` + agent-os standards
- Validate: `python reference/skill-creator/scripts/quick_validate.py`
- Package: `python reference/skill-creator/scripts/package_skill.py`

---

## Standards Files (Reference During Development)

**Location:** `/home/kimandrik/workspace/apex/apex-trader/apex-os/agent-os/standards/`

**Key Standards:**
- `backend/api.md` - API design standards
- `backend/migrations.md` - Migration standards
- `backend/models.md` - Model standards
- `backend/queries.md` - Query standards
- `frontend/accessibility.md` - Accessibility standards
- `frontend/components.md` - Component standards
- `frontend/css.md` - CSS standards
- `frontend/responsive.md` - Responsive design standards
- `global/coding-style.md` - Coding style standards
- `global/commenting.md` - Commenting standards
- `global/conventions.md` - Naming conventions
- `global/error-handling.md` - Error handling standards
- `global/tech-stack.md` - Technology stack preferences
- `global/validation.md` - Validation standards
- `testing/test-writing.md` - Testing standards

**Note:** Ensure all spec recommendations align with these standards.

---

## Quick Command Reference

### List Current Agents
```bash
ls -la /home/kimandrik/workspace/apex/apex-trader/apex-os/.claude/agents/apex-os/
```

### List Current Commands (Apex-OS)
```bash
ls -la /home/kimandrik/workspace/apex/apex-trader/apex-os/.claude/commands/apex-os*.md
```

### List Current Commands (Agent-OS)
```bash
ls -la /home/kimandrik/workspace/apex/apex-trader/apex-os/.claude/commands/agent-os/
```

### List Current Skills (to DELETE)
```bash
ls -la /home/kimandrik/workspace/apex/apex-trader/apex-os/.claude/skills/
```

### List Current FMP Scripts
```bash
ls -la /home/kimandrik/workspace/apex/apex-trader/apex-os/scripts/fmp/
```

### List Principles (Content Source)
```bash
ls -la /home/kimandrik/workspace/apex/apex-trader/apex-os/principles/
```

---

## Path Update Examples

### Agents (in Commands)
**Before:** `.claude/agents/apex-os/[agent-name].md`
**After:** `profiles/default/agents/[agent-name].md`

### Skills (in Agents)
**Before:** `.claude/skills/[skill-name].skill.md`
**After:** `profiles/default/skills/[skill-name]/SKILL.md`

### FMP Scripts (in Agents)
**Before:** `scripts/fmp/[script-name].sh` or hardcoded `/Users/nazymazimbayev/apex-os-1/scripts/fmp`
**After:** `scripts/data-fetching/fmp/[script-name].sh`

### Data Files
**Before:** Various locations or inline
**After:** `data/fmp/[symbol]-[type]-[date/period].[ext]`

### Config (config.yml)
**Before:**
```yaml
agents: .claude/agents/apex-os
commands: .claude/commands/apex-os
skills: .claude/skills
```
**After:**
```yaml
agents: profiles/default/agents
commands: profiles/default/commands
skills: profiles/default/skills
```

---

This reference document provides all paths needed for specification development.
