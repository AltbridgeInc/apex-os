---
name: plan-position
description: Calculate position sizing, stops, and targets with risk management validation
color: red
---

# Plan Position: Risk Management & Sizing

You are calculating mathematically correct position size and validating risk parameters.

## Usage

```
/plan-position AAPL
```

## Prerequisites

Must have completed `/write-thesis` first with investment thesis documented.

## Task

Use the **risk-manager** subagent to ensure this position follows all risk management rules:

Provide the risk-manager with:
- Ticker symbol
- Analysis directory path with thesis and technical reports
- Current portfolio state from `apex-os/config.yml`
- Current open positions (if any)

The risk-manager will:
1. Review thesis and extract entry/stop/target levels
2. Review portfolio context (value, open positions, cash, heat)
3. Calculate position size using formula: (Portfolio × Risk %) / (Entry - Stop)
4. Verify all constraints (position size, risk %, portfolio heat, sector exposure)
5. Validate stop loss placement (logical level, distance from entry)
6. Calculate risk/reward ratios for all targets
7. Plan scale-out strategy (3-target system)
8. Complete Gate 2 verification checklist
9. Create `apex-os/analysis/YYYY-MM-DD-{TICKER}/position-plan.md`

Once the risk-manager completes, evaluate Gate 2:

**Gate 2 Checklist:**
- Position size calculated mathematically
- Position <15% of portfolio
- Risk per trade ≤2%
- Total portfolio heat ≤8%
- Stop loss within 8% of entry
- Risk/reward ≥2:1
- Cash reserve ≥20% maintained
- Sector limits respected

Then inform the user:

```
Position plan complete for [TICKER]!

✅ Position Size: [X] shares at $[Y] = $[Z] ([W]% of portfolio)
🎯 Risk: $[A] ([B]% of portfolio)
📊 Risk/Reward: [C]:1
📂 Location: `apex-os/analysis/YYYY-MM-DD-{TICKER}/position-plan.md`

GATE 2: [✓ PASS / ✗ FAIL]

**If PASS**: "Position plan approved. Ready for `/execute-entry {TICKER}`"

**If FAIL**: "Position does not meet risk parameters. [Specific reason - adjust or pass]"
```

## Important

**NEVER execute without approved position plan that passes Gate 2**
