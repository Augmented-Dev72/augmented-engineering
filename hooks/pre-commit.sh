#!/bin/bash
# compound-engineering plugin — PreToolUse hook
# Auto-prepends conventional commit emoji to git commit messages.
#
# Intercepts Bash tool calls containing `git commit`, parses the commit message,
# and prepends the appropriate emoji based on conventional commit prefix or keywords.

INPUT=$(cat)

# Bypass if disabled
if [ "${COMPOUND_SKIP_PRE_COMMIT:-0}" = "1" ]; then
  exit 0
fi

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Only process git commit commands
if ! echo "$COMMAND" | grep -q 'git commit'; then
  exit 0
fi

# Try to extract the commit message from various formats
# Format 1: heredoc style — git commit -m "$(cat <<'EOF' ... EOF🛠️ )"
MESSAGE=$(echo "$COMMAND" | sed -n 's/.*-m ["\x27]\{0,1\}\$(cat <<.*EOF["\x27]\{0,1\}[[:space:]]*\n\{0,1\}//p' | sed '/EOF/,$d' 2>/dev/null)

# Format 2: simple quoted — git commit -m "message" or git commit -m 'message'
if [ -z "$MESSAGE" ]; then
  MESSAGE=$(echo "$COMMAND" | grep -oP '(?<=-m ["'"'"'])[^"'"'"']*' 2>/dev/null || echo "$COMMAND" | sed -n 's/.*-m "\([^"]*\🛠️ )".*/\1/p' 2>/dev/null)
fi

# No message found — nothing to do
if [ -z "$MESSAGE" ]; then
  exit 0
fi

FIRST_LINE=$(echo "$MESSAGE" | head -1)

# Already has an emoji prefix — skip
if echo "$FIRST_LINE" | grep -q '^[✨🐛♻️🧪📝🛠️🎨⚡🗑️🔧🚀🔒📦]'; then
  exit 0
fi

# Map conventional commit prefix to emoji
case "$FIRST_LINE" in
  feat*)     EMOJI="✨" ;;
  fix*)      EMOJI="🐛" ;;
  refactor*) EMOJI="♻️" ;;
  test*)     EMOJI="🧪" ;;
  docs*)     EMOJI="📝" ;;
  chore*)    EMOJI="🛠️" ;;
  style*)    EMOJI="🎨" ;;
  perf*)     EMOJI="⚡" ;;
  remove*|delete*) EMOJI="🗑️" ;;
  *)
    # Fallback: infer from keywords in the message
    case "$FIRST_LINE" in
      *[Aa]dd*|*[Nn]ew*|*[Cc]reate*|*[Ii]mplement*) EMOJI="✨" ;;
      *[Ff]ix*|*[Rr]esolve*|*[Cc]orrect*)            EMOJI="🐛" ;;
      *[Rr]efactor*|*[Rr]estructure*|*[Ee]xtract*)    EMOJI="♻️" ;;
      *[Tt]est*)                                        EMOJI="🧪" ;;
      *[Dd]oc*|*README*|*CLAUDE*)                       EMOJI="📝" ;;
      *[Rr]emov*|*[Dd]elet*|*[Cc]lean*)               EMOJI="🗑️" ;;
      *[Uu]pdat*|*[Uu]pgrad*|*[Bb]ump*)               EMOJI="🛠️" ;;
      *)                                                EMOJI="🛠️" ;;
    esac
    ;;
esac

# Replace the first line of the commit message with emoji-prefixed version
NEW_COMMAND=$(echo "$COMMAND" | sed "s|${FIRST_LINE}|${EMOJI} ${FIRST_LINE}|")

# Output the modified command via hook protocol
jq -n --arg cmd "$NEW_COMMAND" --arg emoji "$EMOJI" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "allow",
    permissionDecisionReason: ("Auto-added " + $emoji + " emoji to commit message"),
    updatedInput: {
      command: $cmd
    }
  }
}'
