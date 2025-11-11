# APEX-OS: Advanced Portfolio Execution & Analysis Operating System

**Version**: 1.0
**Created**: November 2025
**Purpose**: Structured, repeatable investment decision framework for disciplined stock trading

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [The Problem](#the-problem)
3. [The Solution](#the-solution)
4. [Core Architecture](#core-architecture)
5. [The 6-Phase Workflow](#the-6-phase-workflow)
6. [The 8 Specialized Agents](#the-8-specialized-agents)
7. [The 16 Investment Principles (Skills)](#the-16-investment-principles-skills)
8. [Quality Gates](#quality-gates)
9. [File Structure](#file-structure)
10. [Example Trade Workflow](#example-trade-workflow)
11. [Implementation Guide](#implementation-guide)
12. [Success Metrics](#success-metrics)
13. [Benefits vs Traditional Trading](#benefits-vs-traditional-trading)

---

## Executive Summary

**APEX-OS** is an investment decision framework that applies software engineering best practices (from Agent OS) to stock trading. It transforms ad-hoc, emotional investing into a structured, documented, repeatable process.

**Target User**: Individual stock traders focusing on 2-week to 3-month positions using hybrid analysis (fundamental + technical + quantitative).

**Core Problem Solved**: Inconsistent analysis leading to emotional decisions, poor documentation, and inability to learn from past trades.

**Key Innovation**: Just as Agent OS structures software development through specialized agents and automated standards, APEX-OS structures investment decisions through specialized analyst agents and automated investment principles.

**Time Investment**:
- Setup: 2-3 hours (one-time)
- Per trade: 2-4 hours (vs 30 min ad-hoc, but 10x better quality)
- Payoff: Consistent process → Better decisions → Higher risk-adjusted returns

---

## The Problem

### Traditional Stock Trading Challenges

**1. Inconsistent Analysis**
```
Trade 1: Spent 3 hours on deep research → Good decision
Trade 2: FOMO, bought in 5 minutes → Bad decision
Trade 3: Partial analysis, skipped technical → Mediocre decision
```
**Result**: No repeatable process, can't identify what works

**2. Emotional Decision-Making**
- FOMO buying at peaks
- Panic selling at bottoms
- Moving stops based on fear
- Averaging down on losing positions
- Revenge trading after losses

**3. Poor Documentation**
- Forget why you bought a stock
- Can't track thesis evolution
- Unable to learn from mistakes
- No pattern identification over time

**4. Inconsistent Risk Management**
- Random position sizing
- Arbitrary stop placement
- No clear profit-taking strategy
- Portfolio concentration risks

**5. No Learning Loop**
- Rarely review closed trades
- Can't distinguish luck from skill
- Repeat same mistakes
- No systematic improvement

###The Gap

You need structure, but traditional solutions don't work:

- **Trading journals**: Require manual discipline (often skipped)
- **Checklists**: Static, easy to override emotionally
- **Automated trading**: Removes human judgment entirely
- **Professional tools**: Expensive, overly complex

**What's missing**: A framework that provides structure while preserving judgment - exactly what Agent OS does for software development.

---

## The Solution

### APEX-OS Core Concept

**Insight**: Successful investing isn't about finding secret strategies - it's about consistently applying good strategies.

**Approach**: Borrow proven methodology from Agent OS:
1. **Structured Workflow** - 6 mandatory phases
2. **Specialized Agents** - 8 analysts with specific roles
3. **Investment Principles** - 16 auto-loaded standards
4. **Quality Gates** - 5 verification checkpoints
5. **Complete Documentation** - Every decision captured

### The Three Pillars

**Pillar 1: Structure (Workflow)**
- Prevents skipping steps when excited
- Ensures consistent analysis quality
- Creates repeatable process
- Builds institutional memory

**Pillar 2: Specialization (Agents)**
- Fundamental analyst focuses only on fundamentals
- Technical analyst focuses only on technicals
- Risk manager enforces position sizing rules
- Each agent has constraints preventing scope creep

**Pillar 3: Knowledge (Principles/Skills)**
- Investment principles stored once
- Auto-loaded when relevant
- Ensures disciplined application
- Updated based on learnings

---

## Core Architecture

### System Overview

```
APEX-OS/
├── Workflow (6 Phases)
│   ├── 1. Opportunity Discovery
│   ├── 2. Initial Analysis
│   ├── 3. Deep Research
│   ├── 4. Position Planning
│   ├── 5. Execution
│   └── 6. Review & Learning
│
├── Agents (8 Specialists)
│   ├── market-scanner (identifies opportunities)
│   ├── fundamental-analyst (company analysis)
│   ├── technical-analyst (chart analysis)
│   ├── risk-manager (position sizing)
│   ├── thesis-writer (synthesizes analysis)
│   ├── executor (trade execution)
│   ├── portfolio-monitor (ongoing tracking)
│   └── post-mortem-analyst (trade reviews)
│
├── Principles (16 Standards)
│   ├── Fundamental Analysis (5)
│   ├── Technical Analysis (4)
│   ├── Risk Management (4)
│   └── Behavioral/Psychological (3)
│
└── Quality Gates (5 Checkpoints)
    ├── Gate 1: Thesis Verification (before entry)
    ├── Gate 2: Execution Verification (at entry)
    ├── Gate 3: Ongoing Monitoring (during hold)
    ├── Gate 4: Exit Verification (at sale)
    └── Gate 5: Post-Mortem (after close)
```

### Integration with Claude Code

APEX-OS is built as a `.claude/` configuration:
- **Agents**: `.claude/agents/apex-os/` - 8 specialized analysts
- **Commands**: `.claude/commands/apex-os/` - 6 slash commands for workflows
- **Skills**: `.claude/skills/` - 16 auto-generated investment principles
- **Principles**: `apex-os/principles/` - Source documents for skills

This allows you to use Claude Code as your investment analysis assistant with automatic principle enforcement.

---

## The 6-Phase Workflow

### Phase 1: Opportunity Discovery

**Purpose**: Identify potential investments systematically

**Agent**: market-scanner

**Activities**:
- Run stock screeners (technical, fundamental, momentum)
- Monitor price alerts and breakouts
- Track news and catalyst events
- Review analyst upgrades/downgrades
- Check social sentiment indicators

**Output**: `opportunities/YYYY-MM-DD-TICKER.md`
- Ticker symbol
- Discovery source (screener, alert, news)
- Initial trigger (what caught attention)
- Quick check (basic metrics pass/fail)
- Decision: Move to analysis or add to watchlist

**Quality Standard**: Document WHY it's interesting, not just THAT it's interesting

**Time**: 15-30 minutes per opportunity

---

### Phase 2: Initial Analysis

**Purpose**: Quick evaluation to determine if deep research is warranted

**Agents**: fundamental-analyst (light), technical-analyst (light)

**Activities**:
- **Fundamental Quick Check**:
  - Revenue growth trend (growing or declining?)
  - Profitability (profitable or burning cash?)
  - Debt level (manageable or concerning?)
  - Recent news (any major red flags?)

- **Technical Quick Check**:
  - Trend direction (up, down, sideways?)
  - Position relative to support/resistance
  - Volume pattern (healthy or concerning?)
  - Recent price action (strength or weakness?)

**Output**: `analysis/YYYY-MM-DD-TICKER/initial-analysis.md`
- Fundamental quick score: 0-10
- Technical quick score: 0-10
- Initial concerns/red flags
- Decision: Proceed to deep research or pass

**Quality Gate**: Must score ≥5 on both fundamental and technical to proceed

**Time**: 30-45 minutes

---

### Phase 3: Deep Research

**Purpose**: Comprehensive analysis to build investment thesis

**Agents**: fundamental-analyst (deep), technical-analyst (deep), risk-manager

**Activities**:

**A. Fundamental Deep Dive**:
- Financial statement analysis (3-5 years)
- Competitive positioning and moat analysis
- Management quality assessment
- Industry dynamics and TAM
- Valuation analysis (multiple methods)
- Bull case (what could go right)
- Bear case (what could go wrong)
- **Output**: `fundamental-report.md` with score 0-10

**B. Technical Deep Dive**:
- Trend analysis (multiple timeframes)
- Support/resistance levels
- Chart pattern identification
- Volume analysis
- Entry/exit level planning
- **Output**: `technical-report.md` with score 0-10

**C. Risk Assessment**:
- Portfolio correlation check
- Position size calculation (based on portfolio and volatility)
- Stop loss determination
- Risk/reward ratio calculation
- **Output**: `risk-assessment.md`

**D. Thesis Synthesis**:
- **Agent**: thesis-writer
- Combines all analysis into cohesive thesis
- **Output**: `investment-thesis.md` (1-2 pages)

**Thesis Must Include**:
1. **Investment Hypothesis**: Why this will generate returns
2. **Bull Case**: Best-case scenario (with probability estimate)
3. **Base Case**: Expected scenario
4. **Bear Case**: Worst-case scenario (with probability estimate)
5. **Catalysts**: Events that would drive thesis
6. **Risks**: What could go wrong
7. **Falsification Criteria**: What would prove thesis wrong (exit triggers)
8. **Timeline**: Expected holding period

**Quality Gate**: Thesis must be falsifiable (clear conditions to exit)

**Time**: 2-3 hours

---

### Phase 4: Position Planning

**Purpose**: Determine exact entry, sizing, and risk parameters

**Agent**: risk-manager

**Activities**:
- Review thesis and technical levels
- Calculate position size based on:
  - Portfolio size
  - Risk per trade (1-2% of portfolio)
  - Stop distance
  - Formula: Position Size = (Portfolio × Risk%) / (Entry - Stop)
- Determine entry strategy:
  - Limit order at specific price
  - Scale-in approach (1/3 at three levels)
  - Market order if urgent
- Set stop loss levels:
  - Technical stop (below support)
  - ATR-based stop (2-3× ATR below entry)
  - Maximum stop (never >8% from entry)
- Define profit targets:
  - Target 1 (2:1 R:R) - sell 1/3
  - Target 2 (3:1 R:R) - sell 1/3
  - Target 3 (trailing stop on final 1/3)
- Set timeline expectations

**Output**: `position-plan.md`
- Entry price range: $X.XX - $X.XX (ideal to maximum)
- Position size: XX shares = $X,XXX
- Stop loss: $X.XX (X% below entry)
- Take profit 1: $X.XX (X% gain, sell 1/3)
- Take profit 2: $X.XX (X% gain, sell 1/3)
- Trailing stop: Trail final 1/3 at X% below peak
- Risk amount: $XXX (X% of portfolio)
- Reward potential: $XXX (X:1 R:R ratio)
- Timeline: X weeks to X months

**Quality Gate**: Must pass all risk checks:
- Position size <15% of portfolio
- Risk per trade <2% of portfolio
- R:R ratio ≥2:1
- Stop loss reasonable (<8% from entry)
- No conflicting positions (correlation check)

**Time**: 30 minutes

---

### Phase 5: Execution

**Purpose**: Enter position according to plan with verification

**Agent**: executor

**Activities**:
- Wait for entry conditions (price in planned range)
- Place orders:
  - Entry order (limit or market)
  - Stop loss order (immediately after fill)
  - Take profit orders (GTC limit orders)
- Verify execution:
  - Filled at planned price? (or acceptable deviation)
  - Stop loss order active?
  - Position size correct?
  - Total portfolio risk within limits?
- Document actual entry:
  - Actual fill price
  - Actual number of shares
  - Order timestamps
  - Any deviations from plan (with reasons)

**Output**: `positions/YYYY-MM-DD-TICKER/entry-log.md`
- Entry date and time
- Fill price and shares
- Total cost (including commissions)
- Stop loss level (as placed)
- Take profit levels (as placed)
- Portfolio impact (% of portfolio, % of total risk)
- Notes (any deviations or observations)

**Quality Gate**: Execution verification
- Entry within planned range (or documented exception)
- Stop loss order placed (confirmed active)
- Position size matches plan (±5% acceptable)
- Portfolio limits not exceeded

**Time**: 15 minutes (plus waiting for entry conditions)

---

### Phase 6: Review & Learning

**A. Ongoing Monitoring (During Hold)**

**Agent**: portfolio-monitor

**Frequency**: Daily/Weekly depending on position

**Activities**:
- Check thesis validity:
  - Any news/events contradicting thesis?
  - Technical setup still intact?
  - Fundamentals deteriorating?
- Monitor price action:
  - Approaching targets?
  - Stop threatened?
  - Unusual volume or volatility?
- Update trailing stops if applicable
- Document significant events

**Output**: `positions/YYYY-MM-DD-TICKER/monitoring/YYYY-MM-DD-update.md`

**Quality Gate**: Flag thesis violations immediately
- Technical breakdown (breaks key support on volume)
- Fundamental deterioration (earnings miss, guidance down)
- Better opportunity elsewhere (opportunity cost)

**Time**: 10-15 minutes per position per week

---

**B. Exit Execution**

**Agent**: executor

**Trigger Conditions**:
1. Stop loss hit (risk management)
2. Profit target reached (planned exit)
3. Thesis falsified (fundamental change)
4. Time stop (no progress after 2× expected timeline)

**Activities**:
- Execute exit order
- Verify fill
- Calculate P&L
- Document exit reason

**Output**: `positions/YYYY-MM-DD-TICKER/exit-log.md`
- Exit date and time
- Exit price and shares
- Reason for exit (which trigger)
- Holding period
- Profit/loss ($XXX, X.X%)
- Notes

**Quality Gate**: Exit verification
- Reason documented (stop, target, thesis, or time)
- Not emotional override (unless thesis violated)
- P&L calculated correctly

**Time**: 15 minutes

---

**C. Post-Mortem Analysis**

**Agent**: post-mortem-analyst

**Timing**: Within 1 week of exit

**Activities**:
- Review complete trade history:
  - Opportunity identification
  - Analysis quality
  - Thesis accuracy
  - Execution quality
  - Monitoring effectiveness
  - Exit timing
- Analyze outcome:
  - Thesis correct or incorrect?
  - Process followed or violated?
  - Luck vs skill?
  - What went right?
  - What went wrong?
- Extract lessons:
  - Mistakes to avoid
  - Successes to repeat
  - Process improvements needed
  - Pattern identification

**Output**: `positions/YYYY-MM-DD-TICKER/post-mortem.md`

**Required Sections**:
1. **Trade Summary**: Dates, prices, P&L
2. **Thesis Review**: Was hypothesis correct?
3. **Process Review**: Did we follow APEX-OS workflow?
4. **What Worked**: Successes to repeat
5. **What Didn't Work**: Mistakes to avoid
6. **Luck vs Skill**: Honest assessment
7. **Lessons Learned**: Specific takeaways
8. **Process Updates**: Any principle changes needed

**Quality Gate**: Must be completed for ALL trades (winners AND losers)

**Time**: 30-60 minutes

---

## The 8 Specialized Agents

### Agent 1: market-scanner (Blue)

**Role**: Systematic opportunity identification

**Color**: Blue (calm, systematic scanning)

**Tools**:
- Stock screeners (fundamental, technical, momentum)
- Price alert systems
- News aggregators
- Social sentiment tools
- Earnings calendars

**Constraints**:
- ONLY identifies opportunities, NEVER recommends buying
- Must document trigger source
- Must provide initial quick-check metrics
- Cannot skip documentation

**Workflow**:
1. Run daily/weekly screeners
2. Check alert systems
3. Review news/catalysts
4. Document each opportunity
5. Quick filter (basic sanity checks)
6. Output opportunity document

**Output Format**: `opportunities/YYYY-MM-DD-TICKER.md`

**Activation**: Use `/scan-opportunities` command

---

### Agent 2: fundamental-analyst (Green)

**Role**: Company fundamental analysis

**Color**: Green (growth, fundamentals, value)

**Tools**:
- Financial statements (10-K, 10-Q)
- Earnings call transcripts
- SEC filings
- Industry reports
- Competitive analysis frameworks

**Constraints**:
- MUST provide both bull AND bear cases
- MUST cite specific data sources
- MUST assign numerical score (0-10)
- Cannot be overly optimistic or pessimistic

**Workflow**:

**Initial Analysis** (30 min):
1. Revenue/earnings trend
2. Profitability check
3. Debt level review
4. Recent news scan
5. Quick score (0-10)

**Deep Analysis** (2 hours):
1. Financial Health (5 years):
   - Revenue growth rate and consistency
   - Profit margin trends
   - Cash flow quality
   - Debt-to-equity and interest coverage
2. Competitive Positioning:
   - Market share trends
   - Competitive advantages (moat)
   - Threat assessment
3. Management Quality:
   - Capital allocation track record
   - Insider buying/selling
   - Compensation alignment
4. Industry Dynamics:
   - TAM and growth rate
   - Regulatory environment
   - Cyclical factors
5. Valuation Analysis:
   - P/E vs peers and history
   - PEG ratio
   - DCF valuation
   - Margin of safety
6. Bull Case (best realistic scenario)
7. Bear Case (worst realistic scenario)
8. Final Score (0-10)

**Output**: `fundamental-report.md` with score and supporting analysis

**Activation**: Part of `/analyze-stock` command

---

### Agent 3: technical-analyst (Orange)

**Role**: Chart analysis and setup identification

**Color**: Orange (energy, momentum, action)

**Tools**:
- Price charts (multiple timeframes)
- Technical indicators (MA, RSI, MACD, etc.)
- Volume analysis
- Pattern recognition
- Support/resistance identification

**Constraints**:
- MUST identify invalidation levels (where setup fails)
- MUST consider multiple timeframes
- MUST provide specific entry/exit levels
- Cannot ignore bearish signals

**Workflow**:

**Initial Analysis** (30 min):
1. Trend direction (up/down/sideways)
2. Position relative to support/resistance
3. Volume pattern
4. Quick score (0-10)

**Deep Analysis** (1.5 hours):
1. Trend Analysis:
   - Daily, weekly, monthly trends
   - Moving averages (20, 50, 200-day)
   - Trend strength indicators
2. Support/Resistance Levels:
   - Horizontal levels (previous pivots)
   - Volume at price
   - Fibonacci retracements
   - Psychological levels
3. Chart Patterns:
   - Continuation patterns (flags, triangles)
   - Reversal patterns (H&S, double top/bottom)
   - Candlestick patterns
4. Volume Analysis:
   - Volume trend
   - Volume at breakout/breakdown
   - Accumulation/distribution
5. Indicators:
   - RSI (overbought/oversold)
   - MACD (momentum)
   - ATR (volatility)
6. Entry Levels:
   - Ideal entry (best setup)
   - Acceptable entry (good enough)
   - Maximum entry (don't chase beyond)
7. Stop Loss Levels:
   - Technical stop (below support)
   - Invalidation level (setup fails)
8. Target Levels:
   - Target 1 (measured move)
   - Target 2 (extension)
   - Target 3 (optimistic)
9. Setup Quality Score (0-10)

**Output**: `technical-report.md` with score and levels

**Activation**: Part of `/analyze-stock` command

---

### Agent 4: risk-manager (Red)

**Role**: Position sizing and risk enforcement

**Color**: Red (caution, risk, protection)

**Tools**:
- Portfolio analytics
- Position size calculators
- Volatility measures (ATR, beta)
- Correlation analysis
- Kelly criterion calculator

**Constraints**:
- NEVER allows >2% risk per trade (absolute maximum)
- MUST calculate position size mathematically
- MUST verify portfolio heat limits (max 6-8% total risk)
- Cannot be overridden without documentation

**Workflow**:
1. Review current portfolio:
   - Total value
   - Open positions
   - Current risk exposure
   - Sector/asset correlations
2. Analyze new position:
   - Proposed entry price
   - Proposed stop loss
   - Risk per share (entry - stop)
3. Calculate position size:
   - Risk amount = Portfolio × Risk% (1-2%)
   - Position size = Risk amount / Risk per share
   - Example: $100k portfolio, 1.5% risk = $1,500
   - Entry $50, Stop $48 = $2 risk per share
   - Position size = $1,500 / $2 = 750 shares
4. Verify constraints:
   - Position size <15% of portfolio? ✓
   - Total portfolio heat <8%? ✓
   - Correlation with existing positions? ✓
   - Stop loss <8% from entry? ✓
5. Calculate reward potential:
   - Risk/reward ratio (must be ≥2:1)
   - Profit targets (1st, 2nd, 3rd)
6. Set stop loss:
   - Technical stop (preferred)
   - ATR-based stop (2-3× ATR)
   - Percentage stop (maximum 8%)

**Output**: `risk-assessment.md` with position plan

**Activation**: Part of `/plan-position` command

---

### Agent 5: thesis-writer (Purple)

**Role**: Synthesis of analysis into investment thesis

**Color**: Purple (wisdom, synthesis, strategy)

**Tools**:
- Fundamental report
- Technical report
- Risk assessment
- Synthesis frameworks

**Constraints**:
- Thesis MUST be falsifiable (clear exit conditions)
- MUST include bull, base, and bear cases
- MUST identify specific catalysts
- MUST be concise (1-2 pages maximum)

**Workflow**:
1. Read all analysis reports:
   - Fundamental score and findings
   - Technical score and setup
   - Risk assessment
2. Identify thesis core:
   - What's the primary driver of returns?
   - Why now? (timing/catalyst)
   - What's the edge? (why is market wrong)
3. Build bull case:
   - Best realistic scenario
   - Probability estimate
   - Potential return
4. Build base case:
   - Expected scenario
   - Probability estimate
   - Expected return
5. Build bear case:
   - Worst realistic scenario
   - Probability estimate
   - Potential loss (should be limited by stop)
6. Identify catalysts:
   - Positive catalysts (earnings, product launch, etc.)
   - Negative risks (competition, regulation, etc.)
7. Define falsification criteria:
   - What would prove thesis wrong?
   - Specific, measurable conditions
   - These become exit triggers
8. Set timeline:
   - Expected holding period
   - Key dates (earnings, events)

**Output**: `investment-thesis.md` (1-2 pages)

**Thesis Template**:
```markdown
# Investment Thesis: [TICKER]

## Core Hypothesis
[One paragraph: Why this will generate returns]

## Bull Case (XX% probability)
- [Scenario description]
- Potential return: XX%

## Base Case (XX% probability)
- [Scenario description]
- Expected return: XX%

## Bear Case (XX% probability)
- [Scenario description]
- Potential loss: XX% (limited by stop at XX%)

## Catalysts
**Positive**:
- [Catalyst 1 with timing]
- [Catalyst 2 with timing]

**Risks**:
- [Risk 1]
- [Risk 2]

## Falsification Criteria (Exit Triggers)
1. [Specific condition that would prove thesis wrong]
2. [Another condition]
3. [Technical: breaks support at $XX on volume]

## Timeline
- Expected hold: X weeks to X months
- Key dates: [earnings on MM/DD, etc.]
```

**Activation**: Use `/write-thesis` command

---

### Agent 6: executor (Cyan)

**Role**: Trade execution planning and verification

**Color**: Cyan (precision, execution, action)

**Tools**:
- Order entry systems
- Order types (limit, market, stop)
- Execution analytics
- Fill verification

**Constraints**:
- MUST follow position plan exactly (or document exceptions)
- MUST place stop loss immediately after entry
- MUST verify all orders confirmed
- Cannot deviate without documented reason

**Workflow**:

**Entry Execution**:
1. Review position plan:
   - Entry price range
   - Position size
   - Stop loss level
   - Take profit levels
2. Determine order strategy:
   - Limit order at ideal price (patient approach)
   - Market order if urgent (catalyst-driven)
   - Scale-in (1/3 at three price levels)
3. Place orders:
   - Entry order
   - Stop loss order (GTC, immediately after fill)
   - Take profit orders (GTC limit orders at targets)
4. Monitor execution:
   - Wait for fills
   - Verify prices
   - Confirm all orders active
5. Document execution:
   - Actual fill prices
   - Timestamps
   - Any deviations from plan
6. Run verification checklist:
   - ✓ Filled within planned range?
   - ✓ Position size correct?
   - ✓ Stop loss order active?
   - ✓ Portfolio risk limits ok?

**Exit Execution**:
1. Identify exit trigger:
   - Stop loss hit
   - Profit target reached
   - Thesis falsified
   - Time stop
2. Place exit order:
   - Market order for stops
   - Limit order for targets
3. Verify fill
4. Document exit:
   - Price, time, reason
   - P&L calculation
5. Cancel remaining orders

**Output**:
- `entry-log.md` (at entry)
- `exit-log.md` (at exit)

**Activation**:
- `/execute-entry` command (for entry)
- Manual (for exit)

---

### Agent 7: portfolio-monitor (Yellow)

**Role**: Ongoing position tracking and thesis monitoring

**Color**: Yellow (awareness, alertness, monitoring)

**Tools**:
- Real-time price data
- News aggregators
- Earnings calendars
- Alert systems
- Portfolio analytics

**Constraints**:
- MUST check positions at least weekly
- MUST flag thesis violations immediately
- MUST track stop and target levels
- Cannot ignore warning signals

**Workflow**:

**Daily Quick Check** (5 min per position):
1. Check prices vs key levels:
   - Near stop loss?
   - Near profit targets?
   - Breaking support/resistance?
2. Scan news:
   - Company announcements?
   - Sector news?
   - Market events?
3. Note any flags:
   - Unusual volume
   - Large price moves
   - News alerts

**Weekly Deep Check** (15 min per position):
1. Thesis validity review:
   - Fundamentals still intact?
   - Technical setup still valid?
   - Any bearish developments?
2. Performance review:
   - P&L since entry
   - Time in position
   - Progress toward targets
3. Adjust if needed:
   - Trail stops if in profit
   - Reassess thesis if stalling
   - Consider exit if thesis weakening
4. Document update:
   - Position health score (0-10)
   - Any concerns
   - Any adjustments made

**Thesis Violation Flags** (immediate action):
- **Red Flag** (exit immediately):
  - Major fundamental deterioration (earnings miss, guidance down significantly)
  - Technical breakdown (loses key support on high volume)
  - Management scandal or major negative news
- **Yellow Flag** (review within 24 hours):
  - Minor earnings miss
  - Technical weakness (approaching support)
  - Increased volatility
- **Green** (healthy):
  - Thesis intact
  - Technical structure sound
  - On track for targets

**Output**: `monitoring/YYYY-MM-DD-update.md` (weekly)

**Activation**: Manual daily/weekly, automatic via alerts

---

### Agent 8: post-mortem-analyst (Pink)

**Role**: Trade review and learning extraction

**Color**: Pink (reflection, learning, wisdom)

**Tools**:
- Trade logs (complete history)
- Market data (price action during hold)
- Analysis documents (thesis, reports)
- Pattern recognition frameworks

**Constraints**:
- MUST review ALL closed trades (winners AND losers)
- MUST distinguish luck from skill
- MUST identify process failures vs bad outcomes
- MUST extract actionable lessons

**Workflow**:
1. Gather all trade documents:
   - Opportunity scan
   - Initial analysis
   - Fundamental report
   - Technical report
   - Investment thesis
   - Position plan
   - Entry log
   - Monitoring updates
   - Exit log
2. Analyze thesis accuracy:
   - Was core hypothesis correct?
   - Did expected catalysts materialize?
   - Were risks accurately identified?
   - Did timeline match reality?
3. Review process adherence:
   - Was full workflow followed?
   - Were quality gates passed properly?
   - Were any steps skipped?
   - Were principles followed?
4. Evaluate outcome:
   - Profit/loss amount and %
   - vs expected (base case)
   - Risk/reward achieved vs planned
5. Categorize result:
   - **Skill-based win**: Good process + good outcome
   - **Lucky win**: Bad process + good outcome (concerning!)
   - **Unlucky loss**: Good process + bad outcome (acceptable)
   - **Avoidable loss**: Bad process + bad outcome (learn!)
6. Extract lessons:
   - What worked well? (repeat)
   - What didn't work? (avoid)
   - Process improvements needed?
   - Principle updates required?
7. Identify patterns:
   - Similar to past trades?
   - Recurring mistakes?
   - Consistent strengths?

**Output**: `post-mortem.md` with detailed review

**Post-Mortem Template**:
```markdown
# Post-Mortem: [TICKER]

## Trade Summary
- Entry: [date, price]
- Exit: [date, price]
- Holding period: [X days/weeks]
- P&L: $XXX (XX.X%)
- R:R achieved: X:1

## Thesis Review
**Was thesis correct?**: [Yes/No/Partially]
- Core hypothesis: [validation]
- Bull case: [did it play out?]
- Bear case risks: [did they materialize?]
- Catalysts: [which occurred?]

## Process Review
**Did we follow APEX-OS?**: [Yes/No]
- Opportunity scan: [✓/✗]
- Initial analysis: [✓/✗]
- Deep research: [✓/✗]
- Position planning: [✓/✗]
- Entry execution: [✓/✗]
- Ongoing monitoring: [✓/✗]
- Exit execution: [✓/✗]

**Quality gates passed?**: [All/Some/None]
- [List any gate failures]

## What Worked
1. [Specific thing that went well]
2. [Another success]

## What Didn't Work
1. [Specific mistake or issue]
2. [Another problem]

## Luck vs Skill Assessment
**Category**: [Skill-based win / Lucky win / Unlucky loss / Avoidable loss]

**Reasoning**: [Why this categorization]

## Lessons Learned
1. [Specific, actionable lesson]
2. [Another lesson]
3. [Process improvement needed]

## Principle Updates
[Any updates needed to investment principles based on this experience]

## Pattern Recognition
[Does this trade fit any patterns from previous trades?]
```

**Activation**: Use `/review-trade` command after exit

---

## The 16 Investment Principles (Skills)

Principles are stored in `apex-os/principles/` and auto-compiled into Claude Code skills in `.claude/skills/`. When analyzing stocks, relevant principles automatically load to ensure disciplined application.

### Category 1: Fundamental Analysis (5 Principles)

#### 1. Financial Health
**File**: `principles/fundamental/financial-health.md`
**Skill**: `fundamental-financial-health`

**Key Metrics**:
- Revenue growth: Consistent >10% YoY (high growth) or >5% YoY (stable)
- Profit margins: Expanding or stable (not contracting)
- Free cash flow: Positive and growing
- Debt-to-equity: <1.0 (or industry appropriate)
- Current ratio: >1.5 (ability to pay short-term obligations)
- Interest coverage: >3.0 (earnings can cover interest)

**Red Flags**:
- Declining revenues for 2+ quarters
- Margin compression
- Negative free cash flow
- Rising debt levels
- Inability to service debt

**When to use**: Every fundamental analysis

---

#### 2. Competitive Moat
**File**: `principles/fundamental/competitive-moat.md`
**Skill**: `fundamental-competitive-moat`

**Types of Moats**:
- Network effects (value grows with users - e.g., Facebook, Visa)
- Brand strength (pricing power - e.g., Apple, Nike)
- Cost advantages (scale economies - e.g., Walmart, Amazon)
- Switching costs (lock-in - e.g., enterprise software)
- Regulatory protection (licenses, patents)

**Assessment Questions**:
1. Can competitors easily replicate this?
2. What stops customers from switching?
3. Does the company have pricing power?
4. Is market share stable or growing?

**Scoring**:
- Strong moat (9-10): Multiple advantages, hard to replicate
- Moderate moat (6-8): Some advantages, defensible
- Weak moat (3-5): Limited advantages, competition intense
- No moat (0-2): Commodity business, price competition

**When to use**: Long-term investments, quality assessment

---

#### 3. Valuation Metrics
**File**: `principles/fundamental/valuation-metrics.md`
**Skill**: `fundamental-valuation-metrics`

**Methods**:

**Relative Valuation**:
- P/E ratio vs industry median (trading at premium/discount?)
- PEG ratio <1.5 (P/E justified by growth?)
- P/S ratio vs peers (sales multiple comparison)
- EV/EBITDA (enterprise value multiple)

**Absolute Valuation**:
- DCF (discounted cash flow) - what's intrinsic value?
- Margin of safety: Buy at 20-30% discount to intrinsic value

**Growth Adjustments**:
- High growth (>20%): Can justify higher P/E (25-35×)
- Moderate growth (10-20%): P/E 15-25×
- Slow growth (<10%): P/E 10-15×

**Warning Signs**:
- P/E >40× (unless exceptional growth)
- Negative earnings (unprofitable)
- P/S >10× (unless early-stage high-growth)

**When to use**: Determining entry prices, comparing opportunities

---

#### 4. Management Quality
**File**: `principles/fundamental/management-quality.md`
**Skill**: `fundamental-management-quality`

**Assessment Criteria**:

**Capital Allocation**:
- History of good M&A (accretive acquisitions)?
- Share buybacks at reasonable prices?
- Dividend policy aligned with growth stage?
- R&D investment appropriate for industry?

**Insider Activity**:
- Insiders buying (bullish signal)
- Insiders selling (bearish, unless routine/planned)
- Insider ownership >5% (skin in the game)

**Compensation**:
- Performance-based (aligned with shareholders)?
- Reasonable vs peers (not excessive)?
- Long-term incentives (not just short-term)?

**Communication**:
- Transparent in earnings calls?
- Admits mistakes and adjusts?
- Provides clear guidance?
- Accessible to investors?

**Red Flags**:
- Frequent management turnover
- Accounting irregularities
- Over-promising and under-delivering
- Insider selling at highs
- Excessive compensation

**When to use**: Bull/bear case development, red flag detection

---

#### 5. Industry Dynamics
**File**: `principles/fundamental/industry-dynamics.md`
**Skill**: `fundamental-industry-dynamics`

**Analysis Framework**:

**TAM (Total Addressable Market)**:
- Market size: Large ($1B+) or small?
- Growth rate: Expanding (>10%) or mature (<5%)?
- Penetration: Early stage or saturated?

**Competitive Landscape**:
- Market structure: Monopoly, oligopoly, or fragmented?
- Barriers to entry: High or low?
- Threat of new entrants?
- Substitute products available?

**Regulatory Environment**:
- Regulatory risks (healthcare, finance, energy)
- Policy changes pending?
- Compliance costs increasing?

**Cyclicality**:
- Cyclical (tied to economy - industrials, materials)
- Counter-cyclical (defensive - utilities, staples)
- Secular (long-term trend regardless of cycle)

**Porter's 5 Forces**:
1. Competitive rivalry
2. Threat of new entrants
3. Bargaining power of suppliers
4. Bargaining power of buyers
5. Threat of substitutes

**When to use**: Sector-specific analysis, long-term outlook

---

### Category 2: Technical Analysis (4 Principles)

#### 6. Trend Identification
**File**: `principles/technical/trend-identification.md`
**Skill**: `technical-trend-identification`

**Trend Definition**:
- **Uptrend**: Higher highs + higher lows
- **Downtrend**: Lower highs + lower lows
- **Sideways**: Range-bound, no clear direction

**Moving Averages**:
- 20-day MA: Short-term trend
- 50-day MA: Intermediate trend
- 200-day MA: Long-term trend
- Golden cross: 50 MA crosses above 200 MA (bullish)
- Death cross: 50 MA crosses below 200 MA (bearish)

**Trend Strength**:
- ADX >25: Strong trend
- ADX <20: Weak or no trend

**Multiple Timeframe Analysis**:
- Monthly: Long-term trend direction
- Weekly: Intermediate trend for swing trades
- Daily: Entry timing

**Trading with Trend**:
- **Rule**: Only take trades aligned with higher timeframe trend
- Example: If weekly is uptrend, only buy on daily pullbacks
- Never fight the trend

**When to use**: Entry timing, determining trade direction

---

#### 7. Support & Resistance
**File**: `principles/technical/support-resistance.md`
**Skill**: `technical-support-resistance`

**Types of S/R**:

**Horizontal Levels**:
- Previous swing highs (resistance)
- Previous swing lows (support)
- Round numbers ($50, $100, etc.)

**Volume at Price**:
- High volume areas = strong S/R
- Low volume areas = weak S/R
- Volume profile shows where most trading occurred

**Fibonacci Retracements**:
- 38.2%, 50%, 61.8% retracement levels
- Used to find pullback support in uptrends

**Moving Averages**:
- 50-day MA often acts as support in uptrends
- 200-day MA = major S/R level

**S/R Rules**:
1. Support becomes resistance after break (and vice versa)
2. Multiple touches = stronger level
3. Break + retest = confirmation
4. Volume required for valid break

**Stop Loss Placement**:
- Below support for longs (with buffer for false breaks)
- Above resistance for shorts

**When to use**: Entry/exit levels, stop placement, breakout trades

---

#### 8. Pattern Recognition
**File**: `principles/technical/pattern-recognition.md`
**Skill**: `technical-pattern-recognition`

**Continuation Patterns** (trend resumes):

**Bull Flags/Pennants**:
- Sharp move up + consolidation + breakout
- Measured move: Pole length projected from breakout
- Success rate: ~70%

**Ascending Triangles**:
- Flat resistance + rising support
- Breakout to upside
- Success rate: ~75%

**Reversal Patterns** (trend changes):

**Head & Shoulders**:
- Left shoulder + head + right shoulder
- Break of neckline = trend reversal
- Measured move: Head to neckline distance projected down
- Success rate: ~85%

**Double Top/Bottom**:
- Two similar highs (top) or lows (bottom)
- Break of middle support/resistance confirms
- Success rate: ~80%

**Candlestick Patterns**:
- Doji (indecision)
- Hammer (potential bottom)
- Shooting star (potential top)
- Engulfing (reversal)

**Pattern Confirmation**:
- Volume required (breakout >avg volume)
- Follow-through needed (don't reverse next day)
- Measured moves are targets, not guarantees

**When to use**: Short-term timing, breakout entries

---

#### 9. Volume Analysis
**File**: `principles/technical/volume-analysis.md`
**Skill**: `technical-volume-analysis`

**Volume Principles**:

**Confirmation**:
- Rising prices + rising volume = healthy uptrend
- Rising prices + falling volume = weak (distribution)
- Falling prices + rising volume = healthy downtrend
- Falling prices + falling volume = weak (exhaustion)

**Breakout Validation**:
- Valid breakout: Volume >1.5× average
- Failed breakout: Volume <average (likely false break)

**Accumulation/Distribution**:
- Accumulation: Rising volume on up days, falling on down days
- Distribution: Rising volume on down days, falling on up days

**Volume Patterns**:
- Climax volume: Exhaustion signal (often reversal)
- Drying up volume: Consolidation ending (breakout coming)
- Increasing volume: Trend strengthening

**Relative Volume**:
- Compare today's volume to average
- >200% avg = significant interest
- <50% avg = low conviction

**When to use**: Validating breakouts, gauging trend strength

---

### Category 3: Risk Management (4 Principles)

#### 10. Position Sizing
**File**: `principles/risk-management/position-sizing.md`
**Skill**: `risk-position-sizing`

**Fixed Percentage Risk Model**:

**Formula**:
```
Position Size = (Portfolio Value × Risk%) / (Entry Price - Stop Loss)
```

**Example**:
- Portfolio: $100,000
- Risk per trade: 1.5% = $1,500
- Entry: $50
- Stop: $48
- Risk per share: $2
- Position size: $1,500 / $2 = 750 shares ($37,500 total)

**Risk Guidelines**:
- Conservative: 1% per trade
- Moderate: 1.5% per trade
- Aggressive: 2% per trade (absolute maximum)
- Never exceed 2% on single trade

**Portfolio Heat Limits**:
- Max simultaneous risk: 6-8% of portfolio
- Example: With 1.5% per trade, max 4-5 positions at risk
- If already at limit, must exit a position before entering new one

**Position Concentration**:
- Max position size: 10-15% of portfolio (even if risk allows more)
- Prevents over-concentration in single idea

**Kelly Criterion** (optional advanced):
- Optimal position size based on win rate and payoff ratio
- Formula: f = (p × b - q) / b
- Where: p = win probability, q = loss probability, b = payoff ratio
- Use fractional Kelly (25-50%) to reduce volatility

**When to use**: EVERY position entry, no exceptions

---

#### 11. Stop Loss Placement
**File**: `principles/risk-management/stop-loss-placement.md`
**Skill**: `risk-stop-loss-placement`

**Stop Loss Methods**:

**1. Technical Stop** (preferred):
- Below support level for longs
- Add buffer for false breaks (1-2%)
- Example: Support at $48, set stop at $47.50

**2. ATR-Based Stop**:
- Use 2-3× ATR below entry
- Accounts for volatility
- Example: Stock with $2 ATR, entry $50, stop at $50 - (2.5 × $2) = $45

**3. Percentage Stop**:
- Fixed % below entry (e.g., 7%)
- Simple but doesn't account for volatility
- Maximum: 8% stop (never wider)

**4. Time-Based Stop**:
- If no progress in 2× expected timeline, exit
- Example: Expected 2-week move, if sideways after 4 weeks, exit

**Stop Management**:

**Never Move Stop Down** (for longs):
- Stop can only move up (trailing)
- Moving down = rationalization = danger

**Trail Stops**:
- After hitting first target, move stop to breakeven
- After hitting second target, trail at 10-15% below peak
- Final position: Trail at 20% below peak (give room to run)

**Stop Types**:
- Mental stop: Watch but don't place order (risk of emotional override)
- Stop market: Guaranteed execution, but price varies
- Stop limit: Price protection, but might not fill (gapping risk)

**When to use**: EVERY position immediately after entry

---

#### 12. Profit Taking
**File**: `principles/risk-management/profit-taking.md`
**Skill**: `risk-profit-taking`

**Scale-Out Strategy** (recommended):

**Scale Out in Thirds**:
1. **First 1/3 at 2:1 R:R**
   - If risking $500, take $1,000 profit on 1/3
   - Move stop to breakeven on remaining
   - Locks in profit, de-risks position

2. **Second 1/3 at 3:1 R:R**
   - Take second tranche at higher target
   - Trail stop on remaining 1/3

3. **Final 1/3 with trailing stop**
   - Trail at 15-20% below peak
   - Let winners run
   - This is where big gains happen

**Trailing Stop Methods**:
- Fixed percentage (15-20% below peak)
- ATR-based (3-4× ATR below peak)
- Support-based (trail below next support level)

**Risk/Reward Minimum**:
- Never take trades with <2:1 R:R
- Prefer 3:1 or better
- Example: Risk $500 to make $1,500+

**Time-Based Profit Review**:
- If held 2× expected time with minimal profit, evaluate
- Opportunity cost: Could capital do better elsewhere?

**Don't**:
- Take profits too early (fear of giving back gains)
- Let winners turn into losers (trail stops)
- Sell entire position at once (prevents catching large moves)

**When to use**: Planning exits before entry, during position

---

#### 13. Portfolio Diversification
**File**: `principles/risk-management/portfolio-diversification.md`
**Skill**: `risk-portfolio-diversification`

**Position Limits**:

**Individual Position**:
- Maximum: 10-15% of portfolio in single stock
- Prevents catastrophic loss if wrong
- Example: $100k portfolio, max $10-15k per position

**Number of Positions**:
- Minimum: 5 positions (below this, under-diversified)
- Optimal: 8-12 positions (manageable, diversified)
- Maximum: 20 positions (above this, over-diversified, hard to track)

**Sector Exposure**:
- Maximum per sector: 25-30% of portfolio
- Prevents sector rotation risk
- Example: No more than 3 tech stocks if tech = 25% of portfolio

**Correlation Analysis**:
- Check correlation between positions
- Avoid multiple positions moving together (not truly diversified)
- Example: If already long tech leader, don't add another tech stock

**Cash Reserves**:
- Minimum cash: 20% of portfolio
- Allows for new opportunities
- Reduces need to sell existing positions
- Acts as defense in downturns

**Market Exposure**:
- Bull market: 60-80% invested
- Uncertain market: 40-60% invested
- Bear market: 20-40% invested (defensive)

**Asset Allocation** (if beyond stocks):
- Stocks: 60-80% (primary focus)
- Bonds: 0-20% (stability)
- Alternatives: 0-10% (diversification)
- Cash: 10-30% (opportunities + defense)

**When to use**: Before entering any new position, portfolio reviews

---

### Category 4: Behavioral/Psychological (3 Principles)

#### 14. Emotional Discipline
**File**: `principles/behavioral/emotional-discipline.md`
**Skill**: `behavioral-emotional-discipline`

**Core Rules**:

**NO FOMO (Fear of Missing Out)**:
- Must follow complete APEX-OS workflow
- No shortcuts because "stock is running"
- If you missed the entry, wait for pullback or move on
- There's always another opportunity

**NO Panic Selling**:
- Trust your stops
- Don't exit based on fear alone
- Only exit if: stop hit, thesis violated, or target reached
- Market volatility is normal

**NO Averaging Down**:
- If position goes against you, don't add
- Only average down if:
  - Original thesis still intact (confirmed, not rationalized)
  - Technical setup improves
  - Planned scale-in strategy from beginning
- Usually, averaging down = denial of being wrong

**NO Revenge Trading**:
- After loss, don't immediately look for "recovery trade"
- Take break after 2 consecutive losses
- Review what went wrong before trading again
- Losses are normal part of trading

**Emotional Triggers to Watch**:
- Euphoria after big win (leads to overconfidence)
- Fear after big loss (leads to hesitation)
- Frustration after string of small losses (leads to bigger bets)
- Boredom (leads to overtrading)

**Mitigation Strategies**:
- Follow APEX-OS workflow religiously (structure prevents emotion)
- Take breaks after emotional trades
- Review post-mortems to recognize patterns
- Keep position sizes consistent (prevents big emotional swings)
- Journal emotional state during trades

**When to use**: Every decision point, self-awareness check

---

#### 15. Confirmation Bias Prevention
**File**: `principles/behavioral/confirmation-bias-prevention.md`
**Skill**: `behavioral-confirmation-bias-prevention`

**Confirmation Bias**: Tendency to seek information confirming existing beliefs and ignore contradictory evidence.

**Mitigation Techniques**:

**Devil's Advocate**:
- Assign yourself to argue against your thesis
- What evidence would prove you wrong?
- What are the best arguments bears would make?
- Is there data you're ignoring because it's inconvenient?

**Bear Case Requirement**:
- MUST write detailed bear case (not just one sentence)
- Must be as thorough as bull case
- Must assign realistic probability
- If can't write strong bear case, thesis is weak

**Seek Disconfirming Evidence**:
- Actively search for reasons NOT to buy
- Read bearish articles
- Check short seller reports
- Review negative reviews/ratings

**Thesis Challenges**:
- Weekly: Ask "what would prove me wrong?"
- Monthly: Review full thesis with fresh eyes
- Quarterly: Pretend you're starting from scratch—would you buy today?

**Third Party Review**:
- Explain thesis to non-investor friend
- If you can't explain simply, you don't understand it
- Listen to their questions without defensiveness

**Pre-Mortem Exercise**:
- Before entering, imagine trade failed
- What would have caused the failure?
- How could you have avoided it?
- This surfaces hidden assumptions

**Warning Signs You're Biased**:
- Dismissing negative news quickly
- Rationalizing why bad data "doesn't matter"
- Overweighting positive evidence
- Getting defensive when questioned
- Ignoring your stop loss

**When to use**: Thesis writing, monitoring, before major decisions

---

#### 16. Learning from Mistakes
**File**: `principles/behavioral/learning-from-mistakes.md`
**Skill**: `behavioral-learning-from-mistakes`

**Mistake Categories**:

**Process Mistakes** (avoidable):
- Skipped APEX-OS workflow steps
- Ignored quality gate failures
- Didn't follow position plan
- Moved stops emotionally
- **Action**: Fix process, these are errors

**Outcome Mistakes** (unavoidable):
- Followed process perfectly but lost money
- Thesis was reasonable but wrong
- Unforeseeable events
- **Action**: Accept as part of trading, review but don't over-correct

**Lucky Wins** (dangerous):
- Made money despite bad process
- Skipped analysis and got lucky
- FOMO trade that worked
- **Action**: Don't reinforce bad habits

**Post-Mortem Requirements**:

**MUST complete post-mortem for**:
- ALL losing trades (understand what went wrong)
- ALL winning trades (understand what went right)
- Especially: Lucky wins and unlucky losses

**Post-Mortem Frequency**:
- Individual: Within 1 week of closing trade
- Monthly: Review all trades that month
- Quarterly: Look for patterns across trades

**Pattern Recognition**:

Track mistake patterns:
- Same mistake 3× = systemic issue needing fix
- Example patterns:
  - "I always hold losers too long" → Need stricter stop discipline
  - "I take profits too early" → Need scale-out strategy
  - "I chase breakouts" → Need patience discipline

**Mistake Log**:
Keep running log:
```markdown
# Trading Mistakes Log

## Trade [TICKER] - [Date]
**Mistake**: [What went wrong]
**Category**: [Process/Outcome/Lucky win]
**Cost**: $XXX
**Lesson**: [Specific takeaway]
**Fix**: [What to do differently]

## Pattern Alert
**Recurring mistake**: [If 3+ times]
**Frequency**: X occurrences
**Total cost**: $XXX
**Action plan**: [Systematic fix]
```

**Learning Metrics to Track**:
- Win rate (but remember, can win with <50%)
- Average win size vs average loss size (should be >2:1)
- Largest loss (should never exceed 2% of portfolio)
- Process adherence rate (% of trades following full workflow)
- Mistake repeat rate (are you making same mistakes?)

**Continuous Improvement**:
- Monthly: Review patterns, update principles if needed
- Quarterly: Review all post-mortems, identify themes
- Annually: Assess overall approach, major adjustments if needed

**When to use**: After every closed position, monthly/quarterly reviews

---

## Quality Gates

Quality gates are mandatory checkpoints preventing emotional and impulsive decisions. Cannot be overridden without documented exception.

### Gate 1: Thesis Verification (Before Entry)

**Timing**: After deep research, before position planning

**Purpose**: Ensure thesis is strong enough to risk capital

**Checks**:
1. ✓ Fundamental score ≥6/10
2. ✓ Technical score ≥7/10
3. ✓ Risk/reward ratio ≥2:1
4. ✓ Thesis is falsifiable (clear exit conditions stated)
5. ✓ Bull AND bear cases documented (not just bull)
6. ✓ Potential catalysts identified (within expected timeline)
7. ✓ No conflicting positions (correlation check passed)

**Decision Matrix**:
- **7/7 pass**: Strong GO (proceed to position planning)
- **6/7 pass**: Conditional GO (note concerns, proceed with caution)
- **5/7 pass**: YELLOW (address failures before proceeding)
- **<5/7 pass**: NO GO (back to watchlist or pass entirely)

**Common Failure Reasons**:
- Fundamental weak (<6/10): "I like the chart but company is deteriorating"
- Technical weak (<7/10): "Great company but setup is poor"
- R:R poor (<2:1): "Stop too far or target too close"
- Not falsifiable: "I'll just hold forever" (dangerous)
- Only bull case: "Can't think of what could go wrong" (blind spot)
- Conflicting position: "Already have similar exposure"

**Override Procedure** (rare):
If you believe gate should be overridden:
1. Document specific reason why
2. Note risks being accepted
3. Reduce position size by 50% (acknowledgment of weakness)
4. Mark for extra scrutiny in monitoring

**Output**: Gate 1 report documenting pass/fail on each check

---

### Gate 2: Execution Verification (At Entry)

**Timing**: Immediately after entering position

**Purpose**: Ensure execution matched plan and risk is controlled

**Checks**:
1. ✓ Entry price within planned range (ideal to maximum)
2. ✓ Position size matches plan (±5% acceptable)
3. ✓ Stop loss order placed and confirmed active
4. ✓ Portfolio risk limits not exceeded (<8% total heat)
5. ✓ All orders confirmed filled (entry, stop, targets)

**Execution Quality Scoring**:
- **Perfect**: Filled at ideal price, exact size, all orders placed
- **Good**: Filled within acceptable range, orders placed
- **Fair**: Filled at maximum price or size slightly off
- **Poor**: Exceeded maximum price, size significantly off, or missing orders

**Common Failure Reasons**:
- Entry price slippage (stock ran away)
- Forgot to place stop loss immediately
- Position size too large (broke risk rules)
- Market order filled worse than expected

**Remediation**:
If any check fails:
- **Entry price exceeded max**: Exit immediately (setup invalidated)
- **Position size too large**: Reduce position to planned size
- **No stop placed**: Place immediately (unacceptable to delay)
- **Portfolio heat exceeded**: Exit another position first

**Output**: Execution report with deviations noted

---

### Gate 3: Ongoing Monitoring (During Hold)

**Timing**: Daily quick check, weekly deep check

**Purpose**: Ensure thesis remains valid and position healthy

**Daily Quick Checks** (<5 min per position):
1. ✓ Price vs key levels (stop threatened? target approached?)
2. ✓ Any major news (company, sector, market)?
3. ✓ Any unusual action (volume spike, volatility)?

**Weekly Deep Checks** (~15 min per position):
1. ✓ Thesis still valid (fundamentals intact, technical structure sound)?
2. ✓ Time in trade vs expected (on track or stalling)?
3. ✓ Performance relative to plan (meeting expectations)?
4. ✓ Any adjustments needed (trail stops, reassess thesis)?

**Health Scoring** (0-10):
- **9-10 (Green)**: Thesis intact, technical strong, on track
- **6-8 (Yellow)**: Some concerns but manageable
- **3-5 (Orange)**: Significant concerns, close monitoring needed
- **0-2 (Red)**: Thesis violation, exit immediately

**Thesis Violation Triggers**:

**Red Flags** (exit immediately):
- Major fundamental deterioration (earnings miss >20%, guidance down >30%)
- Technical breakdown (loses key support on 2× average volume)
- Management scandal or major negative news (fraud, lawsuit, etc.)
- Black swan event affecting company directly

**Yellow Flags** (reassess within 24 hours):
- Minor earnings miss (<10%)
- Technical weakness (approaching but not through support)
- Sector weakness affecting all stocks
- Increased volatility without clear reason

**Exit Decision Framework**:
```
Is thesis violated?
  YES → Exit immediately (don't hope)
  NO → Continue holding

Is technical setup broken?
  YES → Exit if can't recover quickly
  NO → Continue holding

Is time stop reached (2× expected timeline)?
  YES → Evaluate if should hold or move on
  NO → Continue holding

Is better opportunity available?
  YES → Consider opportunity cost, potentially exit
  NO → Continue holding
```

**Output**: Weekly monitoring update with health score

---

### Gate 4: Exit Verification (At Sale)

**Timing**: Immediately after exiting position

**Purpose**: Ensure exit was systematic, not emotional

**Checks**:
1. ✓ Exit followed plan (stop, target, thesis, or time)?
2. ✓ Not emotional override (fear, greed, impatience)?
3. ✓ Execution at planned levels (or better)?
4. ✓ P&L calculated correctly
5. ✓ All orders cancelled (stops, targets if any remain)

**Exit Reason Categories**:
- **Stop Loss Hit**: Risk management worked (even if loss, correct process)
- **Profit Target Hit**: Plan worked, took profits as planned
- **Thesis Falsified**: Fundamentals changed, exit was right call
- **Time Stop**: No progress, capital redeployed (opportunity cost)
- **Better Opportunity**: Logical reallocation (acceptable)
- **Emotional**: Fear, impatience, hope (needs review)

**Exit Quality Scoring**:
- **Excellent**: Followed plan exactly (stop, target, or thesis)
- **Good**: Minor deviation but justified
- **Fair**: Emotional component but not pure panic
- **Poor**: Pure emotion (panic, greed, hope)

**Red Flags**:
- Exited before stop with no thesis violation (fear)
- Held through stop hoping for recovery (hope)
- Sold winner too early out of fear of giving back gains (fear)
- Sold at exact bottom (capitulation)

**Output**: Exit log with reason and quality score

---

### Gate 5: Post-Mortem (After Position Closed)

**Timing**: Within 1 week of exit

**Purpose**: Extract learning and prevent repeating mistakes

**Checks**:
1. ✓ Post-mortem completed (full template)
2. ✓ Thesis accuracy assessed (correct/incorrect/partial)
3. ✓ Process adherence reviewed (all gates passed?)
4. ✓ Luck vs skill categorized (honest assessment)
5. ✓ Lessons extracted (specific, actionable)
6. ✓ Patterns identified (similar to past trades?)
7. ✓ Principle updates noted (if needed)

**Post-Mortem Quality**:
- **Excellent**: Thorough, honest, actionable lessons
- **Good**: Complete but could go deeper
- **Fair**: Rushed, surface-level
- **Poor**: Skipped or rationalized away

**Learning Extraction**:

**For Winners**:
- What made it work? (repeat this)
- Was it skill or luck? (honest!)
- What could have been better?
- Pattern: Similar to past winners?

**For Losers**:
- What went wrong? (avoid this)
- Process failure or bad outcome?
- Could it have been prevented?
- Pattern: Similar to past losers?

**Pattern Recognition**:
After 10 trades, look for:
- Recurring mistakes (fix these systemically)
- Consistent strengths (do more of this)
- Environmental factors (what market conditions work best for you?)

**Principle Updates**:
If pattern emerges (3+ times):
- Update relevant principle file
- Add to skills system
- Incorporate into future analysis

**Output**: Complete post-mortem document with learnings

---

## File Structure

```
apex-os/
├── .claude/                          # Claude Code integration
│   ├── agents/apex-os/              # 8 specialized investment agents
│   │   ├── market-scanner.md
│   │   ├── fundamental-analyst.md
│   │   ├── technical-analyst.md
│   │   ├── risk-manager.md
│   │   ├── thesis-writer.md
│   │   ├── executor.md
│   │   ├── portfolio-monitor.md
│   │   └── post-mortem-analyst.md
│   │
│   ├── commands/apex-os/            # 6 workflow slash commands
│   │   ├── scan-opportunities.md
│   │   ├── analyze-stock.md
│   │   ├── write-thesis.md
│   │   ├── plan-position.md
│   │   ├── execute-entry.md
│   │   └── review-trade.md
│   │
│   └── skills/                      # 16 auto-generated skills
│       ├── fundamental-financial-health/SKILL.md
│       ├── fundamental-competitive-moat/SKILL.md
│       ├── fundamental-valuation-metrics/SKILL.md
│       ├── fundamental-management-quality/SKILL.md
│       ├── fundamental-industry-dynamics/SKILL.md
│       ├── technical-trend-identification/SKILL.md
│       ├── technical-support-resistance/SKILL.md
│       ├── technical-pattern-recognition/SKILL.md
│       ├── technical-volume-analysis/SKILL.md
│       ├── risk-position-sizing/SKILL.md
│       ├── risk-stop-loss-placement/SKILL.md
│       ├── risk-profit-taking/SKILL.md
│       ├── risk-portfolio-diversification/SKILL.md
│       ├── behavioral-emotional-discipline/SKILL.md
│       ├── behavioral-confirmation-bias-prevention/SKILL.md
│       └── behavioral-learning-from-mistakes/SKILL.md
│
├── principles/                      # Investment principle source files
│   ├── fundamental/
│   │   ├── financial-health.md
│   │   ├── competitive-moat.md
│   │   ├── valuation-metrics.md
│   │   ├── management-quality.md
│   │   └── industry-dynamics.md
│   ├── technical/
│   │   ├── trend-identification.md
│   │   ├── support-resistance.md
│   │   ├── pattern-recognition.md
│   │   └── volume-analysis.md
│   ├── risk-management/
│   │   ├── position-sizing.md
│   │   ├── stop-loss-placement.md
│   │   ├── profit-taking.md
│   │   └── portfolio-diversification.md
│   └── behavioral/
│       ├── emotional-discipline.md
│       ├── confirmation-bias-prevention.md
│       └── learning-from-mistakes.md
│
├── portfolio/                       # Portfolio-level documents
│   ├── portfolio-strategy.md       # Overall investment approach
│   └── watchlist.md                 # Tracked opportunities
│
├── opportunities/                   # Initial opportunity scans
│   └── YYYY-MM-DD-TICKER.md        # One file per opportunity
│
├── analysis/                        # Deep analysis folders
│   └── YYYY-MM-DD-TICKER/
│       ├── initial-analysis.md
│       ├── fundamental-report.md
│       ├── technical-report.md
│       ├── risk-assessment.md
│       ├── investment-thesis.md
│       └── position-plan.md
│
├── positions/                       # Active and closed positions
│   └── YYYY-MM-DD-TICKER/
│       ├── entry-log.md
│       ├── monitoring/
│       │   └── YYYY-MM-DD-update.md
│       ├── exit-log.md
│       └── post-mortem.md
│
└── reports/                         # Performance reports
    ├── monthly-review-YYYY-MM.md
    ├── quarterly-review-YYYY-QX.md
    └── annual-review-YYYY.md
```

---

## Example Trade Workflow

Let's walk through a complete example trade using APEX-OS.

### Trade: AAPL (Apple Inc.)

---

#### Phase 1: Opportunity Discovery

**Date**: 2025-11-15

**Agent**: market-scanner

**Trigger**: Technical breakout screener flagged AAPL breaking above $200 with 2× average volume

**Initial Check**:
- Revenue: Growing ✓
- Profitable: Yes ✓
- Trend: Uptrend ✓
- Volume: Strong ✓

**Decision**: Move to initial analysis

**File Created**: `opportunities/2025-11-15-AAPL.md`

---

#### Phase 2: Initial Analysis

**Date**: 2025-11-16

**Agents**: fundamental-analyst (light), technical-analyst (light)

**Fundamental Quick Score**: 8/10
- Revenue growth: 8% YoY (stable)
- Margins: Industry-leading 25%+
- Cash: $60B+ net cash
- Recent earnings: Beat estimates

**Technical Quick Score**: 8/10
- Trend: Strong uptrend
- Breaking 6-month resistance at $200
- Volume: 2.5× average (strong)
- Setup: Clean breakout

**Decision**: Proceed to deep research (both scores ≥5)

**File Created**: `analysis/2025-11-16-AAPL/initial-analysis.md`

---

#### Phase 3: Deep Research

**Date**: 2025-11-17

**Agents**: fundamental-analyst, technical-analyst, risk-manager, thesis-writer

**A. Fundamental Deep Dive** (2 hours)

**Financial Health**:
- Revenue: $394B (8% growth)
- Net margin: 26% (excellent)
- FCF: $100B+ (strong)
- Debt/Equity: 1.8 (acceptable given cash hoard)
- Score: 9/10

**Competitive Moat**:
- Brand strength: Best-in-class
- Ecosystem lock-in: High switching costs
- Network effects: App Store
- Pricing power: Premium products
- Score: 10/10

**Valuation**:
- P/E: 28× (vs 5-year avg of 25×)
- PEG: 3.5 (high but growth accelerating)
- DCF: $215 fair value (+7.5% upside)
- Margin of safety: Slight premium but justified
- Score: 7/10 (fairly valued to slight premium)

**Management**:
- Capital allocation: Excellent (buybacks, dividends, R&D)
- Tim Cook: Proven track record
- Insider buying: Recent purchases by CFO
- Score: 9/10

**Industry Dynamics**:
- Smartphone TAM: $500B (mature but stable)
- Services growing 15%+ (high margin)
- AI integration opportunity (Vision Pro, AI features)
- Regulatory risks: Antitrust scrutiny
- Score: 8/10

**Bull Case** (40% probability):
- AI features drive iPhone upgrade cycle
- Services revenue accelerates (20%+ growth)
- Vision Pro gains traction
- Target: $235 (+17.5%)

**Base Case** (50% probability):
- Steady iPhone sales
- Services growth 12-15%
- Target: $220 (+10%)

**Bear Case** (10% probability):
- Regulatory headwinds impact App Store
- China weakness continues
- Target: $190 (-5%)

**Fundamental Score**: 8.2/10

---

**B. Technical Deep Dive** (1 hour)

**Trend Analysis**:
- All timeframes uptrend (daily, weekly, monthly)
- Above all major MAs (20, 50, 200)
- ADX: 32 (strong trend)

**Support/Resistance**:
- Breaking resistance: $200 (6-month consolidation)
- Next resistance: $210 (previous high)
- Support: $195 (previous resistance, now support)

**Pattern**:
- Bull flag continuation pattern
- Measured move target: $218
- Volume confirmation: ✓

**Entry Levels**:
- Ideal: $200-201 (at breakout)
- Acceptable: $201-203 (slight chase)
- Maximum: $205 (don't chase further)

**Stop Loss**:
- Technical: $195 (below breakout level)
- ATR: $193 (2.5× ATR = $7.50, so $200-7.50)
- Use: $195 (technical stop, 2.5% risk)

**Targets**:
- Target 1: $210 (+5%, 2:1 R:R)
- Target 2: $218 (+9%, 3.6:1 R:R)
- Target 3: Trail at $220+

**Technical Score**: 8.5/10

---

**C. Risk Assessment**

**Portfolio Context**:
- Portfolio value: $100,000
- Current positions: 3 (MSFT, GOOGL, NVDA)
- Current risk: 4.5% (3 positions × 1.5% each)
- Available risk capacity: 3.5%

**Position Sizing**:
- Risk per trade: 1.5% of portfolio = $1,500
- Entry: $200
- Stop: $195
- Risk per share: $5
- Position size: $1,500 / $5 = 300 shares
- Total cost: $60,000 (within limits)

**Correlation Check**:
- Existing tech exposure: 45% (MSFT, GOOGL, NVDA)
- Adding AAPL: Would be 60% tech (acceptable, but watch)
- Correlation: High with existing positions (all tech)
- Concern: Sector concentration risk

**Risk/Reward**:
- Risk: $1,500 (1.5% of portfolio)
- Reward (Target 1): $3,000 (2:1)
- Reward (Target 2): $5,400 (3.6:1)

**File Created**: `analysis/2025-11-16-AAPL/risk-assessment.md`

---

**D. Investment Thesis** (30 min)

**Thesis Writer** synthesizes all analysis:

```markdown
# Investment Thesis: AAPL

## Core Hypothesis
Apple is breaking out of 6-month consolidation on strong volume,
presenting a technical continuation setup with fundamental support
from accelerating services growth and potential AI-driven upgrade cycle.

## Bull Case (40% probability)
AI integration drives iPhone upgrade cycle, services accelerate to 20%
growth, Vision Pro gains early traction. Price target: $235 (+17.5%).

## Base Case (50% probability)
Steady iPhone demand continues, services grow 12-15%, incremental
margin improvement. Price target: $220 (+10%).

## Bear Case (10% probability)
Regulatory headwinds impact App Store economics, China weakness
persists, tech sector rotation. Price target: $190 (-5%, limited by stop).

## Catalysts
**Positive**:
- Q4 earnings (Feb 1): Services revenue acceleration
- WWDC 2026 (June): AI feature announcements
- iPhone 16 cycle: Upgrade demand

**Risks**:
- Antitrust actions against App Store
- China geopolitical tensions
- Tech sector valuation compression

## Falsification Criteria (Exit Triggers)
1. Breaks below $195 on volume (technical breakdown)
2. Services growth decelerates <10% (thesis deterioration)
3. Major regulatory action against App Store (fundamental change)
4. Tech sector selloff >15% from highs (risk management)

## Timeline
Expected hold: 6-12 weeks
Key dates: Feb 1 earnings, June WWDC
```

**File Created**: `analysis/2025-11-16-AAPL/investment-thesis.md`

---

#### Quality Gate 1: Thesis Verification

**Checks**:
1. ✓ Fundamental score ≥6/10: 8.2/10 (PASS)
2. ✓ Technical score ≥7/10: 8.5/10 (PASS)
3. ✓ R:R ratio ≥2:1: 2:1 to 3.6:1 (PASS)
4. ✓ Falsifiable: 4 clear exit conditions (PASS)
5. ✓ Bull AND bear cases: Both documented (PASS)
6. ✓ Catalysts identified: 3 positive, timeline clear (PASS)
7. ⚠ Conflicting positions: High tech exposure already (CONCERN)

**Decision**: Conditional GO
- Note: Sector concentration risk
- Mitigation: Reduce position size to 1% risk (vs standard 1.5%)
- If one of the other tech positions exits, can increase back to 1.5%

**Proceed to position planning with modified risk**

---

#### Phase 4: Position Planning

**Date**: 2025-11-17

**Agent**: risk-manager

**Position Plan**:
```markdown
# Position Plan: AAPL

## Entry Strategy
- Entry method: Limit order
- Ideal price: $200.00
- Acceptable range: $200.00 - $202.00
- Maximum: $203.00 (don't chase beyond)
- Validity: 3 trading days

## Position Sizing
Portfolio: $100,000
Risk per trade: 1.0% (reduced due to sector concentration)
Risk amount: $1,000

Entry: $200
Stop: $195
Risk per share: $5

Position size: $1,000 / $5 = 200 shares
Total cost: ~$40,000 (40% of portfolio, within 15% per position limit)

## Risk Management
Stop loss: $195 (2.5% below entry)
- Place immediately after fill
- GTC stop market order
- Below technical support

## Profit Targets
Target 1: $210 (+5%, 2:1 R:R)
- Sell 67 shares (1/3 position)
- Profit: $670
- Move stop to $200.50 (breakeven on remaining)

Target 2: $218 (+9%, 3.6:1 R:R)
- Sell 67 shares (1/3 position)
- Profit: $1,206
- Trail stop on final 66 shares

Target 3: Trail final 1/3
- Trail at 15% below peak
- If hits $225, trail at $191
- Let winners run

## Risk/Reward Summary
Total risk: $1,000 (1% of portfolio)
Potential reward:
- Target 1: $670 (0.67:1 on 1/3)
- Target 2: $1,206 (1.2:1 on 1/3)
- Target 3: $XXX (trail, variable)
- Combined: ~$2,500+ (2.5:1 overall)

## Timeline
Expected hold: 6-12 weeks
Review: Weekly
Time stop: If no progress after 16 weeks, exit
```

**File Created**: `analysis/2025-11-16-AAPL/position-plan.md`

---

#### Phase 5: Execution

**Date**: 2025-11-18

**Agent**: executor

**Entry Execution**:
- **08:45 AM**: Placed limit order: Buy 200 shares at $200.50 (acceptable range)
- **09:32 AM**: Order filled: 200 shares @ $200.62 (avg, within range)
- **09:33 AM**: Stop loss placed: Sell 200 shares stop @ $195.00 (GTC)
- **09:34 AM**: Target 1 placed: Sell 67 shares limit @ $210.00 (GTC)
- **09:34 AM**: Target 2 placed: Sell 67 shares limit @ $218.00 (GTC)

**Execution Quality**: Good
- Entry: $200.62 (vs ideal $200, acceptable $200-202) ✓
- Position size: 200 shares (exact) ✓
- Stop placed: Immediately ✓
- Targets placed: Yes ✓

**Portfolio Impact**:
- New position: $40,124 (40% of portfolio, within limit)
- Total risk: 5.5% (was 4.5%, added 1%)
- Tech exposure: 58% (high but acceptable)

**File Created**: `positions/2025-11-18-AAPL/entry-log.md`

**Quality Gate 2: Execution Verification** ✓ PASS

---

#### Phase 6: Position Management

**Weeks 1-3: Monitoring**

**Agent**: portfolio-monitor

**Week 1 Update** (2025-11-25):
- Price: $205 (+2.2%)
- Thesis: Intact ✓
- Technical: Uptrend continues ✓
- News: None significant
- Health score: 9/10 (healthy)

**Week 2 Update** (2025-12-02):
- Price: $209 (+4.2%)
- Thesis: Intact ✓
- Technical: Approaching Target 1 ✓
- News: Services growth reported +14% (bullish)
- Health score: 9/10 (healthy, approaching target)

**Week 3 Update** (2025-12-09):
- **Price: $211 (+5.2%)**
- **Event: Target 1 hit!**
- **Action taken**:
  - Sold 67 shares @ $210.00 = $14,070
  - Profit on 1/3: $670
  - Moved stop to $201 (breakeven) on remaining 133 shares
- Thesis: Intact ✓
- Technical: Strong, consolidating before next leg ✓
- Health score: 9/10

**File Created**: `positions/2025-11-18-AAPL/monitoring/2025-12-09-target1-hit.md`

---

**Weeks 4-5: Continued Monitoring**

**Week 4 Update** (2025-12-16):
- Price: $214 (+6.7%)
- Thesis: Intact ✓
- Technical: Grinding higher ✓
- News: Vision Pro sales better than expected
- Health score: 9/10

**Week 5 Update** (2025-12-23):
- **Price: $219 (+9.2%)**
- **Event: Target 2 hit!**
- **Action taken**:
  - Sold 67 shares @ $218.00 = $14,606
  - Profit on 2nd 1/3: $1,166
  - Trailing stop on final 66 shares: $186 (15% below $219)
- Thesis: Intact ✓
- Technical: Very strong, potential for extension ✓
- Health score: 9/10

**File Created**: `positions/2025-11-18-AAPL/monitoring/2025-12-23-target2-hit.md`

---

**Weeks 6-8: Trailing Stop Management**

**Week 6 Update** (2025-12-30):
- Price: $223 (+11.1%)
- Action: Trail stop to $189.50 (15% below new high)
- Health score: 9/10

**Week 7 Update** (2026-01-06):
- Price: $225 (+12.1%)
- Action: Trail stop to $191.25 (15% below new high)
- Health score: 9/10

**Week 8 Update** (2026-01-13):
- **Price: $222 (+10.6%)**
- **Event: Starting to pull back**
- **Action**: Keep trail at $191.25
- Health score: 8/10 (profit-taking pressure)

**Week 9 Update** (2026-01-20):
- **Price: $216 (+7.7%)**
- **Event: Consolidating**
- **Thesis check**: Still intact, earnings approaching
- **Action**: Keep trail at $191.25
- Health score: 7/10 (consolidation, watching)

**Week 10 Update** (2026-01-27):
- **Price: $213 (+6.2%)**
- **Event: Continued consolidation**
- **Decision**: Tighten trail to $203 (5% below current, lock in more profit)
- Health score: 7/10

---

**Week 11: Exit**

**Date**: 2026-02-01 (Earnings Day)

**Event**: Earnings released
- Revenue: Beat by 2%
- EPS: Beat by 5%
- Services: +16% growth ✓
- Guidance: In-line

**Market reaction**: Initial pop to $218, then fade to $205

**Decision** (2026-02-03):
- Price touched $205, then bounced
- Trail stop at $203 not hit
- **Thesis**: Still valid (services strong, earnings beat)
- **Technical**: Back at support, could be consolidation
- **Action**: Hold, but tighten trail to $205 (just below support)

**Date**: 2026-02-10

**Event**: Tech sector rotation
- Broader market weak
- AAPL drops to $202 in morning session
- **Trail stop hit @ $205**

**Exit Execution**:
- Time: 10:15 AM
- Fill: 66 shares @ $205.20 (trail triggered)
- Profit on final 1/3: $303

**File Created**: `positions/2025-11-18-AAPL/exit-log.md`

---

#### Quality Gate 4: Exit Verification

**Checks**:
1. ✓ Exit reason: Trail stop hit (systematic, not emotional)
2. ✓ Execution: At planned trail level
3. ✓ Not emotional override: Followed trail stop discipline
4. ✓ P&L calculated correctly (see below)

**Exit Quality**: Excellent (followed plan, trail stop worked as designed)

**PASS** ✓

---

#### Trade Summary

**P&L Calculation**:
```
Entry: 200 shares @ $200.62 avg = $40,124 cost

Exit 1: 67 shares @ $210.00 = $14,070 (1/3 position)
  Profit: $14,070 - $13,441.54 = $628.46 (+4.7%)

Exit 2: 67 shares @ $218.00 = $14,606 (1/3 position)
  Profit: $14,606 - $13,441.54 = $1,164.46 (+8.7%)

Exit 3: 66 shares @ $205.20 = $13,543.20 (1/3 position)
  Profit: $13,543.20 - $13,240.92 = $302.28 (+2.3%)

Total P&L: $628.46 + $1,164.46 + $302.28 = $2,095.20
Return: +5.2% over 12 weeks

Risk/Reward: Risked $1,000, made $2,095 = 2.1:1 (exceeded 2:1 target)
```

**Holding Period**: 12 weeks (within 6-12 week expected range)

---

#### Phase 6: Post-Mortem

**Date**: 2026-02-12

**Agent**: post-mortem-analyst

**Post-Mortem Analysis**:

```markdown
# Post-Mortem: AAPL

## Trade Summary
- **Entry**: 2025-11-18 @ $200.62
- **Exit**: 2026-02-10 (final 1/3) @ $205.20
- **Holding period**: 12 weeks
- **P&L**: +$2,095.20 (+5.2%)
- **R:R achieved**: 2.1:1

## Thesis Review

**Was thesis correct?**: Yes

**Core hypothesis validation**:
✓ Technical breakout sustained (held above $200 throughout)
✓ Services growth accelerated (16% vs 12-15% expected)
✓ AI narrative provided support (Vision Pro, AI features)

**Bull case (40% probability)**: Partially played out
- Services did accelerate (16% growth) ✓
- iPhone cycle modest, not spectacular
- Vision Pro sales better than expected ✓
- Reached $225 (vs $235 target) - close enough

**Base case (50% probability)**: This is what happened
- Steady iPhone demand ✓
- Services growth 16% (above base case expectations) ✓
- Reached $220 (base case target achieved) ✓

**Bear case (10% probability)**: Did not occur
- No major regulatory issues
- China stable (not worse)
- Tech sector rotation at end (minor headwind)

**Catalysts**:
✓ Earnings (Feb 1): Beat expectations, services strong
✓ Vision Pro: Better reception than expected
⏳ WWDC 2026 (June): Not reached (exited before)

## Process Review

**Did we follow APEX-OS?**: Yes, fully

✓ Opportunity scan: Documented trigger (breakout)
✓ Initial analysis: Both scores ≥5, proceeded
✓ Deep research: Thorough fundamental and technical
✓ Position planning: Size calculated correctly
✓ Entry execution: Within range, stop placed immediately
✓ Ongoing monitoring: Weekly updates maintained
✓ Exit execution: Followed trail stop discipline

**Quality gates passed?**: All gates passed
✓ Gate 1 (Thesis): 6/7 checks (noted sector concentration)
✓ Gate 2 (Execution): All checks passed
✓ Gate 3 (Monitoring): Weekly checks maintained
✓ Gate 4 (Exit): Trail stop exit (systematic)
✓ Gate 5 (Post-mortem): This document

**Adherence to principles**:
✓ Position sizing: 1% risk (reduced due to sector exposure)
✓ Stop loss: Placed immediately, never moved down
✓ Profit taking: Scale-out strategy executed perfectly
✓ Emotional discipline: No FOMO, no panic, stuck to plan
✓ Trail stop: Followed discipline, didn't get greedy

## What Worked

1. **Scale-out strategy**: Took 1/3 at +5%, 1/3 at +9%, trailed final 1/3
   - This locked in profits while still participating in upside
   - Final 1/3 caught move to $225 before exiting at $205
   - Avoided giving back all gains

2. **Thesis was solid**: Services growth thesis played out
   - Correctly identified accelerating services as catalyst
   - Fundamental analysis was accurate

3. **Technical entry**: Clean breakout provided clear entry
   - Support at $195 gave clear stop level
   - Pattern target of $218 achieved

4. **Risk management**: Reduced position size due to sector concentration
   - This prevented over-concentration in tech
   - Still made good return with lower risk

5. **Discipline**: Followed APEX-OS workflow completely
   - No emotional overrides
   - Stuck to plan through volatility
   - Trail stop prevented giving back gains

## What Didn't Work / Could Improve

1. **Sector concentration concern**: Tech exposure got to 58%
   - In hindsight, this was validated when tech rotated lower
   - **Lesson**: Should have been more aggressive about diversification
   - **Fix**: Set hard limit of 50% in any sector going forward

2. **Final trail stop**: Arguably could have been wider
   - Exited at $205 on sector rotation
   - Stock recovered to $210 within 2 weeks (missed +2% more)
   - **Counter-argument**: Can't predict this, trail stop worked as designed
   - **Lesson**: Trail stop worked—captured most of move (to $225), exited before major decline

3. **Could have taken more profit at $225**: Peak was $225, exited final 1/3 at $205
   - Left $1,320 on table (66 shares × $20) on final 1/3
   - **Counter-argument**: Impossible to sell at exact peak
   - **Lesson**: 15% trail gave room to breathe while protecting profits

4. **Timing relative to earnings**: Held through earnings (risk event)
   - Worked out (beat expectations)
   - But added uncertainty
   - **Lesson**: Consider taking more off before earnings, or tighter trail

## Luck vs Skill Assessment

**Category**: Skill-based win with some luck

**Skill components**:
- Thorough analysis (fundamental + technical)
- Good entry timing (clean breakout)
- Disciplined risk management (scale-out, trail stop)
- Following APEX-OS process prevented emotional errors

**Luck components**:
- Services growth 16% (better than expected, could have been 12%)
- Tech sector stayed strong for 10 weeks (could have rotated earlier)
- Earnings beat (could have missed)
- Vision Pro reception better than expected

**Assessment**: ~70% skill, 30% luck
- Process was excellent
- Analysis was sound
- Luck was in timing and magnitude of move

**Validation**: Would take this exact trade again with same setup

## Lessons Learned

1. **Scale-out strategy works**: Taking 1/3 at 2:1 and 1/3 at 3.6:1 while trailing final 1/3 is excellent
   - Locks in profits
   - Reduces stress
   - Still participates in big moves
   - **Action**: Continue this approach

2. **Trail stop discipline is crucial**: Without trail, might have given back all gains
   - Easy to get greedy at $225 and think "$250 is possible!"
   - Trail stop forced exit before major decline
   - **Action**: Always use trail on final 1/3, stick to % rule

3. **Sector concentration limits need enforcement**: 58% tech was too high
   - Exposed to sector rotation risk
   - **Action**: Hard limit of 50% in any sector going forward
   - **Update principle**: Add to portfolio-diversification.md

4. **Quality gate 1 warning was valid**: Flagged sector concentration concern
   - This was correct to reduce position size to 1%
   - Mitigated risk appropriately
   - **Action**: Trust quality gates, don't ignore warnings

5. **APEX-OS workflow prevents emotional errors**: Following process kept discipline
   - No FOMO at entry (waited for price)
   - No panic during consolidation
   - No greed at peak (trail stop)
   - No fear at end (systematic exit)
   - **Action**: Continue following workflow religiously

6. **Weekly monitoring is essential**: Caught approaching targets, adjusted trails
   - Without weekly check, might have missed profit-taking opportunities
   - **Action**: Never skip weekly monitoring

7. **Earnings are risk events**: Holding through added uncertainty
   - Worked this time, but coin flip
   - **Action**: Consider taking more off before earnings, or tighter trail

## Principle Updates

**Update `principles/risk-management/portfolio-diversification.md`**:

Add hard sector limit:
```markdown
## Sector Exposure Limits
- **Maximum per sector: 50% of portfolio** (was 25-30%, updating based on AAPL experience)
- Prevents sector rotation risk
- If at limit, must exit another position in sector before adding new
- Tech, healthcare, financials count as separate sectors
```

## Pattern Recognition

**Similar to past trades?**
- Similar to MSFT trade (2025-09): Tech breakout, scale-out strategy worked
- Similar to GOOGL trade (2025-08): Services growth thesis, profitable

**Pattern**: Tech breakouts with fundamental catalysts work well for this strategy
- **Repeat**: Look for more of these setups
- **Watch**: Sector concentration when multiple similar trades active

## Overall Assessment

**Grade**: A-

**Why**:
- Excellent process adherence (A+)
- Good entry and risk management (A)
- Successful execution of scale-out strategy (A)
- Strong return: +5.2% in 12 weeks = +22% annualized (A)
- Room for improvement: Sector concentration, trail stop width (hence A- not A)

**Would repeat**: Yes, with same setup and process

**Key takeaway**: APEX-OS workflow works. Discipline beats emotion.
```

**File Created**: `positions/2025-11-18-AAPL/post-mortem.md`

**Quality Gate 5: Post-Mortem** ✓ COMPLETE

---

### End of Example Trade

This complete workflow demonstrates:
- 6 phases from discovery to post-mortem
- 8 agents working together
- 16 principles applied automatically
- 5 quality gates preventing errors
- Complete documentation trail
- Disciplined execution
- Systematic learning

**Result**:
- +5.2% return in 12 weeks
- 2.1:1 risk/reward achieved
- Process followed perfectly
- Lessons extracted for future trades

---

## Implementation Guide

### Getting Started with APEX-OS

#### Week 1: Setup (2-3 hours)

**Day 1: Install Structure**
1. Clone or download APEX-OS to your system
2. Verify folder structure is complete
3. Verify `.claude/` integration works
4. Test a slash command: `/scan-opportunities`

**Day 2: Customize Principles**
1. Read all 16 principle files
2. Adjust thresholds to your risk tolerance:
   - Position sizing: 1-2% risk per trade
   - Stop loss: Maximum 8% from entry
   - R:R minimum: 2:1 or 3:1
3. Update portfolio strategy: `portfolio/portfolio-strategy.md`

**Day 3: Paper Trade Setup**
1. Pick a recent past trade you made
2. Run it through APEX-OS retroactively
3. Document each phase as if real-time
4. See if you would have done anything differently

#### Week 2: First Live Trade (4-6 hours)

**Phase 1: Find an Opportunity** (30 min)
- Run `/scan-opportunities`
- market-scanner identifies 3-5 opportunities
- Pick one that scores ≥5 on quick check

**Phase 2: Initial Analysis** (45 min)
- Run `/analyze-stock TICKER`
- fundamental-analyst and technical-analyst provide quick scores
- If both ≥5, proceed; if not, back to watchlist

**Phase 3: Deep Research** (2-3 hours)
- Complete fundamental analysis (follow principle files)
- Complete technical analysis (follow principle files)
- Run `/write-thesis`
- thesis-writer synthesizes into investment thesis

**Phase 4: Position Planning** (30 min)
- Run `/plan-position`
- risk-manager calculates size and risk parameters
- Quality Gate 1: Thesis verification (must pass 6/7 checks)

**Phase 5: Execution** (15 min + waiting)
- Run `/execute-entry`
- executor guides order placement
- Place stop loss immediately
- Quality Gate 2: Execution verification

**Phase 6: Monitor** (10 min/week)
- Weekly: portfolio-monitor checks thesis and levels
- Update: Document any significant events
- Adjust: Trail stops as position moves in your favor

**Phase 7: Exit** (when triggered)
- Stop hit, target hit, thesis violated, or time stop
- executor guides exit
- Document reason

**Phase 8: Post-Mortem** (1 hour)
- Within 1 week of exit
- Run `/review-trade`
- post-mortem-analyst guides review
- Extract lessons learned

#### Month 1: Build the Habit (10-15 trades)

**Goals**:
- Complete 10-15 trades using full APEX-OS workflow
- Pass all quality gates (no shortcuts)
- Build muscle memory for process
- Start seeing patterns

**Weekly Review**:
- Review all trades that week
- Check post-mortems for patterns
- Update principles if needed
- Adjust any thresholds

#### Quarter 1: Refine and Optimize (30-40 trades)

**Goals**:
- Identify your edge (what setups work best for you?)
- Update principles based on learnings
- Optimize position sizing (comfortable with risk?)
- Streamline workflow (know it by heart)

**Monthly Review**:
- Performance: Win rate, avg win/loss, R:R achieved
- Process: Quality gate pass rate, principle adherence
- Patterns: What's working? What's not?
- Updates: Principle refinements

#### Year 1: Mastery (100-150 trades)

**Goals**:
- APEX-OS is second nature
- Principles are internalized
- Can trade with confidence and discipline
- Track record demonstrating edge

**Quarterly Review**:
- Performance vs benchmarks
- Process improvements
- Major principle updates
- Strategic refinements

---

## Success Metrics

### Process Metrics (More Important Than Returns)

**Workflow Adherence**:
- Target: 100% of trades follow complete APEX-OS workflow
- Measure: % of trades with all phases documented
- Red flag: <90% (indicates shortcuts)

**Quality Gate Pass Rate**:
- Target: 100% pass rate (or documented exceptions)
- Measure: % of trades passing all 5 gates
- Red flag: <95% (indicates emotional overrides)

**Post-Mortem Completion**:
- Target: 100% of closed trades have post-mortem within 1 week
- Measure: % completion rate
- Red flag: <90% (indicates not learning)

**Principle Adherence**:
- Target: 100% trades follow investment principles
- Measure: Check against 16 principles per trade
- Red flag: <95% (indicates discipline issues)

### Performance Metrics (Results, but not the only measure)

**Risk-Adjusted Returns**:
- Measure: Return / risk taken
- Target: >2:1 average across all trades
- Industry: ~1.5:1 is good for active trading

**Win Rate**:
- Measure: % of trades that are profitable
- Target: >50% (but can be profitable with <50% if winners big enough)
- Note: Less important than R:R

**Average Win vs Average Loss**:
- Measure: $ of average win / $ of average loss
- Target: >2:1 (letting winners run, cutting losers fast)
- Red flag: <1.5:1 (taking profits too early, holding losers too long)

**Maximum Drawdown**:
- Measure: Largest peak-to-trough decline in portfolio
- Target: <10% (good risk management)
- Red flag: >20% (position sizing too large or correlated)

**Process vs Outcome**:
- Measure: % of trades categorized as "skill-based" vs "lucky"
- Target: >70% skill-based (in post-mortems)
- Red flag: <50% (relying on luck, not process)

### Learning Metrics (Long-term edge development)

**Mistake Repeat Rate**:
- Measure: Same mistake occurring 3+ times
- Target: 0 repeated mistakes (should be fixed after 2nd occurrence)
- Track in post-mortems

**Principle Updates**:
- Measure: # of principle refinements based on learnings
- Target: 2-4 updates per quarter (continuous improvement)
- Red flag: 0 updates (not adapting) or >10 (too much tinkering)

**Edge Identification**:
- Measure: Can you articulate your edge in 1-2 sentences?
- Target: Clear edge identified by Month 6
- Example: "I profit from technical breakouts in quality growth stocks"

### Monthly Dashboard Example

```markdown
# APEX-OS Performance Dashboard - January 2026

## Process Metrics (Grade: A)
- Workflow adherence: 100% (15/15 trades)
- Quality gates passed: 100% (no overrides)
- Post-mortems completed: 100% (15/15 within 1 week)
- Principle adherence: 98% (1 minor deviation documented)

## Performance Metrics (Grade: B+)
- Total return: +4.2% (vs S&P +2.1%)
- Risk-adjusted return: 2.8:1 average
- Win rate: 60% (9 wins, 6 losses)
- Average win: +6.8% / Average loss: -2.1% = 3.2:1
- Max drawdown: -3.5% (healthy)
- Process quality: 73% skill-based wins (strong)

## Learning Metrics (Grade: A-)
- Repeated mistakes: 0 (good)
- Principle updates: 1 (sector concentration limit)
- Edge identified: "Technical breakouts in tech/growth stocks with fundamental catalysts"
- Pattern: Best performance on 3:1+ R:R setups

## Action Items for Next Month
1. Increase target R:R from 2:1 to 3:1 minimum (better setups only)
2. Add more defensive plays (currently 80% growth stocks)
3. Continue perfect workflow adherence
```

---

## Benefits vs Traditional Trading

| Aspect | Traditional Trading | APEX-OS | Improvement |
|--------|-------------------|---------|-------------|
| **Consistency** | Random analysis quality | Every trade follows same process | 10x more consistent |
| **Documentation** | Mental notes, maybe journal | Complete paper trail | Infinite improvement |
| **Learning** | Rarely review trades | Mandatory post-mortem | 5x faster learning |
| **Risk Management** | Arbitrary position sizes | Mathematical position sizing | 3x better risk management |
| **Emotional Control** | Willpower-based | Structure-enforced | 5x better discipline |
| **Pattern Recognition** | Hard to identify | Complete history enables analysis | 10x better pattern ID |
| **Replicability** | Can't explain edge | Can teach process to others | Fully replicable |
| **Continuous Improvement** | Static approach | Principle updates from learnings | Always improving |
| **Time to Proficiency** | 3-5 years (if ever) | 6-12 months | 3-5x faster |
| **Confidence** | Fluctuates wildly | Built on process trust | Stable high |

---

## Conclusion

**APEX-OS transforms investing from gambling into engineering.**

Just as Agent OS structured software development, APEX-OS structures investment decisions. The result is:

- **Consistency**: Every trade follows identical workflow
- **Discipline**: Quality gates prevent emotional errors
- **Learning**: Post-mortems ensure continuous improvement
- **Confidence**: Trust in process, not outcomes
- **Edge**: Documented, testable, improvable

**The hypothesis**: Consistent, disciplined process → Better decisions → Higher risk-adjusted returns over time

**Success isn't measured by never losing** - it's measured by:
1. Following the process 100% of the time
2. Learning from every trade
3. Improving principles based on experience
4. Building an edge that compounds

**Start with process, returns will follow.**

---

## Quick Start Checklist

Before your first APEX-OS trade:

- [ ] Folder structure created
- [ ] Principles customized to your risk tolerance
- [ ] Portfolio strategy documented
- [ ] Ran one paper trade through complete workflow
- [ ] Tested all slash commands
- [ ] Understand all 16 principles
- [ ] Understand 5 quality gates
- [ ] Committed to following full workflow (no shortcuts)

**You're ready. Find your first opportunity and let APEX-OS guide you to disciplined trading.**

---

**Welcome to APEX-OS.**

*Structure. Discipline. Results.*
