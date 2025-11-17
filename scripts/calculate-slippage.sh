#!/usr/bin/env bash
# calculate-slippage.sh - Calculate execution slippage vs multiple benchmarks
# Usage: ./calculate-slippage.sh TICKER PLANNED_PRICE ARRIVAL_PRICE FILL_PRICE VWAP SHARES

set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Validate arguments
if [[ $# -ne 6 ]]; then
    echo "Usage: $0 TICKER PLANNED_PRICE ARRIVAL_PRICE FILL_PRICE VWAP SHARES"
    echo ""
    echo "Example: $0 AAPL 150.00 150.10 150.15 150.08 500"
    exit 1
fi

TICKER=$1
PLANNED=$2
ARRIVAL=$3
FILL=$4
VWAP=$5
SHARES=$6

echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}    Slippage Analysis: $TICKER${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo ""

# Display input prices
echo "Benchmark Prices:"
echo "  Planned Entry: \$$PLANNED"
echo "  Arrival Price: \$$ARRIVAL (at order placement)"
echo "  Fill Price: \$$FILL"
echo "  VWAP: \$$VWAP"
echo "  Shares: $SHARES"
echo ""

# Calculate slippage vs planned entry
slippage_plan=$(echo "scale=4; $FILL - $PLANNED" | bc -l)
slippage_plan_pct=$(echo "scale=4; (($FILL - $PLANNED) / $PLANNED) * 100" | bc -l)
slippage_plan_cost=$(echo "scale=2; $slippage_plan * $SHARES" | bc -l)

# Calculate slippage vs arrival
slippage_arrival=$(echo "scale=4; $FILL - $ARRIVAL" | bc -l)
slippage_arrival_pct=$(echo "scale=4; (($FILL - $ARRIVAL) / $ARRIVAL) * 100" | bc -l)

# Calculate slippage vs VWAP
slippage_vwap=$(echo "scale=4; $FILL - $VWAP" | bc -l)
slippage_vwap_pct=$(echo "scale=4; (($FILL - $VWAP) / $VWAP) * 100" | bc -l)

# Determine grades
grade_plan="F"
if (( $(echo "$slippage_plan_pct <= 0" | bc -l) )); then
    grade_plan="A"
    color_plan=$GREEN
elif (( $(echo "$slippage_plan_pct < 0.1" | bc -l) )); then
    grade_plan="A"
    color_plan=$GREEN
elif (( $(echo "$slippage_plan_pct < 0.3" | bc -l) )); then
    grade_plan="B"
    color_plan=$GREEN
elif (( $(echo "$slippage_plan_pct < 0.5" | bc -l) )); then
    grade_plan="C"
    color_plan=$YELLOW
elif (( $(echo "$slippage_plan_pct < 1.0" | bc -l) )); then
    grade_plan="D"
    color_plan=$YELLOW
else
    grade_plan="F"
    color_plan=$RED
fi

grade_arrival="F"
if (( $(echo "$slippage_arrival_pct <= 0" | bc -l) )); then
    grade_arrival="A"
    color_arrival=$GREEN
elif (( $(echo "$slippage_arrival_pct < 0.1" | bc -l) )); then
    grade_arrival="A"
    color_arrival=$GREEN
elif (( $(echo "$slippage_arrival_pct < 0.3" | bc -l) )); then
    grade_arrival="B"
    color_arrival=$GREEN
elif (( $(echo "$slippage_arrival_pct < 0.5" | bc -l) )); then
    grade_arrival="C"
    color_arrival=$YELLOW
elif (( $(echo "$slippage_arrival_pct < 1.0" | bc -l) )); then
    grade_arrival="D"
    color_arrival=$YELLOW
else
    grade_arrival="F"
    color_arrival=$RED
fi

grade_vwap="F"
if (( $(echo "$slippage_vwap_pct <= 0" | bc -l) )); then
    grade_vwap="A"
    color_vwap=$GREEN
elif (( $(echo "$slippage_vwap_pct < 0.1" | bc -l) )); then
    grade_vwap="A"
    color_vwap=$GREEN
elif (( $(echo "$slippage_vwap_pct < 0.3" | bc -l) )); then
    grade_vwap="B"
    color_vwap=$GREEN
elif (( $(echo "$slippage_vwap_pct < 0.5" | bc -l) )); then
    grade_vwap="C"
    color_vwap=$YELLOW
elif (( $(echo "$slippage_vwap_pct < 1.0" | bc -l) )); then
    grade_vwap="D"
    color_vwap=$YELLOW
else
    grade_vwap="F"
    color_vwap=$RED
fi

# Display results
echo "═══════════════════════════════════════"
echo ""
echo "Slippage Results:"
echo ""

echo -e "1. vs Planned Entry (\$$PLANNED):"
echo -e "   Slippage: \$$slippage_plan (${slippage_plan_pct}%)"
echo -e "   Cost: \$$slippage_plan_cost"
echo -e "   Grade: ${color_plan}$grade_plan${NC}"
echo ""

echo -e "2. vs Arrival Price (\$$ARRIVAL):"
echo -e "   Slippage: \$$slippage_arrival (${slippage_arrival_pct}%)"
if (( $(echo "$slippage_arrival < 0" | bc -l) )); then
    echo -e "   Interpretation: ${GREEN}Improved${NC} from order placement"
elif (( $(echo "$slippage_arrival > 0" | bc -l) )); then
    echo -e "   Interpretation: ${RED}Worsened${NC} from order placement"
else
    echo -e "   Interpretation: Same as order placement"
fi
echo -e "   Grade: ${color_arrival}$grade_arrival${NC}"
echo ""

echo -e "3. vs VWAP (\$$VWAP):"
echo -e "   Slippage: \$$slippage_vwap (${slippage_vwap_pct}%)"
if (( $(echo "$slippage_vwap < 0" | bc -l) )); then
    echo -e "   vs Benchmark: ${GREEN}Beat VWAP${NC}"
elif (( $(echo "$slippage_vwap > 0" | bc -l) )); then
    echo -e "   vs Benchmark: ${RED}Missed VWAP${NC}"
else
    echo -e "   vs Benchmark: Met VWAP exactly"
fi
echo -e "   Grade: ${color_vwap}$grade_vwap${NC}"
echo ""

# Overall assessment
echo "═══════════════════════════════════════"
echo ""

# Average grade (simple: count A=4, B=3, C=2, D=1, F=0)
declare -A grade_values=( ["A"]=4 ["B"]=3 ["C"]=2 ["D"]=1 ["F"]=0 )
avg_score=$(echo "scale=2; (${grade_values[$grade_plan]} + ${grade_values[$grade_arrival]} + ${grade_values[$grade_vwap]}) / 3" | bc -l)

overall="Very Poor"
overall_color=$RED
if (( $(echo "$avg_score >= 3.5" | bc -l) )); then
    overall="Excellent"
    overall_color=$GREEN
elif (( $(echo "$avg_score >= 2.5" | bc -l) )); then
    overall="Good"
    overall_color=$GREEN
elif (( $(echo "$avg_score >= 1.5" | bc -l) )); then
    overall="Fair"
    overall_color=$YELLOW
elif (( $(echo "$avg_score >= 0.5" | bc -l) )); then
    overall="Poor"
    overall_color=$YELLOW
fi

echo -e "Overall Slippage Assessment: ${overall_color}$overall${NC}"
echo ""

# Cost analysis
total_cost=$(echo "scale=2; $slippage_plan_cost" | bc -l)
annual_impact=$(echo "scale=0; $total_cost * 50" | bc -l) # Assume 50 trades/year

echo "Cost Impact:"
echo "  This trade: \$$total_cost"
echo "  Annual impact (50 trades): ~\$$annual_impact"
echo ""

# Recommendations
echo "Recommendations:"
if [[ "$grade_plan" == "F" ]] || [[ "$grade_plan" == "D" ]]; then
    echo "  - Slippage vs plan is high - consider more patience with limit orders"
fi
if [[ "$grade_arrival" == "F" ]] || [[ "$grade_arrival" == "D" ]]; then
    echo "  - Execution worsened from order time - avoid chasing, use limits"
fi
if [[ "$grade_vwap" == "F" ]] || [[ "$grade_vwap" == "D" ]]; then
    echo "  - Missed VWAP benchmark - review execution timing"
    echo "  - Consider executing during optimal windows (10-11 AM, 2-3 PM)"
fi
if [[ "$overall" == "Excellent" ]] || [[ "$overall" == "Good" ]]; then
    echo "  - Execution quality is good - maintain current practices"
fi
echo ""

echo "═══════════════════════════════════════"
echo ""

# Output JSON for programmatic use
cat <<EOF
{
  "ticker": "$TICKER",
  "benchmarks": {
    "planned": $PLANNED,
    "arrival": $ARRIVAL,
    "fill": $FILL,
    "vwap": $VWAP
  },
  "slippage": {
    "vs_plan": {
      "dollars": $slippage_plan,
      "percent": $slippage_plan_pct,
      "cost": $slippage_plan_cost,
      "grade": "$grade_plan"
    },
    "vs_arrival": {
      "dollars": $slippage_arrival,
      "percent": $slippage_arrival_pct,
      "grade": "$grade_arrival"
    },
    "vs_vwap": {
      "dollars": $slippage_vwap,
      "percent": $slippage_vwap_pct,
      "grade": "$grade_vwap"
    }
  },
  "overall_assessment": "$overall",
  "total_cost": $total_cost,
  "annual_impact_estimate": $annual_impact
}
EOF
