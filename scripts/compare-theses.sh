#!/usr/bin/env bash
# compare-theses.sh - Compare multiple investment theses side-by-side
# Usage: ./compare-theses.sh THESIS1.md THESIS2.md [THESIS3.md ...]

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
    cat <<EOF
Usage: $(basename "$0") THESIS1.md THESIS2.md [THESIS3.md ...]

Compare multiple investment theses side-by-side to help prioritize opportunities.

Arguments:
    THESIS_FILE     Path to thesis markdown files (2-5 theses)

Examples:
    # Compare two theses
    $(basename "$0") apex-os/analysis/2024-11-16-AAPL/investment-thesis.md \\
                     apex-os/analysis/2024-11-16-MSFT/investment-thesis.md

    # Compare three theses
    $(basename "$0") AAPL-thesis.md MSFT-thesis.md NVDA-thesis.md

Output:
    - Side-by-side comparison table
    - Ranked by expected value
    - Recommendation on which to prioritize

EOF
    exit 1
}

# Check arguments
if [[ $# -lt 2 ]]; then
    echo "Error: Need at least 2 thesis files to compare"
    usage
fi

if [[ $# -gt 5 ]]; then
    echo "Error: Maximum 5 thesis files can be compared at once"
    usage
fi

# Extract metric from thesis file
extract_metric() {
    local file="$1"
    local pattern="$2"
    local default="${3:-N/A}"

    if [[ ! -f "$file" ]]; then
        echo "$default"
        return
    fi

    local value=$(grep -m 1 "$pattern" "$file" | grep -oP '\d+\.?\d*' | head -1 || echo "")

    if [[ -z "$value" ]]; then
        echo "$default"
    else
        echo "$value"
    fi
}

# Extract text field from thesis
extract_field() {
    local file="$1"
    local pattern="$2"
    local default="${3:-N/A}"

    if [[ ! -f "$file" ]]; then
        echo "$default"
        return
    fi

    local value=$(grep -m 1 "$pattern" "$file" | sed -E 's/.*: //' | sed 's/\*\*//g' | head -c 30 || echo "")

    if [[ -z "$value" ]]; then
        echo "$default"
    else
        echo "$value"
    fi
}

# Extract ticker from filename or content
extract_ticker() {
    local file="$1"

    # Try to extract from filename pattern YYYY-MM-DD-TICKER
    local ticker=$(basename "$file" | grep -oP '\d{4}-\d{2}-\d{2}-[A-Z]+' | grep -oP '[A-Z]+$' || echo "")

    # If not found, try to extract from file content
    if [[ -z "$ticker" ]]; then
        ticker=$(grep -m 1 "Investment Thesis:" "$file" | grep -oP '[A-Z]{1,5}' | head -1 || echo "UNKNOWN")
    fi

    echo "$ticker"
}

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           Investment Thesis Comparison Tool                   ║${NC}"
echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Arrays to store data
declare -a tickers
declare -a files
declare -a thesis_scores
declare -a conviction_scores
declare -a expected_values
declare -a fa_scores
declare -a ta_scores
declare -a rr_ratios
declare -a bull_probs
declare -a base_probs
declare -a bear_probs
declare -a gate1_results

# Extract data from each thesis
for thesis_file in "$@"; do
    if [[ ! -f "$thesis_file" ]]; then
        echo -e "${RED}Warning: File not found: $thesis_file${NC}"
        continue
    fi

    ticker=$(extract_ticker "$thesis_file")
    tickers+=("$ticker")
    files+=("$thesis_file")

    # Extract scores
    thesis_score=$(extract_metric "$thesis_file" "TOTAL THESIS QUALITY SCORE" "0")
    conviction_score=$(extract_metric "$thesis_file" "TOTAL CONVICTION SCORE" "0")
    ev=$(extract_metric "$thesis_file" "Expected Value \(EV\):" "0")
    fa=$(extract_metric "$thesis_file" "Fundamental Quality Score" "0")
    ta=$(extract_metric "$thesis_file" "Technical Setup Score" "0")
    rr=$(extract_metric "$thesis_file" "Risk/Reward Ratio" "0")

    # Extract probabilities
    bull=$(extract_metric "$thesis_file" "Bull Case.*probability" "0")
    base=$(extract_metric "$thesis_file" "Base Case.*probability" "0")
    bear=$(extract_metric "$thesis_file" "Bear Case.*probability" "0")

    # Extract gate 1 result
    gate1=$(extract_field "$thesis_file" "Gate 1 Result:" "UNKNOWN")

    thesis_scores+=("$thesis_score")
    conviction_scores+=("$conviction_score")
    expected_values+=("$ev")
    fa_scores+=("$fa")
    ta_scores+=("$ta")
    rr_ratios+=("$rr")
    bull_probs+=("$bull")
    base_probs+=("$base")
    bear_probs+=("$bear")
    gate1_results+=("$gate1")
done

# Print comparison table
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}                    THESIS COMPARISON                          ${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Header
printf "%-12s" "Metric"
for ticker in "${tickers[@]}"; do
    printf "│ %-10s" "$ticker"
done
echo ""
echo "────────────┼$(printf '─%.0s' {1..70})"

# Expected Value (most important)
printf "%-12s" "EV %"
for i in "${!expected_values[@]}"; do
    ev="${expected_values[$i]}"
    if (( $(echo "$ev >= 20" | bc -l 2>/dev/null || echo 0) )); then
        printf "│ ${GREEN}%-10s${NC}" "+${ev}%"
    elif (( $(echo "$ev >= 15" | bc -l 2>/dev/null || echo 0) )); then
        printf "│ %-10s" "+${ev}%"
    else
        printf "│ ${RED}%-10s${NC}" "+${ev}%"
    fi
done
echo ""

# Thesis Quality Score
printf "%-12s" "Thesis /10"
for i in "${!thesis_scores[@]}"; do
    score="${thesis_scores[$i]}"
    if (( $(echo "$score >= 7" | bc -l 2>/dev/null || echo 0) )); then
        printf "│ ${GREEN}%-10s${NC}" "${score}/10"
    elif (( $(echo "$score >= 5" | bc -l 2>/dev/null || echo 0) )); then
        printf "│ ${YELLOW}%-10s${NC}" "${score}/10"
    else
        printf "│ ${RED}%-10s${NC}" "${score}/10"
    fi
done
echo ""

# Conviction Score
printf "%-12s" "Conviction"
for i in "${!conviction_scores[@]}"; do
    score="${conviction_scores[$i]}"
    if (( $(echo "$score >= 7" | bc -l 2>/dev/null || echo 0) )); then
        printf "│ ${GREEN}%-10s${NC}" "${score}/10"
    elif (( $(echo "$score >= 5" | bc -l 2>/dev/null || echo 0) )); then
        printf "│ %-10s" "${score}/10"
    else
        printf "│ ${RED}%-10s${NC}" "${score}/10"
    fi
done
echo ""

echo "────────────┼$(printf '─%.0s' {1..70})"

# Fundamental Score
printf "%-12s" "FA Score"
for i in "${!fa_scores[@]}"; do
    printf "│ %-10s" "${fa_scores[$i]}/10"
done
echo ""

# Technical Score
printf "%-12s" "TA Score"
for i in "${!ta_scores[@]}"; do
    printf "│ %-10s" "${ta_scores[$i]}/10"
done
echo ""

# Risk/Reward
printf "%-12s" "R:R"
for i in "${!rr_ratios[@]}"; do
    rr="${rr_ratios[$i]}"
    if (( $(echo "$rr >= 3" | bc -l 2>/dev/null || echo 0) )); then
        printf "│ ${GREEN}%-10s${NC}" "${rr}:1"
    elif (( $(echo "$rr >= 2" | bc -l 2>/dev/null || echo 0) )); then
        printf "│ %-10s" "${rr}:1"
    else
        printf "│ ${RED}%-10s${NC}" "${rr}:1"
    fi
done
echo ""

echo "────────────┼$(printf '─%.0s' {1..70})"

# Probabilities
printf "%-12s" "Bull %"
for i in "${!bull_probs[@]}"; do
    printf "│ %-10s" "${bull_probs[$i]}%"
done
echo ""

printf "%-12s" "Base %"
for i in "${!base_probs[@]}"; do
    printf "│ %-10s" "${base_probs[$i]}%"
done
echo ""

printf "%-12s" "Bear %"
for i in "${!bear_probs[@]}"; do
    printf "│ %-10s" "${bear_probs[$i]}%"
done
echo ""

echo "────────────┼$(printf '─%.0s' {1..70})"

# Gate 1 Result
printf "%-12s" "Gate 1"
for i in "${!gate1_results[@]}"; do
    result="${gate1_results[$i]}"
    if [[ "$result" == *"PASS"* ]]; then
        printf "│ ${GREEN}%-10s${NC}" "PASS"
    else
        printf "│ ${RED}%-10s${NC}" "FAIL"
    fi
done
echo ""

echo ""
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"

# Rank by Expected Value
echo ""
echo -e "${BLUE}RANKING (by Expected Value):${NC}"
echo ""

# Create array of indices sorted by EV
indices=($(for i in "${!expected_values[@]}"; do echo "$i ${expected_values[$i]}"; done | sort -k2 -rn | cut -d' ' -f1))

rank=1
for idx in "${indices[@]}"; do
    ticker="${tickers[$idx]}"
    ev="${expected_values[$idx]}"
    thesis="${thesis_scores[$idx]}"
    conviction="${conviction_scores[$idx]}"
    gate1="${gate1_results[$idx]}"

    # Determine if this is tradeable
    if [[ "$gate1" == *"PASS"* ]] && (( $(echo "$ev >= 10" | bc -l 2>/dev/null || echo 0) )); then
        status="${GREEN}✓ TRADE${NC}"
    elif [[ "$gate1" == *"PASS"* ]]; then
        status="${YELLOW}⚠ WEAK${NC}"
    else
        status="${RED}✗ PASS${NC}"
    fi

    echo -e "${rank}. ${BLUE}${ticker}${NC}: EV +${ev}% | Thesis: ${thesis}/10 | Conviction: ${conviction}/10 | ${status}"
    rank=$((rank + 1))
done

echo ""
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Recommendation
best_idx="${indices[0]}"
best_ticker="${tickers[$best_idx]}"
best_ev="${expected_values[$best_idx]}"
best_thesis="${thesis_scores[$best_idx]}"
best_conviction="${conviction_scores[$best_idx]}"
best_gate1="${gate1_results[$best_idx]}"

echo -e "${GREEN}RECOMMENDATION:${NC}"
echo ""

if [[ "$best_gate1" == *"PASS"* ]] && (( $(echo "$best_ev >= 15" | bc -l 2>/dev/null || echo 0) )); then
    echo -e "✓ ${GREEN}Prioritize ${best_ticker}${NC} - Strong opportunity (EV: +${best_ev}%)"
    echo "  - Thesis quality: ${best_thesis}/10"
    echo "  - Conviction: ${best_conviction}/10"
    echo "  - Gate 1: PASSED"
    echo ""
    echo "  Next steps:"
    echo "  1. Proceed to position planning with risk-manager"
    echo "  2. Consider other passing theses if capital allows"
elif [[ "$best_gate1" == *"PASS"* ]]; then
    echo -e "⚠  ${YELLOW}${best_ticker} passes Gate 1 but has moderate EV (+${best_ev}%)${NC}"
    echo "  - Consider reducing position size"
    echo "  - Or wait for better opportunities"
else
    echo -e "✗ ${RED}No theses passed Gate 1${NC}"
    echo "  - Review analysis quality"
    echo "  - Consider rescanning for better opportunities"
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
