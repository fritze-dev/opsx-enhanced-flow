# Implementation Tasks: Transparent Project Knowledge Management

## 1. Foundation

- [x] 1.1. Create `src/templates/claude.md` — bootstrap template with frontmatter (`id: claude`, `generates: CLAUDE.md`, `requires: []`) and standard CLAUDE.md content (Workflow + Knowledge Management sections)

## 2. Implementation

- [x] 2.1. [P] Add `## Knowledge Management` section to `CLAUDE.md` after the existing `## Workflow` section
- [x] 2.2. [P] Add `- **Knowledge transparency:** ...` convention entry to `openspec/CONSTITUTION.md` Conventions section (after "Workflow friction")
- [x] 2.3. [P] Update init instruction in `openspec/WORKFLOW.md` — add "and CLAUDE.md" to Fresh mode line
- [x] 2.4. Sync init instruction change to `src/templates/workflow.md` (template synchronization convention)

## 3. QA Loop & Human Approval

- [x] 3.1. Metric Check:
  - [x] CLAUDE.md contains `## Workflow` and `## Knowledge Management` sections — PASS
  - [x] CONSTITUTION.md Conventions section contains `Knowledge transparency` entry — PASS
  - [x] `src/templates/claude.md` exists with correct frontmatter (`id: claude`, `generates: CLAUDE.md`) — PASS
  - [x] WORKFLOW.md init instruction mentions CLAUDE.md generation — PASS
  - [x] `src/templates/workflow.md` init instruction matches WORKFLOW.md — PASS
- [x] 3.2. Auto-Verify: generate review.md using the review template.
- [x] 3.3. User Testing: **Stop here!** Ask the user for manual approval.
- [x] 3.4. Fix Loop: On verify issues or bug reports → fix code OR update specs/design → re-verify. Specs must match code before proceeding.
- [x] 3.5. Final Verify: regenerate review.md after all fixes to confirm consistency. Skip if 3.4 was not entered.
- [x] 3.6. Approval: Only finish on explicit **"Approved"** by the user.

## 4. Standard Tasks (Post-Implementation)

- [x] 4.1. Run `/opsx:workflow finalize` (generates changelog and updates docs)
- [x] 4.2. Bump version
- [x] 4.3. Commit and push to remote
- [x] 4.4. Update PR: mark ready for review, update body with change summary and issue references if applicable (`gh pr ready && gh pr edit --body "... Closes #69"`)

## 5. Post-Merge Reminders

- Update plugin locally (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`)
- Delete redundant memory files from `~/.claude/projects/-home-robinfritze-projekte-opsx-enhanced-flow/memory/`
