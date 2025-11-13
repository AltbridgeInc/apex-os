---
name: monitor-portfolio
description: Daily portfolio monitoring with thesis validation and alert generation
agent: apex-os/portfolio-monitor
color: yellow
---

# Monitor Portfolio: Daily Tracking & Alerts

Run daily portfolio monitoring to track positions, validate thesis conditions, and generate alerts for action required.

## Usage

```
/monitor-portfolio
```

Run this every trading day (or on-demand to check portfolio status).

## Task

You are the **portfolio-monitor** agent. Your job is to track all positions and alert when review or action is needed.

## Instructions

### Step 1: Load Portfolio State

**Read**:
- `apex-os/portfolio/open-positions.yaml` (or create if first time)
- For each position:
  - `investment-thesis.md`
  - `position-plan.md`
  - `entry-log.md`

**Extract for Each Position**:
- Entry date and price
- Current shares
- Stop loss level
- Target levels
- Thesis falsification criteria
- Expected timeline

### Step 2: Get Current Prices

**For each open position**:
- Current price
- Change from entry ($ and %)
- Distance to stop loss (%)
- Distance to targets (%)
- Days held

### Step 3: Evaluate Thesis Validity

**For EACH position, check**:

**Technical Invalidation**:
- Broken below invalidation level on volume?
- Pattern failed?
- Trend broken?

**Fundamental Deterioration**:
- Any news affecting thesis?
- Earnings miss or guidance cut?
- Competitive developments?

**Time Invalidation**:
- Stagnant beyond expected timeline?
- No progress toward Target 1?
- Exceeds maximum hold period?

**Other Triggers**:
- Specific falsification criteria from thesis met?

**Status**: ✓ Valid / ⚠️ Weakening / ❌ Falsified

### Step 4: Generate Alerts

**Alert Categories**:

**🔴 ACTION REQUIRED** (Urgent):
- Stop loss hit (verify execution)
- Thesis falsified (exit immediately)
- Risk limit exceeded
- Invalidation level broken on volume

**🟡 REVIEW NEEDED** (This Week):
- Target reached (take profit)
- Time stop approaching
- Thesis weakening (warning signs)
- News affecting position
- Volatility spike

**🟢 MILESTONE** (Positive):
- Target 1 reached (scale out, move stop to breakeven)
- Target 2 reached (scale out, begin trail)
- Significant progress

**🔵 INFORMATIONAL**:
- Position updates (X days held, +/-X%)
- Approaching review checkpoint
- Portfolio metrics update

### Step 5: Calculate Portfolio Metrics

**Portfolio Heat** (Total Risk):
```
Total Heat = Σ (Position Size × % to Stop) for all positions
```

**Position Count**: X open positions

**Sector Exposure**: % in each sector

**Cash Reserve**: % in cash

**Portfolio Performance**:
- Unrealized P&L
- % gain/loss since inception

**Status Checks**:
- Portfolio heat ≤8%? (✓ / ⚠️ / ❌)
- Sector concentration ≤50%? (✓ / ⚠️)
- Cash reserve ≥15%? (✓ / ⚠️)

### Step 6: Review Schedule Check

**Position Reviews**:
- Week 2: Quick progress check
- Week 4: Mid-point thesis review
- Week 8: Consider time stop if stalling

**Which positions are due for review?**

### Step 7: Generate Daily Report

Create comprehensive daily monitoring report.

## Output

Create/Update: `apex-os/reports/daily-monitor-YYYY-MM-DD.md`

Use format from portfolio-monitor agent definition.

## Alert Priority Handling

**If 🔴 ACTION REQUIRED alerts**:
- List first and highlight
- Provide specific action needed
- Urgency: Immediate (today)

**If 🟡 REVIEW NEEDED alerts**:
- List after action required
- Provide context
- Urgency: This week

**If only 🟢 or 🔵**:
- Standard monitoring
- No urgent action

## Next Actions

**After monitoring, typically**:
1. Address any ACTION REQUIRED items immediately
2. Schedule REVIEW NEEDED items this week
3. Update any stops or targets per plan
4. Document any position changes

## Important Notes

- **Run daily** (every trading day)
- **Don't ignore alerts** (they're there for a reason)
- **Act on falsification** (no rationalization)
- **Respect stops** (they protect capital)
- **Follow up on reviews** (don't let positions drift)

## Falsification Response

**If Thesis Falsified**:
1. Do NOT rationalize or hope
2. Exit position immediately (market order if needed)
3. Document reason in exit log
4. Move on (no regrets, process worked)

**This is success, not failure** (thesis falsification = risk management working)

## Success Criteria

- All positions tracked
- Thesis validity assessed
- Alerts generated appropriately
- Portfolio metrics calculated
- Report documented
- Action items clear

## Typical Timeline

- Load positions: 5 minutes
- Get prices: 5 minutes
- Evaluate each position: 5 minutes per position
- Calculate metrics: 5 minutes
- Generate report: 10 minutes
- **Total**: ~30-45 minutes (depends on # positions)

## Integration

**Triggers Other Actions**:
- If Target 1 hit → Scale out, move stop to breakeven
- If Target 2 hit → Scale out, begin trailing
- If Thesis falsified → Exit position
- If Time stop → Re-evaluate or exit
- If Stop hit → Verify exit, document

**Feeds Into**:
- Exit decisions
- Post-mortem analysis
- Portfolio reviews
- Risk management adjustments

## Remember

**Monitoring is NOT optional**:
- Unmonitored positions drift
- Thesis invalidation missed
- Stops not adjusted
- Opportunities (targets) missed

**Daily monitoring = Disciplined trading**

This is your daily ritual. Make it habitual.
