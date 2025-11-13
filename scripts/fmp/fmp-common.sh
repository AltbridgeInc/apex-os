#!/usr/bin/env bash
# fmp-common.sh - Shared functions for FMP API integration
# This script provides common functions used by all FMP helper scripts
set -euo pipefail

# Load FMP API key from .env file
# Returns: 0 if successful, 1 if key not found
load_api_key() {
    # Check if FMP_API_KEY is already set in environment
    if [[ -n "${FMP_API_KEY:-}" ]]; then
        export FMP_API_KEY
        return 0
    fi

    local env_file="/Users/nazymazimbayev/apex-os-1/.env"

    if [[ ! -f "$env_file" ]]; then
        format_error "missing_api_key" ".env file not found at $env_file"
        return 1
    fi

    # Source .env and export FMP_API_KEY
    set +u  # Temporarily disable unset variable check
    source "$env_file"
    set -u

    if [[ -z "${FMP_API_KEY:-}" ]]; then
        format_error "missing_api_key" "FMP_API_KEY not defined in .env"
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

# Export functions for use by other scripts
export -f load_api_key
export -f fmp_api_call
export -f format_error
export -f map_http_error
export -f validate_symbol
export -f check_rate_limit
