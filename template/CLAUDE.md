# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

## About This Documentation

- **This File (CLAUDE.md)**: Universal project rules loaded for every interaction
- **Subdirectory CLAUDE.md files**: Context-specific patterns loaded automatically when working in those directories
- **docs/ Directory**: Deep-dive documentation (architecture, gotchas, business context)
- **Skills**: On-demand workflows via `/skill-name`

## Project Overview

<!-- TODO: Describe your project in 2-3 sentences -->
<!-- Example: "Node.js API for managing user subscriptions. Uses Express, PostgreSQL, and Redis." -->

## Development Commands

<!-- TODO: List your key development commands -->

```bash
# npm install                  # Install dependencies
# npm run lint                 # Lint code
# npm run test                 # Run tests
# npm run build                # Build project
```

## Project Structure

<!-- TODO: Map your directory structure -->
<!-- Example:
- **src/** — Source code
  - **controllers/** — Request handlers
  - **services/** — Business logic
  - **models/** — Data models
  - **middleware/** — Express middleware
- **tests/** — Test files
- **docs/** — Documentation
-->

## Naming Conventions

<!-- TODO: Document your naming patterns -->
<!-- Example:
- **Files**: kebab-case (e.g., `user-service.ts`)
- **Classes**: PascalCase (e.g., `UserService`)
- **Functions**: camelCase (e.g., `getUserById`)
- **Constants**: UPPER_SNAKE_CASE (e.g., `MAX_RETRY_COUNT`)
- **Test files**: `*.test.ts` or `*.spec.ts`
-->

## Architecture Quick Reference

<!-- TODO: Describe your architecture patterns -->
<!-- Example:
### Layered Architecture
- **Controller Layer**: HTTP handling, input validation
- **Service Layer**: Business logic, orchestration
- **Repository Layer**: Data access, queries
- **Domain Layer**: Entities, value objects
-->

## Core Rules

### Before Making Changes

1. Check existing patterns in similar files
2. Review imports and dependencies in neighboring files
3. Follow existing naming conventions and code style
4. Ensure new code has corresponding test coverage
<!-- TODO: Add project-specific rules -->

### Code Style

- Keep methods short, single-responsibility
- Descriptive naming over comments — code should be self-documenting
- Use JSDoc/docstrings for public APIs and complex logic only
- Extract complex logic into well-named private methods

### Anti-Patterns to Avoid

1. Hardcoded values — use constants or configuration
2. Empty catch blocks — always log or handle errors
3. Logic duplication — extract shared code
4. God classes/functions — keep responsibilities focused
5. Untested code paths — write tests for edge cases
<!-- TODO: Add project-specific anti-patterns -->

### Testing Requirements

- Tests for all new code
- Test positive, negative, and edge cases
- Mock external dependencies
- Keep tests focused on behavior, not implementation
<!-- TODO: Specify minimum coverage, test frameworks, patterns -->

## Git Guidelines

- Concise commit messages (1-2 sentences) focusing on "why" not "what"
- Feature branches off `main` (or your default branch)
- **Worktrees**: Place at `~/.claude-worktrees/<project>/<branch>`, never inside the repo

### Commit Message Format

Use **emoji + conventional commit** format:

| Emoji | Prefix      | When to Use                             |
| ----- | ----------- | --------------------------------------- |
| ✨    | `feat:`     | New feature or capability               |
| 🐛    | `fix:`      | Bug fix                                 |
| ♻️    | `refactor:` | Code restructuring (no behavior change) |
| 🧪    | `test:`     | Adding or updating tests                |
| 📝    | `docs:`     | Documentation changes                   |
| 🛠️    | `chore:`    | Build, config, tooling, dependencies    |
| 🎨    | `style:`    | UI/UX polish, formatting, CSS           |
| ⚡    | `perf:`     | Performance improvement                 |
| 🗑️    | `remove:`   | Removing code or files                  |

**Format**: `<emoji> <type>(<optional-scope>): <description>`

## Documentation Index

| Resource                                                                 | Content                     | When to Use               |
| ------------------------------------------------------------------------ | --------------------------- | ------------------------- |
| [docs/INDEX.md](docs/INDEX.md)                                           | Central doc registry        | Finding relevant docs     |
| [docs/compound-engineering-guide.md](docs/compound-engineering-guide.md) | System philosophy and usage | Understanding the tooling |
| [docs/reference/known-gotchas.md](docs/reference/known-gotchas.md)       | Platform-specific pitfalls  | Avoiding known issues     |

<!-- TODO: Add project-specific documentation links -->
