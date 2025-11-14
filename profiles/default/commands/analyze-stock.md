---
name: analyze-stock
description: Run comprehensive fundamental and technical analysis on a stock
color: multi
---

# Analyze Stock: Fundamental + Technical

You are running comprehensive analysis combining fundamental and technical evaluation.

## Usage

```
/analyze-stock AAPL
```

## Task

This command orchestrates TWO subagents working **in parallel**:

**Use the fundamental-analyst subagent** to perform deep fundamental analysis:
- Provide ticker symbol and analysis directory path
- Agent will create `apex-os/analysis/YYYY-MM-DD-{TICKER}/fundamental-report.md`
- Scoring across 5 dimensions (financial health, moat, valuation, management, industry)
- Must provide bull AND bear cases

**Use the technical-analyst subagent** to perform deep technical analysis:
- Provide ticker symbol and analysis directory path
- Agent will create `apex-os/analysis/YYYY-MM-DD-{TICKER}/technical-report.md`
- Scoring across 5 dimensions (trend, support/resistance, pattern, volume, indicators)
- Must provide specific entry/stop/target levels

Run both agents **in parallel** for efficiency, then wait for both to complete.

## Gate 1 Decision

Once both analyses complete, evaluate Gate 1 criteria:

**Required to proceed:**
- Fundamental score ≥6/10
- Technical score ≥7/10
- Bull and bear cases developed
- Entry/stop/targets defined
- No major red flags

**Then create analysis summary** in the analysis directory and inform the user:

```
Analysis complete for [TICKER]!

✅ Fundamental Score: X.X/10
✅ Technical Score: X.X/10
📂 Location: `apex-os/analysis/YYYY-MM-DD-{TICKER}/`

GATE 1: [✓ PASS / ✗ FAIL]

**If PASS**: "Proceed to `/write-thesis {TICKER}` to synthesize analysis into actionable investment thesis."

**If FAIL**: "Pass on this opportunity. [Specific reason - score too low, red flags, etc.]"
```
