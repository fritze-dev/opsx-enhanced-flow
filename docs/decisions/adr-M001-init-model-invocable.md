# ADR-M001: Setup is model-invocable, not user-only

## Status

Accepted (2026-03-05)

## Context

The three-layer-architecture spec originally declared that the init skill SHALL be user-only with `disable-model-invocation: true`, treating it as a one-time setup command that users invoke manually. This was based on the assumption that init should never be triggered automatically by the model.

When the init skill was actually deployed and tested, `disable-model-invocation: true` made the skill completely invisible in Claude Code — it could not be discovered or invoked at all, not even manually via `/opsx:init`. The fix-init-skill change (2026-03-02) corrected the skill itself to `disable-model-invocation: false` and updated the project-setup spec and the constitution. However, the three-layer-architecture spec was not updated, leaving a contradiction between the two specs.

This contradiction was detected during bootstrap recovery (drift detection, issue #18) when the consistency pass found the three-layer-architecture spec still asserting `disable-model-invocation: true` while the project-setup spec and the actual skill both use `false`. Beyond discoverability, the bootstrap workflow (`/opsx:bootstrap`) needs to programmatically invoke `/opsx:init` as part of its setup sequence. The init skill's idempotent design (skip-if-exists patterns, `mkdir -p`) makes repeated or automated invocation safe.

## Decision

All skills are model-invocable, including init. The init skill has `disable-model-invocation: false`, consistent with the project-setup spec and the current implementation.

## Rationale

`disable-model-invocation: true` makes the skill undiscoverable in Claude Code, not just non-auto-invocable. Bootstrap workflows need to invoke init programmatically. The three-layer-architecture spec contained a stale assumption that was never updated when the init skill was fixed.

## Alternatives Considered

- Revert init to `disable-model-invocation: true` and update project-setup spec — rejected because this breaks discoverability and the bootstrap workflow
- Add a "user-invocable but not model-invocable" mode — rejected because Claude Code does not support this distinction; the flag is binary

## Consequences

### Positive

- Spec contradiction resolved — both specs now agree on init's invocability
- Bootstrap workflow dependency on `/opsx:init` is formally documented in the spec
- Consistency between specs, constitution, and implementation restored

### Negative

- The three-layer-architecture spec no longer distinguishes init from other skills in terms of invocability. If Claude Code later supports a "user-only but discoverable" mode, this decision would need revisiting.

## References

- [Change: fix-init-skill](../../openspec/changes/2026-03-02-fix-init-skill/)
- [ADR-001: Initial Spec Organization](adr-001-initial-spec-organization.md)
- [ADR-011: Rename Init to Setup](adr-011-rename-init-to-setup.md)
- [Spec: three-layer-architecture](../../openspec/specs/three-layer-architecture/spec.md)
- [Spec: project-setup](../../openspec/specs/project-setup/spec.md)
