#!/bin/bash
# Compound Engineering — SessionStart hook
# Injects compound engineering context at session start.

cat <<'CONTEXT'
Compound Engineering is active. At session end, run /session-summary to capture learnings and check for compound improvements:
1. Implicit knowledge used → encode in CLAUDE.md or docs
2. Workflow repeated manually → consider making it a skill
3. Quality issue caught late → consider adding a hook
4. Agent struggled → update agent instructions
CONTEXT

exit 0
