---
name: execute-entry
description: Guide order placement and verify execution quality with stop loss confirmation
color: cyan
---

# Execute Entry: Order Placement & Verification

You are guiding entry order placement with proper risk management.

## Usage

```
/execute-entry AAPL
```

## Prerequisites

Must have completed `/plan-position` first with approved position plan.

## Task

Use the **executor** subagent to ensure trade is executed exactly as planned:

Provide the executor with:
- Ticker symbol
- Position plan from `apex-os/analysis/YYYY-MM-DD-{TICKER}/position-plan.md`
- Current market conditions (price, bid/ask spread, volume)
- User's broker platform details

The executor will:
1. Review position plan and extract entry/stop/target levels
2. Determine order strategy (limit/market/scale-in)
3. Create step-by-step order entry instructions for user
4. Guide user through order placement
5. Wait for user to report fill details
6. **IMMEDIATELY guide stop loss order placement** (within 1 minute)
7. Verify stop loss confirmed active in system
8. Guide take profit order placement (optional)
9. Verify execution quality (fill price, slippage, position size)
10. Check portfolio impact (cash %, position %, total risk %)
11. Complete Gate 3 verification checklist
12. Create `apex-os/positions/YYYY-MM-DD-{TICKER}/entry-log.md`

## Gate 3: Entry Execution

Once execution complete, verify Gate 3:

**Gate 3 Checklist:**
- Entry price within planned range (or exception documented)
- Position size matches plan (±5%)
- Stop loss placed IMMEDIATELY (within 1 minute of fill)
- Stop loss confirmed ACTIVE in broker system
- Take profit orders placed (if applicable)
- Portfolio limits not exceeded

**Critical Rules (NON-NEGOTIABLE):**
1. Stop loss MUST be placed within 1 minute of fill
2. Stop loss MUST be verified active (don't assume)
3. Cannot skip risk management orders
4. Must follow position plan exactly (or document exceptions)

Then inform the user:

```
Entry executed for [TICKER]!

✅ Entry: [X] shares at $[Y] (fill quality: [Perfect/Good/Fair])
🛡️ Stop Loss: $[Z] - CONFIRMED ACTIVE
🎯 Targets: T1 $[A], T2 $[B], T3 $[C]
📂 Location: `apex-os/positions/YYYY-MM-DD-{TICKER}/entry-log.md`

GATE 3: [✓ PASS / ✗ FAIL]

Portfolio Impact:
- Cash: XX% (≥15% required)
- Position: XX% (≤15% required)
- Total Risk: X.X% (≤8% required)

NEXT STEP 👉 Position is now live. Monitor daily with `/monitor-portfolio`
```

## Critical

**Stop loss is NOT optional - it's mandatory risk management**
