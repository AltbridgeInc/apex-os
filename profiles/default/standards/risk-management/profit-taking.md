# Profit Taking and Exit Strategy

## Principle

Knowing when and how to take profits is as important as knowing when to enter. Most traders are good at entries but poor at exits. **A good entry with a bad exit is still a bad trade.** Strategic profit taking locks in gains, manages risk, and allows winners to run while protecting capital.

## The Profit-Taking Dilemma

**The Paradox**:
- Exit too early = Miss big gains ("I sold AAPL at $120, it's now $180")
- Hold too long = Give back profits ("I was up 50%, now I'm up 5%")

**The Solution**: Scale out (take partial profits at targets, let remainder run)

## The Three-Target Scaling Strategy

### Target 1 (2:1 Risk/Reward) - Sell 1/3

**Objective**: Take money off the table, move to breakeven

**Calculation**:
```
If Risk = $2/share (Entry $50, Stop $48)
Target 1 = Entry + (2 × Risk) = $50 + $4 = $54
```

**Actions**:
1. Sell 1/3 of position at $54
2. Move stop on remaining 2/3 to breakeven ($50)
3. Position now risk-free (can't lose money)

**Psychology**:
- Banking some profit reduces anxiety
- Breakeven stop removes pressure
- Can let rest ride without fear

**Timing**: Place GTC limit order at Target 1 from day 1

### Target 2 (3:1 Risk/Reward) - Sell 1/3

**Objective**: Take more profit, begin trailing stop

**Calculation**:
```
Target 2 = Entry + (3 × Risk) = $50 + $6 = $56
```

**Actions**:
1. Sell another 1/3 at $56
2. Move stop on final 1/3 to Target 1 ($54)
3. Now holding 1/3 with $4/share locked in

**Result**:
- 1/3 sold at $54 (+$4)
- 1/3 sold at $56 (+$6)
- 1/3 riding with $54 stop (+$4 minimum)
- Minimum: +$14 total (+28% on 3-share equivalent)

**Timing**: Place GTC limit order at Target 2 from day 1

### Target 3 (Trailing Stop) - Trail Final 1/3

**Objective**: Let winner run indefinitely, protect with trail

**Trailing Stop Method**:
- Trail 15-20% below highest close (daily)
- Adaptive (widens as price rises)
- Lets position breathe while protecting

**Example**:
```
Current: $56 → Stop: $54
Rises to $60 → Stop: $54 (20% = $48, so still $54)
Rises to $70 → Stop: $63 (20% below $70 = $56, move to $63)
Rises to $80 → Stop: $72 (20% below $80 = $64, move to $72)
Pulls back to $73 → Still in (stop at $72)
Pulls back to $71 → Stopped out at $72
```

**Final Result**:
- 1/3 at $54: +$4
- 1/3 at $56: +$6
- 1/3 at $72: +$22
- **Total**: +$32 (+64% return)

**vs All or Nothing**:
- Sell all at $54: +$4/share (+8%)
- Hold all, stopped at $50: $0/share (0%)

**Trail Distance**:
- Aggressive: 10-15% trail (tighter)
- Moderate: 15-20% trail (standard)
- Loose: 20-25% trail (more room)

## Risk/Reward Ratios Explained

### Minimum R:R: 2:1

**Definition**: Potential reward is 2× potential risk

**Example**:
- Entry: $50
- Stop: $48 (risk $2)
- Target: $54 (reward $4)
- R:R = $4/$2 = 2:1

**Why 2:1 Minimum?**:
- With 50% win rate, break even: (50% × 2) - (50% × 1) = 0.5 = profitable
- With 40% win rate, still profitable: (40% × 2) - (60% × 1) = 0.2 = profitable
- Below 2:1 requires >50% win rate to profit

**Gate Requirement**: APEX-OS requires minimum 2:1 R:R (preferably 3:1)

### Preferred R:R: 3:1 or Higher

**Better Setup**:
- Entry: $50, Stop: $48 (risk $2)
- Target: $56 (reward $6)
- R:R = 3:1

**With 3:1 R:R**:
- 40% win rate: (40% × 3) - (60% × 1) = 0.6 = profitable
- 33% win rate: (33% × 3) - (67% × 1) = 0.32 = still profitable
- Can be wrong 2/3 of time and still make money

## Profit-Taking Methods

### Method 1: Fixed Targets (Recommended)

**Approach**: Predetermined price targets based on R:R and technical levels

**Advantages**:
- Unemotional (decided before entry)
- Systematic
- Easy to execute (GTC limit orders)

**How to Set**:
1. Calculate 2:1 R:R (Target 1)
2. Calculate 3:1 R:R (Target 2)
3. Identify next major resistance (validate targets)
4. Trail final portion

**Example**:
- Entry $50, Stop $48
- Target 1: $54 (2:1)
- Target 2: $56 (3:1)
- Target 3: Trail
- Place limit sell orders immediately

### Method 2: Technical Targets

**Approach**: Take profits at technical resistance levels

**Targets**:
- Previous swing high (tested resistance)
- Round numbers ($100, $150, $200)
- Fibonacci extensions (161.8%, 261.8%)
- Moving averages (in downtrend, MA is resistance)

**Combination**: Use R:R + Technical
- Target 1: 2:1 R:R OR nearest resistance (whichever first)
- Target 2: 3:1 R:R OR second resistance
- Target 3: Trail until major resistance

### Method 3: Pattern Measured Moves

**Approach**: Use pattern height for target

**Flag Example**:
- Flagpole: $50 → $60 (+$10)
- Breakout: $60
- Target: $60 + $10 = $70

**Cup & Handle**:
- Cup depth: $20
- Breakout: $120
- Target: $120 + $20 = $140

**Combine with Scaling**:
- Target 1 (2:1): $65
- Target 2 (Measured Move): $70
- Target 3: Trail

### Method 4: Time-Based

**Approach**: Exit after specific time

**Examples**:
- Earnings play: Exit before earnings (avoid volatility)
- Swing trade: Exit after 2-3 weeks regardless
- Catalyst: Exit after catalyst occurs

**Usage**: Supplement to price targets, not replacement

## When NOT to Take Profits Early

### Strong Momentum Continues

**Indicators**:
- Steep uptrend (>30° angle)
- Volume increasing on rallies
- Gaps up on open
- Breaking multiple resistance levels
- Strong relative strength vs market

**Action**: Don't exit just because "up a lot"
- Move stop to protect
- Let momentum work
- Trail tighter (10-15% instead of 20%)

### Thesis Playing Out Better Than Expected

**Example**:
- Expected 15% earnings growth, reported 30%
- Expected Target 1, blowing through all targets
- New catalyst emerged

**Action**: Re-evaluate thesis
- Update targets higher
- Tighten trail but stay in
- Consider adding (if stop moved to breakeven)

### Tax Considerations (Taxable Accounts)

**Short-term vs Long-term**:
- <12 months: Short-term cap gains (ordinary income tax)
- >12 months: Long-term cap gains (preferably 15-20%)

**Strategy**:
- If close to 12 months and modest profit, consider waiting
- If huge profit or thesis weakening, take it regardless
- Don't let tax tail wag investment dog

## When TO Take Profits Early

### Profit Target Reached

**Simple**: When target hit, execute sale
- Target 1: Sell 1/3, move stop to breakeven
- Target 2: Sell 1/3, trail final piece
- No greed, stick to plan

### Momentum Weakening

**Warning Signs**:
- Volume declining on rallies
- Failing to make new highs
- Large wicks (rejection at highs)
- Price stalling at resistance

**Action**: Take partial or full profits
- At minimum: Tighten stop
- If multiple signs: Exit 1/3 or 1/2
- If clear reversal pattern: Exit fully

### Thesis Invalidated

**Reasons**:
- Fundamental change (earnings miss, guidance cut)
- Technical breakdown (broke support)
- Catalyst didn't materialize
- Better opportunity elsewhere

**Action**: Exit immediately (don't wait for targets)
- Thesis wrong = no reason to hold
- Exit at market (don't wait for limit)

### Extreme Parabolic Move

**Pattern**:
- Vertical rise (>20% in 1-2 days)
- Climax volume (3-5× average)
- Everyone euphoric
- "Can't go down" sentiment

**History**: These moves almost always pull back hard
- FOMO crowd buys top
- Early buyers sell into strength
- Exhaustion gap

**Action**: Take profits into strength
- Sell into the euphoria
- Don't wait for reversal
- Okay to leave some on table

### Portfolio Rebalancing

**Reason**: Position grown too large

**Example**:
- Position was 8% of portfolio
- Stock doubled, now 15% of portfolio
- Too concentrated (single stock risk)

**Action**: Trim to target allocation
- Sell enough to bring back to 10-12%
- Lock in some gains
- Maintain diversification

## Profit Protection

### Move to Breakeven

**When**: After Target 1 reached (2:1 R:R achieved)

**Action**: Move stop to entry price
- Can no longer lose money
- Position now "risk-free"
- Removes psychological pressure
- Frees mind to let rest run

**Example**:
- Entry $50, Stop $48
- Reaches $54 (+$4, 2:1 R:R)
- Sell 1/3, move stop on rest to $50
- If stopped out: breakeven on remaining, profit on 1/3 sold

### Lock in Profits

**When**: After significant gains (>20%)

**Action**: Move stop to lock in minimum profit
- Up 20%: Move stop to +10%
- Up 50%: Move stop to +25%
- Protect substantial gains

**Example**:
- Entry $50
- Current $75 (+$25, +50%)
- Move stop to $63 (+$13, +26% protected)
- Lets it run higher but protects if reverses

### Trailing Stop Strategy

**Purpose**: Lock in more profit as stock rises

**Methods**:

**Percentage Trail**:
- Trail 15-20% below highest close
- Updates daily
- Simple to implement

**Chandelier Stop**:
- Trail 3× ATR below highest close
- Adapts to volatility
- More sophisticated

**MA Trail**:
- Trail below 20-day or 50-day MA
- Uses MA as support
- Good for trending stocks

**Example (20% Trail)**:
```
$60 → Stop $48 (entry breakeven)
$70 → Stop $56 (20% below)
$80 → Stop $64 (20% below)
$75 → Stop still $64 (only moves up, never down)
$90 → Stop $72 (20% below)
$85 → Stop still $72
$84 → Stopped out at $72 (+$22, +44%)
```

## Common Profit-Taking Mistakes

### Mistake 1: Taking Profits Too Early
**Problem**: "Up 10%, I'll sell" (then it goes to +50%)
**Solution**: Use 3-target system, let final 1/3 run

### Mistake 2: Never Taking Profits
**Problem**: "Let winners run" becomes "let winners become losers"
**Solution**: Scale out, protect profits with stops

### Mistake 3: Selling All at Once
**Problem**: All or nothing (miss the middle ground)
**Solution**: Sell 1/3 at a time

### Mistake 4: No Predetermined Plan
**Problem**: Emotional decisions in heat of moment
**Solution**: Set targets before entry

### Mistake 5: Moving Targets Higher
**Problem**: Greed (Target was $60, now it's $70, then $80...)
**Solution**: Stick to original plan (or have good reason to adjust)

### Mistake 6: Holding Through Reversals
**Problem**: "I was up 50%, now I'm up 5%"
**Solution**: Trail stops, protect profits

### Mistake 7: Letting Winners Become Losers
**Problem**: +40% → +10% → -5%
**Solution**: Move stop to breakeven after Target 1, lock in profits after Target 2

## Profit Taking Checklist

Before entry, document:
- [ ] Target 1 (2:1 R:R): $XX
- [ ] Target 2 (3:1 R:R): $XX
- [ ] Target 3: Trail method (15-20% below high)
- [ ] Action at Target 1: Sell 1/3, move stop to breakeven
- [ ] Action at Target 2: Sell 1/3, begin trail
- [ ] Trail stop distance: XX%
- [ ] Place GTC limit orders for Target 1 and 2

## Integration with APEX-OS

### Pre-Investment
- **risk-manager** calculates Target 1 and 2 based on stop distance
- **technical-analyst** identifies resistance levels
- Targets documented in position-plan.md
- **Gate 2 Requirement**: R:R minimum 2:1, preferably 3:1

### Entry Execution
- **executor** places GTC limit orders at Target 1 and Target 2
- Documents order details
- Verifies orders active

### During Hold Period
- **portfolio-monitor** tracks progress toward targets
- Alerts when approaching Target 1 or 2
- Moves stop to breakeven after Target 1 fills
- Begins trailing after Target 2 fills

### Exit Execution
- **executor** verifies partial fills at targets
- Adjusts stops as planned
- Trails final position
- Documents all exits in exit-log.md

## Best Practices

1. **Plan Before Entry**: Know all 3 targets before buying
2. **Scale Out**: Sell 1/3 at Target 1, 1/3 at Target 2, trail final 1/3
3. **Move to Breakeven**: After Target 1, position becomes risk-free
4. **Trail Winners**: Let final piece run with trailing stop
5. **Place Limit Orders**: Set GTC orders at targets (unemotional execution)
6. **Minimum 2:1 R:R**: Never take trade with less
7. **Protect Profits**: Trail stop locks in gains
8. **Stick to Plan**: Don't get greedy, don't get scared
9. **Take Profits into Strength**: Sell when others are buying
10. **Accept Leaving Money on Table**: Perfect exits don't exist

## Real-World Example

**Setup**:
- Entry: $50
- Stop: $48 (risk $2, 4% risk)
- Position: 750 shares ($37,500)
- Target 1: $54 (2:1)
- Target 2: $56 (3:1)
- Target 3: Trail 20%

**Trade Progression**:
- Day 10: Hits $54 → Sell 250 shares (+$1,000), move stop to $50
- Day 18: Hits $56 → Sell 250 shares (+$1,500), stop on final 250 at $54
- Day 25: Climbs to $65 → Stop now at $58 (20% trail)
- Day 30: Climbs to $72 → Stop now at $65
- Day 33: Pulls back to $66 → Stopped out at $65 (+$3,750)

**Results**:
- 250 shares at $54: +$1,000
- 250 shares at $56: +$1,500
- 250 shares at $65: +$3,750
- **Total P&L**: +$6,250 (+16.7% on $37,500)
- **R:R Achieved**: ~4.2:1

**Compare to Alternatives**:
- Sold all at $54: +$3,000 (8%)
- Held all, trailed from entry: Likely stopped around $60: +$7,500 (20%)
- Held all, no stop: Gave back gains if reversed

**Lesson**: Scaling strategy balanced taking profit and letting winners run

Remember: **"Bulls make money, bears make money, pigs get slaughtered."** Take your profits systematically.
