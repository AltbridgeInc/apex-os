#!/usr/bin/env bash
# fmp-indicators.sh - Fetch technical indicators
# Usage: ./fmp-indicators.sh SYMBOL INDICATOR_TYPE [PERIOD] [TIMEFRAME]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/fmp-common.sh"

if [[ $# -lt 2 ]]; then
    format_error "invalid_params" "Usage: fmp-indicators.sh SYMBOL INDICATOR_TYPE [PERIOD] [TIMEFRAME]
  INDICATOR_TYPE: sma, ema, rsi, macd, adx, williams, stoch
  PERIOD: default 14
  TIMEFRAME: 1min, 5min, 15min, 30min, 1hour, 4hour, daily (default: daily)"
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
        # Valid indicator type
        ;;
    *)
        format_error "invalid_params" "Invalid indicator type: $indicator_type (use: sma, ema, rsi, macd, adx, williams, stoch)"
        exit 1
        ;;
esac

# Build endpoint
endpoint="/v3/technical_indicator/${timeframe}/${symbol}"
params="type=${indicator_type}&period=${period}"

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

echo "$response"
