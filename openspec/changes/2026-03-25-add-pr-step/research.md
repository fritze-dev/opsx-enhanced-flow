# Research: Add PR Step to Workflow

## 1. Current State

The opsx-enhanced workflow has no git branching or PR integration. The current pipeline operates on whatever branch is active when `/opsx:new` is called. The post-apply workflow ends with "commit and push to remote" — no PR creation or management exists.

**Affected files:**
- `openspec/schemas/opsx-enhanced/schema.yaml` — proposal artifact `instruction` field (lines 34-74), `apply.instruction` (lines 231-247)
- `openspec/schemas/opsx-enhanced/templates/proposal.md` — proposal template structure
- `openspec/constitution.md` — `## Standard Tasks` section (lines 42-47)

**Affected specs:**
- `artifact-pipeline` — defines "Six-Stage Pipeline" requirement; the pipeline stage count and artifact list are referenced throughout. Since our approach keeps 6 stages (no new artifact), only the `apply.instruction` post-apply sequence and standard tasks behavior are impacted.
- `task-implementation` — standard tasks section and post-apply workflow. Adding a PR update step means a new standard task appears.
- `artifact-generation` — continue/ff skills. No structural change needed since skills follow schema instructions dynamically.

**Current standard tasks (constitution):**
```markdown
- [ ] Update plugin locally (...)
```

**Current universal standard tasks (template):**
```markdown
- [ ] 4.1. Archive change
- [ ] 4.2. Generate changelog
- [ ] 4.3. Generate/update docs
- [ ] 4.4. Commit and push to remote
```

## 2. External Research

- `gh pr create --draft` — GitHub CLI command for creating draft PRs. Requires `gh` CLI installed and authenticated.
- `gh pr ready` — marks a draft PR as ready for review.
- `gh pr edit --body "..."` — updates PR description.
- Draft PRs are a standard GitHub feature for early visibility before implementation is complete.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| **A: New `pr-draft` artifact** | Tracked by OpenSpec CLI, visible in `openspec status`, enforced in dependency chain | Schema change, new template, modifies pipeline stage count, breaks "Six-Stage Pipeline" spec requirement |
| **B: Inline in proposal instruction** | No schema structural change, pipeline stays 6 stages, minimal file changes, skills auto-follow | PR creation is a side effect of an existing artifact, not independently trackable |
| **C: Standalone `/opsx:pr` skill** | Can be invoked at any time, flexible | Not enforced by pipeline, user could forget, no dependency gating |
| **D: Standard task only (post-apply)** | Simplest change, constitution only | PR created too late — user wants early visibility for team review |

**Selected: Approach B** — Inline in proposal instruction. The user confirmed this is the preferred approach: add PR creation as a checklist item within the proposal step, plus a standard task for PR finalization after implementation.

## 4. Risks & Constraints

- **`gh` CLI dependency**: Not all environments have `gh` installed or authenticated. Mitigation: graceful degradation — skip PR creation and note in proposal.md.
- **Network failures**: PR creation requires internet. Mitigation: same graceful degradation.
- **Branch naming conflicts**: Change names are already validated as kebab-case by `/opsx:new`, so branch names are safe.
- **Existing changes in-progress**: Schema instruction changes only affect new artifact generation. In-progress changes with existing proposal.md are unaffected.
- **Spec drift**: The `artifact-pipeline` spec references "Six-Stage Pipeline" — our approach preserves this since no new artifact is added. However, the `apply.instruction` post-apply sequence and standard tasks references will change.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Inline PR in proposal instruction + standard task for finalization |
| Behavior | Clear | Create branch, commit artifacts, draft PR after proposal; update PR after implementation |
| Data Model | Clear | PR metadata stored in `## Pull Request` section of proposal.md |
| UX | Clear | Seamless — auto-continued as part of proposal step |
| Integration | Clear | `gh` CLI, graceful degradation path defined |
| Edge Cases | Clear | No `gh`, network failure, branch exists, no-code changes |
| Constraints | Clear | Must not break pipeline structure or existing specs |
| Terminology | Clear | "Draft PR", "ready for review", standard GitHub terminology |
| Non-Functional | Clear | No performance impact, optional `gh` dependency |

All categories Clear — no open questions needed.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Inline PR creation in proposal instruction, not a new artifact | User preference for simplicity; preserves 6-stage pipeline; no schema structural change | New `pr-draft` artifact (rejected: too heavy), standalone skill (rejected: not enforced) |
| 2 | PR created after proposal, not after research | Proposal content (Why, What Changes, Impact) provides meaningful PR body; research alone is insufficient | After research (rejected: empty PR body) |
| 3 | PR finalization as standard task in constitution | Fits existing pattern; tracked in tasks.md; executed post-apply | Second artifact (rejected: adds pipeline complexity) |
| 4 | Graceful degradation when `gh` unavailable | Prevents blocking pipeline on external tool dependency | Hard requirement on `gh` (rejected: limits portability) |
