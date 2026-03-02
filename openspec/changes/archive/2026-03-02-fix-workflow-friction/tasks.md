# Tasks: Fix Workflow Friction

## 1. Rule Ownership Restructuring

- [x] Simplify `openspec/config.yaml` to bootstrap-only: schema ref + constitution pointer
- [x] Remove 12 redundancies from `openspec/constitution.md`
- [x] Add DoD-emergent rule to `tasks.instruction` in schema.yaml
- [x] Add post-apply workflow sequence to `apply.instruction` in schema.yaml
- [x] Add friction tracking convention to `openspec/constitution.md` Conventions section

## 2. README & Version

- [x] Update Development & Testing section in `README.md`
- [x] Bump version in `.claude-plugin/plugin.json` from `1.0.1` to `1.0.2`

## 3. Init Skill

- [x] Update init skill to generate minimal config template (schema + constitution pointer) instead of copying project config

## 4. Artifact Updates

- [x] Update proposal.md, delta specs, design.md to reflect actual changes

## 5. QA Loop

- [x] **Metric Check:** Verify success metrics M1–M7 — all PASS
- [x] **Auto-Verify:** Run `/opsx:verify` — all checks passed
- [x] **User Testing:** Review all changed files for accuracy and consistency
- [x] **Approval:** Approved by user
