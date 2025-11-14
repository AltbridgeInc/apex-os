# Valuation Metrics Analysis

## Principle

Valuation determines whether a stock's price reflects fair value, undervaluation, or overvaluation relative to its fundamentals and growth prospects. Paying the right price is as important as picking the right company.

## Core Valuation Metrics

### Relative Valuation (Compare to Peers/History)

#### Price-to-Earnings (P/E) Ratio
**Formula**: Stock Price / Earnings Per Share

**Interpretation**:
- Low P/E (<15): Potentially undervalued or slow growth
- Medium P/E (15-25): Fairly valued for market
- High P/E (>25): Growth premium or overvalued

**Usage**:
- Compare to industry median P/E
- Compare to company's historical P/E
- Most useful for mature, profitable companies
- Less useful for high-growth or unprofitable companies

**Limitations**:
- Earnings can be manipulated
- Doesn't account for growth rate
- Not applicable to unprofitable companies

#### PEG Ratio (P/E to Growth)
**Formula**: (P/E Ratio) / (Annual EPS Growth Rate %)

**Interpretation**:
- PEG <1: Potentially undervalued relative to growth
- PEG = 1: Fairly valued
- PEG >2: Overvalued relative to growth

**Usage**:
- Better than P/E for growth companies
- Compares valuation to growth rate
- PEG of 1 means paying 1x for each % of growth

**Example**:
- Stock A: P/E = 30, Growth = 30% → PEG = 1.0 (fair)
- Stock B: P/E = 20, Growth = 10% → PEG = 2.0 (expensive)

#### Price-to-Sales (P/S) Ratio
**Formula**: Market Cap / Annual Revenue

**Interpretation**:
- Low P/S (<2): Potentially undervalued
- Medium P/S (2-5): Fairly valued
- High P/S (>10): High expectations or overvalued

**Usage**:
- Useful for unprofitable but growing companies
- Revenue is harder to manipulate than earnings
- Compare to industry peers
- SaaS companies typically command 10-20x P/S

**Limitations**:
- Ignores profitability
- Companies can have revenue with no profit
- Varies greatly by industry

#### EV/EBITDA (Enterprise Value to EBITDA)
**Formula**: (Market Cap + Debt - Cash) / EBITDA

**Interpretation**:
- Low EV/EBITDA (<10): Potentially undervalued
- Medium EV/EBITDA (10-15): Fairly valued
- High EV/EBITDA (>20): High growth or overvalued

**Usage**:
- Better than P/E for comparing companies with different debt levels
- Accounts for capital structure
- Industry-dependent benchmarks

#### Price-to-Book (P/B) Ratio
**Formula**: Stock Price / Book Value Per Share

**Interpretation**:
- P/B <1: Trading below liquidation value
- P/B 1-3: Fairly valued
- P/B >5: Asset-light business or overvalued

**Usage**:
- Most relevant for asset-heavy businesses (banks, real estate)
- Less relevant for asset-light (software, services)
- Value indicator for distressed situations

### Absolute Valuation (Intrinsic Value)

#### Discounted Cash Flow (DCF)
**Concept**: Present value of all future free cash flows

**Simplified Formula**:
```
Intrinsic Value = Sum of (Future FCF / (1 + Discount Rate)^Year)
```

**Usage**:
- Calculate fair value independent of market price
- Test sensitivity to growth and discount rate assumptions
- Most useful for stable, predictable cash flows
- Less useful for early-stage or cyclical companies

**Key Inputs**:
- FCF projections (5-10 years)
- Terminal growth rate (2-3% typical)
- Discount rate (WACC, typically 8-12%)

**Margin of Safety**:
- Buy at 70% of DCF value (30% margin)
- Accounts for estimation errors

#### Dividend Discount Model (DDM)
**Formula**: Stock Value = Dividend / (Discount Rate - Dividend Growth Rate)

**Usage**:
- For dividend-paying mature companies
- Requires stable dividend history
- Less common for growth investors

### Growth-Adjusted Metrics

#### Rule of 40 (SaaS Companies)
**Formula**: Revenue Growth % + FCF Margin % ≥ 40

**Interpretation**:
- >40: Excellent, balancing growth and profitability
- 30-40: Good
- <30: Concerning, burning cash without high growth

**Example**:
- Company A: 50% growth + (-10%) FCF margin = 40 ✓
- Company B: 20% growth + 25% FCF margin = 45 ✓
- Company C: 15% growth + 10% FCF margin = 25 ✗

## Valuation Scoring

### Score 9-10 (Significantly Undervalued)
- P/E <50% of historical average
- PEG <0.7
- Trading at multi-year lows
- DCF shows >50% upside
- Multiple metrics confirm undervaluation

### Score 7-8 (Undervalued)
- P/E 10-20% below historical average
- PEG 0.7-1.0
- Below 52-week average
- DCF shows 25-50% upside
- Most metrics suggest undervaluation

### Score 5-6 (Fairly Valued)
- P/E in line with historical average
- PEG 1.0-1.5
- Near historical mean
- DCF shows ±15% from current price
- Mixed signals

### Score 3-4 (Overvalued)
- P/E 20-50% above historical average
- PEG 1.5-2.5
- Above 52-week average
- DCF shows 15-30% downside
- Multiple metrics suggest overvaluation

### Score 0-2 (Significantly Overvalued)
- P/E >2x historical average
- PEG >2.5
- At all-time highs with no justification
- DCF shows >30% downside
- Bubble-like valuation

## Contextual Factors

### Adjust for Market Conditions
- **Bull Market**: Valuations expand (higher P/E acceptable)
- **Bear Market**: Valuations contract (lower P/E normal)
- **Interest Rates**: Low rates justify higher valuations

### Adjust for Growth Stage
- **High Growth** (>30%): Can justify P/E >30, P/S >10
- **Moderate Growth** (10-30%): P/E 20-30 reasonable
- **Mature** (<10%): P/E <20 appropriate

### Adjust for Quality
- **High Quality Moat**: Commands premium (add 20% to P/E)
- **Average Moat**: Market multiple
- **No Moat**: Discount required (subtract 20% from P/E)

## Red Flags (Valuation Risk)

- Valuation >2x historical average without reason
- PEG >3 (paying too much for growth)
- Priced for perfection (no margin for error)
- Parabolic price move disconnected from fundamentals
- Extreme multiple expansion in short period
- "This time is different" narratives

## Application

### Pre-Investment
- Calculate 3-5 valuation metrics
- Compare to industry peers (relative)
- Calculate DCF if applicable (absolute)
- Determine fair value range
- Require 20%+ margin of safety
- Assign valuation score (0-10)

### During Hold Period
- Monitor P/E and PEG quarterly
- Track valuation vs historical range
- Re-calculate DCF if assumptions change
- Watch for valuation expansion/contraction

### Exit Triggers
- Valuation reaches DCF fair value (take profits)
- Multiple expands to >2x historical (reduce/exit)
- PEG exceeds 3 without growth acceleration
- Better opportunity elsewhere (valuation arbitrage)

## Best Practices

1. **Use Multiple Metrics**: One metric can mislead
2. **Compare Apples to Apples**: Same industry, business model
3. **Understand Context**: Growth stage, market conditions matter
4. **Margin of Safety**: Never pay full price
5. **Valuation is a Range**: Not a precise number

## Common Mistakes

- Using P/E for unprofitable companies
- Ignoring growth rate (P/E without context)
- Comparing across industries (tech P/E vs utility P/E)
- Overfitting DCF models (garbage in, garbage out)
- Buying expensive stocks hoping for multiple expansion
- Ignoring valuation entirely ("great company at any price")

## Integration with APEX-OS

- **fundamental-analyst** agent applies this principle
- Valuation score (0-10) feeds into overall fundamental score
- Overvaluation triggers position size reduction
- Fair value from DCF sets profit targets
- Valuation expansion can trigger profit taking
