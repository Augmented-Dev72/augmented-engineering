#!/bin/bash
# compound-engineering plugin — PostToolUse hook
# Runs formatting, linting, and auto-testing after file edits.
#
# Reads rules from .compound.json via lib/config.sh.
# If no .compound.json exists, exits silently (no-op).
#
# Config shape (postEdit section of .compound.json):
#   {
#     "postEdit": {
#       "rules": [
#         { "match": "\\.(js|ts)$", "run": "npx prettier --write $FILE" },
#         { "match": "\\.(js|ts)$", "pathMatch": "/src/", "run": "npx eslint --fix $FILE" }
#       ],
#       "autoTest": {
#         "enabled": true,
#         "match": "\\.(js|ts)$",
#         "excludeMatch": "__tests__|test|spec",
#         "testDiscovery": "sibling-dir",
#         "testDirName": "__tests__",
#         "testSuffix": ".test.js",
#         "testCommand": "npx jest --testPathPattern=$TEST_FILE --bail"
#       }
#     }
#   }

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Exit silently if no file path or file doesn't exist
if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

# Skip Claude Code internal files
if [[ "$FILE_PATH" =~ /\.claude/ ]]; then
  exit 0
fi

# Bypass if disabled
if [ "${COMPOUND_SKIP_POST_EDIT:-0}" = "1" ]; then
  exit 0
fi

# Load config
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ ! -f "$SCRIPT_DIR/../lib/config.sh" ]; then
  exit 0
fi
source "$SCRIPT_DIR/../lib/config.sh"
load_compound_config || exit 0

# Check if postEdit section exists
if [ "$(get_config_value '.postEdit' '')" = "" ]; then
  exit 0
fi

# --- Run formatting/linting rules ---

RULE_COUNT=$(echo "$COMPOUND_CONFIG" | jq '.postEdit.rules | length' 2>/dev/null)
if [ -n "$RULE_COUNT" ] && [ "$RULE_COUNT" -gt 0 ]; then
  for i in $(seq 0 $((RULE_COUNT - 1))); do
    MATCH=$(echo "$COMPOUND_CONFIG" | jq -r ".postEdit.rules[$i].match // empty")
    PATH_MATCH=$(echo "$COMPOUND_CONFIG" | jq -r ".postEdit.rules[$i].pathMatch // empty")
    RUN_CMD=$(echo "$COMPOUND_CONFIG" | jq -r ".postEdit.rules[$i].run // empty")

    # Skip if no match pattern or no command
    if [ -z "$MATCH" ] || [ -z "$RUN_CMD" ]; then
      continue
    fi

    # Check file extension match
    if ! echo "$FILE_PATH" | grep -qE "$MATCH"; then
      continue
    fi

    # Check path match (optional)
    if [ -n "$PATH_MATCH" ] && ! echo "$FILE_PATH" | grep -qE "$PATH_MATCH"; then
      continue
    fi

    # Execute the command with $FILE replaced
    EXPANDED_CMD=$(echo "$RUN_CMD" | sed "s|\$FILE|$FILE_PATH|g")
    eval "$EXPANDED_CMD" 2>/dev/null
  done
fi

# --- Auto-test on component edits ---

AUTO_TEST_ENABLED=$(get_config_value '.postEdit.autoTest.enabled' 'false')
if [ "$AUTO_TEST_ENABLED" != "true" ]; then
  exit 0
fi

AUTO_TEST_MATCH=$(get_config_value '.postEdit.autoTest.match' '')
EXCLUDE_MATCH=$(get_config_value '.postEdit.autoTest.excludeMatch' '')
DISCOVERY=$(get_config_value '.postEdit.autoTest.testDiscovery' 'sibling-dir')
TEST_DIR_NAME=$(get_config_value '.postEdit.autoTest.testDirName' '__tests__')
TEST_SUFFIX=$(get_config_value '.postEdit.autoTest.testSuffix' '.test.js')
TEST_COMMAND=$(get_config_value '.postEdit.autoTest.testCommand' '')

# Check if file matches auto-test pattern
if [ -z "$AUTO_TEST_MATCH" ] || ! echo "$FILE_PATH" | grep -qE "$AUTO_TEST_MATCH"; then
  exit 0
fi

# Exclude test files themselves
if [ -n "$EXCLUDE_MATCH" ] && echo "$FILE_PATH" | grep -qE "$EXCLUDE_MATCH"; then
  exit 0
fi

# Discover test files based on strategy
COMPONENT_DIR=$(dirname "$FILE_PATH")
TEST_FILES=""

case "$DISCOVERY" in
  sibling-dir)
    # Look in $COMPONENT_DIR/$TEST_DIR_NAME/ for matching test files
    TEST_DIR="$COMPONENT_DIR/$TEST_DIR_NAME"
    if [ -d "$TEST_DIR" ]; then
      TEST_FILES=$(find "$TEST_DIR" -name "*${TEST_SUFFIX}" 2>/dev/null)
    fi
    ;;
  co-located)
    # Look in same directory for matching test files
    TEST_FILES=$(find "$COMPONENT_DIR" -maxdepth 1 -name "*${TEST_SUFFIX}" 2>/dev/null)
    ;;
  custom)
    # User provides the full test command with $FILE placeholder
    if [ -n "$TEST_COMMAND" ]; then
      EXPANDED_TEST_CMD=$(echo "$TEST_COMMAND" | sed "s|\$FILE|$FILE_PATH|g")
      echo "Running test: $EXPANDED_TEST_CMD" >&2
      eval "$EXPANDED_TEST_CMD" 2>&1 || true
    fi
    exit 0
    ;;
esac

# Run tests for discovered files
if [ -n "$TEST_FILES" ] && [ -n "$TEST_COMMAND" ]; then
  echo "$TEST_FILES" | while read -r TEST_FILE; do
    if [ -n "$TEST_FILE" ]; then
      EXPANDED_TEST_CMD=$(echo "$TEST_COMMAND" | sed "s|\$TEST_FILE|$TEST_FILE|g" | sed "s|\$FILE|$FILE_PATH|g")
      echo "Running test: $TEST_FILE" >&2
      eval "$EXPANDED_TEST_CMD" 2>&1 || true
    fi
  done
fi

exit 0
