#!/bin/sh

# Main test runner for animex test suite
# Reads configuration from test-config.yaml and executes test scripts

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Test statistics
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0

# Script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Configuration
VERBOSE=0
CATEGORY=""
STOP_ON_FAILURE=0
OUTPUT_FILE=""

# Usage
usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Run the animex test suite.

Options:
  -h, --help              Show this help message
  -v, --verbose           Enable verbose output
  -c, --category CATEGORY Run only tests in category (unit|integration|smoke)
  -s, --stop-on-failure   Stop running tests after first failure
  -o, --output FILE       Write results to file

Examples:
  $(basename "$0")                    # Run all tests
  $(basename "$0") -c smoke           # Run only smoke tests
  $(basename "$0") -v -s              # Verbose mode, stop on first failure

EOF
}

# Parse command line arguments
parse_args() {
    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help)
                usage
                exit 0
                ;;
            -v|--verbose)
                VERBOSE=1
                shift
                ;;
            -c|--category)
                CATEGORY="$2"
                shift 2
                ;;
            -s|--stop-on-failure)
                STOP_ON_FAILURE=1
                shift
                ;;
            -o|--output)
                OUTPUT_FILE="$2"
                shift 2
                ;;
            *)
                printf "${RED}Error: Unknown option: %s${NC}\n" "$1"
                usage
                exit 1
                ;;
        esac
    done
}

# Print header
print_header() {
    printf "\n"
    printf "${CYAN}========================================${NC}\n"
    printf "${CYAN}  animex Test Suite${NC}\n"
    printf "${CYAN}========================================${NC}\n"
    printf "\n"
}

# Print test category header
print_category_header() {
    category_name="$1"
    category_desc="$2"
    
    printf "\n${MAGENTA}--- %s ---${NC}\n" "$category_name"
    if [ -n "$category_desc" ]; then
        printf "${MAGENTA}%s${NC}\n" "$category_desc"
    fi
    printf "\n"
}

# Run a single test script
run_test() {
    test_script="$1"
    test_name="$2"
    
    if [ ! -f "$test_script" ]; then
        printf "${YELLOW}⊘ SKIP${NC} %s (script not found)\n" "$test_name"
        SKIPPED_TESTS=$((SKIPPED_TESTS + 1))
        return 2
    fi
    
    if [ ! -x "$test_script" ]; then
        printf "${YELLOW}⊘ SKIP${NC} %s (not executable)\n" "$test_name"
        SKIPPED_TESTS=$((SKIPPED_TESTS + 1))
        return 2
    fi
    
    printf "${BLUE}→ RUN${NC}  %s\n" "$test_name"
    
    # Run the test
    if [ $VERBOSE -eq 1 ]; then
        "$test_script"
        exit_code=$?
    else
        output=$("$test_script" 2>&1)
        exit_code=$?
    fi
    
    # Check result
    if [ $exit_code -eq 0 ]; then
        printf "${GREEN}✓ PASS${NC} %s\n" "$test_name"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        TOTAL_TESTS=$((TOTAL_TESTS + 1))
        
        # Store output if needed
        if [ -n "$OUTPUT_FILE" ] && [ $VERBOSE -eq 0 ]; then
            printf "\n=== %s ===\n%s\n" "$test_name" "$output" >> "$OUTPUT_FILE"
        fi
        
        return 0
    else
        printf "${RED}✗ FAIL${NC} %s (exit code: %d)\n" "$test_name" "$exit_code"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        TOTAL_TESTS=$((TOTAL_TESTS + 1))
        
        # Show output on failure
        if [ $VERBOSE -eq 0 ]; then
            printf "\n${YELLOW}Test output:${NC}\n"
            printf "%s\n" "$output"
        fi
        
        # Store output
        if [ -n "$OUTPUT_FILE" ]; then
            printf "\n=== %s (FAILED) ===\n%s\n" "$test_name" "$output" >> "$OUTPUT_FILE"
        fi
        
        return 1
    fi
}

# Run smoke tests
run_smoke_tests() {
    if [ -n "$CATEGORY" ] && [ "$CATEGORY" != "smoke" ]; then
        return 0
    fi
    
    print_category_header "Smoke Tests" "Basic functionality checks"
    
    run_test "$SCRIPT_DIR/test-smoke.sh" "Smoke Tests"
    result=$?
    
    if [ $result -eq 1 ] && [ $STOP_ON_FAILURE -eq 1 ]; then
        printf "\n${RED}Stopping due to test failure${NC}\n"
        return 1
    fi
    
    return 0
}

# Run unit tests
run_unit_tests() {
    if [ -n "$CATEGORY" ] && [ "$CATEGORY" != "unit" ]; then
        return 0
    fi
    
    print_category_header "Unit Tests" "Testing individual functions and components"
    
    # Validation tests
    run_test "$SCRIPT_DIR/test-validation.sh" "Validation Tests"
    result=$?
    if [ $result -eq 1 ] && [ $STOP_ON_FAILURE -eq 1 ]; then
        printf "\n${RED}Stopping due to test failure${NC}\n"
        return 1
    fi
    
    # Quality tests
    run_test "$SCRIPT_DIR/test-quality.sh" "Quality Selection Tests"
    result=$?
    if [ $result -eq 1 ] && [ $STOP_ON_FAILURE -eq 1 ]; then
        printf "\n${RED}Stopping due to test failure${NC}\n"
        return 1
    fi
    
    # Mode tests
    run_test "$SCRIPT_DIR/test-mode.sh" "Mode (Dub/Sub) Tests"
    result=$?
    if [ $result -eq 1 ] && [ $STOP_ON_FAILURE -eq 1 ]; then
        printf "\n${RED}Stopping due to test failure${NC}\n"
        return 1
    fi
    
    return 0
}

# Run integration tests
run_integration_tests() {
    if [ -n "$CATEGORY" ] && [ "$CATEGORY" != "integration" ]; then
        return 0
    fi
    
    print_category_header "Integration Tests" "Testing feature workflows"
    
    # Config file tests
    run_test "$SCRIPT_DIR/test-config-file.sh" "Config File Tests"
    result=$?
    if [ $result -eq 1 ] && [ $STOP_ON_FAILURE -eq 1 ]; then
        printf "\n${RED}Stopping due to test failure${NC}\n"
        return 1
    fi
    
    return 0
}

# Print summary
print_summary() {
    printf "\n"
    printf "${CYAN}========================================${NC}\n"
    printf "${CYAN}  Test Summary${NC}\n"
    printf "${CYAN}========================================${NC}\n"
    
    printf "${GREEN}Passed:  %3d${NC}\n" "$PASSED_TESTS"
    printf "${RED}Failed:  %3d${NC}\n" "$FAILED_TESTS"
    printf "${YELLOW}Skipped: %3d${NC}\n" "$SKIPPED_TESTS"
    printf "${CYAN}────────────────${NC}\n"
    printf "${BLUE}Total:   %3d${NC}\n" "$TOTAL_TESTS"
    printf "${CYAN}========================================${NC}\n"
    
    # Write summary to file
    if [ -n "$OUTPUT_FILE" ]; then
        {
            printf "\n========================================\n"
            printf "Test Summary\n"
            printf "========================================\n"
            printf "Passed:  %d\n" "$PASSED_TESTS"
            printf "Failed:  %d\n" "$FAILED_TESTS"
            printf "Skipped: %d\n" "$SKIPPED_TESTS"
            printf "Total:   %d\n" "$TOTAL_TESTS"
            printf "========================================\n"
        } >> "$OUTPUT_FILE"
    fi
    
    printf "\n"
    
    # Determine overall result
    if [ $FAILED_TESTS -eq 0 ]; then
        if [ $TOTAL_TESTS -eq 0 ]; then
            printf "${YELLOW}⚠ No tests were run${NC}\n\n"
            return 2
        else
            printf "${GREEN}✓ All tests passed!${NC}\n\n"
            return 0
        fi
    else
        printf "${RED}✗ Some tests failed${NC}\n\n"
        return 1
    fi
}

# Cleanup function
cleanup() {
    # Remove temporary test directories if needed
    if [ -d "/tmp/animex-test-"* ]; then
        rm -rf /tmp/animex-test-* 2>/dev/null
    fi
}

# Main execution
main() {
    # Parse arguments
    parse_args "$@"
    
    # Validate category if specified
    if [ -n "$CATEGORY" ]; then
        case "$CATEGORY" in
            unit|integration|smoke)
                ;;
            *)
                printf "${RED}Error: Invalid category: %s${NC}\n" "$CATEGORY"
                printf "Valid categories: unit, integration, smoke\n"
                exit 1
                ;;
        esac
    fi
    
    # Initialize output file
    if [ -n "$OUTPUT_FILE" ]; then
        > "$OUTPUT_FILE"
        printf "animex Test Results\n" > "$OUTPUT_FILE"
        printf "Generated: %s\n\n" "$(date)" >> "$OUTPUT_FILE"
    fi
    
    # Print header
    print_header
    
    # Run test categories in order
    run_smoke_tests
    if [ $? -eq 1 ]; then
        cleanup
        print_summary
        exit 1
    fi
    
    run_unit_tests
    if [ $? -eq 1 ]; then
        cleanup
        print_summary
        exit 1
    fi
    
    run_integration_tests
    if [ $? -eq 1 ]; then
        cleanup
        print_summary
        exit 1
    fi
    
    # Cleanup
    cleanup
    
    # Print summary
    print_summary
    exit_code=$?
    
    exit $exit_code
}

# Trap to cleanup on exit
trap cleanup EXIT INT TERM

# Run main
main "$@"
