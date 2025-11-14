---
name: position-sizing
description: Calculate optimal position sizes based on account risk, stop-loss distance, and position limits to manage capital allocation effectively.
---

# Position Sizing

## Overview

This skill applies mathematical position sizing frameworks to determine optimal trade sizes based on risk management principles.

## Analysis Framework

Refer to `@apex-os/standards/risk-management/position-sizing.md` for comprehensive guidance on:

- **Core Formula**: Position Size = (Portfolio Value × Risk %) / (Entry Price - Stop Loss)
- **Risk Per Trade Guidelines**: Conservative (1%), Moderate (1.5%), Aggressive (2%)
- **Position Size Constraints**: Maximum 15% per position, 8% total portfolio heat
- **Adjustments**: For conviction level, market conditions, win/loss streaks
- **Common Mistakes**: Equal dollar amounts, risking too much, not using formula
- **Advanced Techniques**: Scaling in, pyramiding, Kelly Criterion
- **Best Practices**: Always use formula, risk small, check portfolio heat

## Application Process

When invoked:
1. Identify entry price and stop loss level
2. Calculate risk per share (Entry - Stop)
3. Determine risk amount (Portfolio × Risk %)
4. Calculate position size using formula
5. Verify position < 15% of portfolio
6. Check total portfolio heat < 8%
7. Adjust for conviction level if needed
8. Document calculation in position plan

## Output Format

Provide:
- **Position Size**: Number of shares to buy
- **Dollar Amount**: Total position cost
- **Risk Amount**: $ amount risked if stopped out
- **Risk Percentage**: % of portfolio risked
- **Portfolio Heat**: Total risk across all positions
- **Constraints Check**: All limits verified
