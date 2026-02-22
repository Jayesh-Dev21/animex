#!/bin/sh

# Integration tests for config file functionality

TEST_NAME="Config File Tests"
TESTS_PASSED=0
TESTS_FAILED=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test directory
TEST_DIR="/tmp/animex-test-$$"
TEST_CONFIG="$TEST_DIR/config"

# Setup
setup() {
    mkdir -p "$TEST_DIR"
}

# Cleanup
cleanup() {
    rm -rf "$TEST_DIR"
}

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

assert_file_exists() {
    test_name="$1"
    file_path="$2"
    
    if [ -f "$file_path" ]; then
        printf "${GREEN}✓${NC} %s\n" "$test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        printf "${RED}✗${NC} %s (file not found: %s)\n" "$test_name" "$file_path"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

assert_file_contains() {
    test_name="$1"
    file_path="$2"
    search_string="$3"
    
    if grep -q "$search_string" "$file_path" 2>/dev/null; then
        printf "${GREEN}✓${NC} %s\n" "$test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        printf "${RED}✗${NC} %s (string not found: %s)\n" "$test_name" "$search_string"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Test: Default config creation
test_default_config_creation() {
    cat > "$TEST_CONFIG" <<'EOF'
# animex configuration file
# This file is sourced by animex on startup
# Command-line flags and environment variables override these settings

# Default mode (sub or dub)
default_mode="sub"

# Default quality (best, worst, 360, 480, 720, 1080)
default_quality="best"

# Default player (leave empty for auto-detect: mpv, vlc, iina, etc.)
default_player=""

# Download directory
download_dir="."

# Skip intro automatically (0 or 1)
skip_intro="0"

# Use external menu (rofi) instead of fzf (0 or 1)
use_external_menu="0"

# Exit after playback ends (0 or 1)
exit_after_play="0"
EOF

    assert_file_exists "Config file created" "$TEST_CONFIG"
    assert_file_contains "Config contains default_mode" "$TEST_CONFIG" 'default_mode="sub"'
    assert_file_contains "Config contains default_quality" "$TEST_CONFIG" 'default_quality="best"'
    assert_file_contains "Config contains download_dir" "$TEST_CONFIG" 'download_dir="."'
}

# Test: Config file loading
test_config_loading() {
    cat > "$TEST_CONFIG" <<'EOF'
default_mode="dub"
default_quality="720"
default_player="mpv"
download_dir="/tmp/downloads"
skip_intro="1"
use_external_menu="1"
exit_after_play="1"
EOF

    # Source the config file
    . "$TEST_CONFIG"
    
    assert_equals "Config loads default_mode" "dub" "$default_mode"
    assert_equals "Config loads default_quality" "720" "$default_quality"
    assert_equals "Config loads default_player" "mpv" "$default_player"
    assert_equals "Config loads download_dir" "/tmp/downloads" "$download_dir"
    assert_equals "Config loads skip_intro" "1" "$skip_intro"
    assert_equals "Config loads use_external_menu" "1" "$use_external_menu"
    assert_equals "Config loads exit_after_play" "1" "$exit_after_play"
}

# Test: Config file with comments and whitespace
test_config_parsing() {
    cat > "$TEST_CONFIG" <<'EOF'
# This is a comment
default_mode="sub"

# Another comment
default_quality="1080"  # inline comment

   # Indented comment
default_player="vlc"
EOF

    . "$TEST_CONFIG"
    
    assert_equals "Config parses mode with comments" "sub" "$default_mode"
    assert_equals "Config parses quality with inline comment" "1080" "$default_quality"
    assert_equals "Config parses player with indented comment" "vlc" "$default_player"
}

# Test: Invalid config values
test_invalid_config_values() {
    cat > "$TEST_CONFIG" <<'EOF'
default_mode="invalid"
default_quality="999"
default_player="nonexistent"
EOF

    . "$TEST_CONFIG"
    
    # Config should still load the values (validation happens in animex)
    assert_equals "Config loads invalid mode" "invalid" "$default_mode"
    assert_equals "Config loads invalid quality" "999" "$default_quality"
    assert_equals "Config loads nonexistent player" "nonexistent" "$default_player"
}

# Test: Empty config file
test_empty_config() {
    > "$TEST_CONFIG"
    
    assert_file_exists "Empty config file exists" "$TEST_CONFIG"
    
    # Sourcing empty config should not error
    . "$TEST_CONFIG" 2>/dev/null
    result=$?
    
    if [ $result -eq 0 ]; then
        result_str="true"
    else
        result_str="false"
    fi
    assert_true "Empty config sources without error" "$result_str"
}

# Test: Config with only some values set
test_partial_config() {
    cat > "$TEST_CONFIG" <<'EOF'
default_mode="dub"
default_quality="480"
EOF

    . "$TEST_CONFIG"
    
    assert_equals "Partial config loads mode" "dub" "$default_mode"
    assert_equals "Partial config loads quality" "480" "$default_quality"
}

# Test: Config file permissions
test_config_permissions() {
    cat > "$TEST_CONFIG" <<'EOF'
default_mode="sub"
EOF
    chmod 644 "$TEST_CONFIG"
    
    if [ -r "$TEST_CONFIG" ]; then
        perm_result="true"
    else
        perm_result="false"
    fi
    
    assert_true "Config file is readable" "$perm_result"
}

# Test: Config with special characters in paths
test_special_characters() {
    cat > "$TEST_CONFIG" <<'EOF'
download_dir="/tmp/anime downloads"
default_player="mpv"
EOF

    . "$TEST_CONFIG"
    
    assert_equals "Config handles spaces in paths" "/tmp/anime downloads" "$download_dir"
}

# Test: Multiple equal signs in value
test_multiple_equals() {
    cat > "$TEST_CONFIG" <<'EOF'
download_dir="/path/with=equals"
EOF

    . "$TEST_CONFIG"
    
    # Shell sourcing should handle this correctly
    if [ -n "$download_dir" ]; then
        result="true"
    else
        result="false"
    fi
    
    assert_true "Config handles equals in value" "$result"
}

# Main execution
main() {
    printf "\n${YELLOW}Running %s${NC}\n\n" "$TEST_NAME"
    
    setup
    
    test_default_config_creation
    test_config_loading
    test_config_parsing
    test_invalid_config_values
    test_empty_config
    test_partial_config
    test_config_permissions
    test_special_characters
    test_multiple_equals
    
    cleanup
    
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
