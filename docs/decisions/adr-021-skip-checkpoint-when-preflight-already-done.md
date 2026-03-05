# ADR-021: Skip checkpoint when preflight already done

## Status
Accepted (2026-03-05)

## Context
The `/opsx:ff` command can be resumed after partial completion — for example, if the user previously ran ff through design and is now resuming to complete the remaining artifacts. In this resume scenario, the design review has already occurred (evidenced by preflight already existing), and pausing again for a design review would create unnecessary friction. The convention needed to handle four scenarios: fresh run (no artifacts), partial resume with design done, partial resume past design, and all artifacts done. Research confirmed that preflight existence is a reliable indicator that design review has already occurred.

## Decision
Skip the design review checkpoint when preflight artifacts already exist, indicating a prior design review has occurred.

## Rationale
Avoids unnecessary friction on resume. Preflight existence implies prior design review.

## Alternatives Considered
- Always checkpoint regardless of resume state — annoying for resume cases where design was already reviewed

## Consequences

### Positive
- Resume workflows are not interrupted by redundant review checkpoints
- Fresh runs still get the full design review pause

### Negative
- No significant negative consequences identified

## References
- [Spec: artifact-generation](../../openspec/specs/artifact-generation/spec.md)
- [ADR-020: Checkpoint after design specifically](adr-020-checkpoint-after-design-specifically.md)
