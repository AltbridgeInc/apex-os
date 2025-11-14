# Position Sizing and Risk Management Workflow

## Workflow

### Step 1: Review Portfolio Context

**Current Portfolio**:
- Total portfolio value
- Number of open positions
- Current total risk exposure
- Sector/asset allocation
- Cash available

### Step 2: Analyze Proposed Position

**Inputs Needed**:
- Ticker symbol
- Entry price (proposed)
- Stop loss level (from technical-analyst)
- Position timeline (weeks to months)

### Step 3: Calculate Position Size

**Formula**: Position Size = (Portfolio × Risk%) / (Entry Price - Stop Loss)

**Example**:
```
Portfolio: $100,000
Risk per trade: 1.5%
Risk amount: $1,500

Entry: $50
Stop: $48
Risk per share: $2

Position size: $1,500 / $2 = 750 shares
Total cost: $37,500
```

**Risk Per Trade Guidelines**:
- Conservative: 1.0%
- Moderate: 1.5%
- Aggressive: 2.0% (MAXIMUM)

**Never exceed 2% risk per trade**

### Step 4: Verify Portfolio Constraints

**Position Size Limit**:
- Maximum 10-15% of portfolio per position
- Even if risk calculation allows more

**Portfolio Heat Limit**:
- Current risk + new risk ≤ 6-8% of portfolio
- If exceeded, cannot add position (exit another first)

**Sector Concentration**:
- Maximum 50% in any sector
- Check correlation with existing positions

**Cash Reserve**:
- Maintain minimum 20% cash
- Don't be 100% invested

### Step 5: Set Stop Loss

**Stop Loss Methods**:

1. **Technical Stop** (preferred):
   - Below support level
   - Add 1-2% buffer for false breaks

2. **ATR-Based Stop**:
   - 2-3× ATR below entry
   - Accounts for volatility

3. **Percentage Stop**:
   - Fixed % below entry (e.g., 7%)
   - Maximum: 8% stop (never wider)

**Recommendation**: Use technical stop if clear, otherwise ATR-based

### Step 6: Calculate Risk/Reward

**Profit Targets** (from technical-analyst):
- Target 1: $XX
- Target 2: $XX
- Target 3: $XX

**Risk/Reward Calculation**:
```
Risk: Entry - Stop = $X per share
Reward (Target 1): Target 1 - Entry = $Y per share
R:R ratio: Y / X = Z:1
```

**Minimum R:R**: 2:1

- If R:R <2:1, position fails gate (don't take trade)
- Prefer R:R ≥3:1

### Step 7: Generate Position Plan

Create comprehensive position plan with all parameters.

## Output Format

Create file: `apex-os/analysis/YYYY-MM-DD-TICKER/position-plan.md`

```markdown
# Position Plan: [TICKER]

**Risk Manager**: risk-manager
**Date**: YYYY-MM-DD

## Portfolio Context

**Current Portfolio**:
- Total Value: $XXX,XXX
- Open Positions: X
- Current Risk: X.X%
- Available Risk Capacity: X.X%
- Sector Exposure: [breakdown]
- Cash Reserve: XX%

## Position Sizing Calculation

**Risk Parameters**:
- Risk per trade: X.X% of portfolio
- Risk amount: $X,XXX

**Entry & Stop**:
- Proposed entry: $XX.XX
- Stop loss: $XX.XX
- Risk per share: $X.XX

**Position Size**:
- Shares: XXX
- Total cost: $XX,XXX
- % of portfolio: XX%

**Validation**:
- ✓ Position size <15% of portfolio
- ✓ Risk per trade <2% of portfolio
- ✓ Total portfolio heat <8%
- ✓ Sector exposure acceptable
- ✓ Cash reserve maintained

## Risk Management

**Stop Loss**:
- Level: $XX.XX
- Method: [Technical/ATR/Percentage]
- Distance: XX% from entry
- Reasoning: [Why this level]

**Order Type**: Stop market / Stop limit at $XX.XX

**MUST be placed immediately after entry**

## Profit Targets

**Scale-Out Strategy**:

**Target 1** (2:1 R:R):
- Price: $XX.XX
- Sell: 1/3 position (XXX shares)
- Expected profit: $XXX
- Action: Move stop to breakeven on remaining

**Target 2** (3:1 R:R):
- Price: $XX.XX
- Sell: 1/3 position (XXX shares)
- Expected profit: $XXX
- Action: Trail stop on final 1/3

**Target 3** (Trail):
- Trail at 15-20% below peak
- Let final 1/3 run

## Risk/Reward Summary

**Total Risk**: $X,XXX (X.X% of portfolio)

**Potential Rewards**:
- Target 1: $XXX (X.X:1)
- Target 2: $XXX (X.X:1)
- Target 3: $XXX+ (variable)
- **Combined**: ~$X,XXX+ (X.X:1 overall)

**Minimum R:R Met**: ✓ / ✗ (≥2:1 required)

## Position Timeline

**Expected Hold**: X-XX weeks
**Review Frequency**: Weekly
**Time Stop**: If no progress after XX weeks, re-evaluate

## Correlation Check

**Similar Positions**:
- [List any correlated positions]
- [Assess if too much exposure to same theme]

**Sector Exposure After Entry**:
- [Sector]: XX% (acceptable / warning)

## Approval

**Position Approved**: ✓ / ✗

**Reasoning**: [Why approved or rejected]

**Special Conditions**: [Any modifications needed]
```

## Important Constraints

- **NEVER allow >2% risk per trade**: Absolute maximum
- **MUST calculate position size mathematically**: No guessing
- **MUST verify all constraints**: Position size, portfolio heat, sector limits
- **MUST enforce minimum R:R**: ≥2:1 required
- **Can reject positions**: If risk parameters aren't met

## Red Flags (Reject Position)

- R:R <2:1 (risk not worth reward)
- Portfolio heat would exceed 8% (too much total risk)
- Position would be >15% of portfolio (over-concentration)
- Sector would exceed 50% (sector risk)
- Cash reserve would drop below 20% (under-reserved)
- Stop loss >8% from entry (stop too wide)

## Investment Principles

Automatically apply these principles (auto-loaded as skills):
- `risk-position-sizing`
- `risk-stop-loss-management`
- `risk-profit-taking`
- `risk-portfolio-diversification`
