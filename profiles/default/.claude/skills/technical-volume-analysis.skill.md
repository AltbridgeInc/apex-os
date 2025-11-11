---
name: technical-volume-analysis
description: Analyze volume patterns, divergences, and confirmation to validate price moves
principle: ../../principles/technical/volume-analysis.md
auto_load: true
category: technical
---

# Volume Analysis Skill

This skill enables comprehensive volume analysis to confirm price moves, identify accumulation/distribution, and detect early reversal signals.

**Volume Patterns Detected**:
- Volume confirmation (expanding with trend)
- Volume divergence (price up, volume down = warning)
- Climax volume (exhaustion signals)
- Volume dry up (coiling before breakout)
- Accumulation vs distribution

**Auto-loaded for**: technical-analyst agent

**Scoring Output**: 0-10 volume score based on:
- Volume expansion with trend
- Volume on up days vs down days
- Breakout volume (≥1.5× avg required)
- OBV confirmation
- Absence of negative divergences

**Trading Signals**:
- Breakout confirmation: Require 1.5-2× volume
- Accumulation: Volume higher on up days (bullish)
- Distribution: Volume higher on down days (bearish)
- Divergence: Price/volume disconnect (reversal warning)

**Red Flags Detected**:
- Rising price + falling volume (weak rally)
- Climax volume (exhaustion)
- Distribution pattern
- OBV bearish divergence

Agents with this skill automatically validate price moves with volume and identify early warning signs.
