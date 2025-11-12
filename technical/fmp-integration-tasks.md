# FMP API Integration - Task List

**Project**: APEX-OS Financial Modeling Prep API Integration
**Date**: 2025-11-11
**Total Tasks**: 21
**Reference Documents**:
- Requirements: `/Users/nazymazimbayev/apex-os-1/fmp-integration-requirements.md`
- Specification: `/Users/nazymazimbayev/apex-os-1/fmp-integration-spec.md`

---

## Overview

This task list breaks down the implementation of FMP API integration into 4 phases:
1. **Helper Scripts** (9 tasks) - Core infrastructure for FMP API access
2. **Agent Modifications** (4 tasks) - Update agents to use FMP instead of WebFetch
3. **Testing** (5 tasks) - Comprehensive validation
4. **Documentation** (3 tasks) - User-facing documentation

**Execution Strategy**: Sequential by phase, parallel execution within phases where possible.

---

## Phase 1: Helper Scripts Foundation

**Goal**: Create reusable Bash scripts for FMP API access
**Total Tasks**: 9
**Estimated Effort**: 12-16 hours
**Dependencies**: None - can start immediately

---

## Task 1.1: Create fmp-common.sh (Core Infrastructure)

**Description**: Implement shared functions used by all FMP helper scripts

**Dependencies**: None

**Effort**: 3 hours

**Priority**: CRITICAL - All other scripts depend on this

**Files to Create**:
- `/Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-common.sh`

**Implementation Scope**:

Functions to implement:
1. `load_api_key()` - Load FMP_API_KEY from .env, validate existence
2. `fmp_api_call()` - Make HTTP calls with retry logic and error handling
3. `format_error()` - Return standardized JSON error format
4. `map_http_error()` - Map HTTP codes (400, 401, 429, 500, etc.) to user messages
5. `validate_symbol()` - Validate stock symbol format (1-5 uppercase letters)
6. `check_rate_limit()` - Track API calls per minute, sleep if approaching 240/250 limit

**Acceptance Criteria**:
- [ ] All 6 functions implemented and working
- [ ] Retry logic: 3 attempts with exponential backoff (1s, 2s, 4s)
- [ ] Rate limit tracking using `/tmp/fmp_rate_*.txt` files
- [ ] Errors return JSON: `{"error": true, "type": "...", "message": "..."}`
- [ ] HTTP codes 400, 401, 403, 404, 429, 500, 503 mapped to friendly messages
- [ ] Retries on 429, 500, 503; no retry on 400, 401, 404
- [ ] Script is executable and sourceable by other scripts
- [ ] Functions exported for use by other scripts

**Implementation Notes**:
- Set `set -euo pipefail` for strict error handling
- Use curl with `--max-time 30` for timeout
- Parse HTTP code with `curl -w "\n%{http_code}"`
- Store API key check: exit early if FMP_API_KEY not in .env
- Rate limit file named with minute granularity: `fmp_rate_$(date +%Y%m%d_%H%M).txt`

**Testing**:
```bash
# Test API key loading
source /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-common.sh
load_api_key && echo "API key loaded: ${FMP_API_KEY:0:10}..."

# Test error formatting
format_error "rate_limit" "Too many requests"

# Test symbol validation
validate_symbol "AAPL" && echo "Valid"
validate_symbol "invalid123" && echo "Should fail"

# Test API call (real call)
fmp_api_call "/v3/quote/AAPL" | jq '.[0].symbol'
```

---

## Task 1.2: Create fmp-quote.sh (Real-Time Quotes)

**Description**: Implement script to fetch real-time stock quotes (single or batch)

**Dependencies**: Task 1.1 (fmp-common.sh)

**Effort**: 1.5 hours

**Files to Create**:
- `/Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-quote.sh`

**Implementation Scope**:
- Accept single symbol or comma-separated list: `AAPL` or `AAPL,MSFT,GOOGL`
- Call FMP endpoint: `GET /v3/quote/{symbols}`
- Validate response is array with length > 0
- Return full JSON response (array of quote objects)

**Acceptance Criteria**:
- [ ] Single quote works: `./fmp-quote.sh AAPL`
- [ ] Batch quotes work: `./fmp-quote.sh "AAPL,MSFT,GOOGL"`
- [ ] Converts symbols to uppercase automatically
- [ ] Returns error JSON if no data found
- [ ] Returns error JSON if invalid symbol
- [ ] Response includes all fields: symbol, price, change, changesPercentage, volume, marketCap, etc.

**Implementation Notes**:
- Source fmp-common.sh from same directory
- Use `$1` for symbols parameter
- Build endpoint: `/v3/quote/${symbols}`
- Validate with: `jq -e 'type == "array"'`
- Check array not empty: `jq 'length'`

**Testing**:
```bash
# Single quote
bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-quote.sh AAPL | jq '.[0].price'

# Batch quotes
bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-quote.sh "AAPL,MSFT,GOOGL" | jq -r '.[] | [.symbol, .price] | @tsv'

# Error case - invalid symbol
bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-quote.sh INVALID | jq '.error'
```

---

## Task 1.3: Create fmp-financials.sh (Financial Statements)

**Description**: Implement script to fetch income statement, balance sheet, and cash flow statements

**Dependencies**: Task 1.1 (fmp-common.sh)

**Effort**: 2 hours

**Files to Create**:
- `/Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-financials.sh`

**Implementation Scope**:
- Parameters: `SYMBOL TYPE [LIMIT] [PERIOD]`
- TYPE: `income`, `balance`, `cashflow`
- LIMIT: default 5
- PERIOD: `annual` or `quarterly`, default annual
- Map type to endpoint:
  - income → `/v3/income-statement/{symbol}`
  - balance → `/v3/balance-sheet-statement/{symbol}`
  - cashflow → `/v3/cash-flow-statement/{symbol}`
- Return sorted by date (newest first)

**Acceptance Criteria**:
- [ ] Income statements fetch correctly
- [ ] Balance sheets fetch correctly
- [ ] Cash flow statements fetch correctly
- [ ] Default to 5 years annual if limit/period not specified
- [ ] Quarterly data works with period=quarterly
- [ ] Response sorted by date descending (newest first)
- [ ] Error handling for invalid statement type

**Implementation Notes**:
- Use case statement to validate and map type
- Build params: `limit=${limit}&period=${period}`
- Sort response: `jq 'sort_by(.date) | reverse'`
- Validate response is array with data

**Testing**:
```bash
# Income statement (5 years)
bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-financials.sh AAPL income 5 annual | jq -r '.[] | [.date, .revenue] | @tsv'

# Balance sheet
bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-financials.sh AAPL balance 5 annual | jq -r '.[] | [.date, .totalAssets] | @tsv'

# Cash flow quarterly
bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-financials.sh AAPL cashflow 8 quarterly | jq -r '.[] | .date'

# Invalid type
bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-financials.sh AAPL invalid | jq '.error'
```

---

## Task 1.4: Create fmp-ratios.sh (Ratios & Metrics)

**Description**: Implement script to fetch financial ratios, key metrics, and growth metrics

**Dependencies**: Task 1.1 (fmp-common.sh)

**Effort**: 1.5 hours

**Files to Create**:
- `/Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-ratios.sh`

**Implementation Scope**:
- Parameters: `SYMBOL TYPE [LIMIT]`
- TYPE: `ratios`, `metrics`, `growth`
- LIMIT: default 5
- Map type to endpoint:
  - ratios → `/v3/ratios/{symbol}`
  - metrics → `/v3/key-metrics/{symbol}`
  - growth → `/v3/financial-growth/{symbol}`

**Acceptance Criteria**:
- [ ] Ratios fetch correctly (P/E, P/B, ROE, ROA, debt-to-equity, current ratio)
- [ ] Key metrics fetch correctly (revenue per share, PEG, Graham number)
- [ ] Growth metrics fetch correctly (revenue growth %, earnings growth %)
- [ ] Default to 5 periods if limit not specified
- [ ] Response sorted by date descending
- [ ] Error handling for invalid type

**Implementation Notes**:
- Similar structure to fmp-financials.sh
- Use case statement for type validation
- Sort response by date: `jq 'sort_by(.date) | reverse'`

**Testing**:
```bash
# Financial ratios
bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-ratios.sh AAPL ratios 1 | jq -r '.[0] | [.priceEarningsRatio, .returnOnEquity] | @tsv'

# Key metrics
bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-ratios.sh AAPL metrics 5 | jq -r '.[] | [.date, .revenuePerShare] | @tsv'

# Growth metrics
bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-ratios.sh AAPL growth 5 | jq -r '.[] | [.date, .revenueGrowth] | @tsv'
```

---

## Task 1.5: Create fmp-profile.sh (Company Profile)

**Description**: Implement script to fetch company profile and overview

**Dependencies**: Task 1.1 (fmp-common.sh)

**Effort**: 1 hour

**Files to Create**:
- `/Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-profile.sh`

**Implementation Scope**:
- Parameters: `SYMBOL`
- Endpoint: `GET /v3/profile/{symbol}`
- Return single object (extract first element from array response)

**Acceptance Criteria**:
- [ ] Profile fetches correctly with all fields
- [ ] Returns object (not array) for easy parsing
- [ ] Includes: companyName, sector, industry, description, CEO, website, marketCap, beta
- [ ] Error handling for invalid symbol

**Implementation Notes**:
- FMP returns profile as single-element array
- Extract with: `jq '.[0]'`
- Simple script, similar to quote but simpler

**Testing**:
```bash
# Get profile
bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-profile.sh AAPL | jq -r '[.companyName, .sector, .industry] | @tsv'

# Check all fields present
bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-profile.sh AAPL | jq 'keys'
```

---

## Task 1.6: Create fmp-historical.sh (Historical Prices)

**Description**: Implement script to fetch historical price data (daily or intraday)

**Dependencies**: Task 1.1 (fmp-common.sh)

**Effort**: 2 hours

**Files to Create**:
- `/Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-historical.sh`

**Implementation Scope**:
- Parameters: `SYMBOL [FROM_DATE] [TO_DATE] [LIMIT] [INTERVAL]`
- INTERVAL: `daily` (default), `1min`, `5min`, `15min`, `30min`, `1hour`, `4hour`
- Daily endpoint: `/v3/historical-price-full/{symbol}?from={from}&to={to}`
- Intraday endpoint: `/v3/historical-chart/{interval}/{symbol}`
- Extract `.historical` array for daily data
- Apply limit if specified

**Acceptance Criteria**:
- [ ] Daily historical data fetches correctly
- [ ] Date range filtering works (from/to parameters)
- [ ] Limit parameter works (e.g., last 500 days)
- [ ] Intraday intervals work (5min, 15min, etc.)
- [ ] Response includes OHLCV data for all bars
- [ ] Empty parameters handled gracefully

**Implementation Notes**:
- Conditional logic based on interval
- For daily: extract `response.historical`, then apply limit
- For intraday: response is already array, apply limit directly
- Use `jq ".[0:${limit}]"` for limiting

**Testing**:
```bash
# Last 500 days
bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-historical.sh AAPL "" "" 500 | jq 'length'

# Date range
bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-historical.sh AAPL 2023-01-01 2023-12-31 | jq -r '.[] | .date' | head -5

# Intraday 5-minute
bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-historical.sh AAPL "" "" 100 5min | jq -r '.[] | [.date, .close] | @tsv' | head -10

# Extract OHLCV
bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-historical.sh AAPL "" "" 10 | jq -r '.[] | [.date, .open, .high, .low, .close, .volume] | @tsv'
```

---

## Task 1.7: Create fmp-screener.sh (Stock Screening)

**Description**: Implement script for stock screening with multiple criteria

**Dependencies**: Task 1.1 (fmp-common.sh)

**Effort**: 2.5 hours

**Files to Create**:
- `/Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-screener.sh`

**Implementation Scope**:
- Accept named parameters: `--param=value`
- Support parameters:
  - `--type=gainers|losers|actives` (market movers shortcut)
  - `--marketCapMoreThan`, `--marketCapLowerThan`
  - `--priceMoreThan`, `--priceLowerThan`
  - `--betaMoreThan`, `--volumeMoreThan`
  - `--sector`, `--industry`, `--exchange`
  - `--limit` (default 100)
- Market movers: `/v3/stock_market/{gainers|losers|actives}`
- Stock screener: `/v3/stock-screener?{params}`

**Acceptance Criteria**:
- [ ] Market movers shortcuts work (--type=gainers, etc.)
- [ ] Multi-parameter screening works
- [ ] All filter parameters supported
- [ ] Default limit is 100
- [ ] Returns array of matching stocks
- [ ] Error handling for invalid parameters

**Implementation Notes**:
- Parse arguments with loop: `for arg in "$@"; do case "$arg" ...`
- Build params string incrementally
- Special handling for --type (different endpoint)
- URL encode parameter values if needed

**Testing**:
```bash
# Top gainers
bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-screener.sh --type=gainers --limit=10 | jq -r '.[] | [.symbol, .changesPercentage] | @tsv'

# Most active
bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-screener.sh --type=actives --limit=20 | jq 'length'

# Custom screening
bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-screener.sh --marketCapMoreThan=1000000000 --volumeMoreThan=500000 --priceMoreThan=10 --limit=50 | jq -r '.[] | [.symbol, .marketCap, .volume] | @tsv'

# Sector filter
bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-screener.sh --sector=Technology --limit=30 | jq -r '.[] | .symbol'
```

---

## Task 1.8: Create fmp-indicators.sh (Technical Indicators)

**Description**: Implement script to fetch technical indicators

**Dependencies**: Task 1.1 (fmp-common.sh)

**Effort**: 2 hours

**Files to Create**:
- `/Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-indicators.sh`

**Implementation Scope**:
- Parameters: `SYMBOL INDICATOR_TYPE [PERIOD] [TIMEFRAME]`
- INDICATOR_TYPE: `sma`, `ema`, `rsi`, `macd`, `adx`, `williams`, `stoch`
- PERIOD: default 14
- TIMEFRAME: `daily` (default), `1min`, `5min`, `15min`, `30min`, `1hour`, `4hour`
- Endpoint: `GET /v3/technical_indicator/{timeframe}/{symbol}?type={type}&period={period}`

**Acceptance Criteria**:
- [ ] SMA indicator fetches correctly
- [ ] EMA indicator fetches correctly
- [ ] RSI indicator fetches correctly
- [ ] MACD indicator fetches correctly
- [ ] ADX indicator fetches correctly
- [ ] All timeframes work (daily, 5min, etc.)
- [ ] Default period is 14
- [ ] Returns array of indicator values with dates

**Implementation Notes**:
- Validate indicator type with case statement
- Build endpoint with timeframe and symbol
- Add type and period as parameters
- Return full response array

**Testing**:
```bash
# SMA 50-day
bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-indicators.sh AAPL sma 50 daily | jq -r '.[0:5] | .[] | [.date, .sma] | @tsv'

# RSI 14-day
bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-indicators.sh AAPL rsi 14 daily | jq -r '.[0].rsi'

# EMA 20-day
bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-indicators.sh AAPL ema 20 daily | jq -r '.[] | .ema' | head -10

# ADX (trend strength)
bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-indicators.sh AAPL adx 14 daily | jq -r '.[0].adx'
```

---

## Task 1.9: Create README.md for Helper Scripts

**Description**: Create comprehensive documentation for all helper scripts

**Dependencies**: Tasks 1.1-1.8 (all helper scripts completed)

**Effort**: 1.5 hours

**Files to Create**:
- `/Users/nazymazimbayev/apex-os-1/scripts/fmp/README.md`

**Implementation Scope**:

Documentation sections:
1. Overview - Purpose of FMP helper scripts
2. Prerequisites - FMP API key in .env
3. Script Reference - Each script with usage examples
4. Error Handling - Standard error JSON format
5. Rate Limiting - How rate limit management works
6. Common Patterns - Example workflows for agents

**Acceptance Criteria**:
- [ ] All 8 scripts documented with usage examples
- [ ] Error handling section explains error JSON format
- [ ] Rate limiting explained (250/min limit)
- [ ] Common patterns for each agent type provided
- [ ] Installation/setup instructions included
- [ ] Troubleshooting section included

**Implementation Notes**:
- Include copy-paste ready examples
- Document all parameters for each script
- Show error handling patterns for agents
- Include example integration code
- Reference FMP API documentation

**Testing**:
- Review documentation for completeness
- Test all example commands work correctly
- Verify all script parameters documented

---

## Phase 2: Agent Modifications

**Goal**: Update 4 agents to use FMP API instead of WebFetch
**Total Tasks**: 4
**Estimated Effort**: 8-12 hours
**Dependencies**: Phase 1 complete (all helper scripts working)

---

## Task 2.1: Update Market Scanner Agent

**Description**: Modify Market Scanner to use FMP API for opportunity screening

**Dependencies**: Phase 1 (all helper scripts)

**Effort**: 3 hours

**Files to Modify**:
- `/Users/nazymazimbayev/apex-os-1/.claude/agents/apex-os-market-scanner.md`

**Implementation Scope**:

Changes required:
1. Update YAML frontmatter (line 4): Remove `WebFetch` from tools
   - Before: `tools: Write, Read, Bash, WebFetch`
   - After: `tools: Write, Read, Bash`

2. Add FMP Integration Section (after line 19)
   - Document available scripts: fmp-screener.sh, fmp-quote.sh, fmp-profile.sh
   - Provide usage examples
   - Document error handling pattern

3. Update Step 1: Run Systematic Scans (line 22)
   - Replace generic descriptions with specific FMP calls
   - Technical scanners: gainers, actives
   - Fundamental scanners: growth stocks with filters
   - Catalyst monitoring: earnings calendar
   - Sector performance tracking

4. Update Step 2: Initial Filtering (line 45)
   - Use fmp-quote.sh for detailed quotes
   - Use fmp-profile.sh for company info
   - Apply filters: volume >500k, price >$10, market cap >$100M

5. Add Data Quality Checks section
   - Validate FMP responses
   - Check for stale data
   - Alert on API failures

**Acceptance Criteria**:
- [x] WebFetch removed from tools list
- [x] FMP integration section added with examples
- [x] All scan steps updated to use FMP scripts
- [x] Error handling documented
- [x] Data quality checks documented
- [x] Examples use absolute paths to scripts
- [x] Agent can successfully run opportunity scans

**Implementation Notes**:
- Use absolute paths: `/Users/nazymazimbayev/apex-os-1/scripts/fmp/`
- Include jq parsing examples in workflow steps
- Show error checking: `if echo "$quote" | jq -e '.error'`
- Document filtering logic clearly

**Testing**:
```bash
# Test with Market Scanner agent
# Verify it can:
# 1. Screen for gainers
# 2. Screen for growth stocks
# 3. Filter by volume/price
# 4. Create opportunity documents
```

---

## Task 2.2: Update Fundamental Analyst Agent

**Description**: Modify Fundamental Analyst to use FMP API for financial analysis

**Dependencies**: Phase 1 (all helper scripts)

**Effort**: 3.5 hours

**Files to Modify**:
- `/Users/nazymazimbayev/apex-os-1/.claude/agents/apex-os-fundamental-analyst.md`

**Implementation Scope**:

Changes required:
1. Update YAML frontmatter (line 4): Remove `WebFetch`
   - After: `tools: Write, Read, Bash`

2. Add FMP Integration Section (after line 20)
   - Required scripts: fmp-financials.sh, fmp-ratios.sh, fmp-profile.sh
   - Standard data fetch pattern example
   - Show fetching all data types at once

3. Update Section 1: Financial Health Analysis (line 37)
   - Replace with FMP-specific data extraction
   - Show fetching income/balance/cashflow statements
   - Revenue analysis with jq parsing
   - Profitability analysis (margin trends)
   - Cash flow analysis (calculate free cash flow)
   - Balance sheet strength (debt ratios)

4. Update Section 3: Valuation Analysis (line 75)
   - Fetch valuation metrics with fmp-ratios.sh
   - Compare to industry using screener
   - Show peer comparison workflow

5. Add FMP Data Validation Section
   - Check all API responses for errors
   - Verify 5 years of data (or document why less)
   - Validate financial statement consistency
   - Check data freshness
   - Alert on missing critical fields

**Acceptance Criteria**:
- [x] WebFetch removed from tools
- [x] FMP integration section added
- [x] All analysis sections updated with FMP calls
- [x] 5-year financial data fetching documented
- [x] Ratio calculations using FMP data shown
- [x] Peer comparison workflow documented
- [x] Data validation section added
- [x] Agent can successfully analyze companies

**Implementation Notes**:
- Show comprehensive data fetch at start
- Include trend calculation examples
- Document derived metrics (FCF = OCF - CapEx)
- Show industry comparison methodology

**Testing**:
```bash
# Test with Fundamental Analyst agent on AAPL
# Verify it can:
# 1. Fetch all 3 financial statements (5 years)
# 2. Calculate revenue growth trends
# 3. Analyze profitability margins
# 4. Calculate free cash flow
# 5. Generate bull/bear cases
```

---

## Task 2.3: Update Technical Analyst Agent

**Description**: Modify Technical Analyst to use FMP API for chart and indicator analysis

**Dependencies**: Phase 1 (all helper scripts)

**Effort**: 3 hours

**Files to Modify**:
- `/Users/nazymazimbayev/apex-os-1/.claude/agents/apex-os-technical-analyst.md`

**Implementation Scope**:

Changes required:
1. Update YAML frontmatter (line 4): Remove `WebFetch`
   - After: `tools: Write, Read, Bash`

2. Add FMP Integration Section (after line 20)
   - Required scripts: fmp-quote.sh, fmp-historical.sh, fmp-indicators.sh
   - Standard data fetch pattern
   - Show fetching 500 days of history for reliable calculations

3. Update Section 1: Trend Analysis (line 37)
   - Fetch multi-timeframe data
   - Fetch moving averages (SMA 20/50/200)
   - Calculate trend strength with ADX
   - Identify higher highs/lows from historical data

4. Update Section 2: Support & Resistance (line 59)
   - Extract swing highs/lows from historical data
   - Calculate volume profile
   - Calculate Fibonacci levels from recent range

5. Update Section 5: Technical Indicators (line 128)
   - Fetch momentum indicators (RSI)
   - Show manual Bollinger Bands calculation
   - Document which indicators from FMP vs calculated

**Acceptance Criteria**:
- [x] WebFetch removed from tools
- [x] FMP integration section added
- [x] All analysis sections use FMP data
- [x] 500+ days historical fetch documented
- [x] Moving averages from FMP shown
- [x] Custom indicator calculations documented (Bollinger, Fibonacci)
- [x] Support/resistance calculation from price data shown
- [x] Agent can successfully analyze charts

**Implementation Notes**:
- Document which indicators FMP provides vs manual calculation
- Show swing point identification logic
- Include volume profile calculation approach
- Document Fibonacci calculation from high/low

**Testing**:
```bash
# Test with Technical Analyst agent on AAPL
# Verify it can:
# 1. Fetch 500 days of historical data
# 2. Fetch SMA 20/50/200
# 3. Fetch RSI indicator
# 4. Identify support/resistance levels
# 5. Generate entry/exit/stop levels
```

---

## Task 2.4: Update Portfolio Monitor Agent

**Description**: Modify Portfolio Monitor to use FMP API for position tracking

**Dependencies**: Phase 1 (all helper scripts)

**Effort**: 2.5 hours

**Files to Modify**:
- `/Users/nazymazimbayev/apex-os-1/.claude/agents/apex-os-portfolio-monitor.md`

**Implementation Scope**:

Changes required:
1. YAML frontmatter already correct (no WebFetch), but document FMP usage

2. Add FMP Integration Section (after line 20)
   - Required scripts: fmp-quote.sh (batch), fmp-historical.sh
   - Batch quote pattern for all positions
   - Show extracting symbols from open-positions.yaml

3. Update Step 2: Check Current Prices (line 42)
   - Fetch batch quotes for all positions
   - Parse each position and calculate metrics
   - Show days held, % change, distance to stop/target

4. Update Step 3: Evaluate Thesis Validity (line 51)
   - Check for news events (if fmp-common.sh supports stock_news)
   - Quick fundamental metrics check
   - Technical invalidation check

5. Add FMP Data Quality Section
   - Verify batch quote returned all symbols
   - Check timestamp freshness
   - Validate price movements reasonable
   - Alert if any symbols fail

**Acceptance Criteria**:
- [x] FMP integration section added
- [x] Batch quote workflow documented
- [x] Position metrics calculations shown
- [x] Thesis validity checks use FMP data
- [x] Data quality section added
- [x] Error recovery documented (retry individual quotes if batch fails)
- [x] Agent can successfully monitor portfolio

**Implementation Notes**:
- Show yq usage to extract symbols from YAML
- Demonstrate comma-separated batch quote
- Include position metrics calculations (P&L, days held, etc.)
- Document alerting thresholds

**Testing**:
```bash
# Test with Portfolio Monitor agent
# Create mock open-positions.yaml with 3 positions
# Verify it can:
# 1. Fetch all position quotes in batch
# 2. Calculate metrics for each position
# 3. Compare to stop/target levels
# 4. Generate daily report
```

---

## Phase 3: Testing & Validation

**Goal**: Comprehensive testing of helper scripts and agent integration
**Total Tasks**: 5
**Estimated Effort**: 8-10 hours
**Dependencies**: Phases 1 & 2 complete

---

## Task 3.1: Unit Test Helper Scripts

**Description**: Test each helper script individually with various inputs

**Dependencies**: Phase 1 (all helper scripts created)

**Effort**: 2 hours

**Files to Create**:
- `/Users/nazymazimbayev/apex-os-1/scripts/fmp/test-helpers.sh` (test runner)

**Implementation Scope**:

Test each script with:
1. Valid inputs (happy path)
2. Invalid symbols
3. Missing parameters
4. Edge cases (empty responses, malformed data)

Scripts to test:
- fmp-quote.sh (single, batch, invalid symbol)
- fmp-financials.sh (all 3 types, quarterly/annual)
- fmp-ratios.sh (all 3 types)
- fmp-profile.sh
- fmp-historical.sh (daily, intraday, date ranges)
- fmp-screener.sh (market movers, custom filters)
- fmp-indicators.sh (all indicator types)

**Acceptance Criteria**:
- [x] All scripts handle valid inputs correctly
- [x] All scripts return proper error JSON for invalid inputs
- [x] Symbol validation works across all scripts
- [x] Rate limiting doesn't cause failures
- [x] All scripts executable and return valid JSON
- [x] Test suite documents passing/failing tests

**Implementation Notes**:
- Create test script that calls each helper
- Validate JSON responses with jq
- Check error responses have correct format
- Document any failures for fixing

**Testing**:
```bash
# Run test suite
bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/test-helpers.sh

# Expected output:
# Testing fmp-quote.sh... PASS
# Testing fmp-financials.sh... PASS
# Testing fmp-ratios.sh... PASS
# ... etc
```

---

## Task 3.2: Integration Test Agents

**Description**: Test each agent's ability to use FMP scripts successfully

**Dependencies**: Phase 2 (all agents updated)

**Effort**: 3 hours

**Files to Create**:
- Test cases document: `/Users/nazymazimbayev/apex-os-1/scripts/fmp/agent-test-cases.md`

**Implementation Scope**:

Test each agent:

1. **Market Scanner Agent**
   - Run opportunity scan
   - Verify uses fmp-screener.sh
   - Verify creates opportunity documents
   - Check data quality in outputs

2. **Fundamental Analyst Agent**
   - Analyze AAPL
   - Verify fetches all 3 statements
   - Verify calculates trends
   - Check report completeness

3. **Technical Analyst Agent**
   - Analyze AAPL
   - Verify fetches historical data
   - Verify fetches indicators
   - Check entry/exit levels generated

4. **Portfolio Monitor Agent**
   - Create mock portfolio (AAPL, MSFT, GOOGL)
   - Run daily monitoring
   - Verify batch quotes work
   - Check metrics calculations

**Acceptance Criteria**:
- [x] Market Scanner successfully scans and documents opportunities
- [x] Fundamental Analyst produces complete analysis with FMP data
- [x] Technical Analyst produces complete analysis with indicators
- [x] Portfolio Monitor tracks positions and generates alerts
- [x] No WebFetch calls in any agent
- [x] All FMP API calls successful
- [x] Error handling works (test with invalid symbol)

**Implementation Notes**:
- Run each agent manually with test inputs
- Verify output documents contain FMP-sourced data
- Check logs for any errors or warnings
- Document any issues found

**Testing**:
Each agent tested with real API calls and verified outputs.

---

## Task 3.3: End-to-End Workflow Testing

**Description**: Test complete investment workflow from scan to monitoring

**Dependencies**: Task 3.2 (agents integration tested)

**Effort**: 2 hours

**Implementation Scope**:

Complete workflow:
1. Market Scanner → identifies opportunities
2. Fundamental Analyst → analyzes opportunity
3. Technical Analyst → analyzes opportunity
4. Simulate position entry → add to portfolio
5. Portfolio Monitor → tracks position

**Acceptance Criteria**:
- [x] Complete workflow executes without errors
- [x] Data flows between agents correctly
- [x] All outputs use FMP-sourced data
- [x] Opportunity document → analysis reports → portfolio tracking chain works
- [x] No data inconsistencies between agents
- [x] Rate limiting doesn't cause failures during sequential agent runs

**Implementation Notes**:
- Use single test symbol (e.g., AAPL) through entire workflow
- Verify consistency of data between agents
- Check portfolio YAML correctly updated
- Verify monitoring report references correct entry data

**Testing**:
```bash
# 1. Run Market Scanner
# 2. Pick one opportunity from output
# 3. Run Fundamental Analyst on that symbol
# 4. Run Technical Analyst on that symbol
# 5. Manually add position to open-positions.yaml
# 6. Run Portfolio Monitor
# 7. Verify all steps completed successfully
```

---

## Task 3.4: Error Scenario Testing

**Description**: Test error handling across all components

**Dependencies**: Tasks 3.1, 3.2

**Effort**: 2 hours

**Implementation Scope**:

Test error scenarios:
1. Invalid API key (.env missing or wrong key)
2. Invalid symbols (e.g., "INVALID123")
3. Rate limit exceeded (429 response) - simulate with rapid calls
4. Network timeout (slow connection)
5. Malformed JSON response (simulate)
6. Missing required fields in response
7. Empty response arrays

**Acceptance Criteria**:
- [x] All errors return standard JSON format
- [x] Agents handle errors gracefully (don't crash)
- [x] Error messages are user-friendly
- [x] Retry logic works for transient errors (429, 500)
- [x] No retry for permanent errors (400, 401, 404)
- [x] Rate limiting prevents 429 errors under normal usage
- [x] All error types documented

**Implementation Notes**:
- Test with intentionally invalid inputs
- Monitor error logs
- Verify retry logic with rate limit scenario
- Check agents continue after errors

**Testing**:
```bash
# Test invalid symbol
bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-quote.sh INVALID999

# Test missing API key
mv .env .env.backup
bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-quote.sh AAPL
mv .env.backup .env

# Simulate rate limit (make 250+ calls rapidly)
for i in {1..260}; do
  bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-quote.sh AAPL >/dev/null &
done
wait
```

---

## Task 3.5: Performance Testing

**Description**: Verify performance benchmarks are met

**Dependencies**: Tasks 3.2, 3.3

**Effort**: 1 hour

**Implementation Scope**:

Performance benchmarks from requirements:
- Market Scanner: <3 min per scan
- Fundamental Analyst: <2 min data fetch
- Technical Analyst: <2 min data fetch
- Portfolio Monitor: <1 min daily report

API call efficiency:
- Market Scanner: <20 FMP calls per scan
- Fundamental Analyst: <15 FMP calls per analysis
- Technical Analyst: <10 FMP calls per analysis
- Portfolio Monitor: 1 batch call + minimal per-position calls

**Acceptance Criteria**:
- [x] Market Scanner completes in <3 minutes
- [x] Fundamental Analyst data fetch in <2 minutes
- [x] Technical Analyst data fetch in <2 minutes
- [x] Portfolio Monitor completes in <1 minute
- [x] API call counts within limits
- [x] No rate limit errors during normal workflows
- [x] Performance meets or exceeds benchmarks

**Implementation Notes**:
- Use `time` command to measure execution
- Count API calls with rate limit tracker
- Test with realistic data (multiple symbols, full scans)

**Testing**:
```bash
# Time Market Scanner
time <run market scanner agent>

# Time Fundamental Analyst (data fetch only)
time bash -c "
  fmp-profile.sh AAPL
  fmp-financials.sh AAPL income 5 annual
  fmp-financials.sh AAPL balance 5 annual
  fmp-financials.sh AAPL cashflow 5 annual
  fmp-ratios.sh AAPL ratios 5
  fmp-ratios.sh AAPL metrics 5
  fmp-ratios.sh AAPL growth 5
"

# Count API calls
grep -r "fmp_api_call" /tmp/fmp_rate_*.txt | wc -l
```

---

## Phase 4: Documentation

**Goal**: Create user-facing documentation
**Total Tasks**: 3
**Estimated Effort**: 4-5 hours
**Dependencies**: Phase 3 (testing complete)

---

## Task 4.1: Update Main README

**Description**: Update project README to document FMP integration

**Dependencies**: All previous phases complete

**Effort**: 1.5 hours

**Files to Modify**:
- `/Users/nazymazimbayev/apex-os-1/README.md` (if exists) or create new

**Implementation Scope**:

Add/update sections:
1. Prerequisites - FMP API key requirement
2. Setup - How to configure .env with API key
3. Helper Scripts - Reference to `/scripts/fmp/README.md`
4. Agent Updates - Note that agents now use FMP instead of WebFetch
5. Data Sources - Document FMP as primary financial data provider

**Acceptance Criteria**:
- [ ] FMP API key requirement documented
- [ ] Setup instructions clear and complete
- [ ] Links to helper scripts README
- [ ] Agent capabilities updated to reflect FMP data
- [ ] Data source attribution included

**Implementation Notes**:
- Keep high-level, details in scripts/fmp/README.md
- Include link to FMP documentation
- Note rate limits and subscription requirements

---

## Task 4.2: Create Migration Guide

**Description**: Document migration from WebFetch to FMP for future reference

**Dependencies**: All previous phases complete

**Effort**: 2 hours

**Files to Create**:
- `/Users/nazymazimbayev/apex-os-1/docs/fmp-migration-guide.md`

**Implementation Scope**:

Document:
1. Why migration was done
2. Before/after comparison for each agent
3. Key changes made
4. Benefits realized
5. Lessons learned
6. Troubleshooting common issues

**Acceptance Criteria**:
- [ ] Migration rationale documented
- [ ] Before/after examples for all 4 agents
- [ ] Technical changes summarized
- [ ] Benefits quantified (speed, reliability, data richness)
- [ ] Lessons learned captured
- [ ] Troubleshooting section included

**Implementation Notes**:
- Include code snippets showing before/after
- Document performance improvements
- Note any challenges encountered
- Useful for future API migrations

---

## Task 4.3: Create Troubleshooting Guide

**Description**: Document common issues and solutions

**Dependencies**: Task 3.4 (error testing complete)

**Effort**: 1.5 hours

**Files to Create**:
- `/Users/nazymazimbayev/apex-os-1/docs/fmp-troubleshooting.md`

**Implementation Scope**:

Common issues to document:
1. API key errors (missing, invalid, expired)
2. Rate limit errors (429 responses)
3. Invalid symbol errors (404 responses)
4. Network timeout issues
5. Missing data (empty arrays)
6. Data staleness warnings
7. Script permission errors
8. jq parsing errors

For each issue:
- Symptoms
- Root cause
- Solution
- Prevention

**Acceptance Criteria**:
- [ ] All error types from Task 3.4 documented
- [ ] Solutions provided for each issue
- [ ] Prevention strategies included
- [ ] Example error messages shown
- [ ] Debugging tips included
- [ ] FAQ section included

**Implementation Notes**:
- Use real error messages from testing
- Include command examples for debugging
- Link to relevant documentation
- Provide quick fixes for common issues

---

## Summary & Execution Plan

### Phase Execution Order

1. **Phase 1: Helper Scripts** (Sequential dependencies within phase)
   - Task 1.1 MUST complete first (fmp-common.sh)
   - Tasks 1.2-1.8 can run in parallel after 1.1
   - Task 1.9 completes after all scripts done

2. **Phase 2: Agent Modifications** (Parallel after Phase 1)
   - All 4 agent updates can be done in parallel
   - Each requires Phase 1 complete

3. **Phase 3: Testing** (Sequential)
   - Task 3.1 → 3.2 → 3.3 → 3.4 → 3.5

4. **Phase 4: Documentation** (Parallel after Phase 3)
   - All 3 documentation tasks can be done in parallel

### Critical Path

1. Task 1.1 (fmp-common.sh) - **3 hours**
2. Tasks 1.2-1.8 (helper scripts) - **12 hours** (can parallelize)
3. Task 1.9 (scripts README) - **1.5 hours**
4. Tasks 2.1-2.4 (agent updates) - **12 hours** (can parallelize)
5. Tasks 3.1-3.5 (testing) - **10 hours** (sequential)
6. Tasks 4.1-4.3 (docs) - **5 hours** (can parallelize)

**Total Estimated Effort**: 43.5 hours (serial execution)
**Optimized Effort**: ~28 hours (with parallelization)

### Success Criteria Checklist

Before marking project complete:

**Functionality**:
- [ ] All 8 helper scripts created and working
- [ ] All 4 agents updated (WebFetch removed)
- [ ] All agents successfully use FMP data
- [ ] End-to-end workflow tested and working

**Performance**:
- [ ] Market Scanner: <3 min
- [ ] Fundamental Analyst: <2 min
- [ ] Technical Analyst: <2 min
- [ ] Portfolio Monitor: <1 min

**Quality**:
- [ ] Standard error handling across all scripts
- [ ] Rate limiting prevents 429 errors
- [ ] All error scenarios tested
- [ ] Data validation in place

**Documentation**:
- [ ] Helper scripts README complete
- [ ] Main README updated
- [ ] Migration guide created
- [ ] Troubleshooting guide created

### Risk Mitigation

**Risk**: Rate limit issues during testing
- **Mitigation**: Implement rate limiting early (Task 1.1), test with delays

**Risk**: API changes or unavailability
- **Mitigation**: Implement robust error handling, retry logic

**Risk**: Data quality issues
- **Mitigation**: Comprehensive validation in Task 3.2, 3.3

**Risk**: Performance issues with large data sets
- **Mitigation**: Performance testing in Task 3.5, optimize if needed

---

**End of Task List**
