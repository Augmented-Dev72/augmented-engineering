#!/bin/bash
# compound-engineering plugin — Stop hook
# Runs cleanup tasks when a Claude Code session ends.
#
# Cleanup behavior is configurable via .compound.json:
#   {
#     "cleanup": {
#       "tempFilePatterns": ["/tmp/compound-*", "/tmp/claude-*"],
#       "pruneWorktrees": true
#     }
#   }

# Source config if available
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/../lib/config.sh" ]; then
  source "$SCRIPT_DIR/../lib/config.sh"
  load_compound_config 2>/dev/null
fi

# 1. Clean temp files matching configurable patterns
if has_config 2>/dev/null; then
  PATTERNS=$(get_config_array ".cleanup.tempFilePatterns" 2>/dev/null)
  if [ -n "$PATTERNS" ]; then
    echo "$PATTERNS" | while read -r pattern; do
      if [ -n "$pattern" ]; then
        PARENT_DIR=$(dirname "$pattern")
        BASENAME_PATTERN=$(basename "$pattern")
        find "$PARENT_DIR" -maxdepth 1 -name "$BASENAME_PATTERN" -mmin +120 -delete 2>/dev/null
      fi
    done
  fi
fi

# 2. Prune abandoned git worktrees (default: true)
PRUNE="true"
if has_config 2>/dev/null; then
  PRUNE=$(get_config_value ".cleanup.pruneWorktrees" "true")
fi

if [ "$PRUNE" = "true" ] && command -v git &>/dev/null && git rev-parse --git-dir &>/dev/null 2>&1; then
  git worktree prune 2>/dev/null
  echo "Pruned git worktrees" >&2
fi

exit 0
