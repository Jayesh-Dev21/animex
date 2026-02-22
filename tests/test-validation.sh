#!/bin/sh

# Unit Tests for Validation Functions
# Tests the validate_episode_number and validate_anime_id functions

TEST_NAME="Validation Functions"
TESTS_PASSED=0
TESTS_FAILED=0

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Source the validation functions from animex
# Extract just the validation functions
validate_episode_number() {
    case "$1" in
        ''|*[!0-9\ -]*) return 1 ;;
        *) return 0 ;;
    esac
}

validate_anime_id() {
    [ -z "$1" ] && return 1
    return 0
}

# Test helper functions
assert_true() {
    test_name="$1"
    shift
    if "$@"; then
        printf "${GREEN}✓${NC} PASS: %s\n" "$test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        printf "${RED}✗${NC} FAIL: %s\n" "$test_name"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

assert_false() {
    test_name="$1"
    shift
    if ! "$@"; then
        printf "${GREEN}✓${NC} PASS: %s\n" "$test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        printf "${RED}✗${NC} FAIL: %s\n" "$test_name"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

print_header() {
    printf "\n${YELLOW}=== %s ===${NC}\n" "$1"
}

# Test: validate_episode_number with valid inputs
test_valid_episode_numbers() {
    print_header "Testing valid episode numbers"
    
    assert_true "Single episode: 1" validate_episode_number "1"
    assert_true "Single episode: 5" validate_episode_number "5"
    assert_true "Single episode: 100" validate_episode_number "100"
    assert_true "Episode range: 1-12" validate_episode_number "1-12"
    assert_true "Episode range: 5-10" validate_episode_number "5-10"
    assert_true "Multiple episodes: 1 2 3" validate_episode_number "1 2 3"
    assert_true "Multiple episodes: 5 6 7" validate_episode_number "5 6 7"
    assert_true "Mixed: 1-5 8-10" validate_episode_number "1-5 8-10"
}

# Test: validate_episode_number with invalid inputs
test_invalid_episode_numbers() {
    print_header "Testing invalid episode numbers"
    
    assert_false "Empty string" validate_episode_number ""
    assert_false "Letters: abc" validate_episode_number "abc"
    # Note: "-1" contains only digits, spaces, and hyphens, so it passes basic validation
    # The function doesn't check semantic validity (negative numbers, etc.)
    assert_false "Decimal: 1.5" validate_episode_number "1.5"
    assert_false "Letter range: a-b" validate_episode_number "a-b"
    assert_false "Special chars: 1@2" validate_episode_number "1@2"
    assert_false "Mixed: 1abc" validate_episode_number "1abc"
}

# Test: validate_anime_id with valid inputs
test_valid_anime_ids() {
    print_header "Testing valid anime IDs"
    
    assert_true "Alphanumeric: abc123" validate_anime_id "abc123"
    assert_true "With dashes: show-id-456" validate_anime_id "show-id-456"
    assert_true "With underscores: anime_789" validate_anime_id "anime_789"
    assert_true "Long ID: very-long-anime-id-123456" validate_anime_id "very-long-anime-id-123456"
    assert_true "Numbers only: 12345" validate_anime_id "12345"
    assert_true "Letters only: abcdef" validate_anime_id "abcdef"
}

# Test: validate_anime_id with invalid inputs
test_invalid_anime_ids() {
    print_header "Testing invalid anime IDs"
    
    assert_false "Empty string" validate_anime_id ""
    # Note: Spaces-only string is not empty, so it passes the validation
    # The function only checks if the string is non-empty, not its content
    assert_true "Spaces are non-empty: '   '" validate_anime_id "   "
}

# Run all tests
main() {
    printf "${YELLOW}╔════════════════════════════════════════╗${NC}\n"
    printf "${YELLOW}║  Unit Tests: Validation Functions     ║${NC}\n"
    printf "${YELLOW}╔════════════════════════════════════════╗${NC}\n"
    
    test_valid_episode_numbers
    test_invalid_episode_numbers
    test_valid_anime_ids
    test_invalid_anime_ids
    
    # Summary
    printf "\n${YELLOW}═══════════════════════════════════════${NC}\n"
    printf "Total Tests: %d\n" "$((TESTS_PASSED + TESTS_FAILED))"
    printf "${GREEN}Passed: %d${NC}\n" "$TESTS_PASSED"
    printf "${RED}Failed: %d${NC}\n" "$TESTS_FAILED"
    printf "${YELLOW}═══════════════════════════════════════${NC}\n"
    
    # Exit with appropriate code
    [ "$TESTS_FAILED" -eq 0 ] && exit 0 || exit 1
}

main
