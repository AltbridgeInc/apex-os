#!/usr/bin/env bash
# FMP Master Data Fetcher
# Orchestrate all FMP API data fetching operations

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

#############################################################################
# Display Help
#############################################################################

show_help() {
    cat <<'EOF'
FMP Master Data Fetcher
=======================

A clean, stable API client for Financial Modeling Prep (FMP).
Fetch company data, financials, quotes, earnings, news, and analyst reports.

USAGE:
  fmp-fetch.sh <category> <action> [options]

CATEGORIES & ACTIONS:

  company
    profile <SYMBOL>                        Company profile & info
    search <QUERY> [LIMIT]                  Search companies
    screener [MIN_CAP] [MAX_CAP] [SECTOR]   Screen stocks
    peers <SYMBOL>                          Peer companies

  financials
    income <SYMBOL> [PERIOD] [LIMIT]        Income statements
    balance <SYMBOL> [PERIOD] [LIMIT]       Balance sheets
    cashflow <SYMBOL> [PERIOD] [LIMIT]      Cash flow statements
    ratios <SYMBOL> [PERIOD] [LIMIT]        Financial ratios
    metrics <SYMBOL> [PERIOD] [LIMIT]       Key metrics
    enterprise <SYMBOL> [PERIOD] [LIMIT]    Enterprise values
    all <SYMBOL> [PERIOD] [LIMIT]           All financial data

  quotes
    quote <SYMBOL> [SHORT]                  Real-time quote
    batch <SYMBOLS> [SHORT]                 Batch quotes (comma-separated)
    historical <SYMBOL> [FROM] [TO]         Historical prices (YYYY-MM-DD)
    intraday <SYMBOL> [INTERVAL] [FROM] [TO] Intraday data

  earnings
    transcript <SYMBOL> <YEAR> <QUARTER>    Earnings call transcript
    transcript-dates <SYMBOL>               Available transcript dates
    earnings <SYMBOL> [LIMIT]               Earnings history
    news <SYMBOL> [LIMIT]                   Stock news
    press-releases <SYMBOL> [LIMIT]         Press releases

  analyst
    estimates <SYMBOL> [PERIOD] [LIMIT]     Analyst estimates
    grades <SYMBOL> [LIMIT]                 Stock grades/ratings
    price-targets <SYMBOL>                  Price targets
    price-consensus <SYMBOL>                Price target consensus
    upgrades-downgrades <SYMBOL>            Upgrades & downgrades
    all <SYMBOL>                            All analyst data

  market
    gainers                                 Biggest gainers
    losers                                  Biggest losers
    actives                                 Most active stocks

  technical
    intraday <SYMBOL> [INTERVAL]            Intraday prices (1min, 5min, 15min, 30min, 1hour, 4hour)
    daily <SYMBOL> [FROM] [TO]              Daily historical prices
    indicator <SYMBOL> <TYPE> [PERIOD] [TF] Technical indicator (sma, ema, rsi, adx, williams, etc.)

  bulk
    full-company <SYMBOL>                   All company data
    full-stock <SYMBOL>                     All stock data (no prices)
    everything <SYMBOL>                     Everything for a symbol

PARAMETERS:
  SYMBOL        Stock ticker (e.g., AAPL, TSLA)
  PERIOD        annual or quarter (default: annual)
  LIMIT         Number of records (default varies by endpoint)
  INTERVAL      1min, 5min, 15min, 30min, 1hour, 4hour
  FROM/TO       Date in YYYY-MM-DD format

EXAMPLES:

  # Company information
  fmp-fetch.sh company profile AAPL
  fmp-fetch.sh company search "Tesla" 10
  fmp-fetch.sh company peers TSLA

  # Financial statements
  fmp-fetch.sh financials income AAPL annual 5
  fmp-fetch.sh financials balance MSFT quarter 8
  fmp-fetch.sh financials all NVDA annual 10

  # Stock quotes & prices
  fmp-fetch.sh quotes quote AAPL
  fmp-fetch.sh quotes batch AAPL,MSFT,GOOG
  fmp-fetch.sh quotes historical TSLA 2024-01-01 2024-12-31
  fmp-fetch.sh quotes intraday NVDA 5min

  # Earnings & news
  fmp-fetch.sh earnings transcript AAPL 2024 3
  fmp-fetch.sh earnings news TSLA 100
  fmp-fetch.sh earnings press-releases MSFT 50

  # Analyst data
  fmp-fetch.sh analyst estimates AAPL annual 10
  fmp-fetch.sh analyst price-targets TSLA
  fmp-fetch.sh analyst all NVDA

  # Market movers
  fmp-fetch.sh market gainers
  fmp-fetch.sh market losers
  fmp-fetch.sh market actives

  # Technical data
  fmp-fetch.sh technical intraday AAPL 5min
  fmp-fetch.sh technical daily TSLA 2024-01-01 2024-12-31
  fmp-fetch.sh technical indicator NVDA sma 20 1day
  fmp-fetch.sh technical indicator MSFT rsi 14 1hour

  # Bulk data fetch
  fmp-fetch.sh bulk full-company AAPL
  fmp-fetch.sh bulk everything TSLA

DATA STORAGE:
  All data saved to: $FMP_DATA_DIR/
  ├── company/        Company profiles, searches, screeners
  ├── financials/     Financial statements, ratios, metrics
  ├── quotes/         Real-time and batch quotes
  ├── historical/     Historical and intraday prices
  ├── earnings/       Transcripts, earnings data
  ├── news/           Stock news and press releases
  ├── analyst/        Analyst estimates, ratings, price targets
  ├── market-movers/  Gainers, losers, most actives
  └── technical/      Intraday prices, technical indicators

LOGS:
  API logs: $FMP_LOG_DIR/fmp-api.log
  Requests: $FMP_LOG_DIR/requests.log

CONFIGURATION:
  API Key: Set FMP_API_KEY in .env file
  Rate Limit: $FMP_RATE_LIMIT requests/minute
  Timeout: ${FMP_TIMEOUT}s per request
  Max Retries: $FMP_MAX_RETRIES

For more information, see the FMP API documentation:
https://financialmodelingprep.com/developer/docs/
EOF
}

#############################################################################
# Bulk Fetch Operations
#############################################################################

fetch_full_company() {
    local symbol="$1"

    log_message "INFO" "Fetching full company data for $symbol"

    echo '{"operation": "full_company", "symbol": "'$symbol'", "started": true}'

    # Company data
    "$SCRIPT_DIR/fetch-company.sh" profile "$symbol"
    "$SCRIPT_DIR/fetch-company.sh" peers "$symbol"

    # Analyst data
    "$SCRIPT_DIR/fetch-analyst.sh" all "$symbol"

    log_message "INFO" "Full company data fetch completed for $symbol"

    cat <<EOF
{
  "success": true,
  "operation": "full_company",
  "symbol": "$symbol",
  "completed": true,
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
}

fetch_full_stock() {
    local symbol="$1"

    log_message "INFO" "Fetching full stock data for $symbol"

    echo '{"operation": "full_stock", "symbol": "'$symbol'", "started": true}'

    # Financial data
    "$SCRIPT_DIR/fetch-financials.sh" all "$symbol" annual 10

    # Earnings data
    "$SCRIPT_DIR/fetch-earnings.sh" earnings "$symbol" 20
    "$SCRIPT_DIR/fetch-earnings.sh" news "$symbol" 100

    # Current quote
    "$SCRIPT_DIR/fetch-quotes.sh" quote "$symbol"

    log_message "INFO" "Full stock data fetch completed for $symbol"

    cat <<EOF
{
  "success": true,
  "operation": "full_stock",
  "symbol": "$symbol",
  "completed": true,
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
}

fetch_everything() {
    local symbol="$1"

    log_message "INFO" "Fetching everything for $symbol"

    echo '{"operation": "everything", "symbol": "'$symbol'", "started": true}'

    # Company
    fetch_full_company "$symbol"

    # Stock data
    fetch_full_stock "$symbol"

    # Historical prices (last year)
    local from_date=$(date -d '1 year ago' +%Y-%m-%d 2>/dev/null || date -v-1y +%Y-%m-%d)
    local to_date=$(date +%Y-%m-%d)
    "$SCRIPT_DIR/fetch-quotes.sh" historical "$symbol" "$from_date" "$to_date"

    log_message "INFO" "Everything fetch completed for $symbol"

    cat <<EOF
{
  "success": true,
  "operation": "everything",
  "symbol": "$symbol",
  "completed": true,
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
}

#############################################################################
# Main Router
#############################################################################

main() {
    local category="${1:-}"
    local action="${2:-}"
    shift 2 2>/dev/null || true

    case "$category" in
        company)
            "$SCRIPT_DIR/fetch-company.sh" "$action" "$@"
            ;;
        financials)
            "$SCRIPT_DIR/fetch-financials.sh" "$action" "$@"
            ;;
        quotes)
            "$SCRIPT_DIR/fetch-quotes.sh" "$action" "$@"
            ;;
        earnings)
            "$SCRIPT_DIR/fetch-earnings.sh" "$action" "$@"
            ;;
        analyst)
            "$SCRIPT_DIR/fetch-analyst.sh" "$action" "$@"
            ;;
        market)
            "$SCRIPT_DIR/fetch-market-movers.sh" "$action" "$@"
            ;;
        technical)
            "$SCRIPT_DIR/fetch-technical.sh" "$action" "$@"
            ;;
        bulk)
            case "$action" in
                full-company)
                    fetch_full_company "$@"
                    ;;
                full-stock)
                    fetch_full_stock "$@"
                    ;;
                everything)
                    fetch_everything "$@"
                    ;;
                *)
                    format_error "invalid_action" "Unknown bulk action: $action"
                    exit 1
                    ;;
            esac
            ;;
        help|--help|-h|"")
            show_help
            exit 0
            ;;
        *)
            echo "ERROR: Unknown category: $category" >&2
            echo "" >&2
            echo "Run 'fmp-fetch.sh help' for usage information" >&2
            exit 1
            ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
