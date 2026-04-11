# ADR-051: Gate on CLAUDE_CODE_REMOTE Environment Variable

## Status
Accepted (2026-04-11)

## Context
The setup script installs `gh` via `apt`, which should only run in Claude Code Web cloud sessions -- not locally or in Codespaces (where `gh` is pre-installed via devcontainer features). A reliable gate mechanism is needed to prevent unnecessary execution.

## Decision
Gate script execution on `CLAUDE_CODE_REMOTE=true`, the official environment variable set by Claude Code Web cloud sessions. The script exits 0 immediately when this variable is not set, making it a no-op in local and Codespaces environments.

## Alternatives Considered
- **No gate, just check `command -v gh`**: Would attempt `apt install` in Codespaces too (where gh is already installed via devcontainer but the check might race with setup). The environment variable is a cleaner signal of the execution context.

## Consequences

### Positive
- Clean environment detection with no false positives
- Script is harmless (exit 0) in non-cloud environments

### Negative
- Depends on Claude Code Web continuing to set `CLAUDE_CODE_REMOTE=true`

## References
- Change: openspec/changes/2026-04-11-claude-code-web-setup/
- Spec: openspec/specs/project-init/spec.md
- Issue: #14
