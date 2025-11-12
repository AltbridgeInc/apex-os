---
name: risk-position-sizing
description: Calculate mathematically correct position size based on risk percentage and stop distance
principle: ../../principles/risk-management/position-sizing.md
auto_load: true
category: risk-management
---

# Position Sizing Skill

This skill enables precise mathematical calculation of position size based on predefined risk tolerance, ensuring consistent risk management across all trades.

**Formula Applied**:
```
Position Size = (Portfolio × Risk %) / (Entry - Stop)
```

**Risk Guidelines Enforced**:
- Conservative: 1.0% per trade
- Moderate: 1.5% per trade
- Aggressive: 2.0% maximum (never exceed)

**Auto-loaded for**: risk-manager agent

**Constraints Verified**:
- Position <15% of portfolio (concentration limit)
- Total portfolio heat <8% (across all positions)
- Cash reserve ≥20% (liquidity requirement)
- Risk appropriate for conviction level

**Adjustments Applied**:
- High conviction: Upper end of risk range (1.5-2%)
- Medium conviction: Middle range (1-1.5%)
- Low conviction: Lower range (0.5-1%)
- Market conditions: Reduce in volatility
- After losses: Drop to 0.5-1% after 3 losses

Agents with this skill automatically calculate correct position size, preventing overleveraging and ensuring disciplined capital allocation.
