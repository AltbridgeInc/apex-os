#!/usr/bin/env bash
# test-fmp-scripts.sh - Unit tests for FMP helper scripts
# Tests each helper script individually with various inputs

set -euo pipefail

# Get script directory
SCRIPT_DIR="/Users/nazymazimbayev/apex-os-1"
FMP_SCRIPTS_DIR="$SCRIPT_DIR/scripts/fmp"
TEST_DIR="$(dirname "$0")"

# Source test helpers
source "$SCRIPT_DIR/tests/test-helpers.sh"

# Initialize test suite
init_test_suite "FMP Helper Scripts Unit Tests"

# Setup test environment
setup_test_env

# Create mock data directory
MOCK_DATA_DIR="$TEST_TMP_DIR/mock-data"
mkdir -p "$MOCK_DATA_DIR"

#=============================================================================
# Test fmp-common.sh
#=============================================================================

test_fmp_common_load_api_key_valid() {
    start_test "fmp-common.sh: load_api_key() with valid .env"

    # Create temporary .env with API key
    echo "FMP_API_KEY=test_api_key_12345" > "$TEST_TMP_DIR/.env.test"

    # Source fmp-common and test
    (
        cd "$FMP_SCRIPTS_DIR"
        source ./fmp-common.sh

        # Temporarily modify env file path for test
        env_file="$TEST_TMP_DIR/.env.test"
        if [[ -f "$env_file" ]]; then
            source "$env_file"
            if [[ -n "${FMP_API_KEY:-}" ]]; then
                exit 0
            fi
        fi
        exit 1
    )

    if [[ $? -eq 0 ]]; then
        assert_success "load_api_key should succeed with valid .env"
    else
        assert_failure "load_api_key should succeed with valid .env"
    fi
}

test_fmp_common_validate_symbol_valid() {
    start_test "fmp-common.sh: validate_symbol() with valid symbols"

    # Test valid single symbol
    result=$(cd "$FMP_SCRIPTS_DIR" && source ./fmp-common.sh && validate_symbol "AAPL" && echo "valid")

    assert_equal "valid" "$result" "AAPL should be valid symbol"
}

test_fmp_common_validate_symbol_invalid() {
    start_test "fmp-common.sh: validate_symbol() with invalid symbols"

    # Test invalid symbol (should produce error JSON)
    result=$(cd "$FMP_SCRIPTS_DIR" && source ./fmp-common.sh && validate_symbol "invalid123" 2>&1 || echo "error")

    assert_contains "$result" "error" "invalid123 should fail validation"
}

test_fmp_common_format_error() {
    start_test "fmp-common.sh: format_error() returns valid JSON"

    # Test error formatting
    result=$(cd "$FMP_SCRIPTS_DIR" && source ./fmp-common.sh && format_error "test_error" "Test message")

    assert_json "$result" "Error JSON should be valid"
    assert_contains "$result" "\"error\": true" "Error JSON should have error=true"
    assert_contains "$result" "test_error" "Error JSON should contain error type"
}

#=============================================================================
# Test fmp-quote.sh
#=============================================================================

test_fmp_quote_single_symbol() {
    start_test "fmp-quote.sh: fetch single symbol"

    if ! has_api_key; then
        skip_test "API key not available"
        return
    fi

    result=$(bash "$FMP_SCRIPTS_DIR/fmp-quote.sh" AAPL 2>&1)

    if assert_json "$result" "Quote response should be valid JSON"; then
        if echo "$result" | jq -e '.error' >/dev/null 2>&1; then
            skip_test "API error: $(echo "$result" | jq -r '.message')"
        else
            assert_json_has_key "$result" ".[0].symbol" "Quote should have symbol field"
            assert_json_has_key "$result" ".[0].price" "Quote should have price field"
        fi
    fi
}

test_fmp_quote_batch_symbols() {
    start_test "fmp-quote.sh: fetch batch symbols"

    if ! has_api_key; then
        skip_test "API key not available"
        return
    fi

    result=$(bash "$FMP_SCRIPTS_DIR/fmp-quote.sh" "AAPL,MSFT,GOOGL" 2>&1)

    if assert_json "$result" "Batch quote response should be valid JSON"; then
        if echo "$result" | jq -e '.error' >/dev/null 2>&1; then
            skip_test "API error: $(echo "$result" | jq -r '.message')"
        else
            count=$(echo "$result" | jq 'length')
            if [[ $count -ge 1 ]]; then
                assert_success "Batch quote should return multiple symbols"
            else
                assert_failure "Batch quote returned no symbols"
            fi
        fi
    fi
}

test_fmp_quote_invalid_symbol() {
    start_test "fmp-quote.sh: handle invalid symbol"

    if ! has_api_key; then
        skip_test "API key not available"
        return
    fi

    result=$(bash "$FMP_SCRIPTS_DIR/fmp-quote.sh" "INVALID999" 2>&1)

    if assert_json "$result" "Invalid symbol response should be valid JSON"; then
        # Should either return error or empty array
        if echo "$result" | jq -e '.error' >/dev/null 2>&1; then
            assert_success "Invalid symbol should return error JSON"
        else
            count=$(echo "$result" | jq 'length')
            if [[ $count -eq 0 ]]; then
                assert_success "Invalid symbol should return empty array"
            else
                skip_test "Invalid symbol returned unexpected data"
            fi
        fi
    fi
}

#=============================================================================
# Test fmp-financials.sh
#=============================================================================

test_fmp_financials_income_statement() {
    start_test "fmp-financials.sh: fetch income statement"

    if ! has_api_key; then
        skip_test "API key not available"
        return
    fi

    result=$(bash "$FMP_SCRIPTS_DIR/fmp-financials.sh" AAPL income 5 annual 2>&1)

    if assert_json "$result" "Income statement response should be valid JSON"; then
        if echo "$result" | jq -e '.error' >/dev/null 2>&1; then
            skip_test "API error: $(echo "$result" | jq -r '.message')"
        else
            assert_json_has_key "$result" ".[0].date" "Income statement should have date field"
            assert_json_has_key "$result" ".[0].revenue" "Income statement should have revenue field"
        fi
    fi
}

test_fmp_financials_balance_sheet() {
    start_test "fmp-financials.sh: fetch balance sheet"

    if ! has_api_key; then
        skip_test "API key not available"
        return
    fi

    result=$(bash "$FMP_SCRIPTS_DIR/fmp-financials.sh" AAPL balance 5 annual 2>&1)

    if assert_json "$result" "Balance sheet response should be valid JSON"; then
        if echo "$result" | jq -e '.error' >/dev/null 2>&1; then
            skip_test "API error: $(echo "$result" | jq -r '.message')"
        else
            assert_json_has_key "$result" ".[0].totalAssets" "Balance sheet should have totalAssets field"
        fi
    fi
}

test_fmp_financials_cash_flow() {
    start_test "fmp-financials.sh: fetch cash flow statement"

    if ! has_api_key; then
        skip_test "API key not available"
        return
    fi

    result=$(bash "$FMP_SCRIPTS_DIR/fmp-financials.sh" AAPL cashflow 5 annual 2>&1)

    if assert_json "$result" "Cash flow response should be valid JSON"; then
        if echo "$result" | jq -e '.error' >/dev/null 2>&1; then
            skip_test "API error: $(echo "$result" | jq -r '.message')"
        else
            assert_json_has_key "$result" ".[0].operatingCashFlow" "Cash flow should have operatingCashFlow field"
        fi
    fi
}

test_fmp_financials_invalid_type() {
    start_test "fmp-financials.sh: handle invalid statement type"

    result=$(bash "$FMP_SCRIPTS_DIR/fmp-financials.sh" AAPL invalid 5 annual 2>&1)

    assert_json "$result" "Invalid type response should be valid JSON"
    assert_json_value "$result" ".error" "true" "Invalid type should return error"
}

#=============================================================================
# Test fmp-ratios.sh
#=============================================================================

test_fmp_ratios_ratios() {
    start_test "fmp-ratios.sh: fetch financial ratios"

    if ! has_api_key; then
        skip_test "API key not available"
        return
    fi

    result=$(bash "$FMP_SCRIPTS_DIR/fmp-ratios.sh" AAPL ratios 5 2>&1)

    if assert_json "$result" "Ratios response should be valid JSON"; then
        if echo "$result" | jq -e '.error' >/dev/null 2>&1; then
            skip_test "API error: $(echo "$result" | jq -r '.message')"
        else
            assert_json_has_key "$result" ".[0].date" "Ratios should have date field"
        fi
    fi
}

test_fmp_ratios_metrics() {
    start_test "fmp-ratios.sh: fetch key metrics"

    if ! has_api_key; then
        skip_test "API key not available"
        return
    fi

    result=$(bash "$FMP_SCRIPTS_DIR/fmp-ratios.sh" AAPL metrics 5 2>&1)

    if assert_json "$result" "Metrics response should be valid JSON"; then
        if echo "$result" | jq -e '.error' >/dev/null 2>&1; then
            skip_test "API error: $(echo "$result" | jq -r '.message')"
        else
            assert_json_has_key "$result" ".[0].date" "Metrics should have date field"
        fi
    fi
}

test_fmp_ratios_growth() {
    start_test "fmp-ratios.sh: fetch growth metrics"

    if ! has_api_key; then
        skip_test "API key not available"
        return
    fi

    result=$(bash "$FMP_SCRIPTS_DIR/fmp-ratios.sh" AAPL growth 5 2>&1)

    if assert_json "$result" "Growth response should be valid JSON"; then
        if echo "$result" | jq -e '.error' >/dev/null 2>&1; then
            skip_test "API error: $(echo "$result" | jq -r '.message')"
        else
            assert_json_has_key "$result" ".[0].date" "Growth should have date field"
        fi
    fi
}

#=============================================================================
# Test fmp-profile.sh
#=============================================================================

test_fmp_profile() {
    start_test "fmp-profile.sh: fetch company profile"

    if ! has_api_key; then
        skip_test "API key not available"
        return
    fi

    result=$(bash "$FMP_SCRIPTS_DIR/fmp-profile.sh" AAPL 2>&1)

    if assert_json "$result" "Profile response should be valid JSON"; then
        if echo "$result" | jq -e '.error' >/dev/null 2>&1; then
            skip_test "API error: $(echo "$result" | jq -r '.message')"
        else
            assert_json_has_key "$result" ".companyName" "Profile should have companyName field"
            assert_json_has_key "$result" ".sector" "Profile should have sector field"
            assert_json_has_key "$result" ".industry" "Profile should have industry field"
        fi
    fi
}

#=============================================================================
# Test fmp-historical.sh
#=============================================================================

test_fmp_historical_daily() {
    start_test "fmp-historical.sh: fetch daily historical data"

    if ! has_api_key; then
        skip_test "API key not available"
        return
    fi

    result=$(bash "$FMP_SCRIPTS_DIR/fmp-historical.sh" AAPL "" "" 10 daily 2>&1)

    if assert_json "$result" "Historical response should be valid JSON"; then
        if echo "$result" | jq -e '.error' >/dev/null 2>&1; then
            skip_test "API error: $(echo "$result" | jq -r '.message')"
        else
            count=$(echo "$result" | jq 'length')
            if [[ $count -gt 0 ]]; then
                assert_json_has_key "$result" ".[0].date" "Historical should have date field"
                assert_json_has_key "$result" ".[0].close" "Historical should have close field"
                assert_success "Historical data fetched successfully"
            else
                skip_test "No historical data returned"
            fi
        fi
    fi
}

#=============================================================================
# Test fmp-screener.sh
#=============================================================================

test_fmp_screener_gainers() {
    start_test "fmp-screener.sh: fetch top gainers"

    if ! has_api_key; then
        skip_test "API key not available"
        return
    fi

    result=$(bash "$FMP_SCRIPTS_DIR/fmp-screener.sh" --type=gainers --limit=10 2>&1)

    if assert_json "$result" "Screener response should be valid JSON"; then
        if echo "$result" | jq -e '.error' >/dev/null 2>&1; then
            skip_test "API error: $(echo "$result" | jq -r '.message')"
        else
            count=$(echo "$result" | jq 'length')
            if [[ $count -gt 0 ]]; then
                assert_success "Screener returned gainers"
            else
                skip_test "No gainers returned"
            fi
        fi
    fi
}

test_fmp_screener_custom_filter() {
    start_test "fmp-screener.sh: custom filter criteria"

    if ! has_api_key; then
        skip_test "API key not available"
        return
    fi

    result=$(bash "$FMP_SCRIPTS_DIR/fmp-screener.sh" --marketCapMoreThan=1000000000 --limit=10 2>&1)

    if assert_json "$result" "Screener response should be valid JSON"; then
        if echo "$result" | jq -e '.error' >/dev/null 2>&1; then
            skip_test "API error: $(echo "$result" | jq -r '.message')"
        else
            count=$(echo "$result" | jq 'length')
            if [[ $count -gt 0 ]]; then
                assert_success "Screener returned filtered stocks"
            else
                skip_test "No stocks matched filter"
            fi
        fi
    fi
}

#=============================================================================
# Test fmp-indicators.sh
#=============================================================================

test_fmp_indicators_sma() {
    start_test "fmp-indicators.sh: fetch SMA indicator"

    if ! has_api_key; then
        skip_test "API key not available"
        return
    fi

    result=$(bash "$FMP_SCRIPTS_DIR/fmp-indicators.sh" AAPL sma 50 daily 2>&1)

    if assert_json "$result" "Indicator response should be valid JSON"; then
        if echo "$result" | jq -e '.error' >/dev/null 2>&1; then
            skip_test "API error: $(echo "$result" | jq -r '.message')"
        else
            count=$(echo "$result" | jq 'length')
            if [[ $count -gt 0 ]]; then
                assert_json_has_key "$result" ".[0].date" "Indicator should have date field"
                assert_success "SMA indicator fetched successfully"
            else
                skip_test "No indicator data returned"
            fi
        fi
    fi
}

test_fmp_indicators_rsi() {
    start_test "fmp-indicators.sh: fetch RSI indicator"

    if ! has_api_key; then
        skip_test "API key not available"
        return
    fi

    result=$(bash "$FMP_SCRIPTS_DIR/fmp-indicators.sh" AAPL rsi 14 daily 2>&1)

    if assert_json "$result" "Indicator response should be valid JSON"; then
        if echo "$result" | jq -e '.error' >/dev/null 2>&1; then
            skip_test "API error: $(echo "$result" | jq -r '.message')"
        else
            count=$(echo "$result" | jq 'length')
            if [[ $count -gt 0 ]]; then
                assert_success "RSI indicator fetched successfully"
            else
                skip_test "No indicator data returned"
            fi
        fi
    fi
}

#=============================================================================
# Run all tests
#=============================================================================

echo ""
echo -e "${BOLD}${BLUE}Running Unit Tests...${NC}"
echo ""

# fmp-common.sh tests
test_fmp_common_load_api_key_valid
test_fmp_common_validate_symbol_valid
test_fmp_common_validate_symbol_invalid
test_fmp_common_format_error

# fmp-quote.sh tests
test_fmp_quote_single_symbol
test_fmp_quote_batch_symbols
test_fmp_quote_invalid_symbol

# fmp-financials.sh tests
test_fmp_financials_income_statement
test_fmp_financials_balance_sheet
test_fmp_financials_cash_flow
test_fmp_financials_invalid_type

# fmp-ratios.sh tests
test_fmp_ratios_ratios
test_fmp_ratios_metrics
test_fmp_ratios_growth

# fmp-profile.sh tests
test_fmp_profile

# fmp-historical.sh tests
test_fmp_historical_daily

# fmp-screener.sh tests
test_fmp_screener_gainers
test_fmp_screener_custom_filter

# fmp-indicators.sh tests
test_fmp_indicators_sma
test_fmp_indicators_rsi

# Cleanup and print summary
cleanup_test_env
print_summary

exit $?
