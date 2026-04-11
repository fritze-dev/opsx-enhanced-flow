# Research: SessionStart Hook Fallback for Plugin Auto-Install

## 1. Current State

The project uses declarative plugin installation via `.claude/settings.json`:
- `extraKnownMarketplaces` registers the GitHub repo as a marketplace source
- `enabledPlugins` declares the plugin for auto-install

This was implemented in the `2026-04-11-claude-code-web-setup` change (ADR-050). The declarative approach was chosen over hook-based `claude plugin install` commands to avoid timing issues.

**Problem**: In Claude Code Web sessions, the declarative approach suffers from a race condition — the marketplace async-fetch completes, but plugin installation from `enabledPlugins` does not trigger. The `installed_plugins.json` remains empty. This is tracked upstream as anthropics/claude-code#10997.

**Current workaround**: The `devcontainer.json` `postCreateCommand` handles this for Codespaces/devcontainer environments, but has no effect in Claude Code Web sessions.

**Affected file**: `.claude/settings.json` (no hooks currently defined)

## 2. External Research

- Claude Code hooks documentation confirms `SessionStart` hooks support a `matcher` field with values: `startup`, `resume`, `clear`, `compact`. Omitting matcher or using `*` fires on all session types.
- The `claude plugin install` command is idempotent — running it when the plugin is already installed is a no-op.
- Upstream issue: anthropics/claude-code#10997 (SessionStart hooks fire before marketplace fetch completes on first run)

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| SessionStart hook with `claude plugin install` | Simple, addresses the gap directly, idempotent | May hit same race condition on very first run; adds hook overhead |
| Do nothing, wait for upstream fix | Zero maintenance | Users continue to hit the issue until upstream fixes |
| Add sleep delay before install | More likely to succeed on first run | Slows every session start unnecessarily |

**Selected**: SessionStart hook without sleep. The `|| true` makes it fail silently if the marketplace isn't ready yet. On second session, the marketplace is cached and the install succeeds.

## 4. Risks & Constraints

- **Race condition on first run**: If the marketplace hasn't been fetched when the hook fires, the install command will fail silently (`|| true`). The user would need to start a second session. This is acceptable — the current state is that it *never* works without manual intervention.
- **ADR-050 tension**: ADR-050 chose declarative over hooks. This hook is a *fallback*, not a replacement. The declarative fields stay. When the upstream bug is fixed, the hook becomes a harmless no-op.
- **No spec-level changes needed**: This is a configuration-only fix to `.claude/settings.json`. No existing spec requirements are affected.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Single file change: `.claude/settings.json` |
| Behavior | Clear | Hook runs `claude plugin install` on startup |
| Data Model | Clear | N/A — no data model changes |
| UX | Clear | Transparent to user; plugin becomes available |
| Integration | Clear | Uses existing Claude Code hooks system |
| Edge Cases | Clear | First-run race condition accepted; `|| true` handles failures |
| Constraints | Clear | Must not break existing declarative fields |
| Terminology | Clear | Standard Claude Code hooks terminology |
| Non-Functional | Clear | Minimal overhead — one command on startup |

## 6. Open Questions

All categories Clear — no questions needed.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Use `matcher: "startup"` (new sessions only) | Plugin persists across resume/clear/compact — no need to reinstall | Omitting matcher (fires on all session types) |
| 2 | No sleep delay | Keeps session start fast; second session succeeds since marketplace is cached | `sleep 2` before install command |
| 3 | Keep as fallback alongside declarative fields | Declarative is the correct long-term approach; hook is a workaround for upstream bug | Replace declarative with hook-only approach |
