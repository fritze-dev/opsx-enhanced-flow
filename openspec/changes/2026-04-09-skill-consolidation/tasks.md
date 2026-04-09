# Implementation Tasks: Skill Consolidation

## 1. Foundation

- [x] 1.1. Create `openspec/templates/review.md` — new artifact template with id, generates, requires, instruction, and report body structure (Summary, Findings, Verdict)
- [x] 1.2. Update `openspec/WORKFLOW.md` — template-version 3, pipeline with 7 stages (add review), add `actions:` section (init, apply, finalize), add `auto_approve` field, restructure frontmatter/body split (prose in body sections, structured config in frontmatter)
- [x] 1.3. Update `src/templates/workflow.md` — consumer template matching new WORKFLOW.md structure (with auto_approve commented out, worktree commented out)
- [x] 1.4. Copy `openspec/templates/review.md` to `src/templates/review.md` for consumer distribution

## 2. Implementation

### Router + Stubs
- [x] 2.1. Create `src/skills/router.md` — shared router logic (~80 lines): intent recognition, change context detection, WORKFLOW.md loading, dispatch to pipeline traversal (propose) or sub-agent (apply/finalize/init)
- [x] 2.2. Create `src/skills/propose/SKILL.md` — stub with frontmatter (name: propose) + "Read and follow src/skills/router.md"
- [x] 2.3. [P] Create `src/skills/apply/SKILL.md` — stub with frontmatter (name: apply) + "Read and follow src/skills/router.md"
- [x] 2.4. [P] Create `src/skills/finalize/SKILL.md` — stub with frontmatter (name: finalize) + "Read and follow src/skills/router.md"
- [x] 2.5. [P] Create `src/skills/init/SKILL.md` — stub with frontmatter (name: init) + "Read and follow src/skills/router.md"

### GitHub Actions
- [x] 2.6. Create `.github/workflows/pipeline.yml` — CI workflow triggered on PR approval, reads WORKFLOW.md automation config, executes finalize via claude-code-action, manages labels

### Remove Old Skills
- [x] 2.7. Remove old SKILL.md files: `src/skills/new/`, `src/skills/ff/`, `src/skills/verify/`, `src/skills/discover/`, `src/skills/preflight/`, `src/skills/changelog/`, `src/skills/docs/`, `src/skills/docs-verify/`, `src/skills/bootstrap/`, `src/skills/setup/`
- [x] 2.8. Keep `src/skills/apply/SKILL.md` (overwritten by 2.3) — ensure old content is replaced, not merged

### Update Constitution + Plugin Manifests
- [x] 2.9. Update `openspec/CONSTITUTION.md` — "Three-layer architecture" Layer 3 vocabulary (Router + Actions), skill immutability → router immutability, `/opsx:setup` → `/opsx:init`, update README accuracy convention
- [x] 2.10. Update `src/.claude-plugin/plugin.json` — version bump (2.0.0)
- [x] 2.11. Update `.claude-plugin/marketplace.json` — version sync (2.0.0)

### Update Docs
- [x] 2.12. Update `docs/README.md` — 4 commands, 12 specs, updated architecture description, updated Key Design Decisions table

## 3. QA Loop & Human Approval

- [ ] 3.1. Metric Check:
  - [ ] Only 4 commands registered (init, propose, apply, finalize) — PASS / FAIL
  - [ ] Orchestration code < 200 lines (router.md + stubs + WORKFLOW.md actions) — PASS / FAIL
  - [ ] review.md generated during apply — PASS / FAIL
  - [ ] Pipeline array has 7 entries ending with review — PASS / FAIL
  - [ ] 12 specs in openspec/specs/ — PASS / FAIL
- [ ] 3.2. Auto-Verify: Run `/opsx:verify`
- [ ] 3.3. User Testing: **Stop here!** Ask the user for manual approval.
- [ ] 3.4. Fix Loop: On verify issues or bug reports → fix code OR update specs/design → re-verify.
- [ ] 3.5. Final Verify: Run `/opsx:verify` after all fixes. Skip if 3.4 was not entered.
- [ ] 3.6. Approval: Only finish on explicit **"Approved"** by the user.

## 4. Standard Tasks (Post-Implementation)

- [ ] 4.1. Generate changelog (`/opsx:changelog`)
- [ ] 4.2. Generate/update docs (`/opsx:docs`)
- [ ] 4.3. Bump version
- [ ] 4.4. Commit and push to remote
- [ ] 4.5. Update PR: mark ready for review, update body with change summary and issue references if applicable (`gh pr ready && gh pr edit --body "... Closes #X"`)

## 5. Post-Merge Reminders

- Update plugin locally (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`)
