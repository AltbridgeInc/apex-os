# FMP API - Clean Stable Data Fetcher

Production-ready bash scripts for fetching financial data from Financial Modeling Prep (FMP) API.

## Features

- **Clean Architecture**: Modular design with separation of concerns
- **Stable API Calls**: Retry logic, rate limiting, proper error handling
- **Organized Data Storage**: Automatic file organization by data type
- **JSON Output**: Structured responses for easy parsing
- **Comprehensive Logging**: Request tracking and debugging support
- **Agent-Ready**: Designed for use by data fetcher agents

## Quick Start

### 1. Setup

Create a `.env` file in your project root with your FMP API key:

```bash
echo "FMP_API_KEY=your_api_key_here" > .env
```

### 2. Usage

All operations use the master script `fmp-fetch.sh`:

```bash
./fmp-fetch.sh <category> <action> [options]
```

### 3. Examples

```bash
# Fetch company profile
./fmp-fetch.sh company profile AAPL

# Fetch financial statements
./fmp-fetch.sh financials income AAPL annual 5

# Get real-time quote
./fmp-fetch.sh quotes quote TSLA

# Fetch earnings transcript
./fmp-fetch.sh earnings transcript AAPL 2024 3

# Get all analyst data
./fmp-fetch.sh analyst all NVDA

# Fetch everything for a symbol
./fmp-fetch.sh bulk everything MSFT
```

## Architecture

### Core Files

- **config.sh** - Configuration and environment setup
- **utils.sh** - Shared utilities, API calls, error handling
- **fmp-fetch.sh** - Master orchestrator script

### Data Fetchers

- **fetch-company.sh** - Company profiles, search, screening, peers
- **fetch-financials.sh** - Income, balance, cashflow, ratios, metrics
- **fetch-quotes.sh** - Real-time quotes, historical prices, intraday
- **fetch-earnings.sh** - Transcripts, earnings data, news
- **fetch-analyst.sh** - Estimates, ratings, price targets
- **fetch-market-movers.sh** - Market gainers, losers, most active stocks
- **fetch-technical.sh** - Technical indicators (SMA, EMA, RSI, ADX, Williams, etc.)

## Categories & Actions

### Company Data

```bash
fmp-fetch.sh company profile AAPL
fmp-fetch.sh company search "Tesla" 10
fmp-fetch.sh company screener 1000000000 10000000000 Technology
fmp-fetch.sh company peers TSLA
```

### Financial Statements

```bash
fmp-fetch.sh financials income AAPL annual 5
fmp-fetch.sh financials balance MSFT quarter 8
fmp-fetch.sh financials cashflow NVDA annual 10
fmp-fetch.sh financials ratios TSLA annual 5
fmp-fetch.sh financials metrics AAPL annual 5
fmp-fetch.sh financials enterprise MSFT annual 5
fmp-fetch.sh financials all NVDA annual 10
```

### Stock Quotes & Prices

```bash
fmp-fetch.sh quotes quote AAPL
fmp-fetch.sh quotes batch AAPL,MSFT,GOOG
fmp-fetch.sh quotes historical TSLA 2024-01-01 2024-12-31
fmp-fetch.sh quotes intraday NVDA 5min
```

**Intraday intervals**: 1min, 5min, 15min, 30min, 1hour, 4hour

### Earnings & News

```bash
fmp-fetch.sh earnings transcript AAPL 2024 3
fmp-fetch.sh earnings transcript-dates AAPL
fmp-fetch.sh earnings earnings TSLA 20
fmp-fetch.sh earnings news MSFT 100
fmp-fetch.sh earnings press-releases NVDA 50
```

### Analyst Data

```bash
fmp-fetch.sh analyst estimates AAPL annual 10
fmp-fetch.sh analyst grades TSLA 50
fmp-fetch.sh analyst price-targets MSFT
fmp-fetch.sh analyst price-consensus NVDA
fmp-fetch.sh analyst upgrades-downgrades AAPL
fmp-fetch.sh analyst all TSLA
```

### Market Movers

```bash
fmp-fetch.sh market gainers
fmp-fetch.sh market losers
fmp-fetch.sh market actives
```

### Technical Indicators

```bash
# Intraday historical prices
fmp-fetch.sh technical intraday AAPL 5min
fmp-fetch.sh technical intraday TSLA 1hour

# Daily historical prices
fmp-fetch.sh technical daily NVDA
fmp-fetch.sh technical daily MSFT 2024-01-01 2024-12-31

# Technical indicators
fmp-fetch.sh technical indicator NVDA sma 20 1day
fmp-fetch.sh technical indicator TSLA ema 50 1day
fmp-fetch.sh technical indicator MSFT rsi 14 1hour
fmp-fetch.sh technical indicator AAPL adx 14 1day
fmp-fetch.sh technical indicator GOOGL williams 14 1day
```

**Available indicators**: sma, ema, rsi, adx, williams, wma, dema, tema, standarddeviation

**Timeframes**: 1min, 5min, 15min, 30min, 1hour, 4hour, 1day

### Bulk Operations

```bash
# All company & analyst data
fmp-fetch.sh bulk full-company AAPL

# All financial & earnings data + current quote
fmp-fetch.sh bulk full-stock TSLA

# Everything (company, financials, earnings, analyst, 1yr history)
fmp-fetch.sh bulk everything NVDA
```

## Data Storage

All fetched data is automatically saved to organized directories:

```
fmp-data/
├── company/        Company profiles, searches, screeners, peers
├── financials/     Income statements, balance sheets, cash flows, ratios
├── quotes/         Real-time and batch quotes
├── historical/     Historical EOD and intraday prices
├── earnings/       Earnings transcripts, earnings data
├── news/           Stock news (JSON & Markdown), press releases
└── analyst/        Estimates, ratings, price targets, upgrades/downgrades
```

**File naming conventions**:
- `{symbol}-{data-type}-{period/date}.{ext}`
- Example: `aapl-income-2024.json`, `tsla-news-20241116.md`

## JSON Response Format

All scripts return structured JSON responses:

```json
{
  "success": true,
  "symbol": "AAPL",
  "data_type": "income_statement",
  "count": 5,
  "file": "/path/to/aapl-income-2024.json",
  "timestamp": "2024-11-16T12:34:56Z"
}
```

Error responses:

```json
{
  "success": false,
  "error": {
    "type": "rate_limit",
    "message": "Rate limit exceeded - retry later",
    "timestamp": "2024-11-16T12:34:56Z"
  }
}
```

## Error Handling

The scripts handle common errors automatically:

- **Rate Limiting**: Auto-retry with exponential backoff
- **Network Errors**: Retry up to 3 times
- **Invalid Symbols**: Validation before API calls
- **Missing Data**: Clear error messages
- **API Errors**: HTTP status code mapping

## Configuration

Environment variables (set in `.env` or export):

```bash
FMP_API_KEY=your_key              # Required: Your FMP API key
FMP_DATA_DIR=./fmp-data           # Optional: Data storage directory
FMP_LOG_DIR=./fmp-logs            # Optional: Log directory
FMP_RATE_LIMIT=250                # Optional: Requests per minute
FMP_TIMEOUT=30                    # Optional: Request timeout (seconds)
FMP_MAX_RETRIES=3                 # Optional: Max retry attempts
```

## Logging

**API Log**: `fmp-logs/fmp-api.log`
- Timestamped log of all operations
- Warnings and errors

**Request Log**: `fmp-logs/requests.log`
- Pipe-delimited request tracking
- Format: `timestamp|symbol|endpoint|status|details`

## Use with Data Fetcher Agents

These scripts are designed for autonomous data fetcher agents:

1. **Predictable Output**: All responses in JSON format
2. **File-Based Storage**: Data saved to files, not stdout
3. **Error Handling**: Clear success/failure indicators
4. **Idempotent**: Safe to retry failed operations
5. **Rate Limiting**: Automatic request throttling

Example agent workflow:

```bash
# 1. Fetch company profile
result=$(./fmp-fetch.sh company profile AAPL)

# 2. Parse response
symbol=$(echo "$result" | jq -r '.symbol')
file=$(echo "$result" | jq -r '.file')

# 3. Fetch all financials
./fmp-fetch.sh financials all "$symbol" annual 10

# 4. Fetch analyst data
./fmp-fetch.sh analyst all "$symbol"

# 5. Fetch news
./fmp-fetch.sh earnings news "$symbol" 100
```

## API Reference

Based on Financial Modeling Prep API v3/v4.

Full API documentation: https://financialmodelingprep.com/developer/docs/

## Architecture Benefits

**Design Principles:**
- Clean modular architecture
- Consistent API across all fetchers
- Comprehensive error handling
- Easy to use and extend
- Production-ready for agents
- Single entry point (fmp-fetch.sh)
- Organized data storage
- Complete logging and monitoring

## License

MIT License - Free to use and modify

## Support

For issues or questions:
1. Check logs in `fmp-logs/`
2. Validate `.env` has correct API key
3. Check FMP API status
4. Review error messages in JSON responses
