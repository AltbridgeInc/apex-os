#!/usr/bin/env bash
# Fetch YouTube video transcript
#
# Downloads video transcripts using youtube-transcript-api with proxy support.
# Files saved as: youtube-{sanitized_title}-{video_id}-{lang}.txt
#
# Usage: ./fetch-transcript.sh VIDEO_ID [LANGUAGE] [OUTPUT_DIR]
#
# Examples:
#   ./fetch-transcript.sh abc123xyz
#   ./fetch-transcript.sh abc123xyz es
#   ./fetch-transcript.sh abc123xyz en transcripts/earnings/

set -euo pipefail

# Get script directory and load dependencies
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/utils.sh"

# Parse arguments
VIDEO_ID="${1:-}"
LANGUAGE="${2:-${YOUTUBE_DEFAULT_LANGUAGE}}"
OUTPUT_DIR="${3:-${YOUTUBE_DATA_DIR}/transcripts}"

# Show usage if no video ID
if [[ -z "$VIDEO_ID" ]]; then
    echo "Usage: $0 VIDEO_ID [LANGUAGE] [OUTPUT_DIR]" >&2
    echo "" >&2
    echo "Arguments:" >&2
    echo "  VIDEO_ID    YouTube video ID (required, 11 characters)" >&2
    echo "  LANGUAGE    Language code (optional, default: en)" >&2
    echo "  OUTPUT_DIR  Output directory (optional, default: data/youtube/transcripts/)" >&2
    echo "" >&2
    echo "Examples:" >&2
    echo "  $0 abc123xyz" >&2
    echo "  $0 abc123xyz es" >&2
    echo "  $0 abc123xyz en transcripts/earnings/" >&2
    echo "" >&2
    echo "Output filename: youtube-{title}-{video_id}-{lang}.txt" >&2
    exit 1
fi

# Check dependencies
check_dependencies || exit 1

# Validate inputs
validate_video_id "$VIDEO_ID" || exit 1
validate_api_key || exit 1

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Fetch video metadata first
echo "Fetching video metadata..." >&2
METADATA=$(fetch_video_metadata "$VIDEO_ID") || {
    log_request "transcript" "failed" "video_not_found:$VIDEO_ID"
    format_error_response "transcript" "Video not found: $VIDEO_ID" "not_found"
    exit 1
}

# Extract video information
VIDEO_TITLE=$(echo "$METADATA" | jq -r '.items[0].snippet.title')
VIDEO_DURATION=$(echo "$METADATA" | jq -r '.items[0].contentDetails.duration')
CHANNEL_TITLE=$(echo "$METADATA" | jq -r '.items[0].snippet.channelTitle')

# Sanitize title for filename
SANITIZED_TITLE=$(sanitize_title "$VIDEO_TITLE")

# Create filename
FILENAME=$(create_transcript_filename "$VIDEO_TITLE" "$VIDEO_ID" "$LANGUAGE")
FILE_PATH="$OUTPUT_DIR/$FILENAME"

echo "Video: $VIDEO_TITLE" >&2
echo "Channel: $CHANNEL_TITLE" >&2
echo "Language: $LANGUAGE" >&2
echo "Output: $FILE_PATH" >&2
echo "" >&2

# Download transcript using Python with youtube-transcript-api
echo "Downloading transcript..." >&2

# Export variables for Python script (including proxy credentials if set)
export VIDEO_ID LANGUAGE VIDEO_TITLE CHANNEL_TITLE VIDEO_DURATION FILE_PATH
[[ -n "${WEBSHARE_USERNAME:-}" ]] && export WEBSHARE_USERNAME
[[ -n "${WEBSHARE_PASSWORD:-}" ]] && export WEBSHARE_PASSWORD

TRANSCRIPT_RESULT=$(python3 <<'PYTHON_SCRIPT'
import os
import sys
import json
from datetime import datetime

# Get environment variables
video_id = os.environ.get('VIDEO_ID')
language = os.environ.get('LANGUAGE', 'en')
video_title = os.environ.get('VIDEO_TITLE')
channel_title = os.environ.get('CHANNEL_TITLE')
video_duration = os.environ.get('VIDEO_DURATION')
file_path = os.environ.get('FILE_PATH')
proxy_username = os.getenv('WEBSHARE_USERNAME')
proxy_password = os.getenv('WEBSHARE_PASSWORD')

# Check for youtube-transcript-api
try:
    from youtube_transcript_api import YouTubeTranscriptApi
    from youtube_transcript_api._errors import (
        NoTranscriptFound,
        TranscriptsDisabled,
        VideoUnavailable,
        CouldNotRetrieveTranscript
    )
except ImportError:
    print(json.dumps({
        'success': False,
        'error': 'youtube-transcript-api not installed',
        'hint': 'Install with: pip3 install youtube-transcript-api'
    }))
    sys.exit(1)

# Try to get transcript
try:
    # Configure proxy if credentials provided
    using_proxy = False
    if proxy_username and proxy_password:
        try:
            from youtube_transcript_api._errors import GenericProxyConfig

            proxy_url = f"http://{proxy_username}:{proxy_password}@p.webshare.io:80"
            proxy_config = GenericProxyConfig(
                http_url=proxy_url,
                https_url=proxy_url
            )
            api = YouTubeTranscriptApi(proxy_config=proxy_config)
            transcript_list = api.list(video_id)
            using_proxy = True
        except Exception as e:
            # Fallback to direct connection if proxy fails
            print(f"Warning: Proxy failed, using direct connection: {str(e)}", file=sys.stderr)
            api = YouTubeTranscriptApi()
            transcript_list = api.list(video_id)
    else:
        api = YouTubeTranscriptApi()
        transcript_list = api.list(video_id)

    # Try to find transcript in requested language
    languages_to_try = [language]
    if language != 'en':
        languages_to_try.append('en')

    transcript = None
    used_language = None

    try:
        transcript = transcript_list.find_transcript(languages_to_try)
        used_language = transcript.language_code
    except NoTranscriptFound:
        # Get any available transcript
        available_transcripts = list(transcript_list)
        if available_transcripts:
            transcript = available_transcripts[0]
            used_language = transcript.language_code
            print(f"Warning: Language '{language}' not available, using '{used_language}'", file=sys.stderr)
        else:
            print(json.dumps({
                'success': False,
                'error': 'No transcripts available for this video'
            }))
            sys.exit(1)

    # Fetch transcript data
    transcript_data = transcript.fetch()

    # Write transcript to file
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(f"Title: {video_title}\n")
        f.write(f"Video ID: {video_id}\n")
        f.write(f"URL: https://youtube.com/watch?v={video_id}\n")
        f.write(f"Channel: {channel_title}\n")
        f.write(f"Duration: {video_duration}\n")
        f.write(f"Language: {used_language} ({transcript.language})\n")
        f.write(f"Is Generated: {transcript.is_generated}\n")
        f.write(f"Is Translatable: {transcript.is_translatable}\n")
        f.write(f"Segments: {len(transcript_data)}\n")
        f.write(f"Retrieved: {datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ')}\n\n")

        f.write("=" * 80 + "\n")
        f.write("FULL TRANSCRIPT\n")
        f.write("=" * 80 + "\n\n")

        # Write clean continuous text
        full_text = " ".join(entry.text for entry in transcript_data)
        f.write(full_text)
        f.write("\n\n")

        f.write("=" * 80 + "\n")
        f.write("TIMESTAMPED TRANSCRIPT\n")
        f.write("=" * 80 + "\n\n")

        # Write timestamped version
        for entry in transcript_data:
            timestamp = entry.start
            text = entry.text
            minutes = int(timestamp // 60)
            seconds = int(timestamp % 60)
            f.write(f"[{minutes:02d}:{seconds:02d}] {text}\n")

    # Get file size
    file_size = os.path.getsize(file_path)
    file_size_kb = round(file_size / 1024, 2)

    # Output success JSON
    print(json.dumps({
        'success': True,
        'video_id': video_id,
        'video_title': video_title,
        'language': used_language,
        'language_name': transcript.language,
        'is_generated': transcript.is_generated,
        'segments': len(transcript_data),
        'file': file_path,
        'size_kb': file_size_kb,
        'using_proxy': using_proxy
    }))

except TranscriptsDisabled:
    print(json.dumps({
        'success': False,
        'error': 'Transcripts are disabled for this video'
    }))
    sys.exit(1)
except VideoUnavailable:
    print(json.dumps({
        'success': False,
        'error': 'Video is unavailable'
    }))
    sys.exit(1)
except CouldNotRetrieveTranscript:
    print(json.dumps({
        'success': False,
        'error': 'Could not retrieve transcript for this video'
    }))
    sys.exit(1)
except Exception as e:
    print(json.dumps({
        'success': False,
        'error': str(e)
    }))
    import traceback
    traceback.print_exc(file=sys.stderr)
    sys.exit(1)
PYTHON_SCRIPT
)

# Check Python script result
PYTHON_EXIT=$?
if [[ $PYTHON_EXIT -ne 0 ]]; then
    # Extract error from JSON
    ERROR_MSG=$(echo "$TRANSCRIPT_RESULT" | jq -r '.error // "Unknown error"')
    HINT=$(echo "$TRANSCRIPT_RESULT" | jq -r '.hint // ""')

    echo "ERROR: $ERROR_MSG" >&2
    if [[ -n "$HINT" ]]; then
        echo "$HINT" >&2
    fi

    log_request "transcript" "failed" "error:$VIDEO_ID:$ERROR_MSG"
    format_error_response "transcript" "$ERROR_MSG" "transcript_error"
    exit 1
fi

# Parse result from Python
SUCCESS=$(echo "$TRANSCRIPT_RESULT" | jq -r '.success')
if [[ "$SUCCESS" != "true" ]]; then
    ERROR_MSG=$(echo "$TRANSCRIPT_RESULT" | jq -r '.error')
    echo "ERROR: $ERROR_MSG" >&2

    log_request "transcript" "failed" "error:$VIDEO_ID:$ERROR_MSG"
    format_error_response "transcript" "$ERROR_MSG" "transcript_error"
    exit 1
fi

# Extract results
USED_LANGUAGE=$(echo "$TRANSCRIPT_RESULT" | jq -r '.language')
SEGMENTS=$(echo "$TRANSCRIPT_RESULT" | jq -r '.segments')
SIZE_KB=$(echo "$TRANSCRIPT_RESULT" | jq -r '.size_kb')
USING_PROXY=$(echo "$TRANSCRIPT_RESULT" | jq -r '.using_proxy')

# Log success
log_request "transcript" "success" "video:$VIDEO_ID:lang:$USED_LANGUAGE:segments:$SEGMENTS"

# Print success message
echo "" >&2
echo "✓ Downloaded transcript for: $VIDEO_TITLE" >&2
echo "✓ Language: $USED_LANGUAGE" >&2
echo "✓ Segments: $SEGMENTS" >&2
echo "✓ Size: ${SIZE_KB} KB" >&2
if [[ "$USING_PROXY" == "true" ]]; then
    echo "✓ Using proxy: Webshare" >&2
fi
echo "" >&2
echo "File saved: $FILE_PATH" >&2

# Output JSON response
jq -n \
    --arg vid "$VIDEO_ID" \
    --arg title "$VIDEO_TITLE" \
    --arg sanitized "$SANITIZED_TITLE" \
    --arg lang "$USED_LANGUAGE" \
    --argjson segments "$SEGMENTS" \
    --argjson size "$SIZE_KB" \
    --arg file "$FILE_PATH" \
    --arg proxy "$USING_PROXY" \
    --arg ts "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
    '{
        success: true,
        operation: "transcript",
        video_id: $vid,
        video_title: $title,
        sanitized_title: $sanitized,
        language: $lang,
        segments: $segments,
        size_kb: $size,
        file: $file,
        using_proxy: ($proxy == "true"),
        timestamp: $ts
    }'
