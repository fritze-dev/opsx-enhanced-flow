# ADR-033: Worktree-Based Change Lifecycle

## Status

Accepted (2026-03-30)

## Context

The opsx-enhanced plugin manages all changes in a single working tree at `openspec/changes/<name>/`. When multiple changes are in-flight simultaneously, structural modifications landing on main (file moves, version bumps, ADR numbers) cause merge conflicts on feature branches. This friction was tracked in Issue #59 and affected parallel development workflows.

Git worktrees provide full filesystem isolation per change, each with its own working directory and dedicated branch. The approach eliminates cross-change interference entirely because each worktree operates on an independent copy of the repository. The investigation considered three approaches: worktree-per-change (full isolation), branch-per-change in same worktree (no directory switching but still shared filesystem), and stash-based isolation (lightweight but fragile). Worktree-per-change was selected for its complete isolation guarantees.

Additionally, WORKFLOW.md was being generated inline in the setup skill, inconsistent with the constitution template pattern where templates are maintained as versioned files in `src/templates/`.

## Decision

1. **Store worktrees under `.claude/worktrees/{change}`** -- already gitignored via `/.claude/` entry; keeps worktrees near the repo root; the path is configurable via `worktree.path_pattern` in WORKFLOW.md.

2. **Extract WORKFLOW.md into `src/templates/workflow.md`** -- consistent with the constitution template pattern; provides a single source of truth; the setup skill copies this file instead of generating content inline.

3. **Detect worktree context via `git rev-parse --git-dir`** -- reliable built-in git mechanism that returns a path containing `/worktrees/` when inside a worktree; no false positives compared to checking CWD paths or environment variables.

4. **Derive change name from branch name** -- `/opsx:new` creates the branch with the change name, establishing a 1:1 mapping; more robust than parsing worktree paths or maintaining configuration files.

5. **Offer worktree opt-in during `/opsx:setup`, not via manual WORKFLOW.md edit** -- user-friendly; only offered when `gh` CLI is available and git 2.5+ detected; keeps the one-time setup experience integrated.

6. **Auto-select change from worktree context even for verify/archive/sync** -- a worktree IS the change context by definition (the branch is the change); more specific than directory listing and consistent with the isolation model.

## Alternatives Considered

- **Branch per change, same worktree**: No directory switching required, but changes still share the filesystem, so structural merge conflicts persist.
- **Stash-based isolation**: Lightweight and requires no extra directories, but stashes are fragile, don't support true parallel work, and are easy to lose track of.
- **`../opsx-wt-<change>` for worktree path**: Pollutes the parent directory.
- **`.worktrees/` for worktree path**: Requires a new `.gitignore` entry.
- **Keep WORKFLOW.md inline in setup skill**: Harder to maintain, inconsistent with the template pattern.
- **Check CWD path for worktree detection**: Fragile and dependent on path structure.
- **Environment variable for worktree detection**: Requires manual setup by the user.
- **Add a dedicated `/opsx:worktrees` management skill**: Over-engineering -- `git worktree list` and `git worktree remove` are sufficient.
- **Keep "always prompt" rule for verify/archive/sync in worktrees**: Defeats the purpose of isolation when the worktree already defines the context.

## Consequences

### Positive

- Parallel changes are fully isolated -- no merge conflicts from structural modifications on main.
- Skills automatically detect the active change from worktree context, reducing manual input.
- WORKFLOW.md is maintained as a versioned template file, consistent with the constitution pattern.
- The feature is opt-in, so existing projects are unaffected.
- Worktree paths under `.claude/` are already gitignored, requiring no additional configuration.

### Negative

- Users must switch working directories to operate in a worktree after `/opsx:new`; mitigated by clear output reporting the worktree path.
- Each worktree is a full checkout, consuming disk space; negligible for markdown-heavy projects but potentially significant for large repositories.
- Stale worktrees accumulate if users forget to clean up; mitigated by `auto_cleanup` option and cleanup instructions in archive output.

## References

- [Spec: change-workspace](../../openspec/specs/change-workspace/spec.md)
- [Spec: artifact-pipeline](../../openspec/specs/artifact-pipeline/spec.md)
- [Spec: project-setup](../../openspec/specs/project-setup/spec.md)
- [GitHub Issue #59](https://github.com/anthropics/opsx-enhanced-flow/issues/59)
