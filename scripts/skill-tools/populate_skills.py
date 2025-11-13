#!/usr/bin/env python3
"""
Populate APEX-OS skills with content from principles
"""

import sys
from pathlib import Path

# Skill definitions with content
SKILLS = {
    'financial-health-analysis': {
        'description': 'Assess company financial health through revenue, profitability, cash flow, and balance sheet strength. Use when analyzing company fundamentals or evaluating investment opportunities.',
        'content': '''# Financial Health Analysis

## Overview

Assess company financial health through systematic analysis of revenue trends, profitability metrics, cash flow generation, and balance sheet strength to determine investment quality and risk.

## Core Analysis Framework

### 1. Revenue Analysis
- Calculate revenue growth rate (YoY over 3-5 years)
- Assess revenue consistency and predictability
- Evaluate revenue quality (recurring vs one-time)
- Identify cyclicality and economic sensitivity

### 2. Profitability Metrics
- Calculate gross margin: (Revenue - COGS) / Revenue
- Calculate operating margin: Operating Income / Revenue
- Calculate net margin: Net Income / Revenue
- Analyze margin trends (expanding, stable, contracting)

### 3. Cash Flow Evaluation
- Calculate operating cash flow (OCF)
- Calculate free cash flow (FCF): OCF - Capital Expenditures
- Assess cash conversion: FCF / Net Income (target >1)
- Calculate FCF yield: FCF / Market Cap

### 4. Balance Sheet Strength
- Calculate debt-to-equity ratio: Total Debt / Shareholders' Equity
- Calculate current ratio: Current Assets / Current Liabilities
- Calculate interest coverage: EBIT / Interest Expense
- Assess cash position and liquidity

## Scoring Guidelines

**Score 9-10 (Excellent):**
- Revenue growing >15% YoY consistently
- Expanding margins across all levels
- Strong FCF with >100% cash conversion
- Fortress balance sheet (low debt, high cash)

**Score 7-8 (Strong):**
- Revenue growing 10-15% YoY
- Stable to improving margins
- Positive and growing FCF
- Healthy balance sheet

**Score 5-6 (Average):**
- Revenue growing 5-10% YoY
- Stable margins
- Positive but inconsistent FCF
- Manageable debt levels

**Score 3-4 (Weak):**
- Revenue growing <5% or declining
- Contracting margins
- Inconsistent or negative FCF
- High debt levels

**Score 0-2 (Poor):**
- Revenue declining consistently
- Negative or severely contracting margins
- Burning cash (negative FCF)
- Dangerous debt levels

## Red Flags

Identify and flag:
- Accounting quality issues (revenue recognition games, frequent restatements)
- Deteriorating margins (gross or operating compression)
- Cash flow divergence (net income up but FCF down)
- Debt spiral (debt increasing faster than revenue/assets)
- Working capital issues (receivables/inventory ballooning)

## Output Format

Provide financial health score (0-10) with supporting metrics and rationale. Reference detailed principles in `references/financial-health-principles.md` for comprehensive evaluation criteria.
'''
    },

    'valuation-analysis': {
        'description': 'Evaluate company valuation using multiple methods including P/E, P/S, EV/EBITDA, DCF analysis. Use when determining if a stock is fairly valued, undervalued, or overvalued.',
        'content': '''# Valuation Analysis

## Overview

Evaluate company valuation using multiple methods to determine fair value and identify undervalued or overvalued investment opportunities.

## Valuation Methods

### 1. Relative Valuation (Multiples)
- Calculate P/E ratio: Price / Earnings Per Share
- Calculate P/S ratio: Price / Sales Per Share
- Calculate EV/EBITDA: Enterprise Value / EBITDA
- Calculate P/B ratio: Price / Book Value Per Share
- Compare to industry peers and historical averages

### 2. Discounted Cash Flow (DCF)
- Project free cash flows (5-10 years)
- Determine appropriate discount rate (WACC)
- Calculate terminal value
- Discount all cash flows to present value
- Compare intrinsic value to current price

### 3. PEG Ratio Analysis
- Calculate PEG: P/E / Growth Rate
- Interpret: <1 potentially undervalued, >1 potentially overvalued
- Compare to industry benchmarks

## Valuation Scoring

**Score 9-10 (Deep Value):**
- Trading at >50% discount to intrinsic value
- P/E significantly below historical/peer average
- Strong margin of safety

**Score 7-8 (Attractive):**
- Trading at 30-50% discount to intrinsic value
- P/E moderately below average
- Reasonable margin of safety

**Score 5-6 (Fair Value):**
- Trading near intrinsic value
- P/E in line with historical/peer average
- Limited margin of safety

**Score 3-4 (Expensive):**
- Trading at 20-40% premium to intrinsic value
- P/E above average
- No margin of safety

**Score 0-2 (Severely Overvalued):**
- Trading at >40% premium to intrinsic value
- P/E significantly inflated
- High downside risk

## Output Format

Provide valuation score (0-10) with intrinsic value estimate, current valuation multiples, and margin of safety calculation.
'''
    },

    'growth-analysis': {
        'description': 'Evaluate company growth potential through revenue trends, market opportunity, competitive position, and growth drivers. Use when assessing growth stocks or expansion potential.',
        'content': '''# Growth Analysis

## Overview

Evaluate company growth potential through revenue trends, market opportunity, competitive dynamics, and sustainable growth drivers.

## Growth Evaluation Framework

### 1. Historical Growth
- Analyze revenue CAGR (3, 5, 10 years)
- Analyze earnings CAGR
- Assess customer/user growth rates
- Identify growth consistency vs volatility

### 2. Market Opportunity
- Calculate Total Addressable Market (TAM)
- Estimate current market penetration
- Identify addressable expansion opportunities
- Assess market growth rate

### 3. Growth Drivers
- Evaluate organic growth initiatives
- Assess new product/service pipeline
- Analyze geographic expansion potential
- Consider M&A opportunities
- Examine pricing power potential

### 4. Sustainable Competitive Advantages
- Network effects strength
- Brand value and recognition
- Technology/IP advantages
- Economies of scale
- Switching costs

## Growth Scoring

**Score 9-10 (Hypergrowth):**
- Revenue growing >40% YoY sustainably
- Large TAM with low penetration
- Multiple strong growth drivers
- Durable competitive advantages

**Score 7-8 (Strong Growth):**
- Revenue growing 20-40% YoY
- Sizable TAM with moderate penetration
- Clear growth catalysts
- Defensible market position

**Score 5-6 (Moderate Growth):**
- Revenue growing 10-20% YoY
- Limited TAM or high penetration
- Some growth opportunities
- Competitive position maintained

**Score 3-4 (Slow Growth):**
- Revenue growing 0-10% YoY
- Mature/saturated market
- Few growth catalysts
- Eroding competitive position

**Score 0-2 (Declining):**
- Revenue declining
- Shrinking market or share loss
- No visible growth drivers
- Competitive disadvantages

## Output Format

Provide growth score (0-10) with revenue projections, TAM analysis, and assessment of key growth drivers and risks.
'''
    },
# Continuing with remaining skills...

    'quality-analysis': {
        'description': 'Assess business quality through management effectiveness, competitive advantages, operational excellence, and corporate governance. Use when evaluating long-term investment quality.',
        'content': '''# Quality Analysis

## Overview

Assess business quality through management effectiveness, competitive positioning, operational excellence, and governance standards.

## Quality Evaluation Framework

### 1. Management Quality
- Track record of capital allocation
- Insider ownership and alignment
- Communication transparency
- Strategic vision and execution
- Industry expertise

### 2. Competitive Advantages
- Brand strength and moats
- Patents and intellectual property
- Regulatory barriers
- Network effects
- Cost advantages

### 3. Operational Excellence
- Return on invested capital (ROIC)
- Return on equity (ROE)
- Asset turnover efficiency
- Operating leverage
- Quality of earnings

### 4. Corporate Governance
- Board independence and expertise
- Executive compensation alignment
- Shareholder rights
- Accounting transparency
- ESG considerations

## Quality Scoring

**Score 9-10 (Exceptional Quality):**
- World-class management team
- Multiple durable moats
- Consistently high ROIC (>20%)
- Best-in-class governance

**Score 7-8 (High Quality):**
- Strong management track record
- Clear competitive advantages
- ROIC 15-20%
- Solid governance practices

**Score 5-6 (Average Quality):**
- Competent management
- Some competitive advantages
- ROIC 10-15%
- Standard governance

**Score 3-4 (Below Average):**
- Questionable management decisions
- Weak competitive position
- ROIC <10%
- Governance concerns

**Score 0-2 (Poor Quality):**
- Ineffective management
- No sustainable advantages
- Value destruction (ROIC < WACC)
- Governance red flags

## Output Format

Provide quality score (0-10) with assessment of management, moats, ROIC trends, and governance evaluation.
'''
    },

    'moat-analysis': {
        'description': 'Identify and evaluate sustainable competitive advantages (moats) that protect long-term profitability. Use when assessing defensibility of business model and competitive position.',
        'content': '''# Moat Analysis

## Overview

Identify and evaluate sustainable competitive advantages that create barriers to entry and protect long-term economic returns.

## Types of Moats

### 1. Network Effects
- Value increases with each additional user
- High switching costs due to network lock-in
- Examples: Social platforms, marketplaces, payment networks
- Assessment: Measure active users, engagement, network density

### 2. Intangible Assets
- Brand recognition and customer loyalty
- Patents and proprietary technology
- Regulatory licenses and approvals
- Assessment: Brand value metrics, patent portfolio strength

### 3. Cost Advantages
- Economies of scale
- Proprietary process technology
- Favorable access to resources
- Geographic advantages
- Assessment: Unit cost comparison to competitors

### 4. Switching Costs
- High customer switching costs (time, money, risk)
- Integration complexity
- Data/workflow dependency
- Assessment: Customer retention rates, lifetime value

### 5. Efficient Scale
- Market naturally supports limited competitors
- Duopoly or oligopoly dynamics
- High fixed costs creating barriers
- Assessment: Market concentration, competitor profitability

## Moat Width Assessment

**Score 9-10 (Wide Moat):**
- Multiple strong moats working together
- Decades of sustainable advantage
- Pricing power and market leadership
- Competitors struggle to gain share

**Score 7-8 (Moat):**
- At least one strong moat
- 10+ years of sustainable advantage
- Defensible market position
- Healthy competitive dynamics

**Score 5-6 (Narrow Moat):**
- Limited competitive advantages
- 5-10 years of advantage
- Moderate competitive pressure
- Some pricing power

**Score 3-4 (No Moat):**
- Minimal barriers to entry
- Commoditized offering
- Intense competition
- Price-taker dynamics

**Score 0-2 (Negative Moat):**
- Structural disadvantages
- Obsolete business model
- Losing competitive position
- Margin compression inevitable

## Output Format

Provide moat score (0-10) with identification of specific moat types, durability assessment, and competitive positioning analysis.
'''
    },
}

def populate_skill(skill_dir, skill_name, description, content):
    """Populate a skill with proper content"""
    skill_path = Path(skill_dir) / skill_name
    skill_md = skill_path / 'SKILL.md'

    # Create SKILL.md content
    skill_content = f'''---
name: {skill_name}
description: {description}
---

{content}
'''

    # Write SKILL.md
    skill_md.write_text(skill_content)
    print(f"✓ Populated {skill_name}/SKILL.md")

    # Clean up example files (keep directories)
    (skill_path / 'scripts' / 'example.py').unlink(missing_ok=True)
    (skill_path / 'references' / 'api_reference.md').unlink(missing_ok=True)
    (skill_path / 'assets' / 'example_asset.txt').unlink(missing_ok=True)

    return True

def main():
    skill_dir = Path('profiles/default/skills')

    print("Populating APEX-OS skills with content...")
    print()

    for skill_name, skill_data in SKILLS.items():
        if populate_skill(skill_dir, skill_name, skill_data['description'], skill_data['content']):
            pass

    print()
    print(f"✓ Populated {len(SKILLS)} skills")
    print()
    print("Run validation:")
    print(f"  python3 scripts/skill-tools/quick_validate.py profiles/default/skills/<skill-name>")

if __name__ == "__main__":
    main()
