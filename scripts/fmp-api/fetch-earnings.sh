#!/usr/bin/env bash
# FMP Earnings & News Fetcher
# Fetch earnings transcripts, earnings data, and stock news

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

#############################################################################
# Earnings Transcripts
#############################################################################

fetch_earnings_transcript() {
    local symbol="$1"
    local year="$2"
    local quarter="$3"

    validate_symbol "$symbol" || return 1

    if [[ ! "$year" =~ ^[0-9]{4}$ ]]; then
        format_error "invalid_params" "Year must be 4 digits (e.g., 2024)"
        return 1
    fi

    if [[ ! "$quarter" =~ ^[1-4]$ ]]; then
        format_error "invalid_params" "Quarter must be 1-4"
        return 1
    fi

    local endpoint="/v3/earning_call_transcript/${symbol}"
    local params="year=${year}&quarter=${quarter}"
    local response=$(fmp_api_call "$endpoint" "$params")

    if [[ $? -ne 0 ]]; then
        echo "$response"
        return 1
    fi

    # Extract transcript
    local transcript=$(echo "$response" | jq -r '.[0].content // empty')

    if [[ -z "$transcript" ]]; then
        format_error "no_data" "No transcript for $symbol ${year} Q${quarter}"
        return 1
    fi

    # Save transcript as text file
    local filepath="$FMP_DATA_DIR/earnings/$(get_filename "$symbol" "transcript" "${year}-Q${quarter}" "txt")"
    save_text "$filepath" "$transcript"

    log_request "$symbol" "transcript" "success" "${year}-Q${quarter}"

    cat <<EOF
{
  "success": true,
  "symbol": "$symbol",
  "year": $year,
  "quarter": $quarter,
  "file": "$filepath",
  "size": ${#transcript},
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
}

#############################################################################
# Earnings Transcript Dates
#############################################################################

fetch_transcript_dates() {
    local symbol="$1"

    validate_symbol "$symbol" || return 1

    local endpoint="/v4/earning_call_transcript"
    local params="symbol=${symbol}"
    local response=$(fmp_api_call "$endpoint" "$params")

    if [[ $? -ne 0 ]]; then
        echo "$response"
        return 1
    fi

    local count=$(echo "$response" | jq 'length')
    if [[ $count -eq 0 ]]; then
        format_error "no_data" "No transcript dates for $symbol"
        return 1
    fi

    local filepath="$FMP_DATA_DIR/earnings/$(get_filename "$symbol" "transcript-dates")"
    save_json "$filepath" "$response"

    log_request "$symbol" "transcript-dates" "success" "$count dates"

    cat <<EOF
{
  "success": true,
  "symbol": "$symbol",
  "count": $count,
  "file": "$filepath",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
}

#############################################################################
# Earnings Data
#############################################################################

fetch_earnings() {
    local symbol="$1"
    local limit="${2:-20}"

    validate_symbol "$symbol" || return 1

    local endpoint="/v3/historical/earning_calendar/${symbol}"
    local params="limit=${limit}"
    local response=$(fmp_api_call "$endpoint" "$params")

    if [[ $? -ne 0 ]]; then
        echo "$response"
        return 1
    fi

    local count=$(echo "$response" | jq 'length')
    if [[ $count -eq 0 ]]; then
        format_error "no_data" "No earnings data for $symbol"
        return 1
    fi

    local filepath="$FMP_DATA_DIR/earnings/$(get_filename "$symbol" "earnings-history")"
    save_json "$filepath" "$response"

    log_request "$symbol" "earnings" "success" "$count records"

    cat <<EOF
{
  "success": true,
  "symbol": "$symbol",
  "count": $count,
  "file": "$filepath",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
}

#############################################################################
# Stock News
#############################################################################

fetch_news() {
    local symbol="$1"
    local limit="${2:-50}"

    validate_symbol "$symbol" || return 1

    local endpoint="/v3/stock_news"
    local params="tickers=${symbol}&limit=${limit}"
    local response=$(fmp_api_call "$endpoint" "$params")

    if [[ $? -ne 0 ]]; then
        echo "$response"
        return 1
    fi

    local count=$(echo "$response" | jq 'length')
    if [[ $count -eq 0 ]]; then
        format_error "no_data" "No news for $symbol"
        return 1
    fi

    # Save JSON
    local timestamp=$(date +"%Y%m%d")
    local json_file="$FMP_DATA_DIR/news/$(get_filename "$symbol" "news" "$timestamp")"
    save_json "$json_file" "$response"

    # Generate markdown
    local md_file="$FMP_DATA_DIR/news/$(get_filename "$symbol" "news" "$timestamp" "md")"
    {
        echo "# Stock News: $symbol"
        echo "Generated: $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
        echo "Articles: $count"
        echo ""
        echo "---"
        echo ""

        echo "$response" | jq -r '.[] |
            "## " + .title + "\n" +
            "**Date:** " + .publishedDate + "\n" +
            "**Source:** " + .site + "\n" +
            "**URL:** " + .url + "\n\n" +
            .text + "\n\n" +
            "---\n"'
    } > "$md_file"

    log_request "$symbol" "news" "success" "$count articles"

    cat <<EOF
{
  "success": true,
  "symbol": "$symbol",
  "count": $count,
  "files": {
    "json": "$json_file",
    "markdown": "$md_file"
  },
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
}

#############################################################################
# Press Releases
#############################################################################

fetch_press_releases() {
    local symbol="$1"
    local limit="${2:-50}"

    validate_symbol "$symbol" || return 1

    local endpoint="/v3/press-releases/${symbol}"
    local params="limit=${limit}"
    local response=$(fmp_api_call "$endpoint" "$params")

    if [[ $? -ne 0 ]]; then
        echo "$response"
        return 1
    fi

    local count=$(echo "$response" | jq 'length')
    if [[ $count -eq 0 ]]; then
        format_error "no_data" "No press releases for $symbol"
        return 1
    fi

    local timestamp=$(date +"%Y%m%d")
    local filepath="$FMP_DATA_DIR/news/$(get_filename "$symbol" "press-releases" "$timestamp")"
    save_json "$filepath" "$response"

    log_request "$symbol" "press-releases" "success" "$count releases"

    cat <<EOF
{
  "success": true,
  "symbol": "$symbol",
  "count": $count,
  "file": "$filepath",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
}

#############################################################################
# Main Entry Point
#############################################################################

main() {
    local action="${1:-}"
    shift || true

    case "$action" in
        transcript)
            fetch_earnings_transcript "$@"
            ;;
        transcript-dates)
            fetch_transcript_dates "$@"
            ;;
        earnings)
            fetch_earnings "$@"
            ;;
        news)
            fetch_news "$@"
            ;;
        press-releases)
            fetch_press_releases "$@"
            ;;
        *)
            cat <<EOF
Usage: fetch-earnings.sh <action> [options]

Actions:
  transcript <SYMBOL> <YEAR> <QUARTER>      Fetch earnings call transcript
  transcript-dates <SYMBOL>                 List available transcript dates
  earnings <SYMBOL> [LIMIT]                 Fetch earnings history
  news <SYMBOL> [LIMIT]                     Fetch stock news (default: 50)
  press-releases <SYMBOL> [LIMIT]           Fetch press releases (default: 50)

Examples:
  fetch-earnings.sh transcript AAPL 2024 3
  fetch-earnings.sh transcript-dates AAPL
  fetch-earnings.sh earnings TSLA 20
  fetch-earnings.sh news MSFT 100
  fetch-earnings.sh press-releases NVDA 25
EOF
            exit 1
            ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
