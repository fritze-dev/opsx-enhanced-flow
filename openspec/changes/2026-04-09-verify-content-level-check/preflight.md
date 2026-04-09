# Pre-Flight Check: Verify Content-Level Check

## A. Traceability Matrix

- [x] Modified Capability: quality-gates → Post-Implementation Verification requirement → `src/skills/verify/SKILL.md` steps 5–7 + Verification Heuristics
  - Proposal "Enhance verify skill instructions" → Design "read-then-compare pattern" → Skill instruction edits in steps 5, 6, 7, and heuristics section

## B. Gap Analysis

No gaps identified:
- The change targets only skill instruction text — no edge cases around data models, APIs, or error handling
- Graceful degradation behavior is unchanged (existing fallback logic remains)
- The read-then-compare pattern includes fallback to keyword search for file discovery, covering the case where implementation files can't be directly identified

## C. Side-Effect Analysis

| Area | Risk | Assessment |
|------|------|------------|
| Other verify steps (1–4, 8–9) | Unintended changes to change detection, artifact loading, side-effect cross-check, or report generation | NONE — changes are scoped to steps 5–7 and heuristics only |
| Verify report format | Report structure could change | NONE — report format is untouched; only the verification methodology changes |
| Other skills reading verify output | Skills that depend on verify report format | NONE — no other skill parses verify output programmatically |
| Performance on large codebases | Reading files instead of grepping could be slower | LOW — existing "focus on referenced files" constraint remains; new instructions say "identify file first, then read relevant section" |
| Consumer projects | All consumers use the same verify skill | POSITIVE — improved accuracy benefits all consumers equally |

## D. Constitution Check

- Skill immutability rule: "Skills in `skills/` are generic plugin code shared across all consumers. They MUST NOT be modified for project-specific behavior." — **Compliant.** This change improves generic verification accuracy, not project-specific behavior.
- Template synchronization convention: Not applicable — verify is a skill, not a template.
- No new patterns or technologies introduced — no constitution update needed.

## E. Duplication & Consistency

- No overlapping changes with other specs or pending changes
- The quality-gates spec's Post-Implementation Verification requirement already uses "accuracy" language — the skill instruction changes are consistent with the spec's intent
- No contradictions between the design decisions and existing specs

## F. Assumption Audit

No `<!-- ASSUMPTION -->` markers in spec changes (no spec changes made).
No `<!-- ASSUMPTION -->` markers in design.md.

Verdict: No assumptions to audit.

## G. Review Marker Audit

No `<!-- REVIEW -->` or `<!-- REVIEW: ... -->` markers found in any change artifacts.

---

**Verdict: PASS**

0 blockers, 0 warnings, 0 suggestions. All traceability checks satisfied, no side-effects requiring mitigation, constitution compliance confirmed.
