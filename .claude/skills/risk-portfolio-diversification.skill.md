---
name: risk-portfolio-diversification
description: Maintain optimal diversification with 8-12 positions across sectors while managing correlation
principle: ../../principles/risk-management/portfolio-diversification.md
auto_load: true
category: risk-management
---

# Portfolio Diversification Skill

This skill enables construction and maintenance of adequately diversified portfolio that reduces risk without diluting returns.

**Position Count Guidelines**:
- Minimum: 5 positions
- Target: 8-10 positions (sweet spot)
- Maximum: 15 positions

**Position Size Limits**:
- Target: 8-12% per position
- Maximum: 15% per position
- Minimum: 3-5% per position (smaller not worth tracking)

**Auto-loaded for**: risk-manager, portfolio-monitor agents

**Sector Concentration**:
- Maximum: 50% in any sector
- Preferred: 25-35% per sector
- Monitor correlation within sectors

**Portfolio Heat Management**:
- Maximum total risk: 8% of portfolio
- Target: 5-6% typical exposure
- Conservative: 3-4% in uncertain markets

**Cash Reserve Requirements**:
- Minimum: 20% cash always
- Bull market: 15-20% cash
- Normal market: 20-30% cash
- Uncertain/Bear: 30-80% cash

**Rebalancing Triggers**:
- Position exceeds 15% → Trim to 12%
- Sector exceeds 50% → Reduce exposure
- Portfolio heat exceeds 8% → Exit position or reduce sizes
- Cash below 15% → Take profits, build reserves

Agents with this skill automatically ensure portfolio maintains appropriate diversification while preventing over-concentration.
