---
name: compound-audit
description: Monthly system health check — inventory skills, hooks, agents, docs, and identify gaps
---

Perform a comprehensive audit of your compound engineering system. Run monthly to ensure your tools, documentation, and automation stay healthy and complete.

## Steps

1. **Inventory current assets** — Catalog what exists:

   | Category | What to Count | Where to Look |
   |----------|--------------|---------------|
   | Skills | Skill files | `skills/*/SKILL.md`, plugin skill dirs |
   | Hooks | Hook scripts | `hooks/`, `.claude/hooks/` |
   | Agents | Agent definitions | `.claude/agents/` |
   | CLAUDE.md files | Project instructions | `**/CLAUDE.md` |
   | Documentation | Reference docs | `docs/`, `README.md` |
   | Memory entries | Persistent learnings | `MEMORY.md` |
   | Session files | Unconsolidated sessions | `.claude/sessions/` |
   | MCP servers | Tool integrations | `.mcp.json` |
   | Config | Compound config | `.compound.json` |

2. **Health checks** — For each category, assess:

   **Skills:**
   - Does each skill have a clear description in frontmatter?
   - Are there workflows that are repeatedly done manually but have no skill?
   - Do any skills reference stale file paths or tools?

   **Hooks:**
   - Are all hooks executable (`chmod +x`)?
   - Do hooks degrade gracefully when dependencies are missing?
   - Are there quality checks that are done manually but could be automated?

   **Agents:**
   - Do agent definitions match current project structure?
   - Are there specialized tasks that would benefit from a dedicated agent?
   - Do agents have appropriate tool access?

   **Documentation:**
   - Is CLAUDE.md under 200 lines?
   - Are subdirectory CLAUDE.md files up to date with current patterns?
   - Is there a docs index or navigation aid?
   - Are there undocumented conventions that team members rely on?

   **Memory:**
   - Are there stale MEMORY.md entries (> 3 months without validation)?
   - Are there unconsolidated session files waiting to be processed?
   - Is MEMORY.md approaching its line limit?

3. **Gap analysis** — Identify what's missing:

   Search for indicators of missing compound engineering:
   - `TODO` and `FIXME` comments in source code
   - Repeated patterns that could be abstracted into utilities or skills
   - Test coverage gaps (source files without corresponding test files)
   - Error handling inconsistencies across the codebase
   - Configuration scattered across multiple files vs. centralized

4. **Compound engineering score** — Rate the system (1-10) on:
   - **Documentation completeness**: Are decisions and patterns captured?
   - **Automation maturity**: Are repetitive tasks automated via skills/hooks?
   - **Test coverage**: Do source files have corresponding tests?
   - **Memory hygiene**: Is MEMORY.md lean, current, and useful?
   - **Consistency**: Do similar components follow the same patterns?

5. **Recommendations** — Prioritize improvements:
   - **Quick wins** (< 30 min): Fix broken hooks, update stale docs, add missing test files
   - **Medium effort** (1-2 hours): Create new skills for repeated workflows, add missing hooks
   - **Strategic** (half day+): Restructure documentation, add new agent specializations

6. **Generate report** — Write to `.claude/sessions/YYYY-MM-DD-compound-audit.md`:
   ```markdown
   # Compound Engineering Audit
   **Date:** YYYY-MM-DD
   **Score:** X/10

   ## Inventory
   | Category | Count | Status |
   |----------|-------|--------|
   | Skills | N | healthy/stale/missing |
   ...

   ## Health Check Findings
   ...

   ## Gap Analysis
   ...

   ## Recommendations
   ### Quick Wins
   - [ ] ...
   ### Medium Effort
   - [ ] ...
   ### Strategic
   - [ ] ...

   ## Next Audit
   Recommended: YYYY-MM-DD (one month from now)
   ```

7. **Confirm** — Show the audit report path and highlight the top 3 recommendations.
