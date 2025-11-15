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

echo "Successfully fetched $count earnings record(s)" >&2

# Sort by date, newest first
sorted_response=$(echo "$response" | jq 'sort_by(.date) | reverse')

# Save to file
data_dir=$(get_data_directory)
date_str=$(date +%Y-%m-%d)

# Save earnings data with type-specific naming
combined_file=$(save_json_data "$symbol" "earnings-${type}" "$date_str" "$sorted_response")
echo "Saved: $(basename $combined_file)" >&2

# Log operation
log_data_fetch "$symbol" "earnings-${type}" "success" "Fetched ${count} records"

# Return summary JSON with file path (not content!)
cat <<EOF
{
  "success": true,
  "symbol": "$symbol",
  "type": "$type",
  "count": ${count},
  "data_dir": "$data_dir",
  "file": "$combined_file",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
