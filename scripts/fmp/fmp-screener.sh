#!/usr/bin/env bash
# fmp-screener.sh - Stock screening with multiple criteria
# Usage: ./fmp-screener.sh [--param=value ...]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/fmp-common.sh"

# Initialize variables
type=""
market_cap_more=""
market_cap_lower=""
price_more=""
price_lower=""
beta_more=""
volume_more=""
sector=""
industry=""
exchange=""
limit="100"

# Parse arguments
for arg in "$@"; do
    case "$arg" in
        --type=*)
            type="${arg#*=}"
            ;;
        --marketCapMoreThan=*)
            market_cap_more="${arg#*=}"
            ;;
        --marketCapLowerThan=*)
            market_cap_lower="${arg#*=}"
            ;;
        --priceMoreThan=*)
            price_more="${arg#*=}"
            ;;
        --priceLowerThan=*)
            price_lower="${arg#*=}"
            ;;
        --betaMoreThan=*)
            beta_more="${arg#*=}"
            ;;
        --volumeMoreThan=*)
            volume_more="${arg#*=}"
            ;;
        --sector=*)
            sector="${arg#*=}"
            ;;
        --industry=*)
            industry="${arg#*=}"
            ;;
        --exchange=*)
            exchange="${arg#*=}"
            ;;
        --limit=*)
            limit="${arg#*=}"
            ;;
        *)
            format_error "invalid_params" "Unknown parameter: $arg"
            exit 1
            ;;
    esac
done

# Handle market movers shortcut
if [[ -n "$type" ]]; then
    case "$type" in
        gainers)
            endpoint="/v3/stock_market/gainers"
            ;;
        losers)
            endpoint="/v3/stock_market/losers"
            ;;
        actives)
            endpoint="/v3/stock_market/actives"
            ;;
        *)
            format_error "invalid_params" "Invalid type: $type (use: gainers, losers, actives)"
            exit 1
            ;;
    esac

    response=$(fmp_api_call "$endpoint")
    exit_code=$?

    if [[ $exit_code -ne 0 ]]; then
        echo "$response"
        exit 1
    fi

    # Apply limit
    echo "$response" | jq ".[0:${limit}]"
    exit 0
fi

# Build stock screener parameters
endpoint="/v3/stock-screener"
params="limit=${limit}"

[[ -n "$market_cap_more" ]] && params="${params}&marketCapMoreThan=${market_cap_more}"
[[ -n "$market_cap_lower" ]] && params="${params}&marketCapLowerThan=${market_cap_lower}"
[[ -n "$price_more" ]] && params="${params}&priceMoreThan=${price_more}"
[[ -n "$price_lower" ]] && params="${params}&priceLowerThan=${price_lower}"
[[ -n "$beta_more" ]] && params="${params}&betaMoreThan=${beta_more}"
[[ -n "$volume_more" ]] && params="${params}&volumeMoreThan=${volume_more}"
[[ -n "$sector" ]] && params="${params}&sector=${sector}"
[[ -n "$industry" ]] && params="${params}&industry=${industry}"
[[ -n "$exchange" ]] && params="${params}&exchange=${exchange}"

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
