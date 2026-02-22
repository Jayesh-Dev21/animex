#!/bin/sh

# Smoke tests for basic animex functionality

TEST_NAME="Smoke Tests"
TESTS_PASSED=0
TESTS_FAILED=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Path to animex script (assuming tests are in tests/ directory)
ANIMEX="../animex"

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

assert_exit_code() {
    test_name="$1"
    expected="$2"
    actual="$3"
    
    if [ "$expected" -eq "$actual" ]; then
        printf "${GREEN}✓${NC} %s\n" "$test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        printf "${RED}✗${NC} %s (expected exit: %s, got: %s)\n" "$test_name" "$expected" "$actual"
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

# Test: animex script exists
test_script_exists() {
    if [ -f "$ANIMEX" ]; then
        result="true"
    else
        result="false"
    fi
    assert_true "animex script exists" "$result"
}

# Test: animex script is executable
test_script_executable() {
    if [ -x "$ANIMEX" ]; then
        result="true"
    else
        result="false"
    fi
    assert_true "animex script is executable" "$result"
}

# Test: Help flag (-h)
test_help_flag_short() {
    output=$("$ANIMEX" -h 2>&1)
    exit_code=$?
    
    assert_exit_code "Help flag (-h) exits successfully" 0 "$exit_code"
    assert_contains "Help shows usage" "$output" "Usage:"
}

# Test: Help flag (--help)
test_help_flag_long() {
    output=$("$ANIMEX" --help 2>&1)
    exit_code=$?
    
    assert_exit_code "Help flag (--help) exits successfully" 0 "$exit_code"
    assert_contains "Help shows usage" "$output" "Usage:"
}

# Test: Version flag (-V)
test_version_flag_short() {
    output=$("$ANIMEX" -V 2>&1)
    exit_code=$?
    
    assert_exit_code "Version flag (-V) exits successfully" 0 "$exit_code"
    assert_contains "Version shows version number" "$output" "4.11.0"
}

# Test: Version flag (--version)
test_version_flag_long() {
    output=$("$ANIMEX" --version 2>&1)
    exit_code=$?
    
    assert_exit_code "Version flag (--version) exits successfully" 0 "$exit_code"
    assert_contains "Version shows version number" "$output" "4.11.0"
}

# Test: Help contains all major options
test_help_completeness() {
    output=$("$ANIMEX" -h 2>&1)
    
    assert_contains "Help shows -q option" "$output" "-q"
    assert_contains "Help shows -d option" "$output" "-d"
    assert_contains "Help shows -c option" "$output" "-c"
    assert_contains "Help shows --dub option" "$output" "--dub"
    assert_contains "Help shows --config option" "$output" "--config"
}

# Test: Invalid flag shows error
test_invalid_flag() {
    output=$("$ANIMEX" --invalid-flag 2>&1)
    exit_code=$?
    
    # Should exit with non-zero
    if [ $exit_code -ne 0 ]; then
        cond="true"
    else
        cond="false"
    fi
    assert_true "Invalid flag exits with error" "$cond"
}

# Test: Script shebang is correct
test_shebang() {
    first_line=$(head -n 1 "$ANIMEX")
    
    if [ "$first_line" = "#!/bin/sh" ]; then
        result="true"
    else
        result="false"
    fi
    assert_true "Script has correct shebang" "$result"
}

# Test: Script has required functions
test_required_functions() {
    # Check for key function definitions
    if grep -q "^create_default_config()" "$ANIMEX"; then
        func1="true"
    else
        func1="false"
    fi
    assert_true "Script has create_default_config function" "$func1"
    
    if grep -q "^validate_episode_number()" "$ANIMEX"; then
        func2="true"
    else
        func2="false"
    fi
    assert_true "Script has validate_episode_number function" "$func2"
    
    if grep -q "^validate_anime_id()" "$ANIMEX"; then
        func3="true"
    else
        func3="false"
    fi
    assert_true "Script has validate_anime_id function" "$func3"
    
    if grep -q "^select_quality()" "$ANIMEX"; then
        func4="true"
    else
        func4="false"
    fi
    assert_true "Script has select_quality function" "$func4"
}

# Test: Script contains version number
test_version_in_script() {
    if grep -q "^version_number=" "$ANIMEX"; then
        result="true"
    else
        result="false"
    fi
    assert_true "Script has version variable" "$result"
}

# Test: Script contains updated repository URL
test_repository_url() {
    if grep -q "Jayesh-Dev21/animex" "$ANIMEX"; then
        result="true"
    else
        result="false"
    fi
    assert_true "Script contains updated repository URL" "$result"
}

# Test: Script does not contain old repository URL
test_no_old_repository() {
    if grep -q "pystardust/animex" "$ANIMEX"; then
        result="false"
    else
        result="true"
    fi
    assert_true "Script does not contain old repository URL" "$result"
}

# Test: Config-related flags exist in help
test_config_flags_in_help() {
    output=$("$ANIMEX" -h 2>&1)
    
    assert_contains "Help mentions config file" "$output" "config"
}

# Test: Quality-related flags exist in help
test_quality_flags_in_help() {
    output=$("$ANIMEX" -h 2>&1)
    
    assert_contains "Help mentions quality flag" "$output" "quality"
}

# Test: Mode-related flags exist in help
test_mode_flags_in_help() {
    output=$("$ANIMEX" -h 2>&1)
    
    assert_contains "Help mentions dub flag" "$output" "dub"
}

# Test: Script syntax is valid
test_script_syntax() {
    sh -n "$ANIMEX" 2>/dev/null
    exit_code=$?
    
    assert_exit_code "Script has valid shell syntax" 0 "$exit_code"
}

# Test: Script has no bashisms (POSIX compliant)
test_posix_compliance() {
    # Check for common bashisms (excluding [[:space:]] which is POSIX ERE)
    if grep -qE '\[\[ |^let |^local ' "$ANIMEX"; then
        result="false"
    else
        result="true"
    fi
    # Note: This is a basic check, not comprehensive
    assert_true "Script appears POSIX compliant (basic check)" "$result"
}

# Main execution
main() {
    printf "\n${YELLOW}Running %s${NC}\n\n" "$TEST_NAME"
    
    test_script_exists
    test_script_executable
    test_help_flag_short
    test_help_flag_long
    test_version_flag_short
    test_version_flag_long
    test_help_completeness
    test_invalid_flag
    test_shebang
    test_required_functions
    test_version_in_script
    test_repository_url
    test_no_old_repository
    test_config_flags_in_help
    test_quality_flags_in_help
    test_mode_flags_in_help
    test_script_syntax
    test_posix_compliance
    
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
