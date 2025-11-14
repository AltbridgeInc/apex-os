# Trade Exit Execution Workflow

## Workflow - Exit Execution

### Step 1: Identify Exit Trigger

**Determine reason**:
- Stop loss hit (risk management)
- Profit target reached (planned exit)
- Thesis falsified (fundamental change)
- Time stop (no progress, redeploying capital)

### Step 2: Place Exit Order

**Stop Loss Hit**: Already executed automatically
**Target Hit**: Already executed automatically (if GTC limit was placed)
**Manual Exit**: Place market or limit order

### Step 3: Verify Fill

- Fill price
- All shares exited?
- Any remaining positions?

### Step 4: Cancel Remaining Orders

- Cancel stop if hitting target
- Cancel targets if hitting stop
- Clean up any orphan orders

### Step 5: Calculate P&L

- Entry cost vs exit proceeds
- Include commissions
- Calculate $ and % return
- Calculate R:R achieved

### Step 6: Document Exit

Create detailed exit log.

## Output Format - Exit

Create file: `apex-os/positions/YYYY-MM-DD-TICKER/exit-log.md`

```markdown
# Exit Execution Log: [TICKER]

**Executor**: executor
**Date**: YYYY-MM-DD

## Exit Trigger

**Reason for Exit**: [Stop loss / Target hit / Thesis change / Time stop / Other]

**Details**: [Specific circumstances of exit]

## Exit Execution

**Exit Order**:
- Time placed: HH:MM AM/PM
- Order type: [Market / Limit]
- Limit price: $XX.XX (if limit)
- Shares: XXX

**Fill Details**:
- Time filled: HH:MM AM/PM
- Fill price: $XX.XX (avg if multiple fills)
- Shares filled: XXX
- Total proceeds: $XX,XXX.XX

## Position Summary

**Entry**:
- Date: YYYY-MM-DD
- Price: $XX.XX
- Shares: XXX
- Cost: $XX,XXX.XX

**Exit**:
- Date: YYYY-MM-DD
- Price: $XX.XX
- Shares: XXX
- Proceeds: $XX,XXX.XX

**Holding Period**: XX days (X.X weeks)

## P&L Calculation

**Gross P&L**: $X,XXX.XX
**Commissions**: $XX.XX
**Net P&L**: $X,XXX.XX

**Return**: +/-XX.X%

**R:R Achieved**: X.X:1
**vs Planned R:R**: X.X:1

## Orders Cleanup

- [ ] Stop loss cancelled (if applicable)
- [ ] Take profit orders cancelled (if applicable)
- [ ] No orphan orders remaining
- [ ] Position fully closed

## Exit Verification (Gate 4)

**Checklist**:
- [ ] Exit reason documented (systematic, not emotional)
- [ ] Execution at planned levels (or better/acceptable)
- [ ] P&L calculated correctly
- [ ] All cleanup completed
- [ ] Not emotional override (unless thesis violated)

**Gate 4 Result**: ✓ PASS / ✗ FAIL

**Exit Quality**: [Excellent / Good / Fair / Poor]

**Reasoning**: [Why this rating]

## Portfolio Impact

**After Exit**:
- Portfolio value: $XXX,XXX
- Cash: $XX,XXX (XX%)
- Total risk: X.X% (reduced by X.X%)

## Notes

[Any observations about exit quality, lessons learned, or improvements for next time]
```

## Important Constraints

- **Document all deviations**: If exit differs from plan, explain why
- **No emotional exits**: Unless thesis is invalidated
- **Quality over speed**: Better to exit at plan than rush
- **Verify all cleanup**: No orphan orders left behind
