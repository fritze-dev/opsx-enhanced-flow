# Research: Claude Code Web Setup

## 1. Current State

The plugin has a devcontainer setup (`.devcontainer/devcontainer.json`) that handles Codespaces/local development: installs gh CLI, Claude Code, and the plugin via `postCreateCommand`. Claude Code Web (claude.ai/code) uses its own universal image — devcontainer features do not apply.

**Relevant files:**
- `.devcontainer/devcontainer.json` — Codespaces setup (gh CLI feature, plugin install)
- `.claude/settings.local.json` — local permissions (gitignored, not committed)
- `.gitignore` — contains `/.claude/` which blocks `.claude/settings.json` from being committed
- `src/skills/workflow/SKILL.md:105-106` — `gh pr create --draft` with graceful fallback
- `openspec/specs/project-init/spec.md` — environment checks during init (gh, git version)

**Issue:** [fritze-dev/opsx-enhanced-flow#14](https://github.com/fritze-dev/opsx-enhanced-flow/issues/14) — original issue from before plugin evolution

**No existing specs affected** — this is a new setup/infrastructure concern, not a behavioral change to the workflow.

## 2. External Research

### Claude Code Web Environment (from official docs)

**What's built-in:**
- Full filesystem access (Ubuntu 24.04 VM, runs as root)
- `git` pre-installed (clone, push, fetch work via GitHub Proxy)
- Built-in GitHub tools (read issues, list PRs, fetch diffs, post comments)
- GitHub Proxy handles auth transparently (scoped credential, no token in container)
- Node.js 20/21/22, Python 3.x, Go, Rust, Docker, PostgreSQL, Redis pre-installed

**What's NOT built-in:**
- `gh` CLI — must be installed via `apt update && apt install -y gh`
- User-scoped plugins — must be declared in `.claude/settings.json`
- `GH_TOKEN` — needed for `gh` CLI auth, user configures as environment variable

### Plugin Declaration in settings.json

Per docs, plugins declared in `.claude/settings.json` auto-install at session start:
```json
{
  "extraKnownMarketplaces": {
    "name": { "source": { "source": "github", "repo": "owner/repo" } }
  },
  "enabledPlugins": { "plugin@marketplace": true }
}
```
This eliminates need for `claude plugin` commands in setup scripts.

### SessionStart Hooks

- Format: `hooks.SessionStart[].hooks[].command` in `.claude/settings.json`
- `CLAUDE_CODE_REMOTE=true` env var detects cloud sessions
- `$CLAUDE_PROJECT_DIR` for reliable path resolution
- `matcher: "startup"` runs only on new sessions (not resume)
- stdout is added as context Claude can see

### Setup Scripts vs SessionStart Hooks

| | Setup Scripts | SessionStart Hooks |
|---|---|---|
| Configured in | Cloud environment UI | `.claude/settings.json` (repo) |
| Runs | Before Claude Code launches, new sessions only | After Claude Code launches, all sessions |
| Scope | Cloud only | Both local and cloud |

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| **A: settings.json plugin declaration + SessionStart hook for gh** | Clean separation: plugin install declarative, gh via hook. Follows docs patterns exactly. | Self-referential (repo declares itself as marketplace). Needs testing. |
| **B: SessionStart hook for everything** | Single script handles all setup. Simple to debug. | Duplicates what settings.json can do declaratively. Plugin install via `claude plugin` in hook may have timing issues. |
| **C: Only settings.json, no hook** | Minimal — just plugin declaration. | No `gh` CLI — loses `gh pr create --draft` and `gh release create`. |

**Recommended: Approach A** — declarative plugin install + hook only for `gh` CLI.

## 4. Risks & Constraints

- **Self-referential marketplace**: The repo declares itself as a marketplace via `extraKnownMarketplaces` pointing to `fritze-dev/opsx-enhanced-flow`. The marketplace system fetches from GitHub separately. Needs validation in Claude Code Web.
- **`.gitignore` conflict**: `/.claude/` blocks `.claude/settings.json`. Must add negation rule `!/.claude/settings.json`. Well-established git pattern, low risk.
- **`gh auth setup-git` in hook**: If `GH_TOKEN` is not set, `gh` commands fail gracefully (plugin already handles this). No hard failure.
- **SessionStart hook latency**: `apt update && apt install -y gh` adds ~10-15s to session start. Acceptable for new sessions, and we gate on `command -v gh` to skip if already installed.
- **GitHub Proxy restriction**: Push is restricted to current working branch. Worktree mode creates feature branches which become the current branch — should work fine.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | 4 files: .gitignore, .claude/settings.json, scripts/setup-remote.sh, README.md |
| Behavior | Clear | Plugin auto-installs, gh installed via hook, git via proxy |
| Data Model | Clear | No data model — configuration files only |
| UX | Clear | User must configure GH_TOKEN in Claude Code Web environment settings |
| Integration | Clear | settings.json format documented, SessionStart hooks documented |
| Edge Cases | Clear | Script idempotent, gh fallback exists, CLAUDE_CODE_REMOTE gate |
| Constraints | Clear | Cloud sessions run as root, Trusted network allows apt + github |
| Terminology | Clear | Standard Claude Code Web terms |
| Non-Functional | Clear | ~10-15s added to new session start for gh install |

All categories Clear — no open questions needed.

## 6. Open Questions

All Clear — skipping.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Use `extraKnownMarketplaces` + `enabledPlugins` for plugin install | Declarative, follows docs pattern, no script needed | `claude plugin` commands in SessionStart hook |
| 2 | Install `gh` CLI via SessionStart hook | `gh` not pre-installed, needed for `gh pr create --draft` and `gh release` | Skip gh (degrade gracefully), or use Environment Setup Script (not in repo) |
| 3 | Gate hook on `CLAUDE_CODE_REMOTE=true` | Prevents unnecessary execution in local/Codespaces environments | No gate (run everywhere, check `command -v gh`) |
| 4 | Add `.gitignore` negation for `.claude/settings.json` | Required for settings.json to be committed and available in cloud sessions | Move settings elsewhere (not supported by Claude Code) |
