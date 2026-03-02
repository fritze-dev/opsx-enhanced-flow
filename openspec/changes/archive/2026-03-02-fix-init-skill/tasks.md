# Implementation Tasks: Fix init skill

## 1. Foundation

(no foundational work needed)

## 2. Implementation

- [x] 2.1. [P] Update `skills/init/SKILL.md`: set `disable-model-invocation: false`
- [x] 2.2. [P] Update `skills/init/SKILL.md`: remove Step 2 (`openspec init --tools claude`), renumber remaining steps
- [x] 2.3. [P] Update `skills/init/SKILL.md`: add `mkdir -p openspec/schemas/opsx-enhanced` before `cp -r` in schema copy step
- [x] 2.4. [P] Update `openspec/constitution.md` line 18: remove init exception from "All skills are model-invocable except `init`"

## 3. QA Loop & Human Approval

- [ ] 3.1. Auto-Verify: Run `/opsx:verify`
- [ ] 3.2. User Testing: **Stop here!** Ask the user for manual approval.
- [ ] 3.3. Fix Loop: On verify issues or bug reports → fix code OR update specs → re-verify.
- [ ] 3.4. Approval: Only finish on explicit **"Approved"** by the user.
