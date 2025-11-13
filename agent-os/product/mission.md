# Product Mission

## Pitch
APEX-OS is a systematic, agent-based CLI framework that helps internal development teams conduct disciplined investment research and portfolio management by providing structured workflows, quality gates, and specialized agents that enforce consistent analysis, risk management, and continuous learning.

## Users

### Primary Customers
- **Internal Development Team**: The creators and maintainers of APEX-OS who use it for their own investment research and trading decisions
- **Internal Team Members**: Individual developers who need systematic tools to prevent emotional trading and enforce disciplined decision-making processes

### User Personas
**Systematic Trader/Developer** (25-45 years old)
- **Role:** Software developer or engineer with trading interest
- **Context:** Has technical skills and understands systematic approaches but struggles with emotional discipline in trading
- **Pain Points:**
  - Makes impulsive trades based on FOMO or tips
  - Lacks consistent position sizing methodology
  - Doesn't document decisions, preventing learning from mistakes
  - No structured workflow leads to emotional overrides
  - Unable to identify patterns across multiple trades
  - Poor risk management leading to oversized positions
- **Goals:**
  - Execute a repeatable, systematic trading process
  - Protect capital through mathematical risk management
  - Learn continuously from documented decisions
  - Eliminate emotional decision-making through enforced gates
  - Build confidence through consistent process execution

## The Problem

### Emotional Trading Destroys Accounts
Most traders fail not due to lack of knowledge, but due to inconsistent execution and emotional decision-making. Without a structured system, traders make impulsive entries, fail to size positions properly, skip stop losses, hold losers too long, sell winners too early, and never learn from mistakes because decisions aren't documented. This leads to preventable losses, account drawdowns, and inability to improve over time.

**Our Solution:** APEX-OS enforces a mandatory 5-6 hour analysis workflow before any trade, implements mathematical position sizing, requires immediate stop loss placement, documents every decision for learning, and uses quality gates to prevent emotional overrides. By treating trading like software development with structured phases, specialized agents, and clear quality standards, we transform emotional gambling into systematic execution.

### Inconsistent Architecture Prevents Reliability
The current APEX-OS codebase has structural inconsistencies inherited from adapting agent-os (a coding framework) into an investment research tool. Agents, commands, and skills are scattered across inconsistent locations, the folder structure doesn't match the proven agent-os pattern, and the data integration approach (particularly with Financial Modeling Prep API) is implemented incorrectly. This makes the system fragile, difficult to maintain, and unreliable for mission-critical trading decisions.

**Our Solution:** Restructure APEX-OS to perfectly mirror the agent-os architecture: create proper `agents/` folder hierarchy, align commands structure with agent-os patterns, completely rebuild skills implementation to match proven patterns, and fix data integration to follow the correct pattern (API to files to agent receives paths). This creates a stable, maintainable foundation that can be enhanced confidently.

## Differentiators

### Agent-Based Investment Framework
Unlike traditional trading tools or spreadsheets, APEX-OS applies agent-os principles to investment research. We provide 8 specialized agents (market-scanner, fundamental-analyst, technical-analyst, risk-manager, thesis-writer, executor, portfolio-monitor, post-mortem-analyst), each with specific responsibilities and constraints. This results in consistent quality analysis, separation of concerns, and repeatable workflows that prevent emotional decision-making.

### Quality Gates Enforce Discipline
Unlike discretionary trading where emotions can override logic, APEX-OS implements 5 quality gates that must be passed: Gate 0 (opportunity screening), Gate 1 (analysis verification requiring fundamental score of 6+ and technical score of 7+), Gate 2 (position planning validating all risk limits), Gate 3 (entry execution requiring immediate stop placement), and Gate 4 (systematic exit documentation). This results in prevented impulsive trades, enforced risk management, and accountability that traditional trading approaches lack.

### Systematic Risk Management as Code
Unlike mental stops or guessed position sizes, APEX-OS implements mathematical position sizing formulas (Position Size = Portfolio * Risk% / (Entry - Stop)), enforces maximum 2% risk per trade, requires portfolio heat below 8%, maintains 20%+ cash reserves, and places hard stops within 1 minute of entry. This results in capital preservation, consistent risk exposure, and prevention of the overleveraging that destroys most trading accounts.

### Continuous Learning Through Documentation
Unlike traders who repeat mistakes because they don't document decisions, APEX-OS requires documentation at every phase: analysis reports, investment thesis, position plans, entry/exit logs, daily monitoring reports, and post-mortem analysis. This results in pattern recognition across trades, identification of systematic errors, continuous process improvement, and accelerated learning that compounds over time.

### CLI-First Internal Tool Architecture
Unlike complex UIs or third-party platforms, APEX-OS is a pure CLI framework designed for internal developer use. Built on proven agent-os architecture patterns, using bash scripts and code execution for data integration (not direct MCP servers), saving all data to files before providing paths to agents, and maintaining complete transparency of all operations. This results in full control, easy debugging, scriptable workflows, and perfect integration with developer tooling.

## Key Features

### Core Features
- **8 Specialized Trading Agents:** Market scanner, fundamental analyst, technical analyst, risk manager, thesis writer, executor, portfolio monitor, and post-mortem analyst that each handle specific responsibilities with built-in constraints
- **5 Quality Gates:** Mandatory checkpoints at opportunity screening, analysis verification, position planning, entry execution, and exit execution that prevent emotional overrides and enforce discipline
- **Mathematical Position Sizing:** Automated calculation using the formula (Portfolio * Risk%) / (Entry - Stop) with enforced maximum 2% risk per trade and portfolio heat limits
- **16 Investment Principles:** Codified knowledge covering fundamental analysis (5), technical analysis (4), risk management (4), and behavioral finance (3) that agents reference automatically
- **Falsifiable Investment Thesis:** Required documentation of bull/bear cases with specific falsification criteria that trigger systematic exits when violated

### Data Integration Features
- **Financial Modeling Prep (FMP) Integration:** Bash scripts for fetching earnings transcripts, financial statements, stock news, and company data via code execution
- **File-Based Data Flow:** All API data saved to local files first, then file paths provided to agents (never raw data directly to agents)
- **Multi-Source Data Support:** Extensible architecture for adding additional financial data APIs beyond FMP using same file-based pattern
- **Cached Data Processing:** JSON data cached locally for reprocessing without network calls, enabling fast formatting changes and offline analysis

### Workflow Features
- **6-Phase Trading Workflow:** Structured progression from opportunity discovery to market scanning to analysis to thesis writing to position planning to execution to monitoring
- **Mandatory 5-6 Hour Pre-Trade Analysis:** Enforced time investment in research before any entry, preventing impulsive FOMO-driven trades
- **Slash Command Interface:** Simple CLI commands (/scan-market, /analyze-stock, /write-thesis, /plan-position, /execute-entry, /monitor-portfolio) that guide through each phase
- **Daily Portfolio Monitoring:** Automated tracking of all positions, thesis validation, stop adjustment, and alert generation for portfolio changes
- **Post-Mortem Learning:** Required analysis after every trade exit (win or lose) to extract lessons and identify patterns for continuous improvement

### Risk Management Features
- **Hard Stop Loss Enforcement:** Required stop placement within 1 minute of entry with verification of active status before gate passes
- **3-Target Profit Scaling:** Systematic selling of 1/3 position at 2:1 R:R, 1/3 at 3:1 R:R, and trailing final 1/3 to balance profit-taking with letting winners run
- **Portfolio Heat Tracking:** Real-time calculation of total portfolio risk across all positions with maximum 8% limit to prevent overexposure
- **Position Size Limits:** Enforcement of 8-15% maximum per position, 8-10 total positions, 50% maximum sector exposure, and 20% minimum cash reserve

### Advanced Features
- **Structured Documentation System:** Organized folders for opportunities, analysis (per-stock folders with reports), positions (per-trade folders with logs), and reports (daily monitoring, monthly reviews)
- **CLI Framework Architecture:** Based on agent-os structure with profiles, standards, agents, commands, and skills organized in consistent hierarchy
- **Extensible Agent System:** Agent definitions in markdown format that can be customized, extended, or replaced while maintaining system integrity
- **Process-Over-Outcome Focus:** Metrics tracking on gate pass rates, stop execution rates, falsification adherence, and post-mortem completion rather than just P&L
