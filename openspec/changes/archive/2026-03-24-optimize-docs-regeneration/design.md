# Technical Design: Optimize Docs Regeneration

## Context

The `/opsx:docs` skill scans all capabilities against all archives for change detection, even in the post-archive workflow where affected capabilities are already known. This change extends the argument to accept multiple capability names, letting the caller skip the full archive scan.

Two files affected:
1. `skills/docs/SKILL.md` — Input section and Step 1 change detection
2. `openspec/specs/user-docs/spec.md` — Incremental generation requirement (already in delta spec)

## Architecture & Components

Only the docs skill's Input section and Step 1 need changes. The rest of the pipeline (Steps 2-6) already works per-capability — they just need the filtered list from Step 1.

## Goals & Success Metrics

- PASS/FAIL: `/opsx:docs capability1,capability2` processes only listed capabilities
- PASS/FAIL: Listed capabilities always regenerate (no date scan)
- PASS/FAIL: No argument = existing full scan behavior (backward compatible)
- PASS/FAIL: Single capability = existing behavior (backward compatible)

## Non-Goals

- No changes to ADR or README detection logic
- No automatic change-name resolution (caller passes explicit capability names)
- No changes to archive skill

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Comma-separated list for multi-capability argument | Simple, parseable, consistent with CLI conventions | Space-separated (conflicts with shell quoting), JSON array (over-engineered) |
| Always regenerate listed capabilities (no date check) | Caller knows they're affected; date check is the bottleneck we're removing | Date check even for listed (defeats the purpose) |

## Risks & Trade-offs

- **User error**: Typos in capability names → mitigated by warn-and-skip behavior for nonexistent capabilities
- **Backward compatibility**: Empty or single argument = existing behavior → no risk

## Open Questions

No open questions.

## Assumptions

<!-- ASSUMPTION: Comma-separated parsing is sufficient; no capability name contains commas. -->
No further assumptions beyond those marked above.
