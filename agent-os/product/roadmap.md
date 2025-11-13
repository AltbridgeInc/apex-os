# Product Roadmap

1. [ ] Restructure Directory Hierarchy to Match agent-os Pattern — Create proper `profiles/default/agents/` folder structure, move all agent definitions from `.claude/agents/apex-os/` to new location, create `profiles/default/commands/` hierarchy matching agent-os command organization patterns, and update all references to point to new locations. This establishes the foundation for consistent architecture. `L`

2. [x] Completely Rebuild Skills Implementation — Study reference agent-os skills architecture, delete current `.claude/skills/` implementation that is "totally wrong", recreate skills following exact agent-os patterns for skill definition and loading, ensure skills properly reference the 16 investment principles in `principles/` folder, and verify skills are auto-compiled correctly. `L`

3. [x] Align Commands Structure with agent-os Architecture — Reorganize command folders to match agent-os multi-agent and single-agent command patterns, ensure each command has proper structure with command definition files and supporting files, update command references in profiles and configuration, and verify all 6 commands (/scan-market, /analyze-stock, /write-thesis, /plan-position, /execute-entry, /monitor-portfolio) load correctly. `M`

4. [ ] Fix Financial Modeling Prep (FMP) Data Integration — Implement correct data flow pattern: bash scripts fetch from FMP API and save to files, agents receive file paths (not raw data), create proper skill definition for FMP integration in new skills structure, move FMP scripts from `scripts/fmp/` to appropriate location in new structure, and update all agent references to use file-based data access. `L`

5. [ ] Create Comprehensive Architecture Documentation — Document the target folder structure clearly in `agent-os/product/architecture.md`, create migration guide from old structure to new structure, document correct patterns for adding new agents/commands/skills, reference agent-os architecture patterns with specific examples, and include diagrams showing proper hierarchy and data flow patterns. `M`

6. [x] Fix Configuration and Profile System — Update `config.yml` to reflect new folder structure, ensure default profile in `profiles/default/` follows agent-os patterns exactly, create proper standards structure under `profiles/default/standards/` for investment-specific standards, verify profile loading mechanism works with new structure, and test profile switching if multiple profiles needed. `M`

7. [ ] Implement Additional Financial Data API Integrations — Add support for additional data sources beyond FMP using same file-based pattern (API → save to files → provide paths to agents), create bash scripts for new data sources following FMP reference pattern, implement proper error handling and rate limiting for all API integrations, ensure all data is cached locally in structured folders, and document data source capabilities and limitations. `L`

8. [ ] Fix All Structural Bugs and Inconsistencies — Audit entire codebase for references to old folder locations, fix broken imports and path references throughout system, ensure all agent/command/skill loading works correctly, test complete workflow end-to-end (/scan-market through /monitor-portfolio), fix any quality gate validation bugs, and verify all documentation accurately reflects actual implementation. `L`

9. [ ] Enhance Agent Workflow Coordination — Improve handoff between agents (fundamental-analyst → technical-analyst → thesis-writer), implement proper state management for multi-step workflows, ensure data from previous phases is correctly passed to next phase, add validation that required inputs exist before agent starts, and create clear error messages when workflow prerequisites are missing. `M`

10. [ ] Implement Robust Error Handling and Validation — Add comprehensive error handling to all bash scripts, validate API responses and handle missing/malformed data gracefully, implement input validation for all CLI commands, add clear error messages with actionable guidance for users, ensure system fails safely (doesn't proceed to next gate if previous gate failed), and log all errors for debugging. `M`

11. [ ] Create Automated Testing Suite — Build unit tests for all bash scripts (especially FMP integration scripts), create integration tests for complete workflows, implement tests for quality gate validation logic, add tests for position sizing calculations and risk management rules, create tests for agent coordination and data passing, and set up CI pipeline to run tests on all changes. `L`

12. [ ] Enhance Risk Management Engine — Improve portfolio heat calculation accuracy, add real-time position correlation analysis, implement sector exposure tracking and alerts, enhance stop loss calculation with ATR-based adaptive stops, add position rebalancing recommendations when limits exceeded, and create risk metrics dashboard showing current exposure across all dimensions. `L`

13. [ ] Build Advanced Monitoring and Alerting — Enhance daily monitoring reports with trend analysis, implement alert system for thesis falsification triggers, add watchlist monitoring for pre-entry opportunities, create weekly/monthly performance reports with pattern analysis, implement real-time position monitoring dashboard, and add configurable alert thresholds for portfolio metrics. `M`

14. [ ] Improve Post-Mortem Analysis System — Enhance post-mortem template with guided questions, implement pattern recognition across multiple post-mortems, create aggregated metrics showing common mistake patterns, build learning database that agents can reference, add quarterly review workflow that synthesizes all post-mortems, and create actionable improvement recommendations based on historical data. `M`

15. [ ] Optimize Performance and Caching — Implement efficient caching strategy for frequently accessed financial data, optimize bash scripts for faster execution, add parallel processing for independent data fetches, implement incremental updates for large datasets, create cleanup routines for old cached data, and add performance monitoring to identify bottlenecks. `S`

16. [ ] Create Installation and Onboarding System — Build comprehensive installation script matching agent-os base-install.sh pattern, create project-install.sh that sets up new trading workspaces correctly, implement verification checks after installation, create interactive onboarding guide for first-time users, add example walkthrough with sample analysis, and build troubleshooting guide for common setup issues. `M`

> Notes
> - Order items by technical dependencies and product architecture
> - Each item should represent an end-to-end (frontend + backend) functional and testable feature
> - Phase 1 (items 1-6) is CRITICAL for establishing structural consistency before any feature work
> - Data integration (items 4, 7) follows strict pattern: API → files → paths to agents (never raw data)
> - Testing (item 11) should be implemented after structural fixes but before advanced features
> - All features build incrementally toward the mission of systematic, disciplined investment research
