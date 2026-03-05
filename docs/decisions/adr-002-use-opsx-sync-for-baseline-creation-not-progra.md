# ADR-002: Use /opsx:sync for baseline creation, not programmatic archive merge

## Status
Accepted (2026-03-02)

## Context
After creating the initial 15 capability specs, baseline spec files needed to be produced from the delta specs in the change workspace. The OpenSpec CLI provides a programmatic archive merge, but prior attempts revealed format limitations: the merge expects `## Purpose` and `## Requirements` sections with specific header matching patterns that do not always align with the spec content. Research confirmed that the agent-driven sync via `/opsx:sync` reliably strips delta operation prefixes and produces clean baselines. The initial-spec change was documentation-only with no code changes, so the merge mechanism needed to handle pure spec content without implementation artifacts.

## Decision
Use `/opsx:sync` (agent-driven spec sync) for baseline creation instead of programmatic archive merge.

## Rationale
Programmatic merge has format limitations including missing Purpose sections and header matching issues. The agent-driven sync via `/opsx:sync` handles these cases correctly and produces clean baselines.

## Alternatives Considered
- Direct `openspec archive` programmatic merge — failed in previous attempts due to format limitations

## Consequences

### Positive
- Clean baselines are produced reliably without manual fixups
- Agent-driven sync handles edge cases in spec formatting gracefully

### Negative
- Depends on agent behavior being consistent; the sync agent may produce inconsistent baseline format in edge cases, though validation after sync mitigates this

## References
- [Spec: spec-sync](../../openspec/specs/spec-sync/spec.md)
- [Spec: spec-format](../../openspec/specs/spec-format/spec.md)
