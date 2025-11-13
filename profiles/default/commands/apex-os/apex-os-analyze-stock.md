---
name: analyze-stock
description: Run comprehensive fundamental and technical analysis on a stock
color: multi
---

# Analyze Stock: Fundamental + Technical

Run comprehensive analysis combining fundamental and technical evaluation to determine if opportunity meets quality standards.

## Usage

```
/analyze-stock AAPL
```

## Task

This command orchestrates TWO agents working in parallel:
1. **fundamental-analyst**: Deep fundamental analysis
2. **technical-analyst**: Deep technical analysis

Then wait for both to complete before proceeding.

## Instructions

### Phase 1: Launch Parallel Analysis (Both Agents Simultaneously)

**Agent 1 - fundamental-analyst**:
- Run complete fundamental analysis per agent definition
- Output: `apex-os/analysis/YYYY-MM-DD-{TICKER}/fundamental-report.md`
- Scoring: 0-10 across 5 dimensions
- MUST provide bull AND bear cases

**Agent 2 - technical-analyst**:
- Run complete technical analysis per agent definition
- Output: `apex-os/analysis/YYYY-MM-DD-{TICKER}/technical-report.md`
- Scoring: 0-10 across 5 dimensions
- MUST provide specific entry/stop/target levels

### Phase 2: Review Results

Once both agents complete:

1. **Check Fundamental Score**:
   - ≥6/10 required to proceed
   - If <6: Stop here, document why rejected

2. **Check Technical Score**:
   - ≥7/10 required to proceed
   - If <7: Stop here, document why rejected

3. **Summary**:
   - Create brief summary of findings
   - Highlight strengths and concerns
   - Recommend next step

### Phase 3: Gate 1 Decision

**Proceed to Thesis if**:
- Fundamental ≥6/10: ✓
- Technical ≥7/10: ✓
- No major red flags: ✓

**Recommendation**: "Proceed to `/write-thesis {TICKER}`"

**Reject if**:
- Either score below threshold
- Major red flags identified
- Risk/reward insufficient

**Recommendation**: "Pass on this opportunity. [Reason]"

## Output Format

After both analyses complete, create summary:

```markdown
# Analysis Summary: [TICKER]

**Date**: YYYY-MM-DD
**Analysis Dir**: `apex-os/analysis/YYYY-MM-DD-{TICKER}/`

---

## Scores

**Fundamental**: X.X/10
- Financial Health: X/10
- Competitive Moat: X/10
- Valuation: X/10
- Management: X/10
- Industry: X/10

**Technical**: X.X/10
- Trend: X/10
- Support/Resistance: X/10
- Pattern: X/10
- Volume: X/10
- Indicators: X/10

---

## Key Strengths

1. [Strength 1]
2. [Strength 2]
3. [Strength 3]

## Key Concerns

1. [Concern 1]
2. [Concern 2]
3. [Concern 3]

---

## Gate 1: Analysis Verification

- [ ] Fundamental ≥6/10: **[✓ / ✗] (X.X/10)**
- [ ] Technical ≥7/10: **[✓ / ✗] (X.X/10)**
- [ ] Bull and bear cases developed: **[✓ / ✗]**
- [ ] Entry/stop/targets defined: **[✓ / ✗]**

**Gate 1 Result**: **[✓ PASS / ✗ FAIL]**

---

## Recommendation

[Clear next step]

**If PASS**: "Proceed to `/write-thesis {TICKER}` to synthesize analysis into actionable investment thesis."

**If FAIL**: "Pass on this opportunity. [Specific reason - score too low, red flags, etc.]"
```

## Important Notes

- Run both agents **in parallel** (not sequential) for efficiency
- Wait for BOTH to complete before making Gate 1 decision
- Be objective - failing Gate 1 is good (prevents bad trades)
- Document why opportunity passed or failed
- No bias toward "making it work" - let quality standards reject weak setups

## Success Criteria

- Both analyses completed and documented
- Scores calculated objectively
- Gate 1 decision made with clear reasoning
- Clear path forward (thesis or pass)

## Typical Timeline

- Fundamental analysis: 1-2 hours
- Technical analysis: 30-45 minutes
- (Run in parallel, total: 1-2 hours)
- Summary and decision: 10 minutes

**Total**: ~2 hours for complete analysis
