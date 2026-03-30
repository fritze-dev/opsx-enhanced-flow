# Implementation Tasks: Release Workflow

## 1. Foundation

- [x] 1.1. Fix `marketplace.json` version: update `"version": "1.0.0"` → `"1.0.3"` to match `plugin.json`

## 2. Implementation

- [x] 2.1. [P] Update `openspec/constitution.md`: replace manual version bump convention (line 35) with post-archive auto-bump convention — include version bump + marketplace.json sync + next steps output
- [x] 2.2. [P] Update `openspec/constitution.md`: add skill immutability rule under Architecture Rules
- [x] 2.3. Update `README.md`: improve "Updating the Plugin" section with clearer consumer update steps

## 3. QA Loop & Human Approval

- [x] 3.1. Metric Check:
  - [x] Constitution contains post-archive auto-bump convention — PASS
  - [x] Constitution contains skill immutability rule — PASS
  - [x] `marketplace.json` version matches `plugin.json` version — PASS
  - [x] Constitution no longer references manual version bumps — PASS
  - [x] README documents updated consumer workflow — PASS
- [x] 3.2. Auto-Verify: Run `/opsx:verify` — ALL PASSED, 0 critical, 0 warnings, 1 suggestion
- [x] 3.3. User Testing: Approved by user.
- [x] 3.4. Fix Loop: Spec cleaned up (non-plugin clause removed, E2E checklist added, unrealistic edge cases removed).
- [x] 3.5. Final Verify: Skipped — fixes were spec-only, no implementation changes needed.
- [x] 3.6. Approval: **Approved** by user.
