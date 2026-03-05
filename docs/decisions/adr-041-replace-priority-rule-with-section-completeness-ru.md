# ADR-041: Replace priority rule with section-completeness rule

## Status
Accepted (2026-03-05)

## Context
Step 3 of the `/opsx:docs` skill contained a "space-constrained" priority rule that marked Known Limitations and Future Enhancements as `(optional)`, giving the agent permission to drop them. During a full QA cycle (delete all docs, regenerate, diff), 9 of 18 capability docs lost their Known Limitations section and 6 lost Future Enhancements. However, no capability doc exceeded 1.3 pages — the space constraint did not actually exist. The per-section maximum limits (Purpose max 3 sentences, Limitations max 5 bullets, etc.) were already sufficient conciseness guards. Research confirmed that the spec already described correct behavior (sections should be included when source data exists) but the SKILL.md contradicted it with the permissive priority rule. Replacing the priority rule with a section-completeness rule provides positive guidance ("include when data exists") rather than negative guidance ("drop when constrained").

## Decision
Replace the space-constrained priority rule with a section-completeness rule: include ALL template sections when source data exists, only omit when no data is available.

## Rationale
Positive guidance ("include when data exists") prevents section dropping without removing conciseness guards. Per-section max limits remain as secondary guards.

## Alternatives Considered
- Remove priority line entirely — leaves no guidance at all for the agent

## Consequences

### Positive
- Sections are no longer incorrectly dropped as optional
- Per-section max limits provide sufficient conciseness without a priority hierarchy
- Spec and SKILL.md are now aligned

### Negative
- Agent may still drop sections despite rule change; mitigated by imperative language ("SHALL include ALL sections") and existing per-section max limits

## References
- [Spec: user-docs](../../openspec/specs/user-docs/spec.md)
- [ADR-032: "Read before write" guardrail in SKILL.md](adr-032-read-before-write-guardrail-in-skill-md.md)
