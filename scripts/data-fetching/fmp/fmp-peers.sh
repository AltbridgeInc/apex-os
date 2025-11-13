#!/usr/bin/env bash
# fmp-peers.sh - Peer comparison and competitive benchmarking
# Usage: ./fmp-peers.sh SYMBOL --peers=SYM1,SYM2,SYM3 [--mode=MODE]
#   MODE: metrics|compare|full (default: full)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/fmp-common.sh"

# Validate arguments
if [[ $# -lt 1 ]]; then
    format_error "invalid_params" "Usage: fmp-peers.sh SYMBOL --peers=SYM1,SYM2,... [--mode=MODE]
  SYMBOL: Target company to analyze
  --peers: Comma-separated list of peer symbols (required)
  --mode: metrics|compare|full (default: full)

Example:
  fmp-peers.sh CRM --peers=MSFT,ORCL,SAP,ADBE,NOW
  fmp-peers.sh AAPL --peers=MSFT,GOOGL,AMZN --mode=compare"
    exit 1
fi

symbol=$(echo "$1" | tr '[:lower:]' '[:upper:]')
shift

# Parse arguments
peers=""
mode="full"

for arg in "$@"; do
    case "$arg" in
        --peers=*)
            peers="${arg#*=}"
            ;;
        --mode=*)
            mode="${arg#*=}"
            ;;
        *)
            format_error "invalid_params" "Unknown parameter: $arg"
            exit 1
            ;;
    esac
done

# Validate symbol
validate_symbol "$symbol" || exit 1

# Validate peers provided
if [[ -z "$peers" ]]; then
    format_error "invalid_params" "Peer list is required. Use --peers=SYM1,SYM2,..."
    exit 1
fi

# Convert peers to array
IFS=',' read -ra PEER_ARRAY <<< "$peers"

# Validate each peer symbol
for peer in "${PEER_ARRAY[@]}"; do
    peer=$(echo "$peer" | tr -d ' ' | tr '[:lower:]' '[:upper:]')
    validate_symbol "$peer" || exit 1
done

# Create combined symbol list (target + peers)
all_symbols="$symbol"
for peer in "${PEER_ARRAY[@]}"; do
    peer=$(echo "$peer" | tr -d ' ' | tr '[:lower:]' '[:upper:]')
    all_symbols="${all_symbols},${peer}"
done

#############################################################################
# Function: fetch_peer_metrics
# Fetches key metrics for all symbols (target + peers)
#############################################################################
fetch_peer_metrics() {
    local symbols="$1"

    # Fetch quotes (current data)
    local quotes=$(bash "$SCRIPT_DIR/fmp-quote.sh" "$symbols" 2>&1)
    if echo "$quotes" | jq -e '.error' > /dev/null 2>&1; then
        echo "$quotes"
        return 1
    fi

    # Initialize output JSON
    local output='{"symbols": [], "metrics": {}}'

    # Process each symbol
    IFS=',' read -ra SYM_ARRAY <<< "$symbols"
    for sym in "${SYM_ARRAY[@]}"; do
        sym=$(echo "$sym" | tr -d ' ' | tr '[:lower:]' '[:upper:]')

        # Extract quote data for this symbol
        local quote=$(echo "$quotes" | jq ".[] | select(.symbol == \"$sym\")")

        if [[ -z "$quote" || "$quote" == "null" ]]; then
            continue
        fi

        # Extract key metrics from quote
        local market_cap=$(echo "$quote" | jq -r '.marketCap // 0')
        local price=$(echo "$quote" | jq -r '.price // 0')
        local pe=$(echo "$quote" | jq -r '.pe // 0')
        local beta=$(echo "$quote" | jq -r '.beta // 0')
        local eps=$(echo "$quote" | jq -r '.eps // 0')

        # Fetch ratios for this symbol (includes margins)
        local ratios=$(bash "$SCRIPT_DIR/fmp-ratios.sh" "$sym" ratios 1 2>&1)
        local roe=0
        local debt_equity=0
        local current_ratio=0
        local gross_margin=0
        local operating_margin=0
        local net_margin=0

        if ! echo "$ratios" | jq -e '.error' > /dev/null 2>&1; then
            roe=$(echo "$ratios" | jq -r '.[0].returnOnEquity // 0')
            debt_equity=$(echo "$ratios" | jq -r '.[0].debtEquityRatio // 0')
            current_ratio=$(echo "$ratios" | jq -r '.[0].currentRatio // 0')
            gross_margin=$(echo "$ratios" | jq -r '.[0].grossProfitMargin // 0')
            operating_margin=$(echo "$ratios" | jq -r '.[0].operatingProfitMargin // 0')
            net_margin=$(echo "$ratios" | jq -r '.[0].netProfitMargin // 0')
        fi

        # Fetch growth metrics
        local growth_data=$(bash "$SCRIPT_DIR/fmp-ratios.sh" "$sym" growth 1 2>&1)
        local revenue_growth=0

        if ! echo "$growth_data" | jq -e '.error' > /dev/null 2>&1; then
            revenue_growth=$(echo "$growth_data" | jq -r '.[0].revenueGrowth // 0')
        fi

        # Build metrics JSON for this symbol
        local sym_metrics=$(cat <<EOF
{
    "marketCap": $market_cap,
    "price": $price,
    "peRatio": $pe,
    "beta": $beta,
    "eps": $eps,
    "roe": $roe,
    "debtEquity": $debt_equity,
    "currentRatio": $current_ratio,
    "revenueGrowth": $revenue_growth,
    "grossMargin": $gross_margin,
    "operatingMargin": $operating_margin,
    "netMargin": $net_margin
}
EOF
)

        # Add to output
        output=$(echo "$output" | jq ".symbols += [\"$sym\"] | .metrics[\"$sym\"] = $sym_metrics")
    done

    echo "$output"
}

#############################################################################
# Function: calculate_rankings
# Calculates percentile rankings for target vs peers
#############################################################################
calculate_rankings() {
    local data="$1"
    local target="$2"

    # Metrics to rank
    local metrics_list="peRatio roe debtEquity revenueGrowth grossMargin operatingMargin netMargin currentRatio"

    # Initialize rankings JSON
    local rankings="{}"

    for metric in $metrics_list; do
        # Get all values for this metric
        local symbols=$(echo "$data" | jq -r '.symbols[]')
        local values=()
        local target_value=0

        while IFS= read -r sym; do
            local value=$(echo "$data" | jq -r ".metrics[\"$sym\"].$metric")
            if [[ "$sym" == "$target" ]]; then
                target_value=$value
            fi
            values+=("$value")
        done <<< "$symbols"

        # Calculate rank (how many peers are worse)
        local rank=1
        local count=0

        # For metrics where LOWER is better (PE, debtEquity)
        if [[ "$metric" == "peRatio" || "$metric" == "debtEquity" ]]; then
            for val in "${values[@]}"; do
                count=$((count + 1))
                if (( $(echo "$val > $target_value" | bc -l 2>/dev/null || echo 0) )); then
                    rank=$((rank + 1))
                fi
            done
        else
            # For metrics where HIGHER is better (margins, growth, ROE)
            for val in "${values[@]}"; do
                count=$((count + 1))
                if (( $(echo "$val < $target_value" | bc -l 2>/dev/null || echo 0) )); then
                    rank=$((rank + 1))
                fi
            done
        fi

        # Calculate percentile
        local percentile=0
        if [[ $count -gt 0 ]]; then
            percentile=$(echo "scale=0; (($rank - 1) * 100) / $count" | bc 2>/dev/null || echo 0)
        fi

        # Add to rankings
        rankings=$(echo "$rankings" | jq ". + {\"$metric\": {\"rank\": $rank, \"total\": $count, \"percentile\": $percentile}}")
    done

    echo "$rankings"
}

#############################################################################
# Function: generate_markdown_tables
# Creates markdown comparison tables for human readability
#############################################################################
generate_markdown_tables() {
    local data="$1"
    local target="$2"
    local rankings="$3"

    echo ""
    echo "## Peer Comparison: $target"
    echo ""

    # Get list of all symbols
    local symbols=$(echo "$data" | jq -r '.symbols[]')

    # Table 1: Valuation Metrics
    echo "### Valuation Metrics"
    echo ""
    echo "| Symbol | Market Cap (\$B) | Price | P/E Ratio | Rank |"
    echo "|--------|------------------|-------|-----------|------|"

    while IFS= read -r sym; do
        local mkt_cap=$(echo "$data" | jq -r ".metrics[\"$sym\"].marketCap")
        local price=$(echo "$data" | jq -r ".metrics[\"$sym\"].price")
        local pe=$(echo "$data" | jq -r ".metrics[\"$sym\"].peRatio")

        # Convert market cap to billions
        local mkt_cap_b=$(awk "BEGIN {printf \"%.1f\", $mkt_cap / 1000000000}")

        # Get percentile rank for this symbol (only for target)
        local pe_rank=""
        if [[ "$sym" == "$target" ]]; then
            local percentile=$(echo "$rankings" | jq -r '.peRatio.percentile')
            pe_rank="${percentile}th %ile"
        fi

        # Highlight target row
        if [[ "$sym" == "$target" ]]; then
            echo "| **$sym** | **$mkt_cap_b** | **$price** | **$pe** | **$pe_rank** |"
        else
            echo "| $sym | $mkt_cap_b | $price | $pe | |"
        fi
    done <<< "$symbols"

    echo ""

    # Table 2: Profitability Metrics
    echo "### Profitability Metrics"
    echo ""
    echo "| Symbol | ROE | Gross Margin | Operating Margin | Net Margin | Rank |"
    echo "|--------|-----|--------------|------------------|------------|------|"

    while IFS= read -r sym; do
        local roe=$(echo "$data" | jq -r ".metrics[\"$sym\"].roe")
        local gross=$(echo "$data" | jq -r ".metrics[\"$sym\"].grossMargin")
        local operating=$(echo "$data" | jq -r ".metrics[\"$sym\"].operatingMargin")
        local net=$(echo "$data" | jq -r ".metrics[\"$sym\"].netMargin")

        # Convert to percentages
        local roe_pct=$(awk "BEGIN {printf \"%.1f%%\", $roe * 100}")
        local gross_pct=$(awk "BEGIN {printf \"%.1f%%\", $gross * 100}")
        local operating_pct=$(awk "BEGIN {printf \"%.1f%%\", $operating * 100}")
        local net_pct=$(awk "BEGIN {printf \"%.1f%%\", $net * 100}")

        # Get average percentile for profitability (only for target)
        local prof_rank=""
        if [[ "$sym" == "$target" ]]; then
            local roe_p=$(echo "$rankings" | jq -r '.roe.percentile')
            local gross_p=$(echo "$rankings" | jq -r '.grossMargin.percentile')
            local operating_p=$(echo "$rankings" | jq -r '.operatingMargin.percentile')
            local net_p=$(echo "$rankings" | jq -r '.netMargin.percentile')
            local avg_p=$(awk "BEGIN {printf \"%.0f\", ($roe_p + $gross_p + $operating_p + $net_p) / 4}")
            prof_rank="${avg_p}th %ile"
        fi

        # Highlight target row
        if [[ "$sym" == "$target" ]]; then
            echo "| **$sym** | **$roe_pct** | **$gross_pct** | **$operating_pct** | **$net_pct** | **$prof_rank** |"
        else
            echo "| $sym | $roe_pct | $gross_pct | $operating_pct | $net_pct | |"
        fi
    done <<< "$symbols"

    echo ""

    # Table 3: Growth & Financial Health
    echo "### Growth & Financial Health"
    echo ""
    echo "| Symbol | Revenue Growth | Debt/Equity | Current Ratio | Rank |"
    echo "|--------|----------------|-------------|---------------|------|"

    while IFS= read -r sym; do
        local rev_growth=$(echo "$data" | jq -r ".metrics[\"$sym\"].revenueGrowth")
        local debt_eq=$(echo "$data" | jq -r ".metrics[\"$sym\"].debtEquity")
        local current=$(echo "$data" | jq -r ".metrics[\"$sym\"].currentRatio")

        # Convert to percentages
        local rev_growth_pct=$(awk "BEGIN {printf \"%.1f%%\", $rev_growth * 100}")
        local debt_eq_fmt=$(awk "BEGIN {printf \"%.2f\", $debt_eq}")
        local current_fmt=$(awk "BEGIN {printf \"%.2f\", $current}")

        # Get average percentile for growth/health (only for target)
        local health_rank=""
        if [[ "$sym" == "$target" ]]; then
            local rev_p=$(echo "$rankings" | jq -r '.revenueGrowth.percentile')
            local debt_p=$(echo "$rankings" | jq -r '.debtEquity.percentile')
            local current_p=$(echo "$rankings" | jq -r '.currentRatio.percentile')
            local avg_p=$(awk "BEGIN {printf \"%.0f\", ($rev_p + $debt_p + $current_p) / 3}")
            health_rank="${avg_p}th %ile"
        fi

        # Highlight target row
        if [[ "$sym" == "$target" ]]; then
            echo "| **$sym** | **$rev_growth_pct** | **$debt_eq_fmt** | **$current_fmt** | **$health_rank** |"
        else
            echo "| $sym | $rev_growth_pct | $debt_eq_fmt | $current_fmt | |"
        fi
    done <<< "$symbols"

    echo ""

    # Summary Analysis
    echo "### Competitive Positioning"
    echo ""

    # Identify strengths (>75th percentile)
    local strengths=()
    for metric in peRatio roe revenueGrowth grossMargin operatingMargin netMargin debtEquity currentRatio; do
        local percentile=$(echo "$rankings" | jq -r ".$metric.percentile")
        if [[ $percentile -ge 75 ]]; then
            case $metric in
                peRatio) strengths+=("valuation (P/E)") ;;
                roe) strengths+=("return on equity") ;;
                revenueGrowth) strengths+=("revenue growth") ;;
                grossMargin) strengths+=("gross margin") ;;
                operatingMargin) strengths+=("operating margin") ;;
                netMargin) strengths+=("net margin") ;;
                debtEquity) strengths+=("low leverage") ;;
                currentRatio) strengths+=("liquidity") ;;
            esac
        fi
    done

    # Identify weaknesses (<25th percentile)
    local weaknesses=()
    for metric in peRatio roe revenueGrowth grossMargin operatingMargin netMargin debtEquity currentRatio; do
        local percentile=$(echo "$rankings" | jq -r ".$metric.percentile")
        if [[ $percentile -le 25 ]]; then
            case $metric in
                peRatio) weaknesses+=("valuation (P/E)") ;;
                roe) weaknesses+=("return on equity") ;;
                revenueGrowth) weaknesses+=("revenue growth") ;;
                grossMargin) weaknesses+=("gross margin") ;;
                operatingMargin) weaknesses+=("operating margin") ;;
                netMargin) weaknesses+=("net margin") ;;
                debtEquity) weaknesses+=("high leverage") ;;
                currentRatio) weaknesses+=("liquidity") ;;
            esac
        fi
    done

    echo "**Strengths vs Peers** (top quartile):"
    if [[ ${#strengths[@]} -gt 0 ]]; then
        for strength in "${strengths[@]}"; do
            echo "- $strength"
        done
    else
        echo "- None identified (no metrics in top quartile)"
    fi

    echo ""
    echo "**Weaknesses vs Peers** (bottom quartile):"
    if [[ ${#weaknesses[@]} -gt 0 ]]; then
        for weakness in "${weaknesses[@]}"; do
            echo "- $weakness"
        done
    else
        echo "- None identified (no metrics in bottom quartile)"
    fi

    echo ""
}

#############################################################################
# Main execution
#############################################################################

echo "Fetching metrics for $symbol and peers: $peers..." >&2

# Fetch all peer metrics
metrics=$(fetch_peer_metrics "$all_symbols")

if echo "$metrics" | jq -e '.error' > /dev/null 2>&1; then
    echo "$metrics"
    exit 1
fi

# Check if we got data
symbol_count=$(echo "$metrics" | jq '.symbols | length')
if [[ $symbol_count -eq 0 ]]; then
    format_error "missing_data" "No metrics data retrieved for symbols"
    exit 1
fi

# Calculate rankings
rankings=$(calculate_rankings "$metrics" "$symbol")

# Build output
output=$(cat <<EOF
{
    "target": "$symbol",
    "peers": $(echo "${PEER_ARRAY[@]}" | jq -R -s -c 'split(" ")'),
    "date": "$(date -u +"%Y-%m-%d")",
    "metrics": $(echo "$metrics" | jq '.metrics'),
    "rankings": $rankings
}
EOF
)

# Output based on mode
case "$mode" in
    metrics)
        # Just metrics, no comparison
        echo "$metrics" | jq '.'
        ;;

    compare|full)
        # JSON + Markdown tables
        echo "$output" | jq '.'
        echo "" >&2
        generate_markdown_tables "$metrics" "$symbol" "$rankings" >&2
        ;;

    *)
        # Default: full output
        echo "$output" | jq '.'
        echo "" >&2
        generate_markdown_tables "$metrics" "$symbol" "$rankings" >&2
        ;;
esac
