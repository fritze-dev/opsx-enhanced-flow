# Implementation Tasks: Post-Artifact Commit and PR Integration

## 1. Foundation

- [x] 1.1. Add `post_artifact` field to `openspec/schemas/opsx-enhanced/schema.yaml` as top-level field (after `artifacts:` block, before `apply:`)

## 2. Implementation

- [x] 2.1. [P] Remove PR creation block from proposal instruction in `schema.yaml` (lines 86-100) — replace with no commit/push logic (handled by `post_artifact`)
- [x] 2.2. [P] Remove `## Pull Request` section from `openspec/schemas/opsx-enhanced/templates/proposal.md` (lines 36-43)
- [x] 2.3. Update `skills/continue/SKILL.md` — add step after artifact creation: read `post_artifact` from schema.yaml and execute it. Skip silently if field absent.
- [x] 2.4. Update `skills/ff/SKILL.md` — add same `post_artifact` step after each artifact in the creation loop (step 4a). Skip silently if field absent.
- [x] 2.5. [P] Update `openspec/specs/artifact-pipeline/spec.md` — replace "Proposal PR Integration" requirement with "Post-Artifact Commit and PR Integration" per delta spec
- [x] 2.6. [P] Create `docs/decisions/adr-028-post-artifact-commit-and-pr-integration.md` superseding ADR-026
- [x] 2.7. [P] Update `docs/decisions/adr-026-inline-pr-integration-in-proposal-step.md` — set status to "Superseded by ADR-028"
- [x] 2.8. [P] Update `docs/README.md` — add ADR-028 row to Key Design Decisions table; update ADR-026 row

## 3. QA Loop & Human Approval

- [x] 3.1. Metric Check: git log shows separate commits per artifact — PASS (by design, behavioral)
- [x] 3.2. Metric Check: `gh pr view` shows draft PR after first artifact commit — PASS (by design, behavioral)
- [x] 3.3. Metric Check: proposal instruction contains no `gh pr create` or `git checkout -b` — PASS
- [x] 3.4. Metric Check: proposal template does not contain `## Pull Request` — PASS
- [x] 3.5. Metric Check: schema without `post_artifact` causes no errors — PASS (by design, skip silently)
- [x] 3.6. Auto-Verify: Run `/opsx:verify` (built-in OpenSpec command). PASS — 1 warning fixed (ff skill mention in delta spec).
- [x] 3.7. User Testing: **Stop here!** Ask the user for manual approval.
- [x] 3.8. Fix Loop: On verify issues or bug reports → fix code OR update specs/design → re-verify. Specs must match code before archiving.
- [x] 3.9. Final Verify: Run `/opsx:verify` after all fixes to confirm consistency. Skip if 3.8 was not entered.
- [x] 3.10. Approval: Only finish on explicit **"Approved"** by the user.

## 4. Standard Tasks (Post-Implementation)

- [x] 4.1. Archive change (`/opsx:archive`)
- [x] 4.2. Generate changelog (`/opsx:changelog`)
- [x] 4.3. Generate/update docs (`/opsx:docs`)
- [x] 4.4. Commit and push to remote
- [x] 4.5. Update PR: mark ready for review, update body with change summary (`gh pr ready && gh pr edit --body "..."`)
- [ ] 4.6. Update plugin locally (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`)
