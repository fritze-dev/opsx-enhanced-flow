# Implementation Tasks: Eliminate Delta-Specs, Sync & Archive

## 1. Foundation

- [x] 1.1. Migrate existing archives: `mv openspec/changes/archive/* openspec/changes/` and `rmdir openspec/changes/archive`
- [x] 1.2. Delete `src/skills/sync/SKILL.md` (sync skill removed)
- [x] 1.3. Delete `src/skills/archive/SKILL.md` (archive skill removed)
- [x] 1.4. Delete `openspec/specs/spec-sync/` directory (capability removed)

## 2. Implementation

### Skills
- [x] 2.1. Update `src/skills/new/SKILL.md` — date-prefixed directory creation (`YYYY-MM-DD-<name>`), add lazy worktree cleanup step before creation
- [x] 2.2. Update `src/skills/ff/SKILL.md` — specs stage edits `openspec/specs/<cap>/spec.md` directly; no delta spec creation; post-artifact hook stages `openspec/specs/` too
- [x] 2.3. Update `src/skills/apply/SKILL.md` — read baseline specs for context (proposal Capabilities → spec paths); change detection for date-prefixed dirs with active status; allow spec edits during implementation
- [x] 2.4. Update `src/skills/verify/SKILL.md` — verify against baseline specs; remove sync/archive references; change detection for date-prefixed dirs
- [x] 2.5. Update `src/skills/changelog/SKILL.md` — glob `openspec/changes/*/` instead of `archive/*/`; filter by completed status (all tasks checked); read proposal.md + current baseline specs for content
- [x] 2.6. Update `src/skills/docs/SKILL.md` — incremental detection: scan `openspec/changes/*/proposal.md` Capabilities for affected capabilities; enrichment reads from change dirs; add fallback for proposals without structured Capabilities section (fall back to full regeneration)
- [x] 2.7. Update `src/skills/docs-verify/SKILL.md` — glob `openspec/changes/*/design.md` instead of `archive/*/design.md`
- [x] 2.8. Update `src/skills/preflight/SKILL.md` — traceability checks baseline specs directly; use proposal Capabilities for identifying which specs should have been updated
- [x] 2.9. [P] Update `src/skills/discover/SKILL.md` — context loading guardrails: exclude other completed changes; change selection filters to active changes
- [x] 2.10. [P] Update `src/skills/bootstrap/SKILL.md` — change directory uses date prefix if creating changes

### Templates
- [x] 2.11. Update `src/templates/specs/spec.md` — remove ADDED/MODIFIED/REMOVED/RENAMED sections and delta-format instructions; replace with "edit baseline specs directly" instruction
- [x] 2.12. Update `src/templates/tasks.md` — remove sync/archive from instructions and standard tasks; update baseline spec exclusion note to allow direct edits

### Configuration
- [x] 2.13. Update `openspec/WORKFLOW.md` — remove sync/archive from post-apply workflow; update `post_artifact` to also stage `openspec/specs/`; remove sync references from apply.instruction
- [x] 2.14. Update `openspec/CONSTITUTION.md` — remove delta-spec, archive, sync references from Architecture Rules; update standard tasks (remove archive step); update version bump convention to reference post-apply workflow instead of post-archive

### Documentation
- [x] 2.15. Update `README.md` — reflect new simplified workflow (no sync, no archive, direct spec editing)

## 3. QA Loop & Human Approval

- [x] 3.1. Metric Checks:
  - `/opsx:ff` edits specs directly — no `specs/` subdir in change dir: PASS / FAIL
  - `src/skills/sync/SKILL.md` and `src/skills/archive/SKILL.md` deleted: PASS / FAIL
  - `/opsx:changelog` finds completed changes in `openspec/changes/*/`: PASS / FAIL
  - `/opsx:docs` incremental detection works via proposal Capabilities: PASS / FAIL
  - All 37 archives migrated from `archive/` to `changes/`: PASS / FAIL
  - `/opsx:new` creates `YYYY-MM-DD-<name>` directory: PASS / FAIL
  - Lazy worktree cleanup detects merged branches: PASS / FAIL
- [x] 3.2. Auto-Verify: Run `/opsx:verify`
- [ ] 3.3. User Testing: **Stop here!** Ask the user for manual approval.
- [ ] 3.4. Fix Loop: On verify issues or bug reports → fix code OR update specs/design → re-verify.
- [ ] 3.5. Final Verify: Run `/opsx:verify` after all fixes. Skip if 3.4 was not entered.
- [ ] 3.6. Approval: Only finish on explicit **"Approved"** by the user.

## 4. Standard Tasks (Post-Implementation)

- [x] 4.1. Generate changelog (`/opsx:changelog`)
- [x] 4.2. Generate/update docs (`/opsx:docs change-workspace,artifact-pipeline,artifact-generation,quality-gates,task-implementation,release-workflow,user-docs,interactive-discovery`)
- [x] 4.3. Bump version in `src/.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`
- [x] 4.4. Commit and push to remote

### Pre-Merge
- [ ] 4.5. Update PR: mark ready for review, update body with change summary and issue references if applicable (`gh pr ready && gh pr edit --body "... Closes #X"`)

### Post-Merge
- [ ] 4.6. Update plugin locally (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`)
