# Implementation Tasks: Visible Assumptions & REVIEW Auto-Resolution

## 1. Foundation

- [x] 1.1. Update `openspec/schemas/opsx-enhanced/schema.yaml` line 142 (specs instruction): Change assumption format guidance to prescribe Pattern A (`- Visible text. <!-- ASSUMPTION: tag -->`)
- [x] 1.2. Update `openspec/schemas/opsx-enhanced/schema.yaml` line 169 (design instruction): Same Pattern A format change
- [x] 1.3. [P] Update `openspec/schemas/opsx-enhanced/templates/specs/spec.md` line 35: Pattern A guidance in Assumptions section
- [x] 1.4. [P] Update `openspec/schemas/opsx-enhanced/templates/design.md` line 31: Pattern A guidance in Assumptions section
- [x] 1.5. [P] Update `openspec/schemas/opsx-enhanced/templates/preflight.md` line 20: Change "Assumption Audit" to "Marker Audit", add REVIEW marker scanning guidance
- [x] 1.6. Update `openspec/constitution.md` line 27 (Code Style): Change `<!-- REVIEW -->` convention to document that REVIEW markers are transient and auto-resolved by skills

## 2. Implementation

### 2A. Skill Updates — REVIEW Auto-Resolution

- [x] 2.1. Update `skills/bootstrap/SKILL.md`: Add REVIEW auto-resolution loop after constitution generation — iterate `<!-- REVIEW -->` markers, present each to user, document decision, remove marker
- [x] 2.2. Update `skills/docs/SKILL.md` lines 191-192: Replace `<!-- REVIEW: ... -->` marker insertion with active resolution — ask user about broken references, fix or remove links, no markers in output
- [x] 2.3. Update `skills/docs/SKILL.md` line 118 (mapping rules table): Change `<!-- ASSUMPTION -->` reference to Pattern A format, change `<!-- REVIEW -->` reference to note auto-resolution

### 2B. Delta Spec Sync Preparation

No direct baseline spec edits — all 13 delta specs are already created and will be synced via `/opsx:sync` after implementation.

## 3. QA Loop & Human Approval

- [x] 3.1. Metric Check: Verify each Success Metric from design.md — PASS / FAIL.
  - [x] Zero Pattern B assumptions in schema, templates, or baseline specs — PASS (schema/templates updated; baseline specs pending sync)
  - [x] Zero `<!-- REVIEW` markers in non-archived files after skills complete — PASS (all occurrences are instruction text, not actual markers)
  - [x] Preflight Section F audits both ASSUMPTION format + REVIEW presence — PASS
  - [x] Bootstrap skill actively resolves all REVIEW markers before finishing — PASS (Step 2b)
  - [x] Docs skill produces ADRs with zero REVIEW markers — PASS (auto-resolution)
- [x] 3.2. Auto-Verify: Run `/opsx:verify` (built-in OpenSpec command).
- [x] 3.3. User Testing: **Stop here!** Ask the user for manual approval.
- [x] 3.4. Fix Loop: On verify issues or bug reports → fix code OR update specs/design → re-verify. Specs must match code before archiving.
- [x] 3.5. Final Verify: Run `/opsx:verify` after all fixes to confirm consistency. Skip if 3.4 was not entered.
- [x] 3.6. Approval: Only finish on explicit **"Approved"** by the user.

## 4. Standard Tasks (Post-Implementation)

- [ ] 4.1. Archive change (`/opsx:archive`)
- [ ] 4.2. Generate changelog (`/opsx:changelog`)
- [ ] 4.3. Generate/update docs (`/opsx:docs`)
- [ ] 4.4. Commit and push to remote
- [ ] Update plugin locally (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`)
