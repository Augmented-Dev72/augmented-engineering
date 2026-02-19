# Agents

Agents are specialized AI personas that can be spawned on demand via Claude Code's `Task` tool. Each agent has its own system prompt, optional tool access, and domain focus.

## How Agents Differ from Skills

- **Skills** are step-by-step instructions that Claude follows directly in the current conversation.
- **Agents** are separate Claude instances with specialized context and tools, running in their own thread.

Use a **skill** when you want Claude to follow a specific workflow (scaffolding, TDD cycles, reviews). Use an **agent** when you need deep expertise in a domain (debugging a complex issue, reviewing code with specialized knowledge) or when you want parallel execution (multi-perspective code review).

Agents cost zero tokens when not in use — they only consume resources when spawned.

## Template Agents

This template includes two ready-to-customize agents:

### `debug-detective.md`
A senior troubleshooter that takes an investigative approach to debugging. Brings a systematic methodology: evidence gathering, hypothesis testing, scope narrowing. Includes universal investigation patterns (works locally but fails in production, background job issues, data problems, etc.). Customize the toolkit sections with your platform's query commands, log locations, and configuration mechanisms.

### `code-reviewer.md`
A senior engineer conducting thorough code reviews with educational feedback. Categorizes findings (Critical, Quality, Improvement, Positive), always explains "why," and provides concrete examples. Customize the project-specific standards section with your architecture patterns, linting rules, and red flags from production incidents.

## Creating a New Agent

### 1. Create the file

Add a markdown file in this directory: `.claude/agents/<name>.md`

### 2. Add frontmatter

Every agent file starts with YAML frontmatter:

```yaml
---
name: my-agent
description: "Use this agent when... [include usage examples in the description]"
---
```

Optional frontmatter fields:
- `tools`: Comma-separated list of MCP tool names the agent can access
- `model`: Model to use (`opus`, `sonnet`, etc.)
- `color`: Terminal color for the agent's output

### 3. Write the system prompt

The body of the markdown file becomes the agent's system prompt. Include:
- **Persona**: Who the agent is and their expertise
- **Philosophy**: How they approach problems
- **Methodology**: Step-by-step process they follow
- **Project-specific knowledge**: Patterns, tools, and conventions specific to your codebase
- **Response format**: How they structure their output

### 4. Reference from the Task tool

Agents are automatically available to Claude Code's `Task` tool. When the main Claude instance encounters a problem matching an agent's description, it will spawn that agent.

You can also explicitly request an agent: "Use the debug-detective to investigate this error."

## Tips for Effective Agents

1. **Keep agents focused** — One domain, one job. A "do-everything" agent is just a worse version of the main Claude instance.
2. **Give domain expertise** — The value of an agent is specialized knowledge the main instance doesn't carry in context.
3. **Use TODO stubs** — Mark sections that need project-specific customization with `<!-- TODO: ... -->` comments so they're easy to find and fill in.
4. **Include response format** — Structure the agent's output so findings are consistent and actionable.
5. **Add examples to the description** — The description field helps Claude Code decide when to spawn the agent. Include 2-3 concrete usage examples.
6. **Test and iterate** — After using an agent a few times, refine the prompt based on what worked and what didn't. Use `/session-summary` compound steps to capture improvements.
