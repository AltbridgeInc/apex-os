---
name: execute-entry
description: Guide order placement and verify execution quality with stop loss confirmation
agent: apex-os/executor
color: cyan
---

# Execute Entry: Order Placement & Verification

Guide entry order placement, verify fill quality, place risk management orders, and document execution.

## Usage

```
/execute-entry AAPL
```

## Prerequisites

Must have completed `/plan-position` first with approved position plan.

## Task

You are the **executor** agent. Your job is to ensure trade is executed exactly as planned with proper risk management.

## Instructions

### Step 1: Review Position Plan

**Read**:
- `apex-os/analysis/YYYY-MM-DD-{TICKER}/position-plan.md`

**Extract**:
- Entry price range (ideal to maximum)
- Position size (exact shares)
- Stop loss level
- Target 1, 2, 3 prices

### Step 2: Determine Order Strategy

**Limit Order** (preferred, patient):
- Place limit at ideal price
- Good for 3-5 trading days
- Miss if price runs = discipline

**Market Order** (urgent, catalyst-driven):
- Guaranteed fill
- Price uncertainty
- Use if time-sensitive entry

**Scale-In** (larger positions):
- Buy 1/3 at three price levels
- Average in on pullbacks
- Reduces entry risk

### Step 3: Create Order Entry Guide

**Provide step-by-step instructions**:
1. Order type (limit/market)
2. Exact price (if limit)
3. Exact shares
4. Duration (Day/GTC)
5. How to place in broker platform

**Example**:
```
1. Navigate to [Broker] order entry
2. Enter ticker: AAPL
3. Order type: Limit
4. Limit price: $180.50
5. Quantity: 250 shares
6. Duration: GTC (Good Till Canceled)
7. Review and submit
8. SAVE order confirmation number
```

### Step 4: Monitor Execution

**Wait for fill** (user places order, reports back)

**When filled, verify**:
- Fill price within planned range?
- Number of shares correct?
- Any slippage or issues?
- Total cost as expected?

### Step 5: Place Risk Management Orders IMMEDIATELY

**CRITICAL - Do NOT wait**:

**Stop Loss Order** (within 1 minute of fill):
1. Order type: Stop market
2. Stop price: [From position plan]
3. Shares: [All shares or remaining after scale-out]
4. Duration: GTC
5. **VERIFY**: Order confirmed and active

**Take Profit Orders** (optional but recommended):
1. Target 1: GTC limit at first target, 1/3 shares
2. Target 2: GTC limit at second target, 1/3 shares
3. (Target 3 managed with trailing stop later)

### Step 6: Verify Execution Quality

**Checklist**:
- [ ] Entry price acceptable (within planned range)
- [ ] Position size correct (±5% acceptable)
- [ ] Stop loss order placed and confirmed ACTIVE
- [ ] Take profit orders placed (if using)
- [ ] Portfolio limits not exceeded
- [ ] All orders confirmed in system

**Gate 3 Verification**

### Step 7: Document Execution

Create detailed execution log per format in executor agent definition.

## Output

Create: `apex-os/positions/YYYY-MM-DD-{TICKER}/entry-log.md`

Use exact format from executor agent definition.

## Gate 3: Entry Execution

**Checklist**:
- [ ] Entry price within planned range (or documented exception)
- [ ] Position size matches plan (±5%)
- [ ] Stop loss placed IMMEDIATELY (within 1 minute)
- [ ] Stop loss confirmed active in system
- [ ] Take profit orders placed (if applicable)
- [ ] Portfolio limits not exceeded

**Gate 3 Result**: ✓ PASS / ✗ FAIL

**If FAIL, Action Taken**: [What was done to fix]

## Critical Rules

**NON-NEGOTIABLE**:
1. **MUST place stop loss immediately** (within 1 minute of fill)
2. **MUST verify stop confirmed active** (don't assume)
3. **CANNOT skip risk management orders** (this kills accounts)
4. **MUST follow position plan exactly** (or document exceptions)

## Execution Quality Ratings

**Perfect**:
- Filled at ideal price
- Stop placed immediately
- All orders confirmed
- Zero issues

**Good**:
- Filled within acceptable range
- Minor slippage (<1%)
- Stop placed within 5 minutes
- All orders confirmed

**Fair**:
- Filled near maximum price
- Slippage 1-2%
- Stop placed within 15 minutes
- Some execution issues

**Poor**:
- Filled above maximum price
- Slippage >2%
- Stop delayed
- Multiple issues

**Unacceptable** (Fail Gate 3):
- No stop placed
- Stop not confirmed
- Major execution problems

## Portfolio Impact Check

**After Entry**:
- Portfolio value: $XXX,XXX
- Cash: XX% (should be ≥15%)
- Position value: XX% (should be ≤15%)
- Total risk: X.X% (should be ≤8%)

**Verify**: All limits still within bounds

## Success Criteria

- Entry executed as planned
- Stop loss placed immediately and confirmed
- Execution quality acceptable
- Gate 3 passed
- Position now live and protected

## Typical Timeline

- Review plan: 5 minutes
- Place entry order: 5 minutes
- Wait for fill: Minutes to days (depends on order type)
- Place stop/targets: 5 minutes
- Document: 15 minutes
- **Active time**: ~30 minutes

## Important Notes

- **Stop loss is NOT optional** - it's mandatory
- **Verify confirmation** - don't assume order went through
- **No shortcuts** - follow process every time
- **Document everything** - if not documented, didn't happen

## Next Step

Position is now live. Monitor daily with:
```
/monitor-portfolio
```

**Position enters hold period with active risk management**
