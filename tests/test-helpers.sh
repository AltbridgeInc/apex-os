#!/usr/bin/env bash
# test-helpers.sh - Shared test functions and utilities
# Used by all test scripts for assertions, mocking, and output formatting

set -euo pipefail

# Color codes for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

# Test state
CURRENT_TEST_NAME=""
CURRENT_TEST_SUITE=""

# Initialize test suite
# Args: $1 - suite name
init_test_suite() {
    CURRENT_TEST_SUITE="$1"
    TESTS_RUN=0
    TESTS_PASSED=0
    TESTS_FAILED=0
    TESTS_SKIPPED=0

    echo -e "${BOLD}${BLUE}========================================${NC}"
    echo -e "${BOLD}${BLUE}Test Suite: ${CURRENT_TEST_SUITE}${NC}"
    echo -e "${BOLD}${BLUE}========================================${NC}"
    echo ""
}

# Start a test
# Args: $1 - test name
start_test() {
    CURRENT_TEST_NAME="$1"
    ((TESTS_RUN++))
}

# Assert equal
# Args: $1 - expected, $2 - actual, $3 - message (optional)
assert_equal() {
    local expected="$1"
    local actual="$2"
    local message="${3:-values should be equal}"

    if [[ "$expected" == "$actual" ]]; then
        pass_test "$message"
        return 0
    else
        fail_test "$message (expected: '$expected', got: '$actual')"
        return 1
    fi
}

# Assert not equal
# Args: $1 - not_expected, $2 - actual, $3 - message (optional)
assert_not_equal() {
    local not_expected="$1"
    local actual="$2"
    local message="${3:-values should not be equal}"

    if [[ "$not_expected" != "$actual" ]]; then
        pass_test "$message"
        return 0
    else
        fail_test "$message (both values: '$actual')"
        return 1
    fi
}

# Assert not empty
# Args: $1 - value, $2 - message (optional)
assert_not_empty() {
    local value="$1"
    local message="${2:-value should not be empty}"

    if [[ -n "$value" ]]; then
        pass_test "$message"
        return 0
    else
        fail_test "$message (value is empty)"
        return 1
    fi
}

# Assert empty
# Args: $1 - value, $2 - message (optional)
assert_empty() {
    local value="$1"
    local message="${2:-value should be empty}"

    if [[ -z "$value" ]]; then
        pass_test "$message"
        return 0
    else
        fail_test "$message (value is '$value')"
        return 1
    fi
}

# Assert true (exit code 0)
# Args: $1 - message
assert_true() {
    local message="${1:-assertion should be true}"
    pass_test "$message"
    return 0
}

# Assert false (exit code 1)
# Args: $1 - message
assert_false() {
    local message="${1:-assertion should be false}"
    fail_test "$message"
    return 1
}

# Assert contains
# Args: $1 - haystack, $2 - needle, $3 - message (optional)
assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-string should contain substring}"

    if [[ "$haystack" == *"$needle"* ]]; then
        pass_test "$message"
        return 0
    else
        fail_test "$message (expected to find '$needle' in '$haystack')"
        return 1
    fi
}

# Assert not contains
# Args: $1 - haystack, $2 - needle, $3 - message (optional)
assert_not_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-string should not contain substring}"

    if [[ "$haystack" != *"$needle"* ]]; then
        pass_test "$message"
        return 0
    else
        fail_test "$message (found '$needle' in '$haystack')"
        return 1
    fi
}

# Assert valid JSON
# Args: $1 - json string, $2 - message (optional)
assert_json() {
    local json="$1"
    local message="${2:-should be valid JSON}"

    if echo "$json" | jq -e . >/dev/null 2>&1; then
        pass_test "$message"
        return 0
    else
        fail_test "$message (invalid JSON: '$json')"
        return 1
    fi
}

# Assert JSON has key
# Args: $1 - json string, $2 - key path, $3 - message (optional)
assert_json_has_key() {
    local json="$1"
    local key="$2"
    local message="${3:-JSON should have key '$key'}"

    if echo "$json" | jq -e "$key" >/dev/null 2>&1; then
        pass_test "$message"
        return 0
    else
        fail_test "$message"
        return 1
    fi
}

# Assert JSON value equals
# Args: $1 - json string, $2 - key path, $3 - expected value, $4 - message (optional)
assert_json_value() {
    local json="$1"
    local key="$2"
    local expected="$3"
    local message="${4:-JSON key '$key' should equal '$expected'}"

    local actual=$(echo "$json" | jq -r "$key" 2>/dev/null || echo "")

    if [[ "$actual" == "$expected" ]]; then
        pass_test "$message"
        return 0
    else
        fail_test "$message (expected: '$expected', got: '$actual')"
        return 1
    fi
}

# Assert file exists
# Args: $1 - file path, $2 - message (optional)
assert_file_exists() {
    local file="$1"
    local message="${2:-file '$file' should exist}"

    if [[ -f "$file" ]]; then
        pass_test "$message"
        return 0
    else
        fail_test "$message"
        return 1
    fi
}

# Assert file not exists
# Args: $1 - file path, $2 - message (optional)
assert_file_not_exists() {
    local file="$1"
    local message="${2:-file '$file' should not exist}"

    if [[ ! -f "$file" ]]; then
        pass_test "$message"
        return 0
    else
        fail_test "$message"
        return 1
    fi
}

# Assert command succeeds
# Args: $1 - command, $2 - message (optional)
assert_success() {
    local message="${1:-command should succeed}"
    pass_test "$message"
    return 0
}

# Assert command fails
# Args: $1 - message
assert_failure() {
    local message="${1:-command should fail}"
    fail_test "$message"
    return 1
}

# Mark test as passed
# Args: $1 - message (optional)
pass_test() {
    local message="${1:-}"
    ((TESTS_PASSED++))
    echo -e "  ${GREEN}✓${NC} ${CURRENT_TEST_NAME}: ${message}"
}

# Mark test as failed
# Args: $1 - message (optional)
fail_test() {
    local message="${1:-}"
    ((TESTS_FAILED++))
    echo -e "  ${RED}✗${NC} ${CURRENT_TEST_NAME}: ${message}"
}

# Skip test
# Args: $1 - reason
skip_test() {
    local reason="${1:-test skipped}"
    ((TESTS_SKIPPED++))
    echo -e "  ${YELLOW}○${NC} ${CURRENT_TEST_NAME}: SKIPPED - ${reason}"
}

# Print test suite summary
print_summary() {
    echo ""
    echo -e "${BOLD}${BLUE}========================================${NC}"
    echo -e "${BOLD}${BLUE}Test Summary: ${CURRENT_TEST_SUITE}${NC}"
    echo -e "${BOLD}${BLUE}========================================${NC}"
    echo -e "Total tests:   ${TESTS_RUN}"
    echo -e "${GREEN}Passed:        ${TESTS_PASSED}${NC}"
    echo -e "${RED}Failed:        ${TESTS_FAILED}${NC}"
    echo -e "${YELLOW}Skipped:       ${TESTS_SKIPPED}${NC}"

    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${BOLD}${GREEN}All tests passed!${NC}"
        return 0
    else
        echo -e "${BOLD}${RED}Some tests failed!${NC}"
        return 1
    fi
}

# Create mock FMP API response
# Args: $1 - response file path, $2 - mock data (JSON)
create_mock_response() {
    local file="$1"
    local data="$2"
    echo "$data" > "$file"
}

# Mock FMP API call (for testing without API key)
# Args: $1 - endpoint, $2 - mock response file
mock_fmp_call() {
    local endpoint="$1"
    local mock_file="${2:-}"

    if [[ -n "$mock_file" && -f "$mock_file" ]]; then
        cat "$mock_file"
        return 0
    else
        echo '{"error": true, "type": "mock_error", "message": "Mock response not found"}'
        return 1
    fi
}

# Setup test environment
setup_test_env() {
    # Create temporary directory for test artifacts
    export TEST_TMP_DIR="/tmp/fmp-tests-$$-$(date +%s)"
    mkdir -p "$TEST_TMP_DIR"

    # Create backup of .env if it exists
    if [[ -f "/Users/nazymazimbayev/apex-os-1/.env" ]]; then
        export ENV_BACKUP="$TEST_TMP_DIR/.env.backup"
        cp "/Users/nazymazimbayev/apex-os-1/.env" "$ENV_BACKUP"
    fi

    echo -e "${BLUE}Test environment setup at: $TEST_TMP_DIR${NC}"
}

# Cleanup test environment
cleanup_test_env() {
    # Restore .env if backed up
    if [[ -n "${ENV_BACKUP:-}" && -f "$ENV_BACKUP" ]]; then
        cp "$ENV_BACKUP" "/Users/nazymazimbayev/apex-os-1/.env"
    fi

    # Remove temporary directory
    if [[ -n "${TEST_TMP_DIR:-}" && -d "$TEST_TMP_DIR" ]]; then
        rm -rf "$TEST_TMP_DIR"
        echo -e "${BLUE}Test environment cleaned up${NC}"
    fi
}

# Check if API key is available (for real API tests)
has_api_key() {
    if [[ -f "/Users/nazymazimbayev/apex-os-1/.env" ]]; then
        source "/Users/nazymazimbayev/apex-os-1/.env"
        if [[ -n "${FMP_API_KEY:-}" ]]; then
            return 0
        fi
    fi
    return 1
}

# Export functions for use in other scripts
export -f init_test_suite
export -f start_test
export -f assert_equal
export -f assert_not_equal
export -f assert_not_empty
export -f assert_empty
export -f assert_true
export -f assert_false
export -f assert_contains
export -f assert_not_contains
export -f assert_json
export -f assert_json_has_key
export -f assert_json_value
export -f assert_file_exists
export -f assert_file_not_exists
export -f assert_success
export -f assert_failure
export -f pass_test
export -f fail_test
export -f skip_test
export -f print_summary
export -f create_mock_response
export -f mock_fmp_call
export -f setup_test_env
export -f cleanup_test_env
export -f has_api_key
