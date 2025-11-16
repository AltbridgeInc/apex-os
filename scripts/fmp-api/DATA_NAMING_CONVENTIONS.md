# FMP Data Naming Conventions

## Data Classification

FMP API data falls into three categories based on update frequency and caching strategy:

### 1. **IMMUTABLE** - Never changes once created
- Financial statements (income, balance, cashflow) for past periods
- Historical prices
- Earnings transcripts
- **Cache Strategy**: Keep forever, never re-fetch

### 2. **SEMI-MUTABLE** - Changes occasionally (daily/weekly)
- Company profiles (CEO, employee count, etc.)
- Analyst estimates and ratings
- Company peers
- **Cache Strategy**: Re-fetch if older than 24 hours (daily), include date in filename

### 3. **HIGHLY MUTABLE** - Changes constantly (intraday)
- Real-time quotes
- Market movers (gainers/losers/actives)
- Intraday prices
- **Cache Strategy**: Re-fetch every request, include timestamp in filename

---

## File Naming Patterns

### IMMUTABLE Data

**Pattern**: `{symbol}-{datatype}-{year}-{period}.json`

Examples:
```
aapl-income-2025-annual.json
aapl-income-2025-Q4.json
aapl-balance-2024-annual.json
aapl-cashflow-2025-Q3.json
aapl-earnings-2025-Q4.txt
tsla-transcript-2025-Q3.json
nvda-historical-2025-01-15-to-2025-11-15.json
```

**Rationale**: Year and period identify the specific data point. No need for dates since data never changes.

### SEMI-MUTABLE Data

**Pattern**: `{symbol}-{datatype}-{YYYY-MM-DD}.json`

Examples:
```
aapl-profile-2025-11-16.json
nvda-analyst-estimates-2025-11-16.json
tsla-analyst-grades-2025-11-15.json
msft-peers-2025-11-16.json
aapl-ratios-2025-11-16.json
```

**Rationale**: Date allows checking cache freshness. Can re-fetch if >24 hours old.

### HIGHLY MUTABLE Data

**Pattern**: `{symbol}-{datatype}-{YYYY-MM-DD-HHMMSS}.json` OR `{datatype}-{YYYY-MM-DD-HHMMSS}.json`

Examples:
```
nvda-quote-2025-11-16-143025.json
gainers-2025-11-16-143025.json
losers-2025-11-16-092015.json
actives-2025-11-16-160000.json
aapl-intraday-2025-11-16-153045.json
```

**Rationale**: Full timestamp tracks exact moment of data capture. Useful for historical analysis.

---

## Directory Structure

All FMP data should be stored in: **`apex-os/data/fmp/`**

### Subdirectories by Data Type

```
apex-os/data/fmp/
├── company/              # Company profiles, peers
│   ├── aapl-profile-2025-11-16.json
│   ├── aapl-peers-2025-11-16.json
│   └── nvda-profile-2025-11-15.json
│
├── financials/           # Income, balance, cashflow statements
│   ├── aapl-income-2025-annual.json
│   ├── aapl-income-2025-Q4.json
│   ├── aapl-balance-2025-annual.json
│   ├── aapl-cashflow-2025-Q3.json
│   └── nvda-income-2024-annual.json
│
├── quotes/               # Real-time and intraday quotes
│   ├── aapl-quote-2025-11-16-143025.json
│   ├── nvda-quote-2025-11-16-150000.json
│   └── tsla-intraday-2025-11-16-153045.json
│
├── historical/           # Historical price data
│   ├── aapl-historical-2025-01-01-to-2025-11-16.json
│   └── nvda-historical-2024-11-01-to-2025-11-16.json
│
├── earnings/             # Earnings transcripts, news, press releases
│   ├── aapl-transcript-2025-Q4.json
│   ├── aapl-earnings-2025-Q4.txt
│   ├── nvda-transcript-2025-Q3.json
│   └── tsla-earnings-news-2025-11-16.json
│
├── analyst/              # Analyst estimates, grades, price targets
│   ├── aapl-analyst-estimates-2025-11-16.json
│   ├── aapl-analyst-grades-2025-11-15.json
│   └── nvda-price-targets-2025-11-16.json
│
├── market-movers/        # Daily gainers, losers, actives
│   ├── gainers-2025-11-16-143025.json
│   ├── losers-2025-11-16-143025.json
│   └── actives-2025-11-16-143025.json
│
└── technical/            # Technical indicators (SMA, EMA, RSI, etc.)
    ├── aapl-sma-50-2025-11-16.json
    ├── nvda-rsi-14-2025-11-16.json
    └── tsla-macd-2025-11-16.json
```

---

## Caching Logic

### For IMMUTABLE data (financials, earnings):
```bash
if [ -f "apex-os/data/fmp/financials/aapl-income-2025-Q4.json" ]; then
    echo "File exists, using cached version (never changes)"
    # Use cached file
else
    # Fetch and save
fi
```

### For SEMI-MUTABLE data (profiles, analyst):
```bash
FILE="apex-os/data/fmp/company/aapl-profile-$(date +%Y-%m-%d).json"
if [ -f "$FILE" ]; then
    echo "Today's file exists, using cached version"
    # Use cached file
else
    # Fetch new data for today
    # Clean up old files (optional): rm apex-os/data/fmp/company/aapl-profile-*.json
fi
```

### For HIGHLY MUTABLE data (quotes, market movers):
```bash
# Always fetch fresh data
TIMESTAMP=$(date +%Y-%m-%d-%H%M%S)
FILE="apex-os/data/fmp/quotes/aapl-quote-$TIMESTAMP.json"
# Fetch and save
# Optional: Keep only last N files, delete older ones
```

---

## Multi-Period Data

When fetching multiple periods (e.g., 4 annual income statements), create:

1. **Individual files** for each period (IMMUTABLE pattern)
2. **Combined file** with all periods for convenience

Example:
```bash
# Individual files (can be cached forever)
aapl-income-2025-annual.json
aapl-income-2024-annual.json
aapl-income-2023-annual.json
aapl-income-2022-annual.json

# Combined file (for convenience)
aapl-income-annual-combined-2025.json
```

This allows:
- Individual period caching
- Re-fetching only missing periods
- Easy access to all periods in one file

---

## File Retention

### IMMUTABLE
- **Retention**: Forever
- **Cleanup**: Never (unless data is known to be corrupted)

### SEMI-MUTABLE
- **Retention**: Keep last 7-30 days
- **Cleanup**: Delete files older than retention period

### HIGHLY MUTABLE
- **Retention**: Keep last 100 files OR last 24 hours
- **Cleanup**: Delete older files to prevent disk bloat

---

## Implementation Notes

1. **Scripts should check cache first** before making API calls
2. **Return filepath** (not data) to agents for token efficiency
3. **Timestamp in UTC** for consistency
4. **Symbol in lowercase** for consistency
5. **Create subdirectories automatically** if they don't exist
6. **Log all fetches** to `apex-os/logs/fmp-api.log`
