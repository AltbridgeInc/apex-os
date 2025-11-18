#!/usr/bin/env bash
# YouTube API Configuration
# Single source of truth for YouTube API settings

set -euo pipefail

# Get script directory for relative path resolution
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load environment variables from .env file early
# Try multiple locations in order of preference (relative to script location)
for env_path in \
    "$SCRIPT_DIR/../../.env" \
    "$SCRIPT_DIR/../.env" \
    "$SCRIPT_DIR/.env" \
    "apex-os/.env" \
    ".env" \
    "${HOME}/.env" \
    "${PROJECT_DIR:-.}/.env"; do
    if [[ -f "$env_path" ]]; then
        set +u
        source "$env_path"
        set -u
        break
    fi
done

# API Configuration
export YOUTUBE_API_BASE_URL="${YOUTUBE_API_BASE_URL:-https://www.googleapis.com/youtube/v3}"

# Request Timeouts (seconds)
export YOUTUBE_TIMEOUT="${YOUTUBE_TIMEOUT:-30}"
export YOUTUBE_MAX_RETRIES="${YOUTUBE_MAX_RETRIES:-3}"

# Data Storage
# Use YOUTUBE_DATA_DIR from .env if set, otherwise auto-detect
if [[ -n "${YOUTUBE_DATA_DIR:-}" ]]; then
    # Use directory from .env (apex-os/.env sets this to apex-os/data/youtube)
    export YOUTUBE_DATA_DIR="${YOUTUBE_DATA_DIR}"
    # Extract parent for logs (apex-os/data -> apex-os/logs)
    _data_parent=$(dirname "$(dirname "$YOUTUBE_DATA_DIR")")
    export YOUTUBE_LOG_DIR="${YOUTUBE_LOG_DIR:-${_data_parent}/logs}"
elif [[ -d "../../data/youtube" ]]; then
    # We're in apex-os/scripts/youtube-api, use parent data directory
    export YOUTUBE_DATA_DIR="${YOUTUBE_DATA_DIR:-../../data/youtube}"
    export YOUTUBE_LOG_DIR="${YOUTUBE_LOG_DIR:-../../logs}"
elif [[ -d "../data/youtube" ]]; then
    # Alternative path structure
    export YOUTUBE_DATA_DIR="${YOUTUBE_DATA_DIR:-../data/youtube}"
    export YOUTUBE_LOG_DIR="${YOUTUBE_LOG_DIR:-../logs}"
else
    # Fallback to local directory (for standalone testing)
    export YOUTUBE_DATA_DIR="${YOUTUBE_DATA_DIR:-./youtube-data}"
    export YOUTUBE_LOG_DIR="${YOUTUBE_LOG_DIR:-./youtube-logs}"
fi

# Default Settings
export YOUTUBE_DEFAULT_MAX_RESULTS="${YOUTUBE_DEFAULT_MAX_RESULTS:-10}"
export YOUTUBE_DEFAULT_LANGUAGE="${YOUTUBE_DEFAULT_LANGUAGE:-en}"

# Create directories if they don't exist
mkdir -p "$YOUTUBE_DATA_DIR"/{transcripts,search,metadata}
mkdir -p "$YOUTUBE_LOG_DIR"

# Load API key from .env file
load_api_key() {
    # Skip if already loaded
    if [[ -n "${YOUTUBE_API_KEY:-}" ]]; then
        return 0
    fi

    local env_file=""

    # Try multiple locations in order of preference (relative to script location)
    local search_paths=(
        "$SCRIPT_DIR/../../.env"   # apex-os/.env (from scripts/youtube-api/)
        "$SCRIPT_DIR/../.env"      # apex-os/.env (alternative structure)
        "$SCRIPT_DIR/.env"         # Current directory
        "apex-os/.env"             # From workspace root
        ".env"                     # Current working directory
        "${HOME}/.env"             # Home directory
        "${PROJECT_DIR:-.}/.env"   # Project directory if set
    )

    for path in "${search_paths[@]}"; do
        if [[ -f "$path" ]]; then
            env_file="$path"
            break
        fi
    done

    if [[ -z "$env_file" ]]; then
        echo "ERROR: .env file not found. Searched: ${search_paths[*]}" >&2
        echo "Please create apex-os/.env with YOUTUBE_API_KEY=your_key" >&2
        return 1
    fi

    # Source .env file
    set +u
    source "$env_file"
    set -u

    if [[ -z "${YOUTUBE_API_KEY:-}" ]]; then
        echo "ERROR: YOUTUBE_API_KEY not set in $env_file" >&2
        return 1
    fi

    export YOUTUBE_API_KEY
    return 0
}
