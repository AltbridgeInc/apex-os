#!/usr/bin/env bash
# FMP Analyst Data Fetcher
# Fetch analyst ratings, estimates, and price targets

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

#############################################################################
# Analyst Estimates
#############################################################################

fetch_analyst_estimates() {
    local symbol="$1"
    local period="${2:-annual}"
    local limit="${3:-10}"

    validate_symbol "$symbol" || return 1
    validate_period "$period" || return 1

    local endpoint="/v3/analyst-estimates/${symbol}"
    local params="limit=${limit}&period=${period}"
    local response=$(fmp_api_call "$endpoint" "$params")

    if [[ $? -ne 0 ]]; then
        echo "$response"
        return 1
    fi

    local count=$(echo "$response" | jq 'length')
    if [[ $count -eq 0 ]]; then
        format_error "no_data" "No analyst estimates for $symbol"
        return 1
    fi

    # Save to file (SEMI-MUTABLE - analyst estimates change when new reports published, use dated filename)
    local filepath="$FMP_DATA_DIR/analyst/$(get_filename_dated "$symbol" "estimates-${period}")"
    save_json "$filepath" "$response"

    log_request "$symbol" "analyst-estimates" "success" "$count periods"

    cat <<EOF
{
  "success": true,
  "symbol": "$symbol",
  "data_type": "analyst_estimates",
  "period": "$period",
  "count": $count,
  "file": "$filepath",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
}

#############################################################################
# Stock Grades
#############################################################################

fetch_stock_grades() {
    local symbol="$1"
    local limit="${2:-50}"

    validate_symbol "$symbol" || return 1

    local endpoint="/v3/grade/${symbol}"
    local params="limit=${limit}"
    local response=$(fmp_api_call "$endpoint" "$params")

    if [[ $? -ne 0 ]]; then
        echo "$response"
        return 1
    fi

    local count=$(echo "$response" | jq 'length')
    if [[ $count -eq 0 ]]; then
        format_error "no_data" "No stock grades for $symbol"
        return 1
    fi

    # Save to file (SEMI-MUTABLE - analyst grades/ratings change when new ratings published, use dated filename)
    local filepath="$FMP_DATA_DIR/analyst/$(get_filename_dated "$symbol" "grades")"
    save_json "$filepath" "$response"

    log_request "$symbol" "stock-grades" "success" "$count grades"

    cat <<EOF
{
  "success": true,
  "symbol": "$symbol",
  "data_type": "stock_grades",
  "count": $count,
  "file": "$filepath",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
}

#############################################################################
# Price Targets
#############################################################################

fetch_price_targets() {
    local symbol="$1"

    validate_symbol "$symbol" || return 1

    local endpoint="/v4/price-target"
    local params="symbol=${symbol}"
    local response=$(fmp_api_call "$endpoint" "$params")

    if [[ $? -ne 0 ]]; then
        echo "$response"
        return 1
    fi

    local count=$(echo "$response" | jq 'length')
    if [[ $count -eq 0 ]]; then
        format_error "no_data" "No price targets for $symbol"
        return 1
    fi

    # Save to file (SEMI-MUTABLE - price targets change when analysts update, use dated filename)
    local filepath="$FMP_DATA_DIR/analyst/$(get_filename_dated "$symbol" "price-targets")"
    save_json "$filepath" "$response"

    log_request "$symbol" "price-targets" "success" "$count targets"

    cat <<EOF
{
  "success": true,
  "symbol": "$symbol",
  "data_type": "price_targets",
  "count": $count,
  "file": "$filepath",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
}

#############################################################################
# Price Target Consensus
#############################################################################

fetch_price_target_consensus() {
    local symbol="$1"

    validate_symbol "$symbol" || return 1

    local endpoint="/v4/price-target-consensus"
    local params="symbol=${symbol}"
    local response=$(fmp_api_call "$endpoint" "$params")

    if [[ $? -ne 0 ]]; then
        echo "$response"
        return 1
    fi

    # Extract first element
    local consensus=$(echo "$response" | jq '.[0] // empty')

    if [[ -z "$consensus" || "$consensus" == "null" ]]; then
        format_error "no_data" "No price target consensus for $symbol"
        return 1
    fi

    # Save to file (SEMI-MUTABLE - consensus changes when analysts update targets, use dated filename)
    local filepath="$FMP_DATA_DIR/analyst/$(get_filename_dated "$symbol" "price-target-consensus")"
    save_json "$filepath" "$consensus"

    local target_high=$(echo "$consensus" | jq -r '.targetHigh // "N/A"')
    local target_low=$(echo "$consensus" | jq -r '.targetLow // "N/A"')
    local target_median=$(echo "$consensus" | jq -r '.targetMedian // "N/A"')

    log_request "$symbol" "price-target-consensus" "success" "median=$target_median"

    cat <<EOF
{
  "success": true,
  "symbol": "$symbol",
  "data_type": "price_target_consensus",
  "consensus": {
    "high": $target_high,
    "low": $target_low,
    "median": $target_median
  },
  "file": "$filepath",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
}

#############################################################################
# Upgrades & Downgrades
#############################################################################

fetch_upgrades_downgrades() {
    local symbol="$1"

    validate_symbol "$symbol" || return 1

    local endpoint="/v4/upgrades-downgrades"
    local params="symbol=${symbol}"
    local response=$(fmp_api_call "$endpoint" "$params")

    if [[ $? -ne 0 ]]; then
        echo "$response"
        return 1
    fi

    local count=$(echo "$response" | jq 'length')
    if [[ $count -eq 0 ]]; then
        format_error "no_data" "No upgrades/downgrades for $symbol"
        return 1
    fi

    # Save to file (SEMI-MUTABLE - upgrades/downgrades change when analysts publish, use dated filename)
    local filepath="$FMP_DATA_DIR/analyst/$(get_filename_dated "$symbol" "upgrades-downgrades")"
    save_json "$filepath" "$response"

    log_request "$symbol" "upgrades-downgrades" "success" "$count records"

    cat <<EOF
{
  "success": true,
  "symbol": "$symbol",
  "data_type": "upgrades_downgrades",
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
        estimates)
            fetch_analyst_estimates "$@"
            ;;
        grades)
            fetch_stock_grades "$@"
            ;;
        price-targets)
            fetch_price_targets "$@"
            ;;
        price-consensus)
            fetch_price_target_consensus "$@"
            ;;
        upgrades-downgrades)
            fetch_upgrades_downgrades "$@"
            ;;
        all)
            # Fetch all analyst data
            local symbol="$1"

            echo '{"success": true, "fetching": ["estimates", "grades", "price-targets", "price-consensus", "upgrades-downgrades"]}'

            fetch_analyst_estimates "$symbol" "annual" 10
            fetch_stock_grades "$symbol" 50
            fetch_price_targets "$symbol"
            fetch_price_target_consensus "$symbol"
            fetch_upgrades_downgrades "$symbol"
            ;;
        *)
            cat <<EOF
Usage: fetch-analyst.sh <action> [options]

Actions:
  estimates <SYMBOL> [PERIOD] [LIMIT]       Analyst estimates (annual/quarter)
  grades <SYMBOL> [LIMIT]                   Stock grades/ratings
  price-targets <SYMBOL>                    Price targets
  price-consensus <SYMBOL>                  Price target consensus
  upgrades-downgrades <SYMBOL>              Upgrades & downgrades
  all <SYMBOL>                              All analyst data

Examples:
  fetch-analyst.sh estimates AAPL annual 10
  fetch-analyst.sh grades TSLA 50
  fetch-analyst.sh price-targets MSFT
  fetch-analyst.sh all NVDA
EOF
            exit 1
            ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
