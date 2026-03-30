# Pre-Flight Check: Fix Issue Reference in PR Body

## A. Traceability Matrix

- [x] Requirement: Constitution Contains Only Project-Specific Rules (MODIFIED) → Scenario: PR body update includes issue-closing keywords → `openspec/CONSTITUTION.md` pre-merge task
- [x] Requirement: Constitution Contains Only Project-Specific Rules (MODIFIED) → Scenario: No issue linked — keywords omitted → `openspec/CONSTITUTION.md` pre-merge task

## B. Gap Analysis

No gaps. Two scenarios cover: issue-linked change (include keywords) and non-issue change (omit keywords).

## C. Side-Effect Analysis

- **No regression risk:** Only the wording of the pre-merge task text changes. No skill logic, no template, no pipeline change.
- **No other files affected:** Single-line text change in CONSTITUTION.md.

## D. Constitution Check

The constitution IS the target of this change. No additional constitution updates needed.

## E. Duplication & Consistency

- No overlapping stories.
- No contradictions with existing specs.

## F. Assumption Audit

No `<!-- ASSUMPTION -->` markers in delta spec or design.

## G. Review Marker Audit

No `<!-- REVIEW -->` markers found.
