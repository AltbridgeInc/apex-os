# APEX-OS: Advanced Portfolio Execution & Analysis Operating System

**A systematic, agent-based framework for disciplined stock trading and investment decisions.**

APEX-OS applies software engineering principles to trading: structured workflows, quality gates, specialized agents, and documented processes to eliminate emotional decision-making and enforce consistency.

---

## What is APEX-OS?

APEX-OS is a complete investment decision-making framework that:
- **Prevents impulsive trades** through mandatory quality gates
- **Enforces risk management** through mathematical position sizing
- **Documents all decisions** for learning and accountability
- **Separates concerns** with specialized agents for each phase
- **Makes thesis falsifiable** with specific exit criteria
- **Tracks everything** for continuous improvement

**Think of it as**: Agent OS for trading. Just as Agent OS transforms software development with agents and structured workflows, APEX-OS transforms trading with the same rigor.

---

## Installation

APEX-OS uses a two-step installation process similar to Agent OS:

### Step 1: Install APEX-OS Base

Run this one-line command to install APEX-OS to `~/apex-os`:

```bash
curl -sSL https://raw.githubusercontent.com/AltbridgeInc/apex-os/main/scripts/base-install.sh | bash
```

This clones the APEX-OS repository to your home directory. You only need to do this once.

### Step 2: Set Up Your Trading Workspace

Create a directory for your trading work and install APEX-OS into it:

```bash
mkdir ~/my-trading && cd ~/my-trading
~/apex-os/scripts/project-install.sh
```

This will:
- Install `.claude/` structure (8 agents, 6 commands, 17 skills)
- Create `apex-os/` workspace with:
  - `principles/` - 16 investment principles
  - `portfolio/` - Portfolio config templates
  - `config.yml` - Framework configuration
  - `scripts/` - Data fetching scripts (FMP API integration)
  - `data/` - Cache directories (fmp/, youtube/)
  - `.env` - Environment configuration template

### Step 3: Configure API Keys

The installer creates a `.env` template in the apex-os folder. Edit it with your API key:

```bash
nano apex-os/.env
```

Add your Financial Modeling Prep API key:
```bash
FMP_API_KEY=your_actual_key_here
```

**Get an API key:** Sign up at [https://financialmodelingprep.com](https://financialmodelingprep.com)
- Free tier: 250 requests/day
- Recommended: Professional tier ($29/month) for active research

### Step 4: Test Your Installation

Run the integration test:

```bash
bash apex-os/scripts/test-fmp-integration.sh
```

This verifies everything is working correctly.

### Step 5: Open in Claude Code

```bash
code ~/my-trading
```

Now you're ready to use APEX-OS!

### Updating APEX-OS

To update APEX-OS to the latest version:

```bash
cd ~/apex-os
git pull origin main
```

Then reinstall to your workspace if needed:

```bash
cd ~/my-trading
~/apex-os/scripts/project-install.sh
```

---

## Architecture: File-Based Data Pattern

APEX-OS uses a **file-based data pattern** for optimal token efficiency and data persistence.

### How It Works

```
┌─────────────────────────────────────────────────────────────┐
│                     Data Flow Architecture                   │
└─────────────────────────────────────────────────────────────┘

1. FETCH (apex-os/scripts/)
   ┌──────────────┐
   │ FMP API      │
   │ Request      │
   └──────┬───────┘
          │
          ▼
   ┌──────────────────┐
   │ fmp-transcript.sh│ ──┐
   │ fmp-financials.sh│   │  Fetch data from FMP API
   │ fmp-earnings.sh  │   │
   └──────────────────┘   │
          │                │
          ▼                │
   ┌──────────────────────────────────┐
   │ CACHE to apex-os/data/fmp/       │
   │ • aapl-transcript-2024-Q4.json   │
   │ • aapl-income-statement-2024.json│
   │ • aapl-earnings-calendar.json    │
   └──────┬───────────────────────────┘
          │
          ▼
   ┌──────────────────┐
   │ Return paths     │  ← 99% token savings
   │ (not content)    │     (paths = 100 tokens vs 11,000+)
   └──────┬───────────┘
          │
          ▼

2. ANALYZE (agents/)
   ┌───────────────────┐
   │ fundamental-analyst│
   │                   │  Receives file paths
   │ Uses Read tool    │  Reads only needed files
   │ selectively       │
   └──────┬────────────┘
          │
          ▼
   ┌──────────────────────────────────┐
   │ Create analysis in apex-os/      │
   │ • analysis/AAPL-2024-11-14.md    │
   │ • theses/AAPL-thesis.md          │
   └──────────────────────────────────┘

3. REFERENCE (documentation)
   All analyses reference cached data:
   - Historical comparison
   - Backtesting
   - Offline analysis
   - Immutable data trail
```

### Benefits

- **99% Token Reduction**: Return paths (~100 tokens) not JSON (~11,000 tokens)
- **Selective Reading**: Agents read only needed files
- **Data Persistence**: Cache enables historical analysis
- **Audit Trail**: All fetches logged to `apex-os/logs/data-fetch.log`
- **Offline Capability**: Analyze cached data without API calls

### Example: Token Comparison

**Old Pattern (Return JSON)**:
```bash
./fmp-transcript.sh AAPL 4
# Returns 180KB of JSON = ~44,000 tokens
```

**New Pattern (Return Paths)**:
```bash
./fmp-transcript.sh AAPL 4
# Returns: {"files": [...], "combined": "path"} = ~100 tokens
# Agent reads 1 file when needed = ~11,000 tokens
# Total: 11,100 tokens (75% savings!)
```

### Data Locations

```
your-workspace/
├── .claude/                       # Claude Code framework
│   ├── agents/apex-os/           # 8 compiled agents
│   ├── commands/apex-os/         # 6 compiled commands
│   └── skills/                   # 17 auto-loaded skills
│
└── apex-os/                       # Your APEX-OS workspace
    ├── .env                       # API keys configuration
    ├── config.yml                # Framework settings
    ├── principles/               # 16 investment principles
    ├── portfolio/                # Portfolio config & positions
    │
    ├── data/                     # Cached financial data
    │   ├── fmp/                  # FMP API cache
    │   │   ├── aapl-transcript-2024-Q4.json
    │   │   ├── aapl-earnings-2024-Q4.txt  (processed)
    │   │   └── aapl-income-statement-2024-annual.json
    │   └── youtube/              # YouTube transcript cache
    │
    ├── scripts/                  # Data fetching infrastructure
    │   └── data-fetching/
    │       └── fmp/
    │           ├── fmp-common.sh      # Shared functions
    │           ├── fmp-transcript.sh  # Earnings transcripts
    │           ├── fmp-financials.sh  # Financial statements
    │           └── process-transcript.py  # JSON → text
    │
    ├── analysis/                 # References cached data
    ├── theses/                   # References cached data
    └── logs/
        └── data-fetch.log        # API usage audit trail
```

---

## Complete Usage Example

Here's a real-world workflow showing how data fetching integrates with analysis:

### Scenario: Analyzing Apple (AAPL)

**Step 1: Check Cache First**
```bash
# Check if we already have data
ls apex-os/data/fmp/aapl-*

# If data exists and is recent (< 7 days old), skip fetching
```

**Step 2: Fetch Financial Data**
```bash
cd apex-os/scripts/data-fetching/fmp

# Fetch last 4 earnings transcripts
./fmp-transcript.sh AAPL 4
# Output: {"success": true, "files": [...], "combined_file": "..."}
# Files saved to: apex-os/data/fmp/aapl-transcript-2024-Q*.json

# Process to readable text
python3 process-transcript.py ../../../data/fmp/aapl-transcripts-combined.json
# Creates: apex-os/data/fmp/aapl-earnings-2024-Q4.txt (for each quarter)

# Fetch financial statements
./fmp-financials.sh AAPL income annual 4
# Saves to: apex-os/data/fmp/aapl-income-statement-2024-annual.json

cd ../../../..
```

**Step 3: Run Analysis (Agent Uses Cached Data)**
```bash
# In Claude Code:
/analyze-stock AAPL
```

The fundamental-analyst agent will:
1. Check for cached data: `ls apex-os/data/fmp/aapl-*`
2. If missing, fetch using scripts above
3. Read only needed files:
   - `Read apex-os/data/fmp/aapl-earnings-2024-Q4.txt` (latest quarter)
   - `Read apex-os/data/fmp/aapl-income-statement-2024-annual.json` (latest year)
4. Conduct analysis applying investment principles
5. Save analysis to: `apex-os/analysis/AAPL-2024-11-14.md`

**Step 4: Verify Logging**
```bash
# Check API usage audit trail
tail apex-os/logs/data-fetch.log

# Output:
# 2024-11-14T10:30:00Z|AAPL|earnings-transcripts|success|4 quarters fetched
# 2024-11-14T10:31:00Z|AAPL|income-statement|success|4 years fetched
```

**Token Usage Breakdown**:
- Fetch 4 transcripts: ~100 tokens (paths returned)
- Agent reads 1 transcript: ~11,000 tokens
- Fetch 4 financials: ~100 tokens (paths returned)
- Agent reads 1 financial: ~3,000 tokens
- **Total: ~14,200 tokens** (vs 60,000+ with old pattern)

---

## How to Use APEX-OS: Complete Guide

This section walks you through using APEX-OS from start to finish, including what to expect at each step and how to interpret results.

---

### Step 0: Initial Setup (One-Time)

Before your first trade, configure your portfolio parameters:

#### Configure Portfolio Settings

Edit `apex-os/portfolio/portfolio-config.yaml`:

```yaml
portfolio:
  total_capital: 100000          # Your total trading capital
  risk_per_trade: 1.5            # Percentage to risk per trade (1-2%)
  max_risk_per_trade: 2.0        # Absolute maximum (hard limit)
  max_portfolio_heat: 8.0        # Total risk across all positions
  min_cash_reserve: 20.0         # Minimum cash percentage to maintain

  position_limits:
    max_position_size: 15.0      # Max % of portfolio per position
    max_positions: 10            # Maximum number of open positions
    max_sector_exposure: 50.0    # Max % in any single sector
```

**What these mean**:
- **risk_per_trade (1.5%)**: On a $100k portfolio, you'll risk $1,500 per trade
- **max_portfolio_heat (8%)**: Total risk across ALL positions can't exceed $8,000
- **min_cash_reserve (20%)**: Always keep $20k cash for opportunities
- **max_position_size (15%)**: No single position larger than $15k

---

### Daily Workflow Overview

```
Morning:
  1. /monitor-portfolio (30 min)  - Check all positions
  2. Review alerts                - Act on anything urgent

Weekly:
  1. /scan-market (1 hour)        - Find new opportunities
  2. /analyze-stock TICKER (2h)   - Deep dive on 1-2 stocks
  3. /write-thesis TICKER (1.5h)  - If analysis passes
  4. /plan-position TICKER (1h)   - If thesis passes

When Ready to Enter:
  1. /execute-entry TICKER (30m)  - Enter the trade
  2. Place stop loss IMMEDIATELY  - Non-negotiable

Daily (Every Trading Day):
  1. /monitor-portfolio (30-45m)  - Track all positions
```

---

### Step 1: Find Opportunities

**Command**: `/scan-market`

**Time**: 30-60 minutes

**What it does**: Runs technical and fundamental screeners to identify 5-10 potential trading opportunities.

**Expected output**:
```markdown
Market scan complete!

✅ Opportunities identified: 8 stocks
📂 Location: `apex-os/opportunities/scan-2024-11-15.md`

TOP PICKS for analysis:
1. NVDA - Strong earnings growth + technical breakout
2. MSFT - Undervalued relative to peers + uptrend
3. META - High insider buying + consolidation pattern

NEXT STEP 👉 Run `/analyze-stock NVDA` to begin fundamental + technical analysis.
```

**What to do next**:
- Review the scan file: `Read apex-os/opportunities/scan-2024-11-15.md`
- Pick 1-2 stocks that look most interesting
- Run `/analyze-stock` on your top pick

**Important**: Don't analyze more than 1-2 stocks per week. Quality over quantity.

---

### Step 2: Deep Analysis

**Command**: `/analyze-stock TICKER`

**Example**: `/analyze-stock NVDA`

**Time**: 1-2 hours (agents work in parallel)

**What it does**:
- **fundamental-analyst**: Analyzes financials, competitive moat, valuation
- **technical-analyst**: Analyzes charts, patterns, support/resistance, entry levels

**Expected output**:
```markdown
Analysis complete!

📊 Fundamental Score: 7.5/10
  - Financial Health: Strong (revenue growth +45% YoY)
  - Competitive Moat: Excellent (network effects, switching costs)
  - Valuation: Fair (P/E 35 vs industry avg 28)
  - Bull case: AI leadership, margin expansion
  - Bear case: Valuation risk, competition from AMD

📈 Technical Score: 8.0/10
  - Trend: Strong uptrend (price > all MAs)
  - Pattern: Ascending triangle (target: $580)
  - Entry: $520-525 (current: $522)
  - Stop: $495 (5.2% risk)
  - R:R: 2.3:1 (at first target)

✅ GATE 1 PASSED: Fundamental ≥6, Technical ≥7

📂 Reports saved:
  - apex-os/analysis/2024-11-15-NVDA/fundamental-report.md
  - apex-os/analysis/2024-11-15-NVDA/technical-report.md

NEXT STEP 👉 Run `/write-thesis NVDA` to synthesize into investment thesis.
```

**How to interpret**:

**Fundamental Score**:
- **9-10**: Exceptional company, rare
- **7-8**: High quality, good odds
- **6**: Acceptable if technical is strong
- **<6**: Pass, too risky

**Technical Score**:
- **9-10**: Textbook setup, high probability
- **7-8**: Good setup, proceed
- **5-6**: Mediocre, only if fundamentals exceptional
- **<5**: Pass, poor setup

**Gate 1 Check**:
- ✅ **PASS**: Fundamental ≥6 AND Technical ≥7 → Proceed to thesis
- ❌ **FAIL**: Either score too low → Pass on this opportunity

**What to do next**:
- If Gate 1 PASSED: Read both reports, then `/write-thesis TICKER`
- If Gate 1 FAILED: Move on to next opportunity, don't force it

---

### Step 3: Write Investment Thesis

**Command**: `/write-thesis TICKER`

**Example**: `/write-thesis NVDA`

**Time**: 1-1.5 hours

**What it does**: Synthesizes fundamental + technical analysis into a falsifiable investment thesis with bull/base/bear cases and specific exit criteria.

**Expected output**:
```markdown
Investment thesis complete!

## Thesis Summary
NVDA is a BUY based on AI datacenter dominance and technical breakout from consolidation.

Bull Case (40% probability): AI adoption accelerates → $650 (24% upside)
Base Case (50% probability): Steady growth → $580 (11% upside)
Bear Case (10% probability): Competition intensifies → $450 (14% downside)

Expected Value: +13.6%
Risk/Reward: 2.1:1

## Falsification Criteria (Exit Triggers)
1. **Technical**: Break below $495 on volume → EXIT
2. **Fundamental**: Gross margin drops below 60% → EXIT
3. **Competitive**: AMD wins 2+ major datacenter contracts → EXIT
4. **Time**: No progress after 8 weeks → REVIEW

✅ GATE 1 PASSED: Thesis is falsifiable with clear exit criteria

📂 Saved: apex-os/analysis/2024-11-15-NVDA/investment-thesis.md

NEXT STEP 👉 Run `/plan-position NVDA` to calculate position sizing.
```

**How to interpret**:

**Probability Distribution**:
- Should add up to 100%
- Base case should be most likely (40-60%)
- Bull and bear cases are your upside/downside scenarios

**Falsification Criteria**:
- These are your "I was wrong" triggers
- If ANY trigger hits → Exit immediately, no rationalization
- Should be specific and measurable

**Expected Value**:
- Probability-weighted return
- Should be positive (if negative, why are you trading this?)

**What to do next**:
- If thesis makes sense and is falsifiable → `/plan-position TICKER`
- If you can't define falsification criteria → Don't trade (not a thesis)

---

### Step 4: Plan Position

**Command**: `/plan-position TICKER`

**Example**: `/plan-position NVDA`

**Time**: 1 hour

**What it does**: Calculates mathematical position sizing, validates all risk management rules, creates detailed execution plan.

**Expected output**:
```markdown
Position plan complete!

## Position Sizing
Entry Price: $522
Stop Loss: $495
Risk per Share: $27
Portfolio Size: $100,000
Risk Amount: $1,500 (1.5% of portfolio)
Position Size: 55 shares
Position Value: $28,710 (28.7% of portfolio)

## Risk Validation
✅ Position <15% of portfolio (28.7% < 15% FAIL → ADJUSTED to 10%)
✅ Risk ≤2% per trade (1.5% ✓)
✅ Portfolio heat ≤8% (currently 3.2% + 1.5% = 4.7% ✓)
✅ Cash reserve ≥20% (currently 45% ✓)
✅ Stop loss ≤8% from entry (5.2% ✓)

ADJUSTED POSITION:
Position Size: 37 shares (reduced to meet position limit)
Position Value: $19,314 (19.3% of portfolio)
Risk: $999 (1.0% of portfolio)

## Profit Targets
Target 1 (2:1): $549 → Sell 12 shares, move stop to breakeven
Target 2 (3:1): $576 → Sell 12 shares, trail stop at 15% below high
Target 3 (Trail): Trail remaining 13 shares

✅ GATE 2 PASSED: All risk management rules satisfied

📂 Saved: apex-os/analysis/2024-11-15-NVDA/position-plan.md

NEXT STEP 👉 When ready to enter: `/execute-entry NVDA`
⏰ TIMING: Wait for entry range $520-525 before executing
```

**How to interpret**:

**Position Sizing Formula**:
```
Risk Amount = Portfolio × Risk %
Position Size = Risk Amount / (Entry - Stop)
```

**Gate 2 Checks**:
- All must pass (✅)
- If any fails, position is auto-adjusted or rejected
- **Never override these limits** - they protect your account

**Adjusted Position**:
- If position too large → Automatically reduced
- This is GOOD - prevents concentration risk

**What to do next**:
- Review the position plan carefully
- **DO NOT enter yet** - wait for right timing
- Entry range: Only enter if price is within planned range
- `/execute-entry` when conditions align

---

### Step 5: Execute Entry

**Command**: `/execute-entry TICKER`

**Example**: `/execute-entry NVDA`

**Time**: 30 minutes (active work)

**What it does**: Guides order placement, REQUIRES stop loss placed immediately, creates entry log.

**Expected output**:
```markdown
## Entry Execution Checklist

### PRE-ENTRY VALIDATION
✅ Price within entry range? ($520-525, current: $522) → YES
✅ Volume healthy? (>80% of average) → YES (112% avg)
✅ Market conditions favorable? (no extreme volatility) → YES
✅ Portfolio heat <8% after this trade? (4.7% < 8%) → YES

### ORDER PLACEMENT

1. **Place LIMIT BUY Order**:
   - Symbol: NVDA
   - Quantity: 37 shares
   - Limit Price: $525 (don't chase higher)
   - Order Type: DAY

2. **Immediately After Fill: PLACE STOP LOSS**
   ⚠️ CRITICAL: You have 1 MINUTE to place stop

   - Symbol: NVDA
   - Quantity: 37 shares
   - Stop Price: $495
   - Order Type: STOP MARKET (or STOP LIMIT at $494)

3. **Place Profit Target Orders** (GTC):
   - Target 1: LIMIT SELL 12 shares at $549
   - Target 2: LIMIT SELL 12 shares at $576

### CONFIRMATION

Did you place stop loss? [Y/N]: Y
Stop loss order ID: #123456
Entry filled at: $522.50
Entry time: 2024-11-15 10:32 EST

✅ GATE 3 PASSED: Stop loss confirmed active

### ENTRY LOG

📂 Saved: apex-os/positions/2024-11-15-NVDA/entry-log.md
📊 Updated: apex-os/portfolio/open-positions.yaml

Position is now ACTIVE. Run `/monitor-portfolio` daily.
```

**Critical Rules**:

1. **NEVER enter without a stop loss**
   - Place stop within 1 minute of fill
   - If broker glitches, exit position immediately
   - No exceptions, ever

2. **Entry range discipline**
   - Only enter within planned range
   - If price runs away, let it go
   - Don't chase (FOMO kills accounts)

3. **Order type matters**
   - Use LIMIT orders for entry (don't pay more than planned)
   - Use STOP MARKET for stop loss (guaranteed execution)

**What to do next**:
- Stop loss is placed → Relax, system is protecting you
- Set calendar reminder: Daily portfolio monitoring
- Week 2, 4, 8: Review checkpoints

---

### Step 6: Daily Monitoring

**Command**: `/monitor-portfolio`

**Run**: Every trading day (before market close)

**Time**: 30-45 minutes

**What it does**: Tracks all positions, validates thesis conditions, generates prioritized alerts.

**Expected output**:
```markdown
Portfolio monitoring complete!

📊 Portfolio Status:
- Open Positions: 3
- Total Risk (Heat): 4.7% (≤8% required)
- Cash Reserve: 32% (≥20% required)
- Unrealized P&L: +$2,340 (+2.3%)

🚨 Alerts:

🔴 ACTION REQUIRED: 1 item
  - TSLA: Stop loss hit at $245.20 → EXIT IMMEDIATELY
    Reason: Technical invalidation (broke support on volume)
    Action: Close position at market
    P&L: -$480 (-1.5% of portfolio)

🟡 REVIEW NEEDED: 2 items
  - NVDA: Target 1 hit at $549.20 → SCALE OUT
    Action: Sell 12 shares, move stop to breakeven

  - MSFT: Week 4 checkpoint → THESIS REVIEW
    Progress: +3.2% (on track)
    Thesis: Still valid (no falsification triggers)
    Action: Continue holding

🟢 MILESTONES: 1 item
  - AAPL: +10% gain in 3 weeks → STRONG PERFORMANCE
    Consider trailing stop tighter

📂 Report: apex-os/reports/daily-monitor-2024-11-15.md

NEXT ACTIONS:
1. EXIT TSLA immediately (stop hit)
2. SCALE OUT NVDA at Target 1
3. MOVE NVDA stop to breakeven
4. REVIEW MSFT thesis (week 4 checkpoint)
```

**How to interpret**:

**Alert Priorities**:
- 🔴 **ACTION REQUIRED**: Do this NOW (stops hit, thesis falsified)
- 🟡 **REVIEW NEEDED**: Do today (targets hit, checkpoints, news)
- 🟢 **MILESTONES**: Good news, no action needed
- 🔵 **INFORMATIONAL**: FYI only

**Portfolio Metrics**:
- **Portfolio Heat**: Total risk across all positions (must be ≤8%)
- **Cash Reserve**: Keep ≥20% for opportunities
- **Unrealized P&L**: Current profit/loss (ignore, focus on process)

**Critical: When Stop Hit (🔴)**:
- Exit IMMEDIATELY at market
- Don't wait for "better price"
- Don't rationalize ("just a shakeout")
- **This is SUCCESS** - risk management working

**What to do next**:
- Complete all 🔴 ACTION REQUIRED items first
- Then 🟡 REVIEW NEEDED items
- Update positions as needed
- Run `/monitor-portfolio` again tomorrow

---

### Step 7: Exit Positions

Exits happen in 3 scenarios:

#### A) Stop Loss Hit (Thesis Falsified)

**This is a GOOD thing** - system protecting you.

```bash
# Exit at market immediately
Order: SELL 37 NVDA @ MARKET
Reason: Stop hit at $495
P&L: -$999 (-1.0% of portfolio)
```

**Then**:
1. Log the exit: Updates `apex-os/positions/2024-11-15-NVDA/exit-log.md`
2. Wait for post-mortem: Auto-generated after 24 hours
3. Review what you learned
4. Move on (don't revenge trade)

#### B) Target Hit (Taking Profits)

**Scale out as targets hit**:

```bash
# Target 1 hit
SELL 12 NVDA @ $549 (limit order)
Move stop to $522 (breakeven)
Lock in: +$318 profit

# Target 2 hit
SELL 12 NVDA @ $576 (limit order)
Trail stop: 15% below high
Lock in: +$324 more profit

# Final 13 shares
Trail until stopped out
Let winners run
```

#### C) Thesis Invalidated (Fundamental Change)

**Exit criteria from thesis triggered**:

```bash
Example: "AMD wins 2 major datacenter contracts"
→ Competitive moat weakening
→ EXIT at market
→ Don't wait for stop loss
```

**After any exit**:
- Position closes in `apex-os/portfolio/open-positions.yaml`
- Exit log created
- Post-mortem scheduled
- Update portfolio metrics

---

### Step 8: Learn from Trades (Post-Mortem)

**Triggered**: Automatically 24 hours after exit

**Agent**: post-mortem-analyst

**What it does**: Analyzes the trade objectively, identifies what went right/wrong, extracts lessons.

**Expected output**:
```markdown
# Trade Post-Mortem: NVDA

## Trade Summary
Entry: $522.50 (2024-11-15)
Exit: $549.20 (2024-11-28) - Target 1 hit
Duration: 13 days
P&L: +$318 (+1.6% of portfolio)
Result: ✅ WIN

## Process Evaluation

✅ Analysis: Thorough, both bull and bear cases considered
✅ Entry: Within planned range, patient
✅ Position Sizing: Followed rules (adjusted down correctly)
✅ Stop Placement: Immediate, confirmed active
⚠️  Exit: Scaled out at T1 but let T2 run away (missed)

## What Went Right
1. Disciplined entry - waited for setup
2. Position sizing protected against larger loss
3. Stopped out at T1 preserved capital

## What Went Wrong
1. Didn't trail tighter after T1 hit
2. Gave back gains when stock pulled back
3. Should have taken more at T1

## Lessons Learned
→ When T1 hits, consider taking 50% instead of 33%
→ Implement tighter trailing stop after first target
→ Don't get greedy after initial profit

## Pattern Recognition
This is the 3rd time this pattern occurred:
- Strong earnings momentum
- Technical breakout
- Quick move to T1, then pullback
→ Update playbook: Take more profits at T1 on momentum trades

📂 Saved: apex-os/positions/2024-11-15-NVDA/post-mortem.md
```

**What to do with this**:
- Read all post-mortems monthly
- Identify patterns across trades
- Update your process
- **Focus on process, not outcome**

---

### Common Scenarios

#### "I want to add to a winning position"

Only add if:
1. ✅ Original thesis still valid
2. ✅ Technical setup still intact
3. ✅ Portfolio heat <8% after adding
4. ✅ New stop loss placed for added shares
5. ❌ NEVER average down losers

#### "The stock is down but my thesis is still valid"

If stop not hit:
- ✅ Hold (system working)
- ✅ Review thesis for invalidation
- ❌ DON'T add unless criteria above met

If stop hit:
- ❌ EXIT (no debate)
- ❌ DON'T re-enter same stock for 30 days

#### "I have a new idea but portfolio is full"

Options:
1. Wait for existing position to exit
2. Close worst-performing position (if stop not protecting)
3. **NEVER exceed 10 positions**
4. Quality > Quantity

#### "Analysis says pass but I have strong conviction"

- ❌ DON'T override the system
- The gates exist to protect you from yourself
- Strong conviction = **Emotional bias**
- If you can't articulate why in the thesis → Not ready

---

### Key Principles to Remember

1. **Process Over Outcome**
   - Good trade + bad outcome = Good trade (variance)
   - Bad trade + good outcome = Bad trade (got lucky)

2. **Never Skip Gates**
   - Each gate prevents costly mistakes
   - If gate fails, opportunity fails
   - No exceptions

3. **Stop Losses Are Sacred**
   - Place within 1 minute
   - Never move them further away
   - When hit, exit immediately

4. **Position Sizing Is Mathematical**
   - Never risk >2% per trade
   - Never exceed portfolio heat of 8%
   - Preserve capital above all else

5. **Daily Monitoring Is Mandatory**
   - Run `/monitor-portfolio` every trading day
   - Act on alerts same day
   - Thesis validation is continuous

---

### Getting Help

**When confused**:
- Read the agent prompts: `apex-os/../.claude/agents/apex-os/`
- Read principles: `apex-os/principles/`
- Review past post-mortems: `apex-os/positions/*/post-mortem.md`

**When unsure**:
- Ask: "Does this follow the process?"
- If no → Don't do it
- If yes → Proceed

**Remember**: The system is designed to keep you disciplined when emotions run high. Trust the process.

---

## The 6-Phase Workflow

### Phase 0: Opportunity Discovery
**Agent**: market-scanner (blue)
**Command**: `/scan-market`
**Output**: List of 5-10 opportunities
**Time**: 30-60 minutes

### Phase 1: Initial Analysis
**Agents**: fundamental-analyst (green) + technical-analyst (orange)
**Command**: `/analyze-stock TICKER`
**Output**: Fundamental report + Technical report
**Time**: 1-2 hours (parallel)
**Gate 1**: Fundamental ≥6, Technical ≥7

### Phase 2: Deep Research & Thesis
**Agent**: thesis-writer (purple)
**Command**: `/write-thesis TICKER`
**Output**: Investment thesis with bull/bear cases
**Time**: 1-1.5 hours
**Gate 1**: Thesis must be falsifiable

### Phase 3: Position Planning
**Agent**: risk-manager (red)
**Command**: `/plan-position TICKER`
**Output**: Position plan with sizing and stops
**Time**: 1 hour
**Gate 2**: All risk limits validated

### Phase 4: Execution
**Agent**: executor (cyan)
**Command**: `/execute-entry TICKER`
**Output**: Entry log with execution details
**Time**: 30 minutes (active)
**Gate 3**: Stop loss placed immediately

### Phase 5: Monitoring & Exit
**Agent**: portfolio-monitor (yellow)
**Command**: `/monitor-portfolio`
**Output**: Daily monitoring report
**Time**: 30-45 minutes daily
**Gate 4**: Systematic exit per plan

### Phase 6: Learning
**Agent**: post-mortem-analyst (pink)
**Command**: Automatic after exit
**Output**: Trade post-mortem with lessons
**Time**: 30 minutes
**Result**: Pattern recognition, continuous improvement

---

## The 8 Specialized Agents

Each agent has a specific role and operates independently:

1. **market-scanner** (blue): Identifies opportunities, never recommends
2. **fundamental-analyst** (green): Deep company analysis, MUST provide bull AND bear cases
3. **technical-analyst** (orange): Chart analysis, MUST identify invalidation levels
4. **risk-manager** (red): Position sizing, NEVER allows >2% risk per trade
5. **thesis-writer** (purple): Synthesis, thesis MUST be falsifiable
6. **executor** (cyan): Entry/exit, MUST place stops immediately
7. **portfolio-monitor** (yellow): Daily tracking, alerts on thesis changes
8. **post-mortem-analyst** (pink): Learning, every trade reviewed

**Agents in `profiles/default/agents/apex-os/`**

---

## The 16 Investment Principles

Knowledge encoded as principles, auto-loaded as skills:

### Fundamental Analysis (5 principles)
- `fundamental-financial-health`: Revenue, margins, cash flow, debt
- `fundamental-competitive-moat`: Network effects, brand, switching costs
- `fundamental-valuation-metrics`: P/E, PEG, DCF, relative valuation
- `fundamental-management-quality`: Capital allocation, alignment, execution
- `fundamental-industry-dynamics`: TAM, competition, regulations, disruption

### Technical Analysis (4 principles)
- `technical-trend-identification`: Multi-timeframe, MAs, ADX, price action
- `technical-support-resistance`: S/R zones, volume confirmation, role reversal
- `technical-pattern-recognition`: Flags, triangles, H&S with measured moves
- `technical-volume-analysis`: Confirmation, divergence, accumulation/distribution

### Risk Management (4 principles)
- `risk-position-sizing`: Mathematical formula, NEVER exceed 2% risk
- `risk-stop-loss-placement`: Technical/ATR/percentage stops, max 8% distance
- `risk-profit-taking`: 3-target scaling (2:1, 3:1, trail)
- `risk-portfolio-diversification`: 8-12 positions, sector limits, portfolio heat

### Behavioral Finance (3 principles)
- `behavioral-emotional-discipline`: Circuit breakers, process over emotion
- `behavioral-confirmation-bias-prevention`: Seek disconfirming evidence, falsifiable exits
- `behavioral-loss-aversion-management`: Cut losses quickly, let winners run

**Principles in `principles/` folder**
**Auto-loaded skills in `profiles/default/skills/`**

---

## The 5 Quality Gates

Gates prevent emotional override and enforce discipline:

### Gate 0: Opportunity Screening
**Prevents**: Analyzing low-quality opportunities
**Requires**: Meets basic criteria (growth, profitability, technical setup)

### Gate 1: Analysis & Thesis Verification
**Prevents**: Weak analysis or unfalsifiable theses
**Requires**:
- Fundamental ≥6/10
- Technical ≥7/10
- Bull AND bear cases developed
- Falsification criteria defined
- R:R ≥2:1

### Gate 2: Position Planning
**Prevents**: Overleveraging or poor risk management
**Requires**:
- Position <15% of portfolio
- Risk ≤2% per trade
- Portfolio heat ≤8%
- Cash reserve ≥20%
- Stop loss ≤8% from entry

### Gate 3: Entry Execution
**Prevents**: Entering without protection
**Requires**:
- Stop loss placed immediately (within 1 minute)
- Stop confirmed active
- Entry within planned range
- All orders verified

### Gate 4: Exit Execution
**Prevents**: Emotional or irrational exits
**Requires**:
- Exit reason documented
- Systematic (target, stop, or falsification)
- Not emotional override
- Thesis validity assessed

**Gates create accountability and prevent mistakes that destroy accounts.**

---

## Directory Structure

After installation, your workspace will have this structure:

```
your-workspace/                    # Your trading workspace
├── .claude/                       # Claude Code reads from here
│   ├── agents/apex-os/           # 8 compiled agent definitions
│   ├── commands/apex-os/         # 6 compiled command workflows
│   └── skills/                   # 17 auto-loaded skills (including fmp)
│
└── apex-os/                       # Your APEX-OS workspace
    ├── .env                       # API keys configuration
    ├── config.yml                # Framework configuration
    │
    ├── principles/               # 16 investment principles
    │   ├── fundamental/          # 5 fundamental principles
    │   ├── technical/            # 4 technical principles
    │   ├── risk-management/      # 4 risk management principles
    │   └── behavioral/           # 3 behavioral principles
    │
    ├── portfolio/                # Portfolio tracking
    │   ├── portfolio-config.yaml # Your settings
    │   └── open-positions.yaml   # Active positions
    │
    ├── data/                     # Cached financial data (file-based pattern)
    │   ├── fmp/                  # FMP API cache
    │   │   ├── aapl-transcript-2024-Q4.json
    │   │   ├── aapl-earnings-2024-Q4.txt  (processed)
    │   │   ├── aapl-income-statement-2024-annual.json
    │   │   └── ...
    │   └── youtube/              # YouTube transcript cache
    │
    ├── scripts/                  # Data fetching infrastructure
    │   ├── data-fetching/
    │   │   └── fmp/
    │   │       ├── fmp-common.sh     # Shared functions
    │   │       ├── fmp-transcript.sh # Earnings transcripts
    │   │       ├── fmp-financials.sh # Financial statements
    │   │       ├── fmp-earnings.sh   # Earnings calendar
    │   │       ├── process-transcript.py  # JSON → text processor
    │   │       └── ...
    │   └── test-fmp-integration.sh   # Integration test
    │
    ├── opportunities/            # Market scans (created on first use)
    ├── analysis/                 # Stock analysis (created on first use)
    │   └── YYYY-MM-DD-TICKER/   # Per-stock analysis folder
    │       ├── fundamental-report.md
    │       ├── technical-report.md
    │       ├── investment-thesis.md
    │       └── position-plan.md
    │
    ├── positions/                # Trade execution (created on first use)
    │   └── YYYY-MM-DD-TICKER/   # Per-trade folder
    │       ├── entry-log.md
    │       ├── exit-log.md
    │       ├── post-mortem.md
    │       └── alert-YYYY-MM-DD.md
    │
    ├── reports/                  # Monitoring & reviews (created on first use)
    │   ├── daily-monitor-YYYY-MM-DD.md
    │   └── monthly-review-YYYY-MM.md
    │
    └── logs/                     # Audit trails
        └── data-fetch.log        # API usage logging
```

**Key Locations**:
- **`.claude/`**: Framework components (agents, commands, skills) - Claude Code reads from here
- **`apex-os/`**: Your complete APEX-OS workspace
  - **`apex-os/data/`**: Cached financial data - enables offline analysis and historical comparison
  - **`apex-os/scripts/`**: Data fetching scripts - agents call these to fetch from FMP API
  - **`apex-os/.env`**: API keys and configuration

---

## Core Philosophy

### 1. Process Over Outcome
- Good process + bad outcome = Good trade (variance)
- Bad process + good outcome = Bad trade (got lucky)
- **Focus**: Execute process perfectly, outcomes will follow

### 2. Systematic > Emotional
- Decisions made when calm (before entry)
- Executed mechanically (during trade)
- Reviewed objectively (after exit)
- **Emotions are data, not decisions**

### 3. Falsifiable Theses
- Every thesis must define what would prove it wrong
- When falsified, exit immediately (no rationalization)
- **If thesis isn't falsifiable, it's not a thesis**

### 4. Risk Management First
- Never risk >2% per trade (non-negotiable)
- Position sizing is mathematical (not guessed)
- Stop loss placed immediately (not "later")
- **Protect capital > Make money**

### 5. Continuous Learning
- Every trade reviewed (win or lose)
- Patterns identified across multiple trades
- Process improved based on data
- **Losses are tuition, not failures**

---

## Key Principles in Action

### Position Sizing Formula
```
Position Size = (Portfolio × Risk %) / (Entry - Stop)

Example:
- Portfolio: $100,000
- Risk: 1.5% = $1,500
- Entry: $50
- Stop: $48
- Risk per share: $2
- Position: $1,500 / $2 = 750 shares
```

### 3-Target Scaling
```
Target 1 (2:1): Sell 1/3, move stop to breakeven
Target 2 (3:1): Sell 1/3, begin trailing stop
Target 3 (Trail): Trail final 1/3 at 15-20% below high
```

### Portfolio Limits
```
Position size: 8-12% each (max 15%)
Total positions: 8-10 (max 15)
Portfolio heat: ≤8% total risk
Sector exposure: ≤50% any sector
Cash reserve: ≥20% always
```

---

## Typical Trade Timeline

**Week 0** (Pre-Entry):
- Market scan: 1 hour
- Analysis: 2 hours
- Thesis: 1.5 hours
- Position planning: 1 hour
- **Total prep: ~5-6 hours** (prevents impulsive trades)

**Day 1** (Entry):
- Execute entry: 30 minutes
- Place stops/targets: 5 minutes
- Document: 15 minutes

**Weeks 1-12** (Hold Period):
- Daily monitoring: 30-45 minutes
- Week 2: Quick review
- Week 4: Mid-point review
- Week 8: Time stop consideration
- Adjust stops as targets hit

**Exit**:
- Execute exit: 10 minutes
- Document: 15 minutes

**Post-Trade**:
- Post-mortem: 30 minutes
- Extract lessons
- Update principles if needed

---

## Common Mistakes APEX-OS Prevents

### ❌ Without APEX-OS:
- Impulsive trades based on tips or FOMO
- No position sizing (guess how much to buy)
- No stop loss or "mental stops"
- Holding losers too long (hope)
- Selling winners too early (fear)
- No documentation (can't learn)
- Emotional decisions override logic
- No falsification criteria
- Inconsistent process
- Can't identify patterns

### ✓ With APEX-OS:
- Every trade requires 5-6 hours analysis (prevents impulse)
- Mathematical position sizing (consistent risk)
- Hard stops placed immediately (protects capital)
- Stops respected (systematic)
- Scaling out (balance profit-taking and letting winners run)
- Everything documented (enables learning)
- Gates prevent emotional override
- Clear falsification triggers exit
- Repeatable process
- Pattern recognition through post-mortems

---

## Measuring Success

### Process Metrics (More Important)
- Gate pass rate (higher = better quality filter)
- Stop loss execution rate (should be 100%)
- Thesis falsification adherence (exit when triggered?)
- Post-mortem completion rate (should be 100%)
- Average time from opportunity to decision (~6 hours)

### Outcome Metrics
- Win rate (40-60% is normal and profitable with good R:R)
- Average R:R achieved (should be >2:1)
- Maximum drawdown (<20% with proper risk management)
- Profit factor (gross wins / gross losses, target >1.5)
- Risk-adjusted return (Sharpe ratio)

**Focus on process metrics. Outcome metrics will follow.**

---

## Customization

### Adjust Risk Tolerance
Edit `portfolio/portfolio-config.yaml`:
- Conservative: 1% risk per trade
- Moderate: 1.5% risk per trade
- Aggressive: 2% risk per trade (maximum)

### Adjust Quality Standards
- Stricter: Increase gate thresholds (fundamental ≥7, technical ≥8)
- Looser: Decrease thresholds (but maintain minimum standards)

### Adjust Position Count
- Focused: 5-8 positions (more concentrated)
- Diversified: 10-15 positions (more diversification)

### Adjust Time Horizon
- Short-term: 2-6 weeks (adjust time stops)
- Medium-term: 2-3 months (standard)
- Long-term: 3-12 months (widen stops, trail more)

---

## Best Practices

1. **Run /monitor-portfolio daily** (every trading day, non-negotiable)
2. **Never skip gates** (they exist for a reason)
3. **Document everything** (if not documented, didn't happen)
4. **Review post-mortems monthly** (identify patterns)
5. **Update config quarterly** (adapt to changing conditions)
6. **Take breaks after 3 losses** (reset emotionally)
7. **Maintain 20%+ cash** (opportunity fund)
8. **Only add to winners** (never average down losers)
9. **Respect falsification** (exit when triggered, no exceptions)
10. **Focus on process** (outcomes are variance, process is edge)

---

## Getting Help

### Documentation
- Read agent definitions in `profiles/default/agents/apex-os/`
- Read principles in `principles/`
- Read command workflows in `profiles/default/commands/apex-os/`
- Review `apex-os_description.md` for complete framework

### Learning Path
1. Start with paper trading (track trades without real money)
2. Run complete workflow on 3-5 stocks
3. Identify your weak points (usually emotional discipline)
4. Focus on process, not outcomes
5. Graduate to small real positions (0.5% risk)
6. Scale up as confidence and competence build

### Common Questions

**Q: Can I skip the 5-6 hour analysis?**
A: No. That's the point. Prevents impulsive trades.

**Q: Can I use 3% risk per trade?**
A: No. Maximum is 2%. More risks account blow-up.

**Q: Do I really need to place stops immediately?**
A: Yes. Non-negotiable. This is what kills accounts.

**Q: Can I override a gate if I'm confident?**
A: No. Gates prevent overconfidence. Follow the process.

**Q: What if my thesis was wrong?**
A: Exit per falsification criteria. Losses are tuition. Learn and move on.

---

## Maintenance

### Daily
- Run `/monitor-portfolio`
- Check for alerts
- Update stops/targets as needed

### Weekly
- Review position progress
- Check for thesis validity
- Rebalance if needed

### Monthly
- Review all post-mortems
- Calculate performance metrics
- Identify patterns
- Update processes

### Quarterly
- Full portfolio review
- Strategy assessment
- Update `portfolio-config.yaml`
- Adjust for market conditions

---

## Philosophy

**APEX-OS exists because**:
- Most trading losses are preventable (emotional decisions, poor risk management)
- Humans are terrible at emotional decisions under uncertainty
- Systems beat discretion over time
- Documentation enables learning
- Process creates edge

**APEX-OS assumes**:
- You want to trade systematically (not gamble)
- You can follow a process (even when uncomfortable)
- You want to improve (continuous learning)
- You prioritize capital preservation (risk management first)
- You can be patient (opportunities come to those who wait)

**APEX-OS is NOT**:
- A get-rich-quick system
- A guarantee of profits
- Fully automated trading
- A replacement for thinking
- A magic formula

**APEX-OS IS**:
- A structured decision-making framework
- A risk management system
- A learning accelerator
- An emotional discipline enforcer
- A path to consistent, repeatable results

---

## Next Steps

1. **Configure your portfolio**: Edit `portfolio/portfolio-config.yaml`
2. **Run your first scan**: `/scan-market`
3. **Analyze an opportunity**: `/analyze-stock TICKER`
4. **Complete the workflow**: Through all 6 phases
5. **Review your process**: Read post-mortem, identify improvements
6. **Repeat**: Consistency creates edge

**Remember**: Trading is a marathon, not a sprint. APEX-OS optimizes for long-term success through disciplined process execution.

---

**Built on**: Agent OS principles (structured workflows, specialized agents, quality gates)

**Purpose**: Transform trading from emotional gambling to systematic execution

**Goal**: Protect capital, let winners run, learn continuously

**Edge**: Process discipline when others are emotional

---

*"The goal of a successful trader is to make the best trades. Money is secondary." - Alexander Elder*

*"In investing, what is comfortable is rarely profitable." - Robert Arnott*

*"It's not whether you're right or wrong, but how much money you make when you're right and how much you lose when you're wrong." - George Soros*

**With APEX-OS, you have a system. Now you need discipline. The system will guide you. You must follow it.**

Good luck, and trade systematically.
