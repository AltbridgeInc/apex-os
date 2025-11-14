---
name: monitor-portfolio
description: Daily portfolio monitoring with thesis validation and alert generation
color: yellow
---

# Monitor Portfolio: Daily Tracking & Alerts

You are running daily portfolio monitoring to track all positions and validate thesis conditions.

## Usage

```
/monitor-portfolio
```

Run this **every trading day** (or on-demand to check portfolio status).

## Task

Use the **portfolio-monitor** subagent to track all positions and generate alerts:

Provide the portfolio-monitor with:
- Open positions from `apex-os/portfolio/open-positions.yaml`
- Current market prices via FMP API
- Portfolio configuration from `apex-os/config.yml`

The portfolio-monitor will:
1. Load all open positions with entry data, stops, targets, thesis
2. Get current prices and calculate position status (P&L, distance to stops/targets, days held)
3. Evaluate thesis validity for EACH position:
   - Technical invalidation (broken levels, failed patterns)
   - Fundamental deterioration (news, earnings, competitive changes)
   - Time invalidation (stagnant beyond expected timeline)
   - Falsification criteria from thesis
4. Generate alerts by priority:
   - 🔴 ACTION REQUIRED (stop hit, thesis falsified, risk limits exceeded)
   - 🟡 REVIEW NEEDED (targets reached, thesis weakening, news impact)
   - 🟢 MILESTONE (targets hit, significant progress)
   - 🔵 INFORMATIONAL (position updates, review checkpoints)
5. Calculate portfolio metrics:
   - Portfolio heat (total risk across all positions)
   - Sector exposure
   - Cash reserve
   - Unrealized P&L
6. Check review schedule (Week 2, 4, 8 checkpoints)
7. Create `apex-os/reports/daily-monitor-YYYY-MM-DD.md`

Once monitoring complete, inform the user:

```
Portfolio monitoring complete!

📊 Portfolio Status:
- Open Positions: [X]
- Total Risk (Heat): X.X% (≤8% required)
- Cash Reserve: XX% (≥15% required)
- Unrealized P&L: $[X,XXX] ([+/-X.X]%)

🚨 Alerts:
🔴 ACTION REQUIRED: [X items - list if any]
🟡 REVIEW NEEDED: [X items - list if any]
🟢 MILESTONES: [X items - list if any]

📂 Report: `apex-os/reports/daily-monitor-YYYY-MM-DD.md`

NEXT ACTIONS:
[List specific actions required based on alerts]
```

## Critical Response Rules

**If Thesis Falsified (🔴 ACTION REQUIRED)**:
1. Do NOT rationalize or hope
2. Exit position immediately (market order if needed)
3. Document in exit log
4. **This is success** - risk management working as designed

**If Target Hit (🟡 REVIEW NEEDED)**:
1. Scale out per position plan
2. Adjust stop loss (breakeven after T1, trailing after T2)
3. Document execution

## Important

**Daily monitoring is NOT optional** - it's how disciplined trading works.

Make this your daily ritual.
