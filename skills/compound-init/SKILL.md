---
name: compound-init
description: Bootstrap compound engineering in any project — scaffolds CLAUDE.md, agents, docs, and configuration
user_invocable: true
---

Bootstrap compound engineering scaffolding into the current project.

## Template Location

Find the augmented-engineering plugin's template files. Search these locations in order:
1. `~/.claude/plugins/augmented-engineering/template/`
2. Any path matching `*/augmented-engineering/template/CLAUDE.md` found via Glob

Store the resolved template directory path — you'll need it for every file copy below.

## Step 1: Idempotency Check

Read `CLAUDE.md` in the project root (if it exists). If it contains the marker text "About This Documentation", this project has already been initialized.

**If marker found:**
- Warn the user: "This project already has compound engineering scaffolding (found 'About This Documentation' marker in CLAUDE.md). Running again will overwrite existing files."
- Ask: "Overwrite all scaffolding files? (Existing customizations will be lost)"
- If the user declines, stop here.

**If no CLAUDE.md or no marker:** proceed.

## Step 2: Create Directory Structure

Create these directories (skip any that exist):

```
.claude/agents/
.claude/hooks/
.claude/skills/
.claude/sessions/
docs/architecture/
docs/reference/
docs/plans/
docs/strategic/
```

## Step 3: Copy Template Files

Read each file from the plugin's `template/` directory and write it to the corresponding path in the project root. The template directory structure maps directly — `template/CLAUDE.md` becomes `./CLAUDE.md`, `template/.claude/agents/README.md` becomes `./.claude/agents/README.md`, etc.

Copy these files (read from template dir, write to project root):

| Template Source | Project Destination |
|-----------------|---------------------|
| `CLAUDE.md` | `CLAUDE.md` |
| `CLAUDE.local.md.example` | `CLAUDE.local.md.example` |
| `.compound.json` | `.compound.json` |
| `.claude/agents/README.md` | `.claude/agents/README.md` |
| `.claude/agents/debug-detective.md` | `.claude/agents/debug-detective.md` |
| `.claude/agents/code-reviewer.md` | `.claude/agents/code-reviewer.md` |
| `.claude/hooks/README.md` | `.claude/hooks/README.md` |
| `.claude/skills/README.md` | `.claude/skills/README.md` |
| `.claude/sessions/.gitkeep` | `.claude/sessions/.gitkeep` |
| `docs/INDEX.md` | `docs/INDEX.md` |
| `docs/compound-engineering-guide.md` | `docs/compound-engineering-guide.md` |
| `docs/reference/known-gotchas.md` | `docs/reference/known-gotchas.md` |
| `docs/architecture/.gitkeep` | `docs/architecture/.gitkeep` |
| `docs/plans/WorkingMemory.md` | `docs/plans/WorkingMemory.md` |
| `docs/strategic/.gitkeep` | `docs/strategic/.gitkeep` |

**Important:** Do NOT skip the `.gitkeep` files — they ensure empty directories are tracked by git.

## Step 4: Append to .gitignore

Read `template/gitignore-entries` from the plugin's template directory.

- If the project has no `.gitignore`, create one with the full contents of `gitignore-entries`.
- If the project has an existing `.gitignore`, read it and append only lines from `gitignore-entries` that are NOT already present (compare trimmed lines, skip blank lines and comments that already exist). Add a blank line separator before appending.

**Never duplicate existing entries.**

## Step 5: Guide Customization

After scaffolding is complete, present this summary:

```
Compound engineering scaffolding complete! Files created:

  CLAUDE.md                              <- Project rules (start here)
  CLAUDE.local.md.example                <- Personal preferences template
  .compound.json                         <- Hook configuration
  .claude/agents/debug-detective.md      <- Debugging agent
  .claude/agents/code-reviewer.md        <- Code review agent
  docs/compound-engineering-guide.md     <- System guide
  docs/reference/known-gotchas.md        <- Gotcha tracker

Next steps — fill in the TODO stubs:
  1. CLAUDE.md → Project Overview, Development Commands, Project Structure
  2. .compound.json → Update formatter/linter rules for your stack
  3. .claude/agents/*.md → Add platform-specific debugging/review patterns
  4. Copy CLAUDE.local.md.example to CLAUDE.local.md and personalize
```

Then ask: "Want me to help fill in the CLAUDE.md project overview now? I can analyze your codebase and draft it."

If the user accepts, read the project's `package.json`, `Cargo.toml`, `pyproject.toml`, `go.mod`, or equivalent to determine the tech stack, then draft the Project Overview, Development Commands, and Project Structure sections of CLAUDE.md.
