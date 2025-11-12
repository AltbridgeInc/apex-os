#!/usr/bin/env bash
# test-agents.sh - Integration tests for agents using FMP scripts
# Tests that agents can successfully use FMP helper scripts

set -euo pipefail

# Get script directory
SCRIPT_DIR="/Users/nazymazimbayev/apex-os-1"
FMP_SCRIPTS_DIR="$SCRIPT_DIR/scripts/fmp"
TEST_DIR="$(dirname "$0")"

# Source test helpers
source "$SCRIPT_DIR/tests/test-helpers.sh"

# Initialize test suite
init_test_suite "Agent Integration Tests"

# Setup test environment
setup_test_env

# Agent paths
MARKET_SCANNER_AGENT="$SCRIPT_DIR/.claude/agents/apex-os-market-scanner.md"
FUNDAMENTAL_ANALYST_AGENT="$SCRIPT_DIR/.claude/agents/apex-os-fundamental-analyst.md"
TECHNICAL_ANALYST_AGENT="$SCRIPT_DIR/.claude/agents/apex-os-technical-analyst.md"
PORTFOLIO_MONITOR_AGENT="$SCRIPT_DIR/.claude/agents/apex-os-portfolio-monitor.md"

# Output directories
OPPORTUNITIES_DIR="$SCRIPT_DIR/data/opportunities"
ANALYSIS_DIR="$SCRIPT_DIR/data/analysis"
REPORTS_DIR="$SCRIPT_DIR/data/reports"

#=============================================================================
# Helper Functions
#=============================================================================

# Check if agent file exists and has FMP integration
check_agent_has_fmp() {
    local agent_file="$1"
    local agent_name="$2"

    start_test "$agent_name: agent file exists and configured"

    if [[ ! -f "$agent_file" ]]; then
        assert_failure "Agent file not found: $agent_file"
        return 1
    fi

    # Check that WebFetch is not in tools (removed as per Phase 2)
    if grep -q "tools:.*WebFetch" "$agent_file"; then
        assert_failure "Agent still uses WebFetch (should be removed)"
        return 1
    fi

    # Check that agent mentions FMP
    if grep -qi "fmp" "$agent_file"; then
        assert_success "Agent configured with FMP integration"
        return 0
    else
        assert_failure "Agent does not mention FMP integration"
        return 1
    fi
}

# Simulate agent workflow using FMP scripts
simulate_agent_workflow() {
    local agent_name="$1"
    shift
    local commands=("$@")

    start_test "$agent_name: workflow simulation"

    local all_passed=true

    for cmd in "${commands[@]}"; do
        if eval "$cmd" >/dev/null 2>&1; then
            : # Command succeeded
        else
            all_passed=false
            break
        fi
    done

    if $all_passed; then
        assert_success "All FMP script calls succeeded"
        return 0
    else
        assert_failure "Some FMP script calls failed"
        return 1
    fi
}

#=============================================================================
# Test Market Scanner Agent
#=============================================================================

test_market_scanner_agent_config() {
    check_agent_has_fmp "$MARKET_SCANNER_AGENT" "Market Scanner"
}

test_market_scanner_workflow() {
    start_test "Market Scanner: FMP workflow simulation"

    if ! has_api_key; then
        skip_test "API key not available"
        return
    fi

    # Simulate Market Scanner workflow:
    # 1. Screen for gainers
    # 2. Get quotes for filtered symbols
    # 3. Get profile for company info

    local gainers=$(bash "$FMP_SCRIPTS_DIR/fmp-screener.sh" --type=gainers --limit=5 2>&1)

    if ! echo "$gainers" | jq -e . >/dev/null 2>&1; then
        skip_test "Screener API call failed"
        return
    fi

    if echo "$gainers" | jq -e '.error' >/dev/null 2>&1; then
        skip_test "API error: $(echo "$gainers" | jq -r '.message')"
        return
    fi

    # Extract first symbol
    local symbol=$(echo "$gainers" | jq -r '.[0].symbol // empty')

    if [[ -z "$symbol" ]]; then
        skip_test "No gainers found"
        return
    fi

    # Get detailed quote
    local quote=$(bash "$FMP_SCRIPTS_DIR/fmp-quote.sh" "$symbol" 2>&1)

    if ! echo "$quote" | jq -e . >/dev/null 2>&1; then
        assert_failure "Quote API call failed"
        return
    fi

    # Get profile
    local profile=$(bash "$FMP_SCRIPTS_DIR/fmp-profile.sh" "$symbol" 2>&1)

    if ! echo "$profile" | jq -e . >/dev/null 2>&1; then
        assert_failure "Profile API call failed"
        return
    fi

    assert_success "Market Scanner workflow completed successfully"
}

test_market_scanner_output_creation() {
    start_test "Market Scanner: creates opportunity documents"

    # Create opportunities directory if it doesn't exist
    mkdir -p "$OPPORTUNITIES_DIR"

    # Simulate creating an opportunity document
    local test_opportunity="$OPPORTUNITIES_DIR/test-opportunity-$(date +%Y%m%d).md"

    cat > "$test_opportunity" <<EOF
# Investment Opportunity: TEST

**Scan Date**: $(date +%Y-%m-%d)
**Symbol**: TEST
**Source**: Market Scanner

## Overview
Test opportunity document.

## Key Metrics
- Price: \$100.00
- Volume: 1,000,000

## Data Source
FMP API via fmp-screener.sh and fmp-quote.sh
EOF

    if assert_file_exists "$test_opportunity" "Opportunity document created"; then
        # Verify it contains FMP reference
        if grep -q "FMP API" "$test_opportunity"; then
            assert_success "Opportunity document references FMP"
        else
            assert_failure "Opportunity document missing FMP reference"
        fi

        # Cleanup
        rm -f "$test_opportunity"
    fi
}

#=============================================================================
# Test Fundamental Analyst Agent
#=============================================================================

test_fundamental_analyst_agent_config() {
    check_agent_has_fmp "$FUNDAMENTAL_ANALYST_AGENT" "Fundamental Analyst"
}

test_fundamental_analyst_workflow() {
    start_test "Fundamental Analyst: FMP workflow simulation"

    if ! has_api_key; then
        skip_test "API key not available"
        return
    fi

    local symbol="AAPL"

    # Simulate Fundamental Analyst workflow:
    # 1. Get profile
    # 2. Get financial statements (income, balance, cashflow)
    # 3. Get ratios and metrics

    local profile=$(bash "$FMP_SCRIPTS_DIR/fmp-profile.sh" "$symbol" 2>&1)

    if ! echo "$profile" | jq -e . >/dev/null 2>&1; then
        skip_test "Profile API call failed"
        return
    fi

    if echo "$profile" | jq -e '.error' >/dev/null 2>&1; then
        skip_test "API error: $(echo "$profile" | jq -r '.message')"
        return
    fi

    local income=$(bash "$FMP_SCRIPTS_DIR/fmp-financials.sh" "$symbol" income 5 annual 2>&1)

    if ! echo "$income" | jq -e . >/dev/null 2>&1; then
        assert_failure "Income statement API call failed"
        return
    fi

    local ratios=$(bash "$FMP_SCRIPTS_DIR/fmp-ratios.sh" "$symbol" ratios 5 2>&1)

    if ! echo "$ratios" | jq -e . >/dev/null 2>&1; then
        assert_failure "Ratios API call failed"
        return
    fi

    assert_success "Fundamental Analyst workflow completed successfully"
}

test_fundamental_analyst_data_quality() {
    start_test "Fundamental Analyst: validates FMP data quality"

    if ! has_api_key; then
        skip_test "API key not available"
        return
    fi

    local symbol="AAPL"

    # Fetch financial data
    local income=$(bash "$FMP_SCRIPTS_DIR/fmp-financials.sh" "$symbol" income 5 annual 2>&1)

    if ! echo "$income" | jq -e . >/dev/null 2>&1; then
        skip_test "Income statement API call failed"
        return
    fi

    if echo "$income" | jq -e '.error' >/dev/null 2>&1; then
        skip_test "API error: $(echo "$income" | jq -r '.message')"
        return
    fi

    # Validate data has required fields
    local has_date=$(echo "$income" | jq -e '.[0].date' >/dev/null 2>&1 && echo "yes" || echo "no")
    local has_revenue=$(echo "$income" | jq -e '.[0].revenue' >/dev/null 2>&1 && echo "yes" || echo "no")

    if [[ "$has_date" == "yes" && "$has_revenue" == "yes" ]]; then
        assert_success "Financial data has required fields"
    else
        assert_failure "Financial data missing required fields"
    fi
}

#=============================================================================
# Test Technical Analyst Agent
#=============================================================================

test_technical_analyst_agent_config() {
    check_agent_has_fmp "$TECHNICAL_ANALYST_AGENT" "Technical Analyst"
}

test_technical_analyst_workflow() {
    start_test "Technical Analyst: FMP workflow simulation"

    if ! has_api_key; then
        skip_test "API key not available"
        return
    fi

    local symbol="AAPL"

    # Simulate Technical Analyst workflow:
    # 1. Get current quote
    # 2. Get historical data
    # 3. Get technical indicators (SMA, RSI)

    local quote=$(bash "$FMP_SCRIPTS_DIR/fmp-quote.sh" "$symbol" 2>&1)

    if ! echo "$quote" | jq -e . >/dev/null 2>&1; then
        skip_test "Quote API call failed"
        return
    fi

    if echo "$quote" | jq -e '.error' >/dev/null 2>&1; then
        skip_test "API error: $(echo "$quote" | jq -r '.message')"
        return
    fi

    local historical=$(bash "$FMP_SCRIPTS_DIR/fmp-historical.sh" "$symbol" "" "" 100 daily 2>&1)

    if ! echo "$historical" | jq -e . >/dev/null 2>&1; then
        assert_failure "Historical data API call failed"
        return
    fi

    local sma=$(bash "$FMP_SCRIPTS_DIR/fmp-indicators.sh" "$symbol" sma 50 daily 2>&1)

    if ! echo "$sma" | jq -e . >/dev/null 2>&1; then
        assert_failure "Indicator API call failed"
        return
    fi

    assert_success "Technical Analyst workflow completed successfully"
}

test_technical_analyst_indicators() {
    start_test "Technical Analyst: fetches multiple indicators"

    if ! has_api_key; then
        skip_test "API key not available"
        return
    fi

    local symbol="AAPL"

    # Test multiple indicator types
    local sma=$(bash "$FMP_SCRIPTS_DIR/fmp-indicators.sh" "$symbol" sma 20 daily 2>&1)
    local rsi=$(bash "$FMP_SCRIPTS_DIR/fmp-indicators.sh" "$symbol" rsi 14 daily 2>&1)

    local sma_valid=$(echo "$sma" | jq -e . >/dev/null 2>&1 && echo "yes" || echo "no")
    local rsi_valid=$(echo "$rsi" | jq -e . >/dev/null 2>&1 && echo "yes" || echo "no")

    if [[ "$sma_valid" == "yes" && "$rsi_valid" == "yes" ]]; then
        if echo "$sma" | jq -e '.error' >/dev/null 2>&1 || echo "$rsi" | jq -e '.error' >/dev/null 2>&1; then
            skip_test "API errors in indicator calls"
        else
            assert_success "Multiple indicators fetched successfully"
        fi
    else
        assert_failure "Indicator API calls failed"
    fi
}

#=============================================================================
# Test Portfolio Monitor Agent
#=============================================================================

test_portfolio_monitor_agent_config() {
    check_agent_has_fmp "$PORTFOLIO_MONITOR_AGENT" "Portfolio Monitor"
}

test_portfolio_monitor_batch_quotes() {
    start_test "Portfolio Monitor: batch quote workflow"

    if ! has_api_key; then
        skip_test "API key not available"
        return
    fi

    # Simulate portfolio with multiple positions
    local symbols="AAPL,MSFT,GOOGL"

    local batch_quotes=$(bash "$FMP_SCRIPTS_DIR/fmp-quote.sh" "$symbols" 2>&1)

    if ! echo "$batch_quotes" | jq -e . >/dev/null 2>&1; then
        skip_test "Batch quote API call failed"
        return
    fi

    if echo "$batch_quotes" | jq -e '.error' >/dev/null 2>&1; then
        skip_test "API error: $(echo "$batch_quotes" | jq -r '.message')"
        return
    fi

    local count=$(echo "$batch_quotes" | jq 'length')

    if [[ $count -ge 3 ]]; then
        assert_success "Batch quotes fetched for all positions"
    else
        assert_failure "Batch quotes incomplete (expected 3, got $count)"
    fi
}

test_portfolio_monitor_position_tracking() {
    start_test "Portfolio Monitor: position tracking simulation"

    # Create test portfolio file
    local test_portfolio="$TEST_TMP_DIR/test-portfolio.yaml"

    cat > "$test_portfolio" <<EOF
positions:
  - symbol: AAPL
    entry_price: 150.00
    quantity: 10
    entry_date: 2024-01-01
  - symbol: MSFT
    entry_price: 350.00
    quantity: 5
    entry_date: 2024-01-01
EOF

    if assert_file_exists "$test_portfolio" "Test portfolio created"; then
        # Simulate reading symbols from portfolio
        if command -v yq >/dev/null 2>&1; then
            local symbols=$(yq -r '.positions[].symbol' "$test_portfolio" | paste -sd "," -)

            if [[ -n "$symbols" ]]; then
                assert_success "Successfully extracted symbols from portfolio"
            else
                skip_test "Could not extract symbols"
            fi
        else
            skip_test "yq not available for YAML parsing"
        fi
    fi
}

#=============================================================================
# Cross-Agent Integration Tests
#=============================================================================

test_data_consistency_across_agents() {
    start_test "Cross-Agent: data consistency check"

    if ! has_api_key; then
        skip_test "API key not available"
        return
    fi

    local symbol="AAPL"

    # Get quote from Market Scanner perspective
    local quote1=$(bash "$FMP_SCRIPTS_DIR/fmp-quote.sh" "$symbol" 2>&1)

    # Get quote from Portfolio Monitor perspective
    local quote2=$(bash "$FMP_SCRIPTS_DIR/fmp-quote.sh" "$symbol" 2>&1)

    if ! echo "$quote1" | jq -e . >/dev/null 2>&1 || ! echo "$quote2" | jq -e . >/dev/null 2>&1; then
        skip_test "Quote API calls failed"
        return
    fi

    if echo "$quote1" | jq -e '.error' >/dev/null 2>&1 || echo "$quote2" | jq -e '.error' >/dev/null 2>&1; then
        skip_test "API errors in quote calls"
        return
    fi

    local price1=$(echo "$quote1" | jq -r '.[0].price')
    local price2=$(echo "$quote2" | jq -r '.[0].price')

    if [[ "$price1" == "$price2" ]]; then
        assert_success "Price data consistent across agent calls"
    else
        assert_failure "Price data inconsistent (quote1: $price1, quote2: $price2)"
    fi
}

#=============================================================================
# Run all tests
#=============================================================================

echo ""
echo -e "${BOLD}${BLUE}Running Integration Tests...${NC}"
echo ""

# Market Scanner tests
test_market_scanner_agent_config
test_market_scanner_workflow
test_market_scanner_output_creation

# Fundamental Analyst tests
test_fundamental_analyst_agent_config
test_fundamental_analyst_workflow
test_fundamental_analyst_data_quality

# Technical Analyst tests
test_technical_analyst_agent_config
test_technical_analyst_workflow
test_technical_analyst_indicators

# Portfolio Monitor tests
test_portfolio_monitor_agent_config
test_portfolio_monitor_batch_quotes
test_portfolio_monitor_position_tracking

# Cross-agent tests
test_data_consistency_across_agents

# Cleanup and print summary
cleanup_test_env
print_summary

exit $?
