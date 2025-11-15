#!/usr/bin/env bash
# fmp-financials.sh - Fetch financial statements
# Usage: ./fmp-financials.sh SYMBOL TYPE [LIMIT] [PERIOD]
#   TYPE: income, balance, cashflow
#   LIMIT: number of periods (default: 5)
#   PERIOD: annual, quarterly (default: annual)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/fmp-common.sh"

# Validate arguments
if [[ $# -lt 2 ]]; then
    format_error "invalid_params" "Usage: fmp-financials.sh SYMBOL TYPE [LIMIT] [PERIOD]
  TYPE: income, balance, cashflow
  LIMIT: number of periods (default: 5)
  PERIOD: annual, quarterly (default: annual)"
    exit 1
fi

symbol=$(echo "$1" | tr '[:lower:]' '[:upper:]')
statement_type=$(echo "$2" | tr '[:upper:]' '[:lower:]')
limit=${3:-5}
period=${4:-annual}

# Validate symbol
validate_symbol "$symbol" || exit 1

# Validate statement type and build endpoint
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
        format_error "invalid_params" "Invalid statement type: $statement_type (use: income, balance, cashflow)"
        exit 1
        ;;
esac

# Build parameters
params="limit=${limit}&period=${period}"

# Make API call
response=$(fmp_api_call "$endpoint" "$params")
exit_code=$?

if [[ $exit_code -ne 0 ]]; then
    echo "$response"
    exit 1
fi

# Validate response
if ! echo "$response" | jq -e 'type == "array"' > /dev/null 2>&1; then
    format_error "invalid_response" "Expected array response"
    exit 1
fi

count=$(echo "$response" | jq 'length')
if [[ $count -eq 0 ]]; then
    format_error "missing_data" "No financial data returned for $symbol"
    exit 1
fi

echo "Successfully fetched $count financial statement(s)" >&2

# Sort by date, newest first
sorted_response=$(echo "$response" | jq 'sort_by(.date) | reverse')

# Save individual statement files and track paths
saved_json_files=()
data_dir=$(get_data_directory)

while IFS= read -r statement; do
    date=$(echo "$statement" | jq -r '.date // .calendarYear')
    year=$(echo "$statement" | jq -r '.calendarYear // (.date | split("-")[0])')

    # Determine period suffix
    if [[ "$period" == "quarterly" ]]; then
        quarter=$(echo "$statement" | jq -r '.period // "Q1"')
        period_suffix="${year}-${quarter}"
    else
        period_suffix="${year}-annual"
    fi

    # Save statement JSON
    filepath=$(save_json_data "$symbol" "${statement_type}-statement" "$period_suffix" "$statement")
    saved_json_files+=("$filepath")

    echo "Saved: $(basename $filepath)" >&2
done < <(echo "$sorted_response" | jq -c '.[]')

# Also save combined file
combined_file=$(save_json_data "$symbol" "${statement_type}-statements" "combined-${period}" "$sorted_response")
echo "Saved combined: $(basename $combined_file)" >&2

# Log operation
log_data_fetch "$symbol" "financials-${statement_type}" "success" "Fetched ${#saved_json_files[@]} ${period} periods"

# Return summary JSON with file paths (not content!)
cat <<EOF
{
  "success": true,
  "symbol": "$symbol",
  "statement_type": "$statement_type",
  "period": "$period",
  "count": ${#saved_json_files[@]},
  "data_dir": "$data_dir",
  "files": $(printf '%s\n' "${saved_json_files[@]}" | jq -R . | jq -s .),
  "combined_file": "$combined_file",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
