---
name: session-summary
description: Capture session learnings to .claude/sessions/ for later consolidation
---

Capture learnings from the current session to a timestamped markdown file.

## Current State
- Branch: !`git branch --show-current`
- Latest session files: !`ls -lt .claude/sessions/ 2>/dev/null | head -5 || echo "No session files yet"`

## Steps

1. **Ask for summary scope** — Prompt the user:
   - "What did we learn or discover in this session?"
   - "What gotchas should be documented?"
   - "Any architectural decisions or patterns worth noting?"

2. **Generate filename** — Format: `.claude/sessions/YYYY-MM-DD-HHMM-<topic-slug>.md`
   Create the `.claude/sessions/` directory if it doesn't exist.

3. **Write session file** with this structure:
   ```markdown
   # Session Summary: <Topic>
   **Date:** YYYY-MM-DD
   **Branch:** <branch-name>

   ## What We Did
   - <bullet summary of work done>

   ## Key Learnings
   - <things discovered, gotchas, patterns>

   ## Decisions Made
   - <architectural or design decisions with rationale>

   ## Gotchas & Warnings
   - <things that tripped us up or could trip up future sessions>

   ## Follow-Up Items
   - [ ] <anything that still needs to be done>
   ```

4. **Compound Step** — After writing the session file, evaluate these 4 questions:
   1. "What implicit knowledge was used this session? Should it be encoded in CLAUDE.md or docs?"
   2. "What workflow was repeated manually? Should it become a skill?"
   3. "What quality issue was caught late? Should it become a hook?"
   4. "What agent struggled with something? Should agent instructions be updated?"

   For each question, provide a concrete recommendation or note "N/A" if nothing applies.
   Append the Compound Step section to the session file:
   ```markdown
   ## Compound Engineering Review
   | Question | Finding | Action |
   |----------|---------|--------|
   | Implicit knowledge used? | ... | ... |
   | Manual workflow repeated? | ... | ... |
   | Quality issue caught late? | ... | ... |
   | Agent struggled? | ... | ... |
   ```

5. **Optional: Queue doc update** — If the Compound Step identified CLAUDE.md or doc updates, ask the user if they want to apply them now.

6. **Confirm** — Show path to the session file and remind the user:
   > "Session captured. Run `/consolidate-memory` periodically to promote key learnings to MEMORY.md."
