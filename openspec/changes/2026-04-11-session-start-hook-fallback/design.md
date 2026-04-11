<!--
---
has_decisions: true
---
-->
# Technical Design: SessionStart Hook Fallback

## Context

The declarative plugin install via `enabledPlugins` in `.claude/settings.json` fails in Claude Code Web due to a race condition (anthropics/claude-code#10997). A SessionStart hook provides a fallback mechanism until the upstream fix is available.

Current `.claude/settings.json` has only `extraKnownMarketplaces` and `enabledPlugins` — no hooks.

## Architecture & Components

Single file change:
- **`.claude/settings.json`** — add `hooks.SessionStart` array with one entry

No other files affected. No spec or skill changes.

## Goals & Success Metrics

* `.claude/settings.json` is valid JSON after the change — PASS/FAIL via `jq .`
* Plugin auto-installs in Claude Code Web sessions — PASS/FAIL via manual test
* Existing declarative fields preserved — PASS/FAIL via content inspection

## Non-Goals

- Fixing the upstream race condition in Claude Code
- Guaranteeing first-run success (if marketplace hasn't been fetched yet, the hook fails silently)
- Modifying `devcontainer.json` (already works for Codespaces)

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Use `matcher: "startup"` | Plugin persists across resume/clear/compact — only new sessions need the install | No matcher (fires on all session types — unnecessary overhead) |
| No sleep delay | Keeps session start fast; second session succeeds since marketplace is cached | `sleep 2` before install (slows every session) |
| Fallback alongside declarative | Declarative is correct long-term; hook is temporary workaround for upstream bug | Replace declarative with hook-only (loses the correct approach) |

## Risks & Trade-offs

- [First-run race condition persists] → Mitigation: `|| true` ensures silent failure; second session succeeds since marketplace is cached after first fetch
- [ADR-050 tension] → Mitigation: Hook is explicitly a fallback, declarative fields remain primary; when upstream fixes the bug, hook becomes a harmless no-op

## Open Questions

No open questions.

## Assumptions

- The `claude plugin install` command is idempotent and returns success when the plugin is already installed. <!-- ASSUMPTION: idempotent-install -->
- SessionStart hooks with `matcher: "startup"` fire on new Claude Code Web sessions. <!-- ASSUMPTION: web-session-startup-matcher -->
