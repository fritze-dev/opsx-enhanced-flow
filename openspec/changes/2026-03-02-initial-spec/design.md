# Technical Design: Initial Project Specification

## Context

This is a documentation-only bootstrap — no code changes. The plugin is fully functional with 13 skills, a 6-stage artifact pipeline, and a three-layer architecture. This change creates baseline specs so that future feature development can use the spec-driven workflow (delta specs, verify, sync, archive).

## Architecture & Components

**Affected:** Only `openspec/specs/` (created by archive after this change) and `openspec/changes/initial-spec/` (artifacts).

**Existing architecture (being documented, not changed):**

```
Three-Layer Architecture
========================
Constitution (openspec/constitution.md)
    ↓ referenced via config.yaml workflow rules
Schema (openspec/schemas/opsx-enhanced/)
    ↓ defines artifact pipeline + templates
Skills (skills/*/SKILL.md)
    ↓ 13 commands: 6 workflow + 5 governance + 2 documentation
```

**Spec organization:** 15 capabilities mapped at three levels:
- **Structural:** three-layer-architecture, artifact-pipeline, spec-format
- **Operational:** project-setup, project-bootstrap, artifact-generation, change-workspace, task-implementation, quality-gates, human-approval-gate, interactive-discovery, spec-sync
- **Supporting:** constitution-management, docs-generation, roadmap-tracking

## Goals & Success Metrics

- All 15 spec files pass `openspec validate` (Purpose + Requirements sections, SHALL/MUST in every requirement, #### for scenarios)
- Every skill's core behavior is covered by at least one Gherkin scenario
- Specs are self-contained — each covers one coherent capability without cross-spec duplication
- Archive produces clean baselines via `/opsx:sync` (no manual fixups needed)

## Non-Goals

- No code changes or feature additions
- No automated test suite setup
- No CI/CD pipeline configuration
- No implementation tasks (tasks.md will contain only the QA loop)

## Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | 15 capabilities (not one per skill) | Groups related behavior logically — e.g., continue+ff under artifact-generation, docs+changelog under docs-generation | One per skill (19 specs, too granular), monolithic (1 spec, untraceable) |
| 2 | Use `/opsx:sync` for baseline creation, not programmatic archive merge | Programmatic merge has format limitations (missing Purpose, header matching issues) | Direct `openspec archive` (failed in previous attempt) |
| 3 | Empty tasks.md (QA loop only) | No code to implement — this is a documentation bootstrap | Skip tasks entirely (breaks pipeline gate) |

## Risks & Trade-offs

| Risk | Mitigation |
|------|------------|
| Spec content may not perfectly match actual skill behavior | Verify step will check coherence; iterate in fix loop |
| 15 specs is a lot to maintain | Each is focused and self-contained; drift detection in bootstrap re-run mode |
| Sync agent may produce inconsistent baseline format | Validate all baselines after sync; fix format issues before committing |

## Open Questions

None — the architecture is established and documented in the constitution.

## Assumptions

<!-- ASSUMPTION: OpenSpec CLI 1.2.0 validate command checks for Purpose + Requirements sections -->
<!-- ASSUMPTION: Agent-driven sync via /opsx:sync correctly strips delta operation prefixes -->
