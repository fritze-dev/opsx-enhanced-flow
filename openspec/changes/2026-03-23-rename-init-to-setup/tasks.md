# Implementation Tasks: Rename init skill to setup

## 1. Foundation
- [x] 1.1. Rename skill directory: `git mv skills/init skills/setup`
- [x] 1.2. Update `skills/setup/SKILL.md`: frontmatter `name: init` → `name: setup`, heading, and all self-references (`/opsx:init` → `/opsx:setup`)

## 2. Implementation
- [x] 2.1. [P] Update `README.md`: replace all `/opsx:init` → `/opsx:setup` references
- [x] 2.2. [P] Update `openspec/schemas/opsx-enhanced/README.md`: replace `/opsx:init` → `/opsx:setup`
- [x] 2.3. [P] Update baseline specs — replace `/opsx:init` → `/opsx:setup` and `skills/init/` → `skills/setup/` in:
  - `openspec/specs/project-setup/spec.md`
  - `openspec/specs/three-layer-architecture/spec.md`
  - `openspec/specs/project-bootstrap/spec.md`
  - `openspec/specs/interactive-discovery/spec.md`
  - `openspec/specs/constitution-management/spec.md`
  - `openspec/specs/change-workspace/spec.md`
  - `openspec/specs/release-workflow/spec.md`
  - `openspec/specs/user-docs/spec.md`
- [x] 2.4. [P] Update user docs — replace `/opsx:init` → `/opsx:setup` in:
  - `docs/README.md`
  - `docs/capabilities/project-setup.md`
  - `docs/capabilities/project-bootstrap.md`
  - `docs/capabilities/release-workflow.md`
  - `docs/capabilities/constitution-management.md`
  - `docs/capabilities/interactive-discovery.md`
- [x] 2.5. [P] Update other skills — replace `/opsx:init` → `/opsx:setup` in:
  - `skills/bootstrap/SKILL.md`
  - `skills/docs/SKILL.md`
  - `skills/discover/SKILL.md`
  - `skills/preflight/SKILL.md`
  - `skills/changelog/SKILL.md`

## 3. QA Loop & Human Approval
- [x] 3.1. Metric Check: No stale `/opsx:init` references outside archives/CHANGELOG/ADRs — PASS
- [x] 3.2. Metric Check: No stale `skills/init` path references outside archives/CHANGELOG/ADRs — PASS
- [x] 3.3. Metric Check: `skills/setup/SKILL.md` exists with `name: setup` — PASS
- [x] 3.4. Metric Check: `skills/init/` does not exist — PASS
- [x] 3.5. Metric Check: Archives untouched (`git diff openspec/changes/archive/` shows no changes) — PASS
- [x] 3.6. Auto-Verify: Run `/opsx:verify` (built-in OpenSpec command).
- [x] 3.7. User Testing: **Stop here!** Ask the user for manual approval.
- [x] 3.8. Fix Loop: No issues found — skipped.
- [x] 3.9. Final Verify: Skipped (3.8 not entered).
- [x] 3.10. Approval: Approved by user.
