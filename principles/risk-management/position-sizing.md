# Position Sizing

## Principle

Position sizing is the most critical yet most overlooked aspect of trading. It mathematically determines how much capital to risk on each trade based on predefined risk tolerance. Proper position sizing protects capital during losing streaks and allows compounding during winning streaks. **It's not about picking winners; it's about managing risk.**

## Core Formula

### The Position Sizing Formula

```
Position Size = (Portfolio Value × Risk %) / (Entry Price - Stop Loss)
```

**Variables**:
- **Portfolio Value**: Total investable capital
- **Risk %**: How much you're willing to lose on this trade (1-2%)
- **Entry Price**: Planned entry point
- **Stop Loss**: Price where you'll exit if wrong

### Example Calculation

**Given**:
- Portfolio: $100,000
- Risk per trade: 1.5% ($1,500)
- Entry price: $50
- Stop loss: $48
- Risk per share: $2

**Calculation**:
```
Position Size = $1,500 / $2 = 750 shares
Total Cost = 750 × $50 = $37,500 (37.5% of portfolio)
```

**Result**: Buy 750 shares at $50
- If stopped out at $48: Lose $1,500 (exactly 1.5% of portfolio)
- If rallies to $60: Gain $7,500 (7.5% of portfolio)

## Risk Per Trade Guidelines

### Conservative (Recommended for Most)
**Risk**: 1.0% per trade
- **Rationale**: Can survive 20+ consecutive losses without major damage
- **Best for**: New traders, volatile markets, uncertainty
- **Portfolio Impact**: 10 positions at 1% risk = 10% total portfolio heat

### Moderate (Standard)
**Risk**: 1.5% per trade
- **Rationale**: Balance between growth and preservation
- **Best for**: Experienced traders, normal markets
- **Portfolio Impact**: 8 positions at 1.5% risk = 12% total portfolio heat

### Aggressive (Maximum)
**Risk**: 2.0% per trade
- **Rationale**: Faster growth but higher drawdown risk
- **Best for**: Very experienced, high conviction, favorable conditions
- **Portfolio Impact**: 6 positions at 2% risk = 12% total portfolio heat

### NEVER EXCEED 2%
**Critical Rule**: Never risk more than 2% on single trade
- Protects from catastrophic losses
- Allows recovery from mistakes
- 50 consecutive 2% losses = 50% drawdown (recoverable)
- 5 consecutive 10% losses = 50% drawdown (devastating)

## Position Size Constraints

### Maximum Position Size (% of Portfolio)

Even if risk calculation allows more, cap individual positions:

**Hard Limits**:
- **Maximum**: 15% of portfolio in any single position
- **Target**: 8-12% per position (optimal diversification)
- **Minimum**: 3-5% per position (too small = not worth the effort)

**Rationale**:
- Concentration risk (one position tanks, portfolio tanks)
- Opportunity cost (capital trapped)
- Psychological impact (too large positions cause emotional decisions)

**Adjustment**:
If risk calculation exceeds 15% of portfolio, reduce position size to 15% maximum and accept higher stop loss percentage.

### Portfolio Heat (Total Risk Exposure)

**Definition**: Sum of all open position risks

**Formula**:
```
Portfolio Heat = Σ (Position Size × Distance to Stop) for all positions
```

**Guidelines**:
- **Maximum**: 8% of portfolio at risk across all positions
- **Target**: 5-6% typical
- **Conservative**: 3-4% during uncertain markets

**Example**:
- Position 1: 1.5% risk
- Position 2: 1.5% risk
- Position 3: 1.0% risk
- Position 4: 1.5% risk
- Position 5: 1.0% risk
- **Total Heat**: 6.5% (acceptable)

**Rule**: If adding new position would exceed 8% heat, must exit existing position first

## Position Sizing Adjustments

### Adjust for Confidence Level

**High Conviction** (8-10 fundamental + technical scores):
- Risk 1.5-2.0% (upper end of range)
- Larger position size justified
- Strong thesis, multiple confirmations

**Medium Conviction** (6-7 scores):
- Risk 1.0-1.5% (middle range)
- Standard position sizing
- Good setup but not perfect

**Low Conviction** (5-6 scores):
- Risk 0.5-1.0% (lower end)
- Smaller position or skip entirely
- Marginal setup

### Adjust for Market Conditions

**Bull Market** (VIX < 15, uptrend established):
- Risk upper end of range (1.5-2%)
- Favorable conditions
- Can carry more positions

**Normal Market** (VIX 15-25):
- Standard risk (1-1.5%)
- Neutral conditions
- Standard portfolio construction

**Volatile/Bear Market** (VIX > 25, downtrend):
- Risk lower end (0.5-1%)
- Defensive posture
- Fewer positions, more cash

### Adjust for Win/Loss Streaks

**After Losing Streak** (3+ consecutive losses):
- Reduce risk to 0.5-1% temporarily
- Something may be wrong (process, market, you)
- Preserve capital, rebuild confidence
- Return to normal after 2 consecutive wins

**After Winning Streak** (5+ consecutive wins):
- Maintain standard risk (don't get cocky)
- Consider taking chips off table (raise cash %)
- Avoid overconfidence trap

**Golden Rule**: **Never** increase risk after losses to "make it back" (revenge trading = disaster)

## Position Sizing Mistakes to Avoid

### Mistake 1: Equal Dollar Amounts
**Wrong**: Buy $10,000 of every stock
- Ignores distance to stop loss
- One position might risk 2%, another 10%
- Inconsistent risk management

**Right**: Calculate based on stop distance

### Mistake 2: Equal Share Amounts
**Wrong**: Buy 500 shares of everything
- Doesn't account for price or risk
- 500 shares of $10 stock ≠ 500 shares of $100 stock

**Right**: Shares determined by risk formula

### Mistake 3: "I Have $50K, So I'll Buy $50K Worth"
**Wrong**: Going all-in or max position immediately
- No risk management
- No diversification
- One bad trade = major damage

**Right**: Position size determined by risk % and stop distance

### Mistake 4: Risking Too Much
**Wrong**: "I'm confident, so I'll risk 10%"
- One bad trade wipes out 10 good 1% winners
- Catastrophic to account
- Impossible to recover from 3-4 consecutive losses

**Right**: Never exceed 2% risk per trade

### Mistake 5: Not Using Formula
**Wrong**: Guessing position size "that feels right"
- Emotional decision
- Inconsistent
- Often way too large or too small

**Right**: Always calculate mathematically

## Advanced Position Sizing

### Scaling In (Dollar Cost Averaging)

**Method**: Enter position in 2-3 tranches

**Example**:
- Total planned: 900 shares at average $50 (risk 1.5%)
- Tranche 1: Buy 300 shares at $50
- Tranche 2: Buy 300 shares at $48.50 (pullback)
- Tranche 3: Buy 300 shares at $47 (deeper pullback)
- Average: $48.50, better than buying all at $50

**Advantages**:
- Lower average cost
- Reduces timing risk
- Psychologically easier

**Disadvantages**:
- May miss move if doesn't pull back
- More complex to manage
- Stop loss adjustments needed

**When to Use**: Larger positions (>$30K), choppy entries

### Pyramiding (Adding to Winners)

**Method**: Add to position after initial profit

**Example**:
- Initial: Buy 500 shares at $50 (risk $1,500 at $47 stop)
- Stock moves to $55
- Add: Buy 300 more shares at $55 (move stop on initial to $52, breakeven)
- Total: 800 shares, average $51.88

**Rules**:
- Only add to winners (never average down on losers)
- Move stop on original position to breakeven before adding
- Second position smaller than first (500 → 300)
- Total portfolio heat still within limits

**Advantage**: Compounds winners (where you make money)

### Kelly Criterion (Advanced)

**Formula**:
```
Kelly % = (Win Rate × Avg Win - Loss Rate × Avg Loss) / Avg Win
```

**Example**:
- Win rate: 60%
- Avg win: 8%
- Loss rate: 40%
- Avg loss: 3%
```
Kelly = (0.60 × 8 - 0.40 × 3) / 8 = 3.6 / 8 = 45%
```

**Interpretation**: Kelly suggests risking 45% of capital (WAY too aggressive)

**Half-Kelly**: Use 50% of Kelly calculation = 22.5% (still too much)

**Quarter-Kelly**: Use 25% of Kelly = 11.25% (getting reasonable)

**Note**: Kelly is theoretical maximum, not practical recommendation. Most traders use fixed % (1-2%) which is far more conservative and sustainable.

## Position Sizing Checklist

Before entering any trade:
- [ ] Calculate risk per share (Entry - Stop)
- [ ] Determine risk amount (Portfolio × Risk %)
- [ ] Calculate position size (Risk $ / Risk per share)
- [ ] Verify position < 15% of portfolio
- [ ] Check total portfolio heat < 8%
- [ ] Confirm have enough capital for position
- [ ] Adjust for conviction level if needed
- [ ] Document position size in position plan

## Integration with APEX-OS

### Pre-Investment
- **risk-manager** agent calculates position size
- Uses formula: (Portfolio × Risk %) / (Entry - Stop)
- Verifies all constraints (15% max, 8% heat, cash reserve)
- Documents in position-plan.md
- **Gate 2 Requirement**: Position size mathematically correct

### During Hold Period
- **portfolio-monitor** tracks total portfolio heat
- Alerts if risk exposure approaching limits
- Prevents adding positions if would exceed 8% heat

### After Trade
- **post-mortem-analyst** reviews position sizing
- Was size appropriate for conviction/conditions?
- Did constraints work as intended?
- Learn and adjust for future trades

## Best Practices

1. **Always Use the Formula**: Never guess or "feel" position size
2. **Risk Small**: 1-2% maximum, bias toward 1% for most trades
3. **Check Portfolio Heat**: Sum of all risks ≤ 8%
4. **Cap Position Size**: No position > 15% of portfolio
5. **Adjust for Conviction**: High conviction = higher end of range
6. **Reduce After Losses**: Drop to 0.5-1% after 3 consecutive losses
7. **Document Everything**: Write down calculation (prevents errors)
8. **When in Doubt, Smaller**: Better to be too small than too large

## Common Pitfalls

- Not calculating position size (winging it)
- Risking too much (>2% per trade)
- Letting single position exceed 15% of portfolio
- Ignoring portfolio heat (total risk)
- Increasing risk after losses (revenge trading)
- Not adjusting for conviction or market conditions
- Using equal dollar or share amounts instead of formula

**Remember**: Position sizing is not optional. It's the difference between surviving to trade another day and blowing up your account.
