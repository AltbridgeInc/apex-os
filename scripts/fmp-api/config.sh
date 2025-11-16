#!/usr/bin/env bash
# FMP API Configuration
# Single source of truth for FMP API settings

set -euo pipefail

# API Configuration
export FMP_API_BASE_URL="${FMP_API_BASE_URL:-https://financialmodelingprep.com/api}"
export FMP_API_VERSION="${FMP_API_VERSION:-v3}"

# Rate Limiting (requests per minute)
export FMP_RATE_LIMIT="${FMP_RATE_LIMIT:-250}"

# Request Timeouts (seconds)
export FMP_TIMEOUT="${FMP_TIMEOUT:-30}"
export FMP_MAX_RETRIES="${FMP_MAX_RETRIES:-3}"

# Data Storage
# Default to apex-os/data/fmp if it exists, otherwise use local ./fmp-data
if [[ -d "../../data/fmp" ]]; then
    # We're in apex-os/scripts/fmp-api, use parent data directory
    export FMP_DATA_DIR="${FMP_DATA_DIR:-../../data/fmp}"
    export FMP_LOG_DIR="${FMP_LOG_DIR:-../../logs}"
elif [[ -d "../data/fmp" ]]; then
    # Alternative path structure
    export FMP_DATA_DIR="${FMP_DATA_DIR:-../data/fmp}"
    export FMP_LOG_DIR="${FMP_LOG_DIR:-../logs}"
else
    # Fallback to local directory (for standalone testing)
    export FMP_DATA_DIR="${FMP_DATA_DIR:-./fmp-data}"
    export FMP_LOG_DIR="${FMP_LOG_DIR:-./fmp-logs}"
fi

# Default Limits
export FMP_DEFAULT_LIMIT="${FMP_DEFAULT_LIMIT:-10}"
export FMP_DEFAULT_PERIOD="${FMP_DEFAULT_PERIOD:-annual}"

# Create directories if they don't exist
mkdir -p "$FMP_DATA_DIR"/{company,financials,quotes,earnings,news,analyst,historical,market-movers,technical}
mkdir -p "$FMP_LOG_DIR"

# Load API key from .env file
load_api_key() {
    local env_file=""

    # Try multiple locations in order of preference
    local search_paths=(
        "../../.env"           # apex-os/.env (from scripts/fmp-api/)
        "../.env"              # apex-os/.env (alternative structure)
        ".env"                 # Current directory
        "${HOME}/.env"         # Home directory
        "${PROJECT_DIR:-.}/.env"  # Project directory if set
    )

    for path in "${search_paths[@]}"; do
        if [[ -f "$path" ]]; then
            env_file="$path"
            break
        fi
    done

    if [[ -z "$env_file" ]]; then
        echo "ERROR: .env file not found. Searched: ${search_paths[*]}" >&2
        echo "Please create apex-os/.env with FMP_API_KEY=your_key" >&2
        return 1
    fi

    # Source .env file
    set +u
    source "$env_file"
    set -u

    if [[ -z "${FMP_API_KEY:-}" ]]; then
        echo "ERROR: FMP_API_KEY not set in $env_file" >&2
        return 1
    fi

    export FMP_API_KEY
    return 0
}
