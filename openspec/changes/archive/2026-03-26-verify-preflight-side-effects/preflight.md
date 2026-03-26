# Pre-Flight Check: Verify Preflight Side-Effect Cross-Check

## A. Traceability Matrix

| Requirement | Scenario | Component |
|-------------|----------|-----------|
| Post-Implementation Verification (MODIFIED) | Verification with all checks passing | `skills/verify/SKILL.md` step 8 (report) |
| Post-Implementation Verification (MODIFIED) | Verification finds critical issues | `skills/verify/SKILL.md` step 8 (report) |
| Post-Implementation Verification (MODIFIED) | Verification finds implementation diverging from spec | `skills/verify/SKILL.md` step 6 (correctness) |
| Post-Implementation Verification (MODIFIED) | Verification finds code pattern inconsistency | `skills/verify/SKILL.md` step 7 (coherence) |
| Post-Implementation Verification (MODIFIED) | Graceful degradation with missing artifacts | `skills/verify/SKILL.md` step 3 (load) |
| Post-Implementation Verification (MODIFIED) | Verification with no delta specs | `skills/verify/SKILL.md` step 5 (completeness) |
| Post-Implementation Verification (MODIFIED) | Final verify confirms fix loop resolved all issues | `skills/verify/SKILL.md` step 8 (report) |
| Post-Implementation Verification (MODIFIED) | Side-effect from preflight not addressed | `skills/verify/SKILL.md` new step 8 (side-effects) |
| Post-Implementation Verification (MODIFIED) | Side-effect addressed in code but not as task | `skills/verify/SKILL.md` new step 8 (side-effects) |
| Post-Implementation Verification (MODIFIED) | Preflight Section C has no side-effects | `skills/verify/SKILL.md` new step 8 (side-effects) |

All 10 scenarios map to components. 3 new scenarios (side-effect related) map to the new step 8.

## B. Gap Analysis

No gaps identified:
- Happy path (no side-effects) covered by "Preflight Section C has no side-effects" scenario
- Unaddressed side-effect covered by "Side-effect from preflight not addressed" scenario
- Code-only evidence covered by "Side-effect addressed in code but not as task" scenario
- Generic/ambiguous keywords covered by edge case "Side-effect keyword ambiguity"
- Existing scenarios (all checks passing, critical issues, divergence, pattern inconsistency, graceful degradation, no delta specs, final verify) are unchanged and carried forward

## C. Side-Effect Analysis

| Risk | Assessment |
|------|------------|
| Regression to existing verify behavior | **LOW** — existing steps 1-7 are unchanged; new step 8 is additive after Coherence |
| Breaking existing verify output format | **NONE** — report format is extended (new section), not modified |
| Impact on other skills | **NONE** — only `skills/verify/SKILL.md` is modified; no other skill reads it |
| Spec sync side-effects | **NONE** — delta spec uses MODIFIED correctly; existing scenarios preserved verbatim |

Result: No significant regression risk. Change is purely additive.

## D. Constitution Check

| Rule | Status |
|------|--------|
| Skill immutability | **OK** — verify is a generic skill; this change extends its generic behavior, not project-specific customization |
| Three-layer architecture | **OK** — skill reads preflight.md (an artifact), consistent with existing pattern of reading specs/design/tasks |
| Baseline spec format | **OK** — delta spec uses MODIFIED header correctly |
| No ADR references in specs | **OK** — no ADR references in delta spec |

No constitution updates needed — no new technologies or patterns introduced.

## E. Duplication & Consistency

- No overlap with other capabilities — side-effect cross-check is unique to verify
- Delta spec is consistent with existing quality-gates spec: same severity model (CRITICAL/WARNING/SUGGESTION), same heuristic philosophy
- New assumption (Section C format) is consistent with existing assumption style

## F. Assumption Audit

| # | Assumption | Source | Rating |
|---|-----------|--------|--------|
| 1 | The OpenSpec CLI provides accurate artifact dependency and status information. | spec.md | Acceptable Risk |
| 2 | Keyword-based code search provides reasonable (not perfect) implementation coverage detection. | spec.md | Acceptable Risk |
| 3 | constitution.md is the authoritative source for project rules and is kept up to date. | spec.md | Acceptable Risk |
| 4 | The codebase is accessible and searchable for verification of requirement implementation. | spec.md | Acceptable Risk |
| 5 | Preflight Section C uses a consistent structure (table or list with risk descriptions and assessments) that can be parsed for side-effect extraction. | spec.md | Acceptable Risk |
| 6 | Preflight Section C uses a recognizable structure (table with risk/assessment columns, or bulleted list) across all changes. | design.md | Acceptable Risk |

Assumptions 5 and 6 are overlapping (same concern from spec and design). Both are Acceptable Risk — Section C structure is defined by the preflight template, so format is predictable.

All assumptions have visible text before the HTML comment tag. Format: valid.

## G. Review Marker Audit

Scanned: `specs/quality-gates/spec.md`, `design.md`

No `<!-- REVIEW -->` or `<!-- REVIEW: ... -->` markers found.

---

**Verdict: PASS**

0 blockers, 0 warnings. Ready for task creation.
