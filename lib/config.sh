#!/bin/bash
# compound-engineering plugin — shared configuration loader
#
# Provides functions to read .compound.json project configuration.
# All functions degrade gracefully when jq is not installed or config is missing.

COMPOUND_CONFIG=""
COMPOUND_CONFIG_PATH_RESOLVED=""

# Check if jq is available
_compound_has_jq() {
  command -v jq &>/dev/null
}

# load_compound_config — finds and loads .compound.json
# Resolution order:
#   1. $COMPOUND_CONFIG_PATH (explicit override)
#   2. $CLAUDE_PROJECT_DIR/.compound.json (Claude Code project root)
#   3. CWD/.compound.json (fallback)
load_compound_config() {
  COMPOUND_CONFIG=""
  COMPOUND_CONFIG_PATH_RESOLVED=""

  local config_file=""

  if [ -n "$COMPOUND_CONFIG_PATH" ] && [ -f "$COMPOUND_CONFIG_PATH" ]; then
    config_file="$COMPOUND_CONFIG_PATH"
  elif [ -n "$CLAUDE_PROJECT_DIR" ] && [ -f "$CLAUDE_PROJECT_DIR/.compound.json" ]; then
    config_file="$CLAUDE_PROJECT_DIR/.compound.json"
  elif [ -f ".compound.json" ]; then
    config_file=".compound.json"
  fi

  if [ -z "$config_file" ]; then
    return 1
  fi

  if ! _compound_has_jq; then
    echo "compound-engineering: jq not found — config loading disabled" >&2
    return 1
  fi

  # Validate JSON before loading
  if ! jq empty "$config_file" 2>/dev/null; then
    echo "compound-engineering: invalid JSON in $config_file" >&2
    return 1
  fi

  COMPOUND_CONFIG=$(cat "$config_file")
  COMPOUND_CONFIG_PATH_RESOLVED="$config_file"
  return 0
}

# get_config_value <jq_path> [default]
# Reads a scalar value from loaded config. Returns default if not found.
get_config_value() {
  local jq_path="${1:-.}"
  local default="${2:-}"

  if [ -z "$COMPOUND_CONFIG" ]; then
    echo "$default"
    return
  fi

  if ! _compound_has_jq; then
    echo "$default"
    return
  fi

  local result
  result=$(echo "$COMPOUND_CONFIG" | jq -r "$jq_path // empty" 2>/dev/null)

  if [ -z "$result" ] || [ "$result" = "null" ]; then
    echo "$default"
  else
    echo "$result"
  fi
}

# get_config_array <jq_path>
# Reads a JSON array from config, outputs one item per line.
get_config_array() {
  local jq_path="${1:-.}"

  if [ -z "$COMPOUND_CONFIG" ]; then
    return
  fi

  if ! _compound_has_jq; then
    return
  fi

  echo "$COMPOUND_CONFIG" | jq -r "$jq_path[]? // empty" 2>/dev/null
}

# has_config — returns 0 if config is loaded, 1 otherwise
has_config() {
  [ -n "$COMPOUND_CONFIG" ]
}
