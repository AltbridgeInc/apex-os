# FMP Integration Requirements

**Project**: APEX-OS Financial Modeling Prep API Integration
**Date**: 2025-11-11
**Status**: Requirements Documentation
**FMP API Key**: SZXOMqlwN2RRrx5bBjDjkxzZpSBvTlHF (configured in .env)

---

## 1. Executive Summary

This document specifies the requirements for migrating APEX-OS from generic WebFetch/WebSearch tools to direct Financial Modeling Prep (FMP) API integration using Bash/curl commands.

**Scope**: Four agents will be modified to use FMP's comprehensive financial data API:
- Market Scanner Agent (identify opportunities)
- Fundamental Analyst Agent (financial analysis)
- Technical Analyst Agent (chart/indicator analysis)
- Portfolio Monitor Agent (real-time price tracking)

**Approach**: Replace WebFetch calls with direct FMP API calls via Bash tool using curl, supported by reusable helper scripts in `/scripts/fmp/`.

**Benefits**:
- Faster, more reliable data access
- Structured JSON responses (no HTML parsing)
- Rich financial dataset (statements, ratios, fundamentals, technicals)
- Rate limit awareness and error handling
- No web scraping brittleness

---

## 2. Current State Analysis

### 2.1 Agent Inventory

**Agents Using WebFetch** (line 4 in agent YAML frontmatter):

1. `.claude/agents/apex-os-market-scanner.md`
   - **Current**: Uses WebFetch for screening opportunities
   - **Data Needed**: Stock screeners, market movers, earnings calendar, sector performance
   - **Workflow**: Scans multiple sources → filters → creates opportunity documents

2. `.claude/agents/apex-os-fundamental-analyst.md`
   - **Current**: Uses WebFetch for financial data
   - **Data Needed**: Financial statements, ratios, company profiles, SEC filings, competitive data
   - **Workflow**: Financial analysis → competitive moat → valuation → bull/bear cases

3. `.claude/agents/apex-os-technical-analyst.md`
   - **Current**: Uses WebFetch for chart data
   - **Data Needed**: Historical prices, technical indicators, volume data, moving averages
   - **Workflow**: Trend analysis → S/R levels → patterns → entry/exit levels

4. `.claude/agents/apex-os-portfolio-monitor.md`
   - **Current**: Uses only Write, Read, Bash
   - **Addition Needed**: Add FMP calls for real-time price updates
   - **Data Needed**: Real-time quotes, price changes, volume

### 2.2 Current WebFetch Usage Patterns

**Generic Pattern**:
```markdown
tools: Write, Read, Bash, WebFetch
```

**Implicit Behavior**:
- Agents would use WebFetch to fetch financial websites
- Parse HTML/markdown content
- Extract relevant financial data
- Process and analyze

**Problems**:
- Slow (HTML parsing)
- Unreliable (website structure changes)
- Limited data depth
- No structured responses
- Rate limiting issues

---

## 3. Target State

### 3.1 Agent Tool Configuration

**Update all four agents' YAML frontmatter**:
```yaml
tools: Write, Read, Bash
```

Remove `WebFetch` from tools list - all data fetching done via Bash/curl.

### 3.2 FMP API Integration Pattern

**Standard Pattern for All Agents**:

1. Source helper scripts from `/scripts/fmp/fmp-common.sh`
2. Call specific FMP helper scripts for data needs
3. Parse JSON responses using `jq`
4. Handle errors gracefully with standardized error messages
5. Cache API key from `.env` (FMP_API_KEY)

**Example Usage**:
```bash
# In agent workflow
source /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-common.sh
quote_data=$(get_fmp_quote "AAPL")
echo "$quote_data" | jq -r '.price'
```

### 3.3 Data Flow Architecture

```
Agent Need → Helper Script → FMP API → JSON Response → jq Parsing → Agent Analysis
```

**Error Flow**:
```
FMP API Error → fmp-common.sh error handler → Standardized error message → Agent retry/fallback logic
```

---

## 4. FMP API Endpoint Mapping

### 4.1 Market Scanner Agent

**Purpose**: Identify investment opportunities from multiple sources

**FMP Endpoints Required**:

1. **Stock Screener API**
   - Endpoint: `https://financialmodelingprep.com/api/v3/stock-screener`
   - Parameters: `marketCapMoreThan`, `betaMoreThan`, `volumeMoreThan`, `sector`, `exchange`, `limit`
   - Use Case: Technical and fundamental screening
   - Example: Find stocks with revenue growth >10%, positive net income, volume >500k

2. **Market Movers - Gainers**
   - Endpoint: `https://financialmodelingprep.com/api/v3/stock_market/gainers`
   - Parameters: None (returns top gainers)
   - Use Case: Identify momentum opportunities

3. **Market Movers - Most Active**
   - Endpoint: `https://financialmodelingprep.com/api/v3/stock_market/actives`
   - Parameters: None (returns most active by volume)
   - Use Case: Find high-volume opportunities

4. **Earnings Calendar**
   - Endpoint: `https://financialmodelingprep.com/api/v3/earnings_calendar`
   - Parameters: `from`, `to` (date range)
   - Use Case: Track upcoming catalysts

5. **Sector Performance**
   - Endpoint: `https://financialmodelingprep.com/api/v3/sectors-performance`
   - Parameters: None
   - Use Case: Identify strong/weak sectors

6. **Stock News**
   - Endpoint: `https://financialmodelingprep.com/api/v3/stock_news`
   - Parameters: `tickers`, `limit`
   - Use Case: News catalyst monitoring

7. **Analyst Estimates**
   - Endpoint: `https://financialmodelingprep.com/api/v3/analyst-estimates/{symbol}`
   - Parameters: `limit`
   - Use Case: Analyst upgrade/downgrade tracking

**Data Processing**:
- Filter results by liquidity (volume >500k)
- Filter by price (>$10)
- Combine multiple sources for comprehensive scanning
- Rank by signal strength

### 4.2 Fundamental Analyst Agent

**Purpose**: Deep financial and competitive analysis

**FMP Endpoints Required**:

1. **Company Profile**
   - Endpoint: `https://financialmodelingprep.com/api/v3/profile/{symbol}`
   - Use Case: Company overview, sector, industry, market cap, description

2. **Income Statement**
   - Endpoint: `https://financialmodelingprep.com/api/v3/income-statement/{symbol}`
   - Parameters: `limit=5` (5 years), `period=annual`
   - Use Case: Revenue, profit margins, earnings analysis

3. **Balance Sheet**
   - Endpoint: `https://financialmodelingprep.com/api/v3/balance-sheet-statement/{symbol}`
   - Parameters: `limit=5`, `period=annual`
   - Use Case: Assets, liabilities, debt analysis, cash position

4. **Cash Flow Statement**
   - Endpoint: `https://financialmodelingprep.com/api/v3/cash-flow-statement/{symbol}`
   - Parameters: `limit=5`, `period=annual`
   - Use Case: Operating cash flow, free cash flow, CapEx

5. **Financial Ratios**
   - Endpoint: `https://financialmodelingprep.com/api/v3/ratios/{symbol}`
   - Parameters: `limit=5`
   - Use Case: P/E, P/S, debt-to-equity, current ratio, ROE, ROA

6. **Key Metrics**
   - Endpoint: `https://financialmodelingprep.com/api/v3/key-metrics/{symbol}`
   - Parameters: `limit=5`
   - Use Case: Revenue per share, net income per share, P/B, PEG, Graham number

7. **Financial Growth**
   - Endpoint: `https://financialmodelingprep.com/api/v3/financial-growth/{symbol}`
   - Parameters: `limit=5`
   - Use Case: Revenue growth %, earnings growth %, asset growth %

8. **Company Rating**
   - Endpoint: `https://financialmodelingprep.com/api/v3/rating/{symbol}`
   - Use Case: FMP's proprietary quality score

9. **Analyst Recommendations**
   - Endpoint: `https://financialmodelingprep.com/api/v3/analyst-stock-recommendations/{symbol}`
   - Use Case: Buy/hold/sell consensus

10. **Price Target**
    - Endpoint: `https://financialmodelingprep.com/api/v4/price-target`
    - Parameters: `symbol`
    - Use Case: Analyst price targets

11. **Enterprise Value**
    - Endpoint: `https://financialmodelingprep.com/api/v3/enterprise-values/{symbol}`
    - Parameters: `limit=5`
    - Use Case: EV/EBITDA, EV/Sales calculations

12. **Insider Trading**
    - Endpoint: `https://financialmodelingprep.com/api/v4/insider-trading`
    - Parameters: `symbol`
    - Use Case: Management insider buying/selling

13. **Institutional Ownership**
    - Endpoint: `https://financialmodelingprep.com/api/v3/institutional-holder/{symbol}`
    - Use Case: Institutional investor positions

**Data Processing**:
- Calculate 5-year trends for all financial metrics
- Compare ratios to industry medians
- Compute derived metrics (free cash flow, margins)
- Generate bull/bear scenario probabilities

### 4.3 Technical Analyst Agent

**Purpose**: Chart analysis, pattern recognition, entry/exit timing

**FMP Endpoints Required**:

1. **Real-Time Quote**
   - Endpoint: `https://financialmodelingprep.com/api/v3/quote/{symbol}`
   - Use Case: Current price, day change, volume

2. **Historical Daily Prices**
   - Endpoint: `https://financialmodelingprep.com/api/v3/historical-price-full/{symbol}`
   - Parameters: `from`, `to` (date range)
   - Use Case: Daily OHLCV data for charting, up to 20 years

3. **Intraday Prices**
   - Endpoint: `https://financialmodelingprep.com/api/v3/historical-chart/5min/{symbol}`
   - Parameters: Time intervals (1min, 5min, 15min, 30min, 1hour)
   - Use Case: Intraday patterns, entry timing

4. **Technical Indicators - SMA**
   - Endpoint: `https://financialmodelingprep.com/api/v3/technical_indicator/daily/{symbol}`
   - Parameters: `type=sma`, `period=50`
   - Use Case: 20/50/200-day moving averages

5. **Technical Indicators - EMA**
   - Endpoint: `https://financialmodelingprep.com/api/v3/technical_indicator/daily/{symbol}`
   - Parameters: `type=ema`, `period=20`
   - Use Case: Exponential moving averages

6. **Technical Indicators - RSI**
   - Endpoint: `https://financialmodelingprep.com/api/v3/technical_indicator/daily/{symbol}`
   - Parameters: `type=rsi`, `period=14`
   - Use Case: Overbought/oversold conditions

7. **Technical Indicators - ADX**
   - Endpoint: `https://financialmodelingprep.com/api/v3/technical_indicator/daily/{symbol}`
   - Parameters: `type=adx`, `period=14`
   - Use Case: Trend strength measurement

8. **Technical Indicators - Williams %R**
   - Endpoint: `https://financialmodelingprep.com/api/v3/technical_indicator/daily/{symbol}`
   - Parameters: `type=williams`, `period=14`
   - Use Case: Momentum indicator

9. **Support and Resistance Levels** (if available)
   - Endpoint: Check FMP API documentation
   - Fallback: Calculate from historical price data

**Data Processing**:
- Download sufficient historical data for pattern recognition
- Calculate custom indicators not provided by FMP (Fibonacci levels, volume profile)
- Identify swing highs/lows for S/R levels
- Detect chart patterns algorithmically
- Generate entry/exit/stop levels

**Technical Indicator Strategy**:
- Use FMP pre-calculated indicators when available (SMA, EMA, RSI, ADX)
- Calculate custom indicators from historical data when needed (Fibonacci, Bollinger Bands, volume patterns)
- Fetch sufficient history (500+ days) for reliable calculations

### 4.4 Portfolio Monitor Agent

**Purpose**: Track open positions, monitor thesis validity, generate alerts

**FMP Endpoints Required**:

1. **Real-Time Quote (Batch)**
   - Endpoint: `https://financialmodelingprep.com/api/v3/quote/{symbol1},{symbol2},{symbol3}`
   - Use Case: Fetch all open position prices in single call
   - Frequency: Daily (or multiple times per day)

2. **Historical Daily Prices (Recent)**
   - Endpoint: `https://financialmodelingprep.com/api/v3/historical-price-full/{symbol}`
   - Parameters: `from={entry_date}`, `to={today}`
   - Use Case: Track price movement since entry

3. **Stock News (Position-Specific)**
   - Endpoint: `https://financialmodelingprep.com/api/v3/stock_news`
   - Parameters: `tickers={symbol}`, `limit=10`
   - Use Case: Monitor news affecting thesis validity

4. **Key Metrics (Quick Check)**
   - Endpoint: `https://financialmodelingprep.com/api/v3/key-metrics/{symbol}`
   - Parameters: `limit=1` (most recent)
   - Use Case: Quick fundamental health check

5. **Analyst Recommendations (Change Detection)**
   - Endpoint: `https://financialmodelingprep.com/api/v3/analyst-stock-recommendations/{symbol}`
   - Use Case: Detect rating changes that might affect thesis

**Data Processing**:
- Compare current price to entry, stop, target levels
- Calculate days held, % change, P&L
- Check for thesis invalidation triggers
- Calculate portfolio-level metrics (heat, sector exposure)
- Generate alerts based on thresholds

---

## 5. Helper Scripts Specification

All scripts located in: `/Users/nazymazimbayev/apex-os-1/scripts/fmp/`

### 5.1 fmp-common.sh

**Purpose**: Shared functions used by all FMP scripts

**Functions**:

```bash
# Load API key from .env
load_api_key() {
  # Source /Users/nazymazimbayev/apex-os-1/.env
  # Export FMP_API_KEY
  # Return 1 if not found
}

# Make FMP API call with error handling
fmp_api_call() {
  # Args: $1=endpoint_path, $2=optional_params
  # Returns: JSON response or error message
  # Handles: HTTP errors, rate limits, timeouts
  # Uses: curl with timeout, retry logic
}

# Parse JSON with error handling
parse_json() {
  # Args: $1=json_string, $2=jq_filter
  # Returns: Parsed value or error
  # Handles: Invalid JSON, missing fields
}

# Error message formatter
format_error() {
  # Args: $1=error_type, $2=message
  # Returns: Standardized error JSON
  # Format: {"error": true, "type": "...", "message": "..."}
}

# Validate symbol
validate_symbol() {
  # Args: $1=symbol
  # Returns: 0 if valid, 1 if invalid
  # Checks: Not empty, uppercase, alphanumeric
}

# Rate limit handler
check_rate_limit() {
  # Track API calls per minute
  # Sleep if approaching limit (250/min for paid tier)
}
```

**Error Handling Standards**:
- All errors return JSON format: `{"error": true, "type": "rate_limit|http_error|invalid_response|missing_data", "message": "description"}`
- HTTP error codes mapped to user-friendly messages
- Rate limit errors include retry-after suggestion
- Network timeouts set to 30 seconds
- Retry logic: 3 attempts with exponential backoff

**API Key Security**:
- Never log API key
- Load from .env only
- Validate key exists before making calls

### 5.2 fmp-quote.sh

**Purpose**: Real-time stock quotes

**Usage**:
```bash
./fmp-quote.sh AAPL
./fmp-quote.sh "AAPL,MSFT,GOOGL"  # Batch quotes
```

**Output** (JSON):
```json
{
  "symbol": "AAPL",
  "price": 175.43,
  "change": 2.15,
  "changesPercentage": 1.24,
  "dayLow": 173.50,
  "dayHigh": 176.00,
  "yearHigh": 199.62,
  "yearLow": 124.17,
  "marketCap": 2750000000000,
  "volume": 65432100,
  "avgVolume": 55000000,
  "open": 174.00,
  "previousClose": 173.28,
  "timestamp": 1699648800
}
```

**FMP Endpoint**: `GET /v3/quote/{symbol}`

**Features**:
- Single or batch quotes (comma-separated)
- Error handling for invalid symbols
- Timestamp validation (market hours check)

### 5.3 fmp-financials.sh

**Purpose**: Financial statements (income, balance sheet, cash flow)

**Usage**:
```bash
./fmp-financials.sh AAPL income 5 annual
./fmp-financials.sh AAPL balance 5 annual
./fmp-financials.sh AAPL cashflow 5 quarterly
```

**Parameters**:
- `$1`: Symbol
- `$2`: Statement type (income|balance|cashflow)
- `$3`: Limit (number of periods, default 5)
- `$4`: Period (annual|quarterly, default annual)

**Output** (JSON array):
```json
[
  {
    "date": "2023-09-30",
    "symbol": "AAPL",
    "reportedCurrency": "USD",
    "revenue": 383285000000,
    "costOfRevenue": 214137000000,
    "grossProfit": 169148000000,
    "grossProfitRatio": 0.4414,
    "operatingIncome": 114301000000,
    "netIncome": 96995000000,
    ...
  },
  ...
]
```

**FMP Endpoints**:
- Income: `GET /v3/income-statement/{symbol}?limit={limit}&period={period}`
- Balance: `GET /v3/balance-sheet-statement/{symbol}?limit={limit}&period={period}`
- Cash Flow: `GET /v3/cash-flow-statement/{symbol}?limit={limit}&period={period}`

**Features**:
- Validate statement type
- Default to 5 years annual if not specified
- Return sorted by date (newest first)

### 5.4 fmp-ratios.sh

**Purpose**: Financial ratios and key metrics

**Usage**:
```bash
./fmp-ratios.sh AAPL ratios 5
./fmp-ratios.sh AAPL metrics 5
./fmp-ratios.sh AAPL growth 5
```

**Parameters**:
- `$1`: Symbol
- `$2`: Type (ratios|metrics|growth)
- `$3`: Limit (default 5)

**Output** (JSON array):
```json
[
  {
    "date": "2023-09-30",
    "symbol": "AAPL",
    "currentRatio": 1.07,
    "debtEquityRatio": 1.97,
    "returnOnEquity": 1.72,
    "returnOnAssets": 0.28,
    "priceEarningsRatio": 28.5,
    "priceToBookRatio": 45.6,
    ...
  },
  ...
]
```

**FMP Endpoints**:
- Ratios: `GET /v3/ratios/{symbol}?limit={limit}`
- Metrics: `GET /v3/key-metrics/{symbol}?limit={limit}`
- Growth: `GET /v3/financial-growth/{symbol}?limit={limit}`

### 5.5 fmp-profile.sh

**Purpose**: Company profile and overview

**Usage**:
```bash
./fmp-profile.sh AAPL
```

**Output** (JSON):
```json
{
  "symbol": "AAPL",
  "companyName": "Apple Inc.",
  "price": 175.43,
  "beta": 1.29,
  "volAvg": 55000000,
  "mktCap": 2750000000000,
  "sector": "Technology",
  "industry": "Consumer Electronics",
  "description": "Apple Inc. designs, manufactures...",
  "ceo": "Timothy Cook",
  "website": "https://www.apple.com",
  "country": "US",
  "exchange": "NASDAQ",
  ...
}
```

**FMP Endpoint**: `GET /v3/profile/{symbol}`

### 5.6 fmp-historical.sh

**Purpose**: Historical price data

**Usage**:
```bash
./fmp-historical.sh AAPL 2023-01-01 2023-12-31
./fmp-historical.sh AAPL "" "" 500  # Last 500 days
./fmp-historical.sh AAPL "" "" "" 5min  # Intraday 5-minute
```

**Parameters**:
- `$1`: Symbol
- `$2`: From date (YYYY-MM-DD, optional)
- `$3`: To date (YYYY-MM-DD, optional)
- `$4`: Limit (number of days, optional)
- `$5`: Interval (1min|5min|15min|30min|1hour|4hour|daily, default daily)

**Output** (JSON array):
```json
[
  {
    "date": "2023-12-31",
    "open": 175.00,
    "high": 177.50,
    "low": 174.25,
    "close": 176.43,
    "volume": 65432100,
    "adjClose": 176.43,
    "change": 1.43,
    "changePercent": 0.82
  },
  ...
]
```

**FMP Endpoints**:
- Daily: `GET /v3/historical-price-full/{symbol}?from={from}&to={to}`
- Intraday: `GET /v3/historical-chart/{interval}/{symbol}`

**Features**:
- Flexible date range or limit
- Support for intraday intervals
- Sorted by date (newest first)

### 5.7 fmp-screener.sh

**Purpose**: Stock screening with multiple criteria

**Usage**:
```bash
./fmp-screener.sh --marketCapMoreThan=1000000000 --volumeMoreThan=500000 --sector=Technology --limit=50
./fmp-screener.sh --betaMoreThan=1.5 --exchange=NASDAQ
```

**Parameters** (all optional, passed as --key=value):
- `marketCapMoreThan`, `marketCapLowerThan`
- `priceMoreThan`, `priceLowerThan`
- `betaMoreThan`, `betaLowerThan`
- `volumeMoreThan`, `volumeLowerThan`
- `dividendMoreThan`, `dividendLowerThan`
- `sector`, `industry`, `exchange`
- `limit` (default 100)

**Output** (JSON array):
```json
[
  {
    "symbol": "AAPL",
    "companyName": "Apple Inc.",
    "marketCap": 2750000000000,
    "sector": "Technology",
    "beta": 1.29,
    "price": 175.43,
    "volume": 65432100,
    ...
  },
  ...
]
```

**FMP Endpoint**: `GET /v3/stock-screener?{params}`

**Additional Screener Functions**:
```bash
./fmp-screener.sh --type=gainers      # Top gainers
./fmp-screener.sh --type=losers       # Top losers
./fmp-screener.sh --type=actives      # Most active
```

### 5.8 fmp-indicators.sh

**Purpose**: Technical indicators

**Usage**:
```bash
./fmp-indicators.sh AAPL sma 50 daily
./fmp-indicators.sh AAPL ema 20 daily
./fmp-indicators.sh AAPL rsi 14 daily
./fmp-indicators.sh AAPL adx 14 daily
```

**Parameters**:
- `$1`: Symbol
- `$2`: Indicator type (sma|ema|rsi|macd|adx|williams|stoch)
- `$3`: Period (default 14)
- `$4`: Timeframe (1min|5min|15min|30min|1hour|4hour|daily, default daily)

**Output** (JSON array):
```json
[
  {
    "date": "2023-12-31",
    "sma": 172.45
  },
  ...
]
```

**FMP Endpoint**: `GET /v3/technical_indicator/{timeframe}/{symbol}?type={type}&period={period}`

**Supported Indicators**:
- SMA (Simple Moving Average)
- EMA (Exponential Moving Average)
- RSI (Relative Strength Index)
- MACD (Moving Average Convergence Divergence)
- ADX (Average Directional Index)
- Williams %R
- Stochastic Oscillator

**Custom Calculations** (not available from FMP):
- Bollinger Bands: Calculate from SMA + standard deviation
- Fibonacci levels: Calculate from high/low ranges
- Volume profile: Calculate from historical volume data

---

## 6. Error Handling Requirements

### 6.1 Standard Error Format

**All FMP scripts MUST return errors in this JSON format**:

```json
{
  "error": true,
  "type": "error_category",
  "message": "User-friendly description",
  "details": {
    "http_code": 429,
    "endpoint": "/v3/quote/AAPL",
    "timestamp": "2023-12-31T12:00:00Z"
  }
}
```

**Error Categories**:
- `missing_api_key`: FMP_API_KEY not found in .env
- `invalid_symbol`: Symbol validation failed
- `invalid_params`: Missing or invalid parameters
- `rate_limit`: API rate limit exceeded (429)
- `http_error`: HTTP error (400, 401, 403, 404, 500, etc.)
- `timeout`: Request timeout (>30s)
- `invalid_response`: Non-JSON or malformed response
- `missing_data`: Valid response but missing expected fields
- `network_error`: Network connectivity issue

### 6.2 HTTP Error Code Handling

**Map HTTP codes to user messages**:

- `400 Bad Request`: "Invalid request parameters for {endpoint}"
- `401 Unauthorized`: "FMP API key is invalid or expired"
- `403 Forbidden`: "Access denied - check API subscription tier"
- `404 Not Found`: "Symbol {symbol} not found or endpoint unavailable"
- `429 Too Many Requests`: "Rate limit exceeded - retry after {X} seconds"
- `500 Internal Server Error`: "FMP API server error - retry later"
- `503 Service Unavailable`: "FMP API temporarily unavailable"

### 6.3 Retry Logic

**Automatic retry for transient errors**:

```bash
# Exponential backoff: 1s, 2s, 4s
MAX_RETRIES=3
retry_count=0
while [ $retry_count -lt $MAX_RETRIES ]; do
  response=$(curl ...)
  if [ $? -eq 0 ]; then
    break
  fi
  retry_count=$((retry_count + 1))
  sleep $((2 ** retry_count))
done
```

**Retry on**:
- HTTP 429 (rate limit)
- HTTP 500/503 (server errors)
- Network timeouts
- Connection refused

**Do NOT retry on**:
- 400 (bad request - fix params)
- 401 (unauthorized - fix API key)
- 404 (not found - invalid symbol)

### 6.4 Rate Limit Management

**FMP Rate Limits** (paid tier):
- 250 requests per minute
- 750 requests per hour
- 50,000 requests per day

**Rate Limit Strategy**:
1. Track calls per minute in temp file
2. Sleep if approaching 250/min threshold
3. Log rate limit hits
4. Batch requests when possible (e.g., multi-symbol quotes)

**Implementation**:
```bash
check_rate_limit() {
  local rate_file="/tmp/fmp_rate_limit_$(date +%Y%m%d_%H%M).txt"
  local count=$(wc -l < "$rate_file" 2>/dev/null || echo 0)

  if [ "$count" -ge 240 ]; then
    echo "Approaching rate limit, sleeping 10s..." >&2
    sleep 10
  fi

  echo "$(date +%s)" >> "$rate_file"
}
```

### 6.5 Agent-Level Error Handling

**Agents MUST**:
1. Check for `"error": true` in all FMP responses
2. Log errors for debugging
3. Provide fallback behavior when appropriate
4. Never fail silently - alert user to data issues
5. Include error context in reports (e.g., "Unable to fetch financials for XYZ due to rate limit")

**Example Agent Pattern**:
```bash
quote=$(./scripts/fmp/fmp-quote.sh AAPL)
if echo "$quote" | jq -e '.error' > /dev/null 2>&1; then
  error_msg=$(echo "$quote" | jq -r '.message')
  echo "ERROR: Failed to fetch quote - $error_msg"
  # Fallback or exit
else
  price=$(echo "$quote" | jq -r '.price')
  # Continue with price
fi
```

---

## 7. Data Transformation Requirements

### 7.1 JSON Parsing Standards

**All agents MUST use `jq` for JSON parsing**:

**Basic Extraction**:
```bash
# Single field
price=$(echo "$json" | jq -r '.price')

# Multiple fields
read symbol price change < <(echo "$json" | jq -r '[.symbol, .price, .change] | @tsv')

# Nested field
revenue=$(echo "$json" | jq -r '.[0].revenue')

# Array iteration
echo "$json" | jq -r '.[] | [.date, .revenue, .netIncome] | @tsv'
```

**Error Handling in jq**:
```bash
# Use -e to exit non-zero if result is null/false
price=$(echo "$json" | jq -e -r '.price') || echo "ERROR: Missing price field"

# Provide default value
price=$(echo "$json" | jq -r '.price // 0')
```

### 7.2 Financial Data Transformations

**Revenue Trend Analysis** (5 years):
```bash
# Input: income statement JSON array
# Output: Revenue growth rate calculation

financials=$(./scripts/fmp/fmp-financials.sh AAPL income 5 annual)

# Extract revenues and dates
revenues=$(echo "$financials" | jq -r '.[] | [.date, .revenue] | @tsv')

# Calculate YoY growth (agent logic)
while IFS=$'\t' read -r date revenue; do
  # Compare to previous year
  # Calculate % growth
  # Identify trends
done <<< "$revenues"
```

**Ratio Comparison to Industry** (requires industry median data):
```bash
# Fetch company ratios
ratios=$(./scripts/fmp/fmp-ratios.sh AAPL ratios 1)
company_pe=$(echo "$ratios" | jq -r '.[0].priceEarningsRatio')

# Fetch industry median (via sector performance or screener)
# Compare company_pe to industry_median_pe
# Generate assessment: undervalued/fairly valued/overvalued
```

**Technical Indicator Interpretation**:
```bash
# Fetch RSI
rsi_data=$(./scripts/fmp/fmp-indicators.sh AAPL rsi 14 daily)
rsi=$(echo "$rsi_data" | jq -r '.[0].rsi')

# Interpret
if (( $(echo "$rsi > 70" | bc -l) )); then
  echo "Overbought (RSI: $rsi)"
elif (( $(echo "$rsi < 30" | bc -l) )); then
  echo "Oversold (RSI: $rsi)"
else
  echo "Neutral (RSI: $rsi)"
fi
```

### 7.3 Data Caching Strategy

**Phase 1 (Initial Implementation)**: No caching - fetch fresh every time

**Phase 2 (Future Enhancement)**: Implement caching layer
- Cache quotes for 1 minute
- Cache financials for 24 hours
- Cache historical data for 1 week
- Cache location: `/tmp/fmp_cache/{symbol}_{endpoint}_{timestamp}.json`

**Rationale**: Start simple, add caching if performance becomes issue

### 7.4 Data Validation

**All agents MUST validate**:
1. Symbol exists in response
2. Required fields are not null
3. Numeric fields are valid numbers
4. Dates are in expected format (YYYY-MM-DD)
5. Arrays are not empty when expected to contain data

**Validation Example**:
```bash
validate_financial_data() {
  local json="$1"

  # Check array not empty
  count=$(echo "$json" | jq '. | length')
  if [ "$count" -eq 0 ]; then
    echo "ERROR: No financial data returned"
    return 1
  fi

  # Check required fields
  revenue=$(echo "$json" | jq -e '.[0].revenue')
  if [ $? -ne 0 ]; then
    echo "ERROR: Missing revenue field"
    return 1
  fi

  return 0
}
```

---

## 8. Quality Gate Enhancements

### 8.1 FMP-Specific Validation Checks

**Add to each agent's workflow**:

**Market Scanner Agent**:
- Verify screener returns results (not empty array)
- Validate all required fields exist (symbol, price, volume, marketCap)
- Check liquidity filter applied correctly (volume >500k)
- Verify price filter applied (price >$10)
- Confirm sector/industry fields populated

**Fundamental Analyst Agent**:
- Verify all 3 financial statements fetched successfully
- Check 5-year data available (or explain if less)
- Validate ratio calculations (no division by zero)
- Ensure growth rates computed from valid data points
- Confirm company profile has description and sector

**Technical Analyst Agent**:
- Verify historical data spans requested period
- Check indicators calculated for sufficient data points
- Validate moving average periods match request
- Ensure OHLCV data complete (no missing values)
- Confirm support/resistance levels based on actual price data

**Portfolio Monitor Agent**:
- Verify all position symbols return valid quotes
- Check batch quote response matches requested symbols
- Validate price changes calculated correctly
- Ensure news API returns recent articles (within 7 days)
- Confirm position metrics align with stored entry data

### 8.2 Data Quality Assertions

**Pre-Analysis Checks**:
```bash
# Before analyzing financial data
assert_financial_quality() {
  local json="$1"

  # 1. Check data freshness
  latest_date=$(echo "$json" | jq -r '.[0].date')
  days_old=$(( ($(date +%s) - $(date -d "$latest_date" +%s)) / 86400 ))
  if [ "$days_old" -gt 365 ]; then
    echo "WARNING: Financial data is $days_old days old"
  fi

  # 2. Check for unusual values
  revenue=$(echo "$json" | jq -r '.[0].revenue')
  if [ "$revenue" -eq 0 ]; then
    echo "WARNING: Revenue is zero - may indicate missing data"
  fi

  # 3. Check for consistency
  gross_profit=$(echo "$json" | jq -r '.[0].grossProfit')
  calc_gross=$((revenue - cost_of_revenue))
  # Compare and warn if mismatch
}
```

### 8.3 Alert on Data Issues

**Agents MUST alert when**:
- API returns error (include in report)
- Data is stale (>1 year old for financials)
- Missing expected fields
- Unusual values (zero revenue, negative market cap)
- Inconsistent calculations (gross profit ≠ revenue - COGS)

**Alert Format in Reports**:
```markdown
## Data Quality Alerts

⚠️ WARNING: Financial data for AAPL is 15 months old (last update: 2022-09-30)
⚠️ WARNING: Unable to fetch analyst recommendations due to rate limit
✓ All other data quality checks passed
```

---

## 9. Agent Modification Requirements

### 9.1 Market Scanner Agent

**File**: `.claude/agents/apex-os-market-scanner.md`

**Changes**:

1. **Update YAML frontmatter** (line 4):
   ```yaml
   tools: Write, Read, Bash
   ```
   Remove `WebFetch`.

2. **Add FMP Integration Section** (after line 19):
   ```markdown
   ## FMP API Integration

   Use Financial Modeling Prep API for all market data via helper scripts in `/Users/nazymazimbayev/apex-os-1/scripts/fmp/`.

   **Available Scripts**:
   - `fmp-screener.sh`: Stock screening with multiple criteria
   - `fmp-quote.sh`: Real-time quotes and batch quotes
   - `fmp-profile.sh`: Company profiles

   **Example Usage**:
   ```bash
   # Run momentum scanner
   gainers=$(bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-screener.sh --type=gainers --limit=50)

   # Screen for growth stocks
   growth=$(bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-screener.sh \
     --marketCapMoreThan=1000000000 \
     --volumeMoreThan=500000 \
     --priceMoreThan=10 \
     --limit=100)

   # Get detailed quotes
   quotes=$(bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-quote.sh "AAPL,MSFT,GOOGL")
   ```

   **Error Handling**: Check all responses for `"error": true` and log issues.
   ```

3. **Update Step 1: Run Systematic Scans** (line 22):
   Replace general descriptions with specific FMP API calls:

   ```markdown
   ### Step 1: Run Systematic Scans

   **Technical Screeners** (using FMP):
   ```bash
   # Momentum scanner - top gainers with volume
   bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-screener.sh \
     --type=gainers \
     --volumeMoreThan=500000 \
     --limit=50

   # Volume breakout scanner
   bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-screener.sh \
     --type=actives \
     --priceMoreThan=10 \
     --limit=50
   ```

   **Fundamental Screeners** (using FMP):
   ```bash
   # Growth stocks: large cap, liquid, profitable
   bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-screener.sh \
     --marketCapMoreThan=1000000000 \
     --volumeMoreThan=500000 \
     --priceMoreThan=10 \
     --sector=Technology \
     --limit=100
   ```

   **Catalyst Monitoring** (using FMP):
   ```bash
   # Upcoming earnings (next 7 days)
   today=$(date +%Y-%m-%d)
   next_week=$(date -d "+7 days" +%Y-%m-%d)
   bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-common.sh earnings_calendar "$today" "$next_week"
   ```

   **Sector Performance** (using FMP):
   ```bash
   # Identify hot/cold sectors
   bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-common.sh sector_performance
   ```
   ```

4. **Update Step 2: Initial Filtering** (line 45):
   Add FMP-based validation:

   ```markdown
   ### Step 2: Initial Filtering

   For each identified opportunity, fetch detailed quote and run checks:

   ```bash
   # Get detailed quote
   quote=$(bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-quote.sh "$symbol")

   # Extract metrics
   price=$(echo "$quote" | jq -r '.price')
   volume=$(echo "$quote" | jq -r '.avgVolume')
   market_cap=$(echo "$quote" | jq -r '.marketCap')

   # Apply filters
   # - Liquidity: Avg volume >500k shares/day
   # - Price: >$10 (avoid penny stocks)
   # - Market cap: >$100M (real companies)
   ```

   Then fetch quick fundamentals:
   ```bash
   # Get company profile
   profile=$(bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-profile.sh "$symbol")

   # Get latest financials
   income=$(bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-financials.sh "$symbol" income 1 annual)
   ```
   ```

5. **Add Data Quality Section** (before "Important Constraints"):
   ```markdown
   ## Data Quality Checks

   Before documenting opportunities:
   - Verify FMP API responses contain expected fields
   - Check for stale data (warn if >6 months old)
   - Validate numeric values are reasonable
   - Alert if any API calls fail
   ```

### 9.2 Fundamental Analyst Agent

**File**: `.claude/agents/apex-os-fundamental-analyst.md`

**Changes**:

1. **Update YAML frontmatter** (line 4):
   ```yaml
   tools: Write, Read, Bash
   ```

2. **Add FMP Integration Section** (after line 20):
   ```markdown
   ## FMP API Integration

   Use Financial Modeling Prep API for all financial data.

   **Required Scripts**:
   - `fmp-financials.sh`: Income statement, balance sheet, cash flow
   - `fmp-ratios.sh`: Financial ratios, key metrics, growth metrics
   - `fmp-profile.sh`: Company profile and overview

   **Standard Data Fetch Pattern**:
   ```bash
   SYMBOL="AAPL"
   SCRIPTS_DIR="/Users/nazymazimbayev/apex-os-1/scripts/fmp"

   # Fetch all required data
   profile=$(bash "$SCRIPTS_DIR/fmp-profile.sh" "$SYMBOL")
   income=$(bash "$SCRIPTS_DIR/fmp-financials.sh" "$SYMBOL" income 5 annual)
   balance=$(bash "$SCRIPTS_DIR/fmp-financials.sh" "$SYMBOL" balance 5 annual)
   cashflow=$(bash "$SCRIPTS_DIR/fmp-financials.sh" "$SYMBOL" cashflow 5 annual)
   ratios=$(bash "$SCRIPTS_DIR/fmp-ratios.sh" "$SYMBOL" ratios 5)
   metrics=$(bash "$SCRIPTS_DIR/fmp-ratios.sh" "$SYMBOL" metrics 5)
   growth=$(bash "$SCRIPTS_DIR/fmp-ratios.sh" "$SYMBOL" growth 5)
   ```

   **Parse and Analyze**: Use `jq` to extract fields and calculate trends.
   ```

3. **Update Section 1: Financial Health Analysis** (line 37):
   Replace with FMP-specific data extraction:

   ```markdown
   #### 1. Financial Health Analysis

   **Fetch Financial Statements** (5-year annual):
   ```bash
   income=$(bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-financials.sh "$SYMBOL" income 5 annual)
   balance=$(bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-financials.sh "$SYMBOL" balance 5 annual)
   cashflow=$(bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-financials.sh "$SYMBOL" cashflow 5 annual)
   ```

   **Revenue Analysis**:
   ```bash
   # Extract 5-year revenue
   echo "$income" | jq -r '.[] | [.date, .revenue] | @tsv' | while IFS=$'\t' read -r date revenue; do
     echo "Date: $date, Revenue: $revenue"
     # Calculate YoY growth
     # Identify trends (accelerating/decelerating)
   done
   ```

   **Profitability Analysis**:
   ```bash
   # Extract margin trends
   echo "$income" | jq -r '.[] | [.date, .grossProfitRatio, .operatingIncomeRatio, .netIncomeRatio] | @tsv'

   # Compare to industry (fetch via screener or sector avg)
   ```

   **Cash Flow Analysis**:
   ```bash
   # Calculate free cash flow
   echo "$cashflow" | jq -r '.[] | [.date, .operatingCashFlow, .capitalExpenditure] | @tsv' | \
   while IFS=$'\t' read -r date ocf capex; do
     fcf=$((ocf - capex))
     echo "FCF ($date): $fcf"
   done
   ```

   **Balance Sheet Strength**:
   ```bash
   # Fetch ratios (includes debt-to-equity, current ratio, etc.)
   ratios=$(bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-ratios.sh "$SYMBOL" ratios 1)

   debt_equity=$(echo "$ratios" | jq -r '.[0].debtEquityRatio')
   current_ratio=$(echo "$ratios" | jq -r '.[0].currentRatio')

   # Assess strength
   ```
   ```

4. **Update Section 3: Valuation Analysis** (line 75):
   ```markdown
   #### 3. Valuation Analysis

   **Fetch Valuation Metrics**:
   ```bash
   profile=$(bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-profile.sh "$SYMBOL")
   ratios=$(bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-ratios.sh "$SYMBOL" ratios 1)
   metrics=$(bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-ratios.sh "$SYMBOL" metrics 1)

   # Extract key metrics
   pe_ratio=$(echo "$ratios" | jq -r '.[0].priceEarningsRatio')
   pb_ratio=$(echo "$ratios" | jq -r '.[0].priceToBookRatio')
   peg_ratio=$(echo "$metrics" | jq -r '.[0].pegRatio')
   ```

   **Compare to Industry**:
   ```bash
   # Fetch sector/industry peers
   sector=$(echo "$profile" | jq -r '.sector')
   industry=$(echo "$profile" | jq -r '.industry')

   # Screen for peers in same industry
   peers=$(bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-screener.sh \
     --sector="$sector" \
     --marketCapMoreThan=1000000000 \
     --limit=20)

   # Calculate median P/E, P/S for comparison
   ```
   ```

5. **Add Data Validation Section** (before "Output Format"):
   ```markdown
   ## FMP Data Validation

   Before proceeding with analysis:
   1. Check all API responses for errors
   2. Verify 5 years of data available (or document why less)
   3. Validate financial statement consistency (e.g., assets = liabilities + equity)
   4. Check data freshness (latest fiscal year within 18 months)
   5. Alert on any missing critical fields

   **Validation Script**:
   ```bash
   validate_fmp_data() {
     local json="$1"

     # Check error
     if echo "$json" | jq -e '.error' > /dev/null 2>&1; then
       echo "ERROR: $(echo "$json" | jq -r '.message')"
       return 1
     fi

     # Check array length
     count=$(echo "$json" | jq '. | length')
     if [ "$count" -lt 3 ]; then
       echo "WARNING: Only $count years of data available"
     fi

     return 0
   }
   ```
   ```

### 9.3 Technical Analyst Agent

**File**: `.claude/agents/apex-os-technical-analyst.md`

**Changes**:

1. **Update YAML frontmatter** (line 4):
   ```yaml
   tools: Write, Read, Bash
   ```

2. **Add FMP Integration Section** (after line 20):
   ```markdown
   ## FMP API Integration

   Use Financial Modeling Prep API for all price and technical data.

   **Required Scripts**:
   - `fmp-quote.sh`: Current price and volume
   - `fmp-historical.sh`: Historical OHLCV data
   - `fmp-indicators.sh`: Technical indicators (SMA, EMA, RSI, ADX)

   **Standard Data Fetch**:
   ```bash
   SYMBOL="AAPL"
   SCRIPTS_DIR="/Users/nazymazimbayev/apex-os-1/scripts/fmp"

   # Current quote
   quote=$(bash "$SCRIPTS_DIR/fmp-quote.sh" "$SYMBOL")

   # Historical data (500 days for reliable calculations)
   historical=$(bash "$SCRIPTS_DIR/fmp-historical.sh" "$SYMBOL" "" "" 500)

   # Technical indicators
   sma20=$(bash "$SCRIPTS_DIR/fmp-indicators.sh" "$SYMBOL" sma 20 daily)
   sma50=$(bash "$SCRIPTS_DIR/fmp-indicators.sh" "$SYMBOL" sma 50 daily)
   sma200=$(bash "$SCRIPTS_DIR/fmp-indicators.sh" "$SYMBOL" sma 200 daily)
   rsi=$(bash "$SCRIPTS_DIR/fmp-indicators.sh" "$SYMBOL" rsi 14 daily)
   adx=$(bash "$SCRIPTS_DIR/fmp-indicators.sh" "$SYMBOL" adx 14 daily)
   ```
   ```

3. **Update Section 1: Trend Analysis** (line 37):
   ```markdown
   #### 1. Trend Analysis

   **Fetch Multi-Timeframe Data**:
   ```bash
   # Daily chart (500 days)
   daily=$(bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-historical.sh "$SYMBOL" "" "" 500)

   # Weekly chart (build from daily)
   # Monthly chart (build from daily or fetch longer period)
   ```

   **Fetch Moving Averages**:
   ```bash
   sma20=$(bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-indicators.sh "$SYMBOL" sma 20 daily)
   sma50=$(bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-indicators.sh "$SYMBOL" sma 50 daily)
   sma200=$(bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-indicators.sh "$SYMBOL" sma 200 daily)

   # Extract latest values
   ma20=$(echo "$sma20" | jq -r '.[0].sma')
   ma50=$(echo "$sma50" | jq -r '.[0].sma')
   ma200=$(echo "$sma200" | jq -r '.[0].sma')

   # Get current price
   price=$(bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-quote.sh "$SYMBOL" | jq -r '.price')

   # Compare: is price above/below MAs?
   ```

   **Calculate Trend Strength (ADX)**:
   ```bash
   adx_data=$(bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-indicators.sh "$SYMBOL" adx 14 daily)
   adx=$(echo "$adx_data" | jq -r '.[0].adx')

   if (( $(echo "$adx > 25" | bc -l) )); then
     echo "Strong trend (ADX: $adx)"
   else
     echo "Weak/no trend (ADX: $adx)"
   fi
   ```

   **Identify Higher Highs/Lows** (from historical data):
   ```bash
   # Parse daily data to find swing highs/lows
   echo "$daily" | jq -r '.[] | [.date, .high, .low] | @tsv' | while IFS=$'\t' read -r date high low; do
     # Logic to identify swing points
   done
   ```
   ```

4. **Update Section 2: Support & Resistance** (line 59):
   ```markdown
   #### 2. Support & Resistance Levels

   **Extract Swing Highs/Lows from Historical Data**:
   ```bash
   # Fetch 500 days of history
   historical=$(bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-historical.sh "$SYMBOL" "" "" 500)

   # Identify swing points (simplified logic)
   echo "$historical" | jq -r '.[] | [.date, .high, .low, .volume] | @tsv' | \
   while IFS=$'\t' read -r date high low volume; do
     # Track previous highs/lows
     # Identify swings where high/low is local peak/trough
     # Mark as resistance/support
   done
   ```

   **Calculate Volume Profile** (high volume price areas):
   ```bash
   # Group prices into buckets and sum volume
   echo "$historical" | jq -r '.[] | [.close, .volume] | @tsv' | \
   awk '{price=int($1); vol[$price]+=$2} END {for (p in vol) print p, vol[p]}' | sort -k2 -nr | head -10
   # Top 10 high-volume price levels are strong S/R
   ```

   **Calculate Fibonacci Levels** (from recent range):
   ```bash
   # Find highest high and lowest low in last 100 days
   recent=$(echo "$historical" | jq -r '.[0:100]')
   high=$(echo "$recent" | jq '[.[].high] | max')
   low=$(echo "$recent" | jq '[.[].low] | min')

   # Calculate Fib levels
   range=$(echo "$high - $low" | bc -l)
   fib_236=$(echo "$low + $range * 0.236" | bc -l)
   fib_382=$(echo "$low + $range * 0.382" | bc -l)
   fib_500=$(echo "$low + $range * 0.500" | bc -l)
   fib_618=$(echo "$low + $range * 0.618" | bc -l)
   ```
   ```

5. **Update Section 5: Technical Indicators** (line 128):
   ```markdown
   #### 5. Technical Indicators

   **Fetch Momentum Indicators**:
   ```bash
   rsi=$(bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-indicators.sh "$SYMBOL" rsi 14 daily)
   rsi_value=$(echo "$rsi" | jq -r '.[0].rsi')

   # Interpret
   if (( $(echo "$rsi_value > 70" | bc -l) )); then
     echo "Overbought (RSI: $rsi_value)"
   elif (( $(echo "$rsi_value < 30" | bc -l) )); then
     echo "Oversold (RSI: $rsi_value)"
   fi
   ```

   **Calculate Bollinger Bands** (not in FMP, calculate manually):
   ```bash
   # Get SMA(20) and calculate standard deviation from historical data
   sma20_data=$(bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-indicators.sh "$SYMBOL" sma 20 daily)

   # Extract last 20 closing prices
   closes=$(echo "$historical" | jq -r '.[0:20] | .[].close')

   # Calculate standard deviation (use awk or bc)
   std_dev=$(echo "$closes" | awk '{sum+=$1; sumsq+=$1^2} END {print sqrt(sumsq/NR - (sum/NR)^2)}')

   # Bollinger Bands: SMA ± 2*StdDev
   ```
   ```

### 9.4 Portfolio Monitor Agent

**File**: `.claude/agents/apex-os-portfolio-monitor.md`

**Changes**:

1. **Update YAML frontmatter** (line 4):
   ```yaml
   tools: Write, Read, Bash
   ```
   (No change needed - already doesn't include WebFetch, but document FMP usage)

2. **Add FMP Integration Section** (after line 20):
   ```markdown
   ## FMP API Integration

   Use Financial Modeling Prep API for real-time price tracking.

   **Required Scripts**:
   - `fmp-quote.sh`: Batch quotes for all open positions
   - `fmp-historical.sh`: Price history since entry

   **Batch Quote Pattern**:
   ```bash
   # Assume open positions stored in YAML with symbols
   symbols=$(yq e '.positions[].symbol' /Users/nazymazimbayev/apex-os-1/apex-os/portfolio/open-positions.yaml | paste -sd,)

   # Fetch all quotes in single API call
   quotes=$(bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-quote.sh "$symbols")

   # Parse each position
   echo "$quotes" | jq -r '.[] | [.symbol, .price, .change, .changesPercentage, .volume] | @tsv'
   ```
   ```

3. **Update Step 2: Check Current Prices** (line 42):
   ```markdown
   #### Step 2: Check Current Prices

   **Fetch Batch Quotes** for all open positions:
   ```bash
   # Read open-positions.yaml and extract symbols
   symbols=$(yq e '.positions[].symbol' /Users/nazymazimbayev/apex-os-1/apex-os/portfolio/open-positions.yaml | paste -sd,)

   # Get all quotes (comma-separated)
   all_quotes=$(bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-quote.sh "$symbols")

   # Check for errors
   if echo "$all_quotes" | jq -e '.error' > /dev/null 2>&1; then
     echo "ERROR: Failed to fetch quotes - $(echo "$all_quotes" | jq -r '.message')"
     exit 1
   fi
   ```

   **For each position**:
   ```bash
   echo "$all_quotes" | jq -c '.[]' | while read -r quote; do
     symbol=$(echo "$quote" | jq -r '.symbol')
     current_price=$(echo "$quote" | jq -r '.price')
     change_pct=$(echo "$quote" | jq -r '.changesPercentage')

     # Read position entry data from YAML
     entry_price=$(yq e ".positions[] | select(.symbol == \"$symbol\") | .entry_price" open-positions.yaml)
     entry_date=$(yq e ".positions[] | select(.symbol == \"$symbol\") | .entry_date" open-positions.yaml)
     stop_loss=$(yq e ".positions[] | select(.symbol == \"$symbol\") | .stop_loss" open-positions.yaml)
     target1=$(yq e ".positions[] | select(.symbol == \"$symbol\") | .target1" open-positions.yaml)

     # Calculate metrics
     pct_change=$(echo "scale=2; ($current_price - $entry_price) / $entry_price * 100" | bc)
     dist_to_stop=$(echo "scale=2; ($current_price - $stop_loss) / $current_price * 100" | bc)
     dist_to_target=$(echo "scale=2; ($target1 - $current_price) / $current_price * 100" | bc)

     # Calculate days held
     days_held=$(( ($(date +%s) - $(date -d "$entry_date" +%s)) / 86400 ))

     echo "Position: $symbol"
     echo "  Current: $$current_price ($pct_change% from entry)"
     echo "  Days held: $days_held"
     echo "  Stop: $$stop_loss ($dist_to_stop% away)"
     echo "  Target 1: $$target1 ($dist_to_target% away)"
   done
   ```
   ```

4. **Update Step 3: Evaluate Thesis Validity** (line 51):
   Add FMP-based checks:

   ```markdown
   #### Step 3: Evaluate Thesis Validity

   **Check for News Events** affecting position:
   ```bash
   # For each position symbol
   news=$(bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-common.sh stock_news "$symbol" 10)

   # Parse headlines
   echo "$news" | jq -r '.[] | [.publishedDate, .title] | @tsv' | while IFS=$'\t' read -r date title; do
     echo "News ($date): $title"
     # Flag if negative keywords: "downgrade", "recall", "lawsuit", "investigation"
   done
   ```

   **Check Quick Fundamental Metrics** (has anything deteriorated?):
   ```bash
   # Get latest key metrics
   metrics=$(bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-ratios.sh "$symbol" metrics 1)

   # Compare to thesis expectations
   # E.g., if thesis assumed P/E < 20, check current P/E
   ```

   **Technical Invalidation Check**:
   ```bash
   # Compare current price to invalidation level from position-plan.md
   invalidation_price=$(yq e ".positions[] | select(.symbol == \"$symbol\") | .invalidation_level" open-positions.yaml)

   if (( $(echo "$current_price < $invalidation_price" | bc -l) )); then
     echo "⚠️ ALERT: $symbol broke invalidation level!"
     # Generate ACTION REQUIRED alert
   fi
   ```
   ```

5. **Add Data Quality Section** (before "Important Constraints"):
   ```markdown
   ## FMP Data Quality for Monitoring

   **Pre-Monitoring Checks**:
   1. Verify batch quote returned data for ALL open positions
   2. Check quote timestamps are recent (within last 15 minutes during market hours)
   3. Validate price movements are reasonable (<20% single day change without news)
   4. Alert if any symbols fail to fetch

   **Error Recovery**:
   - If batch quote fails, retry with individual quotes
   - If persistent failure, alert user and skip that position (don't fail entire monitoring)
   ```

---

## 10. Success Criteria

### 10.1 Functional Requirements

**All FMP API integrations MUST**:

1. **Correctly replace WebFetch**: No agent uses WebFetch after migration
2. **Fetch accurate data**: All FMP responses validated and parsed correctly
3. **Handle errors gracefully**: No crashes on API errors; always return error messages
4. **Respect rate limits**: No 429 errors under normal usage
5. **Execute within reasonable time**: Full agent workflows complete in <5 minutes

### 10.2 Agent-Specific Success Criteria

**Market Scanner Agent**:
- Successfully screens stocks using FMP screener API
- Identifies top gainers/losers/actives from FMP
- Fetches earnings calendar for next 7 days
- Filters opportunities correctly (volume >500k, price >$10)
- Creates opportunity documents with FMP-sourced data
- **Test**: Run `/scan-opportunities` and verify 3-5 documented opportunities with complete data

**Fundamental Analyst Agent**:
- Fetches all 3 financial statements (5 years)
- Calculates revenue growth trends correctly
- Computes financial ratios and compares to industry
- Generates bull and bear cases based on FMP data
- Produces fundamental score (0-10) with justification
- **Test**: Run analysis on AAPL and verify 5-year revenue data, ratios, and complete report

**Technical Analyst Agent**:
- Fetches 500+ days of historical price data
- Calculates moving averages (20/50/200-day)
- Fetches technical indicators (RSI, ADX) from FMP
- Identifies support/resistance levels from price data
- Generates specific entry/exit/stop levels
- **Test**: Run analysis on AAPL and verify trend analysis, S/R levels, and entry plan

**Portfolio Monitor Agent**:
- Fetches batch quotes for all open positions in single call
- Calculates days held, % change, P&L correctly
- Compares prices to stop/target levels
- Generates appropriate alerts (action/review/milestone/info)
- Produces daily monitoring report
- **Test**: Create mock portfolio with 3 positions, run `/monitor-portfolio`, verify report accuracy

### 10.3 Data Quality Validation

**All agents MUST**:
1. Validate FMP responses before processing
2. Check for `"error": true` in JSON responses
3. Alert user when data is stale (>1 year for financials)
4. Handle missing fields gracefully (use defaults or skip)
5. Log all API errors for debugging

**Data Freshness Thresholds**:
- Quotes: <15 minutes old during market hours
- Financials: <18 months since last fiscal year
- Historical data: Complete range requested
- Indicators: Match historical data timeframe

### 10.4 Performance Benchmarks

**API Call Efficiency**:
- Market Scanner: <20 FMP calls per scan
- Fundamental Analyst: <15 FMP calls per company analysis
- Technical Analyst: <10 FMP calls per company analysis
- Portfolio Monitor: 1 batch quote call for all positions + 1 call per position for news

**Workflow Completion Time**:
- Market Scanner: <3 minutes for full scan
- Fundamental Analyst: <2 minutes for data fetch + analysis time
- Technical Analyst: <2 minutes for data fetch + analysis time
- Portfolio Monitor: <1 minute for daily report

### 10.5 Error Handling Validation

**Test Error Scenarios**:
1. Invalid symbol (404 response)
2. Missing API key (.env not found)
3. Rate limit exceeded (429 response)
4. Network timeout (>30s)
5. Malformed JSON response
6. Missing required fields in valid response

**Expected Behavior**:
- All errors return standardized JSON error format
- Agents log errors and continue (don't crash)
- User receives clear error message in report
- Retry logic works for transient errors (rate limit, timeout)

### 10.6 Integration Testing

**End-to-End Workflow Test**:
1. Run market scanner → generates opportunities
2. Run fundamental analyst on opportunity → produces report with FMP data
3. Run technical analyst on opportunity → produces report with FMP data
4. Simulate position entry → add to portfolio
5. Run portfolio monitor → generates daily report with FMP quotes

**Verify**:
- All FMP data flows through correctly
- Reports contain accurate, complete data
- No WebFetch calls made
- No API errors under normal conditions
- All helper scripts execute successfully

### 10.7 Documentation Completeness

**Required Documentation**:
- [x] This requirements document
- [ ] Helper script README in `/scripts/fmp/README.md`
- [ ] Agent migration guide (before/after examples)
- [ ] FMP API endpoint reference
- [ ] Error handling guide
- [ ] Testing procedures

### 10.8 Acceptance Checklist

Before marking migration complete:

- [ ] All 4 agents updated (WebFetch removed from tools)
- [ ] All 8 helper scripts created and tested
- [ ] `fmp-common.sh` implements all shared functions
- [ ] Error handling standardized across all scripts
- [ ] Rate limiting implemented
- [ ] API key loaded from .env correctly
- [ ] All agents can fetch and parse FMP data
- [ ] Market Scanner produces opportunities with FMP data
- [ ] Fundamental Analyst generates complete analysis from FMP
- [ ] Technical Analyst generates entry/exit levels from FMP
- [ ] Portfolio Monitor tracks positions using FMP quotes
- [ ] End-to-end workflow test passes
- [ ] No 429 rate limit errors under normal usage
- [ ] All error scenarios handled gracefully
- [ ] Performance benchmarks met (<5 min workflows)
- [ ] Documentation complete

### 10.9 Rollback Plan

**If migration fails or has critical issues**:

1. **Immediate Rollback**:
   - Restore agent YAML frontmatter to include `WebFetch`
   - Revert agent instructions to pre-migration state
   - Document failure reason

2. **Partial Rollback**:
   - Keep helper scripts but re-enable WebFetch as fallback
   - Use FMP for primary data, WebFetch for missing endpoints
   - Investigate and fix FMP issues

3. **Rollback Trigger Conditions**:
   - >10% API error rate
   - Consistent rate limit issues
   - Data accuracy problems
   - Performance degradation (>10 min workflows)
   - Agent failures in production

---

## Appendix A: FMP API Reference

### A.1 Base URL
```
https://financialmodelingprep.com
```

### A.2 Authentication
All endpoints require `apikey` parameter:
```
?apikey=SZXOMqlwN2RRrx5bBjDjkxzZpSBvTlHF
```

### A.3 Rate Limits (Paid Tier)
- 250 requests/minute
- 750 requests/hour
- 50,000 requests/day

### A.4 Key Endpoints Summary

| Category | Endpoint | Purpose |
|----------|----------|---------|
| **Quote** | `/v3/quote/{symbol}` | Real-time quote |
| **Historical** | `/v3/historical-price-full/{symbol}` | Daily OHLCV history |
| **Financials** | `/v3/income-statement/{symbol}` | Income statement |
| **Financials** | `/v3/balance-sheet-statement/{symbol}` | Balance sheet |
| **Financials** | `/v3/cash-flow-statement/{symbol}` | Cash flow |
| **Ratios** | `/v3/ratios/{symbol}` | Financial ratios |
| **Metrics** | `/v3/key-metrics/{symbol}` | Key metrics |
| **Profile** | `/v3/profile/{symbol}` | Company profile |
| **Screener** | `/v3/stock-screener` | Stock screening |
| **Indicators** | `/v3/technical_indicator/daily/{symbol}` | Technical indicators |
| **News** | `/v3/stock_news` | Stock news |
| **Earnings** | `/v3/earnings_calendar` | Earnings calendar |
| **Sectors** | `/v3/sectors-performance` | Sector performance |

### A.5 Response Format
All endpoints return JSON. Successful responses contain data arrays or objects. Errors return:
```json
{
  "Error Message": "Description of error"
}
```

---

## Appendix B: File Locations

### B.1 Agent Files (to modify)
- `/Users/nazymazimbayev/apex-os-1/.claude/agents/apex-os-market-scanner.md`
- `/Users/nazymazimbayev/apex-os-1/.claude/agents/apex-os-fundamental-analyst.md`
- `/Users/nazymazimbayev/apex-os-1/.claude/agents/apex-os-technical-analyst.md`
- `/Users/nazymazimbayev/apex-os-1/.claude/agents/apex-os-portfolio-monitor.md`

### B.2 Helper Scripts (to create)
- `/Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-common.sh`
- `/Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-quote.sh`
- `/Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-financials.sh`
- `/Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-ratios.sh`
- `/Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-profile.sh`
- `/Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-historical.sh`
- `/Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-screener.sh`
- `/Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-indicators.sh`
- `/Users/nazymazimbayev/apex-os-1/scripts/fmp/README.md` (documentation)

### B.3 Configuration
- `/Users/nazymazimbayev/apex-os-1/.env` (FMP_API_KEY already configured)

---

## Appendix C: Example Workflows

### C.1 Market Scanner Workflow
```bash
# Step 1: Screen for momentum stocks
gainers=$(bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-screener.sh --type=gainers --limit=50)

# Step 2: Filter by volume and price
echo "$gainers" | jq -r '.[] | select(.avgVolume > 500000 and .price > 10) | [.symbol, .companyName, .price, .changesPercentage] | @tsv'

# Step 3: For each filtered symbol, get detailed quote
# Step 4: Create opportunity document
```

### C.2 Fundamental Analyst Workflow
```bash
SYMBOL="AAPL"
SCRIPTS="/Users/nazymazimbayev/apex-os-1/scripts/fmp"

# Fetch all financial data
profile=$(bash "$SCRIPTS/fmp-profile.sh" "$SYMBOL")
income=$(bash "$SCRIPTS/fmp-financials.sh" "$SYMBOL" income 5 annual)
balance=$(bash "$SCRIPTS/fmp-financials.sh" "$SYMBOL" balance 5 annual)
cashflow=$(bash "$SCRIPTS/fmp-financials.sh" "$SYMBOL" cashflow 5 annual)
ratios=$(bash "$SCRIPTS/fmp-ratios.sh" "$SYMBOL" ratios 5)

# Parse and analyze
company_name=$(echo "$profile" | jq -r '.companyName')
sector=$(echo "$profile" | jq -r '.sector')
latest_revenue=$(echo "$income" | jq -r '.[0].revenue')
pe_ratio=$(echo "$ratios" | jq -r '.[0].priceEarningsRatio')

# Generate report
echo "# Fundamental Analysis: $SYMBOL"
echo "Company: $company_name"
echo "Sector: $sector"
echo "Latest Revenue: $latest_revenue"
echo "P/E Ratio: $pe_ratio"
```

### C.3 Technical Analyst Workflow
```bash
SYMBOL="AAPL"
SCRIPTS="/Users/nazymazimbayev/apex-os-1/scripts/fmp"

# Fetch price data and indicators
quote=$(bash "$SCRIPTS/fmp-quote.sh" "$SYMBOL")
historical=$(bash "$SCRIPTS/fmp-historical.sh" "$SYMBOL" "" "" 500)
sma50=$(bash "$SCRIPTS/fmp-indicators.sh" "$SYMBOL" sma 50 daily)
rsi=$(bash "$SCRIPTS/fmp-indicators.sh" "$SYMBOL" rsi 14 daily)

# Analyze
current_price=$(echo "$quote" | jq -r '.price')
ma50=$(echo "$sma50" | jq -r '.[0].sma')
rsi_value=$(echo "$rsi" | jq -r '.[0].rsi')

# Determine trend
if (( $(echo "$current_price > $ma50" | bc -l) )); then
  echo "Uptrend: Price ($current_price) above 50-day MA ($ma50)"
else
  echo "Downtrend: Price ($current_price) below 50-day MA ($ma50)"
fi
```

### C.4 Portfolio Monitor Workflow
```bash
SCRIPTS="/Users/nazymazimbayev/apex-os-1/scripts/fmp"

# Read open positions
symbols=$(yq e '.positions[].symbol' apex-os/portfolio/open-positions.yaml | paste -sd,)

# Fetch batch quotes
quotes=$(bash "$SCRIPTS/fmp-quote.sh" "$symbols")

# Generate report
echo "# Daily Portfolio Monitor: $(date +%Y-%m-%d)"
echo ""
echo "## Open Positions"

echo "$quotes" | jq -c '.[]' | while read -r quote; do
  symbol=$(echo "$quote" | jq -r '.symbol')
  price=$(echo "$quote" | jq -r '.price')
  change=$(echo "$quote" | jq -r '.changesPercentage')

  echo "### $symbol"
  echo "Current: $$price ($change%)"
done
```

---

**End of Requirements Document**
