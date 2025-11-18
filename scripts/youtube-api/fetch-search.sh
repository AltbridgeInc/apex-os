#!/usr/bin/env bash
# Search YouTube for videos
#
# Usage: ./fetch-search.sh QUERY [MAX_RESULTS]
#
# Examples:
#   ./fetch-search.sh "NVIDIA earnings call" 10
#   ./fetch-search.sh "Warren Buffett interview" 25

set -euo pipefail

# Get script directory and load dependencies
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/utils.sh"

# Parse arguments
QUERY="${1:-}"
MAX_RESULTS="${2:-${YOUTUBE_DEFAULT_MAX_RESULTS}}"

# Show usage if no query
if [[ -z "$QUERY" ]]; then
    echo "Usage: $0 QUERY [MAX_RESULTS]" >&2
    echo "" >&2
    echo "Arguments:" >&2
    echo "  QUERY        Search query (required)" >&2
    echo "  MAX_RESULTS  Max results to return (optional, default: 10, max: 50)" >&2
    echo "" >&2
    echo "Examples:" >&2
    echo "  $0 \"NVIDIA earnings call\" 10" >&2
    echo "  $0 \"Warren Buffett interview\" 25" >&2
    echo "  $0 \"semiconductor trends 2024\" 5" >&2
    exit 1
fi

# Validate max results
if [[ ! "$MAX_RESULTS" =~ ^[0-9]+$ ]] || [[ "$MAX_RESULTS" -lt 1 ]] || [[ "$MAX_RESULTS" -gt 50 ]]; then
    echo "ERROR: MAX_RESULTS must be between 1 and 50" >&2
    exit 1
fi

# Check dependencies
check_dependencies || exit 1
validate_api_key || exit 1

# URL encode query
ENCODED_QUERY=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$QUERY'''))")

# Build API URL
URL="${YOUTUBE_API_BASE_URL}/search?part=snippet&q=${ENCODED_QUERY}&maxResults=${MAX_RESULTS}&type=video&key=${YOUTUBE_API_KEY}"

# Make API call
echo "Searching YouTube for: \"$QUERY\"..." >&2
RESPONSE=$(make_youtube_api_call "$URL") || {
    log_request "search" "failed" "query:$QUERY"
    format_error_response "search" "API call failed" "api_error"
    exit 1
}

# Parse response
RESULTS_COUNT=$(echo "$RESPONSE" | jq '.items | length')

if [[ "$RESULTS_COUNT" == "0" ]]; then
    echo "No videos found for query: \"$QUERY\"" >&2
    log_request "search" "success" "query:$QUERY:count:0"

    # Output JSON
    jq -n \
        --arg query "$QUERY" \
        --arg ts "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
        '{
            success: true,
            operation: "search",
            query: $query,
            results_count: 0,
            videos: [],
            timestamp: $ts
        }'
    exit 0
fi

echo "✓ Found $RESULTS_COUNT videos" >&2
echo "" >&2

# Display results
echo "$RESPONSE" | jq -r '.items[] |
    "Video: " + .snippet.title + "\n" +
    "Channel: " + .snippet.channelTitle + "\n" +
    "Video ID: " + .id.videoId + "\n" +
    "URL: https://youtube.com/watch?v=" + .id.videoId + "\n" +
    "Published: " + .snippet.publishedAt + "\n"
' >&2

# Log success
log_request "search" "success" "query:$QUERY:count:$RESULTS_COUNT"

# Output JSON
jq -n \
    --arg query "$QUERY" \
    --argjson count "$RESULTS_COUNT" \
    --argjson videos "$(echo "$RESPONSE" | jq '[.items[] | {
        video_id: .id.videoId,
        title: .snippet.title,
        channel: .snippet.channelTitle,
        channel_id: .snippet.channelId,
        published: .snippet.publishedAt,
        url: ("https://youtube.com/watch?v=" + .id.videoId),
        thumbnail: .snippet.thumbnails.default.url,
        description: .snippet.description
    }]')" \
    --arg ts "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
    '{
        success: true,
        operation: "search",
        query: $query,
        results_count: $count,
        videos: $videos,
        timestamp: $ts
    }'
