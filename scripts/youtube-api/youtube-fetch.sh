#!/usr/bin/env bash
# YouTube Fetch - Master Orchestrator
# Single entry point for all YouTube data operations
#
# Usage: ./youtube-fetch.sh <command> [args...]
#
# Commands:
#   search QUERY [MAX_RESULTS]                - Search for videos
#   transcript VIDEO_ID [LANG] [OUTPUT_DIR]   - Download transcript
#   channel CHANNEL_ID [MAX_RESULTS]          - Get channel videos
#   playlist PLAYLIST_ID [MAX_RESULTS]        - Get playlist videos
#   help                                      - Show this help

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Show help
show_help() {
    cat << 'EOF'
YouTube Fetch - Master Orchestrator

USAGE:
    youtube-fetch.sh <command> [args...]

COMMANDS:
    search QUERY [MAX_RESULTS]
        Search YouTube for videos

        Arguments:
            QUERY        Search query (required)
            MAX_RESULTS  Max results (optional, default: 10, max: 50)

        Examples:
            youtube-fetch.sh search "NVIDIA earnings call" 10
            youtube-fetch.sh search "Warren Buffett interview" 25

    transcript VIDEO_ID [LANG] [OUTPUT_DIR]
        Download video transcript

        Arguments:
            VIDEO_ID     YouTube video ID (required, 11 chars)
            LANG         Language code (optional, default: en)
            OUTPUT_DIR   Output directory (optional, default: data/youtube/transcripts/)

        Examples:
            youtube-fetch.sh transcript abc123xyz
            youtube-fetch.sh transcript abc123xyz es
            youtube-fetch.sh transcript abc123xyz en transcripts/earnings/

        Output filename: youtube-{title}-{video_id}-{lang}.txt

    channel CHANNEL_ID [MAX_RESULTS]
        Get videos from a YouTube channel

        Arguments:
            CHANNEL_ID   YouTube channel ID (required, starts with UC)
            MAX_RESULTS  Max results (optional, default: 10, max: 50)

        Examples:
            youtube-fetch.sh channel UC_x5XG1OV2P6uZZ5FSM9Ttw
            youtube-fetch.sh channel UC_x5XG1OV2P6uZZ5FSM9Ttw 50

    playlist PLAYLIST_ID [MAX_RESULTS]
        Get videos from a YouTube playlist

        Arguments:
            PLAYLIST_ID  YouTube playlist ID (required, starts with PL)
            MAX_RESULTS  Max results (optional, default: 10, max: 50)

        Examples:
            youtube-fetch.sh playlist PLrAXtmErZgOeiKm4sgNOknGvNjby9efdf
            youtube-fetch.sh playlist PLrAXtmErZgOeiKm4sgNOknGvNjby9efdf 50

    help
        Show this help message

ENVIRONMENT:
    YOUTUBE_API_KEY       Required: Your YouTube Data API v3 key
    WEBSHARE_USERNAME     Optional: Webshare proxy username (for transcripts in cloud)
    WEBSHARE_PASSWORD     Optional: Webshare proxy password (for transcripts in cloud)

SETUP:
    1. Get YouTube API key: https://console.cloud.google.com/apis/credentials
    2. Add to apex-os/.env file:
       YOUTUBE_API_KEY=your_key_here
    3. (Optional) Add Webshare credentials for cloud/Docker environments

OUTPUT:
    All commands return JSON responses with success status and data
    Transcripts saved to files with human-readable names

For more information, see README.md
EOF
}

# Parse command
COMMAND="${1:-}"
shift || true

case "$COMMAND" in
    search)
        exec "$SCRIPT_DIR/fetch-search.sh" "$@"
        ;;
    transcript)
        exec "$SCRIPT_DIR/fetch-transcript.sh" "$@"
        ;;
    channel)
        exec "$SCRIPT_DIR/fetch-channel.sh" "$@"
        ;;
    playlist)
        exec "$SCRIPT_DIR/fetch-playlist.sh" "$@"
        ;;
    help|--help|-h)
        show_help
        exit 0
        ;;
    "")
        echo "ERROR: No command specified" >&2
        echo "" >&2
        show_help
        exit 1
        ;;
    *)
        echo "ERROR: Unknown command: $COMMAND" >&2
        echo "" >&2
        show_help
        exit 1
        ;;
esac
