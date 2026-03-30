# Implementation Tasks: Fix Apply Baseline Edits

## 1. Foundation

(No foundation tasks — all changes are additive text edits to existing files.)

## 2. Implementation

- [x] 2.1. [P] Extend the IMPORTANT block in `openspec/schemas/opsx-enhanced/schema.yaml` (task instruction, lines 180–184) to also exclude baseline spec edits. Add: "Do NOT include tasks that edit baseline specs under `openspec/specs/`. Baseline spec changes flow exclusively through delta specs and `/opsx:sync`."
- [x] 2.2. [P] Add a guardrail to `skills/apply/SKILL.md` (guardrails section) stating: "Do not modify files under `openspec/specs/` during apply — spec changes flow through `/opsx:sync`."
- [x] 2.3. [P] Add the "Baseline Spec Exclusion from Implementation Scope" requirement to `openspec/specs/task-implementation/spec.md` with both scenarios and edge cases from the delta spec. Note: this is a baseline spec edit, but it is the implementation target of this change — the delta spec documents the intent, and sync will reconcile.

## 3. QA Loop & Human Approval

- [x] 3.1. Metric Check: Task generation instruction explicitly excludes baseline spec file edits — PASS / FAIL. Apply skill guardrails include baseline spec exclusion — PASS / FAIL. Task-implementation spec includes the new requirement with scenarios — PASS / FAIL.
- [x] 3.2. Auto-Verify: Run `/opsx:verify` (built-in OpenSpec command).
- [x] 3.3. User Testing: **Stop here!** Ask the user for manual approval.
- [x] 3.4. Fix Loop: On verify issues or bug reports → fix code OR update specs/design → re-verify. Specs must match code before archiving.
- [x] 3.5. Final Verify: Run `/opsx:verify` after all fixes to confirm consistency. Skip if 3.4 was not entered.
- [x] 3.6. Approval: Only finish on explicit **"Approved"** by the user.
