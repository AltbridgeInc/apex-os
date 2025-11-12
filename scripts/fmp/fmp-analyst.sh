#!/usr/bin/env bash
# fmp-analyst.sh - Fetch analyst estimates, price targets, and ratings
# Usage: ./fmp-analyst.sh SYMBOL [TYPE] [LIMIT]
#   TYPE: estimates, price-targets, ratings, upgrades-downgrades
#   LIMIT: number of records (default: varies by type)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/fmp-common.sh"

# Validate arguments
if [[ $# -lt 1 ]]; then
    format_error "invalid_params" "Usage: fmp-analyst.sh SYMBOL [TYPE] [LIMIT]
  TYPE: estimates, price-targets, ratings, upgrades-downgrades (default: estimates)
  LIMIT: number of records (default: varies by type)"
    exit 1
fi

symbol=$(echo "$1" | tr '[:lower:]' '[:upper:]')
type=$(echo "${2:-estimates}" | tr '[:upper:]' '[:lower:]')
limit=${3:-}

# Validate symbol
validate_symbol "$symbol" || exit 1

# Build endpoint and parameters based on type
case "$type" in
    estimates)
        endpoint="/v3/analyst-estimates/${symbol}"
        # FMP returns 30 quarters by default; limit if specified
        params=""
        [[ -n "$limit" ]] && params="limit=${limit}"
        ;;

    price-targets|targets)
        endpoint="/v3/price-target-consensus/${symbol}"
        params=""
        ;;

    ratings)
        endpoint="/v3/rating/${symbol}"
        params=""
        ;;

    upgrades-downgrades|upgrades)
        endpoint="/v3/upgrades-downgrades"
        # This endpoint allows filtering by symbol
        params="symbol=${symbol}"
        [[ -n "$limit" ]] && params="${params}&limit=${limit}"
        ;;

    *)
        format_error "invalid_params" "Invalid type: $type (use: estimates, price-targets, ratings, upgrades-downgrades)"
        exit 1
        ;;
esac

# Make API call
response=$(fmp_api_call "$endpoint" "$params")
exit_code=$?

if [[ $exit_code -ne 0 ]]; then
    echo "$response"
    exit 1
fi

# Validate response
if ! echo "$response" | jq -e 'type == "array" or type == "object"' > /dev/null 2>&1; then
    format_error "invalid_response" "Expected array or object response"
    exit 1
fi

# For price-targets, response is object, wrap in array for consistency
if [[ "$type" == "price-targets" ]] || [[ "$type" == "targets" ]]; then
    if echo "$response" | jq -e 'type == "object"' > /dev/null 2>&1; then
        echo "[$response]"
        exit 0
    fi
fi

# Check if array is empty
if echo "$response" | jq -e 'type == "array"' > /dev/null 2>&1; then
    count=$(echo "$response" | jq 'length')
    if [[ $count -eq 0 ]]; then
        format_error "missing_data" "No analyst data returned for $symbol (type: $type)"
        exit 1
    fi
fi

# Return response
echo "$response"
