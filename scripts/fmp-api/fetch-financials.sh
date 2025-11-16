#!/usr/bin/env bash
# FMP Financial Statements Fetcher
# Fetch income statements, balance sheets, cash flow statements

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

#############################################################################
# Financial Statements
#############################################################################

fetch_financial_statement() {
    local symbol="$1"
    local statement_type="$2"
    local period="${3:-annual}"
    local limit="${4:-5}"

    validate_symbol "$symbol" || return 1
    validate_period "$period" || return 1

    # Map statement type to endpoint
    local endpoint
    case "$statement_type" in
        income)
            endpoint="/v3/income-statement/${symbol}"
            ;;
        balance)
            endpoint="/v3/balance-sheet-statement/${symbol}"
            ;;
        cashflow)
            endpoint="/v3/cash-flow-statement/${symbol}"
            ;;
        *)
            format_error "invalid_params" "Statement type must be: income, balance, or cashflow"
            return 1
            ;;
    esac

    local params="limit=${limit}&period=${period}"
    local response=$(fmp_api_call "$endpoint" "$params")

    if [[ $? -ne 0 ]]; then
        echo "$response"
        return 1
    fi

    # Validate response
    local count=$(echo "$response" | jq 'length')
    if [[ $count -eq 0 ]]; then
        format_error "no_data" "No $statement_type data for $symbol"
        return 1
    fi

    # Save combined file
    local combined_file="$FMP_DATA_DIR/financials/$(get_filename "$symbol" "${statement_type}-${period}")"
    save_json "$combined_file" "$response"

    # Save individual periods
    local saved_files=()
    while IFS= read -r statement; do
        local date=$(echo "$statement" | jq -r '.date // .calendarYear')
        local year=$(echo "$statement" | jq -r '.calendarYear // (.date | split("-")[0])')
        local quarter=$(echo "$statement" | jq -r '.period // ""')

        local suffix
        if [[ "$period" == "quarter" && -n "$quarter" ]]; then
            suffix="${year}-${quarter}"
        else
            suffix="${year}"
        fi

        local filepath="$FMP_DATA_DIR/financials/$(get_filename "$symbol" "${statement_type}" "$suffix")"
        save_json "$filepath" "$statement"
        saved_files+=("$filepath")
    done < <(echo "$response" | jq -c '.[]')

    log_request "$symbol" "financials-${statement_type}" "success" "$count $period periods"

    # Return summary
    local files_json=$(printf '%s\n' "${saved_files[@]}" | jq -R . | jq -s .)
    cat <<EOF
{
  "success": true,
  "symbol": "$symbol",
  "statement_type": "$statement_type",
  "period": "$period",
  "count": $count,
  "combined_file": "$combined_file",
  "files": $files_json,
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
}

#############################################################################
# Financial Ratios
#############################################################################

fetch_financial_ratios() {
    local symbol="$1"
    local period="${2:-annual}"
    local limit="${3:-5}"

    validate_symbol "$symbol" || return 1
    validate_period "$period" || return 1

    local endpoint="/v3/ratios/${symbol}"
    local params="limit=${limit}&period=${period}"
    local response=$(fmp_api_call "$endpoint" "$params")

    if [[ $? -ne 0 ]]; then
        echo "$response"
        return 1
    fi

    local count=$(echo "$response" | jq 'length')
    if [[ $count -eq 0 ]]; then
        format_error "no_data" "No ratio data for $symbol"
        return 1
    fi

    local filepath="$FMP_DATA_DIR/financials/$(get_filename "$symbol" "ratios-${period}")"
    save_json "$filepath" "$response"

    log_request "$symbol" "ratios" "success" "$count periods"

    cat <<EOF
{
  "success": true,
  "symbol": "$symbol",
  "data_type": "ratios",
  "period": "$period",
  "count": $count,
  "file": "$filepath",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
}

#############################################################################
# Key Metrics
#############################################################################

fetch_key_metrics() {
    local symbol="$1"
    local period="${2:-annual}"
    local limit="${3:-5}"

    validate_symbol "$symbol" || return 1
    validate_period "$period" || return 1

    local endpoint="/v3/key-metrics/${symbol}"
    local params="limit=${limit}&period=${period}"
    local response=$(fmp_api_call "$endpoint" "$params")

    if [[ $? -ne 0 ]]; then
        echo "$response"
        return 1
    fi

    local count=$(echo "$response" | jq 'length')
    if [[ $count -eq 0 ]]; then
        format_error "no_data" "No metrics data for $symbol"
        return 1
    fi

    local filepath="$FMP_DATA_DIR/financials/$(get_filename "$symbol" "metrics-${period}")"
    save_json "$filepath" "$response"

    log_request "$symbol" "metrics" "success" "$count periods"

    cat <<EOF
{
  "success": true,
  "symbol": "$symbol",
  "data_type": "key_metrics",
  "period": "$period",
  "count": $count,
  "file": "$filepath",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
}

#############################################################################
# Enterprise Values
#############################################################################

fetch_enterprise_values() {
    local symbol="$1"
    local period="${2:-annual}"
    local limit="${3:-5}"

    validate_symbol "$symbol" || return 1
    validate_period "$period" || return 1

    local endpoint="/v3/enterprise-values/${symbol}"
    local params="limit=${limit}&period=${period}"
    local response=$(fmp_api_call "$endpoint" "$params")

    if [[ $? -ne 0 ]]; then
        echo "$response"
        return 1
    fi

    local count=$(echo "$response" | jq 'length')
    if [[ $count -eq 0 ]]; then
        format_error "no_data" "No enterprise value data for $symbol"
        return 1
    fi

    local filepath="$FMP_DATA_DIR/financials/$(get_filename "$symbol" "enterprise-${period}")"
    save_json "$filepath" "$response"

    log_request "$symbol" "enterprise" "success" "$count periods"

    cat <<EOF
{
  "success": true,
  "symbol": "$symbol",
  "data_type": "enterprise_values",
  "period": "$period",
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
        income|balance|cashflow)
            fetch_financial_statement "$1" "$action" "${2:-annual}" "${3:-5}"
            ;;
        ratios)
            fetch_financial_ratios "$@"
            ;;
        metrics)
            fetch_key_metrics "$@"
            ;;
        enterprise)
            fetch_enterprise_values "$@"
            ;;
        all)
            # Fetch all financial data for a symbol
            local symbol="$1"
            local period="${2:-annual}"
            local limit="${3:-5}"

            echo '{"success": true, "fetching": ["income", "balance", "cashflow", "ratios", "metrics", "enterprise"]}'

            fetch_financial_statement "$symbol" "income" "$period" "$limit"
            fetch_financial_statement "$symbol" "balance" "$period" "$limit"
            fetch_financial_statement "$symbol" "cashflow" "$period" "$limit"
            fetch_financial_ratios "$symbol" "$period" "$limit"
            fetch_key_metrics "$symbol" "$period" "$limit"
            fetch_enterprise_values "$symbol" "$period" "$limit"
            ;;
        *)
            cat <<EOF
Usage: fetch-financials.sh <action> [options]

Actions:
  income <SYMBOL> [PERIOD] [LIMIT]          Income statement
  balance <SYMBOL> [PERIOD] [LIMIT]         Balance sheet
  cashflow <SYMBOL> [PERIOD] [LIMIT]        Cash flow statement
  ratios <SYMBOL> [PERIOD] [LIMIT]          Financial ratios
  metrics <SYMBOL> [PERIOD] [LIMIT]         Key metrics
  enterprise <SYMBOL> [PERIOD] [LIMIT]      Enterprise values
  all <SYMBOL> [PERIOD] [LIMIT]             All financial data

Parameters:
  SYMBOL    Stock symbol (required)
  PERIOD    annual or quarter (default: annual)
  LIMIT     Number of periods (default: 5)

Examples:
  fetch-financials.sh income AAPL annual 5
  fetch-financials.sh balance TSLA quarter 8
  fetch-financials.sh all MSFT annual 10
EOF
            exit 1
            ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
