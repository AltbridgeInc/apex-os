#!/usr/bin/env bash
# fmp-historical.sh - Fetch historical price data
# Usage: ./fmp-historical.sh SYMBOL [FROM] [TO] [LIMIT] [INTERVAL]
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
