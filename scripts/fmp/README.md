# FMP API Helper Scripts

**Financial Modeling Prep (FMP) API Integration for APEX-OS**

This directory contains Bash helper scripts for accessing Financial Modeling Prep API endpoints. These scripts provide a clean interface for the APEX-OS agents to fetch financial data.

---

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Installation](#installation)
4. [Script Reference](#script-reference)
5. [Error Handling](#error-handling)
6. [Rate Limiting](#rate-limiting)
7. [Common Usage Patterns](#common-usage-patterns)
8. [Troubleshooting](#troubleshooting)

---

## Overview

These helper scripts wrap FMP API endpoints and provide:
- Automatic API key management from `.env`
- Standardized error handling
- Rate limit tracking and management
- JSON response validation
- Retry logic for transient failures

**Scripts Included**:
- `fmp-common.sh` - Shared functions (sourced by all other scripts)
- `fmp-quote.sh` - Real-time stock quotes
- `fmp-financials.sh` - Financial statements (income, balance, cashflow)
- `fmp-ratios.sh` - Financial ratios and metrics
- `fmp-profile.sh` - Company profiles
- `fmp-historical.sh` - Historical price data
- `fmp-screener.sh` - Stock screening
- `fmp-indicators.sh` - Technical indicators

---

## Prerequisites

### 1. FMP API Key

You need a Financial Modeling Prep API key. Get one at: https://financialmodelingprep.com/

### 2. Environment Configuration

Add your API key to `/Users/nazymazimbayev/apex-os-1/.env`:

```bash
FMP_API_KEY="your_api_key_here"
```

### 3. Dependencies

- `bash` 5.x or later
- `curl` for HTTP requests
- `jq` for JSON parsing

Check if installed:
```bash
bash --version
curl --version
jq --version
```

---

## Installation

Scripts are already installed in `/Users/nazymazimbayev/apex-os-1/scripts/fmp/`.

Make all scripts executable (if not already):
```bash
chmod +x /Users/nazymazimbayev/apex-os-1/scripts/fmp/*.sh
```

---

## Script Reference

### fmp-quote.sh

**Purpose**: Fetch real-time stock quotes

**Usage**:
```bash
./fmp-quote.sh SYMBOL[,SYMBOL2,...]
```

**Examples**:
```bash
# Single quote
./fmp-quote.sh AAPL
./fmp-quote.sh AAPL | jq -r '.[0] | "\(.symbol): $\(.price)"'

# Batch quotes
./fmp-quote.sh "AAPL,MSFT,GOOGL"
./fmp-quote.sh "AAPL,MSFT,GOOGL" | jq -r '.[] | [.symbol, .price, .changesPercentage] | @tsv'
```

**Response Fields**: symbol, price, change, changesPercentage, volume, marketCap, dayLow, dayHigh, yearLow, yearHigh, open, previousClose, eps, pe, timestamp

---

### fmp-financials.sh

**Purpose**: Fetch financial statements

**Usage**:
```bash
./fmp-financials.sh SYMBOL TYPE [LIMIT] [PERIOD]
```

**Parameters**:
- `SYMBOL`: Stock ticker
- `TYPE`: `income`, `balance`, or `cashflow`
- `LIMIT`: Number of periods (default: 5)
- `PERIOD`: `annual` or `quarterly` (default: annual)

**Examples**:
```bash
# 5 years of income statements
./fmp-financials.sh AAPL income 5 annual
./fmp-financials.sh AAPL income 5 annual | jq -r '.[] | [.date, .revenue, .netIncome] | @tsv'

# Quarterly cash flow (last 8 quarters)
./fmp-financials.sh AAPL cashflow 8 quarterly

# Balance sheet
./fmp-financials.sh AAPL balance 5 annual | jq -r '.[] | [.date, .totalAssets, .totalLiabilities] | @tsv'
```

**Response Fields**:
- Income: revenue, costOfRevenue, grossProfit, operatingIncome, netIncome, eps, etc.
- Balance: totalAssets, totalLiabilities, totalEquity, cash, inventory, etc.
- Cash Flow: operatingCashFlow, capitalExpenditure, freeCashFlow, etc.

---

### fmp-ratios.sh

**Purpose**: Fetch financial ratios and metrics

**Usage**:
```bash
./fmp-ratios.sh SYMBOL TYPE [LIMIT]
```

**Parameters**:
- `SYMBOL`: Stock ticker
- `TYPE`: `ratios`, `metrics`, or `growth`
- `LIMIT`: Number of periods (default: 5)

**Examples**:
```bash
# Financial ratios
./fmp-ratios.sh AAPL ratios 1
./fmp-ratios.sh AAPL ratios 1 | jq -r '.[0] | "PE: \(.priceEarningsRatio) ROE: \(.returnOnEquity)"'

# Key metrics
./fmp-ratios.sh AAPL metrics 5
./fmp-ratios.sh AAPL metrics 5 | jq -r '.[] | [.date, .revenuePerShare, .netIncomePerShare] | @tsv'

# Growth metrics
./fmp-ratios.sh AAPL growth 5 | jq -r '.[] | [.date, .revenueGrowth, .netIncomeGrowth] | @tsv'
```

**Response Fields**:
- Ratios: priceEarningsRatio, priceToBookRatio, returnOnEquity, returnOnAssets, debtEquityRatio, currentRatio, etc.
- Metrics: revenuePerShare, netIncomePerShare, marketCap, pegRatio, grahamNumber, etc.
- Growth: revenueGrowth, netIncomeGrowth, epsGrowth, assetGrowth, etc.

---

### fmp-profile.sh

**Purpose**: Fetch company profile

**Usage**:
```bash
./fmp-profile.sh SYMBOL
```

**Examples**:
```bash
./fmp-profile.sh AAPL
./fmp-profile.sh AAPL | jq -r '"\(.companyName) - \(.sector) / \(.industry)"'
./fmp-profile.sh AAPL | jq -r '.description'
```

**Response Fields**: companyName, sector, industry, description, CEO, website, country, exchange, marketCap, beta, price, etc.

---

### fmp-historical.sh

**Purpose**: Fetch historical price data

**Usage**:
```bash
./fmp-historical.sh SYMBOL [FROM_DATE] [TO_DATE] [LIMIT] [INTERVAL]
```

**Parameters**:
- `SYMBOL`: Stock ticker
- `FROM_DATE`: Start date (YYYY-MM-DD, optional)
- `TO_DATE`: End date (YYYY-MM-DD, optional)
- `LIMIT`: Number of bars (optional)
- `INTERVAL`: `daily` (default), `1min`, `5min`, `15min`, `30min`, `1hour`, `4hour`

**Examples**:
```bash
# Last 500 days
./fmp-historical.sh AAPL "" "" 500
./fmp-historical.sh AAPL "" "" 500 | jq 'length'

# Specific date range
./fmp-historical.sh AAPL 2023-01-01 2023-12-31
./fmp-historical.sh AAPL 2023-01-01 2023-12-31 | jq -r '.[] | [.date, .close, .volume] | @tsv'

# Intraday data (5-minute)
./fmp-historical.sh AAPL "" "" 100 5min

# Extract OHLCV
./fmp-historical.sh AAPL "" "" 10 | jq -r '.[] | [.date, .open, .high, .low, .close, .volume] | @tsv'
```

**Response Fields**: date, open, high, low, close, volume, adjClose, change, changePercent

---

### fmp-screener.sh

**Purpose**: Stock screening with filters

**Usage**:
```bash
./fmp-screener.sh [--param=value ...]
```

**Parameters**:
- `--type=gainers|losers|actives` (market movers shortcut)
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

**Examples**:
```bash
# Top gainers
./fmp-screener.sh --type=gainers --limit=10
./fmp-screener.sh --type=gainers --limit=10 | jq -r '.[] | [.symbol, .changesPercentage, .price] | @tsv'

# Most active
./fmp-screener.sh --type=actives --limit=20

# Growth stocks: large cap, liquid, expensive stocks
./fmp-screener.sh --marketCapMoreThan=1000000000 --volumeMoreThan=500000 --priceMoreThan=10 --limit=50

# Technology stocks
./fmp-screener.sh --sector=Technology --marketCapMoreThan=1000000000 --limit=30
```

**Response Fields**: symbol, companyName, marketCap, sector, industry, beta, price, volume, change, changesPercentage, etc.

---

### fmp-indicators.sh

**Purpose**: Fetch technical indicators

**Usage**:
```bash
./fmp-indicators.sh SYMBOL INDICATOR_TYPE [PERIOD] [TIMEFRAME]
```

**Parameters**:
- `SYMBOL`: Stock ticker
- `INDICATOR_TYPE`: `sma`, `ema`, `rsi`, `macd`, `adx`, `williams`, `stoch`
- `PERIOD`: Indicator period (default: 14)
- `TIMEFRAME`: `1min`, `5min`, `15min`, `30min`, `1hour`, `4hour`, `daily` (default: daily)

**Examples**:
```bash
# Simple Moving Average (50-day)
./fmp-indicators.sh AAPL sma 50 daily
./fmp-indicators.sh AAPL sma 50 daily | jq -r '.[0:5] | .[] | [.date, .sma] | @tsv'

# Exponential Moving Average (20-day)
./fmp-indicators.sh AAPL ema 20 daily

# RSI (14-period)
./fmp-indicators.sh AAPL rsi 14 daily
./fmp-indicators.sh AAPL rsi 14 daily | jq -r '.[0].rsi'

# ADX (trend strength)
./fmp-indicators.sh AAPL adx 14 daily | jq -r '.[0].adx'

# Intraday 5-minute RSI
./fmp-indicators.sh AAPL rsi 14 5min
```

**Response Fields**: Depends on indicator type (e.g., `sma`, `ema`, `rsi`, `adx`, etc.) plus `date`

---

## Error Handling

All scripts return standardized error JSON when failures occur:

```json
{
  "error": true,
  "type": "error_category",
  "message": "User-friendly description",
  "timestamp": "2025-11-11T21:00:00Z"
}
```

**Error Types**:
- `missing_api_key`: FMP_API_KEY not found in .env
- `invalid_symbol`: Symbol validation failed
- `invalid_params`: Missing or invalid parameters
- `rate_limit`: API rate limit exceeded (429)
- `http_error`: HTTP error (400, 401, 403, 404, 500, etc.)
- `timeout`: Request timeout
- `invalid_response`: Non-JSON or malformed response
- `missing_data`: Valid response but no data
- `network_error`: Network connectivity issue

**Error Handling in Scripts**:
```bash
# Check for errors
response=$(./fmp-quote.sh AAPL)
if echo "$response" | jq -e '.error' > /dev/null 2>&1; then
    error_msg=$(echo "$response" | jq -r '.message')
    echo "ERROR: $error_msg"
    exit 1
else
    price=$(echo "$response" | jq -r '.[0].price')
    echo "Price: $price"
fi
```

---

## Rate Limiting

**FMP Paid Tier Limits**:
- 250 requests per minute
- 750 requests per hour
- 50,000 requests per day

**Automatic Rate Limit Management**:
- Scripts track API calls in `/tmp/fmp_rate_*.txt`
- Approaching 240/250 per minute triggers 10-second sleep
- Rate limit errors (429) trigger automatic retry with exponential backoff
- 3 retry attempts for transient errors

**Manual Rate Limit Check**:
```bash
# View current minute's call count
wc -l /tmp/fmp_rate_$(date +%Y%m%d_%H%M).txt
```

**Best Practices**:
- Use batch quotes when fetching multiple symbols
- Cache results when possible
- Avoid unnecessary repeated calls
- Respect rate limits to prevent API key suspension

---

## Common Usage Patterns

### Pattern 1: Market Scanner Agent

```bash
# Scan for opportunities
gainers=$(./fmp-screener.sh --type=gainers --limit=50)

# Filter by volume and price
filtered=$(echo "$gainers" | jq -r '.[] | select(.avgVolume > 500000 and .price > 10)')

# Get detailed quotes
symbols=$(echo "$filtered" | jq -r '.symbol' | paste -sd,)
quotes=$(./fmp-quote.sh "$symbols")

# Get company profiles
for symbol in $(echo "$filtered" | jq -r '.symbol'); do
    ./fmp-profile.sh "$symbol"
done
```

### Pattern 2: Fundamental Analyst Agent

```bash
SYMBOL="AAPL"

# Fetch all financial data
profile=$(./fmp-profile.sh "$SYMBOL")
income=$(./fmp-financials.sh "$SYMBOL" income 5 annual)
balance=$(./fmp-financials.sh "$SYMBOL" balance 5 annual)
cashflow=$(./fmp-financials.sh "$SYMBOL" cashflow 5 annual)
ratios=$(./fmp-ratios.sh "$SYMBOL" ratios 5)
metrics=$(./fmp-ratios.sh "$SYMBOL" metrics 5)
growth=$(./fmp-ratios.sh "$SYMBOL" growth 5)

# Extract key metrics
company=$(echo "$profile" | jq -r '.companyName')
sector=$(echo "$profile" | jq -r '.sector')
latest_revenue=$(echo "$income" | jq -r '.[0].revenue')
pe_ratio=$(echo "$ratios" | jq -r '.[0].priceEarningsRatio')

# Calculate trends
echo "$income" | jq -r '.[] | [.date, .revenue, .netIncome] | @tsv'
```

### Pattern 3: Technical Analyst Agent

```bash
SYMBOL="AAPL"

# Fetch price data and indicators
quote=$(./fmp-quote.sh "$SYMBOL")
historical=$(./fmp-historical.sh "$SYMBOL" "" "" 500)
sma50=$(./fmp-indicators.sh "$SYMBOL" sma 50 daily)
sma200=$(./fmp-indicators.sh "$SYMBOL" sma 200 daily)
rsi=$(./fmp-indicators.sh "$SYMBOL" rsi 14 daily)
adx=$(./fmp-indicators.sh "$SYMBOL" adx 14 daily)

# Analyze
current_price=$(echo "$quote" | jq -r '.[0].price')
ma50=$(echo "$sma50" | jq -r '.[0].sma')
ma200=$(echo "$sma200" | jq -r '.[0].sma')
rsi_value=$(echo "$rsi" | jq -r '.[0].rsi')

# Determine trend
if (( $(echo "$current_price > $ma50" | bc -l) )); then
    echo "Above 50-day MA: Uptrend"
else
    echo "Below 50-day MA: Downtrend"
fi
```

### Pattern 4: Portfolio Monitor Agent

```bash
# Read open positions (comma-separated symbols)
symbols="AAPL,MSFT,GOOGL"

# Fetch all quotes in single call
quotes=$(./fmp-quote.sh "$symbols")

# Process each position
echo "$quotes" | jq -c '.[]' | while read -r quote; do
    symbol=$(echo "$quote" | jq -r '.symbol')
    price=$(echo "$quote" | jq -r '.price')
    change=$(echo "$quote" | jq -r '.changesPercentage')

    echo "Position: $symbol"
    echo "  Current: \$$price ($change%)"
done
```

---

## Troubleshooting

### Issue: "Invalid API KEY"

**Cause**: FMP_API_KEY not set or invalid

**Solution**:
1. Check `.env` file exists: `ls -la /Users/nazymazimbayev/apex-os-1/.env`
2. Verify API key format: `grep FMP_API_KEY /Users/nazymazimbayev/apex-os-1/.env`
3. Ensure no spaces around `=`: Should be `FMP_API_KEY="key"` not `FMP_API_KEY = "key"`
4. Test API key directly:
```bash
source .env
curl -s "https://financialmodelingprep.com/api/v3/quote/AAPL?apikey=${FMP_API_KEY}" | jq '.'
```

### Issue: Rate Limit Exceeded (429 Error)

**Cause**: Too many API calls in short period

**Solution**:
1. Check current rate:
```bash
wc -l /tmp/fmp_rate_*.txt
```
2. Wait 60 seconds for rate limit window to reset
3. Reduce frequency of calls
4. Use batch requests (e.g., `fmp-quote.sh "AAPL,MSFT,GOOGL"` instead of 3 separate calls)

### Issue: "No data returned"

**Cause**: Invalid symbol or no data available

**Solution**:
1. Verify symbol is correct: Check on Yahoo Finance or FMP website
2. Try different symbol: `./fmp-quote.sh AAPL`
3. Check if data type is available for that symbol (e.g., some symbols may not have full financial statements)

### Issue: Script Permission Denied

**Cause**: Script not executable

**Solution**:
```bash
chmod +x /Users/nazymazimbayev/apex-os-1/scripts/fmp/*.sh
```

### Issue: "jq: command not found"

**Cause**: jq not installed

**Solution**:
```bash
# macOS
brew install jq

# Linux (Ubuntu/Debian)
sudo apt-get install jq

# Linux (CentOS/RHEL)
sudo yum install jq
```

### Issue: Network Timeout

**Cause**: Slow network or FMP API server issue

**Solution**:
1. Check internet connection
2. Retry the request (scripts auto-retry up to 3 times)
3. Check FMP API status: https://financialmodelingprep.com/

### Issue: Malformed JSON Response

**Cause**: FMP API returned non-JSON or HTML error page

**Solution**:
1. Check error message in response
2. Verify API endpoint is correct
3. Test endpoint directly with curl:
```bash
source .env
curl -v "https://financialmodelingprep.com/api/v3/quote/AAPL?apikey=${FMP_API_KEY}"
```

---

## Additional Resources

- **FMP API Documentation**: https://financialmodelingprep.com/developer/docs/
- **FMP API Plans**: https://financialmodelingprep.com/developer/docs/pricing
- **APEX-OS Repository**: https://github.com/AltbridgeInc/apex-os
- **Support**: For APEX-OS issues, file an issue on GitHub

---

**Last Updated**: 2025-11-11
**Version**: 1.0
