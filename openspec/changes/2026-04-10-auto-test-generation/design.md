<!--
---
has_decisions: true
---
-->
# Technical Design: Auto-Test Generation from Gherkin Scenarios

## Context

The OpenSpec workflow produces specs with Gherkin scenarios that define testable behavior. Currently these scenarios are only used for manual verification in the review phase. This change adds a `tests` pipeline stage that generates test artifacts before implementation, enabling TDD. The plugin serves diverse consumer projects with different test frameworks, so the design must be framework-agnostic at its core.

Affected systems: WORKFLOW.md pipeline, Smart Templates (tests, tasks, review, constitution), the router's pipeline traversal logic (no changes needed — it reads the pipeline array dynamically).

## Architecture & Components

### New Components
- **`openspec/templates/tests.md`** — Smart Template defining the tests pipeline stage. Contains the instruction for parsing scenarios, reading constitution config, and generating dual-mode output. Also synced to `src/templates/tests.md`.

### Modified Components
- **`openspec/WORKFLOW.md`** — Pipeline array expands from 7 to 8 stages. `template-version` bumps from 3 to 4.
- **`openspec/templates/tasks.md`** — `requires` changes from `[preflight]` to `[tests]`. Instruction updated to reference generated tests. `template-version` bumps from 1 to 2.
- **`openspec/templates/review.md`** — New verification dimension (8th): test coverage. `template-version` bumps from 1 to 2.
- **`openspec/templates/constitution.md`** — New `## Testing` section template for consumer projects.
- **`openspec/CONSTITUTION.md`** — This project's constitution gets `## Testing` (framework: None).

### Unchanged Components
- **Router (`src/skills/workflow/SKILL.md`)** — No changes needed. The router reads the `pipeline` array dynamically from WORKFLOW.md and discovers templates via `templates_dir`. The new `tests` stage is picked up automatically.

### Data Flow
```
Specs (GIVEN/WHEN/THEN) → tests template instruction → Constitution ## Testing
                                                              ↓
                          ┌─────────────────────────────────────┐
                          │ WITH framework:                      │
                          │   → Automated test stubs (.test.ts)  │
                          │   → Manual checklist (non-automatable)│
                          │ WITHOUT framework:                   │
                          │   → Manual checklist (all scenarios)  │
                          └─────────────────────────────────────┘
                                              ↓
                                    tests.md manifest
                                    (change workspace)
```

## Goals & Success Metrics

1. **Pipeline integrity**: WORKFLOW.md pipeline array contains `tests` between `preflight` and `tasks` — PASS/FAIL
2. **Dependency chain**: tasks.md Smart Template `requires` field is `[tests]` — PASS/FAIL
3. **Template completeness**: `openspec/templates/tests.md` exists with valid frontmatter (id, requires, generates, instruction) — PASS/FAIL
4. **Template sync**: All `openspec/templates/` changes are mirrored in `src/templates/` — PASS/FAIL
5. **Review dimension**: review.md Smart Template instruction includes test coverage as 8th verification dimension — PASS/FAIL
6. **Constitution section**: Constitution template includes `## Testing` section — PASS/FAIL
7. **No router changes**: `src/skills/workflow/SKILL.md` is unchanged — PASS/FAIL

## Non-Goals

- Test runner execution (tests are generated, not run)
- Per-framework code templates (LLM generates from constitution hints)
- Incremental scenario diffing (v1 regenerates all per change)
- Init flow auto-detection of test frameworks (separate future change)

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| New pipeline stage vs. tasks sub-step | Clean TDD flow: tests exist as artifact before tasks are created. Separate stage = separate dependency tracking. | Embedding in tasks instruction — rejected: conflates planning with test generation, no separate artifact |
| Constitution for framework config | Fits three-layer architecture: project-specific config in Layer 1. Already has Tech Stack section as precedent. | WORKFLOW.md frontmatter — rejected: mixes orchestration with project config. Separate config file — rejected: new mechanism outside architecture |
| Always generate manual checklist | Every project benefits from structured verification, even with automated tests. Non-automatable scenarios need manual coverage. | Only with framework — rejected: projects without frameworks get no value. Only without framework — rejected: misses non-automatable scenarios |
| LLM-generated test stubs (not code templates) | Unbounded framework diversity makes per-framework templates infeasible. LLM already knows mainstream frameworks. Constitution provides framework hints. | Per-framework Mustache/Handlebars templates — rejected: maintenance burden, limited framework coverage |

## Risks & Trade-offs

- **Generated tests may be too generic** → Mitigation: Tests are stubs (TDD red phase). Developer fills in implementation details. Traceability comments link each test back to its scenario.
- **Manual vs automatable classification is imprecise** → Mitigation: LLM uses heuristics (visual, UX, multi-system = manual). Users can manually reclassify and add `@manual` marker.
- **Breaking pipeline for consumers with old WORKFLOW.md** → Mitigation: `template-version` bump (3→4) signals the change. `init` detects version drift and offers merge. The stage is additive.

## Open Questions

No open questions.

## Assumptions

- The router's dynamic pipeline reading is sufficient to pick up new stages without code changes. <!-- ASSUMPTION: Router dynamic discovery -->
- Consumer projects will re-run `/opsx:workflow init` after updating the plugin to get the new pipeline stage and constitution template. <!-- ASSUMPTION: Consumer re-init -->
No further assumptions beyond those marked above.
