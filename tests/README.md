# FMP API Integration - Test Suite

Comprehensive test suite for the Financial Modeling Prep (FMP) API integration in APEX-OS.

## Overview

This test suite validates the FMP API integration across all components:
- Helper scripts (fmp-*.sh)
- Agent integrations (4 agents)
- Complete workflows (scan to monitoring)
- Error handling
- Performance benchmarks

## Test Structure

```
tests/
├── README.md                          # This file
├── test-helpers.sh                    # Shared test functions
├── unit/
│   └── test-fmp-scripts.sh           # Unit tests for helper scripts
├── integration/
│   └── test-agents.sh                # Integration tests for agents
├── e2e/
│   └── test-complete-workflow.sh     # End-to-end workflow tests
├── error/
│   └── test-error-scenarios.sh       # Error handling tests
└── performance/
    └── benchmark-fmp.sh              # Performance benchmarks
```

## Prerequisites

### Required

1. **Bash 4.0+** - All tests are written in Bash
2. **jq** - JSON parsing and validation
   ```bash
   # Install on macOS
   brew install jq

   # Install on Linux
   sudo apt-get install jq
   ```

### Optional (for real API tests)

3. **FMP API Key** - Configure in `.env` file at project root
   ```bash
   echo "FMP_API_KEY=your_api_key_here" > /Users/nazymazimbayev/apex-os-1/.env
   ```

### Optional (for portfolio tests)

4. **yq** - YAML parsing (for portfolio integration tests)
   ```bash
   # Install on macOS
   brew install yq
   ```

## Running Tests

### Quick Start - Run All Tests

```bash
# Make all test scripts executable
chmod +x /Users/nazymazimbayev/apex-os-1/tests/**/*.sh

# Run all tests
bash /Users/nazymazimbayev/apex-os-1/tests/unit/test-fmp-scripts.sh
bash /Users/nazymazimbayev/apex-os-1/tests/integration/test-agents.sh
bash /Users/nazymazimbayev/apex-os-1/tests/e2e/test-complete-workflow.sh
bash /Users/nazymazimbayev/apex-os-1/tests/error/test-error-scenarios.sh
bash /Users/nazymazimbayev/apex-os-1/tests/performance/benchmark-fmp.sh
```

### Run Individual Test Suites

#### 1. Unit Tests (Helper Scripts)

Tests each helper script individually with various inputs.

```bash
bash /Users/nazymazimbayev/apex-os-1/tests/unit/test-fmp-scripts.sh
```

**Coverage**:
- fmp-common.sh (API key loading, validation, error formatting)
- fmp-quote.sh (single/batch quotes, invalid symbols)
- fmp-financials.sh (income/balance/cashflow statements)
- fmp-ratios.sh (ratios, metrics, growth)
- fmp-profile.sh (company profiles)
- fmp-historical.sh (daily/intraday historical data)
- fmp-screener.sh (gainers/losers/custom filters)
- fmp-indicators.sh (SMA, RSI, etc.)

**Time**: ~2-3 minutes (with API key)

#### 2. Integration Tests (Agents)

Tests agent integration with FMP scripts.

```bash
bash /Users/nazymazimbayev/apex-os-1/tests/integration/test-agents.sh
```

**Coverage**:
- Market Scanner agent configuration and workflow
- Fundamental Analyst agent configuration and workflow
- Technical Analyst agent configuration and workflow
- Portfolio Monitor agent configuration and workflow
- Cross-agent data consistency

**Time**: ~3-4 minutes (with API key)

#### 3. End-to-End Workflow Tests

Tests complete investment workflow from scan to monitoring.

```bash
bash /Users/nazymazimbayev/apex-os-1/tests/e2e/test-complete-workflow.sh
```

**Workflow Steps**:
1. Market Scanner identifies opportunities
2. Fundamental Analyst analyzes opportunity
3. Technical Analyst analyzes opportunity
4. Position added to portfolio
5. Portfolio Monitor tracks position
6. Verify FMP data in all reports
7. Verify workflow integrity

**Time**: ~4-5 minutes (with API key)

#### 4. Error Scenario Tests

Tests error handling across all components.

```bash
bash /Users/nazymazimbayev/apex-os-1/tests/error/test-error-scenarios.sh
```

**Error Scenarios**:
- Invalid symbols
- Missing/empty API key
- Malformed JSON responses
- Rate limit handling
- Missing parameters
- Invalid parameter types
- Empty responses
- Network timeouts
- Error message quality

**Time**: ~2-3 minutes (with API key)

#### 5. Performance Benchmarks

Tests performance benchmarks and API efficiency.

```bash
bash /Users/nazymazimbayev/apex-os-1/tests/performance/benchmark-fmp.sh
```

**Benchmarks**:
- Market Scanner: < 3 minutes, < 20 API calls
- Fundamental Analyst: < 2 minutes, < 15 API calls
- Technical Analyst: < 2 minutes, < 10 API calls
- Portfolio Monitor: < 1 minute, < 5 API calls
- Rate limit compliance (250 calls/min)
- Concurrent API call handling

**Time**: ~5-6 minutes (with API key)

## Test Modes

### 1. Mock Mode (No API Key)

Tests run with mock data and validation checks. API-dependent tests are skipped.

```bash
# Remove or rename .env to run in mock mode
mv .env .env.backup

# Run tests
bash /Users/nazymazimbayev/apex-os-1/tests/unit/test-fmp-scripts.sh
```

**What's tested**:
- Script existence and configuration
- Error handling for missing API key
- JSON format validation
- Parameter validation
- Agent configuration

**What's skipped**:
- Real API calls
- Data quality validation
- Performance benchmarks

### 2. Real API Mode (With API Key)

Tests run with real FMP API calls.

```bash
# Ensure .env has FMP_API_KEY
echo "FMP_API_KEY=your_key" > .env

# Run tests
bash /Users/nazymazimbayev/apex-os-1/tests/unit/test-fmp-scripts.sh
```

**Note**: Real API mode will consume API calls from your quota. Use responsibly.

## Understanding Test Output

### Test Status Indicators

- `✓` (Green) - Test passed
- `✗` (Red) - Test failed
- `○` (Yellow) - Test skipped (usually due to missing API key)

### Example Output

```
========================================
Test Suite: FMP Helper Scripts Unit Tests
========================================

  ✓ fmp-common.sh: load_api_key() with valid .env: load_api_key should succeed with valid .env
  ✓ fmp-common.sh: validate_symbol() with valid symbols: AAPL should be valid symbol
  ✓ fmp-common.sh: format_error() returns valid JSON: Error JSON should be valid
  ✓ fmp-quote.sh: fetch single symbol: Quote response should be valid JSON
  ○ fmp-quote.sh: fetch batch symbols: SKIPPED - API key not available

========================================
Test Summary: FMP Helper Scripts Unit Tests
========================================
Total tests:   25
Passed:        20
Failed:        0
Skipped:       5
All tests passed!
```

## Test Helpers

The `test-helpers.sh` provides reusable test functions:

### Assertion Functions

- `assert_equal <expected> <actual> [message]` - Assert values are equal
- `assert_not_equal <not_expected> <actual> [message]` - Assert values differ
- `assert_not_empty <value> [message]` - Assert value is not empty
- `assert_empty <value> [message]` - Assert value is empty
- `assert_contains <haystack> <needle> [message]` - Assert substring present
- `assert_json <json> [message]` - Assert valid JSON
- `assert_json_has_key <json> <key> [message]` - Assert JSON has key
- `assert_json_value <json> <key> <expected> [message]` - Assert JSON value
- `assert_file_exists <file> [message]` - Assert file exists
- `assert_success [message]` - Mark test as passed
- `assert_failure [message]` - Mark test as failed

### Utility Functions

- `setup_test_env()` - Setup test environment
- `cleanup_test_env()` - Cleanup test artifacts
- `has_api_key()` - Check if API key is available
- `create_mock_response <file> <data>` - Create mock API response

### Example Usage

```bash
source /Users/nazymazimbayev/apex-os-1/tests/test-helpers.sh

init_test_suite "My Test Suite"

start_test "Test name"
result=$(some_command)
assert_json "$result" "Should return valid JSON"
assert_json_has_key "$result" ".symbol" "Should have symbol field"

print_summary
```

## Troubleshooting

### Tests Not Running

**Problem**: Permission denied
```bash
chmod +x /Users/nazymazimbayev/apex-os-1/tests/**/*.sh
```

**Problem**: Test helpers not found
```bash
# Ensure you're using absolute paths
source /Users/nazymazimbayev/apex-os-1/tests/test-helpers.sh
```

### All Tests Skipped

**Cause**: No API key configured

**Solution**:
```bash
echo "FMP_API_KEY=your_api_key_here" > /Users/nazymazimbayev/apex-os-1/.env
```

### API Errors

**Problem**: "Rate limit exceeded"
- Wait 1 minute before running tests again
- Reduce number of test runs

**Problem**: "Invalid API key"
- Verify API key in `.env` is correct
- Check API key hasn't expired

**Problem**: "403 Forbidden"
- Check API subscription tier
- Some endpoints require paid subscription

### Test Failures

**Problem**: JSON parsing errors
```bash
# Ensure jq is installed
which jq || brew install jq
```

**Problem**: Tests fail due to slow network
- Tests have timeouts configured
- Increase timeout in specific test if needed

### Temporary Files

Tests create temporary files in `/tmp/fmp-tests-*`:
- Automatically cleaned up after each test suite
- Manual cleanup if needed:
```bash
rm -rf /tmp/fmp-tests-*
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: FMP Integration Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Install dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y jq

      - name: Setup API key
        env:
          FMP_API_KEY: ${{ secrets.FMP_API_KEY }}
        run: echo "FMP_API_KEY=$FMP_API_KEY" > .env

      - name: Run unit tests
        run: bash tests/unit/test-fmp-scripts.sh

      - name: Run integration tests
        run: bash tests/integration/test-agents.sh

      - name: Run error tests
        run: bash tests/error/test-error-scenarios.sh
```

## Performance Monitoring

Track performance over time:

```bash
# Run performance tests and save results
bash tests/performance/benchmark-fmp.sh > performance-$(date +%Y%m%d).log

# Compare against thresholds
grep "completed in" performance-*.log
```

## Contributing

When adding new tests:

1. Follow existing test structure
2. Use test-helpers.sh functions
3. Include both mock and real API modes
4. Add descriptive test names
5. Document any new dependencies
6. Update this README

## Test Coverage Summary

| Component | Unit Tests | Integration Tests | E2E Tests | Error Tests | Performance Tests |
|-----------|------------|-------------------|-----------|-------------|-------------------|
| fmp-common.sh | ✓ | - | - | ✓ | - |
| fmp-quote.sh | ✓ | ✓ | ✓ | ✓ | ✓ |
| fmp-financials.sh | ✓ | ✓ | ✓ | ✓ | ✓ |
| fmp-ratios.sh | ✓ | ✓ | ✓ | - | ✓ |
| fmp-profile.sh | ✓ | ✓ | ✓ | - | ✓ |
| fmp-historical.sh | ✓ | ✓ | ✓ | - | ✓ |
| fmp-screener.sh | ✓ | ✓ | ✓ | - | ✓ |
| fmp-indicators.sh | ✓ | ✓ | ✓ | ✓ | ✓ |
| Market Scanner | - | ✓ | ✓ | - | ✓ |
| Fundamental Analyst | - | ✓ | ✓ | - | ✓ |
| Technical Analyst | - | ✓ | ✓ | - | ✓ |
| Portfolio Monitor | - | ✓ | ✓ | - | ✓ |

## Support

For issues or questions:
1. Check troubleshooting section above
2. Review test output for specific error messages
3. Verify prerequisites are installed
4. Check FMP API status: https://site.financialmodelingprep.com/

## License

Same as APEX-OS project license.
