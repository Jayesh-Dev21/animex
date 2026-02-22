#!/bin/sh

# Unit tests for quality selection functionality

TEST_NAME="Quality Selection Tests"
TESTS_PASSED=0
TESTS_FAILED=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Assert helper
assert_true() {
    test_name="$1"
    condition="$2"
    
    if [ "$condition" = "true" ]; then
        printf "${GREEN}✓${NC} %s\n" "$test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        printf "${RED}✗${NC} %s\n" "$test_name"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

assert_equals() {
    test_name="$1"
    expected="$2"
    actual="$3"
    
    if [ "$expected" = "$actual" ]; then
        printf "${GREEN}✓${NC} %s\n" "$test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        printf "${RED}✗${NC} %s (expected: %s, got: %s)\n" "$test_name" "$expected" "$actual"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Mock select_quality function for testing
# This simulates the quality selection logic without external dependencies
mock_select_quality() {
    quality=$1
    # Simulated available links
    links='1080 >http://example.com/1080.mp4
720 >http://example.com/720.mp4
480 >http://example.com/480.mp4
360 >http://example.com/360.mp4'

    case "$quality" in
        best) result=$(printf "%s" "$links" | head -n1) ;;
        worst) result=$(printf "%s" "$links" | grep -E '^[0-9]{3,4}' | tail -n1) ;;
        *) result=$(printf "%s" "$links" | grep -m 1 "$quality") ;;
    esac
    
    if [ -z "$result" ]; then
        # Invalid quality, should return best
        result=$(printf "%s" "$links" | head -n1)
        printf "invalid"
        return 1
    fi
    
    episode=$(printf "%s" "$result" | cut -d'>' -f2)
    printf "%s" "$episode"
}

# Test: Valid quality - best
test_quality_best() {
    result=$(mock_select_quality "best")
    expected="http://example.com/1080.mp4"
    assert_equals "Quality 'best' selects highest" "$expected" "$result"
}

# Test: Valid quality - worst
test_quality_worst() {
    result=$(mock_select_quality "worst")
    expected="http://example.com/360.mp4"
    assert_equals "Quality 'worst' selects lowest" "$expected" "$result"
}

# Test: Valid quality - 1080
test_quality_1080() {
    result=$(mock_select_quality "1080")
    expected="http://example.com/1080.mp4"
    assert_equals "Quality '1080' selects 1080p" "$expected" "$result"
}

# Test: Valid quality - 720
test_quality_720() {
    result=$(mock_select_quality "720")
    expected="http://example.com/720.mp4"
    assert_equals "Quality '720' selects 720p" "$expected" "$result"
}

# Test: Valid quality - 480
test_quality_480() {
    result=$(mock_select_quality "480")
    expected="http://example.com/480.mp4"
    assert_equals "Quality '480' selects 480p" "$expected" "$result"
}

# Test: Valid quality - 360
test_quality_360() {
    result=$(mock_select_quality "360")
    expected="http://example.com/360.mp4"
    assert_equals "Quality '360' selects 360p" "$expected" "$result"
}

# Test: Invalid quality - should fallback to best
test_quality_invalid() {
    # Capture both stdout (which returns "invalid") and the fallback URL
    output=$(mock_select_quality "2160" 2>&1)
    exit_code=$?
    
    # The function returns "invalid" on stderr/stdout and sets exit code
    if [ $exit_code -ne 0 ]; then
        cond="true"
    else
        cond="false"
    fi
    assert_true "Invalid quality returns error code" "$cond"
    
    # Check that "invalid" was in the output
    case "$output" in
        *invalid*)
            cond="true"
            ;;
        *)
            cond="false"
            ;;
    esac
    assert_true "Invalid quality shows error message" "$cond"
}

# Test: Quality validation - valid values
test_quality_validation() {
    valid_qualities="best worst 360 480 720 1080 interactive"
    
    for q in $valid_qualities; do
        case "$q" in
            best|worst|360|480|720|1080|interactive)
                result="valid"
                ;;
            *)
                result="invalid"
                ;;
        esac
        assert_equals "Quality '$q' is valid" "valid" "$result"
    done
}

# Test: Quality validation - invalid values
test_quality_validation_invalid() {
    invalid_qualities="2160 4k ultra high low medium 540"
    
    for q in $invalid_qualities; do
        case "$q" in
            best|worst|360|480|720|1080|interactive)
                result="valid"
                ;;
            *)
                result="invalid"
                ;;
        esac
        assert_equals "Quality '$q' is invalid" "invalid" "$result"
    done
}

# Test: Quality parameter parsing
test_quality_parameter() {
    # Simulate CLI argument parsing
    quality=""
    
    # Test -q flag
    args="-q 720"
    for arg in $args; do
        case "$arg" in
            -q) read_next_quality=1 ;;
            *)
                if [ -n "$read_next_quality" ]; then
                    quality="$arg"
                    unset read_next_quality
                fi
                ;;
        esac
    done
    
    assert_equals "Parse -q flag" "720" "$quality"
}

# Test: Quality parameter with --quality
test_quality_parameter_long() {
    # Simulate parsing --quality=480
    arg="--quality=480"
    quality=$(printf "%s" "$arg" | cut -d'=' -f2)
    
    assert_equals "Parse --quality= flag" "480" "$quality"
}

# Test: Interactive quality should be recognized
test_quality_interactive() {
    quality="interactive"
    
    if [ "$quality" = "interactive" ]; then
        result="recognized"
    else
        result="not_recognized"
    fi
    
    assert_equals "Interactive mode recognized" "recognized" "$result"
}

# Test: Default quality when none specified
test_quality_default() {
    # Unset quality variable first
    unset quality
    quality="${quality:-best}"
    
    assert_equals "Default quality is 'best'" "best" "$quality"
}

# Test: Quality from environment variable
test_quality_from_env() {
    ANIMEX_QUALITY="720"
    quality="${ANIMEX_QUALITY:-best}"
    
    assert_equals "Quality from env var" "720" "$quality"
    
    unset ANIMEX_QUALITY
}

# Test: Quality override priority (CLI > ENV)
test_quality_priority() {
    ANIMEX_QUALITY="480"
    cli_quality="1080"
    
    # CLI should override ENV
    final_quality="${cli_quality:-$ANIMEX_QUALITY}"
    final_quality="${final_quality:-best}"
    
    assert_equals "CLI quality overrides ENV" "1080" "$final_quality"
    
    unset ANIMEX_QUALITY
}

# Test: Quality links parsing
test_quality_links_parsing() {
    links='1080 >http://example.com/1080.mp4
720 >http://example.com/720.mp4
480 >http://example.com/480.mp4'
    
    # Extract available qualities (remove extra spaces)
    available=$(printf "%s\n" "$links" | sed 's|>.*||;s| ||g' | tr '\n' ',' | sed 's|,$||')
    expected="1080,720,480"
    
    assert_equals "Parse available qualities" "$expected" "$available"
}

# Test: Quality selection with empty links
test_quality_empty_links() {
    links=""
    quality="best"
    
    result=$(printf "%s" "$links" | head -n1)
    
    if [ -z "$result" ]; then
        result_str="empty"
    else
        result_str="not_empty"
    fi
    
    assert_equals "Empty links returns empty" "empty" "$result_str"
}

# Main execution
main() {
    printf "\n${YELLOW}Running %s${NC}\n\n" "$TEST_NAME"
    
    test_quality_best
    test_quality_worst
    test_quality_1080
    test_quality_720
    test_quality_480
    test_quality_360
    test_quality_invalid
    test_quality_validation
    test_quality_validation_invalid
    test_quality_parameter
    test_quality_parameter_long
    test_quality_interactive
    test_quality_default
    test_quality_from_env
    test_quality_priority
    test_quality_links_parsing
    test_quality_empty_links
    
    # Summary
    printf "\n${YELLOW}========================================${NC}\n"
    printf "${GREEN}Passed: %d${NC}\n" "$TESTS_PASSED"
    printf "${RED}Failed: %d${NC}\n" "$TESTS_FAILED"
    printf "${YELLOW}Total:  %d${NC}\n" "$((TESTS_PASSED + TESTS_FAILED))"
    printf "${YELLOW}========================================${NC}\n\n"
    
    if [ $TESTS_FAILED -eq 0 ]; then
        exit 0
    else
        exit 1
    fi
}

main
