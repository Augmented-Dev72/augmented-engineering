# augmented-engineering

A Claude Code plugin implementing **[compound engineering](https://every.to/chain-of-thought/compound-engineering-how-every-codes-with-agents)** principles — the practice of making every development session leave your tools, documentation, and automation better than you found them.

> Compound engineering is a methodology developed by [Dan Shipper](https://every.to) and [Kieran Klaassen](https://x.com/kieranklaassen) at [Every](https://every.to). This plugin provides an opinionated tooling implementation of those principles. The skills, hooks, configuration system, and multi-lens review architecture are original work by Brooks Johnson.

Most engineering work generates implicit knowledge that evaporates between sessions: patterns discovered during debugging, architectural decisions made in conversation, workflows repeated manually because nobody wrote them down. Compound engineering captures that knowledge systematically. Each session ends with a structured review that identifies what should be encoded into docs, skills, hooks, or agent instructions — so the next session starts from a higher baseline.

This plugin provides the session management, memory consolidation, code review, and auditing workflows that make compound engineering practical. It extends the [superpowers](https://github.com/anthropics/claude-code-superpowers) plugin with four skills and four hooks.

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) >= 1.0.0
- [superpowers plugin](https://github.com/anthropics/claude-code-superpowers) (peer dependency — provides TDD, debugging, and brainstorming skills)
- `jq` (recommended — required for `.compound.json` config; hooks degrade gracefully without it)

## Installation

### Marketplace install

```bash
# Add the marketplace source
/plugin marketplace add Augmented-Dev72/augmented-engineering

# Install the plugin
/plugin install augmented-engineering@augmented-engineering
```

### Team auto-install

Add to your project's `.claude/settings.json` so teammates get prompted automatically:

```json
{
  "extraKnownMarketplaces": {
    "augmented-engineering": {
      "source": {
        "source": "github",
        "repo": "Augmented-Dev72/augmented-engineering"
      }
    }
  },
  "enabledPlugins": {
    "augmented-engineering@augmented-engineering": true
  }
}
```

### Local development

```bash
# Session-only (no install, great for testing)
claude --plugin-dir ~/augmented-engineering

# Or clone to plugins directory
git clone https://github.com/Augmented-Dev72/augmented-engineering.git ~/.claude/plugins/augmented-engineering
```

## What's Included

### Skills (4)

| Skill              | Command               | Purpose                                                                                              |
| ------------------ | --------------------- | ---------------------------------------------------------------------------------------------------- |
| Session Summary    | `/session-summary`    | Capture learnings to `.claude/sessions/` with a structured compound step review                      |
| Consolidate Memory | `/consolidate-memory` | Weekly promotion of session learnings to `MEMORY.md`, with staleness pruning                         |
| Compound Review    | `/compound-review`    | Multi-perspective code review using 8 specialized lenses (security, performance, architecture, etc.) |
| Compound Audit     | `/compound-audit`     | Monthly system health check — inventory skills, hooks, docs, and identify gaps                       |

### Hooks (4)

| Hook          | Event                      | Purpose                                                                    |
| ------------- | -------------------------- | -------------------------------------------------------------------------- |
| Session Start | `SessionStart`             | Injects compound engineering mindset reminder                              |
| Pre-Commit    | `PreToolUse` (Bash)        | Auto-prepends conventional commit emoji to git commit messages             |
| Post-Edit     | `PostToolUse` (Edit/Write) | Runs formatting, linting, and auto-testing based on `.compound.json` rules |
| Session Stop  | `Stop`                     | Cleans temp files and prunes abandoned git worktrees                       |

## Configuration

The plugin reads project-specific configuration from `.compound.json` in your project root. All configuration is optional — the plugin works out of the box with sensible defaults.

```json
{
  "postEdit": {
    "rules": [
      { "match": "\\.(js|ts)$", "run": "npx prettier --write $FILE" },
      {
        "match": "\\.(js|ts)$",
        "pathMatch": "/src/",
        "run": "npx eslint --fix $FILE"
      },
      { "match": "\\.(py)$", "run": "black $FILE" }
    ],
    "autoTest": {
      "enabled": true,
      "match": "\\.(js|ts)$",
      "excludeMatch": "__tests__|test|spec",
      "testDiscovery": "sibling-dir",
      "testDirName": "__tests__",
      "testSuffix": ".test.js",
      "testCommand": "npx jest --testPathPattern=$TEST_FILE --bail"
    }
  },
  "compoundReview": {
    "baseBranch": "main",
    "lenses": [
      "security",
      "performance",
      "architecture",
      "over-engineering",
      "error-handling",
      "test-quality",
      "data-integrity",
      "maintainability"
    ],
    "lensOverrides": {
      "security": "Also check for: SQL injection via ORM raw queries, JWT validation",
      "performance": "Also check for: missing database indexes, N+1 queries"
    }
  },
  "cleanup": {
    "tempFilePatterns": ["/tmp/compound-*"],
    "pruneWorktrees": true
  }
}
```

### Configuration Reference

#### `postEdit` — Formatting and linting after file edits

| Field                    | Type    | Description                                         |
| ------------------------ | ------- | --------------------------------------------------- |
| `rules[].match`          | regex   | File path pattern to match (applied to full path)   |
| `rules[].pathMatch`      | regex   | Optional additional path filter                     |
| `rules[].run`            | string  | Command to run (`$FILE` replaced with actual path)  |
| `autoTest.enabled`       | boolean | Enable auto-test discovery and execution            |
| `autoTest.match`         | regex   | Which source files trigger auto-testing             |
| `autoTest.excludeMatch`  | regex   | Skip files matching this pattern (e.g., test files) |
| `autoTest.testDiscovery` | enum    | `sibling-dir`, `co-located`, or `custom`            |
| `autoTest.testDirName`   | string  | Test directory name for `sibling-dir` strategy      |
| `autoTest.testSuffix`    | string  | Test file suffix pattern                            |
| `autoTest.testCommand`   | string  | Command to run (`$FILE` and `$TEST_FILE` replaced)  |

#### `compoundReview` — Code review configuration

| Field                  | Type     | Description                                       |
| ---------------------- | -------- | ------------------------------------------------- |
| `baseBranch`           | string   | Branch to diff against (default: `main`)          |
| `lenses`               | string[] | Which review lenses to run (default: all 8)       |
| `lensOverrides.<name>` | string   | Additional instructions appended to a lens prompt |

#### `cleanup` — Session stop cleanup

| Field              | Type     | Description                                                |
| ------------------ | -------- | ---------------------------------------------------------- |
| `tempFilePatterns` | string[] | Glob patterns for temp files to clean (older than 2 hours) |
| `pruneWorktrees`   | boolean  | Auto-prune abandoned git worktrees (default: true)         |

### Environment Variables

| Variable                   | Default | Purpose                                            |
| -------------------------- | ------- | -------------------------------------------------- |
| `COMPOUND_SKIP_PRE_COMMIT` | `0`     | Set to `1` to disable emoji auto-prepend           |
| `COMPOUND_SKIP_POST_EDIT`  | `0`     | Set to `1` to disable post-edit formatting/linting |
| `COMPOUND_CONFIG_PATH`     | —       | Override `.compound.json` location                 |

## Project Template

For a full project setup with `.compound.json`, example CLAUDE.md, session directory structure, and recommended `.gitignore` entries, see the [augmented-engineering-template](https://github.com/Augmented-Dev72/augmented-engineering-template) repo.

## Attribution

This plugin implements [compound engineering](https://every.to/chain-of-thought/compound-engineering-how-every-codes-with-agents), a methodology developed by [Dan Shipper](https://every.to) and [Kieran Klaassen](https://x.com/kieranklaassen) at [Every](https://every.to). Their four-phase loop (Plan → Work → Review → Compound) is the philosophical foundation. The tooling implementation — config-driven hooks, multi-lens parallel review, memory consolidation system, and system auditing — is original work.

## License

MIT
