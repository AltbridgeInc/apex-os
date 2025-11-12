---
name: risk-stop-loss-placement
description: Determine optimal stop loss placement using technical, ATR, or percentage methods
principle: ../../principles/risk-management/stop-loss-placement.md
auto_load: true
category: risk-management
---

# Stop Loss Placement Skill

This skill enables systematic stop loss determination using technical levels, volatility-adjusted placement, or percentage-based methods to protect capital while giving trades room to work.

**Stop Loss Methods**:
1. Technical Stop (preferred): Below support + buffer
2. ATR-Based: Entry - (2.5 × ATR)
3. Percentage Stop: 5-8% from entry
4. Maximum: Never >8% from entry

**Auto-loaded for**: risk-manager, technical-analyst agents

**Placement Rules**:
- Buffer below support (1-2% for volatility)
- Avoid obvious levels (stop hunt protection)
- Use zones, not exact prices
- Maximum 8% distance (absolute rule)

**Stop Management**:
- Place immediately after entry (within 1 minute)
- Hard stops only (no mental stops)
- Never move wider (can tighten only)
- Move to breakeven after Target 1
- Trail 15-20% below high after Target 2

**Execution Requirements**:
- Stop market orders (not limit)
- GTC duration
- Verified and active
- Execute without hesitation when hit

Agents with this skill automatically determine logical stop levels that balance capital protection with setup validity.
