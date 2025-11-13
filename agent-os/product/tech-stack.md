# Tech Stack

## Architecture Overview

APEX-OS is a CLI-based agent framework for systematic investment research, adapted from the agent-os architecture (originally designed for software development). The system uses a file-based, bash-driven approach with specialized agents that process structured data through quality-gated workflows.

## Core Framework

### CLI Framework
- **Base Architecture:** agent-os pattern (profiles, agents, commands, skills, standards)
- **Command Interface:** Slash commands (/scan-market, /analyze-stock, etc.) implemented as CLI entry points
- **Profile System:** YAML-based configuration with default profile in `profiles/default/`
- **Agent Loading:** Markdown-based agent definitions loaded from profile structure

### Languages & Runtime
- **Primary Language:** Bash (shell scripts for core workflows, data fetching, system operations)
- **Supporting Language:** Python 3 (for JSON processing, data formatting, no external dependencies beyond stdlib)
- **Configuration Language:** YAML (config.yml, portfolio-config.yaml, open-positions.yaml)
- **Documentation Format:** Markdown (agent definitions, principles, reports, analysis outputs)

### Package Management
- **System Dependencies:** Standard Linux/macOS tools (bash, curl, jq, python3)
- **No Package Managers:** No npm, pip, bundler, or other package managers required
- **No Virtual Environments:** Pure Python stdlib only (no venv, uv, or pipenv)
- **Dependency Philosophy:** Minimal external dependencies, use standard Unix tools

## Agent System

### Agent Framework
- **Agent Architecture:** Custom agent-based system adapted from agent-os
- **Agent Definitions:** Markdown files in `profiles/default/agents/` (to be restructured from current `.claude/agents/apex-os/`)
- **Agent Types:** 8 specialized agents (market-scanner, fundamental-analyst, technical-analyst, risk-manager, thesis-writer, executor, portfolio-monitor, post-mortem-analyst)
- **Agent Communication:** File-based data passing (agents read/write structured files)
- **Agent Constraints:** Built-in rules and quality gates enforced in agent definitions

### Commands & Workflows
- **Command Structure:** Follows agent-os multi-agent and single-agent command patterns
- **Command Location:** `profiles/default/commands/` (to be restructured from current `.claude/commands/apex-os/`)
- **Workflow Orchestration:** Sequential phases with quality gates between phases
- **State Management:** File system-based (analysis folders, position folders, reports)

### Skills System
- **Skills Implementation:** Auto-loaded capabilities following agent-os skill patterns (current implementation "totally wrong", needs complete rebuild)
- **Skills Location:** To be determined after studying agent-os reference architecture
- **Skills Content:** References to 16 investment principles in `principles/` folder
- **Skills Categories:** Fundamental analysis (5), technical analysis (4), risk management (4), behavioral finance (3)

## Data Integration

### Data Integration Architecture
- **Integration Method:** Code execution with MCP or skills (NOT direct MCP servers)
- **Data Flow Pattern:** API → Save to files → Provide file paths to agents (CRITICAL: never give raw data directly to agents)
- **Reference Implementation:** `reference/fmp/` folder demonstrates correct pattern

### Financial Data APIs
- **Primary API:** Financial Modeling Prep (FMP) - earnings transcripts, financial statements, stock news
- **FMP Integration:** Bash scripts in `scripts/fmp/` (fmp-transcript.sh, fmp-financials.sh, fmp-quote.sh, etc.)
- **Additional APIs:** Extensible for other financial data sources using same file-based pattern
- **API Key Management:** Environment variables stored in root `.env` file

### Data Fetching Scripts
- **Transcript Fetching:** `get_earnings_transcripts.sh` - Downloads earnings call transcripts as JSON
- **Financial Statements:** `get_financial_statements.sh` - Fetches income statements, balance sheets, cash flow
- **Stock News:** `get_stock_news.sh` - Retrieves news articles for companies
- **Data Processing:** Python scripts (`process_transcripts.py`, `format_news.py`) convert JSON to readable formats
- **Dependencies:** curl (HTTP client), jq (JSON processor), python3 (JSON parsing)

### Data Storage
- **File System:** Local file system for all data storage (no databases)
- **Data Caching:** JSON files cached locally in structured directories
- **File Organization:** By symbol and date (e.g., `aapl-transcript-2025-Q4.json`, `tsla-news-2025-11-03.json`)
- **File Formats:** JSON (raw API data), TXT (processed transcripts), Markdown (formatted news, reports)

## Documentation & Standards

### Documentation System
- **Principles Location:** `principles/` folder with 16 investment principles organized by category
- **Standards Location:** `agent-os/standards/` (global standards for coding, commenting, conventions, error handling, tech stack, validation)
- **Product Docs Location:** `agent-os/product/` (mission, roadmap, tech-stack, architecture)
- **Agent Definitions:** Markdown files defining agent roles, responsibilities, constraints

### Reference Architecture
- **Reference Source:** `reference/agent-os/` - complete agent-os codebase for structure patterns
- **Reference Data Integration:** `reference/fmp/` - correct implementation of FMP API integration
- **Structure Guidance:** Reference agent-os for folder hierarchy, agent locations, command patterns, skills implementation

## Workflow & Output

### Workflow Management
- **Phase Tracking:** File-based state (opportunities/, analysis/, positions/, reports/)
- **Quality Gates:** YAML configuration defining gate requirements (config.yml)
- **Documentation Output:** Markdown files (reports, logs, thesis, analysis)
- **Position Tracking:** YAML files (portfolio-config.yaml, open-positions.yaml)

### Analysis Outputs
- **Report Format:** Structured Markdown documents
- **Analysis Storage:** Per-stock folders (`analysis/YYYY-MM-DD-TICKER/`)
- **Position Logs:** Per-trade folders (`positions/YYYY-MM-DD-TICKER/`)
- **Monitoring Reports:** Daily reports (`reports/daily-monitor-YYYY-MM-DD.md`)

## Testing & Quality

### Testing Framework
- **Test Structure:** Organized in `tests/` directory (unit, integration, e2e, error, performance)
- **Test Language:** Bash scripts (test-helpers.sh, test-complete-workflow.sh, test-agents.sh, etc.)
- **Unit Tests:** Test FMP scripts (`test-fmp-scripts.sh`)
- **Integration Tests:** Test agent interactions (`test-agents.sh`)
- **E2E Tests:** Complete workflow validation (`test-complete-workflow.sh`)
- **Performance Tests:** Benchmark FMP API calls (`benchmark-fmp.sh`)

### Quality Assurance
- **Error Handling:** Bash script error handling with clear error messages
- **Input Validation:** Parameter validation in all scripts
- **Gate Validation:** Quality gate checks at each workflow phase
- **Documentation Standards:** Consistent markdown formatting, required sections

## Deployment & Infrastructure

### Installation
- **Installation Method:** Two-step process (base install to ~/apex-os, project install to workspace)
- **Base Install Script:** `scripts/base-install.sh` - clones repository
- **Project Install Script:** `scripts/project-install.sh` - sets up workspace with agents, commands, principles
- **Update Process:** `git pull` in ~/apex-os, then reinstall to workspace

### Hosting & Runtime
- **Hosting:** Local developer machine (internal tool, not deployed)
- **Runtime Environment:** Bash shell on Linux/macOS (WSL2 supported)
- **No Web Server:** Pure CLI tool, no HTTP server
- **No Database:** File system only for data persistence

### CI/CD
- **Version Control:** Git (GitHub repository: AltbridgeInc/apex-os)
- **CI Pipeline:** GitHub Actions (workflow definitions in `.github/`)
- **No Deployment:** Internal tool, installed locally by users
- **Release Process:** Git tags, changelog updates (CHANGELOG.md)

## Security & Configuration

### API Security
- **API Keys:** Environment variables in `.env` file (FMP_API_KEY)
- **Key Storage:** Not committed to repository (.env in .gitignore)
- **Key Validation:** Scripts check for API key before making requests

### Configuration Management
- **Global Config:** `config.yml` - framework configuration
- **Portfolio Config:** `portfolio/portfolio-config.yaml` - user trading preferences
- **Profile Config:** Profile-specific settings in `profiles/default/`
- **Environment Variables:** `.env` file for API keys and sensitive configuration

## Future Considerations

### Planned Architecture Changes
- **Structure Migration:** Move from `.claude/agents/` to `profiles/default/agents/` (matching agent-os)
- **Skills Rebuild:** Complete restructure of skills implementation to match agent-os patterns
- **Commands Reorganization:** Align command structure with agent-os multi-agent/single-agent patterns
- **Data Integration Fixes:** Ensure all data flows through file-based pattern (API → files → paths)

### Potential Extensions
- **Additional Data Sources:** More financial APIs following same file-based integration pattern
- **Enhanced Analytics:** Python-based analysis tools for post-mortem pattern recognition
- **Data Visualization:** Optional visualization tools for portfolio metrics (still CLI-driven)
- **Parallel Processing:** Concurrent data fetching for multiple symbols

## Design Principles

### Architectural Philosophy
- **Simplicity:** Bash scripts and file system over complex frameworks
- **Transparency:** All operations visible and debuggable via files
- **Consistency:** Follow agent-os patterns exactly for maintainability
- **File-Based:** All data persisted to files, all communication through files
- **No Magic:** Explicit data flow, no hidden state, clear separation of concerns

### Data Flow Philosophy
- **API → Files → Agents:** NEVER give raw data directly to agents
- **Cache Everything:** Save API responses locally, reprocess without network calls
- **Structured Output:** Consistent file naming, organized directories
- **Explicit Paths:** Agents receive file paths, not data objects

### Integration Philosophy
- **Code Execution:** Use code execution with MCP/skills, not direct MCP servers
- **Bash First:** Bash scripts for fetching, Python only for formatting
- **Minimal Dependencies:** Only stdlib, no pip install, no external packages
- **Standard Tools:** curl, jq, python3 - nothing exotic
