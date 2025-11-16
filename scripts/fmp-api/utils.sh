#!/usr/bin/env bash
# FMP API Utilities
# Core functions for API calls, error handling, and data management

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

#############################################################################
# Error Handling & Formatting
#############################################################################

# Format error as JSON
format_error() {
    local error_type="$1"
    local message="$2"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    cat <<EOF
{
  "success": false,
  "error": {
    "type": "$error_type",
    "message": "$message",
    "timestamp": "$timestamp"
  }
}
EOF
}

# Format success response as JSON
format_success() {
    local message="$1"
    local data="${2:-null}"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    cat <<EOF
{
  "success": true,
  "message": "$message",
  "timestamp": "$timestamp",
  "data": $data
}
EOF
}

# Map HTTP status codes to errors
map_http_error() {
    local code="$1"
    local endpoint="$2"

    case "$code" in
        400) format_error "bad_request" "Invalid parameters for $endpoint" ;;
        401) format_error "unauthorized" "Invalid API key" ;;
        403) format_error "forbidden" "Access denied - check subscription tier" ;;
        404) format_error "not_found" "Resource not found: $endpoint" ;;
        429) format_error "rate_limit" "Rate limit exceeded - retry later" ;;
        500) format_error "server_error" "FMP server error" ;;
        503) format_error "unavailable" "FMP service unavailable" ;;
        *) format_error "http_error" "HTTP $code error for $endpoint" ;;
    esac
}

#############################################################################
# Validation
#############################################################################

# Validate stock symbol format
validate_symbol() {
    local symbol="$1"

    if [[ -z "$symbol" ]]; then
        format_error "invalid_symbol" "Symbol cannot be empty"
        return 1
    fi

    # Allow single symbols and comma-separated batch
    if [[ "$symbol" =~ , ]]; then
        IFS=',' read -ra SYMBOLS <<< "$symbol"
        for sym in "${SYMBOLS[@]}"; do
            sym=$(echo "$sym" | tr -d ' ')
            if [[ ! "$sym" =~ ^[A-Z]{1,5}([-.]?[A-Z0-9]{1,2})?$ ]]; then
                format_error "invalid_symbol" "Invalid symbol format: $sym"
                return 1
            fi
        done
    else
        if [[ ! "$symbol" =~ ^[A-Z]{1,5}([-.]?[A-Z0-9]{1,2})?$ ]]; then
            format_error "invalid_symbol" "Invalid symbol format: $symbol"
            return 1
        fi
    fi

    return 0
}

# Validate period (annual/quarter)
validate_period() {
    local period="$1"

    if [[ "$period" != "annual" && "$period" != "quarter" ]]; then
        format_error "invalid_period" "Period must be 'annual' or 'quarter'"
        return 1
    fi

    return 0
}

#############################################################################
# Rate Limiting
#############################################################################

# Track API rate limits
check_rate_limit() {
    local rate_file="$FMP_LOG_DIR/rate_$(date +%Y%m%d_%H%M).txt"

    if [[ ! -f "$rate_file" ]]; then
        touch "$rate_file"
    fi

    local count=$(wc -l < "$rate_file" 2>/dev/null || echo 0)

    # Approaching limit (240/250)
    if [[ $count -ge 240 ]]; then
        log_message "WARN" "Rate limit approaching ($count/$FMP_RATE_LIMIT), pausing..."
        sleep 10
        # Clean old rate files
        find "$FMP_LOG_DIR" -name "rate_*.txt" -mmin +2 -delete 2>/dev/null || true
        rate_file="$FMP_LOG_DIR/rate_$(date +%Y%m%d_%H%M).txt"
        touch "$rate_file"
    fi

    # Record this request
    echo "$(date +%s)" >> "$rate_file"
}

#############################################################################
# API Calls
#############################################################################

# Make FMP API call with retry logic
fmp_api_call() {
    local endpoint="$1"
    local params="${2:-}"

    # Load API key
    if ! load_api_key; then
        format_error "config_error" "Failed to load API key"
        return 1
    fi

    # Build URL
    local url="${FMP_API_BASE_URL}${endpoint}?apikey=${FMP_API_KEY}"
    if [[ -n "$params" ]]; then
        url="${url}&${params}"
    fi

    # Rate limit check
    check_rate_limit

    # Retry logic
    local retry_count=0
    local response
    local http_code

    while [[ $retry_count -lt $FMP_MAX_RETRIES ]]; do
        # Make request
        response=$(curl -s -w "\n%{http_code}" --max-time "$FMP_TIMEOUT" "$url" 2>&1)
        local curl_exit=$?

        if [[ $curl_exit -ne 0 ]]; then
            retry_count=$((retry_count + 1))
            if [[ $retry_count -ge $FMP_MAX_RETRIES ]]; then
                format_error "network_error" "Network error after $FMP_MAX_RETRIES attempts"
                return 1
            fi
            sleep $((2 ** retry_count))
            continue
        fi

        http_code=$(echo "$response" | tail -n 1)
        response=$(echo "$response" | sed '$d')

        # Success
        if [[ "$http_code" == "200" ]]; then
            # Validate JSON
            if echo "$response" | jq empty 2>/dev/null; then
                echo "$response"
                return 0
            else
                format_error "invalid_response" "Invalid JSON response"
                return 1
            fi
        # Retryable errors
        elif [[ "$http_code" == "429" || "$http_code" == "500" || "$http_code" == "503" ]]; then
            retry_count=$((retry_count + 1))
            local sleep_time=$((2 ** retry_count))
            log_message "WARN" "HTTP $http_code - retrying in ${sleep_time}s (attempt $retry_count/$FMP_MAX_RETRIES)"
            sleep "$sleep_time"
        # Non-retryable errors
        else
            map_http_error "$http_code" "$endpoint"
            return 1
        fi
    done

    format_error "timeout" "Max retries exceeded"
    return 1
}

#############################################################################
# Data Management
#############################################################################

# Get timestamped filename
get_filename() {
    local symbol="$1"
    local data_type="$2"
    local suffix="${3:-}"
    local ext="${4:-json}"

    symbol=$(echo "$symbol" | tr '[:upper:]' '[:lower:]')

    if [[ -n "$suffix" ]]; then
        echo "${symbol}-${data_type}-${suffix}.${ext}"
    else
        echo "${symbol}-${data_type}.${ext}"
    fi
}

# Save JSON data to file
save_json() {
    local filepath="$1"
    local content="$2"

    # Ensure directory exists
    mkdir -p "$(dirname "$filepath")"

    # Validate and format JSON
    if echo "$content" | jq empty 2>/dev/null; then
        echo "$content" | jq '.' > "$filepath"
        return 0
    else
        log_message "ERROR" "Invalid JSON, saving raw content"
        echo "$content" > "$filepath"
        return 1
    fi
}

# Save text data to file
save_text() {
    local filepath="$1"
    local content="$2"

    mkdir -p "$(dirname "$filepath")"
    echo "$content" > "$filepath"
}

#############################################################################
# Logging
#############################################################################

# Log message to file and stderr
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local log_file="$FMP_LOG_DIR/fmp-api.log"

    echo "[$timestamp] [$level] $message" | tee -a "$log_file" >&2
}

# Log API request
log_request() {
    local symbol="$1"
    local endpoint="$2"
    local status="$3"
    local details="${4:-}"

    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local log_file="$FMP_LOG_DIR/requests.log"

    echo "${timestamp}|${symbol}|${endpoint}|${status}|${details}" >> "$log_file"
}

#############################################################################
# Export functions
#############################################################################

export -f format_error
export -f format_success
export -f map_http_error
export -f validate_symbol
export -f validate_period
export -f check_rate_limit
export -f fmp_api_call
export -f get_filename
export -f save_json
export -f save_text
export -f log_message
export -f log_request
