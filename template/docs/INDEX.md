# Documentation Index

Central registry for all project documentation. Each entry includes a "Load when" hint to help Claude Code (and humans) find the right doc quickly.

## Quick Reference

| Document                                                    | Load When                             | Last Updated  |
| ----------------------------------------------------------- | ------------------------------------- | ------------- |
| [Compound Engineering Guide](compound-engineering-guide.md) | Understanding the development system  | <!-- date --> |
| [Known Gotchas](reference/known-gotchas.md)                 | Encountering platform-specific issues | <!-- date --> |

<!-- TODO: Add project documentation as it grows -->

## Categories

### Reference

- [Known Gotchas](reference/known-gotchas.md) — Platform-specific pitfalls and workarounds

### Architecture

<!-- TODO: Add architecture docs as your system grows -->
<!-- Example: [API Design](architecture/api-design.md) — REST conventions and versioning -->

### Strategic

<!-- TODO: Add strategic docs for long-term planning -->
<!-- Example: [Tech Debt Roadmap](strategic/tech-debt.md) — Prioritized technical debt items -->

## Adding New Documentation

Use the `/new-doc` skill (from superpowers) or create manually:

1. Create the file in the appropriate subdirectory
2. Add metadata header (title, tags, last-updated)
3. Add an entry to this INDEX.md
4. Include "Load when" context so Claude knows when to reference it
