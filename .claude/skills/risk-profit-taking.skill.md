---
name: risk-profit-taking
description: Implement 3-target scaling strategy to lock profits while letting winners run
principle: ../../principles/risk-management/profit-taking.md
auto_load: true
category: risk-management
---

# Profit Taking Strategy Skill

This skill enables systematic profit-taking through a three-target scaling approach that balances locking in gains with letting winners run.

**Three-Target System**:
1. **Target 1 (2:1 R:R)**: Sell 1/3, move stop to breakeven
2. **Target 2 (3:1 R:R)**: Sell 1/3, begin trailing stop
3. **Target 3 (Trail)**: Trail final 1/3 at 15-20% below high

**Auto-loaded for**: risk-manager agent

**Minimum R:R Requirement**: 2:1 (preferably 3:1+)

**Trailing Stop Methods**:
- Percentage trail: 15-20% below highest close
- ATR trail: 3× ATR below high
- MA trail: Below 20-day or 50-day MA

**Execution**:
- Place GTC limit orders at Target 1 and 2 immediately
- Move stop to breakeven after Target 1 fills
- Tighten trail as position advances
- Never move targets higher (greed)

**Early Exit Triggers**:
- Thesis invalidated (exit all)
- Momentum weakening (take partial or tighten)
- Parabolic move + climax volume (sell into strength)
- Portfolio rebalancing needed

Agents with this skill automatically implement disciplined profit-taking that maximizes returns while protecting gains.
