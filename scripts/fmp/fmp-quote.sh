#!/usr/bin/env bash
# fmp-quote.sh - Fetch real-time stock quotes
# Usage: ./fmp-quote.sh SYMBOL[,SYMBOL2,...]
set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/fmp-common.sh"

# Validate arguments
if [[ $# -lt 1 ]]; then
    format_error "invalid_params" "Usage: fmp-quote.sh SYMBOL[,SYMBOL2,...]"
    exit 1
fi

symbols="$1"

# Validate symbols (basic check for comma-separated list)
if [[ -z "$symbols" ]]; then
    format_error "invalid_symbol" "Symbols cannot be empty"
    exit 1
fi

# Convert symbols to uppercase
symbols=$(echo "$symbols" | tr '[:lower:]' '[:upper:]')

# Build endpoint
endpoint="/v3/quote/${symbols}"

# Make API call
response=$(fmp_api_call "$endpoint")
exit_code=$?

if [[ $exit_code -ne 0 ]]; then
    echo "$response"
    exit 1
fi

# Validate response is array
if ! echo "$response" | jq -e 'type == "array"' > /dev/null 2>&1; then
    format_error "invalid_response" "Expected array response from quote endpoint"
    exit 1
fi

# Check if array is empty
count=$(echo "$response" | jq 'length')
if [[ $count -eq 0 ]]; then
    format_error "missing_data" "No quote data returned for symbols: $symbols"
    exit 1
fi

# Return response
echo "$response"
