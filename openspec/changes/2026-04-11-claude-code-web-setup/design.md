<!--
---
has_decisions: true
---
-->
# Technical Design: Claude Code Web Setup

## Context

The plugin needs to work in Claude Code Web (claude.ai/code) cloud sessions. The devcontainer handles Codespaces but Claude Code Web uses a universal image where devcontainer features don't apply. Cloud sessions clone the repo from GitHub and read `.claude/settings.json` for hooks and plugin declarations.

Key constraint: `.gitignore` contains `/.claude/` which blocks `.claude/settings.json` from being committed. This must be fixed first.

## Architecture & Components

**Files created (this change — for the plugin project itself):**

| File | Purpose |
|------|---------|
| `.claude/settings.json` | Marketplace + plugin declaration, SessionStart hook |
| `scripts/setup-remote.sh` | `gh` CLI installation, gated on `CLAUDE_CODE_REMOTE` |

**Files modified:**

| File | Change |
|------|--------|
| `.gitignore` | Add `!/.claude/settings.json` negation |
| `README.md` | Claude Code Web documentation section |
| `openspec/specs/project-init/spec.md` | New requirement for settings generation during init |

**Spec change (for consumer projects via init):**

The init skill will generate `.claude/settings.json` and `scripts/setup-remote.sh` for consumer projects. The generated content follows the same pattern but uses the consumer's marketplace reference (`fritze-dev/opsx-enhanced-flow` on GitHub) instead of a self-referential local path.

**No changes to:**
- `src/skills/workflow/SKILL.md` (runtime behavior unchanged)
- `src/templates/` (no template additions — settings.json is not a Smart Template)
- `.devcontainer/devcontainer.json` (continues to work as-is)

## Goals & Success Metrics

- Plugin auto-installs in Claude Code Web session (verified by `/opsx:workflow` responding)
- `gh` CLI available after SessionStart hook (verified by `gh --version`)
- `gh auth status` succeeds when `GH_TOKEN` is configured
- Script is a no-op in local/Codespaces environments (exits immediately)
- `.claude/settings.json` is tracked by git despite `/.claude/` in `.gitignore`

## Non-Goals

- Replacing `gh pr create --draft` with built-in GitHub tools
- Auto-configuring `GH_TOKEN` (user's responsibility in environment settings)
- Modifying devcontainer setup
- Adding Claude Code Web-specific runtime behavior to the plugin

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Declarative plugin install via `extraKnownMarketplaces` + `enabledPlugins` | Follows docs pattern, no script needed, auto-installs at session start | `claude plugin` commands in SessionStart hook (timing issues, more fragile) |
| `gh` CLI as optional user-configured dependency | User configures in their own Environment settings (setup script + GH_TOKEN). Keeps repo minimal, separates system deps from plugin config | SessionStart hook with setup script (mixes system deps into repo, runs on every session) |
| `.gitignore` negation rule | Standard git pattern, allows single file to be tracked in ignored directory | Separate directory outside `.claude/` (not supported by Claude Code) |
| No settings.json template in `src/templates/` | settings.json is project-specific (marketplace refs vary), not a pipeline artifact | Smart Template approach (over-engineered for a config file) |

## Risks & Trade-offs

- **Self-referential marketplace**: The plugin repo declares itself as its own marketplace. The marketplace system fetches from GitHub independently of the local clone, so this should work. → Mitigated by testing in Claude Code Web.
- **`gh` CLI not available by default**: Without `gh`, plugin skips draft PR creation and can't create issues. → Mitigated by clear README documentation on how to set up `gh` optionally. Core workflow (propose/apply/finalize) works without it.

## Open Questions

No open questions.

## Assumptions

- `apt update && apt install -y gh` works in Claude Code Web cloud sessions (runs as root on Ubuntu 24.04). <!-- ASSUMPTION: apt in cloud sessions -->
- The `extraKnownMarketplaces` field in `.claude/settings.json` supports GitHub source format `{ "source": "github", "repo": "owner/repo" }`. <!-- ASSUMPTION: marketplace source format -->
No further assumptions.
