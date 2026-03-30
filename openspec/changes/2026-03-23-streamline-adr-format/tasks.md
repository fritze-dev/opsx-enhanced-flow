# Implementation Tasks: Streamline ADR Format

## 1. Foundation

(No foundational tasks — all changes are independent edits to existing files.)

## 2. Implementation

- [x] 2.1. [P] Update ADR template (`openspec/schemas/opsx-enhanced/templates/docs/adr.md`): remove `## Rationale` section, add inline-rationale em-dash pattern to `## Decision` section
- [x] 2.2. [P] Update SKILL.md Step 4: generalize inline-rationale to all ADR types (not just consolidated), remove references to separate Rationale section, update Language-Aware heading list to 6 headings (drop "Rationale"/"Begründung")
- [x] 2.3. [P] Update SKILL.md Step 5: change Key Design Decisions table data source from design.md archives to ADR files; describe extraction for generated ADRs (inline rationale via em-dash) and manual ADRs (`## Rationale` section)

## 3. QA Loop & Human Approval

- [x] 3.1. Metric Check:
  - [x] M1: ADR template has no `## Rationale` section — PASS
  - [x] M2: ADR template Decision section shows inline-rationale pattern — PASS
  - [x] M3: SKILL.md Step 4 describes inline-rationale for all ADR types; no mention of separate Rationale section — PASS
  - [x] M4: Language-Aware ADR heading list excludes "Rationale" (6 headings: Status, Context, Decision, Alternatives Considered, Consequences, References) — PASS
  - [x] M5: SKILL.md Step 5 sources Key Design Decisions table from ADR files, not design.md — PASS
- [x] 3.2. Auto-Verify: Run `/opsx:verify`
- [x] 3.3. User Testing: **Stop here!** Ask the user for manual approval.
- [x] 3.4. Fix Loop: Skipped — no issues found.
- [x] 3.5. Final Verify: Skipped — 3.4 was not entered.
- [x] 3.6. Approval: User approved ("weiter").
