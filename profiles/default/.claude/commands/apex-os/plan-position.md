---
name: plan-position
description: Calculate position sizing, stops, and targets with risk management validation
agent: apex-os/risk-manager
color: red
---

# Plan Position: Risk Management & Sizing

Calculate mathematically correct position size, validate risk management parameters, and create complete position plan.

## Usage

```
/plan-position AAPL
```

## Prerequisites

Must have completed `/write-thesis` first with investment thesis documented.

## Task

You are the **risk-manager** agent. Your job is to ensure this position follows all risk management rules.

## Instructions

### Step 1: Review Thesis and Technical Levels

**Read**:
- `apex-os/analysis/YYYY-MM-DD-{TICKER}/investment-thesis.md`
- `apex-os/analysis/YYYY-MM-DD-{TICKER}/technical-report.md`

**Extract**:
- Entry price range (ideal to maximum)
- Stop loss level
- Target 1, 2, 3 prices
- Conviction level

### Step 2: Review Portfolio Context

**Current State**:
- Total portfolio value
- Number of open positions
- Current total risk (portfolio heat)
- Sector exposure
- Cash available

### Step 3: Calculate Position Size

**Use Formula**:
```
Position Size = (Portfolio × Risk %) / (Entry - Stop)
```

**Risk Per Trade**:
- High conviction: 1.5-2.0%
- Medium conviction: 1.0-1.5%
- Low conviction: 0.5-1.0%

**Calculate**:
- Risk amount in dollars
- Number of shares
- Total cost
- % of portfolio

### Step 4: Verify All Constraints

**Check**:
- [ ] Position <15% of portfolio
- [ ] Risk per trade ≤2%
- [ ] Total portfolio heat + this position ≤8%
- [ ] Sector exposure acceptable (<50%)
- [ ] Cash reserve ≥20% after entry
- [ ] Stop loss ≤8% from entry

**If ANY fail**: Adjust position size or reject

### Step 5: Validate Stop Loss Placement

**Review**:
- Stop level from technical-analyst
- Is it logical? (below support + buffer)
- Distance from entry (<8% maximum)
- Accounts for volatility

**Adjust if needed**:
- If stop too wide (>8%): Reduce position size
- If stop too tight (<3%): Consider passing

### Step 6: Calculate Risk/Reward Ratio

**For Each Target**:
- Target 1: Risk vs reward (must be ≥2:1)
- Target 2: Risk vs reward (should be ≥3:1)
- Combined R:R across scaling strategy

**Minimum**: 2:1 R:R required (Gate 2)

### Step 7: Plan Scale-Out Strategy

**3-Target System**:
- Target 1 (2:1): Sell 1/3, move stop to breakeven
- Target 2 (3:1): Sell 1/3, begin trailing
- Target 3: Trail final 1/3 at 15-20% below high

**Document**:
- Exact prices
- Exact share amounts
- Stop adjustments

### Step 8: Complete Position Plan

Create complete position plan per format in risk-manager agent definition.

## Output

Create: `apex-os/analysis/YYYY-MM-DD-{TICKER}/position-plan.md`

Use exact format from risk-manager agent definition.

## Gate 2 Verification

**Checklist**:
- [ ] Position size calculated mathematically
- [ ] Position <15% of portfolio
- [ ] Risk per trade ≤2%
- [ ] Total portfolio heat ≤8%
- [ ] Stop loss within 8% of entry
- [ ] Risk/reward ≥2:1
- [ ] Cash reserve ≥20% maintained
- [ ] Sector limits respected

**Gate 2 Result**: ✓ PASS / ✗ FAIL

**If PASS**: "Position plan approved. Ready for `/execute-entry {TICKER}`"

**If FAIL**: "Position does not meet risk parameters. [Specific reason]"

## Important Notes

- **NEVER risk >2% per trade** (absolute maximum)
- **Position size is mathematical** (not guess or feel)
- **Can reject positions** (if risk parameters not met)
- **Protect capital > Make money** (capital preservation first)

## Red Flags (Reject Position)

- R:R <2:1 (insufficient reward for risk)
- Portfolio heat would exceed 8% (too much total risk)
- Position would be >15% of portfolio (concentration)
- Sector would exceed 50% (sector risk)
- Cash would drop below 15% (liquidity)
- Stop >8% from entry (stop too wide)

**If any red flags**: Either adjust parameters or pass on trade

## Success Criteria

- Position size calculated correctly
- All constraints verified
- Gate 2 checklist completed
- Clear execution plan
- Ready to place orders

## Typical Timeline

- Review thesis/technical: 15 minutes
- Calculate position size: 10 minutes
- Verify constraints: 10 minutes
- Write position plan: 20 minutes
- **Total**: ~1 hour

## Next Step

If position plan passes Gate 2, proceed to:
```
/execute-entry {TICKER}
```

**DO NOT execute without approved position plan**
