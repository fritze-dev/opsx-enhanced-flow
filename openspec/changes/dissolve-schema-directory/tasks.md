# Implementation Tasks: Dissolve Schema Directory

## 1. Foundation

- [x] 1.1. Create `openspec/WORKFLOW.md` with full pipeline config in YAML frontmatter (templates_dir, pipeline, apply, post_artifact, context, docs_language) and workflow overview in markdown body
- [x] 1.2. Create `openspec/templates/` directory and convert all 10 templates from `openspec/schemas/opsx-enhanced/templates/` to Smart Template format (add YAML frontmatter with id, description, generates, requires, instruction from schema.yaml)
- [x] 1.3. Rename `openspec/constitution.md` → `openspec/CONSTITUTION.md` and update content (Tech Stack, Architecture Rules, path references)
- [x] 1.4. Remove `openspec/schemas/` directory
- [x] 1.5. Remove `openspec/config.yaml`
- [x] 1.6. Remove `skills/continue/` directory

## 2. Implementation

### Skills (heavy changes)
- [ ] 2.1. Update `skills/ff/SKILL.md`: read WORKFLOW.md + Smart Templates instead of schema.yaml; add change-selection for existing changes; add template variable substitution; remove all schema.yaml/config.yaml references
- [ ] 2.2. Update `skills/setup/SKILL.md`: complete rewrite — copy templates/, generate WORKFLOW.md, create CONSTITUTION.md placeholder; add legacy migration logic; update validation
- [ ] 2.3. Update `skills/new/SKILL.md`: verify WORKFLOW.md instead of schema.yaml + config.yaml; update template paths

### Skills (path updates)
- [ ] 2.4. [P] Update `skills/apply/SKILL.md`: schema.yaml → WORKFLOW.md; `/opsx:continue` → `/opsx:ff`
- [ ] 2.5. [P] Update `skills/verify/SKILL.md`: schema.yaml → WORKFLOW.md
- [ ] 2.6. [P] Update `skills/archive/SKILL.md`: schema.yaml → WORKFLOW.md
- [ ] 2.7. [P] Update `skills/preflight/SKILL.md`: schema.yaml → WORKFLOW.md + Smart Template
- [ ] 2.8. [P] Update `skills/discover/SKILL.md`: schema.yaml → WORKFLOW.md + Smart Template
- [ ] 2.9. [P] Update `skills/bootstrap/SKILL.md`: constitution.md → CONSTITUTION.md; template path; `/opsx:continue` → `/opsx:ff`
- [ ] 2.10. [P] Update `skills/changelog/SKILL.md`: docs_language from WORKFLOW.md
- [ ] 2.11. [P] Update `skills/docs/SKILL.md`: docs_language from WORKFLOW.md; template paths
- [ ] 2.12. [P] Update `skills/sync/SKILL.md`: check for any schema.yaml/config.yaml references

### Documentation
- [ ] 2.13. Update `README.md`: plugin structure, skills table (12 not 13), 3-layer diagram, all continue references, path references
- [ ] 2.14. Close PR #27 with comment (superseded by this change)

## 3. QA Loop & Human Approval

- [ ] 3.1. Metric Check: Verify each Success Metric from design.md — PASS / FAIL
  - `openspec/schemas/` does not exist
  - `openspec/config.yaml` does not exist
  - `openspec/WORKFLOW.md` exists and readable
  - All Smart Templates have `id` field in frontmatter
  - No references to `schema.yaml`, `config.yaml`, `/opsx:continue` in skills (grep)
  - `skills/continue/` does not exist
  - `openspec/CONSTITUTION.md` exists
- [ ] 3.2. Auto-Verify: Run `/opsx:verify`
- [ ] 3.3. User Testing: **Stop here!** Ask the user for manual approval.
- [ ] 3.4. Fix Loop: On verify issues or bug reports → fix code OR update specs/design → re-verify.
- [ ] 3.5. Final Verify: Run `/opsx:verify` after all fixes. Skip if 3.4 was not entered.
- [ ] 3.6. Approval: Only finish on explicit **"Approved"** by the user.

## 4. Standard Tasks (Post-Implementation)

- [ ] 4.1. Archive change (`/opsx:archive`)
- [ ] 4.2. Generate changelog (`/opsx:changelog`)
- [ ] 4.3. Generate/update docs (`/opsx:docs`)
- [ ] 4.4. Commit and push to remote
- [ ] 4.5. Update PR: mark ready for review, update body with change summary (`gh pr ready && gh pr edit --body "..."`)
- [ ] 4.6. _(Post-Merge)_ Update plugin locally (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`)
