#!/usr/bin/env bash
# Get videos from a YouTube channel
#
# Usage: ./fetch-channel.sh CHANNEL_ID [MAX_RESULTS]
#
# Examples:
#   ./fetch-channel.sh UC_x5XG1OV2P6uZZ5FSM9Ttw
#   ./fetch-channel.sh UC_x5XG1OV2P6uZZ5FSM9Ttw 50

set -euo pipefail

# Get script directory and load dependencies
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/utils.sh"

# Parse arguments
CHANNEL_ID="${1:-}"
MAX_RESULTS="${2:-${YOUTUBE_DEFAULT_MAX_RESULTS}}"

# Show usage if no channel ID
if [[ -z "$CHANNEL_ID" ]]; then
    echo "Usage: $0 CHANNEL_ID [MAX_RESULTS]" >&2
    echo "" >&2
    echo "Arguments:" >&2
    echo "  CHANNEL_ID   YouTube channel ID (required, starts with UC)" >&2
    echo "  MAX_RESULTS  Max results to return (optional, default: 10, max: 50)" >&2
    echo "" >&2
    echo "Examples:" >&2
    echo "  $0 UC_x5XG1OV2P6uZZ5FSM9Ttw" >&2
    echo "  $0 UC_x5XG1OV2P6uZZ5FSM9Ttw 50" >&2
    exit 1
fi

# Validate inputs
validate_channel_id "$CHANNEL_ID" || exit 1

if [[ ! "$MAX_RESULTS" =~ ^[0-9]+$ ]] || [[ "$MAX_RESULTS" -lt 1 ]] || [[ "$MAX_RESULTS" -gt 50 ]]; then
    echo "ERROR: MAX_RESULTS must be between 1 and 50" >&2
    exit 1
fi

# Check dependencies
check_dependencies || exit 1
validate_api_key || exit 1

# Get channel info first
echo "Fetching channel information..." >&2
CHANNEL_URL="${YOUTUBE_API_BASE_URL}/channels?part=snippet,statistics&id=${CHANNEL_ID}&key=${YOUTUBE_API_KEY}"
CHANNEL_RESPONSE=$(make_youtube_api_call "$CHANNEL_URL") || {
    log_request "channel" "failed" "channel:$CHANNEL_ID"
    format_error_response "channel" "Failed to fetch channel info" "api_error"
    exit 1
}

# Check if channel found
CHANNEL_COUNT=$(echo "$CHANNEL_RESPONSE" | jq '.items | length')
if [[ "$CHANNEL_COUNT" == "0" ]]; then
    echo "ERROR: Channel not found: $CHANNEL_ID" >&2
    log_request "channel" "failed" "channel_not_found:$CHANNEL_ID"
    format_error_response "channel" "Channel not found: $CHANNEL_ID" "not_found"
    exit 1
fi

# Extract channel info
CHANNEL_NAME=$(echo "$CHANNEL_RESPONSE" | jq -r '.items[0].snippet.title')
SUBSCRIBER_COUNT=$(echo "$CHANNEL_RESPONSE" | jq -r '.items[0].statistics.subscriberCount // "N/A"')
VIDEO_COUNT=$(echo "$CHANNEL_RESPONSE" | jq -r '.items[0].statistics.videoCount // "N/A"')

echo "Channel: $CHANNEL_NAME" >&2
echo "Subscribers: $SUBSCRIBER_COUNT" >&2
echo "Total videos: $VIDEO_COUNT" >&2
echo "" >&2

# Search for channel videos
echo "Fetching channel videos..." >&2
SEARCH_URL="${YOUTUBE_API_BASE_URL}/search?part=snippet&channelId=${CHANNEL_ID}&maxResults=${MAX_RESULTS}&order=date&type=video&key=${YOUTUBE_API_KEY}"
SEARCH_RESPONSE=$(make_youtube_api_call "$SEARCH_URL") || {
    log_request "channel" "failed" "search_failed:$CHANNEL_ID"
    format_error_response "channel" "Failed to fetch channel videos" "api_error"
    exit 1
}

# Parse results
RESULTS_COUNT=$(echo "$SEARCH_RESPONSE" | jq '.items | length')

if [[ "$RESULTS_COUNT" == "0" ]]; then
    echo "No videos found for channel: $CHANNEL_NAME" >&2
    log_request "channel" "success" "channel:$CHANNEL_ID:count:0"

    jq -n \
        --arg cid "$CHANNEL_ID" \
        --arg cname "$CHANNEL_NAME" \
        --arg ts "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
        '{
            success: true,
            operation: "channel",
            channel_id: $cid,
            channel_name: $cname,
            results_count: 0,
            videos: [],
            timestamp: $ts
        }'
    exit 0
fi

echo "✓ Found $RESULTS_COUNT videos" >&2
echo "" >&2

# Display results
echo "$SEARCH_RESPONSE" | jq -r '.items[] |
    "Video: " + .snippet.title + "\n" +
    "Video ID: " + .id.videoId + "\n" +
    "URL: https://youtube.com/watch?v=" + .id.videoId + "\n" +
    "Published: " + .snippet.publishedAt + "\n"
' >&2

# Log success
log_request "channel" "success" "channel:$CHANNEL_ID:count:$RESULTS_COUNT"

# Output JSON
jq -n \
    --arg cid "$CHANNEL_ID" \
    --arg cname "$CHANNEL_NAME" \
    --arg subs "$SUBSCRIBER_COUNT" \
    --arg vcount "$VIDEO_COUNT" \
    --argjson rcount "$RESULTS_COUNT" \
    --argjson videos "$(echo "$SEARCH_RESPONSE" | jq '[.items[] | {
        video_id: .id.videoId,
        title: .snippet.title,
        published: .snippet.publishedAt,
        url: ("https://youtube.com/watch?v=" + .id.videoId),
        thumbnail: .snippet.thumbnails.default.url,
        description: .snippet.description
    }]')" \
    --arg ts "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
    '{
        success: true,
        operation: "channel",
        channel_id: $cid,
        channel_name: $cname,
        subscriber_count: $subs,
        video_count: $vcount,
        results_count: $rcount,
        videos: $videos,
        timestamp: $ts
    }'
