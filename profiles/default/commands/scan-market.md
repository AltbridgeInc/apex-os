---
name: scan-market
description: Systematically scan for investment opportunities using screeners and alerts
color: blue
---

# Scan Market for Opportunities

You are running a systematic market scan to identify investment opportunities.

Use the **market-scanner** subagent to identify opportunities:

Provide the market-scanner with:
- Current market conditions (check major indices, VIX level)
- Any specific sectors or themes to focus on (if user mentioned)
- Risk parameters from `apex-os/config.yml`

The market-scanner will:
1. Run technical and fundamental screeners via FMP API
2. Apply initial quality filters
3. Create opportunity documents in `apex-os/opportunities/`
4. Rank and recommend top 2-3 stocks for deep analysis

Once the market-scanner completes, inform the user:

```
Market scan complete!

✅ Opportunities identified: [N] stocks
📂 Location: `apex-os/opportunities/scan-YYYY-MM-DD.md`

TOP PICKS for analysis:
1. [TICKER] - [Brief reason]
2. [TICKER] - [Brief reason]
3. [TICKER] - [Brief reason]

NEXT STEP 👉 Run `/analyze-stock [TICKER]` to begin fundamental + technical analysis.
```
