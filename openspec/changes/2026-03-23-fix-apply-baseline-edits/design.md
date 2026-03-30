# Technical Design: Fix Apply Baseline Edits

## Context

The apply phase sometimes generates tasks that directly edit baseline specs (`openspec/specs/`), bypassing the delta-spec → sync pipeline. This is a text-instruction problem — no code logic needs changing. Three files need surgical text additions to enforce the exclusion at multiple layers.

## Architecture & Components

Three touch points, each adding a single paragraph or block:

1. **`openspec/schemas/opsx-enhanced/schema.yaml`** (task instruction, lines 180–184)
   Extend the existing IMPORTANT block to also exclude baseline spec edits from generated tasks.

2. **`skills/apply/SKILL.md`** (guardrails section, line ~143)
   Add a guardrail: "Do not modify files under `openspec/specs/` — spec changes flow through `/opsx:sync`."

3. **`openspec/specs/task-implementation/spec.md`** (new requirement)
   Add the "Baseline Spec Exclusion from Implementation Scope" requirement as defined in the delta spec.

## Goals & Success Metrics

* Task generation instruction explicitly excludes baseline spec file edits — verified by reading schema.yaml
* Apply skill guardrails include baseline spec exclusion — verified by reading SKILL.md
* Task-implementation spec includes the new requirement with scenarios — verified by reading spec.md

## Non-Goals

- Changing sync skill behavior (sync is correct as-is)
- Adding runtime validation or file-path checks in the CLI
- Modifying delta spec format or workflow

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Extend existing IMPORTANT block in schema.yaml | Co-locates all exclusion rules (sync, archive, baseline specs) | Separate instruction paragraph — less discoverable |
| Add guardrail to apply skill | Defense in depth — catches edge cases where tasks.md was manually edited | Rely solely on task generation — single point of failure |
| Add formal spec requirement | Traceability — the rule is documented as a testable requirement | Informal convention only — not verifiable |

## Risks & Trade-offs

- **Risk: AI ignores instruction** → Mitigation: Defense in depth across three layers (task gen, apply guardrail, spec requirement)
- **Risk: Over-broad exclusion** → Mitigation: Exclusion is scoped to `openspec/specs/` only; delta specs under `openspec/changes/` remain in scope

## Open Questions

No open questions.

## Assumptions

No assumptions made.
