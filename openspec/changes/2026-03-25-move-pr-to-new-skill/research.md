# Research: Move PR Creation to Schema-Level Post-Artifact Hook

## 1. Current State

PR creation is currently embedded in the **proposal artifact instruction** in `openspec/schemas/opsx-enhanced/schema.yaml` (lines 86-100). After writing `proposal.md`, the agent:
1. Creates a feature branch (`git checkout -b <change-name>`)
2. Commits change artifacts with a WIP message
3. Pushes the branch
4. Creates a draft PR via `gh pr create --draft` with proposal content as body
5. Appends a `## Pull Request` section to `proposal.md`

Only the proposal step commits — all other artifacts are uncommitted until the post-apply workflow.

**Affected files:**
- `openspec/schemas/opsx-enhanced/schema.yaml` — proposal instruction (lines 86-100); new top-level `post_artifact` field
- `openspec/schemas/opsx-enhanced/templates/proposal.md` — `## Pull Request` section (lines 36-43)
- `openspec/specs/artifact-pipeline/spec.md` — "Proposal PR Integration" requirement (lines 89-116)
- `docs/decisions/adr-026-inline-pr-integration-in-proposal-step.md` — documents current approach
- `skills/continue/SKILL.md` — needs to read and apply `post_artifact` from schema after each artifact

**Related architecture:**
- Three-layer architecture: Constitution → Schema → Skills (ADR-002)
- Schema owns workflow rules; skills execute them
- Skills are immutable shared code (per constitution) — but adding "read `post_artifact` from schema" is universal behavior, not project-specific
- ADR-026 documents the original decision to inline PR in proposal step

## 2. External Research

No external dependencies. The `gh` CLI is already used for PR operations. The `git` CLI is already used in the proposal step.

Key `gh` CLI behaviors:
- `gh pr view` automatically finds the PR for the current branch — no URL storage needed
- `gh pr create --draft` creates a draft PR from the current branch
- `gh pr edit` can update the PR body later

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| **Schema `post_artifact` hook** (chosen) | Commits after every artifact; branch+PR on first commit; schema owns rule; DRY | New schema field; continue skill needs small update |
| Move PR to `/opsx:new` | Simple; no schema change | Empty commit; PR before any content; `/opsx:new` does git ops on empty dir |
| Keep PR in proposal, add approval gate | No code change | Adds complexity; still creates PR before user approval |
| Per-artifact instruction blocks | No new schema field | Repetitive (6x same text); harder to maintain |

## 4. Risks & Constraints

- **Schema field addition**: Adding `post_artifact` is a schema structural change. The `continue` skill must be updated to read it. This is acceptable since the skill already reads `instruction` and `template` from the schema.
- **Backward compatibility**: If `post_artifact` is absent (older schemas), the continue skill does nothing after artifact creation — safe default.
- **First-commit detection**: The continue skill needs to detect "is this the first commit on a new branch?" to trigger PR creation. Simplest check: `git branch --show-current` — if on main, create branch first.
- **`gh pr view` as lookup**: Since `gh pr view` finds the PR from the current branch, no metadata file or `## Pull Request` section is needed.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Schema-level `post_artifact` hook; commit after every artifact; branch+PR on first commit |
| Behavior | Clear | Every artifact gets committed; first commit creates branch+PR; proposal loses PR block |
| Data Model | Clear | New `post_artifact` field in schema.yaml; `## Pull Request` section removed from template |
| UX | Clear | Incremental commits visible in PR; `gh pr view` for lookups |
| Integration | Clear | gh CLI, git CLI — same tools already in use |
| Edge Cases | Clear | Graceful degradation, branch-already-exists, no remote — carry over from current spec |
| Constraints | Clear | Schema owns workflow rules (ADR-002); skill reads schema at runtime |
| Terminology | Clear | `post_artifact` is self-explanatory |
| Non-Functional | Clear | No performance or security implications |

## 6. Open Questions

All categories are Clear — no questions needed.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Schema-level `post_artifact` field | Schema owns workflow rules (ADR-002); DRY; one place to maintain | Per-artifact instruction blocks (repetitive); skill-level logic (wrong layer) |
| 2 | No metadata file for PR URL | `gh pr view` derives PR from current branch automatically | `.meta.yaml` in change dir; storing URL in proposal.md |
| 3 | Remove `## Pull Request` section from proposal template | Redundant when `gh pr view` provides the info on-demand | Keep section as optional documentation |
| 4 | Branch+PR created on first artifact commit, not in `/opsx:new` | First commit has real content (research.md); no empty commits | PR in `/opsx:new` (empty commit); PR in proposal only (current, causes Issue #51) |
