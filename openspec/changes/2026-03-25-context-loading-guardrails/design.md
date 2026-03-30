# Design: Context Loading Guardrails

## Context

No central guidance exists for which artifacts Claude should prioritize during the research phase. PR #52 tried an overengineered approach (29 files). This change adds context-loading guardrails directly to the schema research instruction — the simplest possible solution.

## Architecture & Components

### Single file change: `openspec/schemas/opsx-enhanced/schema.yaml`

Add context-loading guidance to the research artifact instruction (after the stale-spec check, before "Document your research findings"):

```yaml
Context loading guardrails:
- Always read: openspec/specs/*/spec.md (source of truth),
  docs/README.md (architecture overview and Key Design Decisions index)
- When relevant: docs/decisions/adr-*.md — use the Key Design
  Decisions table in docs/README.md as index; deep-dive into
  specific ADRs only when the proposed change touches an area
  with a prior decision
- Do not read: openspec/changes/archive/ (historical),
  docs/capabilities/*.md (derived from specs, redundant)
```

## Goals & Success Metrics

| Metric | Threshold | Verification |
|--------|-----------|-------------|
| Schema research instruction contains guardrails | Text present | PASS/FAIL: grep schema.yaml for "Context loading guardrails" |
| Total files changed | 1 | PASS/FAIL: count |
| Total lines added | ≤ 10 | PASS/FAIL: count |

## Non-Goals

- Constitution section or template changes
- Per-stage granular rules (research instruction covers the entry point)
- Hard enforcement or runtime validation
- Skill modifications

## Decisions

- **Schema instruction over constitution section** — The research instruction is the entry point for context loading. Placing guardrails there ensures they're read exactly when needed. Simpler than a separate constitution section.
- **Single instruction block** — All stages downstream of research inherit the context loaded during research. No need for per-stage repetition.
- **README as ADR index** — The Key Design Decisions table already lists all ADRs. Using it as an index solves Issue #17 without loading all ADR files.

## Risks & Trade-offs

- **Only covers research phase** → Acceptable because research is the context-loading entry point. Downstream artifacts build on research context.
- **Convention-based** → Consistent with all enforcement in the project (ADR-004, ADR-006).

## Assumptions

- The research phase is the primary context-loading entry point for all workflows. <!-- ASSUMPTION: Research as entry point -->
- The docs/README.md Key Design Decisions table is kept current by `/opsx:docs`. <!-- ASSUMPTION: README decisions table current -->
