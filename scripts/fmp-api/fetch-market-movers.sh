#!/usr/bin/env bash
# FMP Market Movers Fetcher
# Fetch gainers, losers, and most active stocks

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

#############################################################################
# Biggest Gainers
#############################################################################

fetch_gainers() {
    local endpoint="/v3/stock_market/gainers"
    local response=$(fmp_api_call "$endpoint")

    if [[ $? -ne 0 ]]; then
        echo "$response"
        return 1
    fi

    # Save results
    local timestamp=$(date +"%Y%m%d-%H%M%S")
    local filepath="$FMP_DATA_DIR/market-movers/gainers-${timestamp}.json"
    save_json "$filepath" "$response"

    local count=$(echo "$response" | jq 'length')

    log_request "market" "gainers" "success" "$count stocks"

    cat <<EOF
{
  "success": true,
  "count": $count,
  "filepath": "$filepath",
  "message": "Fetched $count top gaining stocks"
}
EOF
}

#############################################################################
# Biggest Losers
#############################################################################

fetch_losers() {
    local endpoint="/v3/stock_market/losers"
    local response=$(fmp_api_call "$endpoint")

    if [[ $? -ne 0 ]]; then
        echo "$response"
        return 1
    fi

    # Save results
    local timestamp=$(date +"%Y%m%d-%H%M%S")
    local filepath="$FMP_DATA_DIR/market-movers/losers-${timestamp}.json"
    save_json "$filepath" "$response"

    local count=$(echo "$response" | jq 'length')

    log_request "market" "losers" "success" "$count stocks"

    cat <<EOF
{
  "success": true,
  "count": $count,
  "filepath": "$filepath",
  "message": "Fetched $count top losing stocks"
}
EOF
}

#############################################################################
# Most Actives
#############################################################################

fetch_actives() {
    local endpoint="/v3/stock_market/actives"
    local response=$(fmp_api_call "$endpoint")

    if [[ $? -ne 0 ]]; then
        echo "$response"
        return 1
    fi

    # Save results
    local timestamp=$(date +"%Y%m%d-%H%M%S")
    local filepath="$FMP_DATA_DIR/market-movers/actives-${timestamp}.json"
    save_json "$filepath" "$response"

    local count=$(echo "$response" | jq 'length')

    log_request "market" "actives" "success" "$count stocks"

    cat <<EOF
{
  "success": true,
  "count": $count,
  "filepath": "$filepath",
  "message": "Fetched $count most active stocks"
}
EOF
}

#############################################################################
# Main
#############################################################################

main() {
    local action="${1:-}"

    case "$action" in
        gainers)
            fetch_gainers
            ;;
        losers)
            fetch_losers
            ;;
        actives)
            fetch_actives
            ;;
        *)
            cat <<EOF
Usage: fetch-market-movers.sh <action>

Actions:
  gainers                                   Fetch biggest gainers
  losers                                    Fetch biggest losers
  actives                                   Fetch most active stocks

Examples:
  fetch-market-movers.sh gainers
  fetch-market-movers.sh losers
  fetch-market-movers.sh actives
EOF
            exit 1
            ;;
    esac
}

main "$@"
