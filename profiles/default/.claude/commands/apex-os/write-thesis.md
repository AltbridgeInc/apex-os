---
name: write-thesis
description: Synthesize fundamental and technical analysis into falsifiable investment thesis
agent: apex-os/thesis-writer
color: purple
---

# Write Investment Thesis

Synthesize all analysis into clear, falsifiable investment thesis with bull/base/bear cases and specific exit criteria.

## Usage

```
/write-thesis AAPL
```

## Prerequisites

Must have completed `/analyze-stock` first with both fundamental and technical reports generated.

## Task

You are the **thesis-writer** agent. Synthesize all analysis into actionable investment thesis.

## Instructions

### Step 1: Review All Analysis

**Read**:
- `apex-os/analysis/YYYY-MM-DD-{TICKER}/fundamental-report.md`
- `apex-os/analysis/YYYY-MM-DD-{TICKER}/technical-report.md`

**Extract**:
- Fundamental and technical scores
- Key strengths and weaknesses
- Bull and bear arguments from both
- Entry/stop/target levels

### Step 2: Formulate Core Hypothesis

**Answer**:
- Why will this generate returns?
- What's the primary driver?
- Why now? (catalyst/timing)
- What's our edge?

**Synthesize into ONE sentence hypothesis**

### Step 3: Develop Three Scenarios

**Bull Case** (30-40% probability):
- Best realistic outcome
- Key assumptions
- Catalysts needed
- Potential return

**Base Case** (50-60% probability):
- Most likely outcome
- Expected path
- Expected return

**Bear Case** (10-20% probability):
- What goes wrong
- Key risks
- Potential loss (limited by stop)

**CRITICAL**: Bear case must be as detailed as bull case

### Step 4: Define Falsification Criteria

**Must Be**:
- Specific ("Revenue growth <10%" not "fundamentals worsen")
- Measurable (clear yes/no)
- Actionable (triggers exit)

**Include**:
- Technical invalidation (price level)
- Fundamental deterioration (specific metrics)
- Time invalidation (no progress after X weeks)

### Step 5: Set Timeline and Milestones

- Expected hold period
- Key dates (earnings, events)
- Review checkpoints (Week 2, 4, 8)

### Step 6: Complete Gate 1 Checklist

**Verify**:
- Thesis is falsifiable (clear exit conditions)
- Bull and bear cases equally detailed
- Catalysts identified with timing
- Fundamental ≥6/10
- Technical ≥7/10
- Risk/reward ≥2:1

### Step 7: Write Thesis Document

Output complete investment thesis per format in agent definition.

## Output

Create: `apex-os/analysis/YYYY-MM-DD-{TICKER}/investment-thesis.md`

Use exact format from thesis-writer agent definition.

## Gate 1 Verification

**Checklist**:
- [✓] Thesis is falsifiable
- [✓] Bull and bear cases both detailed
- [✓] Catalysts identified with timing
- [✓] Fundamental score ≥6/10
- [✓] Technical score ≥7/10
- [✓] Risk/reward ≥2:1

**Gate 1 Result**: ✓ PASS / ✗ FAIL

**If PASS**: "Proceed to `/plan-position {TICKER}` for risk management and sizing."

**If FAIL**: "Thesis does not meet quality standards. [Specific reason]"

## Important Constraints

- **MUST be falsifiable**: Vague exits not acceptable
- **Equal detail bull/bear**: No one-sided analysis
- **Concise**: 1-2 pages maximum
- **Synthesize**: Add insight, don't just copy
- **Be honest**: If thesis weak, say so (don't force it)

## Success Criteria

- Clear one-sentence hypothesis
- Three scenarios with probabilities
- Specific falsification criteria
- All Gate 1 requirements met
- Conviction level stated
- Ready for position planning

## Typical Timeline

- Review analysis: 15 minutes
- Develop thesis: 30-45 minutes
- Write document: 30 minutes
- **Total**: ~1.5 hours

## Next Step

If thesis passes Gate 1, proceed to:
```
/plan-position {TICKER}
```
