# Implementation Tasks: Spec Frontmatter Tracking

## 1. Foundation — Template Versioning

- [x] 1.1. Add `template-version: 1` to all 10 Smart Templates in `src/templates/` (research, proposal, specs/spec, design, preflight, tasks, docs/capability, docs/adr, docs/readme, constitution)
- [x] 1.2. Add `template-version: 1` to `src/templates/workflow.md` frontmatter
- [x] 1.3. [P] Mirror template-version changes to `openspec/templates/` (project copies)
- [x] 1.4. [P] Add `template-version: 1` to `openspec/WORKFLOW.md` frontmatter
- [x] 1.5. [P] Add `template-version: 1` frontmatter to `openspec/CONSTITUTION.md`

## 2. Foundation — Spec & Artifact Template Output

- [x] 2.1. Update spec template output structure in `src/templates/specs/spec.md` — add tracking fields (`status`, `change`, `version`, `lastModified`) to the optional frontmatter block
- [x] 2.2. Mirror spec template change to `openspec/templates/specs/spec.md`
- [x] 2.3. Update proposal template output structure in `src/templates/proposal.md` — add frontmatter block (`status`, `branch`, `worktree`, `capabilities`) to the template body (before `## Why`)
- [x] 2.4. Mirror proposal template change to `openspec/templates/proposal.md`
- [x] 2.5. Update design template output structure in `src/templates/design.md` — add `has_decisions` frontmatter to template body
- [x] 2.6. Mirror design template change to `openspec/templates/design.md`

## 3. Spec Migration

- [x] 3.1. Add `status: stable`, `version: 1`, `lastModified: 2026-04-08` to all 18 existing specs under `openspec/specs/*/spec.md`

## 4. Skill Updates — FF & New

- [x] 4.1. Update `src/skills/ff/SKILL.md` — during specs stage: set `status: draft`, `change: <change-dir>`, `lastModified: <today>` on edited specs; check for collision (existing draft from different change)
- [x] 4.2. Update `src/skills/ff/SKILL.md` — during proposal stage: include frontmatter with `status: active`, `branch`, `worktree` (if applicable), `capabilities` (from body)
- [x] 4.3. Update `src/skills/ff/SKILL.md` — during design stage: include `has_decisions` frontmatter
- [x] 4.4. Update `src/skills/new/SKILL.md` — set proposal frontmatter at change creation (when proposal is first generated)

## 5. Skill Updates — Verify & Preflight

- [x] 5.1. Update `src/skills/verify/SKILL.md` — read capabilities from proposal frontmatter (fallback to section parsing); add draft spec gate (CRITICAL if draft specs remain)
- [x] 5.2. Update `src/skills/verify/SKILL.md` — add verify completion step: flip spec `draft → stable`, bump `version`, set `lastModified`, set proposal `status: completed`
- [x] 5.3. Update `src/skills/preflight/SKILL.md` — add dimension G (Draft Spec Validation); read capabilities from proposal frontmatter (fallback to section parsing)

## 6. Skill Updates — Docs, Changelog, Apply, Discover, Docs-Verify

- [x] 6.1. [P] Update `src/skills/docs/SKILL.md` — use spec `lastModified` for incremental detection; read capabilities from proposal frontmatter; use design `has_decisions` for ADR skip
- [x] 6.2. [P] Update `src/skills/changelog/SKILL.md` — read proposal `status` for completed detection; read `capabilities` from proposal frontmatter (fallback to section parsing)
- [x] 6.3. [P] Update `src/skills/apply/SKILL.md` — read capabilities from proposal frontmatter (fallback to section parsing)
- [x] 6.4. [P] Update `src/skills/discover/SKILL.md` — read proposal `status` for active change detection
- [x] 6.5. [P] Update `src/skills/docs-verify/SKILL.md` — read proposal `status` for completed detection; use design `has_decisions` for ADR skip

## 7. Skill Updates — Setup (Template Merge)

- [x] 7.1. Update `src/skills/setup/SKILL.md` — replace `cp -r` template copy with template-version merge detection logic
- [x] 7.2. Update `src/skills/setup/SKILL.md` — replace WORKFLOW.md skip-if-exists with template-version merge detection
- [x] 7.3. Update `src/skills/setup/SKILL.md` — add CONSTITUTION.md section-level merge detection

## 8. QA Loop & Human Approval

- [x] 8.1. Metric Check: All 18 specs have `status: stable`, `version: 1`, `lastModified: 2026-04-08` — PASS
- [x] 8.2. Metric Check: All 11 templates + workflow.md have `template-version: 1` — PASS
- [x] 8.3. Metric Check: No skill parses `## Capabilities` section as primary detection (grep verification) — PASS
- [x] 8.4. Auto-Verify: Run `/opsx:verify`
- [ ] 8.5. User Testing: **Stop here!** Ask the user for manual approval.
- [ ] 8.6. Fix Loop: On verify issues or bug reports → fix code OR update specs/design → re-verify.
- [ ] 8.7. Final Verify: Run `/opsx:verify` after all fixes. Skip if 8.6 was not entered.
- [ ] 8.8. Approval: Only finish on explicit **"Approved"** by the user.

## 9. Standard Tasks (Post-Implementation)

- [ ] 9.1. Generate changelog (`/opsx:changelog`)
- [ ] 9.2. Generate/update docs (`/opsx:docs spec-format,artifact-generation,quality-gates,release-workflow,user-docs,workflow-contract,project-setup,change-workspace,artifact-pipeline`)
- [ ] 9.3. Bump version
- [ ] 9.4. Commit and push to remote
- [ ] 9.5. Update PR: mark ready for review, update body with change summary and issue references (`gh pr ready && gh pr edit --body "... Closes #78 Closes #67"`)

## 10. Post-Merge Reminders

- Update plugin locally (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`)
