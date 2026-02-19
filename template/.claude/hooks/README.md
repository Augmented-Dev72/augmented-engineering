# Hooks

Hooks are shell scripts that run automatically in response to Claude Code lifecycle events. Unlike prompt instructions (which the AI _might_ follow), hooks are deterministic — they always execute.

## The Hook Philosophy

**If a rule can be enforced deterministically, make it a hook. If it requires judgment, make it a skill or agent instruction.**

- Hooks are for **mechanical rules**: formatting, linting, commit message validation, file cleanup.
- Skills are for **workflows that need reasoning**: TDD cycles, code review, documentation authoring.
- Agent instructions are for **domain expertise**: debugging strategies, architecture decisions.

## Plugin Hooks vs. Project-Local Hooks

### Plugin Hooks (from compound-engineering)

The `compound-engineering` plugin provides generic hooks that work across any project:

| Hook | Type | What It Does |
|------|------|--------------|
| Emoji commit | PreToolUse (Bash) | Auto-prepends the correct emoji to conventional commit messages |
| Post-edit | PostToolUse (Edit/Write) | Runs formatters, linters, and auto-tests based on `.compound.json` rules |
| Audio alert | Notification | Plays a sound when Claude needs your attention |
| Session cleanup | Stop | Cleans temp files and prunes git worktrees |

Plugin hooks are configured in the plugin's `hooks.json` and apply automatically when the plugin is installed.

### Project-Local Hooks

You can add hooks specific to your project by creating a `.claude/hooks.json` file:

```json
[
  {
    "type": "PostToolUse",
    "matcher": {
      "tool_name": "Edit",
      "file_pattern": "*.py"
    },
    "command": "black $FILE && mypy $FILE"
  }
]
```

Project-local hooks run in addition to plugin hooks. They're checked into version control so the whole team benefits.

## Hook Types

### PreToolUse
Runs **before** a tool executes. Can modify or validate the tool call.

**Use cases**: Commit message formatting, validating file paths, preventing destructive operations.

```json
{
  "type": "PreToolUse",
  "matcher": { "tool_name": "Bash" },
  "command": "./scripts/validate-bash-command.sh"
}
```

### PostToolUse
Runs **after** a tool completes. Receives the tool result.

**Use cases**: Auto-formatting after edits, running linters, executing related tests.

```json
{
  "type": "PostToolUse",
  "matcher": {
    "tool_name": "Edit",
    "file_pattern": "*.ts"
  },
  "command": "npx prettier --write $FILE && npx eslint --fix $FILE"
}
```

### Notification
Runs when Claude Code shows a permission prompt or needs attention.

**Use cases**: Audio alerts, desktop notifications, Slack messages.

```json
{
  "type": "Notification",
  "command": "afplay /System/Library/Sounds/Ping.aiff"
}
```

### Stop
Runs when a Claude Code session ends.

**Use cases**: Cleaning temp files, pruning worktrees, archiving session state.

```json
{
  "type": "Stop",
  "command": "./scripts/session-cleanup.sh"
}
```

### SessionStart
Runs when a new Claude Code session begins.

**Use cases**: Environment setup, state initialization, dependency checks.

```json
{
  "type": "SessionStart",
  "command": "./scripts/session-init.sh"
}
```

## Adding a Project-Local Hook

1. Create `.claude/hooks.json` if it doesn't exist (or add to the existing array)
2. Define the hook type, matcher, and command
3. Test the hook by triggering the matched event
4. Commit to version control

## Environment Variables in Hooks

Hooks receive context via environment variables:

| Variable | Available In | Description |
|----------|-------------|-------------|
| `$FILE` | PostToolUse (Edit/Write) | Path to the file that was edited |
| `$TOOL_NAME` | All | Name of the tool that triggered the hook |

## Tips

- Keep hook scripts fast — they block the AI while running
- Use `.compound.json` `postEdit.rules` for the common case of format-on-save, and reserve `hooks.json` for more complex logic
- Test hooks manually before relying on them (`bash ./scripts/my-hook.sh`)
- If a hook fails, Claude Code sees the error output — this can be used intentionally to surface issues (e.g., linter violations)
