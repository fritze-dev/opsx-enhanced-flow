# Research: Worktree-Based Change Lifecycle

## 1. Current State

### Change Workspace Architecture
All changes currently live in `openspec/changes/<name>/` within a single working tree. The `/opsx:new` skill creates this directory via `mkdir -p`. Seven skills detect the active change by scanning `openspec/changes/` (excluding `archive/`): `ff`, `apply`, `verify`, `archive`, `sync`, `discover`, `preflight`.

### Post-Artifact Git Flow (WORKFLOW.md `post_artifact`)
After each artifact, the `ff` skill:
1. Creates a feature branch if on main: `git checkout -b <change-name>`
2. Stages artifacts: `git add openspec/changes/<change-name>/`
3. Commits: `git commit -m "WIP: <change-name> — <artifact-id>"`
4. Pushes: `git push -u origin <change-name>`
5. Creates draft PR on first push: `gh pr create --draft`

### WORKFLOW.md Generation
Currently generated inline in `src/skills/setup/SKILL.md` (Step 2). Unlike `constitution.md`, which has a template at `src/templates/constitution.md`, WORKFLOW.md has no template file — the full content is hardcoded in the setup skill.

### Known Friction (Issue #59)
When structural changes land on main (e.g., skills moved to `src/skills/`, templates to `src/templates/`), in-flight feature branches encounter:
- File path conflicts from directory restructuring
- Version bump conflicts (both branches bump patch version)
- ADR number conflicts (both branches create same-numbered ADRs)

### Skill Change Detection Pattern
All 7 change-detecting skills follow this pattern:
1. Check for explicit argument
2. Infer from conversation context
3. Auto-select if only one active change (some skills skip this)
4. Prompt user to select

Skills `verify`, `archive`, and `sync` explicitly say "Do NOT auto-select" — they always prompt.

### Existing Spec Coverage
- `change-workspace` (order: 3, category: change-workflow) — covers `/opsx:new` workspace creation and `/opsx:archive`
- `artifact-pipeline` (order: 4, category: change-workflow) — covers 6-stage pipeline, post-artifact commits, WORKFLOW.md ownership
- `project-setup` (order: 1, category: setup) — covers `/opsx:setup` including WORKFLOW.md generation
- `workflow-contract` (order: 3, category: reference) — covers WORKFLOW.md format, Smart Template format, skill reading pattern
- `three-layer-architecture` (order: 13, category: reference) — mentions 12 skills (stale — actually 13 with docs-verify)

## 2. External Research

### Git Worktree Mechanics
- `git worktree add <path> -b <branch>`: Creates a new worktree at `<path>` on a new branch
- `git worktree add <path> <existing-branch>`: Creates worktree for existing branch
- `git worktree list [--porcelain]`: Lists all worktrees
- `git worktree remove <path>`: Removes a worktree (fails if dirty)
- `git worktree remove <path> --force`: Removes even with untracked files
- Worktrees share the `.git` directory — all branches, refs, and objects are shared
- A branch can only be checked out in one worktree at a time
- Detection: `git rev-parse --git-dir` returns `<main-repo>/.git/worktrees/<name>` when in a worktree

### Claude Code Context
- Claude Code sessions operate in a working directory — switching to a worktree means changing the CWD
- The plugin resolves via `${CLAUDE_PLUGIN_ROOT}` which points to the plugin source, independent of CWD
- `.claude/` directory at repo root is excluded by `.gitignore`

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| **A: Worktree per change (selected)** | Full isolation; parallel changes never conflict; each worktree has its own branch from creation | User must switch directories; worktrees consume disk space |
| B: Branch per change, same worktree | No directory switching; familiar git workflow | Changes still share filesystem; merge conflicts on parallel work |
| C: Stash-based isolation | Lightweight; no extra directories | Stashes are fragile; no true parallel work; easy to lose track |

## 4. Risks & Constraints

- **Session continuity**: After `/opsx:new` creates a worktree, the Claude Code session needs to operate in the worktree directory. The user must `cd` or start a new session there.
- **Plugin resolution**: `${CLAUDE_PLUGIN_ROOT}` is plugin-relative, not CWD-relative — should work in worktrees without modification.
- **Disk usage**: Each worktree is a full checkout. For this markdown-only project it's negligible, but for large repos it could matter.
- **Archive in worktree**: Archiving moves the change directory within the worktree's branch. This is correct — the archive merges to main with the PR.
- **Spec sync in worktree**: `/opsx:sync` modifies baseline specs on the feature branch. This is correct — changes merge to main with the PR.
- **Worktree path in .gitignore**: If worktrees are stored under `.claude/worktrees/`, they're already excluded by `/.claude/` in `.gitignore`.
- **Backward compatibility**: Must be opt-in. Projects without `worktree.enabled: true` keep current behavior.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Worktree creation, context detection, cleanup, setup integration |
| Behavior | Clear | Git worktree mechanics well-understood; skill detection pattern documented |
| Data Model | Clear | WORKFLOW.md gets `worktree:` section; no new data structures |
| UX | Clear | User opts in during setup; `/opsx:new` reports worktree path; skills auto-detect |
| Integration | Clear | 7 skills need detection preamble; setup needs environment checks |
| Edge Cases | Clear | Branch already exists, dirty worktree removal, no gh CLI |
| Constraints | Clear | Backward compat via opt-in; skill immutability respected |
| Terminology | Clear | Worktree, feature branch, change name — all well-defined |
| Non-Functional | Clear | Disk space is the only concern; negligible for markdown projects |

## 6. Open Questions

All categories are Clear — no open questions.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Worktree path under `.claude/worktrees/{change}` | Already gitignored; keeps worktrees near the repo; configurable via `path_pattern` | `../opsx-wt-<change>` (pollutes parent dir), `<repo>/.worktrees/` (needs new gitignore entry) |
| 2 | Extract WORKFLOW.md into `src/templates/workflow.md` | Consistent with constitution template pattern; single source of truth; setup skill copies instead of inlining | Keep inline in setup skill (harder to maintain, inconsistent) |
| 3 | No `/opsx:worktrees` skill | `git worktree list` and `git worktree remove` are sufficient; avoids skill proliferation | Add dedicated skill (over-engineering for standard git commands) |
| 4 | Integrate gh CLI check and merge strategy into `/opsx:setup` | Natural place for environment configuration; runs once per project | Separate setup step (fragmented), manual documentation (easy to forget) |
| 5 | Worktree context detection via `git rev-parse --git-dir` | Reliable, built-in git mechanism; returns path containing `/worktrees/` when in a worktree | Check CWD path (fragile), environment variable (requires manual setup) |
