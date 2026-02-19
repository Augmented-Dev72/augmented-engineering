# Skills

Skills are executable workflow instructions that Claude Code follows step-by-step. They encode multi-step processes so that complex workflows are repeatable and consistent.

## How Skills Work

A skill is a markdown file with instructions that Claude loads and follows when invoked with `/skill-name`. Skills can include:
- Step-by-step instructions
- Decision trees and conditionals
- Code templates and patterns
- Quality gates and validation checks
- References to other tools, agents, or commands

## Plugin Skills vs. Project-Local Skills

### Plugin Skills

Skills from installed plugins are available automatically:

**From `compound-engineering`:**
| Skill | Purpose |
|-------|---------|
| `/compound-review` | Multi-perspective parallel code review |
| `/compound-audit` | Monthly system health check |
| `/session-summary` | End-of-session learning capture |
| `/consolidate-memory` | Weekly memory consolidation |

**From `superpowers`:**
| Skill | Purpose |
|-------|---------|
| `/new-doc` | Create new documentation with metadata |
| `/update-docs` | Update existing documentation |
| `/pr` | Create pull requests |
| `/commit` | Guided commit workflow |

### Project-Local Skills

You can create skills specific to your project in this directory.

**Project-local skills override plugin skills with the same name.** This lets you customize plugin workflows for your specific needs — for example, a project-local `/pr` that adds your team's PR template.

## Creating a Project-Local Skill

### 1. Create the directory and file

```
.claude/skills/<skill-name>/SKILL.md
```

### 2. Add frontmatter

```yaml
---
name: skill-name
description: "When to use this skill"
user_invocable: true
---
```

Key frontmatter fields:
- `name`: The `/name` used to invoke the skill
- `description`: Helps Claude decide when to suggest the skill
- `user_invocable`: Set to `true` if users can invoke with `/name`

### 3. Write the instructions

The body is the workflow Claude follows. Use clear, imperative steps:

```markdown
## Steps

1. Read the target file
2. Analyze the current implementation
3. Generate tests following these patterns:
   - One test per public method
   - Test happy path, error cases, and edge cases
4. Write the test file
5. Run the tests and verify they pass
```

### 4. Use load-time commands (optional)

Skills can execute commands at load time to gather context:

```markdown
Current branch: `!git branch --show-current`
Changed files: `!git diff --name-only HEAD~1`
```

Note: Load-time commands must be simple, single operations — no pipes or chained commands.

## What to Encode as Skills

**Good candidates for skills:**
- Multi-step workflows with quality gates (TDD cycles, deploy procedures)
- Scaffolding that must follow exact patterns (new component, new service)
- Review processes with specific checklists
- Data migration or setup procedures

**Poor candidates for skills:**
- One-step operations (just do them directly)
- Pure knowledge reference (put in CLAUDE.md or docs instead)
- Highly variable workflows that change every time

## Tips

1. **Encode workflows, not knowledge** — Skills are for processes with steps. Static reference information belongs in CLAUDE.md files or docs.
2. **Include quality gates** — A skill for writing tests should verify tests actually pass. A skill for deployment should validate before pushing.
3. **Be specific about patterns** — Include exact code templates inline rather than referencing other files. This produces more consistent output.
4. **Test the skill** — Run it a few times and refine based on where Claude deviates or misses steps.
5. **Version control skills** — Skills are code. Review changes, track improvements, and share with the team.
6. **Use the compound step** — When `/session-summary` identifies a workflow you repeated manually, that's a signal to create a skill.
