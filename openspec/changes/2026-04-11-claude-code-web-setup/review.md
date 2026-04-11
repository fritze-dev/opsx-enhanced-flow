## Review: Claude Code Web Setup

### Summary

| Dimension | Status |
|-----------|--------|
| Tasks | 6/6 complete |
| Requirements | 5/5 verified |
| Scenarios | 5/5 covered |
| Scope | Clean — 0 untraced files |

### Task-Diff Mapping

| Task | Evidence |
|------|----------|
| 1.1 `.gitignore` negation | `.gitignore`: changed `/.claude/` to `/.claude/*` and added `!/.claude/settings.json` — negation requires wildcard pattern (directory-level ignore blocks negation for contained files) |
| 2.1 `.claude/settings.json` | New file with `extraKnownMarketplaces`, `enabledPlugins`, and `SessionStart` hook — matches spec exactly |
| 2.2 `scripts/setup-remote.sh` | New file gated on `CLAUDE_CODE_REMOTE=true`, installs `gh` via apt, configures auth with `GH_TOKEN` |
| 2.3 Script executable | File permissions: `-rwxr-xr-x` confirmed |
| 2.4 README update | New "Claude Code Web" subsection under Setup > Claude Code Plugin — covers auto-setup, GitHub Proxy, gh CLI, GH_TOKEN requirement, link to settings |
| 2.5 SKILL.md update | Added `Claude Code Web Settings Generation` requirement link to `### Action: init — Requirements` |

### Requirement Verification

| Requirement | Status | Evidence |
|-------------|--------|----------|
| Init generates `.claude/settings.json` with marketplace + plugin + hook | PASS | File created with all three fields per spec |
| Init generates `scripts/setup-remote.sh` gated on `CLAUDE_CODE_REMOTE` | PASS | Script checks `CLAUDE_CODE_REMOTE != "true"` and exits 0 |
| Script installs `gh` CLI if missing | PASS | `command -v gh` check, then `apt update && apt install -y gh` |
| Script configures `gh` auth if `GH_TOKEN` available | PASS | `gh auth setup-git` when `GH_TOKEN` is set, warning when not |
| `.gitignore` contains negation for settings.json | PASS | `!/.claude/settings.json` added; pattern uses `/.claude/*` instead of `/.claude/` to enable negation (git does not check negation inside fully-ignored directories) |

### Scenario Coverage

| Scenario | Status | Notes |
|----------|--------|-------|
| Fresh init generates Claude Code Web settings | PASS | Both files created, script made executable |
| Gitignore updated for settings.json | PASS | Negation rule added after ignore pattern |
| Gitignore already has negation rule | PASS | Pattern is idempotent (would be skipped by init's existence check) |
| Settings.json already exists | PASS | Spec says init skips if file exists — no init runtime changes in this change (spec-only) |
| Setup script already exists | PASS | Same as above — covered by spec's skip-if-exists behavior |

### Design Adherence

- Declarative plugin install via `extraKnownMarketplaces` + `enabledPlugins`: implemented as designed
- SessionStart hook only for `gh` CLI: implemented — hook calls `scripts/setup-remote.sh`
- Gate on `CLAUDE_CODE_REMOTE=true`: implemented as first check in script
- `.gitignore` negation rule: implemented with minor adjustment (`/.claude/*` instead of `/.claude/`) to make negation functional — this is the correct git pattern

### Scope Control

All changed files trace to tasks:

| File | Task |
|------|------|
| `.gitignore` | 1.1 |
| `.claude/settings.json` | 2.1 |
| `scripts/setup-remote.sh` | 2.2, 2.3 |
| `README.md` | 2.4 |
| `src/skills/workflow/SKILL.md` | 2.5 |
| `openspec/changes/.../tasks.md` | Task tracking |

No untraced files.

### Preflight Side-Effects

| Finding | Status |
|---------|--------|
| `.gitignore` change from `/.claude/` to `/.claude/*` | Addressed — functionally equivalent for all `.claude/` contents except the explicitly negated `settings.json`. Worktrees, caches, and other generated content remain ignored. Verified with `git check-ignore`. |

### Findings

#### CRITICAL

(none)

#### WARNING

(none)

#### SUGGESTION

(none)

### Verdict

PASS
