# ADR-042: Add enrichment reads only to Step 4, not all steps

## Status
Accepted (2026-03-05)

## Context
ADR Context sections lost approximately 50% of their length during full regeneration because Step 4 (ADR generation) only instructed the agent to read the Decisions table from design.md. When running in the same context as Step 2, Step 4 implicitly benefited from data already loaded (research.md, proposal.md, full design.md). When running in a subagent, this data was missing, producing thin Context sections. Research evaluated three approaches: adding self-contained enrichment reads to Step 4 only, restructuring all steps into self-contained subagent instructions (Approach C), or skipping step changes. Only Step 4 had the implicit dependency problem — Step 3's regression had a different root cause (the priority rule). A full per-step restructure would add scope without immediate benefit, though it aligns with the planned transition to autonomous agents.

## Decision
Add explicit enrichment reads (full design.md, research.md, proposal.md) only to Step 4, not restructure all steps.

## Rationale
Only Step 4 has the implicit dependency problem. Making it self-contained is sufficient for now. Full per-step restructure is a valid fallback if this fix proves insufficient.

## Alternatives Considered
- Full per-step restructure into self-contained subagent instructions — more robust but unnecessary scope; deferred as future enhancement for autonomous agent readiness

## Consequences

### Positive
- Step 4 produces rich ADR Context sections regardless of execution context
- Minimal change surface addresses the specific problem

### Negative
- Enrichment reads add minor overhead to Step 4; negligible since reading 2-3 additional markdown files per archive adds less than 1 second per archive
- Step independence guardrail is advisory, not enforced; backed by explicit read instructions in Step 4

## References
- [Spec: decision-docs](../../openspec/specs/decision-docs/spec.md)
- [ADR-043: Add step independence as a guardrail, not a structural change](adr-043-add-step-independence-as-a-guardrail-not-a-structu.md)
