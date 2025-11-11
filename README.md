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
curl -sSL https://raw.githubusercontent.com/yourusername/apex-os/main/scripts/base-install.sh | bash
```

This clones the APEX-OS repository to your home directory. You only need to do this once.

### Step 2: Set Up Your Trading Workspace

Create a directory for your trading work and install APEX-OS into it:

```bash
mkdir ~/my-trading && cd ~/my-trading
~/apex-os/scripts/project-install.sh
```

This will:
- Copy `.claude/` directory (8 agents, 6 commands, 16 skills)
- Copy `principles/` directory (16 investment principles)
- Copy `portfolio/` templates (configure for your needs)
- Create workflow directories (`opportunities/`, `analysis/`, `positions/`, `reports/`)
- Copy documentation files

### Step 3: Open in Claude Code

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

## Quick Start

Once installed, configure your portfolio and start trading:

### 1. Configure Your Portfolio

Edit `portfolio/portfolio-config.yaml`:
- Set your portfolio size
- Choose risk per trade (1-2%)
- Configure position limits
- Set your preferences

### 2. Run Your First Scan

```
/scan-market
```

This identifies 5-10 potential opportunities meeting your criteria.

### 3. Analyze a Stock

```
/analyze-stock AAPL
```

Runs parallel fundamental + technical analysis. Takes ~2 hours.

**Gate 1**: Only passes if Fundamental ≥6/10 AND Technical ≥7/10

### 4. Write Investment Thesis

```
/write-thesis AAPL
```

Synthesizes analysis into falsifiable thesis with bull/base/bear cases.

**Gate 1**: Only passes if thesis is falsifiable with clear exit criteria.

### 5. Plan Position

```
/plan-position AAPL
```

Calculates mathematical position sizing and validates all risk limits.

**Gate 2**: Only passes if all risk management rules met.

### 6. Execute Entry

```
/execute-entry AAPL
```

Guides order placement and REQUIRES stop loss placed immediately.

**Gate 3**: Only passes if stop confirmed active.

### 7. Monitor Daily

```
/monitor-portfolio
```

Tracks all positions, validates thesis, generates alerts.

Run every trading day.

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

**Agents in `.claude/agents/apex-os/`**

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
**Auto-loaded skills in `.claude/skills/`**

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

```
apex-os/
├── .claude/
│   ├── agents/apex-os/          # 8 specialized agent definitions
│   ├── commands/apex-os/         # 6 slash command workflows
│   └── skills/                   # 16 auto-loaded skills
├── principles/                    # 16 investment principles
│   ├── fundamental/              # 5 fundamental principles
│   ├── technical/                # 4 technical principles
│   ├── risk-management/          # 4 risk management principles
│   └── behavioral/               # 3 behavioral principles
├── portfolio/                     # Portfolio tracking
│   ├── portfolio-config.yaml     # Your settings
│   └── open-positions.yaml       # Active positions
├── opportunities/                 # Market scans
├── analysis/                      # Stock analysis
│   └── YYYY-MM-DD-TICKER/        # Per-stock analysis folder
│       ├── fundamental-report.md
│       ├── technical-report.md
│       ├── investment-thesis.md
│       └── position-plan.md
├── positions/                     # Trade execution
│   └── YYYY-MM-DD-TICKER/        # Per-trade folder
│       ├── entry-log.md
│       ├── exit-log.md
│       ├── post-mortem.md
│       └── alert-YYYY-MM-DD.md
├── reports/                       # Monitoring & reviews
│   ├── daily-monitor-YYYY-MM-DD.md
│   └── monthly-review-YYYY-MM.md
└── README.md                      # This file
```

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
- Read agent definitions in `.claude/agents/apex-os/`
- Read principles in `principles/`
- Read command workflows in `.claude/commands/apex-os/`
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
