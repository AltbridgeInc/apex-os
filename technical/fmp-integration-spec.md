# FMP Integration Technical Specification

**Project**: APEX-OS Financial Modeling Prep API Integration
**Version**: 1.0
**Date**: 2025-11-11
**Status**: Technical Specification
**Author**: Agent-OS Spec-Writer

---

## 1. Executive Summary

### 1.1 Overview

This specification defines the technical implementation for migrating APEX-OS from generic WebFetch/WebSearch tools to direct Financial Modeling Prep (FMP) API integration.

**Scope**: Four APEX-OS agents will be modified to use FMP's comprehensive financial data API:
- Market Scanner Agent (opportunity identification)
- Fundamental Analyst Agent (financial analysis)
- Technical Analyst Agent (technical analysis)
- Portfolio Monitor Agent (position tracking)

**Approach**: Replace WebFetch calls with structured FMP API calls via Bash/curl, supported by reusable helper scripts.

### 1.2 Why This Migration

**Current Problems**:
- WebFetch is slow (HTML parsing overhead)
- Unreliable (website structure changes)
- Limited data depth
- No structured responses
- Rate limiting issues

**FMP API Benefits**:
- Fast, structured JSON responses
- Comprehensive financial dataset (statements, ratios, fundamentals, technicals)
- Reliable data source with SLA
- Rich API (50+ financial ratios, technical indicators, etc.)
- No HTML parsing brittleness

### 1.3 Expected Outcomes

**Functional**:
- All agents fetch data exclusively from FMP API
- No WebFetch dependencies
- Comprehensive error handling
- Rate limit management

**Performance**:
- Market Scanner: <3 min per scan
- Fundamental Analyst: <2 min data fetch
- Technical Analyst: <2 min data fetch
- Portfolio Monitor: <1 min daily report

**Quality**:
- Standardized error handling across all agents
- Data validation at all integration points
- Quality gates enhanced with FMP-specific checks
- Complete test coverage

---

## 2. Architecture Overview

### 2.1 System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        APEX-OS System                        │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Market     │  │ Fundamental  │  │  Technical   │      │
│  │   Scanner    │  │   Analyst    │  │   Analyst    │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
│         │                  │                  │              │
│         │                  │                  │              │
│         └──────────────────┴──────────────────┘              │
│                            │                                 │
│                  ┌─────────▼──────────┐                     │
│                  │  Portfolio Monitor  │                     │
│                  └─────────┬──────────┘                     │
│                            │                                 │
├────────────────────────────┼─────────────────────────────────┤
│         Helper Scripts Layer (Bash/curl/jq)                  │
├────────────────────────────┼─────────────────────────────────┤
│                            │                                 │
│  ┌─────────────┐  ┌───────▼────────┐  ┌─────────────┐     │
│  │fmp-quote.sh │  │fmp-financials.sh│  │fmp-ratios.sh│     │
│  └──────┬──────┘  └───────┬────────┘  └──────┬──────┘     │
│         │                  │                   │             │
│  ┌──────▼─────┐  ┌────────▼───────┐  ┌───────▼──────┐     │
│  │fmp-profile │  │fmp-historical.sh│  │fmp-screener  │     │
│  └──────┬─────┘  └────────┬───────┘  └───────┬──────┘     │
│         │                  │                   │             │
│         └──────────────────┴───────────────────┘             │
│                            │                                 │
│                  ┌─────────▼──────────┐                     │
│                  │  fmp-common.sh     │                     │
│                  │  (shared functions)│                     │
│                  └─────────┬──────────┘                     │
│                            │                                 │
├────────────────────────────┼─────────────────────────────────┤
│              Financial Modeling Prep API                     │
├────────────────────────────┼─────────────────────────────────┤
│                            │                                 │
│  https://financialmodelingprep.com/api/v3/                  │
│                                                               │
│  • Quotes & Historical  • Financials  • Ratios              │
│  • Screener  • Indicators  • News  • Calendar               │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 Data Flow

**Standard Flow**:
```
Agent Needs Data
      ↓
Call Helper Script (e.g., fmp-quote.sh AAPL)
      ↓
Helper Script → Load API key from .env
      ↓
Helper Script → Call FMP API via curl
      ↓
FMP API → Returns JSON response
      ↓
Helper Script → Parse with jq
      ↓
Helper Script → Validate & format
      ↓
Return to Agent (JSON or error)
      ↓
Agent → Parse & analyze
      ↓
Agent → Generate report
```

**Error Flow**:
```
FMP API Error (429, 500, etc.)
      ↓
Helper Script → Detect HTTP error
      ↓
Helper Script → Format standard error JSON
      ↓
Return error to Agent
      ↓
Agent → Check for "error": true
      ↓
Agent → Log error & retry OR fallback OR alert user
```

### 2.3 Technology Stack

| Component | Technology | Purpose |
|-----------|------------|---------|
| **API** | Financial Modeling Prep | Financial data source |
| **HTTP Client** | curl | API requests |
| **JSON Parser** | jq | Parse FMP responses |
| **Scripting** | Bash 5.x | Helper scripts & agent logic |
| **Config** | .env file | API key storage |
| **Agents** | Claude (Bash tool) | Analysis & reporting |

### 2.4 File Structure

```
apex-os-1/
├── .env                                    # FMP_API_KEY
├── .claude/
│   └── agents/
│       ├── apex-os-market-scanner.md      # Modified
│       ├── apex-os-fundamental-analyst.md # Modified
│       ├── apex-os-technical-analyst.md   # Modified
│       └── apex-os-portfolio-monitor.md   # Modified
└── scripts/
    └── fmp/
        ├── README.md                       # Documentation
        ├── fmp-common.sh                   # Shared functions
        ├── fmp-quote.sh                    # Quotes
        ├── fmp-financials.sh               # Financial statements
        ├── fmp-ratios.sh                   # Ratios & metrics
        ├── fmp-profile.sh                  # Company profile
        ├── fmp-historical.sh               # Historical prices
        ├── fmp-screener.sh                 # Stock screening
        └── fmp-indicators.sh               # Technical indicators
```

---

## 3. Helper Scripts Detailed Design

### 3.1 fmp-common.sh

**Purpose**: Shared functions used by all FMP helper scripts

**Location**: `/Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-common.sh`

**Functions**:

#### 3.1.1 load_api_key()

```bash
#!/usr/bin/env bash

# Load FMP API key from .env file
# Returns: 0 if successful, 1 if key not found
load_api_key() {
    local env_file="/Users/nazymazimbayev/apex-os-1/.env"

    if [[ ! -f "$env_file" ]]; then
        format_error "missing_api_key" ".env file not found at $env_file"
        return 1
    fi

    # Source .env and export FMP_API_KEY
    source "$env_file"

    if [[ -z "$FMP_API_KEY" ]]; then
        format_error "missing_api_key" "FMP_API_KEY not defined in .env"
        return 1
    fi

    export FMP_API_KEY
    return 0
}
```

#### 3.1.2 fmp_api_call()

```bash
# Make FMP API call with error handling
# Args:
#   $1: endpoint path (e.g., "/v3/quote/AAPL")
#   $2: optional additional parameters (e.g., "limit=5&period=annual")
# Returns: JSON response or error JSON
fmp_api_call() {
    local endpoint="$1"
    local params="$2"
    local base_url="https://financialmodelingprep.com"

    # Load API key
    load_api_key || return 1

    # Build URL
    local url="${base_url}${endpoint}?apikey=${FMP_API_KEY}"
    if [[ -n "$params" ]]; then
        url="${url}&${params}"
    fi

    # Rate limit check
    check_rate_limit

    # Make request with retry logic
    local max_retries=3
    local retry_count=0
    local response
    local http_code

    while [[ $retry_count -lt $max_retries ]]; do
        # Execute curl with timeout
        response=$(curl -s -w "\n%{http_code}" --max-time 30 "$url")
        http_code=$(echo "$response" | tail -n 1)
        response=$(echo "$response" | sed '$d')

        # Check HTTP status
        if [[ "$http_code" == "200" ]]; then
            # Validate JSON
            if echo "$response" | jq empty 2>/dev/null; then
                echo "$response"
                return 0
            else
                format_error "invalid_response" "FMP returned invalid JSON"
                return 1
            fi
        elif [[ "$http_code" == "429" ]]; then
            # Rate limit - retry with backoff
            retry_count=$((retry_count + 1))
            local sleep_time=$((2 ** retry_count))
            echo "Rate limit hit, sleeping ${sleep_time}s..." >&2
            sleep "$sleep_time"
        elif [[ "$http_code" == "500" ]] || [[ "$http_code" == "503" ]]; then
            # Server error - retry
            retry_count=$((retry_count + 1))
            sleep $((2 ** retry_count))
        else
            # Other error - don't retry
            map_http_error "$http_code" "$endpoint"
            return 1
        fi
    done

    # Max retries exceeded
    format_error "timeout" "Max retries exceeded for $endpoint"
    return 1
}
```

#### 3.1.3 format_error()

```bash
# Format standardized error JSON
# Args:
#   $1: error type
#   $2: error message
# Returns: JSON error object
format_error() {
    local error_type="$1"
    local message="$2"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    cat <<EOF
{
  "error": true,
  "type": "$error_type",
  "message": "$message",
  "timestamp": "$timestamp"
}
EOF
}
```

#### 3.1.4 map_http_error()

```bash
# Map HTTP error codes to user-friendly messages
# Args:
#   $1: HTTP status code
#   $2: endpoint path
map_http_error() {
    local code="$1"
    local endpoint="$2"

    case "$code" in
        400)
            format_error "http_error" "Invalid request parameters for $endpoint"
            ;;
        401)
            format_error "http_error" "FMP API key is invalid or expired"
            ;;
        403)
            format_error "http_error" "Access denied - check API subscription tier"
            ;;
        404)
            format_error "http_error" "Endpoint not found or symbol invalid: $endpoint"
            ;;
        429)
            format_error "rate_limit" "Rate limit exceeded - retry after a few seconds"
            ;;
        500)
            format_error "http_error" "FMP API server error - retry later"
            ;;
        503)
            format_error "http_error" "FMP API temporarily unavailable"
            ;;
        *)
            format_error "http_error" "HTTP $code error for $endpoint"
            ;;
    esac
}
```

#### 3.1.5 validate_symbol()

```bash
# Validate stock symbol
# Args:
#   $1: symbol
# Returns: 0 if valid, 1 if invalid
validate_symbol() {
    local symbol="$1"

    if [[ -z "$symbol" ]]; then
        format_error "invalid_symbol" "Symbol cannot be empty"
        return 1
    fi

    # Check format: uppercase letters, optional dot/dash
    if [[ ! "$symbol" =~ ^[A-Z]{1,5}([-.]?[A-Z]{1,2})?$ ]]; then
        format_error "invalid_symbol" "Invalid symbol format: $symbol"
        return 1
    fi

    return 0
}
```

#### 3.1.6 check_rate_limit()

```bash
# Track and manage API rate limits
# FMP Paid Tier: 250 requests/minute
check_rate_limit() {
    local rate_file="/tmp/fmp_rate_$(date +%Y%m%d_%H%M).txt"
    local count=$(wc -l < "$rate_file" 2>/dev/null || echo 0)

    # If approaching limit (240/250), sleep
    if [[ $count -ge 240 ]]; then
        echo "WARNING: Approaching rate limit, sleeping 10s..." >&2
        sleep 10
        # Clear old rate file
        rm -f /tmp/fmp_rate_*.txt
        rate_file="/tmp/fmp_rate_$(date +%Y%m%d_%H%M).txt"
    fi

    # Record this call
    echo "$(date +%s)" >> "$rate_file"
}
```

**Complete Implementation**:

```bash
#!/usr/bin/env bash
# fmp-common.sh - Shared functions for FMP API integration
set -euo pipefail

# [Include all functions above]

# Export functions for use by other scripts
export -f load_api_key
export -f fmp_api_call
export -f format_error
export -f map_http_error
export -f validate_symbol
export -f check_rate_limit
```

---

### 3.2 fmp-quote.sh

**Purpose**: Fetch real-time stock quotes (single or batch)

**Location**: `/Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-quote.sh`

**Function Signature**:
```bash
./fmp-quote.sh SYMBOL[,SYMBOL2,SYMBOL3...]
```

**Parameters**:
- `$1`: Stock symbol(s) - single symbol or comma-separated list

**FMP Endpoint**: `GET /v3/quote/{symbols}`

**Response Structure**:
```json
[
  {
    "symbol": "AAPL",
    "name": "Apple Inc.",
    "price": 175.43,
    "changesPercentage": 1.24,
    "change": 2.15,
    "dayLow": 173.50,
    "dayHigh": 176.00,
    "yearHigh": 199.62,
    "yearLow": 124.17,
    "marketCap": 2750000000000,
    "priceAvg50": 172.30,
    "priceAvg200": 165.80,
    "volume": 65432100,
    "avgVolume": 55000000,
    "open": 174.00,
    "previousClose": 173.28,
    "eps": 6.15,
    "pe": 28.5,
    "earningsAnnouncement": "2024-02-01T00:00:00.000+0000",
    "sharesOutstanding": 15634200000,
    "timestamp": 1699648800
  }
]
```

**Complete Implementation**:

```bash
#!/usr/bin/env bash
# fmp-quote.sh - Fetch real-time stock quotes
set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/fmp-common.sh"

# Validate arguments
if [[ $# -lt 1 ]]; then
    format_error "invalid_params" "Usage: fmp-quote.sh SYMBOL[,SYMBOL2,...]"
    exit 1
fi

symbols="$1"

# Validate symbols (basic check for comma-separated list)
if [[ -z "$symbols" ]]; then
    format_error "invalid_symbol" "Symbols cannot be empty"
    exit 1
fi

# Convert symbols to uppercase
symbols=$(echo "$symbols" | tr '[:lower:]' '[:upper:]')

# Build endpoint
endpoint="/v3/quote/${symbols}"

# Make API call
response=$(fmp_api_call "$endpoint")
exit_code=$?

if [[ $exit_code -ne 0 ]]; then
    echo "$response"
    exit 1
fi

# Validate response is array
if ! echo "$response" | jq -e 'type == "array"' > /dev/null 2>&1; then
    format_error "invalid_response" "Expected array response from quote endpoint"
    exit 1
fi

# Check if array is empty
count=$(echo "$response" | jq 'length')
if [[ $count -eq 0 ]]; then
    format_error "missing_data" "No quote data returned for symbols: $symbols"
    exit 1
fi

# Return response
echo "$response"
```

**Usage Examples**:

```bash
# Single quote
quote=$(bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-quote.sh AAPL)
price=$(echo "$quote" | jq -r '.[0].price')

# Batch quotes
quotes=$(bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-quote.sh "AAPL,MSFT,GOOGL")
echo "$quotes" | jq -r '.[] | [.symbol, .price, .changesPercentage] | @tsv'

# Error handling
if echo "$quote" | jq -e '.error' > /dev/null 2>&1; then
    error_msg=$(echo "$quote" | jq -r '.message')
    echo "ERROR: $error_msg"
    exit 1
fi
```

---

### 3.3 fmp-financials.sh

**Purpose**: Fetch financial statements (income, balance sheet, cash flow)

**Location**: `/Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-financials.sh`

**Function Signature**:
```bash
./fmp-financials.sh SYMBOL STATEMENT_TYPE [LIMIT] [PERIOD]
```

**Parameters**:
- `$1`: Stock symbol
- `$2`: Statement type: `income`, `balance`, `cashflow`
- `$3`: Limit (number of periods, default: 5)
- `$4`: Period: `annual`, `quarterly` (default: annual)

**FMP Endpoints**:
- Income: `GET /v3/income-statement/{symbol}?limit={limit}&period={period}`
- Balance: `GET /v3/balance-sheet-statement/{symbol}?limit={limit}&period={period}`
- Cash Flow: `GET /v3/cash-flow-statement/{symbol}?limit={limit}&period={period}`

**Response Structure** (Income Statement example):
```json
[
  {
    "date": "2023-09-30",
    "symbol": "AAPL",
    "reportedCurrency": "USD",
    "cik": "0000320193",
    "fillingDate": "2023-11-03",
    "acceptedDate": "2023-11-02 18:08:27",
    "calendarYear": "2023",
    "period": "FY",
    "revenue": 383285000000,
    "costOfRevenue": 214137000000,
    "grossProfit": 169148000000,
    "grossProfitRatio": 0.4414,
    "researchAndDevelopmentExpenses": 29915000000,
    "generalAndAdministrativeExpenses": 0,
    "sellingAndMarketingExpenses": 0,
    "sellingGeneralAndAdministrativeExpenses": 24932000000,
    "otherExpenses": 0,
    "operatingExpenses": 54847000000,
    "costAndExpenses": 268984000000,
    "interestIncome": 3750000000,
    "interestExpense": 3933000000,
    "depreciationAndAmortization": 11519000000,
    "ebitda": 125820000000,
    "ebitdaratio": 0.3283,
    "operatingIncome": 114301000000,
    "operatingIncomeRatio": 0.2982,
    "totalOtherIncomeExpensesNet": -565000000,
    "incomeBeforeTax": 113736000000,
    "incomeBeforeTaxRatio": 0.2967,
    "incomeTaxExpense": 16741000000,
    "netIncome": 96995000000,
    "netIncomeRatio": 0.2531,
    "eps": 6.16,
    "epsdiluted": 6.13,
    "weightedAverageShsOut": 15744200000,
    "weightedAverageShsOutDil": 15812500000,
    "link": "https://www.sec.gov/cgi-bin/viewer?action=view&cik=320193&accession_number=0000320193-23-000106&xbrl_type=v",
    "finalLink": "https://www.sec.gov/cgi-bin/viewer?action=view&cik=320193&accession_number=0000320193-23-000106&xbrl_type=v"
  },
  ...
]
```

**Complete Implementation**:

```bash
#!/usr/bin/env bash
# fmp-financials.sh - Fetch financial statements
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/fmp-common.sh"

# Validate arguments
if [[ $# -lt 2 ]]; then
    format_error "invalid_params" "Usage: fmp-financials.sh SYMBOL TYPE [LIMIT] [PERIOD]"
    echo "  TYPE: income, balance, cashflow"
    echo "  LIMIT: number of periods (default: 5)"
    echo "  PERIOD: annual, quarterly (default: annual)"
    exit 1
fi

symbol=$(echo "$1" | tr '[:lower:]' '[:upper:]')
statement_type=$(echo "$2" | tr '[:upper:]' '[:lower:]')
limit=${3:-5}
period=${4:-annual}

# Validate symbol
validate_symbol "$symbol" || exit 1

# Validate statement type and build endpoint
case "$statement_type" in
    income)
        endpoint="/v3/income-statement/${symbol}"
        ;;
    balance)
        endpoint="/v3/balance-sheet-statement/${symbol}"
        ;;
    cashflow)
        endpoint="/v3/cash-flow-statement/${symbol}"
        ;;
    *)
        format_error "invalid_params" "Invalid statement type: $statement_type (use: income, balance, cashflow)"
        exit 1
        ;;
esac

# Build parameters
params="limit=${limit}&period=${period}"

# Make API call
response=$(fmp_api_call "$endpoint" "$params")
exit_code=$?

if [[ $exit_code -ne 0 ]]; then
    echo "$response"
    exit 1
fi

# Validate response
if ! echo "$response" | jq -e 'type == "array"' > /dev/null 2>&1; then
    format_error "invalid_response" "Expected array response"
    exit 1
fi

count=$(echo "$response" | jq 'length')
if [[ $count -eq 0 ]]; then
    format_error "missing_data" "No financial data returned for $symbol"
    exit 1
fi

# Return response (sorted by date, newest first)
echo "$response" | jq 'sort_by(.date) | reverse'
```

**Usage Examples**:

```bash
# Get 5 years of income statements
income=$(bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-financials.sh AAPL income 5 annual)

# Extract revenue trend
echo "$income" | jq -r '.[] | [.date, .revenue, .netIncome] | @tsv'

# Get quarterly cash flows
cashflow=$(bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-financials.sh AAPL cashflow 8 quarterly)

# Calculate free cash flow
echo "$cashflow" | jq -r '.[] | [.date, (.operatingCashFlow - .capitalExpenditure)] | @tsv'
```

---

### 3.4 fmp-ratios.sh

**Purpose**: Fetch financial ratios, key metrics, and growth metrics

**Location**: `/Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-ratios.sh`

**Function Signature**:
```bash
./fmp-ratios.sh SYMBOL TYPE [LIMIT]
```

**Parameters**:
- `$1`: Stock symbol
- `$2`: Type: `ratios`, `metrics`, `growth`
- `$3`: Limit (default: 5)

**FMP Endpoints**:
- Ratios: `GET /v3/ratios/{symbol}?limit={limit}`
- Metrics: `GET /v3/key-metrics/{symbol}?limit={limit}`
- Growth: `GET /v3/financial-growth/{symbol}?limit={limit}`

**Complete Implementation**:

```bash
#!/usr/bin/env bash
# fmp-ratios.sh - Fetch financial ratios and metrics
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/fmp-common.sh"

if [[ $# -lt 2 ]]; then
    format_error "invalid_params" "Usage: fmp-ratios.sh SYMBOL TYPE [LIMIT]"
    echo "  TYPE: ratios, metrics, growth"
    exit 1
fi

symbol=$(echo "$1" | tr '[:lower:]' '[:upper:]')
ratio_type=$(echo "$2" | tr '[:upper:]' '[:lower:]')
limit=${3:-5}

validate_symbol "$symbol" || exit 1

case "$ratio_type" in
    ratios)
        endpoint="/v3/ratios/${symbol}"
        ;;
    metrics)
        endpoint="/v3/key-metrics/${symbol}"
        ;;
    growth)
        endpoint="/v3/financial-growth/${symbol}"
        ;;
    *)
        format_error "invalid_params" "Invalid type: $ratio_type (use: ratios, metrics, growth)"
        exit 1
        ;;
esac

params="limit=${limit}"

response=$(fmp_api_call "$endpoint" "$params")
exit_code=$?

if [[ $exit_code -ne 0 ]]; then
    echo "$response"
    exit 1
fi

if ! echo "$response" | jq -e 'type == "array"' > /dev/null 2>&1; then
    format_error "invalid_response" "Expected array response"
    exit 1
fi

echo "$response" | jq 'sort_by(.date) | reverse'
```

**Usage Examples**:

```bash
# Get financial ratios
ratios=$(bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-ratios.sh AAPL ratios 1)
pe=$(echo "$ratios" | jq -r '.[0].priceEarningsRatio')
roe=$(echo "$ratios" | jq -r '.[0].returnOnEquity')

# Get key metrics
metrics=$(bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-ratios.sh AAPL metrics 5)
echo "$metrics" | jq -r '.[] | [.date, .revenuePerShare, .netIncomePerShare] | @tsv'

# Get growth metrics
growth=$(bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-ratios.sh AAPL growth 5)
echo "$growth" | jq -r '.[] | [.date, .revenueGrowth, .netIncomeGrowth] | @tsv'
```

---

### 3.5 fmp-profile.sh

**Purpose**: Fetch company profile and overview information

**Location**: `/Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-profile.sh`

**Function Signature**:
```bash
./fmp-profile.sh SYMBOL
```

**FMP Endpoint**: `GET /v3/profile/{symbol}`

**Complete Implementation**:

```bash
#!/usr/bin/env bash
# fmp-profile.sh - Fetch company profile
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/fmp-common.sh"

if [[ $# -lt 1 ]]; then
    format_error "invalid_params" "Usage: fmp-profile.sh SYMBOL"
    exit 1
fi

symbol=$(echo "$1" | tr '[:lower:]' '[:upper:]')
validate_symbol "$symbol" || exit 1

endpoint="/v3/profile/${symbol}"

response=$(fmp_api_call "$endpoint")
exit_code=$?

if [[ $exit_code -ne 0 ]]; then
    echo "$response"
    exit 1
fi

if ! echo "$response" | jq -e 'type == "array"' > /dev/null 2>&1; then
    format_error "invalid_response" "Expected array response"
    exit 1
fi

# Return first element (profile is returned as single-element array)
echo "$response" | jq '.[0]'
```

---

### 3.6 fmp-historical.sh

**Purpose**: Fetch historical price data (daily or intraday)

**Location**: `/Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-historical.sh`

**Function Signature**:
```bash
./fmp-historical.sh SYMBOL [FROM_DATE] [TO_DATE] [LIMIT] [INTERVAL]
```

**Parameters**:
- `$1`: Stock symbol
- `$2`: From date (YYYY-MM-DD, optional)
- `$3`: To date (YYYY-MM-DD, optional)
- `$4`: Limit (number of days, optional)
- `$5`: Interval: `1min`, `5min`, `15min`, `30min`, `1hour`, `4hour`, `daily` (default: daily)

**FMP Endpoints**:
- Daily: `GET /v3/historical-price-full/{symbol}?from={from}&to={to}`
- Intraday: `GET /v3/historical-chart/{interval}/{symbol}`

**Complete Implementation**:

```bash
#!/usr/bin/env bash
# fmp-historical.sh - Fetch historical price data
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/fmp-common.sh"

if [[ $# -lt 1 ]]; then
    format_error "invalid_params" "Usage: fmp-historical.sh SYMBOL [FROM] [TO] [LIMIT] [INTERVAL]"
    exit 1
fi

symbol=$(echo "$1" | tr '[:lower:]' '[:upper:]')
from_date="${2:-}"
to_date="${3:-}"
limit="${4:-}"
interval="${5:-daily}"

validate_symbol "$symbol" || exit 1

# Build endpoint based on interval
if [[ "$interval" == "daily" ]]; then
    endpoint="/v3/historical-price-full/${symbol}"
    params=""

    if [[ -n "$from_date" ]]; then
        params="from=${from_date}"
    fi
    if [[ -n "$to_date" ]]; then
        [[ -n "$params" ]] && params="${params}&"
        params="${params}to=${to_date}"
    fi

    response=$(fmp_api_call "$endpoint" "$params")
    exit_code=$?

    if [[ $exit_code -ne 0 ]]; then
        echo "$response"
        exit 1
    fi

    # Extract historical array
    historical=$(echo "$response" | jq '.historical')

    # Apply limit if specified
    if [[ -n "$limit" ]]; then
        historical=$(echo "$historical" | jq ".[0:${limit}]")
    fi

    echo "$historical"
else
    # Intraday data
    endpoint="/v3/historical-chart/${interval}/${symbol}"

    response=$(fmp_api_call "$endpoint")
    exit_code=$?

    if [[ $exit_code -ne 0 ]]; then
        echo "$response"
        exit 1
    fi

    # Apply limit if specified
    if [[ -n "$limit" ]]; then
        response=$(echo "$response" | jq ".[0:${limit}]")
    fi

    echo "$response"
fi
```

**Usage Examples**:

```bash
# Get last 500 days
historical=$(bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-historical.sh AAPL "" "" 500)

# Get specific date range
historical=$(bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-historical.sh AAPL 2023-01-01 2023-12-31)

# Get intraday 5-minute data
intraday=$(bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-historical.sh AAPL "" "" 100 5min)

# Extract OHLCV
echo "$historical" | jq -r '.[] | [.date, .open, .high, .low, .close, .volume] | @tsv'
```

---

### 3.7 fmp-screener.sh

**Purpose**: Stock screening with multiple criteria

**Location**: `/Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-screener.sh`

**Function Signature**:
```bash
./fmp-screener.sh [--param=value ...]
```

**Parameters** (all optional):
- `--type=gainers|losers|actives` (market movers)
- `--marketCapMoreThan=VALUE`
- `--marketCapLowerThan=VALUE`
- `--priceMoreThan=VALUE`
- `--priceLowerThan=VALUE`
- `--betaMoreThan=VALUE`
- `--volumeMoreThan=VALUE`
- `--sector=VALUE`
- `--industry=VALUE`
- `--exchange=VALUE`
- `--limit=VALUE` (default: 100)

**FMP Endpoints**:
- Screener: `GET /v3/stock-screener`
- Gainers: `GET /v3/stock_market/gainers`
- Losers: `GET /v3/stock_market/losers`
- Actives: `GET /v3/stock_market/actives`

**Complete Implementation**:

```bash
#!/usr/bin/env bash
# fmp-screener.sh - Stock screening
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/fmp-common.sh"

# Parse arguments
type=""
params=""

for arg in "$@"; do
    case "$arg" in
        --type=*)
            type="${arg#*=}"
            ;;
        --*)
            key="${arg%%=*}"
            key="${key#--}"
            value="${arg#*=}"
            [[ -n "$params" ]] && params="${params}&"
            params="${params}${key}=${value}"
            ;;
    esac
done

# Determine endpoint
if [[ -n "$type" ]]; then
    case "$type" in
        gainers)
            endpoint="/v3/stock_market/gainers"
            ;;
        losers)
            endpoint="/v3/stock_market/losers"
            ;;
        actives)
            endpoint="/v3/stock_market/actives"
            ;;
        *)
            format_error "invalid_params" "Invalid type: $type"
            exit 1
            ;;
    esac
else
    endpoint="/v3/stock-screener"
fi

response=$(fmp_api_call "$endpoint" "$params")
exit_code=$?

if [[ $exit_code -ne 0 ]]; then
    echo "$response"
    exit 1
fi

echo "$response"
```

**Usage Examples**:

```bash
# Top gainers
gainers=$(bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-screener.sh --type=gainers --limit=50)

# Growth stocks
growth=$(bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-screener.sh \
    --marketCapMoreThan=1000000000 \
    --volumeMoreThan=500000 \
    --priceMoreThan=10 \
    --sector=Technology \
    --limit=100)

# Most active stocks
actives=$(bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-screener.sh --type=actives)
```

---

### 3.8 fmp-indicators.sh

**Purpose**: Fetch technical indicators

**Location**: `/Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-indicators.sh`

**Function Signature**:
```bash
./fmp-indicators.sh SYMBOL TYPE [PERIOD] [TIMEFRAME]
```

**Parameters**:
- `$1`: Stock symbol
- `$2`: Indicator type: `sma`, `ema`, `rsi`, `macd`, `adx`, `williams`
- `$3`: Period (default: 14)
- `$4`: Timeframe: `1min`, `5min`, `15min`, `30min`, `1hour`, `4hour`, `daily` (default: daily)

**FMP Endpoint**: `GET /v3/technical_indicator/{timeframe}/{symbol}?type={type}&period={period}`

**Complete Implementation**:

```bash
#!/usr/bin/env bash
# fmp-indicators.sh - Fetch technical indicators
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/fmp-common.sh"

if [[ $# -lt 2 ]]; then
    format_error "invalid_params" "Usage: fmp-indicators.sh SYMBOL TYPE [PERIOD] [TIMEFRAME]"
    echo "  TYPE: sma, ema, rsi, macd, adx, williams"
    echo "  PERIOD: default 14"
    echo "  TIMEFRAME: 1min, 5min, 15min, 30min, 1hour, 4hour, daily (default: daily)"
    exit 1
fi

symbol=$(echo "$1" | tr '[:lower:]' '[:upper:]')
indicator_type=$(echo "$2" | tr '[:upper:]' '[:lower:]')
period=${3:-14}
timeframe=${4:-daily}

validate_symbol "$symbol" || exit 1

# Validate indicator type
case "$indicator_type" in
    sma|ema|rsi|macd|adx|williams|stoch)
        ;;
    *)
        format_error "invalid_params" "Invalid indicator: $indicator_type"
        exit 1
        ;;
esac

endpoint="/v3/technical_indicator/${timeframe}/${symbol}"
params="type=${indicator_type}&period=${period}"

response=$(fmp_api_call "$endpoint" "$params")
exit_code=$?

if [[ $exit_code -ne 0 ]]; then
    echo "$response"
    exit 1
fi

echo "$response"
```

**Usage Examples**:

```bash
# Get 50-day SMA
sma50=$(bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-indicators.sh AAPL sma 50 daily)
latest_sma=$(echo "$sma50" | jq -r '.[0].sma')

# Get RSI
rsi=$(bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-indicators.sh AAPL rsi 14 daily)
rsi_value=$(echo "$rsi" | jq -r '.[0].rsi')

# Check overbought/oversold
if (( $(echo "$rsi_value > 70" | bc -l) )); then
    echo "Overbought: RSI $rsi_value"
elif (( $(echo "$rsi_value < 30" | bc -l) )); then
    echo "Oversold: RSI $rsi_value"
fi
```

---

## 4. Agent Modifications Specification

### 4.1 Market Scanner Agent

**File**: `.claude/agents/apex-os-market-scanner.md`

**Current State**:
- Line 4: `tools: Write, Read, Bash, WebFetch`
- Uses WebFetch for generic web scraping
- No structured data source

**Target State**:
- Line 4: `tools: Write, Read, Bash`
- Uses FMP API via helper scripts
- Structured JSON data processing

**Modifications**:

#### 4.1.1 YAML Frontmatter (Line 4)

**Before**:
```yaml
tools: Write, Read, Bash, WebFetch
```

**After**:
```yaml
tools: Write, Read, Bash
```

#### 4.1.2 Add FMP Integration Section (After Line 19)

```markdown
## FMP API Integration

All market data is fetched from Financial Modeling Prep API using helper scripts in `/Users/nazymazimbayev/apex-os-1/scripts/fmp/`.

### Available Scripts

- `fmp-screener.sh`: Stock screening (technical/fundamental criteria + market movers)
- `fmp-quote.sh`: Real-time quotes (single or batch)
- `fmp-profile.sh`: Company profiles
- `fmp-financials.sh`: Quick fundamental checks

### Example Usage

```bash
SCRIPTS="/Users/nazymazimbayev/apex-os-1/scripts/fmp"

# Screen for momentum stocks
gainers=$(bash "$SCRIPTS/fmp-screener.sh" --type=gainers --limit=50)

# Screen for growth stocks
growth=$(bash "$SCRIPTS/fmp-screener.sh" \
    --marketCapMoreThan=1000000000 \
    --volumeMoreThan=500000 \
    --priceMoreThan=10 \
    --limit=100)

# Get detailed quotes
symbols=$(echo "$gainers" | jq -r '.[0:10] | .[].symbol' | paste -sd,)
quotes=$(bash "$SCRIPTS/fmp-quote.sh" "$symbols")
```

### Error Handling

Always check for errors in API responses:

```bash
if echo "$response" | jq -e '.error' > /dev/null 2>&1; then
    error_msg=$(echo "$response" | jq -r '.message')
    echo "⚠️ FMP API Error: $error_msg" >&2
    # Log error and continue with available data
fi
```
```

#### 4.1.3 Update Step 1: Run Systematic Scans (Replace Lines 22-44)

```markdown
### Step 1: Run Systematic Scans

Use FMP API to identify opportunities from multiple sources.

**Technical Screeners**:

```bash
SCRIPTS="/Users/nazymazimbayev/apex-os-1/scripts/fmp"

# Momentum scanner - top gainers with volume
gainers=$(bash "$SCRIPTS/fmp-screener.sh" --type=gainers --limit=50)
gainers_filtered=$(echo "$gainers" | jq '[.[] | select(.avgVolume > 500000 and .price > 10)]')

# Volume breakout scanner - most active
actives=$(bash "$SCRIPTS/fmp-screener.sh" --type=actives --limit=50)
actives_filtered=$(echo "$actives" | jq '[.[] | select(.avgVolume > 500000 and .price > 10)]')

# Combine and deduplicate
all_technical=$(echo "$gainers_filtered" "$actives_filtered" | jq -s 'add | unique_by(.symbol)')
```

**Fundamental Screeners**:

```bash
# Growth stocks: large cap, liquid, in growth sectors
growth_tech=$(bash "$SCRIPTS/fmp-screener.sh" \
    --marketCapMoreThan=1000000000 \
    --volumeMoreThan=500000 \
    --priceMoreThan=10 \
    --sector=Technology \
    --limit=50)

growth_health=$(bash "$SCRIPTS/fmp-screener.sh" \
    --marketCapMoreThan=1000000000 \
    --volumeMoreThan=500000 \
    --priceMoreThan=10 \
    --sector="Healthcare" \
    --limit=50)

# Combine growth stocks
all_fundamental=$(echo "$growth_tech" "$growth_health" | jq -s 'add | unique_by(.symbol)')
```

**Catalyst Monitoring** (if available endpoints):

```bash
# Note: Earnings calendar and news require custom implementation via fmp-common.sh
# For now, focus on screener-based opportunities
```

**Sector Performance Check**:

```bash
# Identify hot sectors for sector rotation
# Note: Implement sector performance check if needed
```
```

#### 4.1.4 Update Step 2: Initial Filtering (Replace Lines 45-60)

```markdown
### Step 2: Initial Filtering

For each identified opportunity, fetch detailed data and apply filters.

```bash
# Combine all opportunities
all_opportunities=$(echo "$all_technical" "$all_fundamental" | jq -s 'add | unique_by(.symbol)')

# Process each symbol
echo "$all_opportunities" | jq -c '.[]' | while read -r opp; do
    symbol=$(echo "$opp" | jq -r '.symbol')

    # Get detailed quote
    quote=$(bash "$SCRIPTS/fmp-quote.sh" "$symbol")

    if echo "$quote" | jq -e '.error' > /dev/null 2>&1; then
        echo "Skipping $symbol - quote fetch failed"
        continue
    fi

    # Extract metrics
    price=$(echo "$quote" | jq -r '.[0].price')
    avg_volume=$(echo "$quote" | jq -r '.[0].avgVolume')
    market_cap=$(echo "$quote" | jq -r '.[0].marketCap')

    # Apply filters
    if (( $(echo "$price < 10" | bc -l) )); then
        echo "Filtered $symbol: price too low ($price)"
        continue
    fi

    if (( $(echo "$avg_volume < 500000" | bc -l) )); then
        echo "Filtered $symbol: volume too low ($avg_volume)"
        continue
    fi

    if (( $(echo "$market_cap < 100000000" | bc -l) )); then
        echo "Filtered $symbol: market cap too small ($market_cap)"
        continue
    fi

    # Quick fundamental check
    income=$(bash "$SCRIPTS/fmp-financials.sh" "$symbol" income 1 annual)

    if ! echo "$income" | jq -e '.error' > /dev/null 2>&1; then
        revenue=$(echo "$income" | jq -r '.[0].revenue // 0')
        net_income=$(echo "$income" | jq -r '.[0].netIncome // 0')

        # Require positive revenue and profit
        if (( $(echo "$revenue <= 0" | bc -l) )) || (( $(echo "$net_income <= 0" | bc -l) )); then
            echo "Filtered $symbol: not profitable (Revenue: $revenue, Net Income: $net_income)"
            continue
        fi
    fi

    # Passed all filters
    echo "✓ $symbol passed filters"
    # Store for next step
done
```
```

#### 4.1.5 Add Data Quality Checks Section (Before "Important Constraints")

```markdown
## Data Quality Checks

Before documenting opportunities, validate FMP data quality:

**Required Validations**:
1. ✓ API responses contain expected fields
2. ✓ No stale data (prices updated within 24 hours)
3. ✓ Numeric values are reasonable (no negative prices/volumes)
4. ✓ Symbol exists in FMP database

**Implementation**:

```bash
validate_opportunity_data() {
    local quote="$1"

    # Check for error
    if echo "$quote" | jq -e '.error' > /dev/null 2>&1; then
        return 1
    fi

    # Check required fields
    local price=$(echo "$quote" | jq -r '.[0].price // null')
    local volume=$(echo "$quote" | jq -r '.[0].volume // null')
    local market_cap=$(echo "$quote" | jq -r '.[0].marketCap // null')

    if [[ "$price" == "null" ]] || [[ "$volume" == "null" ]] || [[ "$market_cap" == "null" ]]; then
        echo "Missing required fields"
        return 1
    fi

    # Validate ranges
    if (( $(echo "$price <= 0" | bc -l) )); then
        echo "Invalid price: $price"
        return 1
    fi

    return 0
}
```

**Alert on Issues**:
```bash
if ! validate_opportunity_data "$quote"; then
    echo "⚠️ WARNING: Data quality issue for $symbol - excluding from scan"
fi
```
```

---

### 4.2 Fundamental Analyst Agent

**File**: `.claude/agents/apex-os-fundamental-analyst.md`

**Modifications**:

#### 4.2.1 YAML Frontmatter (Line 4)

**Before**:
```yaml
tools: Write, Read, Bash, WebFetch
```

**After**:
```yaml
tools: Write, Read, Bash
```

#### 4.2.2 Add FMP Integration Section (After Line 20)

```markdown
## FMP API Integration

All financial data is fetched from Financial Modeling Prep API.

### Required Scripts

```bash
SCRIPTS="/Users/nazymazimbayev/apex-os-1/scripts/fmp"

# Financial statements
$SCRIPTS/fmp-financials.sh SYMBOL income|balance|cashflow [LIMIT] [PERIOD]

# Ratios and metrics
$SCRIPTS/fmp-ratios.sh SYMBOL ratios|metrics|growth [LIMIT]

# Company profile
$SCRIPTS/fmp-profile.sh SYMBOL
```

### Standard Data Fetch Pattern

```bash
SYMBOL="AAPL"
SCRIPTS="/Users/nazymazimbayev/apex-os-1/scripts/fmp"

# Fetch all required data (5-year history)
profile=$(bash "$SCRIPTS/fmp-profile.sh" "$SYMBOL")
income=$(bash "$SCRIPTS/fmp-financials.sh" "$SYMBOL" income 5 annual)
balance=$(bash "$SCRIPTS/fmp-financials.sh" "$SYMBOL" balance 5 annual)
cashflow=$(bash "$SCRIPTS/fmp-financials.sh" "$SYMBOL" cashflow 5 annual)
ratios=$(bash "$SCRIPTS/fmp-ratios.sh" "$SYMBOL" ratios 5)
metrics=$(bash "$SCRIPTS/fmp-ratios.sh" "$SYMBOL" metrics 5)
growth=$(bash "$SCRIPTS/fmp-ratios.sh" "$SYMBOL" growth 5)

# Parse with jq
company_name=$(echo "$profile" | jq -r '.companyName')
sector=$(echo "$profile" | jq -r '.sector')
latest_revenue=$(echo "$income" | jq -r '.[0].revenue')
```
```

#### 4.2.3 Update Section 1: Financial Health Analysis (Replace Lines 37-74)

```markdown
#### 1. Financial Health Analysis

**Fetch Financial Statements** (5-year annual data):

```bash
SYMBOL="$1"  # Passed as argument
SCRIPTS="/Users/nazymazimbayev/apex-os-1/scripts/fmp"

income=$(bash "$SCRIPTS/fmp-financials.sh" "$SYMBOL" income 5 annual)
balance=$(bash "$SCRIPTS/fmp-financials.sh" "$SYMBOL" balance 5 annual)
cashflow=$(bash "$SCRIPTS/fmp-financials.sh" "$SYMBOL" cashflow 5 annual)

# Validate data
for data in "$income" "$balance" "$cashflow"; do
    if echo "$data" | jq -e '.error' > /dev/null 2>&1; then
        echo "ERROR: Failed to fetch financial data"
        echo "$data" | jq -r '.message'
        exit 1
    fi
done
```

**Revenue Analysis** (5-year trend):

```bash
# Extract revenue and calculate growth
echo "$income" | jq -r '.[] | [.date, .revenue] | @tsv' | while IFS=$'\t' read -r date revenue; do
    echo "Revenue ($date): \$$(echo "scale=2; $revenue / 1000000000" | bc)B"
done

# Calculate CAGR
oldest_revenue=$(echo "$income" | jq -r '.[-1].revenue')
latest_revenue=$(echo "$income" | jq -r '.[0].revenue')
years=$(echo "$income" | jq 'length')

revenue_cagr=$(echo "scale=2; (($latest_revenue / $oldest_revenue)^(1/($years-1)) - 1) * 100" | bc -l)
echo "Revenue CAGR (5Y): ${revenue_cagr}%"
```

**Profitability Analysis**:

```bash
# Analyze margin trends
echo "Margin Analysis:"
echo "$income" | jq -r '.[] | [.date, .grossProfitRatio, .operatingIncomeRatio, .netIncomeRatio] | @tsv' | \
    while IFS=$'\t' read -r date gross_margin op_margin net_margin; do
        echo "  $date: Gross ${gross_margin}%, Operating ${op_margin}%, Net ${net_margin}%"
    done

# Compare to industry (requires sector average - implement if available)
```

**Cash Flow Analysis**:

```bash
# Calculate Free Cash Flow (OCF - CapEx)
echo "Free Cash Flow:"
echo "$cashflow" | jq -r '.[] | [.date, .operatingCashFlow, .capitalExpenditure, (.operatingCashFlow - .capitalExpenditure)] | @tsv' | \
    while IFS=$'\t' read -r date ocf capex fcf; do
        echo "  $date: OCF \$$(echo "scale=0; $ocf/1000000" | bc)M - CapEx \$$(echo "scale=0; $capex/1000000" | bc)M = FCF \$$(echo "scale=0; $fcf/1000000" | bc)M"
    done
```

**Balance Sheet Strength**:

```bash
# Fetch ratios
ratios=$(bash "$SCRIPTS/fmp-ratios.sh" "$SYMBOL" ratios 1)

debt_equity=$(echo "$ratios" | jq -r '.[0].debtEquityRatio')
current_ratio=$(echo "$ratios" | jq -r '.[0].currentRatio')
quick_ratio=$(echo "$ratios" | jq -r '.[0].quickRatio')

echo "Leverage: Debt/Equity = $debt_equity"
echo "Liquidity: Current Ratio = $current_ratio, Quick Ratio = $quick_ratio"

# Assess strength
if (( $(echo "$debt_equity < 0.5" | bc -l) )); then
    echo "✓ Conservative leverage"
elif (( $(echo "$debt_equity < 1.5" | bc -l) )); then
    echo "⚠ Moderate leverage"
else
    echo "⚠ High leverage - requires scrutiny"
fi
```
```

#### 4.2.4 Update Section 3: Valuation Analysis (Replace Lines 75-100)

```markdown
#### 3. Valuation Analysis

**Fetch Valuation Metrics**:

```bash
profile=$(bash "$SCRIPTS/fmp-profile.sh" "$SYMBOL")
ratios=$(bash "$SCRIPTS/fmp-ratios.sh" "$SYMBOL" ratios 1)
metrics=$(bash "$SCRIPTS/fmp-ratios.sh" "$SYMBOL" metrics 1)

# Extract key metrics
price=$(echo "$profile" | jq -r '.price')
pe_ratio=$(echo "$ratios" | jq -r '.[0].priceEarningsRatio')
pb_ratio=$(echo "$ratios" | jq -r '.[0].priceToBookRatio')
ps_ratio=$(echo "$ratios" | jq -r '.[0].priceToSalesRatioTTM')
peg_ratio=$(echo "$metrics" | jq -r '.[0].pegRatio')
ev_ebitda=$(echo "$metrics" | jq -r '.[0].enterpriseValueOverEBITDA')

echo "Current Price: \$$price"
echo "P/E Ratio: $pe_ratio"
echo "P/B Ratio: $pb_ratio"
echo "P/S Ratio: $ps_ratio"
echo "PEG Ratio: $peg_ratio"
echo "EV/EBITDA: $ev_ebitda"
```

**Compare to Industry**:

```bash
# Get sector and industry
sector=$(echo "$profile" | jq -r '.sector')
industry=$(echo "$profile" | jq -r '.industry')

# Screen for peers in same industry
peers=$(bash "$SCRIPTS/fmp-screener.sh" \
    --sector="$sector" \
    --marketCapMoreThan=1000000000 \
    --limit=20)

# Calculate median P/E for comparison (simplified)
peer_symbols=$(echo "$peers" | jq -r '.[].symbol' | grep -v "^${SYMBOL}$" | head -10 | paste -sd,)
peer_quotes=$(bash "$SCRIPTS/fmp-quote.sh" "$peer_symbols")

median_pe=$(echo "$peer_quotes" | jq -r '.[].pe' | sort -n | awk '{arr[NR]=$1} END {if (NR%2) print arr[(NR+1)/2]; else print (arr[NR/2]+arr[NR/2+1])/2}')

echo "Industry Median P/E: $median_pe"

# Compare
if (( $(echo "$pe_ratio < $median_pe * 0.8" | bc -l) )); then
    echo "✓ Undervalued vs peers (P/E $pe_ratio vs median $median_pe)"
elif (( $(echo "$pe_ratio < $median_pe * 1.2" | bc -l) )); then
    echo "≈ Fairly valued vs peers"
else
    echo "⚠ Overvalued vs peers (P/E $pe_ratio vs median $median_pe)"
fi
```

**DCF Valuation** (simplified):

```bash
# Estimate intrinsic value using simplified DCF
fcf_latest=$(echo "$cashflow" | jq -r '.[0].freeCashFlow // (.[0].operatingCashFlow - .[0].capitalExpenditure)')
shares_out=$(echo "$profile" | jq -r '.mktCap / .price')

# Assume 8% discount rate, 3% terminal growth
# 5-year DCF calculation (simplified)
intrinsic_value=$(echo "scale=2; ($fcf_latest * 5) / $shares_out" | bc -l)

echo "Estimated Intrinsic Value (simplified DCF): \$$intrinsic_value"
echo "Current Price: \$$price"

margin_of_safety=$(echo "scale=2; (($intrinsic_value - $price) / $intrinsic_value) * 100" | bc -l)
echo "Margin of Safety: ${margin_of_safety}%"
```
```

#### 4.2.5 Add FMP Data Validation Section (Before "Output Format")

```markdown
## FMP Data Validation

Validate all FMP data before proceeding with analysis.

**Pre-Analysis Checks**:

```bash
validate_financial_data() {
    local data="$1"
    local data_type="$2"

    # Check for error
    if echo "$data" | jq -e '.error' > /dev/null 2>&1; then
        echo "ERROR: $data_type fetch failed - $(echo "$data" | jq -r '.message')"
        return 1
    fi

    # Check array not empty
    local count=$(echo "$data" | jq 'length')
    if [[ $count -eq 0 ]]; then
        echo "ERROR: No $data_type data returned"
        return 1
    fi

    # Check data freshness
    local latest_date=$(echo "$data" | jq -r '.[0].date')
    local days_old=$(( ($(date +%s) - $(date -j -f "%Y-%m-%d" "$latest_date" +%s 2>/dev/null || echo 0)) / 86400 ))

    if [[ $days_old -gt 540 ]]; then  # 18 months
        echo "⚠️ WARNING: $data_type is $days_old days old (date: $latest_date)"
    fi

    # Check required fields exist
    if [[ "$data_type" == "income" ]]; then
        local revenue=$(echo "$data" | jq -r '.[0].revenue // null')
        if [[ "$revenue" == "null" ]]; then
            echo "ERROR: Missing revenue field in income data"
            return 1
        fi
    fi

    return 0
}

# Validate all fetched data
validate_financial_data "$income" "income" || exit 1
validate_financial_data "$balance" "balance" || exit 1
validate_financial_data "$cashflow" "cashflow" || exit 1

echo "✓ All financial data validated"
```

**Data Completeness Check**:

```bash
# Check for 5 years of data
years=$(echo "$income" | jq 'length')
if [[ $years -lt 5 ]]; then
    echo "⚠️ WARNING: Only $years years of data available (expected 5)"
    echo "   This may affect trend analysis accuracy"
fi
```

**Alert on Data Issues** (include in report):

```markdown
## Data Quality Alerts

⚠️ Financial data for {{SYMBOL}} is 15 months old (last update: {{DATE}})
✓ All other data quality checks passed
```
```

---

### 4.3 Technical Analyst Agent

**File**: `.claude/agents/apex-os-technical-analyst.md`

**Modifications**: [Similar structure to Fundamental Analyst - updating tool list, adding FMP integration section, updating workflow steps with FMP API calls]

#### 4.3.1 YAML Frontmatter (Line 4)

**Before**:
```yaml
tools: Write, Read, Bash, WebFetch
```

**After**:
```yaml
tools: Write, Read, Bash
```

#### 4.3.2 Add FMP Integration Section

```markdown
## FMP API Integration

All price data and technical indicators fetched from FMP API.

### Required Scripts

```bash
SCRIPTS="/Users/nazymazimbayev/apex-os-1/scripts/fmp"

# Current quote
$SCRIPTS/fmp-quote.sh SYMBOL

# Historical data
$SCRIPTS/fmp-historical.sh SYMBOL [FROM] [TO] [LIMIT] [INTERVAL]

# Technical indicators
$SCRIPTS/fmp-indicators.sh SYMBOL TYPE [PERIOD] [TIMEFRAME]
```

### Standard Data Fetch

```bash
SYMBOL="AAPL"
SCRIPTS="/Users/nazymazimbayev/apex-os-1/scripts/fmp"

# Current quote
quote=$(bash "$SCRIPTS/fmp-quote.sh" "$SYMBOL")
price=$(echo "$quote" | jq -r '.[0].price')

# Historical data (500 days for reliable calculations)
historical=$(bash "$SCRIPTS/fmp-historical.sh" "$SYMBOL" "" "" 500)

# Moving averages
sma20=$(bash "$SCRIPTS/fmp-indicators.sh" "$SYMBOL" sma 20 daily)
sma50=$(bash "$SCRIPTS/fmp-indicators.sh" "$SYMBOL" sma 50 daily)
sma200=$(bash "$SCRIPTS/fmp-indicators.sh" "$SYMBOL" sma 200 daily)

# Momentum indicators
rsi=$(bash "$SCRIPTS/fmp-indicators.sh" "$SYMBOL" rsi 14 daily)
adx=$(bash "$SCRIPTS/fmp-indicators.sh" "$SYMBOL" adx 14 daily)
```
```

#### 4.3.3 Update Trend Analysis Section

```markdown
#### 1. Trend Analysis

**Fetch Multi-Timeframe Data**:

```bash
# Daily chart (500 days for reliable MA calculations)
daily=$(bash "$SCRIPTS/fmp-historical.sh" "$SYMBOL" "" "" 500)

# Validate
if echo "$daily" | jq -e '.error' > /dev/null 2>&1; then
    echo "ERROR: Failed to fetch historical data"
    exit 1
fi

count=$(echo "$daily" | jq 'length')
echo "Fetched $count days of historical data"
```

**Fetch Moving Averages**:

```bash
sma20=$(bash "$SCRIPTS/fmp-indicators.sh" "$SYMBOL" sma 20 daily)
sma50=$(bash "$SCRIPTS/fmp-indicators.sh" "$SYMBOL" sma 50 daily)
sma200=$(bash "$SCRIPTS/fmp-indicators.sh" "$SYMBOL" sma 200 daily)

# Extract latest values
ma20=$(echo "$sma20" | jq -r '.[0].sma')
ma50=$(echo "$sma50" | jq -r '.[0].sma')
ma200=$(echo "$sma200" | jq -r '.[0].sma')

# Get current price
quote=$(bash "$SCRIPTS/fmp-quote.sh" "$SYMBOL")
price=$(echo "$quote" | jq -r '.[0].price')

echo "Price: \$$price"
echo "MA(20): \$$ma20"
echo "MA(50): \$$ma50"
echo "MA(200): \$$ma200"

# Determine trend
if (( $(echo "$price > $ma20 && $ma20 > $ma50 && $ma50 > $ma200" | bc -l) )); then
    echo "✓ Strong uptrend (all MAs aligned)"
    trend="uptrend"
elif (( $(echo "$price > $ma50" | bc -l) )); then
    echo "≈ Uptrend (above MA50)"
    trend="uptrend"
elif (( $(echo "$price < $ma50" | bc -l) )); then
    echo "≈ Downtrend (below MA50)"
    trend="downtrend"
else
    echo "≈ Sideways/Consolidation"
    trend="sideways"
fi
```

**Trend Strength (ADX)**:

```bash
adx_data=$(bash "$SCRIPTS/fmp-indicators.sh" "$SYMBOL" adx 14 daily)
adx=$(echo "$adx_data" | jq -r '.[0].adx')

if (( $(echo "$adx > 25" | bc -l) )); then
    echo "✓ Strong trend (ADX: $adx)"
elif (( $(echo "$adx > 20" | bc -l) )); then
    echo "≈ Moderate trend (ADX: $adx)"
else
    echo "⚠ Weak/no trend (ADX: $adx)"
fi
```
```

---

### 4.4 Portfolio Monitor Agent

**File**: `.claude/agents/apex-os-portfolio-monitor.md`

**Modifications**:

#### 4.4.1 Add FMP Integration Section

```markdown
## FMP API Integration

Use FMP for real-time price tracking of open positions.

### Batch Quote Pattern

```bash
SCRIPTS="/Users/nazymazimbayev/apex-os-1/scripts/fmp"

# Read open positions and extract symbols
positions_file="/Users/nazymazimbayev/apex-os-1/positions/open-positions.yaml"
symbols=$(yq e '.positions[].symbol' "$positions_file" | paste -sd,)

# Fetch all quotes in single API call
quotes=$(bash "$SCRIPTS/fmp-quote.sh" "$symbols")

# Check for errors
if echo "$quotes" | jq -e '.error' > /dev/null 2>&1; then
    echo "ERROR: Failed to fetch batch quotes"
    echo "$quotes" | jq -r '.message'
    exit 1
fi

# Process each position
echo "$quotes" | jq -c '.[]' | while read -r quote; do
    symbol=$(echo "$quote" | jq -r '.symbol')
    price=$(echo "$quote" | jq -r '.price')
    change_pct=$(echo "$quote" | jq -r '.changesPercentage')

    echo "$symbol: \$$price ($change_pct%)"
done
```
```

#### 4.4.2 Update Price Checking Logic

```markdown
#### Step 2: Check Current Prices

**Fetch Batch Quotes for All Open Positions**:

```bash
SCRIPTS="/Users/nazymazimbayev/apex-os-1/scripts/fmp"
positions_file="/Users/nazymazimbayev/apex-os-1/positions/open-positions.yaml"

# Extract symbols
symbols=$(yq e '.positions[].symbol' "$positions_file" | paste -sd,)

if [[ -z "$symbols" ]]; then
    echo "No open positions to monitor"
    exit 0
fi

# Get batch quotes
all_quotes=$(bash "$SCRIPTS/fmp-quote.sh" "$symbols")

# Validate
if echo "$all_quotes" | jq -e '.error' > /dev/null 2>&1; then
    echo "ERROR: Failed to fetch quotes - $(echo "$all_quotes" | jq -r '.message')"
    exit 1
fi

echo "✓ Fetched quotes for $(echo "$all_quotes" | jq 'length') positions"
```

**Process Each Position**:

```bash
echo "$all_quotes" | jq -c '.[]' | while read -r quote; do
    symbol=$(echo "$quote" | jq -r '.symbol')
    current_price=$(echo "$quote" | jq -r '.price')
    day_change=$(echo "$quote" | jq -r '.changesPercentage')
    volume=$(echo "$quote" | jq -r '.volume')

    # Read position data from YAML
    entry_price=$(yq e ".positions[] | select(.symbol == \"$symbol\") | .entry_price" "$positions_file")
    entry_date=$(yq e ".positions[] | select(.symbol == \"$symbol\") | .entry_date" "$positions_file")
    stop_loss=$(yq e ".positions[] | select(.symbol == \"$symbol\") | .stop_loss" "$positions_file")
    target1=$(yq e ".positions[] | select(.symbol == \"$symbol\") | .target1" "$positions_file")
    shares=$(yq e ".positions[] | select(.symbol == \"$symbol\") | .shares" "$positions_file")

    # Calculate metrics
    pct_change=$(echo "scale=2; (($current_price - $entry_price) / $entry_price) * 100" | bc -l)
    pnl=$(echo "scale=2; ($current_price - $entry_price) * $shares" | bc -l)
    days_held=$(( ($(date +%s) - $(date -j -f "%Y-%m-%d" "$entry_date" +%s)) / 86400 ))

    # Distance to levels
    dist_to_stop=$(echo "scale=2; (($current_price - $stop_loss) / $current_price) * 100" | bc -l)
    dist_to_target=$(echo "scale=2; (($target1 - $current_price) / $current_price) * 100" | bc -l)

    # Generate position report
    echo "## $symbol"
    echo "Current: \$$current_price (Day: $day_change%)"
    echo "Position: $shares shares @ \$$entry_price entry ($days_held days held)"
    echo "P&L: \$$pnl ($pct_change%)"
    echo "Stop Loss: \$$stop_loss ($dist_to_stop% away)"
    echo "Target 1: \$$target1 ($dist_to_target% away)"

    # Check for alerts
    if (( $(echo "$current_price <= $stop_loss" | bc -l) )); then
        echo "🚨 ALERT: Stop loss hit!"
    elif (( $(echo "$current_price >= $target1" | bc -l) )); then
        echo "✓ Target 1 reached!"
    fi
done
```
```

---

## 5. Implementation Roadmap

### 5.1 Phase 1: Create Helper Scripts

**Estimated Time**: 2-3 days

**Tasks**:

1. **Create fmp-common.sh** (Day 1, 4 hours)
   - Implement load_api_key()
   - Implement fmp_api_call()
   - Implement format_error()
   - Implement map_http_error()
   - Implement validate_symbol()
   - Implement check_rate_limit()
   - Test all functions individually

2. **Create fmp-quote.sh** (Day 1, 2 hours)
   - Implement single quote fetch
   - Implement batch quote fetch
   - Add validation
   - Test with real API

3. **Create fmp-financials.sh** (Day 1, 2 hours)
   - Support income, balance, cashflow
   - Add period/limit parameters
   - Test data parsing

4. **Create fmp-ratios.sh** (Day 2, 2 hours)
   - Support ratios, metrics, growth
   - Test calculations

5. **Create fmp-profile.sh** (Day 2, 1 hour)
   - Simple profile fetch
   - Test data extraction

6. **Create fmp-historical.sh** (Day 2, 3 hours)
   - Daily historical data
   - Intraday data support
   - Date range handling

7. **Create fmp-screener.sh** (Day 2, 2 hours)
   - Implement screener with parameters
   - Market movers (gainers/losers/actives)
   - Test filtering

8. **Create fmp-indicators.sh** (Day 3, 2 hours)
   - Support SMA, EMA, RSI, ADX, MACD
   - Test indicator calculations

9. **Create README.md** (Day 3, 1 hour)
   - Document all scripts
   - Usage examples
   - Error handling guide

**Dependencies**:
- fmp-common.sh MUST be completed first
- All other scripts depend on fmp-common.sh
- Can be parallelized after fmp-common.sh is done

**Testing Approach**:
- Unit test each script individually
- Test error scenarios (invalid symbol, rate limit, etc.)
- Validate JSON parsing
- Check rate limit handling

---

### 5.2 Phase 2: Modify Agents

**Estimated Time**: 3-4 days

**Tasks**:

1. **Update Market Scanner Agent** (Day 4, 6 hours)
   - Update YAML frontmatter
   - Add FMP Integration section
   - Update Step 1: Run Systematic Scans
   - Update Step 2: Initial Filtering
   - Add Data Quality Checks
   - Test full scanning workflow

2. **Update Fundamental Analyst Agent** (Day 5, 8 hours)
   - Update YAML frontmatter
   - Add FMP Integration section
   - Update Section 1: Financial Health Analysis
   - Update Section 2: Competitive Analysis
   - Update Section 3: Valuation Analysis
   - Add FMP Data Validation section
   - Test full analysis workflow

3. **Update Technical Analyst Agent** (Day 6, 6 hours)
   - Update YAML frontmatter
   - Add FMP Integration section
   - Update Section 1: Trend Analysis
   - Update Section 2: Support & Resistance
   - Update Section 5: Technical Indicators
   - Test full analysis workflow

4. **Update Portfolio Monitor Agent** (Day 7, 4 hours)
   - Add FMP Integration section
   - Update Step 2: Check Current Prices
   - Update Step 3: Evaluate Thesis Validity
   - Add Data Quality section
   - Test monitoring workflow

**Dependencies**:
- All helper scripts must be completed
- Agents can be modified in parallel
- Each agent should be tested after modification

**Testing Approach**:
- Test each agent independently
- Verify FMP data fetching
- Check error handling
- Validate report generation

---

### 5.3 Phase 3: Integration Testing

**Estimated Time**: 2 days

**Tasks**:

1. **End-to-End Workflow Test** (Day 8, 4 hours)
   - Run market scanner → verify opportunities created
   - Run fundamental analyst on opportunity → verify report
   - Run technical analyst on opportunity → verify analysis
   - Verify all FMP data flows correctly

2. **Error Scenario Testing** (Day 8, 2 hours)
   - Test invalid symbols
   - Test rate limit handling
   - Test network failures
   - Test missing data scenarios

3. **Performance Testing** (Day 8, 2 hours)
   - Measure API call counts
   - Measure workflow completion times
   - Verify rate limit compliance
   - Optimize batch requests

4. **Data Quality Validation** (Day 9, 4 hours)
   - Verify data freshness checks
   - Test validation logic
   - Check alert mechanisms
   - Validate error reporting

**Success Criteria**:
- All agents fetch data successfully from FMP
- No WebFetch references remain
- All error scenarios handled gracefully
- Performance benchmarks met
- Data quality checks working

---

### 5.4 Phase 4: Documentation

**Estimated Time**: 1 day

**Tasks**:

1. **Create Helper Scripts README** (Day 9, 2 hours)
   - Document each script
   - Provide usage examples
   - Document error codes
   - Add troubleshooting guide

2. **Create Migration Guide** (Day 9, 2 hours)
   - Before/after comparison
   - Migration benefits
   - Testing procedures
   - Rollback plan

3. **Update Main README** (Day 9, 1 hour)
   - Document FMP integration
   - Add setup instructions
   - Update prerequisites

4. **Create FMP API Reference** (Day 9, 1 hour)
   - Key endpoints used
   - Rate limits
   - Response formats
   - Best practices

---

## 6. Testing Strategy

### 6.1 Unit Testing (Helper Scripts)

**Test fmp-common.sh**:

```bash
# Test load_api_key
test_load_api_key() {
    # Test with valid .env
    load_api_key
    assert_equal $? 0
    assert_not_empty "$FMP_API_KEY"

    # Test with missing .env
    mv .env .env.bak
    load_api_key
    assert_equal $? 1
    mv .env.bak .env
}

# Test fmp_api_call
test_fmp_api_call() {
    # Test valid endpoint
    response=$(fmp_api_call "/v3/quote/AAPL")
    assert_equal $? 0
    assert_json "$response"

    # Test invalid endpoint
    response=$(fmp_api_call "/v3/invalid")
    assert_equal $? 1
    echo "$response" | jq -e '.error'
    assert_equal $? 0
}

# Test validate_symbol
test_validate_symbol() {
    validate_symbol "AAPL"
    assert_equal $? 0

    validate_symbol ""
    assert_equal $? 1

    validate_symbol "123"
    assert_equal $? 1
}
```

**Test fmp-quote.sh**:

```bash
test_quote_single() {
    quote=$(bash fmp-quote.sh AAPL)
    assert_json "$quote"
    symbol=$(echo "$quote" | jq -r '.[0].symbol')
    assert_equal "$symbol" "AAPL"
}

test_quote_batch() {
    quotes=$(bash fmp-quote.sh "AAPL,MSFT,GOOGL")
    count=$(echo "$quotes" | jq 'length')
    assert_equal "$count" "3"
}

test_quote_invalid_symbol() {
    quote=$(bash fmp-quote.sh "INVALID999")
    echo "$quote" | jq -e '.error'
    assert_equal $? 0
}
```

**Test All Other Scripts**: Similar unit test patterns

---

### 6.2 Integration Testing (Agents)

**Test Market Scanner**:

```bash
test_market_scanner() {
    # Run scanner
    /apex-os-scan-market

    # Check output file created
    scan_file="opportunities/scan-$(date +%Y-%m-%d).md"
    assert_file_exists "$scan_file"

    # Verify opportunities documented
    grep -q "## Opportunity" "$scan_file"
    assert_equal $? 0

    # Verify FMP data present
    grep -q "Market Cap:" "$scan_file"
    assert_equal $? 0
}
```

**Test Fundamental Analyst**:

```bash
test_fundamental_analyst() {
    # Run analyst on known symbol
    /apex-os-analyze-stock AAPL

    # Check report created
    report="analysis/$(date +%Y-%m-%d)-AAPL/fundamental-report.md"
    assert_file_exists "$report"

    # Verify sections present
    grep -q "## Financial Health" "$report"
    assert_equal $? 0

    # Verify FMP data
    grep -q "Revenue" "$report"
    assert_equal $? 0
}
```

**Test Technical Analyst**: Similar pattern

**Test Portfolio Monitor**: Similar pattern

---

### 6.3 End-to-End Workflow Tests

**Complete Trading Workflow**:

```bash
test_complete_workflow() {
    echo "=== Phase 0: Scan Market ==="
    /apex-os-scan-market
    scan_file="opportunities/scan-$(date +%Y-%m-%d).md"
    assert_file_exists "$scan_file"

    # Extract first opportunity symbol
    symbol=$(grep "^## " "$scan_file" | head -1 | awk '{print $2}')
    echo "Testing with symbol: $symbol"

    echo "=== Phase 1: Fundamental Analysis ==="
    /apex-os-analyze-stock "$symbol"
    fundamental_report="analysis/$(date +%Y-%m-%d)-${symbol}/fundamental-report.md"
    assert_file_exists "$fundamental_report"

    echo "=== Phase 1: Technical Analysis ==="
    # Technical analyst runs in parallel
    technical_report="analysis/$(date +%Y-%m-%d)-${symbol}/technical-report.md"
    assert_file_exists "$technical_report"

    echo "=== Phase 2: Thesis Writing ==="
    /apex-os-write-thesis "$symbol"
    thesis="analysis/$(date +%Y-%m)-${symbol}/investment-thesis.md"
    assert_file_exists "$thesis"

    echo "=== Phase 3: Position Planning ==="
    /apex-os-plan-position "$symbol"
    position_plan="analysis/$(date +%Y-%m-%d)-${symbol}/position-plan.md"
    assert_file_exists "$position_plan"

    echo "✓ Complete workflow test passed"
}
```

---

### 6.4 Error Scenario Tests

```bash
test_error_invalid_symbol() {
    # Test all agents with invalid symbol
    /apex-os-analyze-stock "INVALID999" 2>&1 | tee output.log
    grep -q "ERROR" output.log
    assert_equal $? 0
}

test_error_rate_limit() {
    # Make 250 rapid requests to trigger rate limit
    for i in {1..250}; do
        bash fmp-quote.sh AAPL > /dev/null 2>&1
    done

    # Next request should handle rate limit gracefully
    quote=$(bash fmp-quote.sh AAPL 2>&1)
    # Should either succeed or return error (not crash)
    assert_not_empty "$quote"
}

test_error_network_timeout() {
    # Simulate network timeout (requires mocking or firewall rule)
    # Should return timeout error, not crash
}
```

---

### 6.5 Performance Tests

```bash
test_performance_market_scanner() {
    start_time=$(date +%s)
    /apex-os-scan-market
    end_time=$(date +%s)

    duration=$((end_time - start_time))
    echo "Market Scanner Duration: ${duration}s"

    # Should complete in <3 minutes (180s)
    assert_less_than "$duration" 180
}

test_performance_api_calls() {
    # Count API calls made during fundamental analysis
    # Should be <15 calls

    # Reset rate limit tracking
    rm -f /tmp/fmp_rate_*.txt

    /apex-os-analyze-stock AAPL

    # Count logged calls
    call_count=$(cat /tmp/fmp_rate_*.txt | wc -l)
    echo "API Calls Made: $call_count"

    assert_less_than "$call_count" 15
}
```

---

## 7. Error Handling & Recovery

### 7.1 Standard Error Format

All FMP helper scripts return errors in this JSON format:

```json
{
  "error": true,
  "type": "error_category",
  "message": "User-friendly description",
  "timestamp": "2025-11-11T12:00:00Z"
}
```

**Error Categories**:
- `missing_api_key`: FMP_API_KEY not found in .env
- `invalid_symbol`: Symbol validation failed
- `invalid_params`: Missing or invalid parameters
- `rate_limit`: API rate limit exceeded (HTTP 429)
- `http_error`: HTTP error (400, 401, 403, 404, 500, etc.)
- `timeout`: Request timeout (>30s)
- `invalid_response`: Non-JSON or malformed response
- `missing_data`: Valid response but missing expected fields
- `network_error`: Network connectivity issue

---

### 7.2 Retry Logic Specification

**Automatic Retry Conditions**:
- HTTP 429 (rate limit) - retry with exponential backoff
- HTTP 500/503 (server errors) - retry with exponential backoff
- Network timeout - retry
- Connection refused - retry

**Do NOT Retry**:
- HTTP 400 (bad request) - fix parameters
- HTTP 401 (unauthorized) - fix API key
- HTTP 404 (not found) - invalid symbol/endpoint

**Implementation**:

```bash
max_retries=3
retry_count=0

while [[ $retry_count -lt $max_retries ]]; do
    response=$(curl -s -w "\n%{http_code}" --max-time 30 "$url")
    http_code=$(echo "$response" | tail -n 1)
    response=$(echo "$response" | sed '$d')

    if [[ "$http_code" == "200" ]]; then
        # Success
        echo "$response"
        return 0
    elif [[ "$http_code" == "429" ]] || [[ "$http_code" == "500" ]] || [[ "$http_code" == "503" ]]; then
        # Retry with exponential backoff
        retry_count=$((retry_count + 1))
        sleep_time=$((2 ** retry_count))
        echo "Retry $retry_count after ${sleep_time}s..." >&2
        sleep "$sleep_time"
    else
        # Don't retry other errors
        map_http_error "$http_code" "$endpoint"
        return 1
    fi
done

# Max retries exceeded
format_error "timeout" "Max retries exceeded"
return 1
```

---

### 7.3 Rate Limit Handling

**FMP Rate Limits** (Paid Tier):
- 250 requests/minute
- 750 requests/hour
- 50,000 requests/day

**Strategy**:
1. Track calls per minute using temp file
2. Sleep if approaching limit (240/250)
3. Clear old tracking files
4. Batch requests when possible

**Implementation**:

```bash
check_rate_limit() {
    local rate_file="/tmp/fmp_rate_$(date +%Y%m%d_%H%M).txt"
    local count=$(wc -l < "$rate_file" 2>/dev/null || echo 0)

    if [[ $count -ge 240 ]]; then
        echo "WARNING: Approaching rate limit ($count/250), sleeping 10s..." >&2
        sleep 10
        # Clear old files
        find /tmp -name "fmp_rate_*.txt" -mmin +2 -delete
        rate_file="/tmp/fmp_rate_$(date +%Y%m%d_%H%M).txt"
    fi

    echo "$(date +%s)" >> "$rate_file"
}
```

**Batch Request Optimization**:

```bash
# Instead of multiple single quotes:
# for symbol in AAPL MSFT GOOGL; do
#     bash fmp-quote.sh "$symbol"  # 3 API calls
# done

# Use batch quote:
bash fmp-quote.sh "AAPL,MSFT,GOOGL"  # 1 API call
```

---

### 7.4 Agent-Level Error Handling

**Pattern for All Agents**:

```bash
# Fetch data
data=$(bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-quote.sh AAPL)

# Check for error
if echo "$data" | jq -e '.error' > /dev/null 2>&1; then
    error_type=$(echo "$data" | jq -r '.type')
    error_msg=$(echo "$data" | jq -r '.message')

    # Log error
    echo "ERROR: FMP API call failed" >&2
    echo "  Type: $error_type" >&2
    echo "  Message: $error_msg" >&2

    # Decide: retry, fallback, or fail
    case "$error_type" in
        rate_limit)
            echo "Rate limit hit - sleeping 30s before retry..." >&2
            sleep 30
            # Retry once
            data=$(bash /Users/nazymazimbayev/apex-os-1/scripts/fmp/fmp-quote.sh AAPL)
            ;;
        invalid_symbol)
            echo "Invalid symbol - cannot proceed" >&2
            exit 1
            ;;
        *)
            echo "Unexpected error - check logs" >&2
            exit 1
            ;;
    esac
fi

# Proceed with data
price=$(echo "$data" | jq -r '.[0].price')
```

**Include Errors in Reports**:

```markdown
## Data Issues

⚠️ WARNING: Unable to fetch analyst recommendations due to rate limit
⚠️ WARNING: Financial data is 15 months old (last update: 2022-09-30)
✓ All other data fetched successfully
```

---

## 8. Quality Assurance

### 8.1 Code Review Checklist

**For Helper Scripts**:
- [ ] Sources fmp-common.sh correctly
- [ ] Validates all input parameters
- [ ] Checks for API errors
- [ ] Returns standardized error format
- [ ] Uses jq for JSON parsing
- [ ] Handles empty responses
- [ ] Logs errors to stderr
- [ ] Exits with appropriate code (0=success, 1=error)
- [ ] Documented usage in comments
- [ ] Tested with valid and invalid inputs

**For Agent Modifications**:
- [ ] WebFetch removed from tools list
- [ ] FMP Integration section added
- [ ] All WebFetch calls replaced with FMP helper scripts
- [ ] Error handling implemented for all API calls
- [ ] Data validation added
- [ ] Quality checks included
- [ ] Maintains original workflow structure
- [ ] Reports include FMP data sources
- [ ] Tested end-to-end

---

### 8.2 Data Validation Requirements

**All Agents Must Validate**:

```bash
validate_fmp_response() {
    local response="$1"
    local expected_type="$2"  # "array" or "object"

    # Check for error
    if echo "$response" | jq -e '.error' > /dev/null 2>&1; then
        return 1
    fi

    # Check type
    actual_type=$(echo "$response" | jq -r 'type')
    if [[ "$actual_type" != "$expected_type" ]]; then
        echo "ERROR: Expected $expected_type, got $actual_type" >&2
        return 1
    fi

    # Check not empty (for arrays)
    if [[ "$expected_type" == "array" ]]; then
        count=$(echo "$response" | jq 'length')
        if [[ $count -eq 0 ]]; then
            echo "ERROR: Empty array returned" >&2
            return 1
        fi
    fi

    return 0
}

# Usage
data=$(bash fmp-quote.sh AAPL)
if ! validate_fmp_response "$data" "array"; then
    echo "Validation failed"
    exit 1
fi
```

---

### 8.3 Performance Benchmarks

**Target Metrics**:

| Metric | Target | Measurement |
|--------|--------|-------------|
| Market Scanner | <3 min | Time from start to report creation |
| Fundamental Analyst | <2 min | Time to fetch all data |
| Technical Analyst | <2 min | Time to fetch all data |
| Portfolio Monitor | <1 min | Time for daily report |
| API Calls (Scanner) | <20 calls | Count via rate tracking |
| API Calls (Fundamental) | <15 calls | Count via rate tracking |
| API Calls (Technical) | <10 calls | Count via rate tracking |
| API Calls (Monitor) | <5 calls | Count via rate tracking |

**Measurement Script**:

```bash
#!/usr/bin/env bash
# measure_performance.sh

measure_agent() {
    local agent_name="$1"
    local command="$2"

    # Clear rate tracking
    rm -f /tmp/fmp_rate_*.txt

    # Measure time
    start=$(date +%s)
    eval "$command"
    end=$(date +%s)

    duration=$((end - start))
    api_calls=$(cat /tmp/fmp_rate_*.txt 2>/dev/null | wc -l)

    echo "$agent_name:"
    echo "  Duration: ${duration}s"
    echo "  API Calls: $api_calls"
}

measure_agent "Market Scanner" "/apex-os-scan-market"
measure_agent "Fundamental Analyst" "/apex-os-analyze-stock AAPL"
measure_agent "Technical Analyst" "# runs with fundamental"
measure_agent "Portfolio Monitor" "/apex-os-monitor-portfolio"
```

---

### 8.4 Security Considerations

**API Key Management**:
- ✓ Store in .env file (not in code)
- ✓ Never log API key
- ✓ Load from .env only
- ✓ Validate key exists before API calls
- ✓ Don't include in error messages

**Data Security**:
- ✓ Validate all inputs (prevent injection)
- ✓ Sanitize symbols before API calls
- ✓ Don't execute arbitrary code from API responses
- ✓ Use --max-time in curl (prevent hangs)

**Error Messages**:
- ✓ Don't expose internal paths in production
- ✓ Sanitize error messages before showing to users
- ✓ Log detailed errors to stderr, user-friendly to stdout

---

## 9. Deployment & Migration

### 9.1 Pre-Migration Checklist

Before starting migration:

- [ ] FMP API key configured in .env
- [ ] Backup current agent files
- [ ] Test FMP API key works (curl test)
- [ ] Review current agent workflows
- [ ] Document current data sources
- [ ] Create rollback plan
- [ ] Set up test environment
- [ ] Allocate time for migration (7-9 days)

### 9.2 Migration Steps

**Step 1: Setup** (Day 0)
```bash
# Create scripts directory
mkdir -p /Users/nazymazimbayev/apex-os-1/scripts/fmp

# Verify .env exists
cat /Users/nazymazimbayev/apex-os-1/.env | grep FMP_API_KEY

# Test API key
curl "https://financialmodelingprep.com/api/v3/quote/AAPL?apikey=$(grep FMP_API_KEY .env | cut -d= -f2)"
```

**Step 2: Create Helper Scripts** (Days 1-3)
```bash
# Create each helper script following Phase 1 tasks
# Test each script individually
# Validate error handling

# Verification
ls -la scripts/fmp/
# Should show: fmp-common.sh, fmp-quote.sh, fmp-financials.sh, etc.
```

**Step 3: Backup Agent Files** (Day 4)
```bash
# Backup current agents
cp -r .claude/agents .claude/agents.backup-$(date +%Y%m%d)

# Verify backup
ls -la .claude/agents.backup-*
```

**Step 4: Modify Agents** (Days 4-7)
```bash
# Modify one agent at a time
# Test after each modification
# Verify reports generated correctly

# Test sequence:
# 1. Market Scanner
# 2. Fundamental Analyst
# 3. Technical Analyst
# 4. Portfolio Monitor
```

**Step 5: Integration Testing** (Day 8)
```bash
# Run end-to-end workflow
# Test error scenarios
# Measure performance
# Validate data quality
```

**Step 6: Documentation** (Day 9)
```bash
# Create/update documentation
# Add examples
# Document troubleshooting
```

### 9.3 Validation After Each Step

**After Helper Script Creation**:
```bash
# Test each script
bash scripts/fmp/fmp-quote.sh AAPL
bash scripts/fmp/fmp-financials.sh AAPL income 5 annual
bash scripts/fmp/fmp-ratios.sh AAPL ratios 1
bash scripts/fmp/fmp-profile.sh AAPL
bash scripts/fmp/fmp-historical.sh AAPL "" "" 100
bash scripts/fmp/fmp-screener.sh --type=gainers --limit=10
bash scripts/fmp/fmp-indicators.sh AAPL rsi 14 daily

# All should return valid JSON (not errors)
```

**After Agent Modification**:
```bash
# Test modified agent
/apex-os-scan-market
# Verify: opportunities/scan-YYYY-MM-DD.md created with valid data

/apex-os-analyze-stock AAPL
# Verify: analysis/YYYY-MM-DD-AAPL/fundamental-report.md created
# Verify: analysis/YYYY-MM-DD-AAPL/technical-report.md created

# Check for FMP data in reports
grep "FMP" analysis/YYYY-MM-DD-AAPL/fundamental-report.md
```

### 9.4 Rollback Procedures

**If Migration Fails**:

```bash
# Stop immediately
# Assess issue

# Rollback agents
rm -rf .claude/agents
cp -r .claude/agents.backup-YYYYMMDD .claude/agents

# Verify rollback
cat .claude/agents/apex-os-market-scanner.md | grep "tools:"
# Should show: tools: Write, Read, Bash, WebFetch

# Keep helper scripts (useful for future attempts)
# Document failure reason
echo "Migration failed: [REASON]" >> migration-log.txt
```

**Partial Rollback**:
```bash
# Rollback single agent
cp .claude/agents.backup-YYYYMMDD/apex-os-market-scanner.md .claude/agents/

# Keep other modified agents
# Fix issue with rolled-back agent
# Retry
```

### 9.5 Post-Migration Verification

**Complete Verification Checklist**:

- [ ] All helper scripts created and executable
- [ ] All agents modified (WebFetch removed)
- [ ] Market Scanner produces opportunities with FMP data
- [ ] Fundamental Analyst generates complete reports
- [ ] Technical Analyst generates technical analysis
- [ ] Portfolio Monitor tracks positions
- [ ] End-to-end workflow completes successfully
- [ ] No WebFetch calls in any agent
- [ ] Error handling works (test with invalid symbol)
- [ ] Rate limiting functional (no 429 errors)
- [ ] Performance targets met (<5 min workflows)
- [ ] Documentation complete
- [ ] Backup created and validated

**Final Test**:
```bash
# Run complete workflow
./test-complete-workflow.sh

# Should output:
# ✓ Market Scanner: PASS
# ✓ Fundamental Analyst: PASS
# ✓ Technical Analyst: PASS
# ✓ Portfolio Monitor: PASS
# ✓ End-to-End Workflow: PASS
```

---

## 10. Appendices

### Appendix A: FMP API Quick Reference

**Base URL**: `https://financialmodelingprep.com`

**Authentication**: All endpoints require `?apikey=YOUR_KEY`

**Rate Limits** (Paid Tier):
- 250 requests/minute
- 750 requests/hour
- 50,000 requests/day

**Key Endpoints**:

| Endpoint | Purpose | Example |
|----------|---------|---------|
| `/v3/quote/{symbol}` | Real-time quote | `/v3/quote/AAPL` |
| `/v3/quote/{symbol1},{symbol2}` | Batch quotes | `/v3/quote/AAPL,MSFT` |
| `/v3/income-statement/{symbol}` | Income statement | `/v3/income-statement/AAPL?limit=5` |
| `/v3/balance-sheet-statement/{symbol}` | Balance sheet | `/v3/balance-sheet-statement/AAPL` |
| `/v3/cash-flow-statement/{symbol}` | Cash flow | `/v3/cash-flow-statement/AAPL` |
| `/v3/ratios/{symbol}` | Financial ratios | `/v3/ratios/AAPL?limit=5` |
| `/v3/key-metrics/{symbol}` | Key metrics | `/v3/key-metrics/AAPL` |
| `/v3/profile/{symbol}` | Company profile | `/v3/profile/AAPL` |
| `/v3/historical-price-full/{symbol}` | Historical daily | `/v3/historical-price-full/AAPL` |
| `/v3/technical_indicator/daily/{symbol}` | Indicators | `/v3/technical_indicator/daily/AAPL?type=rsi` |
| `/v3/stock-screener` | Stock screener | `/v3/stock-screener?marketCapMoreThan=1B` |
| `/v3/stock_market/gainers` | Top gainers | `/v3/stock_market/gainers` |
| `/v3/stock_market/actives` | Most active | `/v3/stock_market/actives` |

---

### Appendix B: Bash/jq Code Snippets

**Extract Single Field**:
```bash
price=$(echo "$json" | jq -r '.price')
```

**Extract Multiple Fields**:
```bash
read symbol price change < <(echo "$json" | jq -r '[.symbol, .price, .change] | @tsv')
```

**Iterate Array**:
```bash
echo "$json" | jq -c '.[]' | while read -r item; do
    field=$(echo "$item" | jq -r '.field')
    echo "$field"
done
```

**Filter Array**:
```bash
filtered=$(echo "$json" | jq '[.[] | select(.price > 10)]')
```

**Calculate with bc**:
```bash
result=$(echo "scale=2; $a / $b * 100" | bc -l)
```

**Check if field exists**:
```bash
if echo "$json" | jq -e '.field' > /dev/null 2>&1; then
    echo "Field exists"
fi
```

**Date arithmetic**:
```bash
days_ago=$(( ($(date +%s) - $(date -j -f "%Y-%m-%d" "2023-01-01" +%s)) / 86400 ))
```

---

### Appendix C: File Locations

**Helper Scripts**:
```
/Users/nazymazimbayev/apex-os-1/scripts/fmp/
├── README.md
├── fmp-common.sh
├── fmp-quote.sh
├── fmp-financials.sh
├── fmp-ratios.sh
├── fmp-profile.sh
├── fmp-historical.sh
├── fmp-screener.sh
└── fmp-indicators.sh
```

**Agent Files**:
```
/Users/nazymazimbayev/apex-os-1/.claude/agents/
├── apex-os-market-scanner.md
├── apex-os-fundamental-analyst.md
├── apex-os-technical-analyst.md
└── apex-os-portfolio-monitor.md
```

**Configuration**:
```
/Users/nazymazimbayev/apex-os-1/.env
```

**Documentation**:
```
/Users/nazymazimbayev/apex-os-1/
├── fmp-integration-requirements.md
├── fmp-integration-spec.md
└── README.md (to be updated)
```

---

### Appendix D: Glossary

- **FMP**: Financial Modeling Prep API
- **API Key**: Authentication token for FMP API
- **Rate Limit**: Maximum number of API calls allowed per time period
- **Helper Script**: Reusable bash script for FMP API calls
- **Agent**: Specialized APEX-OS component (market-scanner, fundamental-analyst, etc.)
- **jq**: Command-line JSON processor
- **curl**: Command-line HTTP client
- **WebFetch**: Generic web fetching tool (being replaced)
- **Batch Request**: Single API call for multiple symbols
- **OHLCV**: Open, High, Low, Close, Volume (price data format)
- **TTM**: Trailing Twelve Months
- **CAGR**: Compound Annual Growth Rate
- **FCF**: Free Cash Flow (OCF - CapEx)
- **P/E**: Price-to-Earnings Ratio
- **RSI**: Relative Strength Index (technical indicator)
- **SMA**: Simple Moving Average
- **EMA**: Exponential Moving Average
- **ADX**: Average Directional Index (trend strength)

---

**End of Technical Specification**

---

**Document Status**: Complete
**Next Steps**: Proceed to Phase 3 (Create Task List)
