#!/usr/bin/env bash
# FMP API Examples
# Demonstration of common data fetching operations

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_section() {
    echo -e "\n${BLUE}═══════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════${NC}\n"
}

print_command() {
    echo -e "${YELLOW}$ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}\n"
}

#############################################################################
# Example 1: Fetch Company Profile
#############################################################################

example_company_profile() {
    print_section "Example 1: Fetch Company Profile"

    local symbol="AAPL"

    print_command "./fmp-fetch.sh company profile $symbol"
    local result=$("$SCRIPT_DIR/fmp-fetch.sh" company profile "$symbol")

    echo "$result" | jq '.'

    local company_name=$(echo "$result" | jq -r '.company_name // "Unknown"')
    local file=$(echo "$result" | jq -r '.file // "N/A"')

    print_success "Fetched profile for $company_name → $file"
}

#############################################################################
# Example 2: Fetch Financial Statements
#############################################################################

example_financial_statements() {
    print_section "Example 2: Fetch Financial Statements"

    local symbol="TSLA"

    print_command "./fmp-fetch.sh financials income $symbol annual 5"
    local result=$("$SCRIPT_DIR/fmp-fetch.sh" financials income "$symbol" annual 5)

    echo "$result" | jq '.'

    local count=$(echo "$result" | jq -r '.count // 0')

    print_success "Fetched $count income statements for $symbol"
}

#############################################################################
# Example 3: Fetch Real-Time Quote
#############################################################################

example_quote() {
    print_section "Example 3: Fetch Real-Time Quote"

    local symbol="NVDA"

    print_command "./fmp-fetch.sh quotes quote $symbol"
    local result=$("$SCRIPT_DIR/fmp-fetch.sh" quotes quote "$symbol")

    echo "$result" | jq '.'

    local price=$(echo "$result" | jq -r '.price // "N/A"')
    local change=$(echo "$result" | jq -r '.change // "N/A"')

    print_success "Current price: \$$price (change: $change)"
}

#############################################################################
# Example 4: Fetch Batch Quotes
#############################################################################

example_batch_quotes() {
    print_section "Example 4: Fetch Batch Quotes"

    local symbols="AAPL,MSFT,GOOG"

    print_command "./fmp-fetch.sh quotes batch $symbols"
    local result=$("$SCRIPT_DIR/fmp-fetch.sh" quotes batch "$symbols")

    echo "$result" | jq '.'

    local count=$(echo "$result" | jq -r '.count // 0')

    print_success "Fetched quotes for $count symbols"
}

#############################################################################
# Example 5: Fetch Stock News
#############################################################################

example_news() {
    print_section "Example 5: Fetch Stock News"

    local symbol="TSLA"
    local limit=10

    print_command "./fmp-fetch.sh earnings news $symbol $limit"
    local result=$("$SCRIPT_DIR/fmp-fetch.sh" earnings news "$symbol" "$limit")

    echo "$result" | jq '.'

    local count=$(echo "$result" | jq -r '.count // 0')
    local md_file=$(echo "$result" | jq -r '.files.markdown // "N/A"')

    print_success "Fetched $count news articles → $md_file"
}

#############################################################################
# Example 6: Fetch Analyst Data
#############################################################################

example_analyst() {
    print_section "Example 6: Fetch Analyst Price Targets"

    local symbol="AAPL"

    print_command "./fmp-fetch.sh analyst price-consensus $symbol"
    local result=$("$SCRIPT_DIR/fmp-fetch.sh" analyst price-consensus "$symbol")

    echo "$result" | jq '.'

    local median=$(echo "$result" | jq -r '.consensus.median // "N/A"')
    local high=$(echo "$result" | jq -r '.consensus.high // "N/A"')
    local low=$(echo "$result" | jq -r '.consensus.low // "N/A"')

    print_success "Price targets - Low: \$$low, Median: \$$median, High: \$$high"
}

#############################################################################
# Example 7: Bulk Fetch - Full Company Data
#############################################################################

example_bulk_company() {
    print_section "Example 7: Bulk Fetch - Full Company Data"

    local symbol="MSFT"

    print_command "./fmp-fetch.sh bulk full-company $symbol"
    echo "Fetching all company data for $symbol..."
    echo "(This will take a few seconds due to rate limiting)"
    echo ""

    local result=$("$SCRIPT_DIR/fmp-fetch.sh" bulk full-company "$symbol" 2>/dev/null || echo '{"success": false}')

    if [[ $(echo "$result" | jq -r '.success') == "true" ]]; then
        print_success "Successfully fetched all company data for $symbol"
    else
        echo "Note: Some endpoints may not have data available"
    fi
}

#############################################################################
# Example 8: Search Companies
#############################################################################

example_search() {
    print_section "Example 8: Search Companies"

    local query="Apple"
    local limit=5

    print_command "./fmp-fetch.sh company search '$query' $limit"
    local result=$("$SCRIPT_DIR/fmp-fetch.sh" company search "$query" "$limit")

    echo "$result" | jq '.'

    local count=$(echo "$result" | jq -r '.count // 0')

    print_success "Found $count companies matching '$query'"
}

#############################################################################
# Main
#############################################################################

main() {
    echo -e "${GREEN}"
    cat <<'EOF'
  _____ __  __ ____     _    ____ ___   _____                           _
 |  ___|  \/  |  _ \   / \  |  _ \_ _| | ____|_  ____ _ _ __ ___  _ __ | | ___  ___
 | |_  | |\/| | |_) | / _ \ | |_) | |  |  _| \ \/ / _` | '_ ` _ \| '_ \| |/ _ \/ __|
 |  _| | |  | |  __/ / ___ \|  __/| |  | |___ >  < (_| | | | | | | |_) | |  __/\__ \
 |_|   |_|  |_|_|   /_/   \_\_|  |___| |_____/_/\_\__,_|_| |_| |_| .__/|_|\___||___/
                                                                  |_|
EOF
    echo -e "${NC}"

    # Check if .env exists
    if [[ ! -f "$SCRIPT_DIR/.env" && ! -f "$(pwd)/.env" ]]; then
        echo -e "${YELLOW}WARNING: No .env file found!${NC}"
        echo "Please create .env with your FMP_API_KEY before running examples."
        echo "See .env.example for template"
        exit 1
    fi

    local example="${1:-all}"

    case "$example" in
        1|profile)
            example_company_profile
            ;;
        2|financials)
            example_financial_statements
            ;;
        3|quote)
            example_quote
            ;;
        4|batch)
            example_batch_quotes
            ;;
        5|news)
            example_news
            ;;
        6|analyst)
            example_analyst
            ;;
        7|bulk)
            example_bulk_company
            ;;
        8|search)
            example_search
            ;;
        all)
            example_company_profile
            sleep 1
            example_financial_statements
            sleep 1
            example_quote
            sleep 1
            example_batch_quotes
            sleep 1
            example_news
            sleep 1
            example_analyst
            sleep 1
            example_search

            echo -e "\n${GREEN}═══════════════════════════════════════════════════${NC}"
            echo -e "${GREEN}All examples completed successfully!${NC}"
            echo -e "${GREEN}═══════════════════════════════════════════════════${NC}\n"
            echo "Check the fmp-data/ directory for all fetched data"
            echo ""
            ;;
        *)
            echo "Usage: examples.sh [1-8|all]"
            echo ""
            echo "Examples:"
            echo "  1|profile      - Company profile"
            echo "  2|financials   - Financial statements"
            echo "  3|quote        - Real-time quote"
            echo "  4|batch        - Batch quotes"
            echo "  5|news         - Stock news"
            echo "  6|analyst      - Analyst data"
            echo "  7|bulk         - Bulk company data"
            echo "  8|search       - Company search"
            echo "  all            - Run all examples"
            exit 1
            ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
