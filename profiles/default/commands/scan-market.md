---
name: scan-market
description: Systematically scan for investment opportunities using professional two-stage workflow
color: blue
---

# Scan Market for Opportunities

You are running a systematic market scan to identify high-quality investment opportunities.

## Task

**Use the market-scanner agent** to execute the professional two-stage scanning workflow:

### What the market-scanner will do:

**Stage 1 (5-10 min)**: Quick scan of multiple sources
- Scan gainers, losers, actives via FMP API
- Apply basic filters (price >$10, volume >500k)
- Generate 20-50 initial candidates with quick scores

**Stage 2 (30-45 min)**: Deep analysis of top candidates
- Analyze top 5-10 candidates in detail
- Company profiles, earnings, news, sector comparison
- Generate 3-5 high-quality opportunity reports (score ≥7/10)

### Inputs to provide:

From `apex-os/config.yml`:
- Risk parameters (max position size, sectors allowed)
- Any user preferences or focus areas

### Expected outputs:

- Scan summary: `apex-os/opportunities/scan-YYYY-MM-DD.md`
- Individual opportunities: `apex-os/opportunities/YYYY-MM-DD-TICKER-opportunity.md`
- Scan history updated: `apex-os/data/scan-history.json`

---

## After market-scanner completes

Report to user:

```
✅ Market Scan Complete!

📊 Stage 1: Scanned [N] candidates from multiple sources
🎯 Stage 2: Analyzed top [N] in depth

HIGH-QUALITY OPPORTUNITIES (Score ≥7/10):
1. [TICKER] - Score: X/10 - [Brief reason + catalyst]
2. [TICKER] - Score: X/10 - [Brief reason + catalyst]
3. [TICKER] - Score: X/10 - [Brief reason + catalyst]

📂 Full Details: apex-os/opportunities/scan-YYYY-MM-DD.md

NEXT STEP 👉 Run `/analyze-stock TICKER` for fundamental + technical analysis
           or `/write-thesis TICKER` to create investment thesis
```

**Note**: Do NOT try to fetch market data yourself. The market-scanner agent handles all FMP API calls using the correct syntax.
