# Compound Engineering Guide

A human-readable guide to the AI-assisted development system. Written for developers joining a project or anyone wanting to understand why the tooling exists and how to get the most out of it.

- **Audience**: Humans, not AI. Clear prose, not terse context instructions.
- **Last updated**: 2026-02-14
- **Tags**: compound-engineering, onboarding, system-overview, skills, hooks, agents

---

## What Is Compound Engineering?

Compound engineering is the practice of making every development cycle leave the codebase — and the tools around it — better than you found it. The idea is simple: instead of treating AI-assisted development as "type prompt, get code," you invest a small amount of time after each task to encode what you learned back into the system.

Over time, these small investments compound:

- A gotcha you document today saves 30 minutes in every future session that encounters it.
- A scaffold skill you create today saves an hour for every new module of that type.
- A hook you add today catches a class of bugs automatically, forever.
- An agent prompt you refine today produces better code in every future invocation.

The system follows a four-phase loop:

```
Plan  ->  Work  ->  Review  ->  Compound
  |                                |
  +--------------------------------+
        (each cycle feeds the next)
```

**Plan**: Load context from CLAUDE.md files, docs, and memory. Understand existing patterns before writing code.

**Work**: Use skills, agents, and hooks to develop with guardrails. The system catches formatting issues, runs linters, and can execute tests — all automatically.

**Review**: Run `/compound-review` for a multi-perspective parallel review that examines your changes through 8 lenses simultaneously.

**Compound**: Run `/session-summary` at session end. It asks four questions that identify opportunities to encode knowledge, create skills, add hooks, or improve agents.

The goal is that 80% of the "effort" in a session isn't writing code — it's the system doing work for you because someone encoded the right patterns at the right time.

---

## The CLAUDE.md Hierarchy

Claude Code reads `CLAUDE.md` files as context instructions. This system uses a multi-file hierarchy with **progressive disclosure** — each file loads only when you're working in its directory.

### Root CLAUDE.md

**Location**: `/CLAUDE.md`
**Loads**: Every session, always.

Contains universal rules: project overview, directory structure, naming conventions, core coding rules, complexity limits, git guidelines, and the documentation index pointer.

This file should be deliberately lean — aim for 100-200 lines. Everything specific to a subdomain should be moved to subdirectory files.

### Subdirectory CLAUDE.md Files

**Location**: `<any-directory>/CLAUDE.md`
**Loads**: When working on files in that directory.

Contains domain-specific patterns, conventions, and examples relevant to that directory's code. For example:

<!-- TODO: Replace these examples with your actual subdirectory CLAUDE.md files -->
<!-- Example:
- `src/api/CLAUDE.md` — API conventions, middleware patterns, route structure
- `src/models/CLAUDE.md` — ORM patterns, migration conventions, validation rules
- `tests/CLAUDE.md` — Test utilities, fixture patterns, assertion helpers
-->

### Why This Structure Matters

A flat, monolithic CLAUDE.md wastes context tokens on irrelevant instructions. When you're writing tests, you don't need API middleware patterns. When you're debugging a database query, you don't need frontend component documentation.

Progressive disclosure means each session loads only what's relevant, keeping the AI focused and reducing hallucination from context overload.

---

## Skills Catalog

Skills are executable workflows. Invoke them with `/skill-name` in the Claude Code CLI. Each skill is a markdown file with instructions that Claude follows step-by-step.

### Plugin Skills (from compound-engineering)

| Skill                 | Purpose                                            | When to Use                             |
| --------------------- | -------------------------------------------------- | --------------------------------------- |
| `/compound-review`    | Multi-perspective parallel code review (8 lenses)  | After feature completion, before PR     |
| `/session-summary`    | Capture learnings + compound engineering checklist | End of every coding session             |
| `/consolidate-memory` | Weekly memory consolidation                        | Weekly hygiene (promotes session notes) |
| `/compound-audit`     | Monthly system health check                        | Monthly hygiene                         |

### Plugin Skills (from superpowers)

| Skill          | Purpose                                | When to Use                          |
| -------------- | -------------------------------------- | ------------------------------------ |
| `/new-doc`     | Create new documentation with metadata | Documenting a new feature or pattern |
| `/update-docs` | Update existing documentation          | When docs need new information       |
| `/pr`          | Create pull request                    | Feature complete, ready for review   |
| `/commit`      | Guided commit workflow                 | Ready to commit changes              |

### Project-Local Skills

<!-- TODO: Add your project-specific skills as you create them -->
<!-- Example:
| Skill | Purpose | When to Use |
|-------|---------|-------------|
| `/scaffold-service` | Generate service + repository + test | Adding a new service |
| `/tdd` | Red-Green-Refactor TDD cycle | Before writing production code |
| `/deploy` | Deploy to environment | After code changes are validated |
-->

### Why Skills Exist

A skill encodes a workflow that would otherwise depend on the developer (or AI) remembering every step. Without a TDD skill, an AI agent might write production code first and tests second — or skip the test verification step entirely. The skill makes the correct workflow deterministic.

Skills are also versioned in git, so improvements benefit every developer and every AI session. When you discover a better testing pattern, updating the skill propagates it everywhere.

---

## Hooks Explained

Hooks are shell scripts that run automatically in response to Claude Code lifecycle events. Unlike prompt instructions (which the AI _might_ follow), hooks are deterministic — they always execute.

### Plugin Hooks (from compound-engineering)

The plugin provides four hooks that work across any project:

**PreToolUse: Emoji Commit Hook**
Intercepts `git commit` commands and auto-prepends the correct emoji based on the conventional commit prefix (`feat:` to a sparkle, `fix:` to a bug, etc.).

**PostToolUse: Format + Lint + Test**
After every file edit, routes the file through formatters and linters configured in `.compound.json`. Can optionally auto-run the nearest test file.

**Notification: Audio Alert**
Plays a system sound when Claude Code shows a permission prompt, so you hear it even if the terminal isn't visible.

**Stop: Session Cleanup**
Cleans temp files and prunes abandoned git worktrees when a session ends.

### Project-Local Hooks

You can add project-specific hooks in `.claude/hooks.json`. See the [hooks README](.claude/hooks/README.md) for details.

### The Hook Philosophy

The general principle: **if a rule can be enforced deterministically, make it a hook. If it requires judgment, make it a skill or agent instruction.**

Hooks are for mechanical rules. Skills are for workflows that need reasoning. Agent instructions are for domain expertise.

---

## Agent Architecture

Agents are specialized AI personas that can be spawned on demand via the `Task` tool. Each agent has its own system prompt and domain focus. They cost zero tokens when not in use.

### Template Agents

This template includes two agents ready to customize:

| Agent             | Focus                                          | When to Spawn             |
| ----------------- | ---------------------------------------------- | ------------------------- |
| `debug-detective` | Bug investigation, root cause analysis         | "Why isn't this working?" |
| `code-reviewer`   | Thorough code review with educational feedback | Pre-PR quality check      |

<!-- TODO: Add project-specific agents as you create them -->
<!-- Example:
| `backend-expert` | API development, database patterns | Writing backend code |
| `devops-engineer` | CI/CD, deployment, infrastructure | Pipeline and deployment work |
| `frontend-expert` | Component development, state management | Building UI |
-->

### How Agents Differ from Skills

- **Skills** are step-by-step instructions that Claude follows directly.
- **Agents** are separate Claude instances with specialized context and tools.

Use a skill when you want Claude to follow a specific workflow (TDD, scaffolding). Use an agent when you need deep expertise in a domain (debugging a complex race condition) or parallel execution (multi-perspective code review).

### The Compound Review Pattern

The `/compound-review` skill demonstrates the agent architecture's power: it spawns multiple code reviewer agents in parallel, each evaluating changes through a single lens (security, performance, architecture, over-engineering, error handling, test quality, data integrity, maintainability). Each agent gets the full file contents and a narrowly scoped prompt, ensuring deep focus without context-switching. Results are de-duplicated and synthesized into a prioritized report.

This costs roughly the same wall-clock time as a single reviewer, but covers 8x the surface area.

---

## Memory System

The memory system has three tiers, each with a different lifecycle:

### MEMORY.md (Permanent, Always Loaded)

**Location**: `~/.claude/projects/<project>/memory/MEMORY.md`
**Loads**: Every session, automatically (first 200 lines)

Contains stable patterns confirmed across multiple sessions: key architectural decisions, incident learnings, environment setup procedures, known gotchas that affect every session. This is the most expensive memory (it's always in context), so it's kept lean and high-signal.

### Session Summaries (Temporary, Per-Session)

**Location**: `.claude/sessions/YYYY-MM-DD-HHMM-<topic>.md`
**Created by**: `/session-summary`

Captures what was learned in a single session. These files accumulate over time and are reviewed weekly via `/consolidate-memory`. Patterns that appear in multiple sessions get promoted to MEMORY.md or permanent docs.

### Weekly Consolidation

**Invoked by**: `/consolidate-memory` (run weekly)

Reviews session files from the past 2 weeks. Identifies recurring patterns and promotes them to permanent documentation. Archives old session files. This prevents MEMORY.md from growing unbounded while ensuring important learnings aren't lost.

### The Compound Step

Built into `/session-summary`, the compound step is a 4-question checklist run after every session:

1. **What implicit knowledge was used?** — Encode in CLAUDE.md or docs
2. **What workflow was repeated manually?** — Consider creating a skill
3. **What quality issue was caught late?** — Consider adding a hook
4. **What agent struggled?** — Update agent instructions

This checklist is the compounding flywheel. Without it, improvements are ad-hoc and eventually plateau. With it, every session has a structured opportunity to make the next one better.

---

## How to Take Advantage

### If You Just Set Up This Template

1. **Read the root CLAUDE.md** — fill in the TODO stubs with your project's specifics.
2. **Browse the skills list** — type `/` in Claude Code to see available skills. Start with `/compound-review` and `/session-summary`.
3. **Customize the agent templates** — fill in the TODO sections in `debug-detective.md` and `code-reviewer.md` with your platform's patterns.
4. **Read `docs/reference/known-gotchas.md`** — start adding gotchas as you discover them.

### During Development

1. **Let the hooks work** — don't manually run formatters or linters. The PostToolUse hook handles it via `.compound.json` rules.
2. **Use agents for hard problems** — debugging a complex issue? Spawn `debug-detective`. Want a quality check? Spawn `code-reviewer`.
3. **Run `/compound-review` before PRs** — 8 perspectives catch things a single reviewer misses.
4. **Create skills for repeated workflows** — if you find yourself describing the same multi-step process more than twice, it's a skill.

### After Development

1. **Run `/session-summary`** — it captures learnings and runs the compound step.
2. **Act on compound step findings** — if you discovered a gotcha, add it to `known-gotchas.md`. If you repeated a workflow, consider a new skill.
3. **Run `/consolidate-memory` weekly** — promotes session learnings to permanent docs.

### How to Contribute Back

The system improves only when people add to it. Here's how:

- **Found a gotcha?** Add it to `docs/reference/known-gotchas.md`
- **Created a new pattern?** Update the relevant CLAUDE.md file
- **Automated a workflow?** Create a skill in `.claude/skills/<name>/SKILL.md`
- **Caught a class of bugs?** Add a hook in `.claude/hooks/`
- **Need a specialized AI?** Create an agent in `.claude/agents/<name>.md`

Every contribution compounds. A skill you write today will be used in hundreds of future sessions.

---

## System Inventory

<!-- TODO: Fill in your system's actual inventory as it grows -->

| Component       | Count   | Key Items                                                                   |
| --------------- | ------- | --------------------------------------------------------------------------- |
| CLAUDE.md files | 1       | root (add subdirectory files as your project grows)                         |
| Skills          | 0 local | Plugin skills: compound-review, session-summary, consolidate-memory, etc.   |
| Hooks           | 0 local | Plugin hooks: emoji commit, format-on-edit, audio alert, session cleanup    |
| Agents          | 2       | debug-detective, code-reviewer                                              |
| MCP Servers     | 0       | <!-- TODO: Add your MCP servers here -->                                    |
| Documentation   | 4       | INDEX.md, compound-engineering-guide.md, known-gotchas.md, WorkingMemory.md |
| Memory entries  | 0       | MEMORY.md starts empty — grows with each `/session-summary`                 |

---

## Further Reading

- [Documentation Index](INDEX.md) — Central hub for all docs with "load when" metadata
- [Known Gotchas](reference/known-gotchas.md) — Platform-specific pitfalls (add yours here)
- [Root CLAUDE.md](../CLAUDE.md) — Universal project rules
- [Agent Guide](../.claude/agents/README.md) — Creating and customizing agents
- [Skills Guide](../.claude/skills/README.md) — Creating project-local skills
- [Hooks Guide](../.claude/hooks/README.md) — Hook types and configuration
