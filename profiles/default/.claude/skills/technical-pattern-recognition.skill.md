---
name: technical-pattern-recognition
description: Recognize chart patterns (flags, triangles, H&S, cups) with measured move targets
principle: ../../principles/technical/pattern-recognition.md
auto_load: true
category: technical
---

# Chart Pattern Recognition Skill

This skill enables identification and quality assessment of chart patterns that precede predictable price moves, with calculated measured move targets.

**Patterns Recognized**:
- Continuation: Flags, pennants, triangles, cup & handle, wedges
- Reversal: Head & shoulders, double tops/bottoms, rounding patterns
- Candlestick: Hammers, shooting stars, engulfing, doji

**Auto-loaded for**: technical-analyst agent

**Scoring Output**: 0-10 pattern score based on:
- Formation quality (textbook vs poor)
- Volume confirmation
- Context appropriateness
- Multiple timeframe visibility
- Completion status

**Measured Moves Calculated**:
- Flags: Add pole height
- Triangles: Add pattern height
- Cup & Handle: Add cup depth
- H&S: Subtract head height

**Risk Management**:
- Pattern failure identified
- Breakout volume requirements (1.5× minimum)
- False breakout detection

Agents with this skill automatically identify high-probability setups with defined targets and failure points.
