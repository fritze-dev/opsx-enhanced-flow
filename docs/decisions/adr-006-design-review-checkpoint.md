# ADR-006: Design Review Checkpoint

## Status

Accepted — 2026-03-05

## Context

The `/opsx:ff` command generated all 6 pipeline artifacts (research, proposal, specs, design, preflight, tasks) in a single uninterrupted loop without pausing for user review between stages. During real usage (GitHub Issue #9), a user had to manually interrupt the fast-forward command to discuss the approach, revealing that the workflow lacked a natural review checkpoint. The design phase is the point where approach and architecture decisions are finalized — the last moment where feedback is cheap before the system invests in quality gates (preflight) and implementation planning (tasks). Three approaches were investigated: a constitution convention only, a constitution convention combined with skill modification, and a schema-level checkpoint. The skill modification approach was rejected because it violates the skill immutability rule established in the three-layer architecture (Constitution, Schema, Skills). The schema-level checkpoint was rejected as over-engineering since the schema defines artifact order, not interaction pauses. The constitution is loaded into every AI prompt via `config.yaml`, making conventions authoritative and followed by all agents without requiring any skill code changes.

## Decision

1. **Constitution convention only, no skill changes** — Respects skill immutability as established in the three-layer architecture. The constitution is always loaded into every prompt and is authoritative, so all agents — including ff — follow the convention without modifying skill files.

2. **Checkpoint after design specifically** — Design finalizes approach and architecture decisions, making it the last point where feedback is cheap. After specs is too early (design is not yet done), and after preflight is too late (the system has already invested in a quality review).

3. **Skip checkpoint when preflight already done** — Avoids unnecessary friction on resume. If a user resumes ff past design, the existence of a preflight artifact implies a prior design review has already occurred.

4. **Update constitution before spec** — The constitution establishes the governance rule first; the spec then formalizes the behavioral change. Updating the spec first would introduce a requirement that lacks governance backing.

## Alternatives Considered

- Skill modification to add a hard pause in the ff loop — rejected because it violates the skill immutability rule in the three-layer architecture
- Schema-level checkpoint mechanism — rejected as over-engineering; the schema defines artifact order, not interaction pauses
- Checkpoint after specs (before design) — rejected because it is too early; design has not yet finalized the approach
- Checkpoint after preflight — rejected because it is too late; the system has already invested in the quality review
- Always checkpoint on resume regardless of progress — rejected because it adds unnecessary friction when preflight already implies prior review
- Spec-first update order — rejected because it would introduce a requirement without governance backing

## Consequences

### Positive

- Users get a natural review point after design where they can provide feedback before quality gates and task planning proceed
- Skill immutability is preserved — no ff skill file modifications needed
- The convention applies to all agents automatically since the constitution is injected into every prompt
- Resume workflows are not disrupted — the checkpoint is skipped when preflight already exists

### Negative

- Soft enforcement only — the constitution convention relies on agent compliance, not hard code enforcement. Mitigated by the constitution being injected into every prompt via config.yaml and agents being instructed to always read and follow it.
- Spec text contradiction during transition — until the delta spec is archived, the baseline spec says "without pausing." Mitigated by delta spec taking precedence during active change, and archiving resolving the contradiction.

## References

- [Change: design-review-checkpoint](../../openspec/changes/2026-03-05-design-review-checkpoint/)
- [Spec: artifact-generation](../../openspec/specs/artifact-generation/spec.md)
- [Spec: three-layer-architecture](../../openspec/specs/three-layer-architecture/spec.md)
