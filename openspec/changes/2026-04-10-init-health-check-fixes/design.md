---
has_decisions: false
---
# Technical Design: Init Health Check Fixes

## Context

The `/opsx:workflow init` re-sync health check identified three drift issues. All are text-level corrections — no architectural changes, no new dependencies, no behavioral modifications. This design is minimal because the change is purely corrective.

## Architecture & Components

| File | Change |
|------|--------|
| `openspec/specs/three-layer-architecture/spec.md` | "6-stage" → "7-stage", add "review" to pipeline list (lines 30, 37) |
| `src/templates/tasks.md` | Copy expanded instruction from `openspec/templates/tasks.md`, bump `template-version: 1` → `2` |
| `src/templates/specs/spec.md` | Copy implementation-detail prohibition paragraph from `openspec/templates/specs/spec.md`, bump `template-version: 1` → `2` |
| `openspec/WORKFLOW.md` | Add 2 comment lines after `actions:` array (custom action hints) |

No module interactions. Each file is edited independently.

## Goals & Success Metrics

* `three-layer-architecture/spec.md` references "7-stage" pipeline and lists 7 artifact IDs including "review" — PASS/FAIL
* `src/templates/tasks.md` content matches `openspec/templates/tasks.md` (instruction + body) with `template-version: 2` — PASS/FAIL
* `src/templates/specs/spec.md` content matches `openspec/templates/specs/spec.md` (instruction + body) with `template-version: 2` — PASS/FAIL
* `openspec/WORKFLOW.md` contains the custom action hint comments after `actions:` — PASS/FAIL
* Re-running `/opsx:workflow init` produces a clean report for these items — PASS/FAIL

## Non-Goals

- No behavioral changes to any workflow actions
- No changes to pipeline mechanics or artifact generation
- No constitution updates (current constitution is accurate)

## Decisions

No significant technical decisions — all changes are prescribed corrections.

## Risks & Trade-offs

- [Template version bump triggers consumer updates] → Intended behavior. Consumers with uncustomized templates get silent update; customized templates get merge prompt. This is the designed behavior per the Template Merge on Re-Init spec.

## Open Questions

No open questions.

## Assumptions

No assumptions made.
