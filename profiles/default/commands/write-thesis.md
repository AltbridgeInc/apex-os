---
name: write-thesis
description: Synthesize fundamental and technical analysis into falsifiable investment thesis
color: purple
---

# Write Investment Thesis

You are synthesizing analysis into a clear, falsifiable investment thesis.

## Usage

```
/write-thesis AAPL
```

## Prerequisites

Must have completed `/analyze-stock` first with both fundamental and technical reports.

## Task

Use the **thesis-writer** subagent to synthesize analysis into actionable thesis:

Provide the thesis-writer with:
- Ticker symbol
- Analysis directory path (`apex-os/analysis/YYYY-MM-DD-{TICKER}/`)
- Fundamental and technical reports from previous analysis

The thesis-writer will:
1. Review all analysis and extract key insights
2. Formulate one-sentence core hypothesis
3. Develop three scenarios (bull/base/bear) with probabilities
4. Define specific falsification criteria
5. Set timeline and milestones
6. Complete Gate 1 verification checklist
7. Create `apex-os/analysis/YYYY-MM-DD-{TICKER}/investment-thesis.md`

Once the thesis-writer completes, evaluate Gate 1:

**Gate 1 Checklist:**
- Thesis is falsifiable (specific exit conditions)
- Bull and bear cases equally detailed
- Catalysts identified with timing
- Fundamental ≥6/10
- Technical ≥7/10
- Risk/reward ≥2:1

Then inform the user:

```
Investment thesis complete for [TICKER]!

✅ Hypothesis: [One-sentence thesis]
📊 Risk/Reward: X:1
🎯 Conviction: [High/Medium/Low]
📂 Location: `apex-os/analysis/YYYY-MM-DD-{TICKER}/investment-thesis.md`

GATE 1: [✓ PASS / ✗ FAIL]

**If PASS**: "Proceed to `/plan-position {TICKER}` for risk management and position sizing."

**If FAIL**: "Thesis does not meet quality standards. [Specific reason]"
```
