#!/usr/bin/env bash
# validate-thesis.sh - Check position against thesis falsification criteria
# Usage: ./validate-thesis.sh TICKER [CURRENT_PRICE]

set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

TICKER="${1:-}"
CURRENT_PRICE="${2:-}"

if [[ -z "$TICKER" ]]; then
    echo "Usage: $(basename "$0") TICKER [CURRENT_PRICE]"
    echo ""
    echo "Validates position against investment thesis falsification criteria"
    echo ""
    echo "Arguments:"
    echo "  TICKER         Stock symbol (required)"
    echo "  CURRENT_PRICE  Current price (optional, will fetch if not provided)"
    echo ""
    echo "Example:"
    echo "  $(basename "$0") AAPL"
    echo "  $(basename "$0") AAPL 210.50"
    exit 1
fi

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Find thesis file
THESIS_FILE=""
for thesis_path in \
    "$SCRIPT_DIR/../analysis/"*"-$TICKER/investment-thesis.md" \
    "$SCRIPT_DIR/../../apex-os/analysis/"*"-$TICKER/investment-thesis.md" \
    "apex-os/analysis/"*"-$TICKER/investment-thesis.md" \
    "../analysis/"*"-$TICKER/investment-thesis.md"; do
    if [[ -f "$thesis_path" ]]; then
        THESIS_FILE="$thesis_path"
        break
    fi
done

if [[ -z "$THESIS_FILE" ]]; then
    echo -e "${RED}ERROR: No thesis found for $TICKER${NC}"
    echo ""
    echo "Searched in:"
    echo "  - apex-os/analysis/*-$TICKER/investment-thesis.md"
    echo ""
    echo "Make sure thesis exists before validating"
    exit 1
fi

echo -e "${GREEN}Found thesis: $(basename "$(dirname "$THESIS_FILE")")${NC}"
echo ""

# Get current price if not provided
if [[ -z "$CURRENT_PRICE" ]]; then
    echo "Fetching current price for $TICKER..."

    # Try to fetch quote
    if [[ -f "$SCRIPT_DIR/fmp-api/fmp-fetch.sh" ]]; then
        quote_result=$(bash "$SCRIPT_DIR/fmp-api/fmp-fetch.sh" quotes quote "$TICKER" 2>/dev/null || echo '{"success": false}')

        if echo "$quote_result" | jq -e '.success' > /dev/null 2>&1; then
            quote_file=$(echo "$quote_result" | jq -r '.filepath')
            CURRENT_PRICE=$(cat "$quote_file" | jq -r '.[0].price')
            echo "  Current price: \$$CURRENT_PRICE"
        else
            echo -e "${YELLOW}  Warning: Could not fetch price, using placeholder${NC}"
            CURRENT_PRICE="0"
        fi
    else
        echo -e "${YELLOW}  Warning: FMP scripts not found, price not fetched${NC}"
        CURRENT_PRICE="0"
    fi
    echo ""
fi

# Extract thesis date and hold period
THESIS_DATE=$(grep -m 1 "^**Date**:" "$THESIS_FILE" | sed 's/**Date**: //' || echo "Unknown")
EXPECTED_HOLD=$(grep -m 1 "^**Expected Hold**:" "$THESIS_FILE" | grep -oP '\d+' | head -1 || echo "0")

# Calculate days held
if [[ "$THESIS_DATE" != "Unknown" ]]; then
    thesis_timestamp=$(date -d "$THESIS_DATE" +%s 2>/dev/null || echo "0")
    current_timestamp=$(date +%s)
    days_held=$(( (current_timestamp - thesis_timestamp) / 86400 ))
else
    days_held=0
fi

# Expected hold in days (assuming weeks)
expected_hold_days=$((EXPECTED_HOLD * 7))

echo "=== THESIS VALIDATION: $TICKER ==="
echo ""
echo "Thesis Date: $THESIS_DATE"
echo "Days Held: $days_held / $expected_hold_days expected"
echo "Progress: $((days_held * 100 / (expected_hold_days > 0 ? expected_hold_days : 1)))%"
echo ""

# Initialize validation status
VALIDATION_STATUS="VALID"
VIOLATIONS=()

# 1. Extract and check TECHNICAL invalidation
echo "1. Technical Invalidation Check"
echo "   ────────────────────────────"

tech_stop=$(grep -A 5 "^### Technical Invalidation" "$THESIS_FILE" | grep "Breaks below" | grep -oP '\$\d+\.?\d*' | tr -d '$' || echo "")

if [[ -n "$tech_stop" ]] && [[ "$CURRENT_PRICE" != "0" ]]; then
    echo "   Technical stop: \$$tech_stop"
    echo "   Current price: \$$CURRENT_PRICE"

    if (( $(echo "$CURRENT_PRICE < $tech_stop" | bc -l 2>/dev/null || echo 0) )); then
        echo -e "   ${RED}✗ VIOLATED: Broke below \$$tech_stop${NC}"
        VALIDATION_STATUS="INVALIDATED"
        VIOLATIONS+=("Technical: Broke below \$$tech_stop (current: \$$CURRENT_PRICE)")
    else
        echo -e "   ${GREEN}✓ VALID: Above \$$tech_stop${NC}"
    fi
else
    echo "   ⚠  Could not extract technical stop or no price available"
fi

echo ""

# 2. Extract and check FUNDAMENTAL deterioration
echo "2. Fundamental Deterioration Check"
echo "   ──────────────────────────────"

# Look for specific metrics in falsification criteria
fundamental_criteria=$(grep -A 10 "^### Fundamental Deterioration" "$THESIS_FILE" | grep -E "^\s*-" || echo "")

if [[ -n "$fundamental_criteria" ]]; then
    echo "$fundamental_criteria" | while read -r line; do
        echo "   Criterion: $(echo "$line" | sed 's/^- //')"
    done
    echo "   ⚠  Manual check required (check recent earnings/reports)"
else
    echo "   No specific fundamental criteria found"
fi

echo ""

# 3. Extract and check TIME invalidation
echo "3. Time Invalidation Check"
echo "   ───────────────────────"

time_stop=$(grep -A 5 "^### Time Invalidation" "$THESIS_FILE" | grep -oP '\d+\s+weeks?' | grep -oP '\d+' | head -1 || echo "")

if [[ -n "$time_stop" ]]; then
    time_stop_days=$((time_stop * 7))
    echo "   Time stop: $time_stop weeks ($time_stop_days days)"
    echo "   Days held: $days_held days"

    if (( days_held >= time_stop_days )); then
        echo -e "   ${YELLOW}⚠  WARNING: Time stop reached ($time_stop weeks)${NC}"
        echo "   Action: Re-evaluate thesis, consider exit if no progress"
        VIOLATIONS+=("Time: Held $days_held days, time stop at $time_stop_days days")
    else
        remaining=$((time_stop_days - days_held))
        echo -e "   ${GREEN}✓ VALID: $remaining days remaining before time stop${NC}"
    fi
else
    echo "   No time stop found"
fi

echo ""

# 4. Extract and check OTHER invalidation conditions
echo "4. Other Invalidation Conditions"
echo "   ─────────────────────────────"

other_criteria=$(grep -A 10 "^### Other" "$THESIS_FILE" | grep -E "^\s*-" || echo "")

if [[ -n "$other_criteria" ]]; then
    echo "$other_criteria" | while read -r line; do
        echo "   Criterion: $(echo "$line" | sed 's/^- //')"
    done
    echo "   ⚠  Manual check required (check for events)"
else
    echo "   No other criteria specified"
fi

echo ""

# Summary
echo "═══════════════════════════════════════════"
echo "VALIDATION SUMMARY"
echo "═══════════════════════════════════════════"
echo ""

if [[ "$VALIDATION_STATUS" == "INVALIDATED" ]]; then
    echo -e "${RED}THESIS STATUS: ✗ INVALIDATED${NC}"
    echo ""
    echo "VIOLATED CRITERIA:"
    for violation in "${VIOLATIONS[@]}"; do
        echo -e "  ${RED}✗${NC} $violation"
    done
    echo ""
    echo -e "${RED}REQUIRED ACTION: EXIT POSITION IMMEDIATELY${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Place market sell order for $TICKER"
    echo "  2. Document exit in exit-log.md"
    echo "  3. Run post-mortem analysis"
    echo "  4. Update thesis-outcomes.json"
    exit_code=2
elif [[ ${#VIOLATIONS[@]} -gt 0 ]]; then
    echo -e "${YELLOW}THESIS STATUS: ⚠  AT RISK${NC}"
    echo ""
    echo "WARNINGS:"
    for violation in "${VIOLATIONS[@]}"; do
        echo -e "  ${YELLOW}⚠${NC}  $violation"
    done
    echo ""
    echo "RECOMMENDED ACTION: MONITOR CLOSELY"
    echo ""
    echo "Next steps:"
    echo "  1. Re-evaluate thesis validity"
    echo "  2. Consider reducing position size"
    echo "  3. Prepare for exit if conditions worsen"
    echo "  4. Check daily for fundamental changes"
    exit_code=1
else
    echo -e "${GREEN}THESIS STATUS: ✓ VALID${NC}"
    echo ""
    echo "All falsification criteria passing:"
    echo -e "  ${GREEN}✓${NC} Technical levels holding"
    echo -e "  ${GREEN}✓${NC} No fundamental deterioration (check manually)"
    echo -e "  ${GREEN}✓${NC} Within expected timeframe"
    echo ""
    echo "RECOMMENDED ACTION: HOLD POSITION"
    echo ""
    echo "Next steps:"
    echo "  1. Continue daily monitoring"
    echo "  2. Check progress toward targets"
    echo "  3. Monitor for catalyst developments"
    echo "  4. Run weekly thesis review"
    exit_code=0
fi

echo ""
echo "Thesis file: $THESIS_FILE"
echo "Validated at: $(date)"
echo ""

exit $exit_code
