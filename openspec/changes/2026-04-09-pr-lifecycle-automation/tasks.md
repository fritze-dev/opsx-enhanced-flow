# Implementation Tasks: PR Lifecycle Automation

## 1. Foundation

- [x] 1.1. Create action templates in `openspec/templates/`: `apply.md`, `verify.md`, `changelog.md`, `docs.md`, `version-bump.md` — each with `type: action`, `requires`, and `instruction` (extract from current `apply.instruction` prose + constitution conventions)
- [x] 1.2. Copy action templates to `src/templates/` (consumer copies)
- [x] 1.3. Restructure `openspec/WORKFLOW.md`: move `post_artifact` and `context` from frontmatter to body sections (`## Context`, `## Post-Artifact Hook`), remove `apply.instruction`, extend `pipeline` array, add `automation` block, bump `template-version` to 2
- [x] 1.4. Update `src/templates/workflow.md` (consumer template): mirror restructured frontmatter, add body sections, add commented `automation` block, bump `template-version` to 2

## 2. Implementation

### Skill Modifications
- [ ] 2.1. Update `src/skills/ff/SKILL.md`: add template type detection (`type: action`), sub-agent execution via Agent tool for action steps, read `## Context` and `## Post-Artifact Hook` from body instead of frontmatter, process full `pipeline` array, add `--auto-approve` flag support
- [ ] 2.2. Update `src/skills/apply/SKILL.md`: read `instruction` from `templates/apply.md` action template instead of `WORKFLOW.md` `apply.instruction`. Add fallback: if `apply.md` template not found, fall back to `apply.instruction` from WORKFLOW.md frontmatter (W4: backward compat for old consumers)
- [ ] 2.3. [P] Proof-of-concept: test that ff can spawn a sub-agent via the Agent tool when processing an action template (W3: verify assumption)

### CI Pipeline
- [ ] 2.4. Create `.github/workflows/pipeline.yml`: thin trigger YAML (~30 lines) — trigger on `pull_request_review: submitted`, check `reviewDecision == APPROVED`, run `claude-code-action` with `plugin_marketplaces: './'`, read WORKFLOW.md `automation.post_approval` config
- [ ] 2.5. [P] Create GitHub labels: `automation/running`, `automation/complete`, `automation/failed`

### Constitution & Conventions
- [ ] 2.6. Update `openspec/CONSTITUTION.md`: add `## CI Automation` section, add `## Worktree Lifecycle` section (move post-merge cleanup prose from old `apply.instruction`), update "Template synchronization" convention to reference new field structure (W2)

## 3. QA Loop & Human Approval

- [ ] 3.1. Metric Check:
  - [ ] ff with full pipeline completes all steps (research → version-bump) without manual intervention when `--auto-approve` is used — PASS / FAIL
  - [ ] Post-approval CI pipeline commits changelog + docs + version-bump to PR branch within one run — PASS / FAIL
  - [ ] Pipeline sets correct labels at each state — PASS / FAIL
  - [ ] Sub-agents receive bounded context (not full conversation) — PASS / FAIL
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
- [ ] 4.5. Update PR: mark ready for review, update body with change summary and issue references if applicable (`gh pr ready && gh pr edit --body "... Closes #60 Closes #37 Closes #38"`)

## 5. Post-Merge Reminders

- Update plugin locally (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`)
