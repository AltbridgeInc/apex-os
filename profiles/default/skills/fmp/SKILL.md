---
name: fmp
description: Fetch financial data from Financial Modeling Prep API. Data is cached to files; paths are returned for analysis. Use when you need earnings transcripts, financial statements, or market data.
---

# FMP - Financial Modeling Prep Integration

## Overview

This skill fetches financial data from FMP API and caches it in `apex-os/data/fmp/` directory. All operations return file paths (not payloads) to minimize token usage and enable data persistence.

**Key Pattern:** Fetch → Cache → Return Paths → Agent Reads as Needed

## When to Use This Skill

Invoke when you need to:
- Fetch earnings call transcripts for fundamental analysis
- Get financial statements (income, balance sheet, cash flow)
- Pull recent stock news and developments
- Cache financial data for historical comparison

**Example requests:**
- "Get the latest earnings transcripts for AAPL"
- "Fetch income statements for NVDA for the last 4 years"
- "Pull recent news about TSLA"

## Prerequisites

1. **FMP API Key:** Must be set in project `.env` file
   ```bash
   FMP_API_KEY=your_key_here
   ```

2. **Dependencies:** `curl`, `jq`, `python3` (stdlib only)

3. **Workspace:** Proper APEX-OS installation with `apex-os/data/fmp/` directory

## Available Scripts

All scripts located at: `apex-os/scripts/data-fetching/fmp/`

### 1. Earnings Transcripts

```bash
cd apex-os/scripts/data-fetching/fmp
./fmp-transcript.sh SYMBOL NUM_QUARTERS
```

**Example:**
```bash
./fmp-transcript.sh AAPL 4
```

**Output:**
```json
{
  "success": true,
  "symbol": "AAPL",
  "count": 4,
  "data_dir": "/path/to/apex-os/data/fmp",
  "files": [
    "/path/to/apex-os/data/fmp/aapl-transcript-2024-Q4.json",
    "/path/to/apex-os/data/fmp/aapl-transcript-2024-Q3.json",
    ...
  ],
  "combined_file": "/path/to/apex-os/data/fmp/aapl-transcripts-combined.json",
  "timestamp": "2024-11-14T10:30:00Z"
}
```

**Then process to readable text:**
```bash
python3 apex-os/scripts/data-fetching/fmp/process-transcript.py apex-os/data/fmp/aapl-transcripts-combined.json
# Creates: apex-os/data/fmp/aapl-earnings-2024-Q4.txt (for each quarter)
```

### 2. Financial Statements

```bash
./fmp-financials.sh SYMBOL TYPE PERIOD NUM_PERIODS
```

**Types:** `income`, `balance`, `cashflow`
**Period:** `annual`, `quarterly`

**Example:**
```bash
./fmp-financials.sh AAPL income annual 4
```

Saves to: `apex-os/data/fmp/aapl-income-statement-2024-annual.json`

### 3. Earnings Calendar & Surprises

```bash
./fmp-earnings.sh SYMBOL [TYPE] [LIMIT]
```

**Types:** `calendar`, `surprises`, `transcripts`

**Example:**
```bash
./fmp-earnings.sh AAPL calendar 20
```

Fetches 20 most recent earnings events with actual vs estimated data.

## Agent Workflow

When you need financial data, follow this workflow:

### Step 1: Check Cache First
```bash
# Check if data already exists
ls apex-os/data/fmp/{symbol}-*
```

If data exists and is recent (< 7 days for transcripts, < 1 day for news), use cached data to conserve API quota.

### Step 2: Fetch if Missing
```bash
# Navigate to FMP scripts
cd apex-os/scripts/data-fetching/fmp

# Fetch earnings transcripts (example: AAPL, 4 quarters)
result=$(./fmp-transcript.sh AAPL 4)

# Extract file paths from result
files=$(echo "$result" | jq -r '.files[]')
combined=$(echo "$result" | jq -r '.combined_file')
```

### Step 3: Process to Readable Format (Optional)
```bash
# Convert JSON to text for easier reading
python3 process-transcript.py "$combined"
# Creates: apex-os/data/fmp/aapl-earnings-2024-Q4.txt (etc.)
```

### Step 4: Read Files as Needed
```bash
# Use Read tool on specific files
# Example: Read the latest earnings transcript
latest=$(ls -t apex-os/data/fmp/aapl-earnings-*.txt | head -n1)
# Then use Read tool: Read file_path=$latest
```

## Important Rules

1. **Never request raw JSON in your response** - Always work with file paths
2. **Cache first** - Don't re-fetch data that exists and is fresh
3. **Selective reading** - Only read files you actually need for the analysis
4. **Token efficiency** - File paths use ~100 tokens, full JSON uses 10,000+
5. **Audit trail** - All fetches are logged to `apex-os/logs/data-fetch.log`

## Complete Example Workflow

```bash
# Analyze AAPL fundamentals

# 1. Check cache
if [ ! -f "apex-os/data/fmp/aapl-transcripts-combined.json" ]; then
    # 2. Fetch if missing
    cd apex-os/scripts/data-fetching/fmp

    # Fetch transcripts
    transcript_result=$(./fmp-transcript.sh AAPL 4)
    python3 process-transcript.py apex-os/data/fmp/aapl-transcripts-combined.json

    # Fetch financials
    financials_result=$(./fmp-financials.sh AAPL income annual 4)

    cd ../../..
fi

# 3. Read what you need for analysis
# Use Read tool on:
#  - apex-os/data/fmp/aapl-earnings-2024-Q4.txt (latest quarter)
#  - apex-os/data/fmp/aapl-income-statement-2024-annual.json (latest year)

# 4. Conduct analysis applying investment principles
# Reference: @apex-os/principles/fundamental/financial-health.md
# Reference: @apex-os/principles/fundamental/valuation-metrics.md

# 5. Save analysis
# Output: apex-os/analysis/AAPL-2024-11-14.md
```

## File Naming Convention

All files follow standardized pattern:
```
{symbol}-{data-type}-{period}.{ext}

Examples:
 aapl-transcript-2024-Q4.json          # Raw JSON
 aapl-earnings-2024-Q4.txt             # Processed text
 aapl-income-statement-2024-annual.json
 aapl-earnings-calendar-2024-11-14.json
```

## Data Storage

```
your-project/
├── data/
│   └── fmp/                          # All FMP data cached here
│       ├── aapl-transcript-*.json
│       ├── aapl-earnings-*.txt
│       └── ...
└── apex-os/
    ├── analysis/                     # Your analyses reference cached data
    ├── theses/                       # Your theses reference cached data
    └── logs/
        └── data-fetch.log            # Audit trail
```

## Data Freshness Guidelines

- **Earnings transcripts:** Fetch after each quarterly earnings call; cache for 90 days
- **Financial statements:** Fetch quarterly; cache for 90 days
- **Earnings calendar:** Fetch daily for upcoming events; cache for 1 day
- **Company profile:** Fetch once; cache indefinitely (rarely changes)
- **Historical prices:** Fetch as needed; cache indefinitely (immutable)

## Error Handling

**Missing API key:**
```
Error: FMP_API_KEY not defined in .env
```
→ Add `FMP_API_KEY=your_key` to project `.env` file

**Rate limit:**
```
Rate limit hit, sleeping 10s...
```
→ Script auto-retries with backoff

**No data available:**
```
No transcripts available for SYMBOL
```
→ Check symbol; not all companies have all data types

## Integration with Analysis Workflow

**Typical usage:**

1. **Market Scanner** identifies AAPL opportunity
2. **Fundamental Analyst** fetches data:
   ```bash
   cd apex-os/scripts/data-fetching/fmp
   ./fmp-transcript.sh AAPL 4
   ./fmp-financials.sh AAPL income annual 4
   cd ../../..
   ```
3. **Analyst reads cached files:**
   - Read: `apex-os/data/fmp/aapl-earnings-2024-Q4.txt`
   - Read: `apex-os/data/fmp/aapl-income-statement-2024-annual.json`
4. **Analysis saved:** `apex-os/analysis/AAPL-2024-11-14.md`
5. **Data remains cached** for future reference and backtesting

## Why File-Based?

Based on Anthropic's MCP code execution best practices:
- **Token efficiency:** Path (100 tokens) vs Full JSON (11,000+ tokens) = 99% savings
- **Progressive loading:** Fetch all data, read only what's needed
- **Data persistence:** Enables historical comparison and backtesting
- **Separation of concerns:** Fetching vs analysis
- **Reproducibility:** Immutable data references in analysis
- **Offline capability:** Analyze cached data without API calls

## Token Savings Example

**Before (stdout JSON):**
- Single AAPL transcript: ~45KB = ~11,000 tokens
- 4 quarters: ~180KB = ~44,000 tokens

**After (file paths):**
- Path summary JSON: ~0.5KB = ~100 tokens
- Agent reads 1 file when needed: ~11,000 tokens
- **Selective reading = 75% savings**

**Example workflow:**
1. Fetch 4 transcripts: ~100 tokens (paths only)
2. Agent decides to read latest: ~11,000 tokens (1 file)
3. **Total: 11,100 tokens vs 44,000 tokens = 75% savings**
