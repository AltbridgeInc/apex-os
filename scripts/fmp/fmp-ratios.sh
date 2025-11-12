#!/usr/bin/env bash
# fmp-ratios.sh - Fetch financial ratios and metrics
# Usage: ./fmp-ratios.sh SYMBOL TYPE [LIMIT]
#   TYPE: ratios, metrics, growth
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/fmp-common.sh"

if [[ $# -lt 2 ]]; then
    format_error "invalid_params" "Usage: fmp-ratios.sh SYMBOL TYPE [LIMIT]
  TYPE: ratios, metrics, growth"
    exit 1
fi

symbol=$(echo "$1" | tr '[:lower:]' '[:upper:]')
ratio_type=$(echo "$2" | tr '[:upper:]' '[:lower:]')
limit=${3:-5}

validate_symbol "$symbol" || exit 1

case "$ratio_type" in
    ratios)
        endpoint="/v3/ratios/${symbol}"
        ;;
    metrics)
        endpoint="/v3/key-metrics/${symbol}"
        ;;
    growth)
        endpoint="/v3/financial-growth/${symbol}"
        ;;
    *)
        format_error "invalid_params" "Invalid type: $ratio_type (use: ratios, metrics, growth)"
        exit 1
        ;;
esac

params="limit=${limit}"

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

echo "$response" | jq 'sort_by(.date) | reverse'
