#!/bin/bash
# APEX-OS FMP Integration Test Suite
# Tests end-to-end data fetching and file-based pattern

set -e

BLUE='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_test() { echo -e "${BLUE}TEST: $1${NC}"; }
print_pass() { echo -e "${GREEN}✓ PASS: $1${NC}"; }
print_fail() { echo -e "${RED}✗ FAIL: $1${NC}"; exit 1; }
print_info() { echo -e "${YELLOW}INFO: $1${NC}"; }

echo "========================================"
echo "APEX-OS FMP Integration Test Suite"
echo "========================================"
echo ""

# Test 1: Environment configuration
print_test "Checking .env configuration"
if [ ! -f apex-os/.env ]; then
    print_fail "apex-os/.env file missing (run installer first)"
fi

source apex-os/.env
if [ -z "$FMP_API_KEY" ]; then
    print_fail "FMP_API_KEY not set in apex-os/.env"
fi
if [ "$FMP_API_KEY" = "your_fmp_api_key_here" ]; then
    print_fail "FMP_API_KEY still contains placeholder value"
fi
print_pass "apex-os/.env configured correctly"
echo ""

# Test 2: Directory structure
print_test "Checking workspace directories"
required_dirs=(
    "apex-os/data/fmp"
    "apex-os/scripts/data-fetching/fmp"
    "apex-os/portfolio"
    "apex-os/principles"
)

for dir in "${required_dirs[@]}"; do
    if [ ! -d "$dir" ]; then
        print_fail "Required directory missing: $dir"
    fi
done
print_pass "All workspace directories exist"
echo ""

# Test 3: Scripts exist and are executable
print_test "Checking FMP scripts"
required_scripts=(
    "apex-os/scripts/data-fetching/fmp/fmp-common.sh"
    "apex-os/scripts/data-fetching/fmp/fmp-transcript.sh"
    "apex-os/scripts/data-fetching/fmp/fmp-financials.sh"
    "apex-os/scripts/data-fetching/fmp/fmp-earnings.sh"
    "apex-os/scripts/data-fetching/fmp/process-transcript.py"
)

for script in "${required_scripts[@]}"; do
    if [ ! -f "$script" ]; then
        print_fail "Script missing: $script"
    fi
    if [ ! -x "$script" ] && [[ "$script" == *.sh ]]; then
        chmod +x "$script"
        print_info "Made executable: $script"
    fi
done
print_pass "All FMP scripts found"
echo ""

# Test 4: Fetch test transcript
print_test "Fetching test transcript (AAPL, 1 quarter)"
print_info "This will consume 1 API call from your quota"

cd apex-os/scripts/data-fetching/fmp
result=$(./fmp-transcript.sh AAPL 1 2>&1)

# Verify valid JSON response
if ! echo "$result" | jq empty 2>/dev/null; then
    echo "Script output:"
    echo "$result"
    print_fail "Script returned invalid JSON"
fi

# Check success flag
success=$(echo "$result" | jq -r '.success')
if [ "$success" != "true" ]; then
    echo "Error details:"
    echo "$result" | jq '.'
    print_fail "Fetch failed (check API key and quota)"
fi

print_pass "Transcript fetch successful"
echo ""

# Test 5: Verify files created
print_test "Verifying JSON files were created"
data_dir=$(echo "$result" | jq -r '.data_dir')

if [ ! -d "$data_dir" ]; then
    print_fail "Data directory not found: $data_dir"
fi

file_count=$(ls "$data_dir"/aapl-transcript-*.json 2>/dev/null | wc -l)
if [ "$file_count" -eq 0 ]; then
    print_fail "No transcript JSON files created"
fi

print_pass "Created $file_count transcript JSON file(s)"
echo ""

# Test 6: Process to text format
print_test "Processing JSON to readable text"
combined=$(echo "$result" | jq -r '.combined_file')

if [ ! -f "$combined" ]; then
    print_fail "Combined file not found: $combined"
fi

process_result=$(python3 process-transcript.py "$combined" 2>&1)
if ! echo "$process_result" | jq empty 2>/dev/null; then
    echo "Processor output:"
    echo "$process_result"
    print_fail "Processing failed"
fi

print_pass "JSON processed to text successfully"
echo ""

# Test 7: Verify text files exist
print_test "Verifying readable text files created"
txt_count=$(ls "$data_dir"/aapl-earnings-*.txt 2>/dev/null | wc -l)

if [ "$txt_count" -eq 0 ]; then
    print_fail "No text files created"
fi

print_pass "Created $txt_count readable text file(s)"
echo ""

# Test 8: Test financial statements
print_test "Testing financial statements fetch"
cd ../../../..

fin_result=$(bash apex-os/scripts/data-fetching/fmp/fmp-financials.sh AAPL income annual 2 2>&1)

if ! echo "$fin_result" | jq empty 2>/dev/null; then
    echo "Financials output:"
    echo "$fin_result"
    print_fail "Financials returned invalid JSON"
fi

fin_success=$(echo "$fin_result" | jq -r '.success')
if [ "$fin_success" != "true" ]; then
    print_fail "Financials fetch failed"
fi

fin_files=$(echo "$fin_result" | jq -r '.files[]')
if [ -z "$fin_files" ]; then
    print_fail "No financial statement files created"
fi

print_pass "Financial statements fetch successful"
echo ""

# Test 9: Verify log file created
print_test "Checking data fetch logging"

if [ ! -f "apex-os/logs/data-fetch.log" ]; then
    print_fail "Log file not created"
fi

log_lines=$(wc -l < "apex-os/logs/data-fetch.log")
if [ "$log_lines" -eq 0 ]; then
    print_fail "Log file is empty"
fi

print_pass "Data fetch logged correctly ($log_lines entries)"
echo ""

# Test 10: Verify file naming convention
print_test "Verifying file naming convention"

if ! ls apex-os/data/fmp/aapl-transcript-*-Q*.json >/dev/null 2>&1; then
    print_fail "Transcript files don't follow naming convention: {symbol}-transcript-{YYYY}-Q{#}.json"
fi

if ! ls apex-os/data/fmp/aapl-income-statement-*-annual.json >/dev/null 2>&1; then
    print_fail "Financial files don't follow naming convention: {symbol}-income-statement-{YYYY}-annual.json"
fi

print_pass "File naming convention correct"
echo ""

# Summary
echo "========================================"
echo -e "${GREEN}All tests passed! ✓${NC}"
echo "========================================"
echo ""
echo "Files created in: $data_dir"
ls -lh "$data_dir"/aapl-* 2>/dev/null | head -10
echo ""
echo "You can now:"
echo "  1. Read cached data with Read tool"
echo "  2. Run fundamental analysis on AAPL"
echo "  3. Fetch more data for other symbols"
echo ""
echo "API usage logged to: apex-os/logs/data-fetch.log"
tail -5 apex-os/logs/data-fetch.log
echo ""
print_info "Test complete. Your APEX-OS installation is ready for use!"
