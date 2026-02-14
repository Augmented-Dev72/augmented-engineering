---
name: consolidate-memory
description: Weekly memory consolidation — promote session learnings to MEMORY.md and prune stale entries
---

Consolidate session files into permanent memory entries. Run this weekly (or when `.claude/sessions/` accumulates 5+ files).

## Current State
- Session files: !`ls -lt .claude/sessions/ 2>/dev/null | head -10 || echo "No session files"`

## Steps

1. **Inventory sessions** — Read all files in `.claude/sessions/`. For each file, extract:
   - Date and topic
   - Key learnings
   - Compound Step findings
   - Follow-up items

2. **Cross-reference with MEMORY.md** — Check which learnings are already captured and which are new. Look for:
   - Duplicate information (already in MEMORY.md)
   - Contradictions (session learning conflicts with existing memory)
   - Patterns (same learning appears in multiple sessions)

3. **Draft MEMORY.md updates** — For each new learning that appeared in 2+ sessions or was flagged as important:
   - Write a concise entry (2-3 lines max)
   - Group under the appropriate topic heading
   - Include a date stamp for freshness tracking

4. **Review stale entries** — Check existing MEMORY.md entries for:
   - Entries older than 3 months that haven't been validated recently
   - Entries that contradict new session learnings
   - Entries that are too verbose (compress them)

5. **Present changes to user** — Show a diff-style summary:
   - New entries to add
   - Existing entries to update
   - Stale entries to remove
   - Current line count vs. limit (keep MEMORY.md under 200 lines)

6. **Apply approved changes** — Update MEMORY.md with user-approved edits only.

7. **Archive processed sessions** — Move consolidated session files to `.claude/sessions/archived/` (create dir if needed). Do NOT delete them — they're the audit trail.

8. **Report** — Summarize what was consolidated:
   - Sessions processed
   - Entries added/updated/removed
   - Current MEMORY.md line count
   - Next consolidation recommended date
