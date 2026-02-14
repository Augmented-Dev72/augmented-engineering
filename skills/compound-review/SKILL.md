---
name: compound-review
description: Multi-perspective code review using 8 specialized lenses — security, performance, architecture, and more
---

Run a comprehensive multi-perspective code review on the current branch's changes. Each lens examines the code from a different angle, producing findings that go beyond what a single reviewer would catch.

## Configuration

This skill reads from `.compound.json` for project-specific overrides:
```json
{
  "compoundReview": {
    "baseBranch": "main",
    "lenses": ["security", "performance", "architecture", "over-engineering", "error-handling", "test-quality", "data-integrity", "maintainability"],
    "lensOverrides": {
      "security": "Also check for: hardcoded secrets, API keys in source, CORS misconfig",
      "performance": "Also check for: N+1 database queries, missing indexes"
    }
  }
}
```

## Steps

1. **Identify changes** — Determine the base branch and diff:
   - Read `compoundReview.baseBranch` from `.compound.json` (default: `main`)
   - Run `git diff <baseBranch>...HEAD --name-only` to list changed files
   - Run `git diff <baseBranch>...HEAD` to get the full diff
   - If no changes found, inform user and exit

2. **Categorize files** — Group changed files by type/purpose:
   - Source code (business logic, controllers, services)
   - Tests
   - Configuration / infrastructure
   - Documentation
   - Focus review on source code changes; note test gaps for test-quality lens

3. **Run 8 review lenses** — For each lens, read the relevant source files and analyze:

   **Lens 1: Security**
   Review all changed code for security vulnerabilities:
   - Injection attacks (SQL, command, template, XSS, path traversal)
   - Authentication and authorization bypass
   - Sensitive data exposure (logging secrets, insecure storage, PII leaks)
   - Input validation gaps (missing sanitization, type coercion issues)
   - Access control violations (privilege escalation, insecure direct object references)
   - Dependency vulnerabilities (known CVEs in added packages)

   Project-specific additions from `.compound.json` lensOverrides.security (if configured).

   **Lens 2: Performance**
   Review all changed code for performance issues:
   - N+1 query patterns (database calls in loops, unbatched operations)
   - Unbounded loops or recursion (missing limits, potential infinite loops)
   - Excessive memory allocation (large collections, unnecessary copies)
   - Blocking I/O on hot paths (synchronous calls where async is available)
   - Unnecessary computation (redundant calculations, missing early returns)
   - Cache misses and missed memoization opportunities
   - Missing pagination for large data sets

   Project-specific additions from `.compound.json` lensOverrides.performance (if configured).

   **Lens 3: Architecture**
   Review all changed code for architectural issues:
   - Layer separation violations (UI logic in data layer, business logic in controllers)
   - Dependency direction issues (lower layers importing higher layers)
   - Bypassing abstractions (direct access when interface exists)
   - Missing interface or abstraction registrations
   - Tight coupling between modules that should be independent
   - Circular dependencies
   - God objects or classes with too many responsibilities

   Project-specific additions from `.compound.json` lensOverrides.architecture (if configured).

   **Lens 4: Over-Engineering**
   Review all changed code for unnecessary complexity:
   - Premature abstractions (interfaces with single implementation, unused generics)
   - Speculative features (code for requirements that don't exist yet)
   - Unnecessary design patterns (factory for one type, strategy for one algorithm)
   - Configuration where constants would suffice
   - Abstraction layers that add indirection without value
   - Over-parameterized functions (feature flags, options objects for simple operations)

   Project-specific additions from `.compound.json` lensOverrides.over-engineering (if configured).

   **Lens 5: Error Handling**
   Review all changed code for error handling issues:
   - Missing try/catch around operations that can fail (I/O, parsing, external calls)
   - Empty catch blocks (swallowing errors silently)
   - Catch-and-rethrow without adding context
   - Exposing internal error details to users (stack traces, SQL errors)
   - Missing null/undefined checks on external data
   - Inconsistent error response formats
   - Missing error logging or observability

   Project-specific additions from `.compound.json` lensOverrides.error-handling (if configured).

   **Lens 6: Test Quality**
   Review all changed test files AND assess test coverage for changed source:
   - Weak assertions (checking existence but not value, assertTrue without message)
   - Missing negative test cases (only testing happy path)
   - Missing edge cases (empty collections, null inputs, boundary values)
   - Over-mocking (mocking so much that tests don't verify real behavior)
   - Tests that don't assert behavior (setup-only tests, tests with no assertions)
   - Missing bulk/concurrent scenario tests
   - Test-only code in production sources (test hooks, conditional test logic)
   - Changed source files without corresponding test changes

   Project-specific additions from `.compound.json` lensOverrides.test-quality (if configured).

   **Lens 7: Data Integrity**
   Review all changed code for data handling issues:
   - Null safety violations (accessing properties without null checks)
   - Missing default values for optional fields
   - Cascading updates without consistency guarantees
   - Partial failure handling (what happens when step 3 of 5 fails?)
   - Race conditions in concurrent data access
   - Data validation gaps at system boundaries
   - Inconsistent state across related entities

   Project-specific additions from `.compound.json` lensOverrides.data-integrity (if configured).

   **Lens 8: Maintainability**
   Review all changed code for maintainability issues:
   - Unclear or misleading names (variables, functions, classes)
   - Single Responsibility Principle violations
   - High cognitive complexity (deeply nested logic, long methods)
   - Code duplication (similar logic in multiple places)
   - Magic values (unexplained numbers, strings, or booleans)
   - Excessive method or class length
   - Missing or misleading documentation on complex public APIs

   Project-specific additions from `.compound.json` lensOverrides.maintainability (if configured).

4. **Determine which lenses to run** — Check `compoundReview.lenses` in config:
   - If specified, only run the listed lenses
   - If not specified, run all 8 lenses
   - For each lens, load `lensOverrides.<lens-name>` and append to the analysis prompt

5. **Synthesize findings** — After all lenses complete, produce a summary:
   - Group findings by severity: Critical / Warning / Suggestion
   - De-duplicate findings that appear in multiple lenses
   - Highlight cross-cutting concerns (e.g., a security issue that's also a data integrity issue)
   - Provide a 1-paragraph executive summary

6. **Present report** — Format as:
   ```
   ## Compound Review Summary
   **Branch:** <branch> → <base>
   **Files reviewed:** <count>
   **Findings:** <critical> critical, <warning> warnings, <suggestion> suggestions

   ### Critical
   - [Security] File:line — description and recommendation
   ...

   ### Warnings
   ...

   ### Suggestions
   ...

   ### Compound Step
   | Question | Finding |
   |----------|---------|
   | New pattern to document? | ... |
   | Review lens missing? | ... |
   | False positive to suppress? | ... |
   ```
