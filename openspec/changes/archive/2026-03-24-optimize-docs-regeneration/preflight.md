# Pre-Flight Check: Optimize Docs Regeneration

## A. Traceability Matrix

- [x] Incremental Capability Documentation Generation (MODIFIED) → Scenario: Multi-capability mode processes only listed capabilities → `skills/docs/SKILL.md` Input + Step 1
- [x] Incremental Capability Documentation Generation (MODIFIED) → Scenario: Multi-capability mode with nonexistent capability → `skills/docs/SKILL.md` Step 1
- [x] Incremental Capability Documentation Generation (MODIFIED) → All existing scenarios preserved → backward compatible

## B. Gap Analysis

No gaps. Existing single-capability and no-argument modes unchanged. Multi-capability mode is a superset of single-capability mode.

## C. Side-Effect Analysis

- **Existing `/opsx:docs` calls**: No impact — no argument = full scan (unchanged)
- **Post-archive workflow**: Can now pass affected capabilities directly, but not required to

## D. Constitution Check

No constitution updates needed.

## E. Duplication & Consistency

No overlapping stories. Single delta spec for `user-docs` only. Consistent with existing incremental generation pattern.

## F. Assumption Audit

| # | Assumption | Source | Rating |
|---|-----------|--------|--------|
| 1 | Post-archive caller can determine affected capabilities from archived change's specs/ directory | delta spec | Acceptable Risk — archive skill already lists delta specs |
| 2 | No capability name contains commas | design.md | Acceptable Risk — kebab-case naming convention excludes commas |

---

**Verdict: PASS**
