#!/usr/bin/env bash
# FMP Company Data Fetcher
# Fetch company profile, search, and metadata

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

#############################################################################
# Company Profile
#############################################################################

fetch_company_profile() {
    local symbol="$1"

    validate_symbol "$symbol" || return 1

    local endpoint="/v3/profile/${symbol}"
    local response=$(fmp_api_call "$endpoint")

    if [[ $? -ne 0 ]]; then
        echo "$response"
        return 1
    fi

    # Extract first element from array
    local profile=$(echo "$response" | jq '.[0] // empty')

    if [[ -z "$profile" || "$profile" == "null" ]]; then
        format_error "no_data" "No profile data for $symbol"
        return 1
    fi

    # Save to file (SEMI-MUTABLE - profile changes occasionally, use dated filename)
    local filepath="$FMP_DATA_DIR/company/$(get_filename_dated "$symbol" "profile")"
    save_json "$filepath" "$profile"

    log_request "$symbol" "profile" "success" "$filepath"

    # Return summary with filepath
    local company_name=$(echo "$profile" | jq -r '.companyName // "Unknown"')
    local sector=$(echo "$profile" | jq -r '.sector // "N/A"')
    local industry=$(echo "$profile" | jq -r '.industry // "N/A"')

    cat <<EOF
{
  "success": true,
  "symbol": "$symbol",
  "company_name": "$company_name",
  "sector": "$sector",
  "industry": "$industry",
  "file": "$filepath",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
}

#############################################################################
# Company Search
#############################################################################

search_company() {
    local query="$1"
    local limit="${2:-10}"

    if [[ -z "$query" ]]; then
        format_error "invalid_params" "Search query cannot be empty"
        return 1
    fi

    local endpoint="/v3/search"
    local params="query=${query}&limit=${limit}"
    local response=$(fmp_api_call "$endpoint" "$params")

    if [[ $? -ne 0 ]]; then
        echo "$response"
        return 1
    fi

    # Save results (HIGHLY MUTABLE - search results change constantly, use timestamped filename)
    local query_slug=$(echo "$query" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
    local timestamp=$(date +%Y%m%d-%H%M%S)
    local filepath="$FMP_DATA_DIR/company/search-${query_slug}-${timestamp}.json"
    save_json "$filepath" "$response"

    local count=$(echo "$response" | jq 'length')

    log_request "$query" "search" "success" "$count results"

    cat <<EOF
{
  "success": true,
  "query": "$query",
  "count": $count,
  "file": "$filepath",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
}

#############################################################################
# Stock Screener
#############################################################################

fetch_stock_screener() {
    local market_cap_min="${1:-}"
    local market_cap_max="${2:-}"
    local sector="${3:-}"
    local limit="${4:-100}"

    local params="limit=${limit}"

    [[ -n "$market_cap_min" ]] && params="${params}&marketCapMoreThan=${market_cap_min}"
    [[ -n "$market_cap_max" ]] && params="${params}&marketCapLowerThan=${market_cap_max}"
    [[ -n "$sector" ]] && params="${params}&sector=${sector}"

    local endpoint="/v3/stock-screener"
    local response=$(fmp_api_call "$endpoint" "$params")

    if [[ $? -ne 0 ]]; then
        echo "$response"
        return 1
    fi

    # Save results
    local timestamp=$(date +"%Y%m%d-%H%M%S")
    local filepath="$FMP_DATA_DIR/company/screener-${timestamp}.json"
    save_json "$filepath" "$response"

    local count=$(echo "$response" | jq 'length')

    log_request "screener" "screener" "success" "$count stocks"

    cat <<EOF
{
  "success": true,
  "count": $count,
  "filters": {
    "market_cap_min": "$market_cap_min",
    "market_cap_max": "$market_cap_max",
    "sector": "$sector"
  },
  "file": "$filepath",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
}

#############################################################################
# Stock Peers
#############################################################################

fetch_stock_peers() {
    local symbol="$1"

    validate_symbol "$symbol" || return 1

    local endpoint="/v4/stock_peers"
    local params="symbol=${symbol}"
    local response=$(fmp_api_call "$endpoint" "$params")

    if [[ $? -ne 0 ]]; then
        echo "$response"
        return 1
    fi

    # Save to file (SEMI-MUTABLE - peers change occasionally, use dated filename)
    local filepath="$FMP_DATA_DIR/company/$(get_filename_dated "$symbol" "peers")"
    save_json "$filepath" "$response"

    local peers=$(echo "$response" | jq -r '.peersList[]? // empty' | tr '\n' ',' | sed 's/,$//')

    log_request "$symbol" "peers" "success" "$filepath"

    cat <<EOF
{
  "success": true,
  "symbol": "$symbol",
  "peers": "$peers",
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
        profile)
            fetch_company_profile "$@"
            ;;
        search)
            search_company "$@"
            ;;
        screener)
            fetch_stock_screener "$@"
            ;;
        peers)
            fetch_stock_peers "$@"
            ;;
        *)
            cat <<EOF
Usage: fetch-company.sh <action> [options]

Actions:
  profile <SYMBOL>                          Fetch company profile
  search <QUERY> [LIMIT]                    Search for companies
  screener [MIN_CAP] [MAX_CAP] [SECTOR]     Screen stocks
  peers <SYMBOL>                            Fetch peer companies

Examples:
  fetch-company.sh profile AAPL
  fetch-company.sh search "Apple" 5
  fetch-company.sh screener 1000000000 10000000000 Technology
  fetch-company.sh peers AAPL
EOF
            exit 1
            ;;
    esac
}

# Run main if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
