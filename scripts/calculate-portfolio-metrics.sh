#!/usr/bin/env bash
# calculate-portfolio-metrics.sh - Calculate professional portfolio performance metrics
# Usage: ./calculate-portfolio-metrics.sh

set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PORTFOLIO_HISTORY="${SCRIPT_DIR}/../data/portfolio-history.json"
CLOSED_POSITIONS="${SCRIPT_DIR}/../data/closed-positions.json"

echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}  Portfolio Performance Metrics${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo ""

# Check if portfolio history exists
if [[ ! -f "$PORTFOLIO_HISTORY" ]]; then
    echo -e "${RED}Error: Portfolio history not found at $PORTFOLIO_HISTORY${NC}"
    echo "Run portfolio-monitor first to build history"
    exit 1
fi

history=$(cat "$PORTFOLIO_HISTORY")
days_tracked=$(echo "$history" | jq 'length')

if (( days_tracked < 2 )); then
    echo -e "${YELLOW}Insufficient data: Only $days_tracked day(s) tracked${NC}"
    echo "Need at least 2 days of data for metrics calculation"
    exit 1
fi

echo "Portfolio history: $days_tracked days tracked"
echo ""

# === Total Return Metrics ===
echo "═══════════════════════════════════════"
echo "Total Return Metrics"
echo "═══════════════════════════════════════"
echo ""

initial_value=$(echo "$history" | jq '.[0].portfolio_value')
current_value=$(echo "$history" | jq '.[-1].portfolio_value')
total_return=$(echo "scale=4; (($current_value - $initial_value) / $initial_value) * 100" | bc -l)

echo "Initial Value: \$$initial_value"
echo "Current Value: \$$current_value"
echo "Total Return: ${total_return}%"
echo ""

# Calculate CAGR (annualized return)
days_elapsed=$(( days_tracked - 1 ))
years=$(echo "scale=6; $days_elapsed / 365" | bc -l)

if (( $(echo "$years > 0" | bc -l) )); then
    total_return_decimal=$(echo "scale=6; $total_return / 100" | bc -l)
    cagr=$(echo "scale=4; ((1 + $total_return_decimal) ^ (1 / $years) - 1) * 100" | bc -l)
    echo "Days Elapsed: $days_elapsed"
    echo "CAGR (Annualized): ${cagr}%"
else
    echo "CAGR: N/A (< 1 day)"
fi

echo ""

# === Risk-Adjusted Metrics ===
echo "═══════════════════════════════════════"
echo "Risk-Adjusted Metrics"
echo "═══════════════════════════════════════"
echo ""

# Calculate daily returns
daily_returns=$(echo "$history" | jq '[.[1:] | to_entries | .[] |
    {
        date: .value.date,
        return: (((.value.portfolio_value - $initial[.key].portfolio_value) / $initial[.key].portfolio_value) * 100)
    }
] as $returns | $returns | map(.return)' --argjson initial "$(echo "$history" | jq '.')")

num_returns=$(echo "$daily_returns" | jq 'length')

if (( num_returns > 0 )); then
    # Average daily return
    avg_daily_return=$(echo "$daily_returns" | jq 'add / length')

    # Standard deviation of daily returns
    variance=$(echo "$daily_returns" | jq --argjson avg "$avg_daily_return" \
        'map(. - $avg | . * .) | add / length')
    std_dev=$(echo "scale=6; sqrt($variance)" | bc -l)

    echo "Average Daily Return: ${avg_daily_return}%"
    echo "Daily Volatility (Std Dev): ${std_dev}%"
    echo ""

    # Sharpe Ratio
    # (Portfolio Return - Risk-Free Rate) / Portfolio Std Dev
    # Using 4.5% annual risk-free rate = 0.0123% daily
    risk_free_daily=0.0123

    if (( $(echo "$std_dev > 0" | bc -l) )); then
        sharpe=$(echo "scale=4; ($avg_daily_return - $risk_free_daily) / $std_dev" | bc -l)

        # Annualized Sharpe (multiply by sqrt(252 trading days))
        sharpe_annual=$(echo "scale=4; $sharpe * sqrt(252)" | bc -l)

        echo "Sharpe Ratio (Daily): $sharpe"
        echo "Sharpe Ratio (Annualized): $sharpe_annual"

        if (( $(echo "$sharpe_annual > 2.0" | bc -l) )); then
            echo -e "Rating: ${GREEN}EXCELLENT${NC} (>2.0)"
        elif (( $(echo "$sharpe_annual > 1.0" | bc -l) )); then
            echo -e "Rating: ${GREEN}GOOD${NC} (>1.0)"
        elif (( $(echo "$sharpe_annual > 0.5" | bc -l) )); then
            echo -e "Rating: ${YELLOW}FAIR${NC} (>0.5)"
        else
            echo -e "Rating: ${RED}POOR${NC} (<0.5)"
        fi
    else
        echo "Sharpe Ratio: N/A (zero volatility)"
    fi

    echo ""

    # Sortino Ratio (focus on downside risk)
    # Only count negative returns in std dev calculation
    downside_returns=$(echo "$daily_returns" | jq 'map(select(. < 0))')
    num_downside=$(echo "$downside_returns" | jq 'length')

    if (( num_downside > 0 )); then
        downside_variance=$(echo "$downside_returns" | jq \
            'map(. * .) | add / length')
        downside_dev=$(echo "scale=6; sqrt($downside_variance)" | bc -l)

        sortino=$(echo "scale=4; ($avg_daily_return - $risk_free_daily) / $downside_dev" | bc -l)
        sortino_annual=$(echo "scale=4; $sortino * sqrt(252)" | bc -l)

        echo "Downside Deviation: ${downside_dev}%"
        echo "Sortino Ratio (Daily): $sortino"
        echo "Sortino Ratio (Annualized): $sortino_annual"

        if (( $(echo "$sortino_annual > 3.0" | bc -l) )); then
            echo -e "Rating: ${GREEN}EXCELLENT${NC} (>3.0)"
        elif (( $(echo "$sortino_annual > 1.5" | bc -l) )); then
            echo -e "Rating: ${GREEN}GOOD${NC} (>1.5)"
        elif (( $(echo "$sortino_annual > 1.0" | bc -l) )); then
            echo -e "Rating: ${YELLOW}FAIR${NC} (>1.0)"
        else
            echo -e "Rating: ${RED}POOR${NC} (<1.0)"
        fi
    else
        echo "Sortino Ratio: N/A (no negative returns - all wins!)"
    fi

    echo ""
fi

# === Maximum Drawdown ===
echo "═══════════════════════════════════════"
echo "Maximum Drawdown"
echo "═══════════════════════════════════════"
echo ""

# Find peak value and worst drawdown
peak_value=$(echo "$history" | jq '[.[] | .portfolio_value] | max')
peak_date=$(echo "$history" | jq -r ".[] | select(.portfolio_value == $peak_value) | .date" | head -1)

echo "Peak Value: \$$peak_value (on $peak_date)"
echo "Current Value: \$$current_value"

current_drawdown=$(echo "scale=4; (($current_value - $peak_value) / $peak_value) * 100" | bc -l)
echo "Current Drawdown: ${current_drawdown}%"

# Calculate max drawdown (largest peak-to-trough decline)
max_dd=$(echo "$history" | jq '
    [
        . as $data |
        to_entries |
        .[] |
        .key as $i |
        ($data[0:$i+1] | map(.portfolio_value) | max) as $peak |
        .value.portfolio_value as $current |
        (($current - $peak) / $peak * 100)
    ] | min
')

echo "Maximum Drawdown: ${max_dd}%"

if (( $(echo "$max_dd > -10" | bc -l) )); then
    echo -e "Rating: ${GREEN}EXCELLENT${NC} (>-10%)"
elif (( $(echo "$max_dd > -15" | bc -l) )); then
    echo -e "Rating: ${GREEN}GOOD${NC} (>-15%)"
elif (( $(echo "$max_dd > -25" | bc -l) )); then
    echo -e "Rating: ${YELLOW}FAIR${NC} (>-25%)"
else
    echo -e "Rating: ${RED}POOR${NC} (<-25%)"
fi

echo ""

# === Win Rate and Trade Statistics ===
echo "═══════════════════════════════════════"
echo "Trade Statistics"
echo "═══════════════════════════════════════"
echo ""

if [[ -f "$CLOSED_POSITIONS" ]]; then
    closed=$(cat "$CLOSED_POSITIONS")
    total_trades=$(echo "$closed" | jq 'length')

    if (( total_trades > 0 )); then
        # Win rate
        winners=$(echo "$closed" | jq '[.[] | select(.pnl > 0)] | length')
        losers=$(echo "$closed" | jq '[.[] | select(.pnl <= 0)] | length')
        win_rate=$(echo "scale=2; ($winners / $total_trades) * 100" | bc -l)

        echo "Total Trades: $total_trades"
        echo "Winners: $winners"
        echo "Losers: $losers"
        echo "Win Rate: ${win_rate}%"

        if (( $(echo "$win_rate > 65" | bc -l) )); then
            echo -e "Rating: ${GREEN}EXCELLENT${NC} (>65%)"
        elif (( $(echo "$win_rate > 55" | bc -l) )); then
            echo -e "Rating: ${GREEN}GOOD${NC} (>55%)"
        elif (( $(echo "$win_rate > 45" | bc -l) )); then
            echo -e "Rating: ${YELLOW}FAIR${NC} (>45%)"
        else
            echo -e "Rating: ${RED}POOR${NC} (<45%)"
        fi

        echo ""

        # Average win vs average loss
        if (( winners > 0 )); then
            total_wins=$(echo "$closed" | jq '[.[] | select(.pnl > 0) | .pnl] | add')
            avg_win=$(echo "scale=2; $total_wins / $winners" | bc -l)
            echo "Average Win: \$$avg_win"
        else
            avg_win=0
            echo "Average Win: N/A (no winners yet)"
        fi

        if (( losers > 0 )); then
            total_losses=$(echo "$closed" | jq '[.[] | select(.pnl <= 0) | .pnl] | add')
            avg_loss=$(echo "scale=2; $total_losses / $losers" | bc -l)
            avg_loss_abs=$(echo "$avg_loss * -1" | bc -l)
            echo "Average Loss: -\$$avg_loss_abs"
        else
            avg_loss=0
            echo "Average Loss: N/A (no losses yet!)"
        fi

        if (( winners > 0 && losers > 0 )); then
            win_loss_ratio=$(echo "scale=4; $avg_win / ($avg_loss * -1)" | bc -l)
            echo "Win:Loss Ratio: ${win_loss_ratio}:1"

            if (( $(echo "$win_loss_ratio > 2.0" | bc -l) )); then
                echo -e "Rating: ${GREEN}EXCELLENT${NC} (>2:1)"
            elif (( $(echo "$win_loss_ratio > 1.5" | bc -l) )); then
                echo -e "Rating: ${GREEN}GOOD${NC} (>1.5:1)"
            elif (( $(echo "$win_loss_ratio > 1.0" | bc -l) )); then
                echo -e "Rating: ${YELLOW}FAIR${NC} (>1:1)"
            else
                echo -e "Rating: ${RED}POOR${NC} (<1:1)"
            fi
        fi

        echo ""

        # Profit factor
        if (( losers > 0 )); then
            profit_factor=$(echo "scale=4; $total_wins / ($total_losses * -1)" | bc -l)
            echo "Profit Factor: $profit_factor"

            if (( $(echo "$profit_factor > 3.0" | bc -l) )); then
                echo -e "Rating: ${GREEN}EXCELLENT${NC} (>3.0)"
            elif (( $(echo "$profit_factor > 2.0" | bc -l) )); then
                echo -e "Rating: ${GREEN}GOOD${NC} (>2.0)"
            elif (( $(echo "$profit_factor > 1.5" | bc -l) )); then
                echo -e "Rating: ${YELLOW}FAIR${NC} (>1.5)"
            else
                echo -e "Rating: ${RED}POOR${NC} (<1.5)"
            fi
        fi

        echo ""
    else
        echo "No closed trades yet"
        echo ""
    fi
else
    echo "No closed positions file found"
    echo "Create $CLOSED_POSITIONS to track trade statistics"
    echo ""
fi

# === Summary ===
echo "═══════════════════════════════════════"
echo "Performance Summary"
echo "═══════════════════════════════════════"
echo ""

echo "Portfolio is tracking $days_tracked days of history"
echo ""

# Output JSON for programmatic use
cat <<EOF
{
  "total_return": {
    "initial_value": $initial_value,
    "current_value": $current_value,
    "total_return_pct": $total_return,
    "days_tracked": $days_tracked
  },
  "risk_adjusted": {
    "sharpe_ratio": ${sharpe_annual:-null},
    "sortino_ratio": ${sortino_annual:-null},
    "max_drawdown_pct": $max_dd,
    "current_drawdown_pct": $current_drawdown,
    "volatility_pct": ${std_dev:-null}
  },
  "trade_statistics": {
    "total_trades": ${total_trades:-0},
    "win_rate": ${win_rate:-null},
    "profit_factor": ${profit_factor:-null},
    "avg_win": ${avg_win:-null},
    "avg_loss": ${avg_loss:-null}
  }
}
EOF
