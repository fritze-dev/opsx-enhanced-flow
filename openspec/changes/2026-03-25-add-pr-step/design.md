# Technical Design: Add PR Step to Workflow

## Context

The opsx-enhanced workflow lacks git branching and PR integration. Teams using GitHub need draft PRs for early visibility and review. This change adds PR creation inline in the proposal step and PR finalization as a constitution standard task, requiring changes to 3 files: `schema.yaml`, `templates/proposal.md`, and `constitution.md`.

## Architecture & Components

**Files affected:**

1. **`openspec/schemas/opsx-enhanced/schema.yaml`**
   - `proposal.instruction` (lines 34-74): Append PR creation steps after existing proposal writing guidance
   - `apply.instruction` (lines 228-248): Update post-apply sequence to include executing constitution standard tasks

2. **`openspec/schemas/opsx-enhanced/templates/proposal.md`**
   - Append `## Pull Request` section at the end

3. **`openspec/constitution.md`**
   - Add PR update standard task to `## Standard Tasks` section

**Interactions:**
- The proposal instruction creates a branch and draft PR → PR URL is recorded in `proposal.md`
- The tasks template + constitution extras produce the standard tasks section in `tasks.md` → includes PR update checkbox
- The apply.instruction tells the agent to execute constitution extras during post-apply → PR gets finalized

**No changes needed to skills** — `continue` and `ff` follow the schema instruction dynamically. The enriched proposal instruction flows through automatically.

## Goals & Success Metrics

* After proposal creation, a feature branch exists and is pushed to remote — PASS/FAIL
* After proposal creation, a draft PR exists on GitHub (when `gh` is available) — PASS/FAIL
* `proposal.md` contains a `## Pull Request` section with branch name and PR URL — PASS/FAIL
* Pipeline status (`openspec status`) still shows 6 stages, unchanged — PASS/FAIL
* Generated `tasks.md` includes PR update as a standard task — PASS/FAIL
* When `gh` is unavailable, proposal creation completes without error — PASS/FAIL

## Non-Goals

- PR reviewer assignment or label management
- PR merge automation
- Branch protection or CI configuration
- Multi-PR or stacked-PR workflows
- Changes to pipeline stage count or dependency chain

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Inline PR in proposal instruction, not new artifact | User preference; preserves 6-stage pipeline; no schema structural change | New `pr-draft` artifact (rejected: heavier, changes pipeline), standalone skill (rejected: not enforced) |
| PR after proposal, not after research | Proposal content (Why, What, Impact) provides meaningful PR body | After research (rejected: no proposal content for PR body) |
| Constitution standard task for PR finalization | Fits existing pattern; project-specific (not all projects use GitHub); tracked in tasks.md | Universal template step (rejected: not all consumers use PRs), separate skill (rejected: not tracked) |
| Execute constitution extras during post-apply | Makes constitution extras actionable, not just documentation; consistent with universal steps | Leave unchecked (rejected: defeats purpose of having standard tasks) |
| Graceful degradation for `gh` CLI | Prevents blocking pipeline on external tool; supports diverse environments | Hard requirement (rejected: limits portability) |

## Risks & Trade-offs

- **`gh` CLI not available** → Mitigation: graceful degradation, branch created but PR skipped, noted in proposal.md
- **Network failure during push/PR** → Mitigation: record partial state, don't block pipeline
- **Branch naming collision** → Mitigation: change names are unique (enforced by `/opsx:new`), reuse existing branch if present
- **Constitution extras execution is a behavior change** → Mitigation: existing constitution extras (plugin update) already expect manual execution; documenting the new behavior in specs clarifies the change

## Open Questions

No open questions.

## Assumptions

- The git remote is configured and accessible for push operations. If not, branch creation succeeds locally but push and PR are skipped. <!-- ASSUMPTION: Git remote availability -->
No further assumptions beyond those marked above.
