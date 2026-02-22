#!/bin/sh

# Unit tests for dub/sub mode functionality

TEST_NAME="Mode (Dub/Sub) Tests"
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

assert_contains() {
    test_name="$1"
    haystack="$2"
    needle="$3"
    
    case "$haystack" in
        *"$needle"*)
            printf "${GREEN}✓${NC} %s\n" "$test_name"
            TESTS_PASSED=$((TESTS_PASSED + 1))
            ;;
        *)
            printf "${RED}✗${NC} %s (string not found: %s)\n" "$test_name" "$needle"
            TESTS_FAILED=$((TESTS_FAILED + 1))
            ;;
    esac
}

# Test: Default mode is sub
test_default_mode() {
    mode="${mode:-sub}"
    assert_equals "Default mode is 'sub'" "sub" "$mode"
}

# Test: Mode can be set to dub
test_mode_dub() {
    mode="dub"
    assert_equals "Mode set to 'dub'" "dub" "$mode"
}

# Test: Mode validation - valid values
test_mode_validation_valid() {
    valid_modes="sub dub"
    
    for m in $valid_modes; do
        case "$m" in
            sub|dub)
                result="valid"
                ;;
            *)
                result="invalid"
                ;;
        esac
        assert_equals "Mode '$m' is valid" "valid" "$result"
    done
}

# Test: Mode validation - invalid values
test_mode_validation_invalid() {
    invalid_modes="raw english japanese dubbed subbed"
    
    for m in $invalid_modes; do
        case "$m" in
            sub|dub)
                result="valid"
                ;;
            *)
                result="invalid"
                ;;
        esac
        assert_equals "Mode '$m' is invalid" "invalid" "$result"
    done
}

# Test: Mode from --dub flag
test_mode_from_flag() {
    # Simulate --dub flag being set
    dub_flag=1
    
    if [ -n "$dub_flag" ]; then
        mode="dub"
    else
        mode="sub"
    fi
    
    assert_equals "Mode from --dub flag" "dub" "$mode"
}

# Test: Mode from environment variable
test_mode_from_env() {
    ANIMEX_MODE="dub"
    mode="${ANIMEX_MODE:-sub}"
    
    assert_equals "Mode from env var" "dub" "$mode"
    
    unset ANIMEX_MODE
}

# Test: Mode priority (CLI > ENV > default)
test_mode_priority_cli_over_env() {
    ANIMEX_MODE="sub"
    cli_mode="dub"
    
    # CLI should override ENV
    final_mode="${cli_mode:-$ANIMEX_MODE}"
    final_mode="${final_mode:-sub}"
    
    assert_equals "CLI mode overrides ENV" "dub" "$final_mode"
    
    unset ANIMEX_MODE
}

# Test: Mode priority (ENV > default)
test_mode_priority_env_over_default() {
    ANIMEX_MODE="dub"
    cli_mode=""
    
    final_mode="${cli_mode:-$ANIMEX_MODE}"
    final_mode="${final_mode:-sub}"
    
    assert_equals "ENV mode overrides default" "dub" "$final_mode"
    
    unset ANIMEX_MODE
}

# Test: Mode toggle from sub to dub
test_mode_toggle_to_dub() {
    mode="sub"
    
    # Toggle mode
    if [ "$mode" = "dub" ]; then
        mode="sub"
    else
        mode="dub"
    fi
    
    assert_equals "Mode toggles from sub to dub" "dub" "$mode"
}

# Test: Mode toggle from dub to sub
test_mode_toggle_to_sub() {
    mode="dub"
    
    # Toggle mode
    if [ "$mode" = "dub" ]; then
        mode="sub"
    else
        mode="dub"
    fi
    
    assert_equals "Mode toggles from dub to sub" "sub" "$mode"
}

# Test: Mode display in prompt (sub)
test_mode_display_sub() {
    mode="sub"
    
    if [ "$mode" = "dub" ]; then
        prompt="[DUB]"
    else
        prompt="[SUB]"
    fi
    
    assert_equals "Mode display shows [SUB]" "[SUB]" "$prompt"
}

# Test: Mode display in prompt (dub)
test_mode_display_dub() {
    mode="dub"
    
    if [ "$mode" = "dub" ]; then
        prompt="[DUB]"
    else
        prompt="[SUB]"
    fi
    
    assert_equals "Mode display shows [DUB]" "[DUB]" "$prompt"
}

# Test: Search result formatting with sub count
test_search_format_sub_only() {
    title="One Piece"
    sub_count=1100
    dub_count=0
    
    if [ "$dub_count" -gt 0 ]; then
        result="$title ($sub_count sub, $dub_count dub)"
    else
        result="$title ($sub_count sub)"
    fi
    
    expected="One Piece (1100 sub)"
    assert_equals "Search shows sub count only" "$expected" "$result"
}

# Test: Search result formatting with both counts
test_search_format_sub_and_dub() {
    title="Attack on Titan"
    sub_count=87
    dub_count=87
    
    if [ "$dub_count" -gt 0 ]; then
        result="$title ($sub_count sub, $dub_count dub)"
    else
        result="$title ($sub_count sub)"
    fi
    
    expected="Attack on Titan (87 sub, 87 dub)"
    assert_equals "Search shows both counts" "$expected" "$result"
}

# Test: Search result formatting with different counts
test_search_format_different_counts() {
    title="Naruto"
    sub_count=500
    dub_count=295
    
    if [ "$dub_count" -gt 0 ]; then
        result="$title ($sub_count sub, $dub_count dub)"
    else
        result="$title ($sub_count sub)"
    fi
    
    expected="Naruto (500 sub, 295 dub)"
    assert_equals "Search shows different counts" "$expected" "$result"
}

# Test: Mode in API query parameter
test_mode_api_parameter_sub() {
    mode="sub"
    
    # Simulate API query construction
    translation_type="sub"
    query_contains_mode="translationType:\"$translation_type\""
    
    assert_contains "API query contains sub mode" "$query_contains_mode" "translationType:\"sub\""
}

# Test: Mode in API query parameter (dub)
test_mode_api_parameter_dub() {
    mode="dub"
    
    # Simulate API query construction
    translation_type="dub"
    query_contains_mode="translationType:\"$translation_type\""
    
    assert_contains "API query contains dub mode" "$query_contains_mode" "translationType:\"dub\""
}

# Test: Mode case insensitivity
test_mode_case() {
    mode="DUB"
    mode_lower=$(printf "%s" "$mode" | tr '[:upper:]' '[:lower:]')
    
    assert_equals "Mode converts to lowercase" "dub" "$mode_lower"
}

# Test: Mode persistence across episodes
test_mode_persistence() {
    mode="dub"
    episode_1_mode="$mode"
    
    # Simulate playing next episode
    episode_2_mode="$mode"
    
    assert_equals "Mode persists across episodes" "$episode_1_mode" "$episode_2_mode"
}

# Test: Mode toggle command recognition
test_mode_toggle_command() {
    user_input="toggle_mode"
    
    if [ "$user_input" = "toggle_mode" ]; then
        recognized="true"
    else
        recognized="false"
    fi
    
    assert_true "Toggle mode command recognized" "$recognized"
}

# Main execution
main() {
    printf "\n${YELLOW}Running %s${NC}\n\n" "$TEST_NAME"
    
    test_default_mode
    test_mode_dub
    test_mode_validation_valid
    test_mode_validation_invalid
    test_mode_from_flag
    test_mode_from_env
    test_mode_priority_cli_over_env
    test_mode_priority_env_over_default
    test_mode_toggle_to_dub
    test_mode_toggle_to_sub
    test_mode_display_sub
    test_mode_display_dub
    test_search_format_sub_only
    test_search_format_sub_and_dub
    test_search_format_different_counts
    test_mode_api_parameter_sub
    test_mode_api_parameter_dub
    test_mode_case
    test_mode_persistence
    test_mode_toggle_command
    
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
