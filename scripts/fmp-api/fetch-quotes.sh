#!/usr/bin/env bash
# FMP Stock Quotes & Prices Fetcher
# Fetch real-time quotes, historical prices, and intraday data

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

#############################################################################
# Real-Time Quote
#############################################################################

fetch_quote() {
    local symbol="$1"
    local short="${2:-false}"

    validate_symbol "$symbol" || return 1

    local endpoint
    if [[ "$short" == "true" ]]; then
        endpoint="/v3/quote-short/${symbol}"
    else
        endpoint="/v3/quote/${symbol}"
    fi

    local response=$(fmp_api_call "$endpoint")

    if [[ $? -ne 0 ]]; then
        echo "$response"
        return 1
    fi

    # Extract first element
    local quote=$(echo "$response" | jq '.[0] // empty')

    if [[ -z "$quote" || "$quote" == "null" ]]; then
        format_error "no_data" "No quote data for $symbol"
        return 1
    fi

    # Save to file
    local timestamp=$(date +"%Y%m%d-%H%M%S")
    local filepath="$FMP_DATA_DIR/quotes/$(get_filename "$symbol" "quote" "$timestamp")"
    save_json "$filepath" "$quote"

    local price=$(echo "$quote" | jq -r '.price // .close // "N/A"')
    local change=$(echo "$quote" | jq -r '.change // "N/A"')

    log_request "$symbol" "quote" "success" "price=$price"

    cat <<EOF
{
  "success": true,
  "symbol": "$symbol",
  "price": $price,
  "change": $change,
  "file": "$filepath",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
}

#############################################################################
# Batch Quotes
#############################################################################

fetch_batch_quotes() {
    local symbols="$1"
    local short="${2:-false}"

    # Validate each symbol
    IFS=',' read -ra SYMBOL_ARRAY <<< "$symbols"
    for sym in "${SYMBOL_ARRAY[@]}"; do
        sym=$(echo "$sym" | tr -d ' ' | tr '[:lower:]' '[:upper:]')
        validate_symbol "$sym" || return 1
    done

    local endpoint
    if [[ "$short" == "true" ]]; then
        endpoint="/v3/quote-short/${symbols}"
    else
        endpoint="/v3/quote/${symbols}"
    fi

    local response=$(fmp_api_call "$endpoint")

    if [[ $? -ne 0 ]]; then
        echo "$response"
        return 1
    fi

    local count=$(echo "$response" | jq 'length')
    if [[ $count -eq 0 ]]; then
        format_error "no_data" "No quote data for $symbols"
        return 1
    fi

    # Save batch file
    local timestamp=$(date +"%Y%m%d-%H%M%S")
    local filepath="$FMP_DATA_DIR/quotes/batch-${timestamp}.json"
    save_json "$filepath" "$response"

    log_request "$symbols" "batch-quote" "success" "$count symbols"

    cat <<EOF
{
  "success": true,
  "symbols": "$symbols",
  "count": $count,
  "file": "$filepath",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
}

#############################################################################
# Historical Prices
#############################################################################

fetch_historical_prices() {
    local symbol="$1"
    local from="${2:-}"
    local to="${3:-}"

    validate_symbol "$symbol" || return 1

    local endpoint="/v3/historical-price-full/${symbol}"
    local params=""

    if [[ -n "$from" ]]; then
        params="from=${from}"
    fi

    if [[ -n "$to" ]]; then
        if [[ -n "$params" ]]; then
            params="${params}&to=${to}"
        else
            params="to=${to}"
        fi
    fi

    local response=$(fmp_api_call "$endpoint" "$params")

    if [[ $? -ne 0 ]]; then
        echo "$response"
        return 1
    fi

    # Extract historical data
    local historical=$(echo "$response" | jq '.historical // empty')

    if [[ -z "$historical" || "$historical" == "null" ]]; then
        format_error "no_data" "No historical data for $symbol"
        return 1
    fi

    local count=$(echo "$historical" | jq 'length')

    # Save to file
    local suffix=""
    [[ -n "$from" ]] && suffix="${from}"
    [[ -n "$to" ]] && suffix="${suffix}_${to}"
    [[ -z "$suffix" ]] && suffix="all"

    local filepath="$FMP_DATA_DIR/historical/$(get_filename "$symbol" "historical" "$suffix")"
    save_json "$filepath" "$historical"

    log_request "$symbol" "historical" "success" "$count days"

    cat <<EOF
{
  "success": true,
  "symbol": "$symbol",
  "count": $count,
  "from": "$from",
  "to": "$to",
  "file": "$filepath",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
}

#############################################################################
# Intraday Prices
#############################################################################

fetch_intraday() {
    local symbol="$1"
    local interval="${2:-5min}"
    local from="${3:-}"
    local to="${4:-}"

    validate_symbol "$symbol" || return 1

    local endpoint="/v3/historical-chart/${interval}/${symbol}"
    local params=""

    if [[ -n "$from" ]]; then
        params="from=${from}"
    fi

    if [[ -n "$to" ]]; then
        if [[ -n "$params" ]]; then
            params="${params}&to=${to}"
        else
            params="to=${to}"
        fi
    fi

    local response=$(fmp_api_call "$endpoint" "$params")

    if [[ $? -ne 0 ]]; then
        echo "$response"
        return 1
    fi

    local count=$(echo "$response" | jq 'length')
    if [[ $count -eq 0 ]]; then
        format_error "no_data" "No intraday data for $symbol"
        return 1
    fi

    # Save to file
    local timestamp=$(date +"%Y%m%d")
    local filepath="$FMP_DATA_DIR/historical/$(get_filename "$symbol" "intraday-${interval}" "$timestamp")"
    save_json "$filepath" "$response"

    log_request "$symbol" "intraday-${interval}" "success" "$count points"

    cat <<EOF
{
  "success": true,
  "symbol": "$symbol",
  "interval": "$interval",
  "count": $count,
  "file": "$filepath",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
}

#############################################################################
# Main Entry Point
#############################################################################

main() {
    local action="${1:-}"
    shift || true

    case "$action" in
        quote)
            fetch_quote "$1" "${2:-false}"
            ;;
        batch)
            fetch_batch_quotes "$1" "${2:-false}"
            ;;
        historical)
            fetch_historical_prices "$1" "${2:-}" "${3:-}"
            ;;
        intraday)
            fetch_intraday "$1" "${2:-5min}" "${3:-}" "${4:-}"
            ;;
        *)
            cat <<EOF
Usage: fetch-quotes.sh <action> [options]

Actions:
  quote <SYMBOL> [SHORT]                    Real-time quote (SHORT=true for compact)
  batch <SYMBOLS> [SHORT]                   Batch quotes (comma-separated symbols)
  historical <SYMBOL> [FROM] [TO]           Historical prices (YYYY-MM-DD format)
  intraday <SYMBOL> [INTERVAL] [FROM] [TO]  Intraday data

Intraday Intervals:
  1min, 5min, 15min, 30min, 1hour, 4hour

Examples:
  fetch-quotes.sh quote AAPL
  fetch-quotes.sh batch AAPL,MSFT,GOOG true
  fetch-quotes.sh historical AAPL 2024-01-01 2024-12-31
  fetch-quotes.sh intraday TSLA 5min
EOF
            exit 1
            ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
