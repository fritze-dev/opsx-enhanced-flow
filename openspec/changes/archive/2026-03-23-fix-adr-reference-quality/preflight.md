# Pre-Flight Check: Fix ADR Reference Quality

## A. Traceability Matrix

- [x] Story: "formal decision records with internal-only references that are always valid" → Scenarios: internal links only, spec link validation, archive link validation, cross-reference, no speculative cross-refs → Component: `skills/docs/SKILL.md` Step 4 References

## B. Gap Analysis

- No gaps identified. All three root causes (broken spec links, external URLs, missing cross-refs) are addressed.
- Edge case coverage: spec splits, missing archives, manual ADRs, existing ADRs with external URLs.

## C. Side-Effect Analysis

- **ADR regeneration output changes**: Next full ADR regeneration will produce References without GitHub issue links. This is intentional — archive backlinks provide traceability.
- **README Key Design Decisions table**: Not affected — the table doesn't contain GitHub issue links.
- **Existing ADRs**: Already fixed manually in previous commit. Next regeneration will apply the new rules.

## D. Constitution Check

- No constitution changes needed. The skill immutability rule is respected — we're modifying SKILL.md instructions, not adding project-specific behavior.

## E. Duplication & Consistency

- The existing `decision-docs` spec has a References determination paragraph. The delta MODIFIED requirement replaces it with the internal-only + validation version. No duplication.
- The existing SKILL.md Step 4 References paragraph includes "If the design.md or research.md references GitHub Issues, include those too." This line must be removed as part of implementation.

## F. Assumption Audit

| # | Assumption | Source | Rating | Notes |
|---|-----------|--------|--------|-------|
| 1 | Spec renames/splits are infrequent and agent can determine successors from context | spec.md | Acceptable Risk | Major restructuring is rare; when it happens, agent can infer from archive content |
| 2 | Archive backlinks provide sufficient traceability to GitHub issues without direct links | design.md | Acceptable Risk | Archives always contain proposal.md which references issues when applicable |
