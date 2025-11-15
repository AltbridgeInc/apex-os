#!/usr/bin/env bash
# fmp-transcript.sh - Fetch earnings call transcripts (uses /stable/ endpoint)
# Usage: ./fmp-transcript.sh SYMBOL [NUM_QUARTERS]
#   NUM_QUARTERS: number of recent quarters to fetch (default: 4)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/fmp-common.sh"

# Validate arguments
if [[ $# -lt 1 ]]; then
    format_error "invalid_params" "Usage: fmp-transcript.sh SYMBOL [NUM_QUARTERS]
  SYMBOL: Stock ticker
  NUM_QUARTERS: number of recent quarters to fetch (default: 4)"
    exit 1
fi

symbol=$(echo "$1" | tr '[:lower:]' '[:upper:]')
num_quarters=${2:-4}

# Validate symbol
validate_symbol "$symbol" || exit 1

# Validate num_quarters
if ! [[ "$num_quarters" =~ ^[0-9]+$ ]] || [[ $num_quarters -lt 1 ]] || [[ $num_quarters -gt 20 ]]; then
    format_error "invalid_params" "NUM_QUARTERS must be between 1 and 20"
    exit 1
fi

#############################################################################
# Function: fetch_transcript_dates
# Fetches available transcript dates/metadata via v4 API
#############################################################################
fetch_transcript_dates() {
    local sym="$1"

    # Use standard API endpoint for dates
    local endpoint="/v4/earning_call_transcript"
    local params="symbol=${sym}"

    local response=$(fmp_api_call "$endpoint" "$params")
    local exit_code=$?

    if [[ $exit_code -ne 0 ]]; then
        echo "$response"
        return 1
    fi

    # Response is array of arrays: [[quarter, year, date], ...]
    # Convert to array of objects for easier processing
    echo "$response" | jq 'map({
        quarter: .[0],
        year: .[1],
        date: .[2]
    }) | sort_by(.year, .quarter) | reverse'
}

#############################################################################
# Function: fetch_single_transcript
# Fetches full transcript text for a specific quarter/year using /stable/ endpoint
#############################################################################
fetch_single_transcript() {
    local sym="$1"
    local year="$2"
    local quarter="$3"

    # Load API key
    if ! load_api_key; then
        return 1
    fi

    # Build URL for /stable/ endpoint (different from /api)
    local base_url="https://financialmodelingprep.com/stable"
    local url="${base_url}/earning-call-transcript?symbol=${sym}&year=${year}&quarter=${quarter}&apikey=${FMP_API_KEY}"

    # Rate limit check
    check_rate_limit

    # Make request with retry logic
    local max_retries=3
    local retry_count=0
    local response
    local http_code

    while [[ $retry_count -lt $max_retries ]]; do
        response=$(curl -s -w "\n%{http_code}" --max-time 30 "$url" 2>&1)
        local curl_exit=$?

        if [[ $curl_exit -ne 0 ]]; then
            retry_count=$((retry_count + 1))
            if [[ $retry_count -ge $max_retries ]]; then
                format_error "network_error" "Network error fetching transcript for Q${quarter} ${year}"
                return 1
            fi
            sleep $((2 ** retry_count))
            continue
        fi

        http_code=$(echo "$response" | tail -n 1)
        response=$(echo "$response" | sed '$d')

        if [[ "$http_code" == "200" ]]; then
            # Validate JSON
            if echo "$response" | jq empty 2>/dev/null; then
                echo "$response"
                return 0
            else
                format_error "invalid_response" "Invalid JSON response for Q${quarter} ${year}"
                return 1
            fi
        elif [[ "$http_code" == "429" ]]; then
            retry_count=$((retry_count + 1))
            local sleep_time=$((2 ** retry_count))
            echo "Rate limit hit, sleeping ${sleep_time}s..." >&2
            sleep "$sleep_time"
        else
            map_http_error "$http_code" "/stable/earning-call-transcript"
            return 1
        fi
    done

    format_error "timeout" "Max retries exceeded for Q${quarter} ${year} transcript"
    return 1
}

#############################################################################
# Main execution
#############################################################################

echo "Fetching available transcript dates for $symbol..." >&2

# Step 1: Get available transcript dates
transcript_dates=$(fetch_transcript_dates "$symbol")

if echo "$transcript_dates" | jq -e '.error' > /dev/null 2>&1; then
    echo "$transcript_dates"
    exit 1
fi

# Check if any transcripts available
count=$(echo "$transcript_dates" | jq 'length')
if [[ $count -eq 0 ]]; then
    format_error "missing_data" "No transcripts available for $symbol"
    exit 1
fi

# Get last N quarters
echo "Found $count available transcripts. Fetching last $num_quarters quarters..." >&2
recent_dates=$(echo "$transcript_dates" | jq ".[0:$num_quarters]")

# Step 2: Fetch full transcript for each quarter
output='[]'
index=0

while IFS= read -r date_obj; do
    quarter=$(echo "$date_obj" | jq -r '.quarter')
    year=$(echo "$date_obj" | jq -r '.year')
    date=$(echo "$date_obj" | jq -r '.date')

    echo "Fetching transcript for Q${quarter} ${year}..." >&2

    transcript_data=$(fetch_single_transcript "$symbol" "$year" "$quarter")

    if echo "$transcript_data" | jq -e '.error' > /dev/null 2>&1; then
        echo "WARNING: Could not fetch Q${quarter} ${year} transcript" >&2
        continue
    fi

    # Check if array (successful) or error object
    if echo "$transcript_data" | jq -e 'type == "array"' > /dev/null 2>&1; then
        # Extract first element (should be the transcript object)
        transcript=$(echo "$transcript_data" | jq '.[0]')

        # Add metadata
        transcript_with_meta=$(echo "$transcript" | jq ". + {
            quarter: $quarter,
            year: $year,
            fetch_date: \"$date\"
        }")

        output=$(echo "$output" | jq ". += [$transcript_with_meta]")

        index=$((index + 1))
        echo "✓ Fetched Q${quarter} ${year}" >&2
    else
        echo "WARNING: Unexpected format for Q${quarter} ${year} transcript" >&2
    fi

done < <(echo "$recent_dates" | jq -c '.[]')

# Check if we got any transcripts
final_count=$(echo "$output" | jq 'length')
if [[ $final_count -eq 0 ]]; then
    format_error "missing_data" "Could not fetch any transcript content for $symbol"
    exit 1
fi

echo "Successfully fetched $final_count transcript(s)" >&2

# Save individual transcript files and track paths
saved_json_files=()
data_dir=$(get_data_directory)

while IFS= read -r transcript; do
    quarter=$(echo "$transcript" | jq -r '.quarter')
    year=$(echo "$transcript" | jq -r '.year')
    period="${year}-Q${quarter}"

    # Save transcript JSON
    filepath=$(save_json_data "$symbol" "transcript" "$period" "$transcript")
    saved_json_files+=("$filepath")

    echo "Saved: $(basename $filepath)" >&2
done < <(echo "$output" | jq -c '.[]')

# Also save combined file for convenience
combined_file=$(save_json_data "$symbol" "transcripts" "combined" "$output")
echo "Saved combined: $(basename $combined_file)" >&2

# Log operation
log_data_fetch "$symbol" "earnings-transcripts" "success" "Fetched ${#saved_json_files[@]} transcripts"

# Return summary JSON with file paths (not content!)
cat <<EOF
{
  "success": true,
  "symbol": "$symbol",
  "count": ${#saved_json_files[@]},
  "data_dir": "$data_dir",
  "files": $(printf '%s\n' "${saved_json_files[@]}" | jq -R . | jq -s .),
  "combined_file": "$combined_file",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
