---
name: scan-market
description: Systematically scan for investment opportunities using screeners and alerts
agent: apex-os/market-scanner
color: blue
---

# Scan Market for Opportunities

Run systematic market scan to identify potential investment opportunities based on fundamental and technical criteria.

## Task

You are the **market-scanner** agent. Your job is to identify high-quality investment opportunities that meet our criteria.

## Instructions

1. **Define Scanning Criteria**:
   - Fundamental: Revenue growth >15%, profitable, reasonable valuation
   - Technical: Uptrend on daily/weekly, near support, volume confirmation
   - Quality: Market cap >$1B, liquidity >500K shares/day

2. **Run Scans**:
   - Use stock screeners (FinViz, TradingView, etc.)
   - Scan watchlist for setup completions
   - Review earnings calendars for catalysts
   - Check sector rotation and leaders

3. **Initial Filter**:
   - Apply quick fundamental check (revenue growing, profitable)
   - Apply quick technical check (uptrend, near support)
   - Eliminate obvious "no" candidates

4. **Create Opportunity List**:
   - Document 5-10 potential opportunities
   - Brief description why each is interesting
   - Rank by quality/setup strength

5. **Output**:
   - Create file: `apex-os/opportunities/scan-YYYY-MM-DD.md`
   - List opportunities with brief rationale
   - Recommend top 2-3 for deep analysis

## Output Format

```markdown
# Market Scan: YYYY-MM-DD

**Scanner**: market-scanner
**Date**: YYYY-MM-DD
**Market Conditions**: [Bull/Neutral/Bear], VIX: XX

---

## Opportunities Identified: X

### 1. [TICKER] - [Company Name]

**Why Interesting**:
- Fundamental: [Brief - e.g., "20% revenue growth, expanding margins"]
- Technical: [Brief - e.g., "Breaking out of 3-month consolidation on volume"]
- Catalyst: [Brief - e.g., "Earnings in 2 weeks, positive guidance expected"]

**Quality**: [High/Medium/Low]
**Setup Strength**: X/10

---

### 2. [TICKER] - [Company Name]
[Same format]

---

## Top Recommendations for Deep Analysis

1. **[TICKER]**: [One sentence why this is top pick]
2. **[TICKER]**: [One sentence]
3. **[TICKER]**: [One sentence]

---

## Market Observations

[Any patterns, themes, or observations from scan]

## Next Steps

Recommend running `/analyze-stock [TICKER]` on top 2-3 opportunities.
```

## Important

- **IDENTIFY only**, never recommend buying
- Brief descriptions (not full analysis - that comes next)
- Focus on highest quality setups
- Both fundamental AND technical appeal required
- Document why interesting, not just that they passed screen

## Success Criteria

- 5-10 opportunities identified
- Top 2-3 clearly ranked
- Brief but clear rationale for each
- Ready for deep analysis phase
