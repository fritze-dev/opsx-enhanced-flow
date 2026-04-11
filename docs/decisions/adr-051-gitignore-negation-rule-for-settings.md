# ADR-051: Gitignore Negation Rule for settings.json

## Status
Accepted (2026-04-11)

## Context
`.gitignore` contains `/.claude/` (now `/.claude/*`) to exclude worktree checkouts, caches, and other generated content from version control. However, `.claude/settings.json` must be committed so that Claude Code Web sessions can read it on clone. Git requires a wildcard pattern (`/.claude/*`) rather than a directory pattern (`/.claude/`) for negation rules to work on contained files.

## Decision
Use a `.gitignore` negation rule `!/.claude/settings.json` with the parent pattern changed from `/.claude/` to `/.claude/*` -- this is the standard git pattern for allowing a single file within an otherwise-ignored directory.

## Alternatives Considered
- **Separate directory outside `.claude/`**: Claude Code only reads settings from `.claude/settings.json` -- no alternative location is supported.

## Consequences

### Positive
- Settings file is version-controlled and available in cloned repos
- All other `.claude/` contents remain ignored (functionally equivalent to the previous `/.claude/` pattern)

### Negative
- The `/.claude/` to `/.claude/*` change is a subtle git pattern difference that may confuse contributors unfamiliar with gitignore negation semantics

## References
- Change: openspec/changes/2026-04-11-claude-code-web-setup/
- Spec: openspec/specs/project-init/spec.md
- Issue: #14
