#!/usr/bin/env bash
# fmp-common.sh - Shared functions for FMP API integration
# This script provides common functions used by all FMP helper scripts
set -euo pipefail

# Load FMP API key from .env file
# Tries multiple locations in order of preference
# Returns: 0 if successful, 1 if key not found
load_api_key() {
    # Try multiple locations in order of preference
    local env_candidates=(
        "${PROJECT_DIR:-.}/apex-os/.env"             # apex-os folder (preferred)
        "${PROJECT_DIR:-.}/.env"                    # Project directory (legacy)
        "$(pwd)/apex-os/.env"                       # Current dir apex-os folder
        "$(pwd)/.env"                                # Current directory (legacy)
        "${APEX_OS_DIR:-$HOME/apex-os}/.env"        # Base installation
        "$HOME/.config/apex-os/.env"                 # User config
    )

    local env_file=""
    for candidate in "${env_candidates[@]}"; do
        if [[ -f "$candidate" ]]; then
            env_file="$candidate"
            break
        fi
    done

    if [[ -z "$env_file" ]]; then
        format_error "missing_api_key" ".env file not found. Searched: ${env_candidates[*]}"
        return 1
    fi

    # Source .env and export FMP_API_KEY
    set +u  # Temporarily disable unset variable check
    source "$env_file"
    set -u

    if [[ -z "${FMP_API_KEY:-}" ]]; then
        format_error "missing_api_key" "FMP_API_KEY not defined in $env_file"
        return 1
    fi

    export FMP_API_KEY
    return 0
}

# Format standardized error JSON
# Args:
#   $1: error type
#   $2: error message
# Returns: JSON error object
format_error() {
    local error_type="$1"
    local message="$2"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date +"%Y-%m-%dT%H:%M:%SZ")

    cat <<EOF
{
  "error": true,
  "type": "$error_type",
  "message": "$message",
  "timestamp": "$timestamp"
}
EOF
}

# Map HTTP error codes to user-friendly messages
# Args:
#   $1: HTTP status code
#   $2: endpoint path
map_http_error() {
    local code="$1"
    local endpoint="$2"

    case "$code" in
        400)
            format_error "http_error" "Invalid request parameters for $endpoint"
            ;;
        401)
            format_error "http_error" "FMP API key is invalid or expired"
            ;;
        403)
            format_error "http_error" "Access denied - check API subscription tier"
            ;;
        404)
            format_error "http_error" "Endpoint not found or symbol invalid: $endpoint"
            ;;
        429)
            format_error "rate_limit" "Rate limit exceeded - retry after a few seconds"
            ;;
        500)
            format_error "http_error" "FMP API server error - retry later"
            ;;
        503)
            format_error "http_error" "FMP API temporarily unavailable"
            ;;
        *)
            format_error "http_error" "HTTP $code error for $endpoint"
            ;;
    esac
}

# Validate stock symbol
# Args:
#   $1: symbol
# Returns: 0 if valid, 1 if invalid
validate_symbol() {
    local symbol="$1"

    if [[ -z "$symbol" ]]; then
        format_error "invalid_symbol" "Symbol cannot be empty"
        return 1
    fi

    # Check format: 1-5 uppercase letters, optional comma for batch
    # Allow comma-separated symbols for batch requests
    if [[ "$symbol" =~ , ]]; then
        # Batch symbols - validate each
        IFS=',' read -ra SYMBOLS <<< "$symbol"
        for sym in "${SYMBOLS[@]}"; do
            sym=$(echo "$sym" | tr -d ' ')
            if [[ ! "$sym" =~ ^[A-Z]{1,5}([-.]?[A-Z]{1,2})?$ ]]; then
                format_error "invalid_symbol" "Invalid symbol format: $sym"
                return 1
            fi
        done
    else
        # Single symbol
        if [[ ! "$symbol" =~ ^[A-Z]{1,5}([-.]?[A-Z]{1,2})?$ ]]; then
            format_error "invalid_symbol" "Invalid symbol format: $symbol"
            return 1
        fi
    fi

    return 0
}

# Track and manage API rate limits
# FMP Paid Tier: 250 requests/minute
check_rate_limit() {
    local rate_file="/tmp/fmp_rate_$(date +%Y%m%d_%H%M).txt"

    # Create file if it doesn't exist
    if [[ ! -f "$rate_file" ]]; then
        touch "$rate_file" 2>/dev/null || true
    fi

    local count=$(wc -l < "$rate_file" 2>/dev/null || echo 0)

    # If approaching limit (240/250), sleep
    if [[ $count -ge 240 ]]; then
        echo "WARNING: Approaching rate limit, sleeping 10s..." >&2
        sleep 10
        # Clear old rate files
        rm -f /tmp/fmp_rate_*.txt
        rate_file="/tmp/fmp_rate_$(date +%Y%m%d_%H%M).txt"
        touch "$rate_file" 2>/dev/null || true
    fi

    # Record this call
    echo "$(date +%s)" >> "$rate_file" 2>/dev/null || true
}

# Make FMP API call with error handling
# Args:
#   $1: endpoint path (e.g., "/v3/quote/AAPL")
#   $2: optional additional parameters (e.g., "limit=5&period=annual")
# Returns: JSON response or error JSON
fmp_api_call() {
    local endpoint="$1"
    local params="${2:-}"
    local base_url="https://financialmodelingprep.com/api"

    # Load API key
    if ! load_api_key; then
        return 1
    fi

    # Build URL
    local url="${base_url}${endpoint}?apikey=${FMP_API_KEY}"
    if [[ -n "$params" ]]; then
        url="${url}&${params}"
    fi

    # Rate limit check
    check_rate_limit

    # Make request with retry logic
    local max_retries=3
    local retry_count=0
    local response
    local http_code

    while [[ $retry_count -lt $max_retries ]]; do
        # Execute curl with timeout
        response=$(curl -s -w "\n%{http_code}" --max-time 30 "$url" 2>&1)
        local curl_exit=$?

        # Check if curl succeeded
        if [[ $curl_exit -ne 0 ]]; then
            retry_count=$((retry_count + 1))
            if [[ $retry_count -ge $max_retries ]]; then
                format_error "network_error" "Network error: curl failed after $max_retries attempts"
                return 1
            fi
            sleep $((2 ** retry_count))
            continue
        fi

        http_code=$(echo "$response" | tail -n 1)
        response=$(echo "$response" | sed '$d')

        # Check HTTP status
        if [[ "$http_code" == "200" ]]; then
            # Validate JSON
            if echo "$response" | jq empty 2>/dev/null; then
                echo "$response"
                return 0
            else
                format_error "invalid_response" "FMP returned invalid JSON"
                return 1
            fi
        elif [[ "$http_code" == "429" ]]; then
            # Rate limit - retry with backoff
            retry_count=$((retry_count + 1))
            local sleep_time=$((2 ** retry_count))
            echo "Rate limit hit, sleeping ${sleep_time}s..." >&2
            sleep "$sleep_time"
        elif [[ "$http_code" == "500" ]] || [[ "$http_code" == "503" ]]; then
            # Server error - retry
            retry_count=$((retry_count + 1))
            sleep $((2 ** retry_count))
        else
            # Other error - don't retry
            map_http_error "$http_code" "$endpoint"
            return 1
        fi
    done

    # Max retries exceeded
    format_error "timeout" "Max retries exceeded for $endpoint"
    return 1
}

#############################################################################
# File-Based Data Management Functions
#############################################################################

# Get data directory path (dynamically)
# Returns: absolute path to apex-os/data/fmp/ directory
get_data_directory() {
    local workspace_root="${PROJECT_DIR:-.}"
    local data_dir="${DATA_CACHE_DIR:-apex-os/data}/fmp"
    local full_path="$workspace_root/$data_dir"

    # Create if doesn't exist
    mkdir -p "$full_path"

    echo "$full_path"
}

# Generate standardized filename
# Args:
#   $1: symbol (e.g., AAPL)
#   $2: data type (e.g., transcript, income-statement, news)
#   $3: period (e.g., 2024-Q3, 2024-annual, 2024-11-14)
#   $4: extension (default: json)
# Returns: standardized filename
get_standard_filename() {
    local symbol=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    local data_type="$2"
    local period="$3"
    local ext="${4:-json}"

    echo "${symbol}-${data_type}-${period}.${ext}"
}

# Save JSON data to file with standardized naming
# Args:
#   $1: symbol
#   $2: data type
#   $3: period
#   $4: JSON content
# Returns: absolute file path
save_json_data() {
    local symbol="$1"
    local data_type="$2"
    local period="$3"
    local content="$4"

    local data_dir=$(get_data_directory)
    local filename=$(get_standard_filename "$symbol" "$data_type" "$period" "json")
    local filepath="${data_dir}/${filename}"

    echo "$content" > "$filepath"
    echo "$filepath"
}

# Save text data to file
# Args:
#   $1: symbol
#   $2: data type
#   $3: period
#   $4: text content
#   $5: extension (default: txt)
# Returns: absolute file path
save_text_data() {
    local symbol="$1"
    local data_type="$2"
    local period="$3"
    local content="$4"
    local ext="${5:-txt}"

    local data_dir=$(get_data_directory)
    local filename=$(get_standard_filename "$symbol" "$data_type" "$period" "$ext")
    local filepath="${data_dir}/${filename}"

    echo "$content" > "$filepath"
    echo "$filepath"
}

# Log data fetch operation
# Args:
#   $1: symbol
#   $2: endpoint
#   $3: status (success/error)
#   $4: details
log_data_fetch() {
    local symbol="$1"
    local endpoint="$2"
    local status="$3"
    local details="$4"

    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date +"%Y-%m-%dT%H:%M:%SZ")
    local log_file="${PROJECT_DIR:-.}/apex-os/logs/data-fetch.log"

    mkdir -p "$(dirname "$log_file")"

    echo "${timestamp}|${symbol}|${endpoint}|${status}|${details}" >> "$log_file"
}

# Export functions for use by other scripts
export -f load_api_key
export -f fmp_api_call
export -f format_error
export -f map_http_error
export -f validate_symbol
export -f check_rate_limit
export -f get_data_directory
export -f get_standard_filename
export -f save_json_data
export -f save_text_data
export -f log_data_fetch
