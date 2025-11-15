#!/bin/bash
# Populate all 16 APEX-OS skills with content

SKILLS_DIR="profiles/default/skills"

# Function to create skill content
create_skill() {
    local SKILL_NAME=$1
    local DESCRIPTION=$2
    local SKILL_DIR="$SKILLS_DIR/$SKILL_NAME"

    # Create SKILL.md with basic content structure
    cat > "$SKILL_DIR/SKILL.md" << EOF
---
name: $SKILL_NAME
description: $DESCRIPTION
---

# $(echo $SKILL_NAME | sed 's/-/ /g' | sed 's/\b\(.\)/\u\1/g')

## Overview

$DESCRIPTION

## Application Guidelines

Apply this skill when analyzing stocks for fundamental analysis, technical analysis, risk management, or behavioral considerations.

## Key Metrics and Frameworks

Refer to bundled references for detailed frameworks, metrics, and evaluation criteria.

## Output Format

Provide analysis with clear scoring, supporting data, and actionable insights.
EOF

    # Remove example files
    rm -f "$SKILL_DIR/scripts/example.py"
    rm -f "$SKILL_DIR/references/api_reference.md"
    rm -f "$SKILL_DIR/assets/example_asset.txt"

    echo "✓ Created $SKILL_NAME"
}

echo "Populating all APEX-OS skills..."
echo ""

# Technical Analysis Skills
create_skill "price-action-analysis" "Analyze price patterns, candlestick formations, support/resistance levels, and chart patterns to identify trading opportunities and market sentiment."
create_skill "volume-analysis" "Evaluate volume patterns, volume confirmation signals, and volume-price relationships to validate price movements and identify accumulation/distribution."
create_skill "momentum-analysis" "Assess price momentum using indicators like RSI, MACD, and momentum oscillators to identify overbought/oversold conditions and trend strength."
create_skill "trend-analysis" "Identify trend direction, strength, and sustainability using trend lines, moving averages, and trend indicators to determine market phase."

# Risk Management Skills
create_skill "position-sizing" "Calculate optimal position sizes based on account risk, stop-loss distance, and position limits to manage capital allocation effectively."
create_skill "stop-loss-management" "Determine stop-loss placement using technical levels, ATR-based stops, and trailing stops to protect capital and manage risk."
create_skill "portfolio-risk-assessment" "Evaluate portfolio diversification, correlation, sector exposure, and overall portfolio risk to maintain balanced risk profile."
create_skill "risk-reward-evaluation" "Calculate risk-reward ratios, assess trade setups, and evaluate potential returns versus downside risk for position planning."

# Behavioral Analysis Skills
create_skill "market-sentiment-analysis" "Assess market sentiment through sentiment indicators, news analysis, and market breadth to identify extremes and contrarian opportunities."
create_skill "bias-detection" "Identify cognitive biases such as confirmation bias, anchoring, recency bias, and overconfidence that may affect investment decisions."
create_skill "discipline-enforcement" "Enforce trading discipline through rule compliance, emotional awareness, and systematic decision-making to avoid impulsive actions."

echo ""
echo "✓ Populated all 11 remaining skills"
echo ""
echo "Total: 16 skills initialized and populated"
echo ""
echo "Validate with: python3 scripts/skill-tools/quick_validate.py profiles/default/skills/<skill-name>"
