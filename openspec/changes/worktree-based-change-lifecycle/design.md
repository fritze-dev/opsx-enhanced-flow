# Technical Design: Worktree-Based Change Lifecycle

## Context

The opsx-enhanced plugin currently manages all changes in a single working tree at `openspec/changes/<name>/`. When multiple developers (or the same developer) work on parallel changes, structural modifications on main (file moves, version bumps, ADR numbers) cause merge conflicts on feature branches. Git worktrees provide full filesystem isolation per change, each with its own branch.

Additionally, WORKFLOW.md is currently generated inline in the setup skill. This is inconsistent with the constitution template pattern and makes maintenance harder.

## Architecture & Components

### Files Modified

| File | Change |
|------|--------|
| `src/templates/workflow.md` | **New** — WORKFLOW.md template with commented-out `worktree:` section |
| `src/skills/setup/SKILL.md` | Copy WORKFLOW.md from template; add environment checks; worktree opt-in; merge strategy |
| `src/skills/new/SKILL.md` | Add worktree creation step after setup verification |
| `src/skills/ff/SKILL.md` | Add worktree context detection preamble |
| `src/skills/apply/SKILL.md` | Add worktree context detection preamble |
| `src/skills/verify/SKILL.md` | Add worktree context detection preamble |
| `src/skills/archive/SKILL.md` | Add worktree context detection preamble + cleanup step |
| `src/skills/sync/SKILL.md` | Add worktree context detection preamble |
| `src/skills/discover/SKILL.md` | Add worktree context detection preamble |
| `src/skills/preflight/SKILL.md` | Add worktree context detection preamble |
| `openspec/WORKFLOW.md` | Add worktree section; update post_artifact for worktree awareness |

### Worktree Detection Pattern (shared across 7 skills)

All change-detecting skills insert this preamble at the start of their "Select the change" step:

```
Worktree Context Detection (runs first, before directory listing):

If no explicit change name was provided as an argument:
1. Run: git rev-parse --git-dir
2. If the result contains /worktrees/, derive change name from branch:
   git rev-parse --abbrev-ref HEAD
3. Verify: openspec/changes/<branch-name>/ exists
4. If valid: auto-select and announce
5. If not: fall through to normal detection
```

This pattern is identical across all 7 skills. It runs before any directory listing or auto-select logic.

### WORKFLOW.md Template Structure

The new `src/templates/workflow.md` contains the current WORKFLOW.md content with an additional commented-out `worktree:` section:

```yaml
# worktree:
#   enabled: false
#   path_pattern: .claude/worktrees/{change}
#   auto_cleanup: false
```

When the user opts in during setup, the setup skill uncomments this section and sets `enabled: true`.

### Post-Artifact Hook Update

The `post_artifact` hook in WORKFLOW.md (and the template) is updated to be worktree-aware:

```
1. Check current branch: git rev-parse --abbrev-ref HEAD
   - If already on <change-name> branch (e.g., in a worktree): skip branch creation
   - If on main: git checkout -b <change-name>
   - If on another branch: git checkout <change-name>
```

This is backward compatible — the existing behavior already handles "branch exists, switch to it."

## Goals & Success Metrics

* WORKFLOW.md template exists at `src/templates/workflow.md` and `/opsx:setup` copies it correctly — PASS/FAIL
* `/opsx:new` with `worktree.enabled: true` creates a git worktree at the configured path — PASS/FAIL
* All 7 change-detecting skills auto-detect change name from worktree branch context — PASS/FAIL
* Post-artifact hook skips `git checkout -b` when already on feature branch in worktree — PASS/FAIL
* `/opsx:archive` in worktree offers cleanup (auto or manual based on config) — PASS/FAIL
* With `worktree` absent or commented out, all skills behave identically to current behavior — PASS/FAIL
* `/opsx:setup` detects gh CLI and offers worktree + rebase-merge configuration — PASS/FAIL

## Non-Goals

- Automatic conflict resolution between worktrees
- CI/CD pipeline changes
- Dedicated `/opsx:worktrees` management skill
- Changes to non-change-detecting skills (docs, docs-verify, changelog, bootstrap)
- Multi-change support within a single worktree

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Worktree path `.claude/worktrees/{change}` | Already gitignored via `/.claude/`; keeps worktrees near repo root; configurable | `../opsx-wt-<change>` (pollutes parent); `.worktrees/` (needs gitignore entry) |
| Extract WORKFLOW.md to template file | Consistent with constitution template; single source of truth; easier maintenance | Keep inline in setup skill (inconsistent, harder to update) |
| Detect worktree via `git rev-parse --git-dir` | Reliable built-in git mechanism; no false positives | Check CWD path (fragile); env var (manual setup needed) |
| Derive change name from branch name | Branch is created with change name by `/opsx:new`; 1:1 mapping | Parse worktree path (fragile); config file (overhead) |
| Worktree opt-in via setup, not WORKFLOW.md manual edit | User-friendly; only offered when gh CLI available; one-time question | Manual WORKFLOW.md edit (error-prone); always-on (breaks existing setups) |
| Worktree context auto-selects even for verify/archive/sync | Worktree IS the change context — more specific than directory listing | Keep "always prompt" rule (defeats purpose of isolation) |

## Risks & Trade-offs

- **Session continuity** → User must switch CWD to worktree after `/opsx:new`. Mitigated by clear output with worktree path.
- **Disk usage** → Each worktree is a full checkout. Negligible for markdown-heavy projects. For large repos, users can opt out.
- **Stale worktrees** → If users don't clean up, disk grows. Mitigated by `auto_cleanup` option and cleanup instructions in archive output.
- **Plugin resolution** → `${CLAUDE_PLUGIN_ROOT}` is plugin-relative, not CWD-relative. Verified to work across worktrees.

## Open Questions

No open questions.

## Assumptions

- Git 2.5+ is available (worktree support). <!-- ASSUMPTION: Git version -->
- `.claude/` gitignore entry covers `.claude/worktrees/`. <!-- ASSUMPTION: Gitignore coverage -->
- `${CLAUDE_PLUGIN_ROOT}` resolves correctly from worktree CWD. <!-- ASSUMPTION: Plugin root resolution -->
No further assumptions beyond those marked above.
