# Implementation Tasks: Standard-Tasks

## 1. Schema & Template (universal steps)
- [x] 1.1. Add section 4 with universal standard tasks to `templates/tasks.md` (archive, changelog, docs, commit and push)
- [x] 1.2. [P] Update `schema.yaml` tasks instruction: clarify sync/archive exclusion rule and add standard tasks directive (include template steps + append constitution extras)
- [x] 1.3. [P] Update `schema.yaml` apply instruction: add scope clarification that standard tasks are not part of apply

## 2. Constitution (project-specific extras)
- [x] 2.1. Add `## Standard Tasks` section to `openspec/constitution.md` with project-specific extras only (plugin update)
- [x] 2.2. Trim the "Post-archive version bump" convention prose — keep auto-bump mechanism, remove next-steps workflow

## 3. QA Loop & Human Approval
- [x] 3.1. Metric Check:
  - [x] M1: Template contains "Standard Tasks (Post-Implementation)" section with universal steps — PASS
  - [x] M2: Apply instruction excludes standard tasks from apply scope — PASS
  - [x] M3: Schema task instruction includes standard tasks directive text — PASS
  - [x] M4: Schema apply instruction includes scope clarification text — PASS
- [x] 3.2. Auto-Verify: Run `/opsx:verify` — all checks passed
- [x] 3.3. User Testing: Approved by user.
- [x] 3.4. Fix Loop: Skipped — no issues found.
- [x] 3.5. Final Verify: Skipped — 3.4 was not entered.
- [x] 3.6. Approval: Approved.
