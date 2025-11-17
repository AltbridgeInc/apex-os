#!/usr/bin/env bash
# detect-market-regime.sh - Classify current market regime
# Usage: ./detect-market-regime.sh

set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}    Market Regime Detection${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo ""

# Fetch SPY data
echo "Fetching SPY data..."
spy_result=$(bash "$SCRIPT_DIR/fmp-api/fmp-fetch.sh" quotes quote SPY 2>/dev/null || echo '{"success": false}')

if echo "$spy_result" | jq -e '.success == false' > /dev/null 2>&1; then
    echo -e "${RED}ERROR: Could not fetch SPY data${NC}"
    echo "Using defaults (assume NORMAL_BULL)"
    spy_price=450
    spy_ma200=445
    spy_vs_ma=1.12
else
    spy_file=$(echo "$spy_result" | jq -r '.file // .filepath')
    spy_data=$(cat "$spy_file")

    spy_price=$(echo "$spy_data" | jq -r '.price')
    spy_ma200=$(echo "$spy_data" | jq -r '.priceAvg200 // 0')

    if (( $(echo "$spy_ma200 > 0" | bc -l) )); then
        spy_vs_ma=$(echo "scale=2; (($spy_price - $spy_ma200) / $spy_ma200) * 100" | bc -l)
    else
        spy_vs_ma=0
    fi
fi

# Fetch VIX (Note: VIX index not available via FMP API)
echo "Checking VIX data..."
# VIX not available through FMP - using default value
vix_result='{"success": false}'  # VIX index not supported by FMP

if echo "$vix_result" | jq -e '.success == false' > /dev/null 2>&1; then
    echo -e "${YELLOW}Warning: Could not fetch VIX, using default (20)${NC}"
    vix=20
else
    vix_file=$(echo "$vix_result" | jq -r '.filepath')
    vix_data=$(cat "$vix_file")
    vix=$(echo "$vix_data" | jq -r '.[0].price // 20')
fi

# Display market data
echo ""
echo "Market Data:"
echo "  SPY Price: \$$spy_price"
echo "  SPY 200-MA: \$$spy_ma200"
echo "  SPY vs 200-MA: ${spy_vs_ma}%"
echo "  VIX: $vix"
echo ""

# Classify market regime
echo "═══════════════════════════════════════"
echo ""

if (( $(echo "$spy_vs_ma > 5 && $vix < 20" | bc -l) )); then
    REGIME="STRONG_BULL"
    MAX_RISK=2.5
    REGIME_ADJ=0.5
    COLOR=$GREEN
    DESCRIPTION="Strong uptrend with low fear"
    RECOMMENDATION="Maximum position sizes allowed"
elif (( $(echo "$spy_vs_ma > 0 && $vix < 25" | bc -l) )); then
    REGIME="NORMAL_BULL"
    MAX_RISK=2.0
    REGIME_ADJ=0.0
    COLOR=$GREEN
    DESCRIPTION="Normal bullish conditions"
    RECOMMENDATION="Standard position sizes"
elif (( $(echo "$spy_vs_ma < 0 && $spy_vs_ma > -5" | bc -l) )); then
    REGIME="CHOPPY"
    MAX_RISK=1.5
    REGIME_ADJ=-0.3
    COLOR=$YELLOW
    DESCRIPTION="Choppy, uncertain market"
    RECOMMENDATION="Reduce position sizes"
elif (( $(echo "$spy_vs_ma < -5 && $vix < 35" | bc -l) )); then
    REGIME="BEAR"
    MAX_RISK=1.0
    REGIME_ADJ=-0.5
    COLOR=$RED
    DESCRIPTION="Bear market, downtrend"
    RECOMMENDATION="Significantly reduce sizes or stay in cash"
else
    REGIME="CRISIS"
    MAX_RISK=0.5
    REGIME_ADJ=-1.0
    COLOR=$RED
    DESCRIPTION="Crisis mode, extreme volatility"
    RECOMMENDATION="Minimal exposure or cash only"
fi

echo -e "${COLOR}MARKET REGIME: $REGIME${NC}"
echo ""
echo "Description: $DESCRIPTION"
echo "Max Risk Allowed: ${MAX_RISK}%"
echo "Regime Adjustment: ${REGIME_ADJ}%"
echo ""
echo "Recommendation: $RECOMMENDATION"
echo ""

# Portfolio heat limits by regime
echo "Portfolio Heat Limits:"
if [[ "$REGIME" == "STRONG_BULL" ]]; then
    echo "  Maximum total portfolio heat: 10%"
elif [[ "$REGIME" == "NORMAL_BULL" ]]; then
    echo "  Maximum total portfolio heat: 8%"
elif [[ "$REGIME" == "CHOPPY" ]]; then
    echo "  Maximum total portfolio heat: 6%"
elif [[ "$REGIME" == "BEAR" ]]; then
    echo "  Maximum total portfolio heat: 4%"
else
    echo "  Maximum total portfolio heat: 2%"
fi

echo ""
echo "═══════════════════════════════════════"
echo ""

# Output JSON for programmatic use
cat <<EOF
{
  "regime": "$REGIME",
  "max_risk_pct": $MAX_RISK,
  "regime_adjustment": $REGIME_ADJ,
  "spy_price": $spy_price,
  "spy_ma200": $spy_ma200,
  "spy_vs_ma_pct": $spy_vs_ma,
  "vix": $vix,
  "description": "$DESCRIPTION",
  "recommendation": "$RECOMMENDATION"
}
EOF
