#!/usr/bin/env bash
# fmp-profile.sh - Fetch company profile
# Usage: ./fmp-profile.sh SYMBOL
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/fmp-common.sh"

if [[ $# -lt 1 ]]; then
    format_error "invalid_params" "Usage: fmp-profile.sh SYMBOL"
    exit 1
fi

symbol=$(echo "$1" | tr '[:lower:]' '[:upper:]')
validate_symbol "$symbol" || exit 1

endpoint="/v3/profile/${symbol}"

response=$(fmp_api_call "$endpoint")
exit_code=$?

if [[ $exit_code -ne 0 ]]; then
    echo "$response"
    exit 1
fi

if ! echo "$response" | jq -e 'type == "array"' > /dev/null 2>&1; then
    format_error "invalid_response" "Expected array response"
    exit 1
fi

# Return first element (profile is returned as single-element array)
echo "$response" | jq '.[0]'
