# Trade Entry Execution Workflow

## Workflow - Entry Execution

### Step 1: Review Position Plan

**Read**: `position-plan.md`

**Extract**:
- Entry price range (ideal to maximum)
- Position size (number of shares)
- Stop loss level
- Take profit targets

### Step 2: Determine Order Strategy

**Limit Order** (preferred, patient approach):
- Place limit at ideal price
- Good for 3-5 trading days
- Miss if price runs = discipline

**Market Order** (urgent, catalyst-driven):
- Guaranteed fill
- Price uncertainty
- Use if entry is time-sensitive

**Scale-In** (larger positions):
- Buy 1/3 at three price levels
- Average in on pullbacks
- Reduces entry risk

### Step 3: Create Order Entry Guide

Generate step-by-step instructions for placing orders.

### Step 4: Monitor Execution

Wait for fills and verify:
- Fill price within planned range?
- Number of shares correct?
- Any slippage or issues?

### Step 5: Place Risk Management Orders

**IMMEDIATELY after entry fill**:

1. **Stop Loss Order**:
   - Type: Stop market (or stop limit if preferred)
   - Level: From position plan
   - Duration: GTC (good til canceled)
   - **CRITICAL**: Place this first

2. **Take Profit Orders** (optional but recommended):
   - Target 1: GTC limit at first target
   - Target 2: GTC limit at second target
   - (Target 3 managed manually with trail)

### Step 6: Verify Execution Quality

Run through checklist:
- [ ] Entry price acceptable (within planned range)
- [ ] Position size correct (±5% acceptable)
- [ ] Stop loss order placed and confirmed active
- [ ] Take profit orders placed (if using)
- [ ] Portfolio limits not exceeded
- [ ] All orders confirmed in system

### Step 7: Document Execution

Create detailed execution log.

## Output Format - Entry

Create file: `apex-os/positions/YYYY-MM-DD-TICKER/entry-log.md`

```markdown
# Entry Execution Log: [TICKER]

**Executor**: executor
**Date**: YYYY-MM-DD

## Position Plan Review

**From Position Plan**:
- Entry range: $XX.XX - $XX.XX
- Position size: XXX shares
- Stop loss: $XX.XX
- Targets: $XX.XX / $XX.XX / Trail

## Order Strategy

**Method Selected**: [Limit / Market / Scale-in]
**Reasoning**: [Why this approach]

## Order Placement

**Entry Order**:
- Time placed: HH:MM AM/PM
- Order type: [Limit / Market]
- Limit price: $XX.XX (if limit)
- Shares: XXX

## Execution Results

**Fill Details**:
- Time filled: HH:MM AM/PM
- Fill price: $XX.XX (avg if multiple fills)
- Shares filled: XXX
- Total cost: $XX,XXX.XX (including commissions)

**Execution Quality**:
- Within planned range: ✓ / ✗
- Slippage: $X.XX per share (X.X%)
- Quality rating: [Perfect / Good / Fair / Poor]

## Risk Management Orders Placed

**Stop Loss**:
- Order type: Stop market
- Stop price: $XX.XX
- Shares: XXX
- Duration: GTC
- Time placed: HH:MM AM/PM
- Status: ✓ Confirmed active

**Take Profit Orders**:
- Target 1: Limit $XX.XX, XXX shares, GTC ✓
- Target 2: Limit $XX.XX, XXX shares, GTC ✓
- Target 3: Will manage manually with trail

## Portfolio Impact

**Before Entry**:
- Portfolio value: $XXX,XXX
- Cash: $XX,XXX (XX%)
- Total risk: X.X%

**After Entry**:
- Portfolio value: $XXX,XXX
- Cash: $XX,XXX (XX%)
- Position value: $XX,XXX (XX% of portfolio)
- Total risk: X.X% (added X.X%)

**Limits Check**:
- ✓ Position <15% of portfolio
- ✓ Total risk <8% of portfolio
- ✓ Cash reserve >20%

## Execution Verification (Gate 3)

**Checklist**:
- [ ] Entry price within planned range (or documented exception)
- [ ] Position size matches plan (±5%)
- [ ] Stop loss placed immediately
- [ ] Stop loss confirmed active in system
- [ ] Take profit orders placed (if applicable)
- [ ] Portfolio limits not exceeded

**Gate 3 Result**: ✓ PASS / ✗ FAIL

**If FAIL, Action Taken**: [Description]

## Deviations from Plan

[List any deviations and reasons]
- [Deviation 1]: [Reason and justification]

Or: None - executed exactly as planned

## Notes

[Any observations about execution, market conditions, or considerations for future]
```
