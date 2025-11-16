#!/usr/bin/env bash
# FMP Technical Data Fetcher
# Fetch historical prices and technical indicators

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

#############################################################################
# Historical Prices (Intraday)
#############################################################################

fetch_historical_intraday() {
    local symbol="$1"
    local interval="${2:-5min}"  # 1min, 5min, 15min, 30min, 1hour, 4hour

    validate_symbol "$symbol" || return 1

    # Validate interval
    case "$interval" in
        1min|5min|15min|30min|1hour|4hour) ;;
        *)
            format_error "invalid_parameter" "Invalid interval: $interval. Must be one of: 1min, 5min, 15min, 30min, 1hour, 4hour"
            return 1
            ;;
    esac

    local endpoint="/v3/historical-chart/${interval}/${symbol}"
    local response=$(fmp_api_call "$endpoint")

    if [[ $? -ne 0 ]]; then
        echo "$response"
        return 1
    fi

    # Save to file
    local filepath="$FMP_DATA_DIR/technical/$(get_filename "$symbol" "historical-${interval}")"
    save_json "$filepath" "$response"

    local count=$(echo "$response" | jq 'length')

    log_request "$symbol" "historical-$interval" "success" "$filepath"

    cat <<EOF
{
  "success": true,
  "symbol": "$symbol",
  "interval": "$interval",
  "count": $count,
  "filepath": "$filepath",
  "message": "Fetched $count $interval candles for $symbol"
}
EOF
}

#############################################################################
# Historical Prices (Daily)
#############################################################################

fetch_historical_daily() {
    local symbol="$1"
    local from="${2:-}"  # Optional: YYYY-MM-DD
    local to="${3:-}"    # Optional: YYYY-MM-DD

    validate_symbol "$symbol" || return 1

    local params=""
    [[ -n "$from" ]] && params="${params}&from=${from}"
    [[ -n "$to" ]] && params="${params}&to=${to}"

    local endpoint="/v3/historical-price-full/${symbol}"
    local response=$(fmp_api_call "$endpoint" "$params")

    if [[ $? -ne 0 ]]; then
        echo "$response"
        return 1
    fi

    # Extract historical data
    local historical=$(echo "$response" | jq '.historical // []')

    # Save to file
    local filepath="$FMP_DATA_DIR/technical/$(get_filename "$symbol" "historical-daily")"
    save_json "$filepath" "$historical"

    local count=$(echo "$historical" | jq 'length')

    log_request "$symbol" "historical-daily" "success" "$filepath"

    cat <<EOF
{
  "success": true,
  "symbol": "$symbol",
  "count": $count,
  "filepath": "$filepath",
  "message": "Fetched $count daily candles for $symbol"
}
EOF
}

#############################################################################
# Technical Indicator
#############################################################################

fetch_indicator() {
    local symbol="$1"
    local indicator="$2"  # sma, ema, rsi, adx, williams, wma, dema, tema, standarddeviation
    local period="${3:-14}"
    local timeframe="${4:-1day}"  # 1min, 5min, 15min, 30min, 1hour, 4hour, 1day

    validate_symbol "$symbol" || return 1

    # Validate indicator
    case "$indicator" in
        sma|ema|rsi|adx|williams|wma|dema|tema|standarddeviation) ;;
        *)
            format_error "invalid_parameter" "Invalid indicator: $indicator. Must be one of: sma, ema, rsi, adx, williams, wma, dema, tema, standarddeviation"
            return 1
            ;;
    esac

    local params="&period=$period&type=$timeframe"
    local endpoint="/v3/technical_indicator/${timeframe}/${symbol}"

    # Different endpoint structure for technical indicators
    local endpoint="/v3/technical_indicator/${timeframe}/${symbol}?type=${indicator}&period=${period}"
    local response=$(fmp_api_call "$endpoint" "")

    if [[ $? -ne 0 ]]; then
        echo "$response"
        return 1
    fi

    # Save to file
    local filepath="$FMP_DATA_DIR/technical/$(get_filename "$symbol" "indicator-${indicator}-${period}-${timeframe}")"
    save_json "$filepath" "$response"

    local count=$(echo "$response" | jq 'length')

    log_request "$symbol" "$indicator-$period" "success" "$filepath"

    cat <<EOF
{
  "success": true,
  "symbol": "$symbol",
  "indicator": "$indicator",
  "period": $period,
  "timeframe": "$timeframe",
  "count": $count,
  "filepath": "$filepath",
  "message": "Fetched $indicator($period) for $symbol on $timeframe timeframe"
}
EOF
}

#############################################################################
# Main
#############################################################################

main() {
    local action="${1:-}"
    shift || true

    case "$action" in
        intraday)
            fetch_historical_intraday "$@"
            ;;
        daily)
            fetch_historical_daily "$@"
            ;;
        indicator)
            fetch_indicator "$@"
            ;;
        *)
            cat <<EOF
Usage: fetch-technical.sh <action> [options]

Actions:
  intraday <SYMBOL> [INTERVAL]             Fetch intraday historical prices
                                           INTERVAL: 1min, 5min, 15min, 30min, 1hour, 4hour (default: 5min)

  daily <SYMBOL> [FROM] [TO]               Fetch daily historical prices
                                           FROM/TO: YYYY-MM-DD (optional)

  indicator <SYMBOL> <TYPE> [PERIOD] [TF]  Fetch technical indicator
                                           TYPE: sma, ema, rsi, adx, williams, wma, dema, tema, standarddeviation
                                           PERIOD: number (default: 14)
                                           TF: 1min, 5min, 15min, 30min, 1hour, 4hour, 1day (default: 1day)

Examples:
  fetch-technical.sh intraday AAPL 5min
  fetch-technical.sh daily TSLA 2024-01-01 2024-12-31
  fetch-technical.sh indicator NVDA sma 20 1day
  fetch-technical.sh indicator MSFT rsi 14 1hour
EOF
            exit 1
            ;;
    esac
}

main "$@"
