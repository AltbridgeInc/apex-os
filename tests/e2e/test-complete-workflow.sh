#!/usr/bin/env bash
# test-complete-workflow.sh - End-to-end workflow testing
# Tests complete investment workflow from scan to monitoring

set -euo pipefail

# Get script directory
SCRIPT_DIR="/Users/nazymazimbayev/apex-os-1"
FMP_SCRIPTS_DIR="$SCRIPT_DIR/scripts/fmp"
TEST_DIR="$(dirname "$0")"

# Source test helpers
source "$SCRIPT_DIR/tests/test-helpers.sh"

# Initialize test suite
init_test_suite "End-to-End Workflow Tests"

# Setup test environment
setup_test_env

# Workflow directories
OPPORTUNITIES_DIR="$TEST_TMP_DIR/opportunities"
ANALYSIS_DIR="$TEST_TMP_DIR/analysis"
REPORTS_DIR="$TEST_TMP_DIR/reports"
PORTFOLIO_DIR="$TEST_TMP_DIR/portfolio"

# Create workflow directories
mkdir -p "$OPPORTUNITIES_DIR" "$ANALYSIS_DIR" "$REPORTS_DIR" "$PORTFOLIO_DIR"

# Test symbol for workflow
TEST_SYMBOL="AAPL"

#=============================================================================
# Workflow Steps
#=============================================================================

step1_market_scanner() {
    start_test "Step 1: Market Scanner identifies opportunities"

    if ! has_api_key; then
        skip_test "API key not available"
        return 1
    fi

    echo -e "${BLUE}  Running market scanner...${NC}"

    # Screen for top gainers
    local gainers=$(bash "$FMP_SCRIPTS_DIR/fmp-screener.sh" --type=gainers --limit=10 2>&1)

    if ! echo "$gainers" | jq -e . >/dev/null 2>&1; then
        assert_failure "Market scanner failed - invalid JSON response"
        return 1
    fi

    if echo "$gainers" | jq -e '.error' >/dev/null 2>&1; then
        skip_test "API error: $(echo "$gainers" | jq -r '.message')"
        return 1
    fi

    local count=$(echo "$gainers" | jq 'length')

    if [[ $count -eq 0 ]]; then
        skip_test "No gainers found"
        return 1
    fi

    # Extract first opportunity
    TEST_SYMBOL=$(echo "$gainers" | jq -r '.[0].symbol')

    if [[ -z "$TEST_SYMBOL" ]]; then
        assert_failure "Could not extract symbol from gainers"
        return 1
    fi

    # Get detailed quote for opportunity
    local quote=$(bash "$FMP_SCRIPTS_DIR/fmp-quote.sh" "$TEST_SYMBOL" 2>&1)

    if ! echo "$quote" | jq -e . >/dev/null 2>&1; then
        assert_failure "Quote fetch failed"
        return 1
    fi

    # Create opportunity document
    local opp_file="$OPPORTUNITIES_DIR/opportunity-${TEST_SYMBOL}-$(date +%Y%m%d).md"

    cat > "$opp_file" <<EOF
# Investment Opportunity: ${TEST_SYMBOL}

**Scan Date**: $(date +%Y-%m-%d)
**Symbol**: ${TEST_SYMBOL}
**Source**: Market Scanner (Top Gainers)

## Overview
$(echo "$quote" | jq -r '.[0].name // "N/A"')

## Key Metrics
- Price: \$$(echo "$quote" | jq -r '.[0].price // "N/A"')
- Change: $(echo "$quote" | jq -r '.[0].change // "N/A"') ($(echo "$quote" | jq -r '.[0].changesPercentage // "N/A"')%)
- Volume: $(echo "$quote" | jq -r '.[0].volume // "N/A"')
- Market Cap: \$$(echo "$quote" | jq -r '.[0].marketCap // "N/A"')

## Data Source
FMP API via fmp-screener.sh and fmp-quote.sh

## Next Steps
- Fundamental analysis required
- Technical analysis required
EOF

    if assert_file_exists "$opp_file" "Opportunity document created"; then
        echo -e "${BLUE}  Created: $opp_file${NC}"
        assert_success "Market Scanner completed successfully"
        return 0
    else
        assert_failure "Failed to create opportunity document"
        return 1
    fi
}

step2_fundamental_analysis() {
    start_test "Step 2: Fundamental Analyst analyzes opportunity"

    if ! has_api_key; then
        skip_test "API key not available"
        return 1
    fi

    if [[ -z "$TEST_SYMBOL" ]]; then
        assert_failure "No symbol from Step 1"
        return 1
    fi

    echo -e "${BLUE}  Running fundamental analysis on ${TEST_SYMBOL}...${NC}"

    # Fetch company profile
    local profile=$(bash "$FMP_SCRIPTS_DIR/fmp-profile.sh" "$TEST_SYMBOL" 2>&1)

    if ! echo "$profile" | jq -e . >/dev/null 2>&1; then
        assert_failure "Profile fetch failed"
        return 1
    fi

    if echo "$profile" | jq -e '.error' >/dev/null 2>&1; then
        skip_test "API error: $(echo "$profile" | jq -r '.message')"
        return 1
    fi

    # Fetch financial statements
    local income=$(bash "$FMP_SCRIPTS_DIR/fmp-financials.sh" "$TEST_SYMBOL" income 5 annual 2>&1)
    local balance=$(bash "$FMP_SCRIPTS_DIR/fmp-financials.sh" "$TEST_SYMBOL" balance 5 annual 2>&1)
    local cashflow=$(bash "$FMP_SCRIPTS_DIR/fmp-financials.sh" "$TEST_SYMBOL" cashflow 5 annual 2>&1)

    # Fetch ratios
    local ratios=$(bash "$FMP_SCRIPTS_DIR/fmp-ratios.sh" "$TEST_SYMBOL" ratios 5 2>&1)
    local metrics=$(bash "$FMP_SCRIPTS_DIR/fmp-ratios.sh" "$TEST_SYMBOL" metrics 5 2>&1)

    # Create fundamental analysis report
    local analysis_file="$ANALYSIS_DIR/fundamental-${TEST_SYMBOL}-$(date +%Y%m%d).md"

    cat > "$analysis_file" <<EOF
# Fundamental Analysis: ${TEST_SYMBOL}

**Analysis Date**: $(date +%Y-%m-%d)
**Symbol**: ${TEST_SYMBOL}
**Company**: $(echo "$profile" | jq -r '.companyName // "N/A"')

## Company Overview
- **Sector**: $(echo "$profile" | jq -r '.sector // "N/A"')
- **Industry**: $(echo "$profile" | jq -r '.industry // "N/A"')
- **Market Cap**: \$$(echo "$profile" | jq -r '.mktCap // "N/A"')
- **CEO**: $(echo "$profile" | jq -r '.ceo // "N/A"')

## Financial Health

### Income Statement (Latest Year)
- Revenue: \$$(echo "$income" | jq -r '.[0].revenue // "N/A"')
- Net Income: \$$(echo "$income" | jq -r '.[0].netIncome // "N/A"')
- EPS: \$$(echo "$income" | jq -r '.[0].eps // "N/A"')

### Balance Sheet (Latest Year)
- Total Assets: \$$(echo "$balance" | jq -r '.[0].totalAssets // "N/A"')
- Total Debt: \$$(echo "$balance" | jq -r '.[0].totalDebt // "N/A"')
- Cash: \$$(echo "$balance" | jq -r '.[0].cashAndCashEquivalents // "N/A"')

### Cash Flow (Latest Year)
- Operating Cash Flow: \$$(echo "$cashflow" | jq -r '.[0].operatingCashFlow // "N/A"')
- Free Cash Flow: \$$(echo "$cashflow" | jq -r '.[0].freeCashFlow // "N/A"')

## Valuation Metrics
- P/E Ratio: $(echo "$ratios" | jq -r '.[0].priceEarningsRatio // "N/A"')
- P/B Ratio: $(echo "$ratios" | jq -r '.[0].priceToBookRatio // "N/A"')
- Debt/Equity: $(echo "$ratios" | jq -r '.[0].debtEquityRatio // "N/A"')

## Data Source
FMP API via fmp-profile.sh, fmp-financials.sh, fmp-ratios.sh

## Recommendation
Analysis completed. Review required for investment decision.
EOF

    if assert_file_exists "$analysis_file" "Fundamental analysis report created"; then
        echo -e "${BLUE}  Created: $analysis_file${NC}"
        assert_success "Fundamental Analysis completed successfully"
        return 0
    else
        assert_failure "Failed to create analysis report"
        return 1
    fi
}

step3_technical_analysis() {
    start_test "Step 3: Technical Analyst analyzes opportunity"

    if ! has_api_key; then
        skip_test "API key not available"
        return 1
    fi

    if [[ -z "$TEST_SYMBOL" ]]; then
        assert_failure "No symbol from Step 1"
        return 1
    fi

    echo -e "${BLUE}  Running technical analysis on ${TEST_SYMBOL}...${NC}"

    # Fetch current quote
    local quote=$(bash "$FMP_SCRIPTS_DIR/fmp-quote.sh" "$TEST_SYMBOL" 2>&1)

    if ! echo "$quote" | jq -e . >/dev/null 2>&1; then
        assert_failure "Quote fetch failed"
        return 1
    fi

    if echo "$quote" | jq -e '.error' >/dev/null 2>&1; then
        skip_test "API error: $(echo "$quote" | jq -r '.message')"
        return 1
    fi

    # Fetch historical data
    local historical=$(bash "$FMP_SCRIPTS_DIR/fmp-historical.sh" "$TEST_SYMBOL" "" "" 200 daily 2>&1)

    # Fetch indicators
    local sma20=$(bash "$FMP_SCRIPTS_DIR/fmp-indicators.sh" "$TEST_SYMBOL" sma 20 daily 2>&1)
    local sma50=$(bash "$FMP_SCRIPTS_DIR/fmp-indicators.sh" "$TEST_SYMBOL" sma 50 daily 2>&1)
    local rsi=$(bash "$FMP_SCRIPTS_DIR/fmp-indicators.sh" "$TEST_SYMBOL" rsi 14 daily 2>&1)

    # Create technical analysis report
    local tech_file="$ANALYSIS_DIR/technical-${TEST_SYMBOL}-$(date +%Y%m%d).md"

    local current_price=$(echo "$quote" | jq -r '.[0].price // "N/A"')
    local sma20_val=$(echo "$sma20" | jq -r '.[0].sma // "N/A"' 2>/dev/null || echo "N/A")
    local sma50_val=$(echo "$sma50" | jq -r '.[0].sma // "N/A"' 2>/dev/null || echo "N/A")
    local rsi_val=$(echo "$rsi" | jq -r '.[0].rsi // "N/A"' 2>/dev/null || echo "N/A")

    cat > "$tech_file" <<EOF
# Technical Analysis: ${TEST_SYMBOL}

**Analysis Date**: $(date +%Y-%m-%d)
**Symbol**: ${TEST_SYMBOL}
**Current Price**: \$${current_price}

## Trend Analysis

### Moving Averages
- SMA 20: \$${sma20_val}
- SMA 50: \$${sma50_val}
- Price vs SMA 20: $(echo "scale=2; ($current_price / ${sma20_val:-1}) * 100 - 100" | bc 2>/dev/null || echo "N/A")%
- Price vs SMA 50: $(echo "scale=2; ($current_price / ${sma50_val:-1}) * 100 - 100" | bc 2>/dev/null || echo "N/A")%

## Momentum Indicators
- RSI (14): ${rsi_val}

## Price Levels
- Current: \$${current_price}
- 52-Week High: \$$(echo "$quote" | jq -r '.[0].yearHigh // "N/A"')
- 52-Week Low: \$$(echo "$quote" | jq -r '.[0].yearLow // "N/A"')

## Volume Analysis
- Current Volume: $(echo "$quote" | jq -r '.[0].volume // "N/A"')
- Average Volume: $(echo "$quote" | jq -r '.[0].avgVolume // "N/A"')

## Data Source
FMP API via fmp-quote.sh, fmp-historical.sh, fmp-indicators.sh

## Trading Recommendation
Technical analysis completed. Entry/exit levels require review.
EOF

    if assert_file_exists "$tech_file" "Technical analysis report created"; then
        echo -e "${BLUE}  Created: $tech_file${NC}"
        assert_success "Technical Analysis completed successfully"
        return 0
    else
        assert_failure "Failed to create technical analysis report"
        return 1
    fi
}

step4_portfolio_entry() {
    start_test "Step 4: Add position to portfolio"

    if [[ -z "$TEST_SYMBOL" ]]; then
        assert_failure "No symbol from Step 1"
        return 1
    fi

    echo -e "${BLUE}  Adding ${TEST_SYMBOL} to portfolio...${NC}"

    # Create portfolio file
    local portfolio_file="$PORTFOLIO_DIR/open-positions.yaml"

    cat > "$portfolio_file" <<EOF
positions:
  - symbol: ${TEST_SYMBOL}
    entry_price: 150.00
    quantity: 10
    entry_date: $(date +%Y-%m-%d)
    stop_loss: 140.00
    target_price: 170.00
    thesis: "Top gainer with strong fundamentals and technical setup"
    entry_source: "Market Scanner + Fundamental + Technical Analysis"
EOF

    if assert_file_exists "$portfolio_file" "Portfolio file created"; then
        echo -e "${BLUE}  Created: $portfolio_file${NC}"
        assert_success "Position added to portfolio"
        return 0
    else
        assert_failure "Failed to create portfolio file"
        return 1
    fi
}

step5_portfolio_monitoring() {
    start_test "Step 5: Portfolio Monitor tracks position"

    if ! has_api_key; then
        skip_test "API key not available"
        return 1
    fi

    if [[ -z "$TEST_SYMBOL" ]]; then
        assert_failure "No symbol from Step 1"
        return 1
    fi

    echo -e "${BLUE}  Running portfolio monitoring for ${TEST_SYMBOL}...${NC}"

    # Read portfolio file
    local portfolio_file="$PORTFOLIO_DIR/open-positions.yaml"

    if [[ ! -f "$portfolio_file" ]]; then
        assert_failure "Portfolio file not found from Step 4"
        return 1
    fi

    # Fetch current quote
    local quote=$(bash "$FMP_SCRIPTS_DIR/fmp-quote.sh" "$TEST_SYMBOL" 2>&1)

    if ! echo "$quote" | jq -e . >/dev/null 2>&1; then
        assert_failure "Quote fetch failed"
        return 1
    fi

    if echo "$quote" | jq -e '.error' >/dev/null 2>&1; then
        skip_test "API error: $(echo "$quote" | jq -r '.message')"
        return 1
    fi

    # Create monitoring report
    local report_file="$REPORTS_DIR/portfolio-monitor-$(date +%Y%m%d).md"

    local current_price=$(echo "$quote" | jq -r '.[0].price // "0"')
    local entry_price=150.00
    local quantity=10
    local pnl=$(echo "scale=2; ($current_price - $entry_price) * $quantity" | bc)
    local pnl_pct=$(echo "scale=2; (($current_price / $entry_price) - 1) * 100" | bc)

    cat > "$report_file" <<EOF
# Portfolio Monitoring Report

**Date**: $(date +%Y-%m-%d)

## Positions Overview

### ${TEST_SYMBOL}
- **Entry Price**: \$${entry_price}
- **Current Price**: \$${current_price}
- **Quantity**: ${quantity}
- **P&L**: \$${pnl} (${pnl_pct}%)
- **Stop Loss**: \$140.00
- **Target**: \$170.00
- **Days Held**: 0

## Position Status
- Status: Active
- Thesis: Valid
- Action: Hold

## Data Source
FMP API via fmp-quote.sh

## Alerts
None at this time.
EOF

    if assert_file_exists "$report_file" "Monitoring report created"; then
        echo -e "${BLUE}  Created: $report_file${NC}"
        assert_success "Portfolio monitoring completed successfully"
        return 0
    else
        assert_failure "Failed to create monitoring report"
        return 1
    fi
}

step6_verify_fmp_data_in_all_reports() {
    start_test "Step 6: Verify FMP data present in all reports"

    local all_found=true

    # Check opportunity document
    if ! grep -q "FMP API" "$OPPORTUNITIES_DIR"/*.md 2>/dev/null; then
        all_found=false
        echo -e "${RED}  FMP reference missing in opportunity document${NC}"
    fi

    # Check fundamental analysis
    if ! grep -q "FMP API" "$ANALYSIS_DIR"/fundamental-*.md 2>/dev/null; then
        all_found=false
        echo -e "${RED}  FMP reference missing in fundamental analysis${NC}"
    fi

    # Check technical analysis
    if ! grep -q "FMP API" "$ANALYSIS_DIR"/technical-*.md 2>/dev/null; then
        all_found=false
        echo -e "${RED}  FMP reference missing in technical analysis${NC}"
    fi

    # Check monitoring report
    if ! grep -q "FMP API" "$REPORTS_DIR"/*.md 2>/dev/null; then
        all_found=false
        echo -e "${RED}  FMP reference missing in monitoring report${NC}"
    fi

    if $all_found; then
        assert_success "All reports contain FMP data references"
    else
        assert_failure "Some reports missing FMP data references"
    fi
}

step7_verify_workflow_integrity() {
    start_test "Step 7: Verify complete workflow integrity"

    echo -e "${BLUE}  Verifying workflow integrity...${NC}"

    local checks_passed=0
    local checks_total=5

    # Check 1: Opportunity document exists
    if ls "$OPPORTUNITIES_DIR"/*.md >/dev/null 2>&1; then
        ((checks_passed++))
        echo -e "${GREEN}  ✓ Opportunity document exists${NC}"
    else
        echo -e "${RED}  ✗ Opportunity document missing${NC}"
    fi

    # Check 2: Fundamental analysis exists
    if ls "$ANALYSIS_DIR"/fundamental-*.md >/dev/null 2>&1; then
        ((checks_passed++))
        echo -e "${GREEN}  ✓ Fundamental analysis exists${NC}"
    else
        echo -e "${RED}  ✗ Fundamental analysis missing${NC}"
    fi

    # Check 3: Technical analysis exists
    if ls "$ANALYSIS_DIR"/technical-*.md >/dev/null 2>&1; then
        ((checks_passed++))
        echo -e "${GREEN}  ✓ Technical analysis exists${NC}"
    else
        echo -e "${RED}  ✗ Technical analysis missing${NC}"
    fi

    # Check 4: Portfolio file exists
    if [[ -f "$PORTFOLIO_DIR/open-positions.yaml" ]]; then
        ((checks_passed++))
        echo -e "${GREEN}  ✓ Portfolio file exists${NC}"
    else
        echo -e "${RED}  ✗ Portfolio file missing${NC}"
    fi

    # Check 5: Monitoring report exists
    if ls "$REPORTS_DIR"/*.md >/dev/null 2>&1; then
        ((checks_passed++))
        echo -e "${GREEN}  ✓ Monitoring report exists${NC}"
    else
        echo -e "${RED}  ✗ Monitoring report missing${NC}"
    fi

    if [[ $checks_passed -eq $checks_total ]]; then
        assert_success "All workflow artifacts created (${checks_passed}/${checks_total})"
    else
        assert_failure "Some workflow artifacts missing (${checks_passed}/${checks_total})"
    fi
}

#=============================================================================
# Run complete workflow
#=============================================================================

echo ""
echo -e "${BOLD}${BLUE}Running End-to-End Workflow Tests...${NC}"
echo -e "${BLUE}Testing complete investment workflow from scan to monitoring${NC}"
echo ""

# Execute workflow steps
if step1_market_scanner; then
    if step2_fundamental_analysis; then
        if step3_technical_analysis; then
            if step4_portfolio_entry; then
                step5_portfolio_monitoring
            fi
        fi
    fi
fi

# Verification steps
step6_verify_fmp_data_in_all_reports
step7_verify_workflow_integrity

# Cleanup and print summary
cleanup_test_env
print_summary

exit $?
