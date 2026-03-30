# Implementation Tasks: Constitution Template Extraction

## 1. Foundation

- [x] 1.1. Create `openspec/schemas/opsx-enhanced/templates/constitution.md` with the section headings and guidance comments currently hardcoded in `skills/bootstrap/SKILL.md` lines 47-69

## 2. Implementation

- [x] 2.1. Update `skills/bootstrap/SKILL.md` Step 2 to reference the schema's `templates/constitution.md` template instead of the inline markdown block
- [x] 2.2. Remove the inline constitution markdown block from `skills/bootstrap/SKILL.md`

## 3. QA Loop & Human Approval

- [x] 3.1. Metric Check: Verify `templates/constitution.md` exists with exactly 6 sections (Tech Stack, Architecture Rules, Code Style, Constraints, Conventions, Standard Tasks) — PASS
- [x] 3.2. Metric Check: Verify `SKILL.md` no longer contains inline constitution section definitions — PASS
- [x] 3.3. Metric Check: Verify `SKILL.md` references the schema template path — PASS
- [x] 3.4. Auto-Verify: Run `/opsx:verify` (built-in OpenSpec command).
- [x] 3.5. User Testing: **Stop here!** Ask the user for manual approval.
- [x] 3.6. Fix Loop: On verify issues or bug reports → fix code OR update specs/design → re-verify. Specs must match code before archiving.
- [x] 3.7. Final Verify: Run `/opsx:verify` after all fixes to confirm consistency. Skip if 3.6 was not entered.
- [x] 3.8. Approval: Only finish on explicit **"Approved"** by the user.

## 4. Standard Tasks (Post-Implementation)

- [x] 4.1. Archive change (`/opsx:archive`)
- [x] 4.2. Generate changelog (`/opsx:changelog`)
- [x] 4.3. Generate/update docs (`/opsx:docs`)
- [x] 4.4. Commit and push to remote
- [x] 4.5. Update plugin locally (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`)
