#!/usr/bin/env bash
# Get videos from a YouTube playlist
#
# Usage: ./fetch-playlist.sh PLAYLIST_ID [MAX_RESULTS]
#
# Examples:
#   ./fetch-playlist.sh PLrAXtmErZgOeiKm4sgNOknGvNjby9efdf
#   ./fetch-playlist.sh PLrAXtmErZgOeiKm4sgNOknGvNjby9efdf 50

set -euo pipefail

# Get script directory and load dependencies
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/utils.sh"

# Parse arguments
PLAYLIST_ID="${1:-}"
MAX_RESULTS="${2:-${YOUTUBE_DEFAULT_MAX_RESULTS}}"

# Show usage if no playlist ID
if [[ -z "$PLAYLIST_ID" ]]; then
    echo "Usage: $0 PLAYLIST_ID [MAX_RESULTS]" >&2
    echo "" >&2
    echo "Arguments:" >&2
    echo "  PLAYLIST_ID  YouTube playlist ID (required, starts with PL)" >&2
    echo "  MAX_RESULTS  Max results to return (optional, default: 10, max: 50)" >&2
    echo "" >&2
    echo "Examples:" >&2
    echo "  $0 PLrAXtmErZgOeiKm4sgNOknGvNjby9efdf" >&2
    echo "  $0 PLrAXtmErZgOeiKm4sgNOknGvNjby9efdf 50" >&2
    exit 1
fi

# Validate inputs
validate_playlist_id "$PLAYLIST_ID" || exit 1

if [[ ! "$MAX_RESULTS" =~ ^[0-9]+$ ]] || [[ "$MAX_RESULTS" -lt 1 ]] || [[ "$MAX_RESULTS" -gt 50 ]]; then
    echo "ERROR: MAX_RESULTS must be between 1 and 50" >&2
    exit 1
fi

# Check dependencies
check_dependencies || exit 1
validate_api_key || exit 1

# Get playlist info first
echo "Fetching playlist information..." >&2
PLAYLIST_URL="${YOUTUBE_API_BASE_URL}/playlists?part=snippet&id=${PLAYLIST_ID}&key=${YOUTUBE_API_KEY}"
PLAYLIST_RESPONSE=$(make_youtube_api_call "$PLAYLIST_URL") || {
    log_request "playlist" "failed" "playlist:$PLAYLIST_ID"
    format_error_response "playlist" "Failed to fetch playlist info" "api_error"
    exit 1
}

# Check if playlist found
PLAYLIST_COUNT=$(echo "$PLAYLIST_RESPONSE" | jq '.items | length')
if [[ "$PLAYLIST_COUNT" == "0" ]]; then
    echo "ERROR: Playlist not found: $PLAYLIST_ID" >&2
    log_request "playlist" "failed" "playlist_not_found:$PLAYLIST_ID"
    format_error_response "playlist" "Playlist not found: $PLAYLIST_ID" "not_found"
    exit 1
fi

# Extract playlist info
PLAYLIST_NAME=$(echo "$PLAYLIST_RESPONSE" | jq -r '.items[0].snippet.title')
CHANNEL_NAME=$(echo "$PLAYLIST_RESPONSE" | jq -r '.items[0].snippet.channelTitle')

echo "Playlist: $PLAYLIST_NAME" >&2
echo "Channel: $CHANNEL_NAME" >&2
echo "" >&2

# Get playlist items
echo "Fetching playlist videos..." >&2
ITEMS_URL="${YOUTUBE_API_BASE_URL}/playlistItems?part=snippet&playlistId=${PLAYLIST_ID}&maxResults=${MAX_RESULTS}&key=${YOUTUBE_API_KEY}"
ITEMS_RESPONSE=$(make_youtube_api_call "$ITEMS_URL") || {
    log_request "playlist" "failed" "items_failed:$PLAYLIST_ID"
    format_error_response "playlist" "Failed to fetch playlist items" "api_error"
    exit 1
}

# Parse results
RESULTS_COUNT=$(echo "$ITEMS_RESPONSE" | jq '.items | length')

if [[ "$RESULTS_COUNT" == "0" ]]; then
    echo "No videos found in playlist: $PLAYLIST_NAME" >&2
    log_request "playlist" "success" "playlist:$PLAYLIST_ID:count:0"

    jq -n \
        --arg pid "$PLAYLIST_ID" \
        --arg pname "$PLAYLIST_NAME" \
        --arg cname "$CHANNEL_NAME" \
        --arg ts "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
        '{
            success: true,
            operation: "playlist",
            playlist_id: $pid,
            playlist_name: $pname,
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
echo "$ITEMS_RESPONSE" | jq -r '.items[] |
    "Video: " + .snippet.title + "\n" +
    "Video ID: " + .snippet.resourceId.videoId + "\n" +
    "URL: https://youtube.com/watch?v=" + .snippet.resourceId.videoId + "\n" +
    "Position: " + (.snippet.position | tostring) + "\n" +
    "Published: " + .snippet.publishedAt + "\n"
' >&2

# Log success
log_request "playlist" "success" "playlist:$PLAYLIST_ID:count:$RESULTS_COUNT"

# Output JSON
jq -n \
    --arg pid "$PLAYLIST_ID" \
    --arg pname "$PLAYLIST_NAME" \
    --arg cname "$CHANNEL_NAME" \
    --argjson rcount "$RESULTS_COUNT" \
    --argjson videos "$(echo "$ITEMS_RESPONSE" | jq '[.items[] | {
        video_id: .snippet.resourceId.videoId,
        title: .snippet.title,
        position: .snippet.position,
        published: .snippet.publishedAt,
        url: ("https://youtube.com/watch?v=" + .snippet.resourceId.videoId),
        thumbnail: .snippet.thumbnails.default.url,
        description: .snippet.description
    }]')" \
    --arg ts "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
    '{
        success: true,
        operation: "playlist",
        playlist_id: $pid,
        playlist_name: $pname,
        channel_name: $cname,
        results_count: $rcount,
        videos: $videos,
        timestamp: $ts
    }'
