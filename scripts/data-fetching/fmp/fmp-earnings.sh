#!/usr/bin/env bash
# fmp-earnings.sh - Fetch earnings calendar, surprises, and transcripts
# Usage: ./fmp-earnings.sh SYMBOL [TYPE] [LIMIT]
#   TYPE: calendar, surprises, transcripts (default: calendar)
#   LIMIT: number of records (default: 20 for calendar, 10 for transcripts)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/fmp-common.sh"

# Validate arguments
if [[ $# -lt 1 ]]; then
    format_error "invalid_params" "Usage: fmp-earnings.sh SYMBOL [TYPE] [LIMIT]
  TYPE: calendar, surprises, transcripts (default: calendar)
  LIMIT: number of records (default: 20 for calendar, 10 for transcripts)"
    exit 1
fi

symbol=$(echo "$1" | tr '[:lower:]' '[:upper:]')
type=$(echo "${2:-calendar}" | tr '[:upper:]' '[:lower:]')
limit=${3:-}

# Validate symbol
validate_symbol "$symbol" || exit 1

# Set default limits if not specified
case "$type" in
    calendar|surprises)
        limit=${limit:-20}
        ;;
    transcripts)
        limit=${limit:-10}
        ;;
esac

# Build endpoint based on type
case "$type" in
    calendar)
        # Earnings calendar includes actual vs estimated (surprises)
        endpoint="/v3/historical/earning_calendar/${symbol}"
        params="limit=${limit}"
        ;;

    surprises)
        # Alias for calendar (same data, different name)
        endpoint="/v3/historical/earning_calendar/${symbol}"
        params="limit=${limit}"
        ;;

    transcripts)
        # Get list of available earnings transcripts (dates only)
        # Note: This returns available transcript dates, not full text
        # For full transcripts, need to call /stable/earning-call-transcript with year & quarter
        endpoint="/v4/earning_call_transcript"
        params="symbol=${symbol}"
        if [[ -n "$limit" ]]; then
            params="${params}"  # v4 doesn't support limit, returns all available
        fi
        ;;

    *)
        format_error "invalid_params" "Invalid type: $type (use: calendar, surprises, transcripts)"
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

# Validate response is array
if ! echo "$response" | jq -e 'type == "array"' > /dev/null 2>&1; then
    format_error "invalid_response" "Expected array response"
    exit 1
fi

# Check if array is empty
count=$(echo "$response" | jq 'length')
if [[ $count -eq 0 ]]; then
    format_error "missing_data" "No earnings data returned for $symbol (type: $type)"
    exit 1
fi

# Return response (sorted by date, newest first)
echo "$response" | jq 'sort_by(.date) | reverse'
