# Stop Loss Placement

## Principle

A stop loss is a predetermined exit point that limits losses when a trade goes against you. It's the single most important risk management tool - protecting capital is more important than making profits. **Never enter a trade without knowing exactly where you'll exit if wrong.** Stops are not suggestions; they are mandatory exits.

## Core Concepts

### Why Stop Losses Are Non-Negotiable

**1. Capital Preservation**:
- Small losses are recoverable, large losses are devastating
- Lose 50% requires 100% gain to recover
- Stops keep losses small and manageable

**2. Emotional Protection**:
- Prevents hope, denial, and rationalization
- Removes emotion from exit decision
- Decided when rational (before entry), not emotional (during loss)

**3. Thesis Falsification**:
- Stop level = where thesis is wrong
- If hit, setup failed, exit immediately
- Don't argue with the market

**4. Enables Compounding**:
- Small consistent losses + occasional big wins = profitable
- No stops = occasional catastrophic loss = account blown

### The Cardinal Rule

**MUST place stop loss IMMEDIATELY after entry**
- Not "later"
- Not "I'll watch it"
- Not "mental stop"
- Immediately = within 1 minute of fill

## Stop Loss Methods

### 1. Technical Stop (Preferred)

**Definition**: Stop below nearest support level (longs) or above resistance (shorts)

**How to Determine**:
- Identify clear support level below entry
- Add 1-2% buffer for volatility/false breaks
- That's your stop

**Example**:
- Entry: $52
- Support level: $50
- Buffer: 2% = $1
- Stop: $49 (below support + buffer)

**Advantages**:
- Logical (based on price structure)
- Gives trade room to breathe
- Invalidation meaningful (support broken = setup failed)

**Disadvantages**:
- Can be far from entry (wide stop)
- May exceed 2% risk tolerance

**When to Use**: When clear technical support exists and within risk tolerance

### 2. ATR-Based Stop

**Definition**: Stop based on Average True Range (volatility)

**Formula**:
```
Stop Loss = Entry - (2.5 × ATR)
```

**Example**:
- Entry: $50
- ATR: $2
- Stop: $50 - (2.5 × $2) = $45

**Advantages**:
- Adapts to volatility automatically
- Gives volatile stocks more room
- Tighter stops for low volatility stocks
- No support level needed

**Disadvantages**:
- Purely mathematical (ignores price structure)
- May be too wide or too tight for specific setup

**When to Use**: When no clear technical level exists, or to verify technical stop is reasonable

### 3. Percentage Stop

**Definition**: Fixed percentage below entry

**Typical**: 5-8% stop
- 5%: Tight stop (momentum, breakouts)
- 7%: Standard stop (most trades)
- 8%: Maximum (never wider)

**Example**:
- Entry: $50
- 7% stop: $46.50

**Advantages**:
- Simple to calculate
- Consistent across trades
- Easy to size positions (uniform risk)

**Disadvantages**:
- Ignores technical levels
- May be too tight (stopped out on noise)
- May be too wide (giving up too much)

**When to Use**: Last resort when no technical level and want consistency

### 4. Time Stop

**Definition**: Exit after specific time period if no progress

**Examples**:
- Exit if no movement toward Target 1 in 2 weeks
- Exit if position still negative after 4 weeks
- Exit if no breakout from consolidation in 8 weeks

**Usage**:
- Supplement to price stops (not replacement)
- Frees up capital from stagnant positions
- Prevents "dead money" situations

**Note**: Not a substitute for price-based stop loss

## Stop Loss Placement Guidelines

### Minimum Buffer from Support

**Problem**: Placing stop exactly at support gets you stopped out on brief dip

**Solution**: Buffer below support
- **Low Volatility** (ATR <2%): 1% buffer
- **Medium Volatility** (ATR 2-3%): 1.5% buffer
- **High Volatility** (ATR >3%): 2% buffer

**Example**:
- Support: $100
- ATR: 3% (volatile)
- Stop: $98 (2% buffer below support)

### Maximum Stop Distance

**Absolute Rule**: Stop should never be >8% from entry

**Rationale**:
- 8% loss requires 8.7% gain to recover
- 10% loss requires 11% gain
- 20% loss requires 25% gain
- 50% loss requires 100% gain

**If Technical Stop >8%**:
- Reduce position size (not widen stop)
- Consider passing on trade (risk too high)
- Wait for better entry point

### Stop Loss Hierarchy

**Priority Order**:
1. Technical stop (if within 8% and makes sense)
2. ATR-based stop (if technical unclear)
3. Percentage stop (if above don't work)
4. Maximum 8% (never exceed under any circumstance)

## Stop Management During Trade

### Initial Stop Placement

**When**: Immediately after entry fill
**Type**: Stop market or stop limit
**Duration**: GTC (Good Till Canceled)
**Important**: Verify order confirmed and active

### Moving Stops (Trailing)

**Never Move Stop Wider** (away from entry):
- ❌ Entry $50, stop $48 → Never move to $47
- That's hoping, not trading

**Move Stop to Breakeven**:
- When: After reaching Target 1 (typically 2:1 R:R)
- Move stop to entry price
- Locks in scratch (no loss)
- Lets rest of position ride risk-free

**Trail Stop Up**:
- When: After Target 2, or strong momentum continuation
- How: Trail 15-20% below highest close
- Lets winners run while protecting profits

**Example**:
```
Entry: $50, Stop: $48 (risk $2)
Target 1: $54 reached → Move stop to $50 (breakeven)
Climbs to $60 → Move stop to $54 (trail 10% below $60)
Climbs to $70 → Move stop to $63 (trail 10% below $70)
Pulls back to $64 → Still in (above $63 stop)
Pulls back to $62 → Stopped out at $63 (+$13/share, +26%)
```

### When to Hold the Line

**Never Move Stop Before Target 1**:
- Stop is stop for a reason
- Moving wider = denying reality
- If technical level breaks, setup failed, exit

**Exception**: Can tighten stop (move closer) if:
- Setup rapidly deteriorating
- Better opportunity elsewhere
- Changed thesis

### Mental Stops (Don't Use Them)

**Problem with Mental Stops**:
- Require discipline in heat of moment
- "I'll watch it and decide" = rationalization
- Often don't execute ("maybe it'll come back")
- Fear, hope, and denial take over

**Reality**: 95% of traders don't execute mental stops when needed

**Solution**: Always use hard stops (orders in system)

### Stop Loss Orders

**Stop Market**:
- Triggers market order when stop hit
- Guaranteed execution (may slippage on price)
- Recommended for most situations

**Stop Limit**:
- Triggers limit order when stop hit
- Price protection but may not fill (gap through)
- Risky in fast moves (can gap past limit, no fill)

**Recommendation**: Use stop market (execution more important than price)

## Avoiding Stop Hunts

### What is a Stop Hunt?

**Pattern**: Brief break below support → Triggers stops → Immediate reversal back up

**Why It Happens**:
- Algos and pros know where stops are (obvious levels)
- Purposely push price to trigger stops
- Buy the panic selling (your stop = their entry)

### Protection Strategies

**1. Buffer Below Obvious Levels**:
- Support at $100 → Don't stop at $99.95
- Stop at $98 (below round number and support)

**2. Use Support Zones, Not Lines**:
- Support zone: $98-100 (not exactly $100)
- Stop below zone: $97.50

**3. Avoid Round Numbers**:
- Don't stop at $50.00 (obvious)
- Stop at $49.30 or $48.75 (less obvious)

**4. Require Close Below Support**:
- Brief wick below support = noise
- Close below support = broken
- Wait for confirming close (but dangerous - could gap)

### False Breaks vs Real Breaks

**False Break** (Fakeout):
- Wicks below support, closes back above
- Low volume
- Quick reversal
- Often leads to strong move opposite direction

**Real Break**:
- Closes below support
- High volume (1.5-2x average)
- Follow-through next day
- No immediate recovery

**Dilemma**: Hard to tell in real-time. This is why stops are necessary.

## Stop Loss Discipline

### Rules for Stop Execution

**1. Stop is Stop**:
- No "let's see if it comes back"
- No "it's just temporary"
- No "I'll give it more room"
- Exit immediately when hit

**2. No Second Chances**:
- Don't re-enter same trade immediately after stopped out
- Setup failed, move on
- Can re-evaluate after 2-3 days if structure changes

**3. No Averaging Down**:
- Don't add to losing position
- "Averaging down" = throwing good money after bad
- Only add to winners (after moving stop to breakeven)

**4. Accept the Loss**:
- Small losses are part of trading
- 50-60% win rate means 40-50% losses
- Move on emotionally, don't dwell

### Psychology of Stops

**Common Emotions When Stop Hit**:
- Frustration: "Why did I get stopped?"
- Denial: "It's coming back up!"
- Revenge: "I'll show the market!"

**Healthy Response**:
- Acceptance: "Setup didn't work, that's okay"
- Analysis: "Why did it fail? Learn anything?"
- Next: "What's my next best opportunity?"

**Remember**: Every successful trader has thousands of stopped-out trades. It's normal.

## Stop Loss Scoring (Risk Management)

### Excellent Stop Placement (Score 9-10)
- Clear technical level with meaningful invalidation
- 1-2% buffer for noise
- Within 5% of entry
- Risk 1-2% of portfolio
- Stop placed immediately after entry
- Proper order type (GTC stop market)

### Good Stop Placement (Score 7-8)
- Reasonable technical or ATR-based stop
- Adequate buffer
- Within 6-7% of entry
- Risk 1.5-2% of portfolio
- Placed promptly

### Average Stop Placement (Score 5-6)
- Logical stop but imperfect
- Within 8% of entry
- Risk acceptable
- Placed same day

### Poor Stop Placement (Score 3-4)
- Arbitrary stop (no clear logic)
- Too wide (>8%) or too tight (<3%)
- Risk >2% of portfolio
- Delayed placement

### Unacceptable (Score 0-2)
- No stop placed
- Mental stop only
- Risk >3% of portfolio
- Stop wider than 10%
- Stop at obvious level (stop hunt bait)

## Integration with APEX-OS

### Pre-Investment
- **technical-analyst** identifies technical stop level
- **risk-manager** verifies stop within 8%, calculates position size based on stop
- Stop level documented in position-plan.md
- **Gate 2 Requirement**: Stop loss identified and within risk tolerance

### Entry Execution
- **executor** places stop loss IMMEDIATELY after fill
- Verifies stop order confirmed and active
- Documents stop details in entry-log.md
- **Gate 3 Requirement**: Stop loss placed and confirmed

### During Hold Period
- **portfolio-monitor** tracks distance to stop
- Alerts if approaching stop (within 5%)
- Never moves stop wider
- Moves to breakeven after Target 1

### Exit Execution
- If stopped out, **executor** verifies fill
- Documents in exit-log.md
- No re-entry same day
- **post-mortem-analyst** reviews stop placement appropriateness

## Best Practices

1. **Identify Stop Before Entry**: Know your exit before you enter
2. **Place Immediately**: Within 1 minute of fill, no exceptions
3. **Use Hard Stops**: No mental stops (95% fail to execute)
4. **Buffer Below Support**: 1-2% below obvious levels (avoid stop hunts)
5. **Maximum 8%**: Never exceed 8% stop distance
6. **Never Move Wider**: Can tighten, never loosen
7. **Execute Without Hesitation**: When hit, exit immediately
8. **Move to Breakeven**: After Target 1, lock in scratch
9. **Trail on Winners**: 15-20% below highest close after Target 2
10. **Accept and Move On**: Losses are part of process, don't dwell

## Common Mistakes

- No stop loss placed ("I'll watch it")
- Mental stops (not executed when needed)
- Stop too wide (>8% from entry)
- Stop exactly at obvious support ($100.00)
- No buffer for volatility (stopped on noise)
- Moving stop wider (denying reality)
- Not executing when hit ("let me see...")
- Re-entering immediately after stopped out
- Averaging down on losing position

**Remember**: A stop loss is your seatbelt. You might feel constrained, but it saves your life in a crash.
