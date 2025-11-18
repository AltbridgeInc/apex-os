#!/usr/bin/env bash
# YouTube API Utilities
# Shared functions for validation, API calls, and error handling

# Check if required dependencies are installed
check_dependencies() {
    local missing=()

    if ! command -v curl &> /dev/null; then
        missing+=("curl")
    fi

    if ! command -v jq &> /dev/null; then
        missing+=("jq")
    fi

    if ! command -v python3 &> /dev/null; then
        missing+=("python3")
    fi

    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "ERROR: Missing required dependencies: ${missing[*]}" >&2
        echo "Install with: apt install ${missing[*]} (Ubuntu/Debian) or brew install ${missing[*]} (macOS)" >&2
        return 1
    fi

    return 0
}

# Validate YouTube API key
validate_api_key() {
    if [[ -z "${YOUTUBE_API_KEY:-}" ]]; then
        echo "ERROR: YOUTUBE_API_KEY not set" >&2
        echo "Please set it in apex-os/.env file" >&2
        return 1
    fi
    return 0
}

# Validate YouTube video ID format
# Format: 11 characters, alphanumeric plus - and _
validate_video_id() {
    local video_id="$1"

    if [[ -z "$video_id" ]]; then
        echo "ERROR: Video ID is required" >&2
        return 1
    fi

    if [[ ! "$video_id" =~ ^[a-zA-Z0-9_-]{11}$ ]]; then
        echo "ERROR: Invalid video ID format: $video_id" >&2
        echo "Expected: 11 characters (alphanumeric, -, _)" >&2
        return 1
    fi

    return 0
}

# Validate YouTube channel ID format
# Format: Starts with UC, 24 characters total
validate_channel_id() {
    local channel_id="$1"

    if [[ -z "$channel_id" ]]; then
        echo "ERROR: Channel ID is required" >&2
        return 1
    fi

    if [[ ! "$channel_id" =~ ^UC[a-zA-Z0-9_-]{22}$ ]]; then
        echo "ERROR: Invalid channel ID format: $channel_id" >&2
        echo "Expected: Starts with UC, 24 characters total" >&2
        return 1
    fi

    return 0
}

# Validate YouTube playlist ID format
# Format: Starts with PL, 34 or 32 characters total
validate_playlist_id() {
    local playlist_id="$1"

    if [[ -z "$playlist_id" ]]; then
        echo "ERROR: Playlist ID is required" >&2
        return 1
    fi

    if [[ ! "$playlist_id" =~ ^PL[a-zA-Z0-9_-]{32}$ ]] && [[ ! "$playlist_id" =~ ^PL[a-zA-Z0-9_-]{16}$ ]]; then
        echo "ERROR: Invalid playlist ID format: $playlist_id" >&2
        echo "Expected: Starts with PL" >&2
        return 1
    fi

    return 0
}

# Make YouTube API call with error handling
make_youtube_api_call() {
    local url="$1"
    local max_retries="${YOUTUBE_MAX_RETRIES:-3}"
    local timeout="${YOUTUBE_TIMEOUT:-30}"
    local retry_count=0
    local response
    local http_code

    while [[ $retry_count -lt $max_retries ]]; do
        # Make request and capture both response and HTTP status code
        response=$(curl -s -w "\n%{http_code}" --max-time "$timeout" "$url")
        http_code=$(echo "$response" | tail -n1)
        response=$(echo "$response" | sed '$d')

        # Check HTTP status code
        case "$http_code" in
            200)
                # Success
                echo "$response"
                return 0
                ;;
            400)
                echo "ERROR: Bad request (HTTP 400)" >&2
                echo "$response" >&2
                return 1
                ;;
            403)
                # Check if quota exceeded
                if echo "$response" | jq -e '.error.errors[0].reason == "quotaExceeded"' &> /dev/null; then
                    echo "ERROR: YouTube API quota exceeded" >&2
                    echo "Daily limit reached. Try again tomorrow or upgrade to paid tier." >&2
                else
                    echo "ERROR: Forbidden (HTTP 403) - Check API key validity" >&2
                fi
                echo "$response" >&2
                return 1
                ;;
            404)
                echo "ERROR: Resource not found (HTTP 404)" >&2
                echo "$response" >&2
                return 1
                ;;
            429)
                echo "WARNING: Rate limited (HTTP 429) - Retrying..." >&2
                sleep $((2 ** retry_count))
                ((retry_count++))
                continue
                ;;
            500|502|503|504)
                echo "WARNING: Server error (HTTP $http_code) - Retrying..." >&2
                sleep $((2 ** retry_count))
                ((retry_count++))
                continue
                ;;
            000)
                echo "ERROR: Network error - Could not reach YouTube API" >&2
                return 1
                ;;
            *)
                echo "ERROR: Unexpected HTTP status: $http_code" >&2
                echo "$response" >&2
                return 1
                ;;
        esac
    done

    echo "ERROR: Max retries ($max_retries) exceeded" >&2
    return 1
}

# Fetch video metadata from YouTube API
fetch_video_metadata() {
    local video_id="$1"

    validate_video_id "$video_id" || return 1
    validate_api_key || return 1

    local url="${YOUTUBE_API_BASE_URL}/videos?part=snippet,contentDetails&id=${video_id}&key=${YOUTUBE_API_KEY}"
    local response

    response=$(make_youtube_api_call "$url") || return 1

    # Check if video found
    local item_count
    item_count=$(echo "$response" | jq '.items | length')

    if [[ "$item_count" == "0" ]]; then
        echo "ERROR: Video not found: $video_id" >&2
        return 1
    fi

    echo "$response"
    return 0
}

# Sanitize title for filename
# Removes invalid characters, replaces spaces with underscores
sanitize_title() {
    local title="$1"
    local safe_title

    # Use Python for robust Unicode handling
    safe_title=$(python3 <<EOF
import re
import sys

title = """$title"""

# Remove invalid filename characters
safe_title = re.sub(r'[<>:"/\\|?*]', '', title)

# Remove punctuation
safe_title = re.sub(r"[',\.!;()\[\]{}]", '', safe_title)

# Replace spaces with underscores
safe_title = re.sub(r'\s+', '_', safe_title)

# Remove non-alphanumeric (except underscore and hyphen)
safe_title = re.sub(r'[^\w\-]', '', safe_title)

# Collapse multiple underscores
safe_title = re.sub(r'_+', '_', safe_title)

# Trim and limit length
safe_title = safe_title.strip('_')[:100]

print(safe_title)
EOF
)

    echo "$safe_title"
}

# Create transcript filename following naming convention
# Pattern: youtube-{sanitized_title}-{video_id}-{lang}.txt
create_transcript_filename() {
    local video_title="$1"
    local video_id="$2"
    local language="$3"

    local sanitized_title
    sanitized_title=$(sanitize_title "$video_title")

    echo "youtube-${sanitized_title}-${video_id}-${language}.txt"
}

# Format JSON response for success
format_success_response() {
    local operation="$1"
    shift
    local -n data=$1

    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    jq -n \
        --arg op "$operation" \
        --arg ts "$timestamp" \
        --argjson data "$(declare -p data | sed 's/^declare -A data=//')" \
        '{success: true, operation: $op, timestamp: $ts} + $data'
}

# Format JSON response for error
format_error_response() {
    local operation="$1"
    local error_message="$2"
    local error_type="${3:-unknown}"

    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    jq -n \
        --arg op "$operation" \
        --arg msg "$error_message" \
        --arg type "$error_type" \
        --arg ts "$timestamp" \
        '{success: false, operation: $op, error: {type: $type, message: $msg}, timestamp: $ts}'
}

# Log request to file
log_request() {
    local operation="$1"
    local status="$2"
    local details="${3:-}"

    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    local log_file="${YOUTUBE_LOG_DIR}/youtube-api.log"

    echo "${timestamp}|${operation}|${status}|${details}" >> "$log_file"
}

# Parse ISO 8601 duration to seconds
parse_duration() {
    local duration="$1"

    python3 <<EOF
import re

duration = "$duration"

# Parse ISO 8601 duration (e.g., PT1H23M45S)
pattern = r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?'
match = re.match(pattern, duration)

if match:
    hours = int(match.group(1) or 0)
    minutes = int(match.group(2) or 0)
    seconds = int(match.group(3) or 0)
    total_seconds = hours * 3600 + minutes * 60 + seconds
    print(total_seconds)
else:
    print(0)
EOF
}
