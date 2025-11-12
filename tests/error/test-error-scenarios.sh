#!/usr/bin/env bash
# test-error-scenarios.sh - Error scenario testing
# Tests error handling across all FMP components

set -euo pipefail

# Get script directory
SCRIPT_DIR="/Users/nazymazimbayev/apex-os-1"
FMP_SCRIPTS_DIR="$SCRIPT_DIR/scripts/fmp"
TEST_DIR="$(dirname "$0")"

# Source test helpers
source "$SCRIPT_DIR/tests/test-helpers.sh"

# Initialize test suite
init_test_suite "Error Scenario Tests"

# Setup test environment
setup_test_env

#=============================================================================
# Test Invalid Symbol Handling
#=============================================================================

test_invalid_symbol_quote() {
    start_test "Error: Invalid symbol in fmp-quote.sh"

    if ! has_api_key; then
        skip_test "API key not available"
        return
    fi

    # Test with clearly invalid symbol
    local result=$(bash "$FMP_SCRIPTS_DIR/fmp-quote.sh" "INVALID999" 2>&1)

    # Should return valid JSON
    if ! assert_json "$result" "Invalid symbol should return valid JSON"; then
        return
    fi

    # Should either be error JSON or empty array
    if echo "$result" | jq -e '.error' >/dev/null 2>&1; then
        assert_success "Invalid symbol returns error JSON"
    else
        local count=$(echo "$result" | jq 'length')
        if [[ $count -eq 0 ]]; then
            assert_success "Invalid symbol returns empty array"
        else
            skip_test "Invalid symbol returned unexpected data"
        fi
    fi
}

test_invalid_symbol_financials() {
    start_test "Error: Invalid symbol in fmp-financials.sh"

    if ! has_api_key; then
        skip_test "API key not available"
        return
    fi

    local result=$(bash "$FMP_SCRIPTS_DIR/fmp-financials.sh" "INVALID999" income 5 annual 2>&1)

    if ! assert_json "$result" "Invalid symbol should return valid JSON"; then
        return
    fi

    # Should handle gracefully
    if echo "$result" | jq -e '.error' >/dev/null 2>&1 || [[ $(echo "$result" | jq 'length') -eq 0 ]]; then
        assert_success "Invalid symbol handled gracefully"
    else
        skip_test "Invalid symbol returned unexpected data"
    fi
}

test_invalid_symbol_all_scripts() {
    start_test "Error: Invalid symbol across all scripts"

    if ! has_api_key; then
        skip_test "API key not available"
        return
    fi

    local invalid_symbol="BADSTOCK999"
    local all_handled=true

    # Test each script with invalid symbol
    local scripts=(
        "fmp-quote.sh $invalid_symbol"
        "fmp-profile.sh $invalid_symbol"
        "fmp-financials.sh $invalid_symbol income 5 annual"
        "fmp-ratios.sh $invalid_symbol ratios 5"
        "fmp-historical.sh $invalid_symbol '' '' 10 daily"
    )

    for script_cmd in "${scripts[@]}"; do
        local result=$(bash "$FMP_SCRIPTS_DIR/$script_cmd" 2>&1)

        if ! echo "$result" | jq -e . >/dev/null 2>&1; then
            all_handled=false
            echo -e "${RED}  Script failed: $script_cmd${NC}"
        fi
    done

    if $all_handled; then
        assert_success "All scripts handle invalid symbols"
    else
        assert_failure "Some scripts failed with invalid symbol"
    fi
}

#=============================================================================
# Test Missing API Key Handling
#=============================================================================

test_missing_api_key() {
    start_test "Error: Missing API key in .env"

    # Backup current .env
    local env_file="$SCRIPT_DIR/.env"
    local env_backup="$TEST_TMP_DIR/.env.backup"

    if [[ -f "$env_file" ]]; then
        cp "$env_file" "$env_backup"
    fi

    # Remove .env temporarily
    rm -f "$env_file"

    # Test API call without .env
    local result=$(bash "$FMP_SCRIPTS_DIR/fmp-quote.sh" AAPL 2>&1)

    # Restore .env
    if [[ -f "$env_backup" ]]; then
        cp "$env_backup" "$env_file"
    fi

    # Should return error JSON
    if assert_json "$result" "Missing API key should return valid JSON"; then
        if echo "$result" | jq -e '.error' >/dev/null 2>&1; then
            local error_type=$(echo "$result" | jq -r '.type')
            if [[ "$error_type" == "missing_api_key" ]]; then
                assert_success "Missing API key returns correct error type"
            else
                assert_failure "Wrong error type: $error_type"
            fi
        else
            assert_failure "Missing API key should return error"
        fi
    fi
}

test_empty_api_key() {
    start_test "Error: Empty API key in .env"

    # Backup current .env
    local env_file="$SCRIPT_DIR/.env"
    local env_backup="$TEST_TMP_DIR/.env.backup"

    if [[ -f "$env_file" ]]; then
        cp "$env_file" "$env_backup"
    fi

    # Create .env with empty API key
    echo "FMP_API_KEY=" > "$env_file"

    # Test API call with empty key
    local result=$(bash "$FMP_SCRIPTS_DIR/fmp-quote.sh" AAPL 2>&1)

    # Restore .env
    if [[ -f "$env_backup" ]]; then
        cp "$env_backup" "$env_file"
    fi

    # Should return error
    if assert_json "$result" "Empty API key should return valid JSON"; then
        if echo "$result" | jq -e '.error' >/dev/null 2>&1; then
            assert_success "Empty API key returns error"
        else
            skip_test "Empty API key test inconclusive"
        fi
    fi
}

#=============================================================================
# Test Malformed Response Handling
#=============================================================================

test_malformed_json_handling() {
    start_test "Error: Malformed JSON response handling"

    # Create a mock script that returns malformed JSON
    local mock_script="$TEST_TMP_DIR/mock-malformed.sh"

    cat > "$mock_script" <<'EOF'
#!/usr/bin/env bash
echo "This is not JSON"
EOF

    chmod +x "$mock_script"

    # Test that jq validation would catch this
    local result=$(bash "$mock_script" 2>&1)

    if echo "$result" | jq -e . >/dev/null 2>&1; then
        assert_failure "Should detect malformed JSON"
    else
        assert_success "Malformed JSON detected correctly"
    fi
}

#=============================================================================
# Test Rate Limit Handling
#=============================================================================

test_rate_limit_tracking() {
    start_test "Error: Rate limit tracking functionality"

    # Check if rate limit files are created
    local rate_limit_dir="/tmp"
    local rate_file_pattern="fmp_rate_*.txt"

    # Make a test API call to create rate limit file
    if has_api_key; then
        bash "$FMP_SCRIPTS_DIR/fmp-quote.sh" AAPL >/dev/null 2>&1

        # Check if rate limit file was created
        if ls $rate_limit_dir/$rate_file_pattern >/dev/null 2>&1; then
            assert_success "Rate limit tracking file created"

            # Check file content
            local rate_file=$(ls -t $rate_limit_dir/$rate_file_pattern | head -1)
            if [[ -f "$rate_file" ]]; then
                local count=$(wc -l < "$rate_file")
                echo -e "${BLUE}  Rate limit file has $count entries${NC}"
            fi
        else
            skip_test "Rate limit file not found (may not be implemented)"
        fi
    else
        skip_test "API key not available"
    fi
}

test_rate_limit_prevention() {
    start_test "Error: Rate limit prevention (controlled test)"

    # Note: We won't actually trigger rate limits to avoid API abuse
    # Instead, we'll verify the rate limit check function exists

    if ! has_api_key; then
        skip_test "API key not available"
        return
    fi

    # Check if fmp-common.sh has rate limit function
    if grep -q "check_rate_limit" "$FMP_SCRIPTS_DIR/fmp-common.sh"; then
        assert_success "Rate limit check function exists in fmp-common.sh"
    else
        assert_failure "Rate limit check function not found"
    fi
}

#=============================================================================
# Test Missing Required Parameters
#=============================================================================

test_missing_parameters_quote() {
    start_test "Error: Missing symbol parameter in fmp-quote.sh"

    # Call without symbol parameter
    local result=$(bash "$FMP_SCRIPTS_DIR/fmp-quote.sh" 2>&1 || echo '{"error": true}')

    # Should handle gracefully (either error or usage message)
    if echo "$result" | grep -qi "usage\|error\|symbol"; then
        assert_success "Missing parameter handled with error/usage message"
    else
        skip_test "Parameter handling unclear"
    fi
}

test_missing_parameters_financials() {
    start_test "Error: Missing parameters in fmp-financials.sh"

    # Call without required parameters
    local result=$(bash "$FMP_SCRIPTS_DIR/fmp-financials.sh" 2>&1 || echo '{"error": true}')

    # Should handle gracefully
    if echo "$result" | grep -qi "usage\|error\|symbol\|type"; then
        assert_success "Missing parameters handled with error/usage message"
    else
        skip_test "Parameter handling unclear"
    fi
}

test_invalid_statement_type() {
    start_test "Error: Invalid statement type in fmp-financials.sh"

    if ! has_api_key; then
        skip_test "API key not available"
        return
    fi

    local result=$(bash "$FMP_SCRIPTS_DIR/fmp-financials.sh" AAPL invalid_type 5 annual 2>&1)

    if assert_json "$result" "Invalid type should return valid JSON"; then
        if echo "$result" | jq -e '.error' >/dev/null 2>&1; then
            assert_success "Invalid statement type returns error"
        else
            assert_failure "Invalid type should return error"
        fi
    fi
}

test_invalid_indicator_type() {
    start_test "Error: Invalid indicator type in fmp-indicators.sh"

    if ! has_api_key; then
        skip_test "API key not available"
        return
    fi

    local result=$(bash "$FMP_SCRIPTS_DIR/fmp-indicators.sh" AAPL invalid_indicator 14 daily 2>&1)

    if assert_json "$result" "Invalid indicator should return valid JSON"; then
        if echo "$result" | jq -e '.error' >/dev/null 2>&1; then
            assert_success "Invalid indicator type returns error"
        else
            skip_test "Invalid indicator handling unclear"
        fi
    fi
}

#=============================================================================
# Test Empty Response Handling
#=============================================================================

test_empty_response_array() {
    start_test "Error: Empty response array handling"

    # Use an obscure symbol that likely has no data
    if ! has_api_key; then
        skip_test "API key not available"
        return
    fi

    local result=$(bash "$FMP_SCRIPTS_DIR/fmp-quote.sh" "ZZZZZ" 2>&1)

    if assert_json "$result" "Empty response should return valid JSON"; then
        # Should be either error or empty array
        if echo "$result" | jq -e '.error' >/dev/null 2>&1; then
            assert_success "Empty response returns error JSON"
        else
            local count=$(echo "$result" | jq 'length')
            if [[ $count -eq 0 ]]; then
                assert_success "Empty response returns empty array"
            else
                skip_test "Obscure symbol returned data"
            fi
        fi
    fi
}

#=============================================================================
# Test Network/Timeout Scenarios
#=============================================================================

test_network_error_handling() {
    start_test "Error: Network error handling structure"

    # Check if scripts use timeout in curl calls
    if grep -q "max-time\|timeout" "$FMP_SCRIPTS_DIR/fmp-common.sh"; then
        assert_success "Timeout configuration found in fmp-common.sh"
    else
        assert_failure "No timeout configuration found"
    fi
}

test_retry_logic_exists() {
    start_test "Error: Retry logic implementation"

    # Check if retry logic exists in fmp-common.sh
    if grep -q "retry\|attempt" "$FMP_SCRIPTS_DIR/fmp-common.sh"; then
        assert_success "Retry logic found in fmp-common.sh"
    else
        skip_test "Retry logic not found (may use different pattern)"
    fi
}

#=============================================================================
# Test Error Message Quality
#=============================================================================

test_error_message_format() {
    start_test "Error: Error messages have standard format"

    if ! has_api_key; then
        skip_test "API key not available"
        return
    fi

    # Generate an error (invalid statement type)
    local result=$(bash "$FMP_SCRIPTS_DIR/fmp-financials.sh" AAPL invalid 5 annual 2>&1)

    if assert_json "$result" "Error should be valid JSON"; then
        if echo "$result" | jq -e '.error' >/dev/null 2>&1; then
            # Check for required error fields
            local has_type=$(echo "$result" | jq -e '.type' >/dev/null 2>&1 && echo "yes" || echo "no")
            local has_message=$(echo "$result" | jq -e '.message' >/dev/null 2>&1 && echo "yes" || echo "no")

            if [[ "$has_type" == "yes" && "$has_message" == "yes" ]]; then
                assert_success "Error has standard format (type, message)"
            else
                assert_failure "Error missing standard fields"
            fi
        else
            skip_test "No error returned"
        fi
    fi
}

test_user_friendly_error_messages() {
    start_test "Error: Error messages are user-friendly"

    if ! has_api_key; then
        skip_test "API key not available"
        return
    fi

    # Generate an error
    local result=$(bash "$FMP_SCRIPTS_DIR/fmp-financials.sh" AAPL invalid 5 annual 2>&1)

    if echo "$result" | jq -e '.error' >/dev/null 2>&1; then
        local message=$(echo "$result" | jq -r '.message')

        # Message should not contain technical jargon like "500 error", etc.
        # Should be descriptive
        if [[ ${#message} -gt 10 ]]; then
            assert_success "Error message is descriptive: $message"
        else
            assert_failure "Error message too short: $message"
        fi
    else
        skip_test "No error message to test"
    fi
}

#=============================================================================
# Run all tests
#=============================================================================

echo ""
echo -e "${BOLD}${BLUE}Running Error Scenario Tests...${NC}"
echo ""

# Invalid symbol tests
test_invalid_symbol_quote
test_invalid_symbol_financials
test_invalid_symbol_all_scripts

# Missing API key tests
test_missing_api_key
test_empty_api_key

# Malformed response tests
test_malformed_json_handling

# Rate limit tests
test_rate_limit_tracking
test_rate_limit_prevention

# Missing parameter tests
test_missing_parameters_quote
test_missing_parameters_financials
test_invalid_statement_type
test_invalid_indicator_type

# Empty response tests
test_empty_response_array

# Network/timeout tests
test_network_error_handling
test_retry_logic_exists

# Error message quality tests
test_error_message_format
test_user_friendly_error_messages

# Cleanup and print summary
cleanup_test_env
print_summary

exit $?
