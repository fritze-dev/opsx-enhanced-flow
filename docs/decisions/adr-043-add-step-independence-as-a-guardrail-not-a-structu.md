# ADR-043: Add step independence as a guardrail, not a structural change

## Status
Accepted (2026-03-05)

## Context
The implicit dependency between Step 4 and Step 2 revealed a general risk: any step that depends on data loaded by a previous step will fail when executed independently (e.g., in a subagent). Rather than restructuring all steps into fully self-contained units (Approach C from research), a guardrail rule in the SKILL.md Guardrails section was chosen. Research showed that only Step 4 currently suffers from this problem, so a full restructure adds scope without immediate benefit. The guardrail catches future regressions in other steps by establishing a principle. If the guardrail proves insufficient, per-step restructure is the documented escalation path, which also aligns with the planned transition to autonomous agents.

## Decision
Add step independence as a guardrail rule in SKILL.md's Guardrails section, rather than restructuring all steps into self-contained units.

## Rationale
A guardrail rule is simpler and matches the existing SKILL.md structure. If insufficient, per-step restructure is the documented fallback for autonomous agent readiness.

## Alternatives Considered
- Restructure all steps into self-contained subagent instructions — more robust but unnecessary scope for the current single-step problem

## Consequences

### Positive
- Establishes a principle that prevents future implicit dependencies across steps
- Minimal change to SKILL.md structure
- Documented escalation path if the guardrail proves insufficient

### Negative
- Step independence guardrail is advisory, not structurally enforced; mitigated by explicit read instructions in affected steps

## References
- [Spec: decision-docs](../../openspec/specs/decision-docs/spec.md)
- [Spec: user-docs](../../openspec/specs/user-docs/spec.md)
- [ADR-042: Add enrichment reads only to Step 4, not all steps](adr-042-add-enrichment-reads-only-to-step-4-not-all-steps.md)
