# Technical Design: Post-Artifact Commit and PR Integration

## Context

PR creation is currently inlined in the proposal artifact instruction (`schema.yaml` lines 86-100). Issue #51 identified that this creates orphaned PRs when proposals are rejected. Additionally, only the proposal commits — all other artifacts remain uncommitted until post-apply. This change introduces a schema-level `post_artifact` hook that commits after every artifact and creates branch+PR on the first commit.

## Architecture & Components

**Files modified:**

| File | Change |
|------|--------|
| `openspec/schemas/opsx-enhanced/schema.yaml` | Add top-level `post_artifact` field; remove PR block from proposal instruction (lines 86-100) |
| `openspec/schemas/opsx-enhanced/templates/proposal.md` | Remove `## Pull Request` section (lines 36-43) |
| `skills/continue/SKILL.md` | Add step: after artifact creation, read and apply `post_artifact` from schema |
| `openspec/specs/artifact-pipeline/spec.md` | Replace "Proposal PR Integration" with "Post-Artifact Commit and PR Integration" |
| `docs/decisions/adr-026-*.md` | Mark as superseded |
| New: `docs/decisions/adr-028-*.md` | Document the new decision |

**New schema field:**
```yaml
post_artifact: |
  After creating any artifact, commit and push:
  1. If not on a feature branch: git checkout -b <change-name>
  2. git add openspec/changes/<change-name>/
  3. git commit -m "WIP: <change-name> — <artifact-id>"
  4. git push -u origin <change-name>
  5. On FIRST push (no existing PR): gh pr create --draft
     --title "<Change Name>" --body "WIP: <change-name>"

  Graceful degradation: skip push/PR if gh unavailable or no remote.
```

**Interaction flow (new):**
1. `/opsx:new` → `mkdir`, show status (no git ops)
2. `/opsx:continue` (research) → write `research.md` → **post_artifact**: create branch, commit, push, create draft PR
3. `/opsx:continue` (proposal) → write `proposal.md` → **post_artifact**: commit, push
4. `/opsx:continue` (specs) → write specs → **post_artifact**: commit, push
5. (same pattern for design, preflight, tasks)
6. Constitution standard task (post-apply) → `gh pr ready && gh pr edit --body "..."`

**Layer responsibilities:**
- **Schema** (`post_artifact`) — owns the rule (what to do after each artifact)
- **Continue skill** — executes the rule (reads `post_artifact`, applies it)
- **Constitution** — owns project-specific PR finalization (standard task)

## Goals & Success Metrics

- Every artifact is committed individually: PASS if git log shows separate commits per artifact
- Branch+PR created on first commit: PASS if `gh pr view` shows a draft PR after first `/opsx:continue`
- Proposal instruction has no PR creation: PASS if proposal instruction contains no `gh pr create` or `git checkout -b`
- `## Pull Request` section removed: PASS if proposal template does not contain `## Pull Request`
- Backward compatibility: PASS if a schema without `post_artifact` causes no errors in continue skill

## Non-Goals

- Automatic PR body update when artifacts are created (stays minimal WIP)
- Changing the PR finalization standard task in the constitution
- Modifying `/opsx:new` or `/opsx:ff` skill logic

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Schema-level `post_artifact` field | Schema owns workflow rules (ADR-002); DRY; one place to maintain | Per-artifact instruction blocks (repetitive 6x); skill-level logic (wrong layer) |
| No metadata file for PR URL | `gh pr view` derives PR from branch; zero storage overhead | `.meta.yaml` (adds file management complexity) |
| Remove `## Pull Request` from proposal template | Redundant with `gh pr view`; cleaner template | Keep as optional docs (maintenance burden, no benefit) |
| Branch+PR on first artifact commit | First commit has real content; no empty commits; organic flow | PR in `/opsx:new` (empty commit); PR in proposal only (Issue #51) |
| New ADR superseding ADR-026 | Preserves decision history | In-place edit (loses original rationale) |

## Risks & Trade-offs

- [Initial PR has minimal content] → Acceptable; team sees PR exists and can follow artifacts in the branch. Constitution standard task updates body post-apply.
- [Continue skill needs update] → Small change: read one additional schema field. Backward compatible (absent field = no-op).
- [Auto-continue creates multiple commits quickly] → By design; each artifact gets its own commit for traceability.

## Open Questions

No open questions.

## Assumptions

- The `gh` CLI, when available, is authenticated and has permission to create PRs. <!-- ASSUMPTION: gh CLI authentication -->
- `git branch --show-current` reliably detects the current branch on all target git versions. <!-- ASSUMPTION: git branch detection -->
No further assumptions beyond those marked above.
