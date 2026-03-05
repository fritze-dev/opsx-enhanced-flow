# ADR-020: Checkpoint after design specifically

## Status
Accepted (2026-03-05)

## Context
The design review checkpoint needed to be placed at a specific point in the 6-stage artifact pipeline (research, proposal, specs, design, preflight, tasks). The placement determines when users get to review and provide feedback on the approach. Research into the pipeline stages showed that design is where approach and architecture decisions are finalized — it is the last point where feedback is cheap before the system invests in quality gates (preflight) and task planning. Placing the checkpoint after specs would be too early (design decisions are not yet made), while placing it after preflight would be too late (significant work has already been invested in quality review).

## Decision
Place the review checkpoint specifically after the design artifact, before preflight and tasks generation.

## Rationale
Design finalizes approach and architecture — the last point where feedback is cheap before quality gates and task planning begin.

## Alternatives Considered
- After specs — too early, design decisions are not yet made
- After preflight — too late, already invested in quality review

## Consequences

### Positive
- Users review approach and architecture decisions at the optimal moment
- Feedback is cheap at this point; changes after design require minimal rework

### Negative
- No significant negative consequences identified

## References
- [Spec: artifact-generation](../../openspec/specs/artifact-generation/spec.md)
- [ADR-019: Constitution convention only](adr-019-constitution-convention-only.md)
