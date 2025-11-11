# Contributing to APEX-OS

Thank you for your interest in contributing to APEX-OS! This document provides guidelines for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Contribution Guidelines](#contribution-guidelines)
- [Pull Request Process](#pull-request-process)
- [Style Guidelines](#style-guidelines)

## Code of Conduct

This project adheres to a Code of Conduct. By participating, you are expected to uphold this code. Please read [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) before contributing.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When creating a bug report, include:

- **Clear title and description**
- **Steps to reproduce** the issue
- **Expected vs actual behavior**
- **APEX-OS version** you're using
- **Environment details** (OS, Claude Code version, etc.)
- **Relevant log files** or error messages

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion:

- **Use a clear and descriptive title**
- **Provide detailed description** of the proposed feature
- **Explain why this enhancement would be useful**
- **Include examples** of how it would work
- **Consider the philosophy** - Does it align with systematic, disciplined trading?

### Contributing Code

#### Areas for Contribution

1. **New Agents**: Additional specialized agents for specific trading strategies
2. **New Principles**: Investment principles for different markets or strategies
3. **New Profiles**: Trading profiles (day trading, options, long-term, etc.)
4. **Improved Analysis**: Better fundamental or technical analysis methods
5. **Documentation**: Improvements to guides, examples, tutorials
6. **Bug Fixes**: Fixes for issues in existing code
7. **Testing**: Unit tests, integration tests, backtesting
8. **Integrations**: Broker APIs, data providers, analytics tools

## Development Setup

### Prerequisites

- Git installed
- Claude Code
- Basic understanding of trading concepts
- Familiarity with Agent OS principles

### Setup Steps

1. **Fork the repository**
   ```bash
   # Fork on GitHub, then clone your fork
   git clone https://github.com/YOUR_USERNAME/apex-os.git
   cd apex-os
   ```

2. **Create a development branch**
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/your-bug-fix
   ```

3. **Make your changes**
   - Edit files in `profiles/default/` for framework changes
   - Edit scripts in `scripts/` for installation changes
   - Update documentation in `README.md` or `apex-os_description.md`

4. **Test your changes**
   - Install locally: `./scripts/project-install.sh`
   - Test all affected workflows
   - Verify agents work as expected
   - Check documentation accuracy

## Contribution Guidelines

### Agent Development

When creating or modifying agents:

- **Single Responsibility**: Each agent should have ONE clear purpose
- **Consistent Format**: Follow existing agent structure
- **Quality Gates**: Agents should enforce quality gates, not bypass them
- **Objective Analysis**: Agents must provide both bull AND bear cases
- **Documentation**: Include clear instructions in agent definition
- **Color Coding**: Assign unique color for agent identification

**Agent Template**:
```markdown
name: your-agent-name
color: blue  # Choose unique color
description: |
  One-line description of agent purpose

instructions: |
  ## Purpose
  Detailed purpose explanation

  ## Responsibilities
  - Specific task 1
  - Specific task 2

  ## Quality Standards
  - Standard 1
  - Standard 2

  ## Output Format
  Specific output requirements

  ## Constraints
  - What agent MUST do
  - What agent MUST NOT do
```

### Principle Development

When creating or modifying principles:

- **Evidence-Based**: Principles should be based on research or proven strategies
- **Actionable**: Must provide specific, actionable guidance
- **Formulas Included**: Include mathematical formulas where applicable
- **Examples Provided**: Include real examples
- **References**: Cite sources for strategies

**Principle Template**:
```markdown
# Principle Name

## Core Concept
Clear explanation of the principle

## Why It Matters
Importance and impact

## How to Apply
Step-by-step application

## Examples
Real-world examples with numbers

## Common Mistakes
What to avoid

## Formulas
Mathematical formulas if applicable

## References
Sources and further reading
```

### Skills Development

Skills auto-compile from principles. When adding skills:

- **One-to-One Mapping**: Each skill maps to one principle
- **Clear Trigger**: Define when skill should be loaded
- **Consistent Naming**: Match principle file name

### Documentation

When updating documentation:

- **Clear and Concise**: Use simple language
- **Examples**: Provide code examples
- **Accurate**: Verify all information
- **Organized**: Use headers, lists, and formatting
- **Beginner-Friendly**: Assume reader is new to APEX-OS

## Pull Request Process

### Before Submitting

1. **Test thoroughly** in a real workspace
2. **Update documentation** if you changed functionality
3. **Follow style guidelines** (see below)
4. **Write clear commit messages**
5. **Squash commits** if you have many small commits

### PR Description Template

```markdown
## Description
Brief description of changes

## Motivation
Why is this change needed?

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Performance improvement
- [ ] Code refactoring

## Testing
How was this tested?

## Checklist
- [ ] Code follows style guidelines
- [ ] Documentation updated
- [ ] Tested in real workspace
- [ ] No breaking changes (or documented)
- [ ] Commit messages are clear
```

### Review Process

1. **Automatic checks** will run (if configured)
2. **Maintainers will review** within 7 days
3. **Feedback addressed** - Make requested changes
4. **Approval** - Once approved, PR will be merged
5. **Thank you!** - Your contribution is appreciated

## Style Guidelines

### Markdown Style

- Use ATX-style headers (`#` not underlines)
- Use fenced code blocks with language specification
- Use bullet lists for unordered items
- Use numbered lists for sequential steps
- Keep line length reasonable (<100 chars when possible)

### YAML Style

- Use 2-space indentation
- Use lowercase with hyphens for keys
- Include comments for complex sections
- Validate YAML syntax before committing

### Bash Script Style

- Use `#!/bin/bash` shebang
- Use `set -e` for error handling
- Comment complex sections
- Use meaningful variable names
- Quote variables: `"$VAR"` not `$VAR`
- Validate with shellcheck if possible

### Agent Instructions Style

- Use clear section headers
- Use bullet points for lists
- Use **bold** for emphasis on critical items
- Use `code` for specific values or commands
- Include examples where helpful

### Commit Message Style

Follow conventional commits:

```
type(scope): brief description

Longer explanation if needed

- Bullet points for details
- Multiple changes listed

Fixes #123
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Formatting changes
- `refactor`: Code restructuring
- `test`: Adding tests
- `chore`: Maintenance tasks

**Examples**:
```
feat(agents): add options-analyst agent for options trading

docs(readme): update installation instructions for Windows

fix(risk-manager): correct position sizing formula for stocks under $10
```

## Philosophy Alignment

All contributions should align with APEX-OS philosophy:

1. **Process Over Outcome**: Focus on systematic process, not quick wins
2. **Risk Management First**: Never compromise on risk management
3. **Falsifiable Theses**: Support evidence-based, falsifiable approaches
4. **Emotional Discipline**: Enforce systematic execution over emotions
5. **Continuous Learning**: Enable learning through documentation

### What We Want

- Features that enforce discipline
- Tools that improve systematic execution
- Documentation that educates
- Risk management enhancements
- Learning and improvement features

### What We Don't Want

- "Get rich quick" features
- Bypasses for quality gates
- Encouraging overleveraging
- Promoting emotional trading
- Unproven "secret strategies"

## Questions?

- **Open an issue** for questions about contributing
- **Check existing issues** for similar questions
- **Read the docs** - README.md and apex-os_description.md
- **Be patient** - Maintainers are volunteers

## Recognition

Contributors will be:
- Listed in CHANGELOG.md for their contributions
- Credited in release notes
- Recognized in the community

Thank you for helping make APEX-OS better!

---

**Remember**: APEX-OS exists to prevent trading losses through systematic discipline. Every contribution should support this mission.
