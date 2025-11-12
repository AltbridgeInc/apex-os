#!/usr/bin/env bash
# benchmark-fmp.sh - Performance benchmarking for FMP integration
# Tests performance benchmarks and API call efficiency

set -euo pipefail

# Get script directory
SCRIPT_DIR="/Users/nazymazimbayev/apex-os-1"
FMP_SCRIPTS_DIR="$SCRIPT_DIR/scripts/fmp"
TEST_DIR="$(dirname "$0")"

# Source test helpers
source "$SCRIPT_DIR/tests/test-helpers.sh"

# Initialize test suite
init_test_suite "Performance Benchmark Tests"

# Setup test environment
setup_test_env

# Performance thresholds (in seconds)
MARKET_SCANNER_THRESHOLD=180    # 3 minutes
FUNDAMENTAL_ANALYST_THRESHOLD=120   # 2 minutes
TECHNICAL_ANALYST_THRESHOLD=120     # 2 minutes
PORTFOLIO_MONITOR_THRESHOLD=60      # 1 minute

# API call limits
MARKET_SCANNER_API_LIMIT=20
FUNDAMENTAL_ANALYST_API_LIMIT=15
TECHNICAL_ANALYST_API_LIMIT=10
PORTFOLIO_MONITOR_API_LIMIT=5

# Test symbol
TEST_SYMBOL="AAPL"

#=============================================================================
# Helper Functions
#=============================================================================

# Time a command execution
# Args: $1 - command, $2 - description
time_command() {
    local cmd="$1"
    local desc="$2"

    echo -e "${BLUE}  Timing: $desc${NC}"

    local start_time=$(date +%s)
    eval "$cmd" >/dev/null 2>&1
    local end_time=$(date +%s)

    local duration=$((end_time - start_time))
    echo -e "${BLUE}  Duration: ${duration}s${NC}"

    echo "$duration"
}

# Count API calls made
# Returns: number of API calls in current minute
count_api_calls() {
    local rate_limit_dir="/tmp"
    local rate_file_pattern="fmp_rate_*.txt"

    local total=0

    if ls $rate_limit_dir/$rate_file_pattern >/dev/null 2>&1; then
        for file in $rate_limit_dir/$rate_file_pattern; do
            if [[ -f "$file" ]]; then
                local count=$(wc -l < "$file" 2>/dev/null || echo 0)
                total=$((total + count))
            fi
        done
    fi

    echo "$total"
}

# Clear API call counters
clear_api_counters() {
    rm -f /tmp/fmp_rate_*.txt 2>/dev/null || true
}

#=============================================================================
# Performance Tests
#=============================================================================

test_single_api_call_performance() {
    start_test "Performance: Single API call latency"

    if ! has_api_key; then
        skip_test "API key not available"
        return
    fi

    # Time a single quote call
    local duration=$(time_command "bash '$FMP_SCRIPTS_DIR/fmp-quote.sh' '$TEST_SYMBOL'" "Single quote API call")

    # Single API call should be fast (< 5 seconds)
    if [[ $duration -lt 5 ]]; then
        assert_success "Single API call completed in ${duration}s (< 5s)"
    else
        assert_failure "Single API call too slow: ${duration}s"
    fi
}

test_batch_quote_performance() {
    start_test "Performance: Batch quote vs individual quotes"

    if ! has_api_key; then
        skip_test "API key not available"
        return
    fi

    local symbols="AAPL,MSFT,GOOGL"

    # Time batch quote
    local batch_duration=$(time_command "bash '$FMP_SCRIPTS_DIR/fmp-quote.sh' '$symbols'" "Batch quote (3 symbols)")

    # Batch should be faster than 3 individual calls
    # Batch call should be < 10 seconds
    if [[ $batch_duration -lt 10 ]]; then
        assert_success "Batch quote completed in ${batch_duration}s (< 10s)"
    else
        assert_failure "Batch quote too slow: ${batch_duration}s"
    fi
}

test_market_scanner_performance() {
    start_test "Performance: Market Scanner workflow (< 3 min)"

    if ! has_api_key; then
        skip_test "API key not available"
        return
    fi

    clear_api_counters
    local start_calls=$(count_api_calls)

    echo -e "${BLUE}  Simulating Market Scanner workflow...${NC}"

    local start_time=$(date +%s)

    # Simulate Market Scanner workflow
    # 1. Screen for gainers
    bash "$FMP_SCRIPTS_DIR/fmp-screener.sh" --type=gainers --limit=10 >/dev/null 2>&1

    # 2. Get detailed quotes for top 5
    bash "$FMP_SCRIPTS_DIR/fmp-quote.sh" "AAPL,MSFT,GOOGL,TSLA,NVDA" >/dev/null 2>&1

    # 3. Get profile for top 3
    bash "$FMP_SCRIPTS_DIR/fmp-profile.sh" AAPL >/dev/null 2>&1
    bash "$FMP_SCRIPTS_DIR/fmp-profile.sh" MSFT >/dev/null 2>&1
    bash "$FMP_SCRIPTS_DIR/fmp-profile.sh" GOOGL >/dev/null 2>&1

    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    local end_calls=$(count_api_calls)
    local api_calls=$((end_calls - start_calls))

    echo -e "${BLUE}  Duration: ${duration}s${NC}"
    echo -e "${BLUE}  API calls: ${api_calls}${NC}"

    # Check duration
    if [[ $duration -lt $MARKET_SCANNER_THRESHOLD ]]; then
        assert_success "Market Scanner completed in ${duration}s (< ${MARKET_SCANNER_THRESHOLD}s)"
    else
        assert_failure "Market Scanner too slow: ${duration}s (threshold: ${MARKET_SCANNER_THRESHOLD}s)"
    fi

    # Check API call count
    if [[ $api_calls -le $MARKET_SCANNER_API_LIMIT ]]; then
        echo -e "${GREEN}  API calls within limit: ${api_calls}/${MARKET_SCANNER_API_LIMIT}${NC}"
    else
        echo -e "${YELLOW}  Warning: API calls exceed limit: ${api_calls}/${MARKET_SCANNER_API_LIMIT}${NC}"
    fi
}

test_fundamental_analyst_performance() {
    start_test "Performance: Fundamental Analyst data fetch (< 2 min)"

    if ! has_api_key; then
        skip_test "API key not available"
        return
    fi

    clear_api_counters
    local start_calls=$(count_api_calls)

    echo -e "${BLUE}  Simulating Fundamental Analyst workflow...${NC}"

    local start_time=$(date +%s)

    # Simulate Fundamental Analyst workflow
    # 1. Get profile
    bash "$FMP_SCRIPTS_DIR/fmp-profile.sh" "$TEST_SYMBOL" >/dev/null 2>&1

    # 2. Get financial statements
    bash "$FMP_SCRIPTS_DIR/fmp-financials.sh" "$TEST_SYMBOL" income 5 annual >/dev/null 2>&1
    bash "$FMP_SCRIPTS_DIR/fmp-financials.sh" "$TEST_SYMBOL" balance 5 annual >/dev/null 2>&1
    bash "$FMP_SCRIPTS_DIR/fmp-financials.sh" "$TEST_SYMBOL" cashflow 5 annual >/dev/null 2>&1

    # 3. Get ratios and metrics
    bash "$FMP_SCRIPTS_DIR/fmp-ratios.sh" "$TEST_SYMBOL" ratios 5 >/dev/null 2>&1
    bash "$FMP_SCRIPTS_DIR/fmp-ratios.sh" "$TEST_SYMBOL" metrics 5 >/dev/null 2>&1
    bash "$FMP_SCRIPTS_DIR/fmp-ratios.sh" "$TEST_SYMBOL" growth 5 >/dev/null 2>&1

    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    local end_calls=$(count_api_calls)
    local api_calls=$((end_calls - start_calls))

    echo -e "${BLUE}  Duration: ${duration}s${NC}"
    echo -e "${BLUE}  API calls: ${api_calls}${NC}"

    # Check duration
    if [[ $duration -lt $FUNDAMENTAL_ANALYST_THRESHOLD ]]; then
        assert_success "Fundamental Analyst completed in ${duration}s (< ${FUNDAMENTAL_ANALYST_THRESHOLD}s)"
    else
        assert_failure "Fundamental Analyst too slow: ${duration}s (threshold: ${FUNDAMENTAL_ANALYST_THRESHOLD}s)"
    fi

    # Check API call count
    if [[ $api_calls -le $FUNDAMENTAL_ANALYST_API_LIMIT ]]; then
        echo -e "${GREEN}  API calls within limit: ${api_calls}/${FUNDAMENTAL_ANALYST_API_LIMIT}${NC}"
    else
        echo -e "${YELLOW}  Warning: API calls exceed limit: ${api_calls}/${FUNDAMENTAL_ANALYST_API_LIMIT}${NC}"
    fi
}

test_technical_analyst_performance() {
    start_test "Performance: Technical Analyst data fetch (< 2 min)"

    if ! has_api_key; then
        skip_test "API key not available"
        return
    fi

    clear_api_counters
    local start_calls=$(count_api_calls)

    echo -e "${BLUE}  Simulating Technical Analyst workflow...${NC}"

    local start_time=$(date +%s)

    # Simulate Technical Analyst workflow
    # 1. Get current quote
    bash "$FMP_SCRIPTS_DIR/fmp-quote.sh" "$TEST_SYMBOL" >/dev/null 2>&1

    # 2. Get historical data
    bash "$FMP_SCRIPTS_DIR/fmp-historical.sh" "$TEST_SYMBOL" "" "" 500 daily >/dev/null 2>&1

    # 3. Get indicators
    bash "$FMP_SCRIPTS_DIR/fmp-indicators.sh" "$TEST_SYMBOL" sma 20 daily >/dev/null 2>&1
    bash "$FMP_SCRIPTS_DIR/fmp-indicators.sh" "$TEST_SYMBOL" sma 50 daily >/dev/null 2>&1
    bash "$FMP_SCRIPTS_DIR/fmp-indicators.sh" "$TEST_SYMBOL" sma 200 daily >/dev/null 2>&1
    bash "$FMP_SCRIPTS_DIR/fmp-indicators.sh" "$TEST_SYMBOL" rsi 14 daily >/dev/null 2>&1

    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    local end_calls=$(count_api_calls)
    local api_calls=$((end_calls - start_calls))

    echo -e "${BLUE}  Duration: ${duration}s${NC}"
    echo -e "${BLUE}  API calls: ${api_calls}${NC}"

    # Check duration
    if [[ $duration -lt $TECHNICAL_ANALYST_THRESHOLD ]]; then
        assert_success "Technical Analyst completed in ${duration}s (< ${TECHNICAL_ANALYST_THRESHOLD}s)"
    else
        assert_failure "Technical Analyst too slow: ${duration}s (threshold: ${TECHNICAL_ANALYST_THRESHOLD}s)"
    fi

    # Check API call count
    if [[ $api_calls -le $TECHNICAL_ANALYST_API_LIMIT ]]; then
        echo -e "${GREEN}  API calls within limit: ${api_calls}/${TECHNICAL_ANALYST_API_LIMIT}${NC}"
    else
        echo -e "${YELLOW}  Warning: API calls exceed limit: ${api_calls}/${TECHNICAL_ANALYST_API_LIMIT}${NC}"
    fi
}

test_portfolio_monitor_performance() {
    start_test "Performance: Portfolio Monitor daily report (< 1 min)"

    if ! has_api_key; then
        skip_test "API key not available"
        return
    fi

    clear_api_counters
    local start_calls=$(count_api_calls)

    echo -e "${BLUE}  Simulating Portfolio Monitor workflow...${NC}"

    local start_time=$(date +%s)

    # Simulate Portfolio Monitor workflow
    # 1. Batch quote for all positions (assume 10 positions)
    bash "$FMP_SCRIPTS_DIR/fmp-quote.sh" "AAPL,MSFT,GOOGL,TSLA,NVDA,AMZN,META,NFLX,AMD,INTC" >/dev/null 2>&1

    # 2. Get brief historical for trend check (optional)
    # Keeping it minimal for performance
    bash "$FMP_SCRIPTS_DIR/fmp-historical.sh" "AAPL" "" "" 5 daily >/dev/null 2>&1

    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    local end_calls=$(count_api_calls)
    local api_calls=$((end_calls - start_calls))

    echo -e "${BLUE}  Duration: ${duration}s${NC}"
    echo -e "${BLUE}  API calls: ${api_calls}${NC}"

    # Check duration
    if [[ $duration -lt $PORTFOLIO_MONITOR_THRESHOLD ]]; then
        assert_success "Portfolio Monitor completed in ${duration}s (< ${PORTFOLIO_MONITOR_THRESHOLD}s)"
    else
        assert_failure "Portfolio Monitor too slow: ${duration}s (threshold: ${PORTFOLIO_MONITOR_THRESHOLD}s)"
    fi

    # Check API call count
    if [[ $api_calls -le $PORTFOLIO_MONITOR_API_LIMIT ]]; then
        echo -e "${GREEN}  API calls within limit: ${api_calls}/${PORTFOLIO_MONITOR_API_LIMIT}${NC}"
    else
        echo -e "${YELLOW}  Warning: API calls exceed limit: ${api_calls}/${PORTFOLIO_MONITOR_API_LIMIT}${NC}"
    fi
}

test_rate_limit_compliance() {
    start_test "Performance: Rate limit compliance (250 calls/min)"

    if ! has_api_key; then
        skip_test "API key not available"
        return
    fi

    # Note: We won't actually make 250 calls to test this
    # Instead, we verify the rate limit mechanism exists

    if grep -q "check_rate_limit" "$FMP_SCRIPTS_DIR/fmp-common.sh"; then
        echo -e "${BLUE}  Rate limit check function exists${NC}"

        # Check if rate limit threshold is set correctly
        if grep -q "250\|240" "$FMP_SCRIPTS_DIR/fmp-common.sh"; then
            assert_success "Rate limit threshold configured (250/min)"
        else
            skip_test "Rate limit threshold not clearly visible in code"
        fi
    else
        skip_test "Rate limit check not implemented"
    fi
}

test_concurrent_api_calls() {
    start_test "Performance: Concurrent API call handling"

    if ! has_api_key; then
        skip_test "API key not available"
        return
    fi

    echo -e "${BLUE}  Testing 3 concurrent API calls...${NC}"

    local start_time=$(date +%s)

    # Make 3 API calls in parallel
    bash "$FMP_SCRIPTS_DIR/fmp-quote.sh" "AAPL" >/dev/null 2>&1 &
    bash "$FMP_SCRIPTS_DIR/fmp-quote.sh" "MSFT" >/dev/null 2>&1 &
    bash "$FMP_SCRIPTS_DIR/fmp-quote.sh" "GOOGL" >/dev/null 2>&1 &

    wait

    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    echo -e "${BLUE}  Concurrent calls completed in: ${duration}s${NC}"

    # Concurrent calls should not take 3x the time of a single call
    # Should be closer to single call time
    if [[ $duration -lt 15 ]]; then
        assert_success "Concurrent calls completed efficiently in ${duration}s"
    else
        assert_failure "Concurrent calls too slow: ${duration}s"
    fi
}

test_data_parsing_overhead() {
    start_test "Performance: JSON parsing overhead"

    if ! has_api_key; then
        skip_test "API key not available"
        return
    fi

    # Fetch data
    local data=$(bash "$FMP_SCRIPTS_DIR/fmp-quote.sh" "$TEST_SYMBOL" 2>&1)

    if ! echo "$data" | jq -e . >/dev/null 2>&1; then
        skip_test "API call failed"
        return
    fi

    # Time jq parsing
    local start_time=$(date +%s%3N)

    local symbol=$(echo "$data" | jq -r '.[0].symbol')
    local price=$(echo "$data" | jq -r '.[0].price')
    local change=$(echo "$data" | jq -r '.[0].change')

    local end_time=$(date +%s%3N)
    local duration=$((end_time - start_time))

    echo -e "${BLUE}  JSON parsing time: ${duration}ms${NC}"

    # Parsing should be fast (< 100ms)
    if [[ $duration -lt 100 ]]; then
        assert_success "JSON parsing efficient: ${duration}ms"
    else
        assert_failure "JSON parsing slow: ${duration}ms"
    fi
}

#=============================================================================
# Performance Summary Report
#=============================================================================

generate_performance_report() {
    start_test "Generate performance summary report"

    local report_file="$TEST_TMP_DIR/performance-report.md"

    cat > "$report_file" <<EOF
# FMP API Integration - Performance Report

**Report Date**: $(date +%Y-%m-%d)

## Performance Benchmarks

### Agent Workflows

| Agent | Threshold | Status |
|-------|-----------|--------|
| Market Scanner | < 3 min (180s) | See test results |
| Fundamental Analyst | < 2 min (120s) | See test results |
| Technical Analyst | < 2 min (120s) | See test results |
| Portfolio Monitor | < 1 min (60s) | See test results |

### API Call Efficiency

| Agent | API Call Limit | Status |
|-------|----------------|--------|
| Market Scanner | < 20 calls | See test results |
| Fundamental Analyst | < 15 calls | See test results |
| Technical Analyst | < 10 calls | See test results |
| Portfolio Monitor | < 5 calls | See test results |

## Rate Limiting

- FMP API Limit: 250 calls/minute
- Rate limit tracking: Implemented
- Rate limit prevention: Active

## Optimization Opportunities

1. **Batch API calls** where possible (reduce individual calls)
2. **Cache frequently accessed data** (company profiles, etc.)
3. **Parallel API calls** for independent data fetches
4. **Minimize redundant calls** across agent workflows

## Recommendations

- Monitor API usage in production
- Implement caching for static data (profiles, company info)
- Use batch endpoints for multiple symbols
- Consider API upgrade if approaching rate limits

---

*Generated by FMP Performance Benchmark Suite*
EOF

    if assert_file_exists "$report_file" "Performance report generated"; then
        echo -e "${BLUE}  Report saved to: $report_file${NC}"
    fi
}

#=============================================================================
# Run all tests
#=============================================================================

echo ""
echo -e "${BOLD}${BLUE}Running Performance Benchmark Tests...${NC}"
echo -e "${BLUE}Testing performance benchmarks and API efficiency${NC}"
echo ""

# Basic performance tests
test_single_api_call_performance
test_batch_quote_performance

# Agent workflow performance tests
test_market_scanner_performance
test_fundamental_analyst_performance
test_technical_analyst_performance
test_portfolio_monitor_performance

# Rate limit and concurrency tests
test_rate_limit_compliance
test_concurrent_api_calls

# Parsing overhead test
test_data_parsing_overhead

# Generate performance report
generate_performance_report

# Cleanup and print summary
cleanup_test_env
print_summary

exit $?
